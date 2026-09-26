import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/core/persistence/app_database.dart';
import 'package:flutter_starter/core/persistence/app_preferences.dart';
import 'package:flutter_starter/core/session/session_manager.dart';
import 'package:flutter_starter/core/session/session_snapshot.dart';
import 'package:flutter_starter/core/session/token_refresh.dart';

import '../persistence/app_preferences_test.dart' show MemoryPreferences;

class MemorySecureStorage extends Fake implements FlutterSecureStorage {
  final values = <String, String>{};
  bool failRead = false;
  Completer<void>? writeGate;
  Completer<void>? writeStarted;
  Object? writeError;
  Completer<void>? deleteGate;
  Completer<void>? deleteStarted;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    final gate = writeGate;
    if (writeStarted case final started? when !started.isCompleted) {
      started.complete();
    }
    if (gate != null) await gate.future;
    if (writeError case final error?) throw error;
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (failRead) throw StateError('secure storage unavailable');
    return values[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (deleteStarted case final started? when !started.isCompleted) {
      started.complete();
    }
    if (deleteGate case final gate?) await gate.future;
    values.remove(key);
  }
}

class FixedRefresher implements TokenRefresher {
  FixedRefresher(this.outcome);

  final RefreshOutcome outcome;
  int calls = 0;

  @override
  Future<RefreshOutcome> refresh(String refreshToken) async {
    calls++;
    return outcome;
  }
}

