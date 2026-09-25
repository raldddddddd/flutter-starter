import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/app_failure.dart';
import '../persistence/app_database.dart';
import '../persistence/app_preferences.dart';
import 'session_snapshot.dart';
import 'token_refresh.dart';

/// Owns local session identity and tokens. No authentication repository is
/// needed by the network interceptor.
final class SessionManager {
  SessionManager(this._secureStorage, this._preferences, this._database);

  static const _envelopeKey = 'session.envelope';

  final FlutterSecureStorage _secureStorage;
  final AppPreferences _preferences;
  final AppDatabase _database;
  final _changes = StreamController<SessionSnapshot>.broadcast(sync: true);
  final _requestTokens = <CancelToken>{};

  SessionSnapshot _snapshot = const SessionSnapshot(
    status: SessionStatus.restoring,
    epoch: 0,
  );
  String? _accessToken;
  String? _refreshToken;
  Future<AppFailure?>? _refreshInFlight;
  int? _refreshEpoch;
  Future<void> _secureTail = Future<void>.value();

  SessionSnapshot get snapshot => _snapshot;
  String? get accessToken => _accessToken;

  bool isCurrentSession({required String accountId, required int epoch}) =>
      _snapshot.isAuthenticated &&
      _snapshot.accountId == accountId &&
      _snapshot.epoch == epoch;

  Stream<SessionSnapshot> get changes => Stream.multi((controller) {
    final subscription = _changes.stream.listen(controller.add);
    controller.add(_snapshot);
    controller.onCancel = subscription.cancel;
  });

  void _setState(SessionStatus status, {String? accountId}) {
    _snapshot = SessionSnapshot(
      status: status,
      epoch: _snapshot.epoch,
      accountId: accountId,
    );
    if (!_changes.isClosed) _changes.add(_snapshot);
  }

  void _advanceEpoch() {
    _snapshot = SessionSnapshot(
      status: _snapshot.status,
      epoch: _snapshot.epoch + 1,
      accountId: _snapshot.accountId,
    );
    if (!_changes.isClosed) _changes.add(_snapshot);
  }

  void trackRequest(CancelToken token) => _requestTokens.add(token);
  void releaseRequest(CancelToken? token) {
    if (token != null) _requestTokens.remove(token);
  }

  void _cancelRequests() {
    for (final token in _requestTokens) {
      token.cancel('Session changed');
    }
    _requestTokens.clear();
  }

  /// Used by a future login adapter after it obtains a real session.
  Future<void> establishSession({
    required String accountId,
    required String accessToken,
    required String refreshToken,
  }) async {
    if (accountId.isEmpty || accessToken.isEmpty || refreshToken.isEmpty) {
      throw ArgumentError('A complete session is required.');
    }
    _advanceEpoch();
    _setState(SessionStatus.restoring);
    _cancelRequests();
    _accessToken = null;
    _refreshToken = null;
    try {
      await _writeEnvelope(accountId, refreshToken);
    } catch (_) {
      _setState(SessionStatus.unauthenticated);
      rethrow;
    }
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _setState(SessionStatus.authenticatedOnline, accountId: accountId);
  }

  /// Reads only local material first. A network outage preserves cached access.
  Future<void> restore(TokenRefresher refresher) async {
    if (_snapshot.status != SessionStatus.restoring &&
        _snapshot.status != SessionStatus.authenticatedOffline) {
      return;
    }
    if (_refreshToken == null) {
      final epoch = _snapshot.epoch;
      try {
        final encoded = await _secureStorage.read(key: _envelopeKey);
        if (_snapshot.epoch != epoch) return;
        if (encoded == null) {
          _setState(SessionStatus.unauthenticated);
          return;
        }
        final decoded = jsonDecode(encoded);
        if (decoded is! Map<String, dynamic> ||
            decoded['accountId'] is! String ||
            decoded['refreshToken'] is! String ||
            (decoded['accountId'] as String).isEmpty ||
            (decoded['refreshToken'] as String).isEmpty) {
          _setState(SessionStatus.unauthenticated);
          return;
        }
        _refreshToken = decoded['refreshToken'] as String;
        _setState(
          SessionStatus.restoring,
          accountId: decoded['accountId'] as String,
        );
      } catch (_) {
        if (_snapshot.epoch != epoch) return;
        // Secure storage is losable. A missing/corrupt envelope is signed out.
        _setState(SessionStatus.unauthenticated);
        return;
      }
    }
    await refreshAccessToken(refresher);
  }

