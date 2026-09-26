import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/core/network/auth_interceptor.dart';
import 'package:flutter_starter/core/network/network_failure_mapper.dart';
import 'package:flutter_starter/core/persistence/app_database.dart'
    show AppDatabase, SampleItemsCompanion;
import 'package:flutter_starter/core/persistence/app_preferences.dart';
import 'package:flutter_starter/core/session/session_manager.dart';
import 'package:flutter_starter/core/session/session_snapshot.dart';
import 'package:flutter_starter/core/session/token_refresh.dart';

import '../persistence/app_preferences_test.dart' show MemoryPreferences;
import '../session/session_manager_test.dart' show MemorySecureStorage;
import 'token_refresh_test.dart' show CallbackAdapter;

ResponseBody _jsonResponse(int status, [String body = '{}']) =>
    ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

void main() {
  late AppDatabase database;
  late MemorySecureStorage secure;
  late SessionManager session;
  late Dio appDio;
  late Dio refreshDio;
  late DioTokenRefresher refresher;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    secure = MemorySecureStorage();
    session = SessionManager(
      secure,
      AppPreferences(MemoryPreferences()),
      database,
    );
    await session.establishSession(
      accountId: 'alice',
      accessToken: 'old-access',
      refreshToken: 'refresh-secret',
    );
    appDio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    refreshDio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    refresher = DioTokenRefresher(refreshDio);
    appDio.interceptors.add(AuthInterceptor(appDio, session, refresher));
  });
  tearDown(() async {
    appDio.close(force: true);
    refreshDio.close(force: true);
    await session.close();
    await database.close();
  });

  test(
    'concurrent 401 responses produce exactly one refresh request',
    () async {
      final allOldRequests = Completer<void>();
      final refreshStarted = Completer<void>();
      final releaseRefresh = Completer<ResponseBody>();
      var oldRequests = 0;
      var refreshRequests = 0;
      var retriedRequests = 0;
      appDio.httpClientAdapter = CallbackAdapter((options, body) async {
        if (options.headers['Authorization'] == 'Bearer old-access') {
          oldRequests++;
          if (oldRequests == 3) allOldRequests.complete();
          return _jsonResponse(401);
        }
        expect(options.headers['Authorization'], 'Bearer new-access');
        retriedRequests++;
        return _jsonResponse(200);
      });
      refreshDio.httpClientAdapter = CallbackAdapter((options, body) {
        expect(options.path, '/auth/refresh');
        expect(jsonDecode(utf8.decode(body))['refreshToken'], 'refresh-secret');
        refreshRequests++;
        refreshStarted.complete();
        return releaseRefresh.future;
      });

      final requests = [
        for (var i = 0; i < 3; i++)
          appDio.get<Map<String, dynamic>>('/item/$i'),
      ];
      await allOldRequests.future;
      await refreshStarted.future;
      expect(refreshRequests, 1);
      releaseRefresh.complete(
        _jsonResponse(200, '{"accessToken":"new-access"}'),
      );
      final responses = await Future.wait(requests);
      expect(responses.map((response) => response.statusCode), [200, 200, 200]);
      expect(refreshRequests, 1);
      expect(retriedRequests, 3);
      expect(session.accessToken, 'new-access');
    },
  );

  test('a late old-token 401 retries with the current token', () async {
    final secondOldRequest = Completer<void>();
    final releaseSecond401 = Completer<ResponseBody>();
    var oldRequests = 0;
    var refreshRequests = 0;
    var retriedRequests = 0;
    appDio.httpClientAdapter = CallbackAdapter((options, body) async {
      if (options.headers['Authorization'] == 'Bearer old-access') {
        oldRequests++;
        if (oldRequests == 2) {
          secondOldRequest.complete();
          return releaseSecond401.future;
        }
        return _jsonResponse(401);
      }
      expect(options.headers['Authorization'], 'Bearer new-access');
      retriedRequests++;
      return _jsonResponse(200);
    });
    refreshDio.httpClientAdapter = CallbackAdapter((options, body) async {
      refreshRequests++;
      return _jsonResponse(200, '{"accessToken":"new-access"}');
    });

    final first = appDio.get<Map<String, dynamic>>('/first');
    final second = appDio.get<Map<String, dynamic>>('/second');
    await secondOldRequest.future;
    expect((await first).statusCode, 200);
    expect(session.accessToken, 'new-access');
    releaseSecond401.complete(_jsonResponse(401));
    expect((await second).statusCode, 200);
    expect(refreshRequests, 1);
    expect(retriedRequests, 2);
  });

  test(
    'definitive refresh rejection signs out and clears account cache',
    () async {
      await database.markFetched('alice', 'feed', DateTime.utc(2026));
      final oldEpoch = session.snapshot.epoch;
      appDio.httpClientAdapter = CallbackAdapter(
        (options, body) async => _jsonResponse(401),
      );
      refreshDio.httpClientAdapter = CallbackAdapter(
        (options, body) async => _jsonResponse(401),
      );

      final error = await appDio
          .get<void>('/private')
          .then<Object>(
            (_) => fail('Expected authentication failure'),
            onError: (Object error) => error,
          );
      expect(error, isA<DioException>());
      // Logout cancels the original request while expiring its session.
      expect((error as DioException).type, DioExceptionType.cancel);
      // The request is cancelled as soon as logout starts; await cleanup too.
      await session.refreshAccessToken(refresher);
      expect(session.snapshot.status, SessionStatus.unauthenticated);
      expect(session.snapshot.epoch, greaterThan(oldEpoch));
      expect(await database.metadataFor('alice', 'feed'), isNull);
      expect(secure.values, isEmpty);
    },
  );

  test('refresh transport failure retains offline session and cache', () async {
    await database.markFetched('alice', 'feed', DateTime.utc(2026));
    final oldEpoch = session.snapshot.epoch;
    appDio.httpClientAdapter = CallbackAdapter(
      (options, body) async => _jsonResponse(401),
    );
    refreshDio.httpClientAdapter = CallbackAdapter((options, body) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });

    final error = await appDio
        .get<void>('/private')
        .then<Object>(
          (_) => fail('Expected network failure'),
          onError: (Object error) => error,
        );
    expect(error, isA<DioException>());
    final failure = mapNetworkError(error);
    expect(failure, isA<NetworkFailure>());
    expect((failure as NetworkFailure).kind, NetworkFailureKind.connection);
    expect(session.snapshot.status, SessionStatus.authenticatedOffline);
    expect(session.snapshot.epoch, oldEpoch);
    expect(await database.metadataFor('alice', 'feed'), isNotNull);
    expect(secure.values['session.envelope'], isNotNull);
  });

  test(
    'offline cold start retains the local identity and cached rows',
    () async {
      final coldSecure = MemorySecureStorage();
      coldSecure.values['session.envelope'] = jsonEncode({
        'accountId': 'alice',
        'refreshToken': 'saved-refresh',
      });
      await database.replaceSampleItems('alice', [
        SampleItemsCompanion.insert(
          accountId: 'alice',
          itemId: 'cached',
          title: 'Cached item',
          position: 0,
        ),
      ]);
      await database.markFetched('alice', 'sample.items', DateTime.utc(2026));
      final coldSession = SessionManager(
        coldSecure,
        AppPreferences(MemoryPreferences()),
        database,
      );
      addTearDown(coldSession.close);
      var refreshRequests = 0;
      refreshDio.httpClientAdapter = CallbackAdapter((options, body) {
        refreshRequests++;
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      await coldSession.restore(DioTokenRefresher(refreshDio));

      expect(refreshRequests, 1);
      expect(coldSession.snapshot.status, SessionStatus.authenticatedOffline);
      expect(coldSession.snapshot.accountId, 'alice');
      expect(coldSession.accessToken, isNull);
      expect(
        (await database.sampleItemsFor('alice')).single.title,
        'Cached item',
      );
      expect(await database.metadataFor('alice', 'sample.items'), isNotNull);
      expect(coldSecure.values['session.envelope'], isNotNull);
    },
  );
}
