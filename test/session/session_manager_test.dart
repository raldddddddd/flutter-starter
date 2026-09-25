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
  }) async => values.remove(key);
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
    await session.establishSession(
      accountId: 'bob',
      accessToken: 'b',
      refreshToken: 'rb',
    );
    expect(session.snapshot.epoch, greaterThan(epoch));
    expect(session.snapshot.accountId, 'bob');
  });
}