void main() {
  late MemorySecureStorage secure;
  late AppPreferences preferences;
  late AppDatabase database;
  late SessionManager session;

  setUp(() {
    secure = MemorySecureStorage();
    preferences = AppPreferences(MemoryPreferences());
    database = AppDatabase(NativeDatabase.memory());
    session = SessionManager(secure, preferences, database);
  });
  tearDown(() async {
    await session.close();
    await database.close();
  });

  test('missing secure material restores as unauthenticated', () async {
    final refresher = FixedRefresher(const RefreshAccepted('unused'));
    await session.restore(refresher);
    expect(session.snapshot.status, SessionStatus.unauthenticated);
    expect(refresher.calls, 0);
  });

  test('lost secure storage is treated as signed out', () async {
    secure.failRead = true;
    await session.restore(FixedRefresher(const RefreshAccepted('unused')));
    expect(session.snapshot.status, SessionStatus.unauthenticated);
  });

  test('offline cold start keeps account scope and cached records', () async {
    secure.values['session.envelope'] = jsonEncode({
      'accountId': 'alice',
      'refreshToken': 'refresh-secret',
    });
    await database.markFetched('alice', 'feed', DateTime.utc(2026));
    await session.restore(
      FixedRefresher(
        const RefreshUnavailable(
          NetworkFailure(kind: NetworkFailureKind.connection),
        ),
      ),
    );

    expect(session.snapshot.status, SessionStatus.authenticatedOffline);
    expect(session.snapshot.accountId, 'alice');
    expect(session.accessToken, isNull);
    expect(await database.metadataFor('alice', 'feed'), isNotNull);
    expect(secure.values['session.envelope'], isNotNull);
  });

  test('accepted restoration rotates token and becomes online', () async {
    secure.values['session.envelope'] = jsonEncode({
      'accountId': 'alice',
      'refreshToken': 'old',
    });
    await session.restore(
      FixedRefresher(const RefreshAccepted('access', refreshToken: 'new')),
    );

    expect(session.snapshot.status, SessionStatus.authenticatedOnline);
    expect(session.accessToken, 'access');
    expect(
      jsonDecode(secure.values['session.envelope']!)['refreshToken'],
      'new',
    );
  });

  test('definitive refresh rejection signs out and clears cache', () async {
    await session.establishSession(
      accountId: 'alice',
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    await database.markFetched('alice', 'feed', DateTime.utc(2026));
    final epoch = session.snapshot.epoch;
    final failure = await session.refreshAccessToken(
      FixedRefresher(const RefreshRejected()),
    );

    expect(failure, isA<AuthenticationFailure>());
    expect(session.snapshot.status, SessionStatus.unauthenticated);
    expect(session.snapshot.epoch, greaterThan(epoch));
    expect(secure.values, isEmpty);
    expect(await database.metadataFor('alice', 'feed'), isNull);
  });

  test(
    'logout advances epoch first, cancels requests and clears user scope',
    () async {
      await session.establishSession(
        accountId: 'alice',
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      await preferences.setUserString('filter', 'mine');
      await preferences.setDeviceString('theme', 'dark');
      await database.markFetched('alice', 'feed', DateTime.utc(2026));
      final token = CancelToken();
      session.trackRequest(token);
      final oldEpoch = session.snapshot.epoch;
      expect(
        session.isCurrentSession(accountId: 'alice', epoch: oldEpoch),
        isTrue,
      );

      await session.logout();

      expect(session.snapshot.epoch, greaterThan(oldEpoch));
      expect(
        session.isCurrentSession(accountId: 'alice', epoch: oldEpoch),
        isFalse,
      );
      expect(session.snapshot.status, SessionStatus.unauthenticated);
      expect(token.isCancelled, isTrue);
      expect(session.accessToken, isNull);
      expect(secure.values, isEmpty);
      expect(await database.metadataFor('alice', 'feed'), isNull);
      expect(await preferences.getUserString('filter'), isNull);
      expect(await preferences.getDeviceString('theme'), 'dark');
    },
  );

  test('replacing identity advances epoch', () async {
    await session.establishSession(
      accountId: 'alice',
      accessToken: 'a',
      refreshToken: 'ra',
    );
    final epoch = session.snapshot.epoch;
    await preferences.setUserString('filter', 'alice-private');
    await preferences.setDeviceString('theme', 'dark');
    await database.markFetched('alice', 'feed', DateTime.utc(2026));
    await session.establishSession(
      accountId: 'bob',
      accessToken: 'b',
      refreshToken: 'rb',
    );
    expect(session.snapshot.epoch, greaterThan(epoch));
    expect(session.snapshot.accountId, 'bob');
    expect(await preferences.getUserString('filter'), isNull);
    expect(await preferences.getDeviceString('theme'), 'dark');
    expect(await database.metadataFor('alice', 'feed'), isNull);
  });

  for (final fails in [false, true]) {
    test('logout wins over pending login (write fails: $fails)', () async {
      secure.writeGate = Completer<void>();
      secure.writeStarted = Completer<void>();
      if (fails) secure.writeError = StateError('write failed');
      final login = session.establishSession(
        accountId: 'alice',
        accessToken: 'a',
        refreshToken: 'r',
      );
      await secure.writeStarted!.future;
      final logout = session.logout();
      final epoch = session.snapshot.epoch;
      secure.writeGate!.complete();
      await login;
      await logout;
      expect(session.snapshot.status, SessionStatus.unauthenticated);
      expect(session.snapshot.epoch, epoch);
      expect(session.snapshot.accountId, isNull);
      expect(session.accessToken, isNull);
      expect(secure.values, isEmpty);
      expect(
        session.isCurrentSession(accountId: 'alice', epoch: epoch),
        isFalse,
      );
    });

    test(
      'logout wins over rotated token persistence (write fails: $fails)',
      () async {
        await session.establishSession(
          accountId: 'alice',
          accessToken: 'a',
          refreshToken: 'old',
        );
        secure.writeGate = Completer<void>();
        secure.writeStarted = Completer<void>();
        if (fails) secure.writeError = StateError('rotation failed');
        final refresh = session.refreshAccessToken(
          FixedRefresher(
            const RefreshAccepted('new-access', refreshToken: 'new'),
          ),
        );
        await secure.writeStarted!.future;
        final logout = session.logout();
        final epoch = session.snapshot.epoch;
        secure.writeGate!.complete();
        expect(await refresh, isA<AuthenticationFailure>());
        await logout;
        expect(session.snapshot.status, SessionStatus.unauthenticated);
        expect(session.snapshot.accountId, isNull);
        expect(session.accessToken, isNull);
        expect(secure.values, isEmpty);
        expect(
          session.isCurrentSession(accountId: 'alice', epoch: epoch),
          isFalse,
        );
      },
    );
  }

  for (final envelope in [null, 'invalid json', '{}']) {
    test(
      'missing/corrupt envelope clears unknown user scope: $envelope',
      () async {
        if (envelope != null) secure.values['session.envelope'] = envelope;
        await preferences.setUserString('filter', 'alice-private');
        await preferences.setDeviceString('theme', 'dark');
        await database.markFetched('alice', 'feed', DateTime.utc(2026));
        await database.markFetched('other', 'feed', DateTime.utc(2026));
        await database
            .into(database.sampleItems)
            .insert(
              SampleItemsCompanion.insert(
                accountId: 'alice',
                itemId: 'private',
                title: 'Private',
                position: 0,
              ),
            );
        await session.restore(FixedRefresher(const RefreshAccepted('unused')));
        expect(session.snapshot.status, SessionStatus.unauthenticated);
        expect(await preferences.getUserString('filter'), isNull);
        expect(await preferences.getDeviceString('theme'), 'dark');
        expect(await database.metadataFor('alice', 'feed'), isNull);
        expect(await database.metadataFor('other', 'feed'), isNull);
        expect(await database.sampleItemsFor('alice'), isEmpty);
        await session.establishSession(
          accountId: 'bob',
          accessToken: 'b',
          refreshToken: 'rb',
        );
        expect(await preferences.getUserString('filter'), isNull);
      },
    );
  }

  test(
    'transient secure read error retains persisted scope until new login',
    () async {
      secure.failRead = true;
      await preferences.setUserString('filter', 'alice-private');
      await database.markFetched('alice', 'feed', DateTime.utc(2026));
      await session.restore(FixedRefresher(const RefreshAccepted('unused')));
      expect(await preferences.getUserString('filter'), 'alice-private');
      expect(await database.metadataFor('alice', 'feed'), isNotNull);
      await session.establishSession(
        accountId: 'bob',
        accessToken: 'b',
        refreshToken: 'rb',
      );
      expect(await preferences.getUserString('filter'), isNull);
      expect(await database.metadataFor('alice', 'feed'), isNull);
    },
  );
  test('new login waits for prior logout scope cleanup', () async {
    await session.establishSession(
      accountId: 'alice',
      accessToken: 'a',
      refreshToken: 'ra',
    );
    await preferences.setUserString('filter', 'alice-private');
    await database.markFetched('alice', 'feed', DateTime.utc(2026));
    secure.deleteGate = Completer<void>();
    secure.deleteStarted = Completer<void>();
    final logout = session.logout();
    await secure.deleteStarted!.future;
    final login = session.establishSession(
      accountId: 'bob',
      accessToken: 'b',
      refreshToken: 'rb',
    );
    expect(session.accessToken, isNull);
    secure.deleteGate!.complete();
    await login;
    await preferences.setUserString('filter', 'bob-private');
    await logout;
    expect(session.snapshot.accountId, 'bob');
    expect(session.snapshot.status, SessionStatus.authenticatedOnline);
    expect(await preferences.getUserString('filter'), 'bob-private');
    expect(await database.metadataFor('alice', 'feed'), isNull);
    expect(jsonDecode(secure.values['session.envelope']!)['accountId'], 'bob');
  });

  test('current-session rotated write failure remains offline', () async {
    await session.establishSession(
      accountId: 'alice',
      accessToken: 'a',
      refreshToken: 'old',
    );
    secure.writeError = StateError('rotation failed');
    expect(
      await session.refreshAccessToken(
        FixedRefresher(
          const RefreshAccepted('new-access', refreshToken: 'new'),
        ),
      ),
      isA<StorageFailure>(),
    );
    expect(session.snapshot.status, SessionStatus.authenticatedOffline);
    expect(session.snapshot.accountId, 'alice');
    expect(session.accessToken, isNull);
    expect(
      jsonDecode(secure.values['session.envelope']!)['refreshToken'],
      'old',
    );
  });
}