  Future<AppFailure?> refreshAccessToken(TokenRefresher refresher) {
    final epoch = _snapshot.epoch;
    if (_refreshEpoch == epoch && _refreshInFlight != null) {
      return _refreshInFlight!;
    }
    final operation = _refresh(refresher);
    _refreshEpoch = epoch;
    _refreshInFlight = operation;
    operation.whenComplete(() {
      if (identical(_refreshInFlight, operation)) {
        _refreshInFlight = null;
        _refreshEpoch = null;
      }
    }).ignore();
    return operation;
  }

  Future<AppFailure?> _refresh(TokenRefresher refresher) async {
    final refreshToken = _refreshToken;
    final accountId = _snapshot.accountId;
    final epoch = _snapshot.epoch;
    if (refreshToken == null || accountId == null) {
      return const AuthenticationFailure();
    }
    RefreshOutcome outcome;
    try {
      outcome = await refresher.refresh(refreshToken);
    } catch (error, stackTrace) {
      outcome = RefreshUnavailable(
        NetworkFailure(cause: error, stackTrace: stackTrace),
      );
    }
    if (_snapshot.epoch != epoch || _snapshot.accountId != accountId) {
      return const AuthenticationFailure();
    }
    switch (outcome) {
      case RefreshAccepted(:final accessToken, :final refreshToken):
        if (accessToken.isEmpty) return const AuthenticationFailure();
        if (refreshToken != null && refreshToken != _refreshToken) {
          try {
            await _writeEnvelope(accountId, refreshToken);
          } catch (error, stackTrace) {
            _accessToken = null;
            _setState(SessionStatus.authenticatedOffline, accountId: accountId);
            return StorageFailure(cause: error, stackTrace: stackTrace);
          }
          _refreshToken = refreshToken;
        }
        if (_snapshot.epoch != epoch || _snapshot.accountId != accountId) {
          return const AuthenticationFailure();
        }
        _accessToken = accessToken;
        _setState(SessionStatus.authenticatedOnline, accountId: accountId);
        return null;
      case RefreshRejected():
        await logout();
        return const AuthenticationFailure();
      case RefreshUnavailable(:final failure):
        _accessToken = null;
        _setState(SessionStatus.authenticatedOffline, accountId: accountId);
        return failure;
    }
  }

  /// The epoch and visible state change before any asynchronous cleanup.
  Future<void> logout() async {
    final oldAccountId = _snapshot.accountId;
    _advanceEpoch();
    _setState(SessionStatus.unauthenticated);
    _cancelRequests();
    _accessToken = null;
    _refreshToken = null;

    Object? firstError;
    StackTrace? firstStack;
    Future<void> clean(Future<void> Function() action) async {
      try {
        await action();
      } catch (error, stackTrace) {
        firstError ??= error;
        firstStack ??= stackTrace;
      }
    }

    await clean(
      () => _queueSecure(() => _secureStorage.delete(key: _envelopeKey)),
    );
    if (oldAccountId != null) {
      await clean(() async {
        await _database.clearAccountMetadata(oldAccountId);
      });
    }
    await clean(_preferences.clearUser);
    if (firstError case final error?) {
      Error.throwWithStackTrace(error, firstStack!);
    }
  }

  Future<void> _writeEnvelope(String accountId, String refreshToken) =>
      _queueSecure(
        () => _secureStorage.write(
          key: _envelopeKey,
          value: jsonEncode({
            'accountId': accountId,
            'refreshToken': refreshToken,
          }),
        ),
      );

  Future<void> _queueSecure(Future<void> Function() action) {
    final operation = _secureTail.then((_) => action());
    _secureTail = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> close() async {
    _cancelRequests();
    await _changes.close();
  }
}
