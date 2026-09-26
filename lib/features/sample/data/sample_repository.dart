import 'package:dio/dio.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/network_failure_mapper.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/persistence/app_database.dart'
    show AppDatabase, CacheMetadataEntry, SampleItemsCompanion;
import '../../../core/session/session_manager.dart';
import '../sample_item.dart';
import 'sample_api_service.dart';

final class _StaleSampleSession implements Exception {}

/// One authoritative list scope per account; API and cache writes stay here.
final class SampleRepository {
  SampleRepository(
    this._database,
    this._api,
    this._session, {
    this._freshness = const Duration(minutes: 5),
    DateTime Function()? now,
    this.logger = const DeveloperLogger(),
  }) : _now = now ?? DateTime.now;

  static const resourceKey = 'sample.items';

  final AppDatabase _database;
  final SampleApiService _api;
  final SessionManager _session;
  final Duration _freshness;
  final DateTime Function() _now;
  final AppLogger logger;
  final _inFlight = <(String, int), Future<Result<void>>>{};

  Stream<List<SampleItem>> watchItems(String accountId) => _database
      .watchSampleItems(accountId)
      .map(
        (rows) => [
          for (final row in rows) SampleItem(id: row.itemId, title: row.title),
        ],
      );

  Stream<CacheMetadataEntry?> watchMetadata(String accountId) =>
      _database.watchMetadata(accountId, resourceKey);

  Future<Result<void>> refreshIfStale() => _refresh(force: false);

  Future<Result<void>> forceRefresh() => _refresh(force: true);

  Future<Result<void>> _refresh({required bool force}) {
    final snapshot = _session.snapshot;
    final accountId = snapshot.accountId;
    if (!snapshot.isAuthenticated || accountId == null) {
      return Future.value(const Failure<void>(AuthenticationFailure()));
    }
    final key = (accountId, snapshot.epoch);
    final existing = _inFlight[key];
    if (existing != null) return existing;
    final operation = _performRefresh(accountId, snapshot.epoch, force: force);
    _inFlight[key] = operation;
    operation.whenComplete(() {
      if (identical(_inFlight[key], operation)) {
        _inFlight.remove(key);
      }
    }).ignore();
    return operation;
  }

  Future<Result<void>> _performRefresh(
    String accountId,
    int epoch, {
    required bool force,
  }) async {
    final cancelToken = CancelToken();
    _session.trackRequest(cancelToken);
    try {
      if (!force) {
        final metadata = await _database.metadataFor(accountId, resourceKey);
        if (metadata != null &&
            _now().difference(metadata.lastFetchedAt) < _freshness) {
          if (!_session.isCurrentSession(accountId: accountId, epoch: epoch)) {
            return const Failure<void>(AuthenticationFailure());
          }
          return const Success<void>(null);
        }
      }
      final fetched = await _api.fetchItems(cancelToken: cancelToken);
      await _database.transaction(() async {
        if (!_session.isCurrentSession(accountId: accountId, epoch: epoch)) {
          throw _StaleSampleSession();
        }
        await _database.replaceSampleItems(accountId, [
          for (final (position, item) in fetched.indexed)
            SampleItemsCompanion.insert(
              accountId: accountId,
              itemId: item.id,
              title: item.title,
              position: position,
            ),
        ]);
        await _database.markFetched(accountId, resourceKey, _now());
        if (!_session.isCurrentSession(accountId: accountId, epoch: epoch)) {
          throw _StaleSampleSession();
        }
      });
      return const Success<void>(null);
    } on _StaleSampleSession {
      return const Failure<void>(AuthenticationFailure());
    } catch (error, stackTrace) {
      return Failure<void>(_failure(error, stackTrace));
    } finally {
      _session.releaseRequest(cancelToken);
    }
  }

  Future<Result<SampleItem>> createItem(String title) async {
    final snapshot = _session.snapshot;
    final accountId = snapshot.accountId;
    if (!snapshot.isAuthenticated || accountId == null) {
      return const Failure<SampleItem>(AuthenticationFailure());
    }
    final cancelToken = CancelToken();
    _session.trackRequest(cancelToken);
    try {
      final created = await _api.createItem(title, cancelToken: cancelToken);
      await _database.transaction(() async {
        if (!_session.isCurrentSession(
          accountId: accountId,
          epoch: snapshot.epoch,
        )) {
          throw _StaleSampleSession();
        }
        final current = await _database.sampleItemsFor(accountId);
        await _database
            .into(_database.sampleItems)
            .insertOnConflictUpdate(
              SampleItemsCompanion.insert(
                accountId: accountId,
                itemId: created.id,
                title: created.title,
                position: current.length,
              ),
            );
        if (!_session.isCurrentSession(
          accountId: accountId,
          epoch: snapshot.epoch,
        )) {
          throw _StaleSampleSession();
        }
      });
      return Success<SampleItem>(created);
    } on _StaleSampleSession {
      return const Failure<SampleItem>(AuthenticationFailure());
    } catch (error, stackTrace) {
      return Failure<SampleItem>(_failure(error, stackTrace));
    } finally {
      _session.releaseRequest(cancelToken);
    }
  }

  AppFailure _failure(Object error, StackTrace stackTrace) {
    final failure = mapNetworkError(error, stackTrace: stackTrace);
    if (failure is UnknownFailure) {
      logger.error(
        'Unexpected sample repository failure',
        error: failure.cause!,
        stackTrace: failure.stackTrace ?? stackTrace,
      );
    }
    return failure;
  }
}
