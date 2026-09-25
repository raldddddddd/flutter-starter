import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/network/auth_interceptor.dart';
import 'package:flutter_starter/core/persistence/app_database.dart';
import 'package:flutter_starter/core/persistence/app_preferences.dart';
import 'package:flutter_starter/core/session/session_manager.dart';
import 'package:flutter_starter/core/session/token_refresh.dart';

import '../persistence/app_preferences_test.dart' show MemoryPreferences;
import '../session/session_manager_test.dart' show MemorySecureStorage;
import 'token_refresh_test.dart' show CallbackAdapter;

class CountingRefresher implements TokenRefresher {
  int calls = 0;

  @override
  Future<RefreshOutcome> refresh(String refreshToken) async {
    calls++;
    return const RefreshAccepted('new-access');
  }
}

void main() {
  test(
    'a multipart 401 retries once with a cloned body and new token',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      final session = SessionManager(
        MemorySecureStorage(),
        AppPreferences(MemoryPreferences()),
        database,
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
      addTearDown(() async {
        dio.close();
        await session.close();
        await database.close();
      });
      await session.establishSession(
        accountId: 'alice',
        accessToken: 'old-access',
        refreshToken: 'refresh',
      );
      final refresher = CountingRefresher();
      dio.interceptors.add(AuthInterceptor(dio, session, refresher));
      final bodies = <List<int>>[];
      final headers = <Object?>[];
      dio.httpClientAdapter = CallbackAdapter((options, body) async {
        bodies.add(body);
        headers.add(options.headers['Authorization']);
        return ResponseBody.fromString(
          '{}',
          headers.length == 1 ? 401 : 200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      });

      final data = FormData.fromMap({
        'file': MultipartFile.fromBytes([1, 2, 3], filename: 'item.bin'),
      });
      final response = await dio.post<Map<String, dynamic>>(
        '/upload',
        data: data,
      );

      expect(response.statusCode, 200);
      expect(refresher.calls, 1);
      expect(headers, ['Bearer old-access', 'Bearer new-access']);
      expect(bodies, hasLength(2));
      expect(bodies.first, isNotEmpty);
      expect(bodies.last, bodies.first);
    },
  );
}
