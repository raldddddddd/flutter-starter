import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/core/errors/result.dart';
import 'package:flutter_starter/core/persistence/app_database.dart'
    show AppDatabase;
import 'package:flutter_starter/core/persistence/app_preferences.dart';
import 'package:flutter_starter/core/session/session_manager.dart';
import 'package:flutter_starter/features/sample/data/fake_sample_api_service.dart';
import 'package:flutter_starter/features/sample/data/sample_api_service.dart';
import 'package:flutter_starter/features/sample/data/sample_repository.dart';
import 'package:flutter_starter/features/sample/sample_item.dart';

import '../persistence/app_preferences_test.dart' show MemoryPreferences;
import '../session/session_manager_test.dart' show MemorySecureStorage;
import '../errors/provider_error_test.dart' show RecordingLogger;

final class DelayedSampleApi implements SampleApiService {
  final fetch = Completer<List<SampleItem>>();
  final create = Completer<SampleItem>();

  @override
  Future<List<SampleItem>> fetchItems({CancelToken? cancelToken}) =>
      fetch.future;

  @override
  Future<SampleItem> createItem(String title, {CancelToken? cancelToken}) =>
      create.future;
}

void main() {
  late AppDatabase database;
  late SessionManager session;
  late FakeSampleApiService api;
  late SampleRepository repository;
  late RecordingLogger logger;
  var now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    session = SessionManager(
      MemorySecureStorage(),
      AppPreferences(MemoryPreferences()),
      database,
    );
    await session.establishSession(
      accountId: 'alice',
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    now = DateTime.utc(2026, 1, 1);
    api = FakeSampleApiService(latency: Duration.zero);
    logger = RecordingLogger();
    repository = SampleRepository(
      database,
      api,
      session,
      now: () => now,
      logger: logger,
    );
  });
  tearDown(() async {
    await session.close();
    await database.close();
  });

  test(
    'refresh stores rows and metadata, respects freshness, and forces',
    () async {
      expect(await repository.refreshIfStale(), isA<Success<void>>());
      expect(api.requestCount, 1);
      expect((await database.sampleItemsFor('alice')).length, 2);
      expect(
        (await database.metadataFor(
          'alice',
          SampleRepository.resourceKey,
        ))?.lastFetchedAt.isAtSameMomentAs(now),
        isTrue,
      );
      expect(await repository.refreshIfStale(), isA<Success<void>>());
      expect(api.requestCount, 1);
      api.items = const [SampleItem(id: 'three', title: 'Third')];
      expect(await repository.forceRefresh(), isA<Success<void>>());
      expect(api.requestCount, 2);
      expect((await database.sampleItemsFor('alice')).map((e) => e.itemId), [
        'three',
      ]);
    },
  );

  test('stale refresh and successful empty result replace the list', () async {
    await repository.refreshIfStale();
    now = now.add(const Duration(minutes: 6));
    api.items = [];
    expect(await repository.refreshIfStale(), isA<Success<void>>());
    expect(await database.sampleItemsFor('alice'), isEmpty);
    expect(
      await database.metadataFor('alice', SampleRepository.resourceKey),
      isNotNull,
    );
  });

  test('duplicate refreshes coalesce and failures preserve cache', () async {
    api.latency = const Duration(milliseconds: 20);
    final first = repository.forceRefresh();
    final second = repository.forceRefresh();
    expect(identical(first, second), isTrue);
    await Future.wait([first, second]);
    expect(api.requestCount, 1);
    api.outcome = FakeSampleOutcome.networkFailure;
    expect(
      (await repository.forceRefresh() as Failure<void>).failure,
      isA<NetworkFailure>(),
    );
    expect((await database.sampleItemsFor('alice')).length, 2);
    api.outcome = FakeSampleOutcome.serverFailure;
    expect(
      (await repository.forceRefresh() as Failure<void>).failure,
      isA<ServerFailure>(),
    );
    api.outcome = FakeSampleOutcome.unauthorized;
    expect(
      (await repository.forceRefresh() as Failure<void>).failure,
      isA<AuthenticationFailure>(),
    );
    expect(logger.errors, isEmpty);
  });

  test('write action inserts returned server item', () async {
    await repository.refreshIfStale();
    final result = await repository.createItem('New');
    expect((result as Success<SampleItem>).value.title, 'New');
    expect((await database.sampleItemsFor('alice')).last.title, 'New');
  });

  test(
    'late refresh and write responses cannot recreate logged-out cache',
    () async {
      final delayed = DelayedSampleApi();
      final guarded = SampleRepository(database, delayed, session);
      final refresh = guarded.forceRefresh();
      final write = guarded.createItem('Late');
      await session.logout();
      delayed.fetch.complete(const [SampleItem(id: 'late', title: 'Late')]);
      delayed.create.complete(
        const SampleItem(id: 'late-write', title: 'Late'),
      );
      expect(
        (await refresh as Failure<void>).failure,
        isA<AuthenticationFailure>(),
      );
      expect(
        (await write as Failure<SampleItem>).failure,
        isA<AuthenticationFailure>(),
      );
      expect(await database.sampleItemsFor('alice'), isEmpty);
      expect(
        await database.metadataFor('alice', SampleRepository.resourceKey),
        isNull,
      );
    },
  );

  test(
    'refresh and create log unexpected failures with original stacks',
    () async {
      final delayed = DelayedSampleApi();
      final observed = SampleRepository(
        database,
        delayed,
        session,
        logger: logger,
      );
      final error = StateError('malformed DTO');
      final stack = StackTrace.current;
      final refresh = observed.forceRefresh();
      delayed.fetch.completeError(error, stack);
      final refreshFailure = (await refresh as Failure<void>).failure;
      expect(refreshFailure, isA<UnknownFailure>());
      expect(refreshFailure.cause, same(error));
      final create = observed.createItem('broken');
      delayed.create.completeError(error, stack);
      expect(
        (await create as Failure<SampleItem>).failure,
        isA<UnknownFailure>(),
      );
      expect(logger.errors, hasLength(2));
      for (final entry in logger.errors) {
        expect(entry.error, same(error));
        expect(entry.stackTrace, same(stack));
      }
    },
  );
}
