import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';
import '../logging/app_logger.dart';
import '../persistence/persistence_providers.dart';
import '../session/session_manager.dart';
import '../session/token_refresh.dart';
import 'auth_interceptor.dart';
import 'redacted_log_interceptor.dart';

part 'network_providers.g.dart';

BaseOptions _baseOptions(String baseUrl) => BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 10),
  sendTimeout: const Duration(seconds: 20),
  receiveTimeout: const Duration(seconds: 20),
  headers: {Headers.acceptHeader: 'application/json'},
);

@Riverpod(keepAlive: true)
SessionManager sessionManager(Ref ref) {
  final manager = SessionManager(
    ref.watch(secureStorageProvider),
    ref.watch(appPreferencesProvider),
    ref.watch(appDatabaseProvider),
  );
  ref.onDispose(manager.close);
  return manager;
}

@Riverpod(keepAlive: true)
Dio refreshDio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(_baseOptions(config.apiBaseUrl));
  if (config.environment != AppEnvironment.prod) {
    dio.interceptors.add(RedactedLogInterceptor(const DeveloperLogger()));
  }
  ref.onDispose(() => dio.close(force: true));
  return dio;
}

@Riverpod(keepAlive: true)
TokenRefresher tokenRefresher(Ref ref) =>
    DioTokenRefresher(ref.watch(refreshDioProvider));

@Riverpod(keepAlive: true)
Dio appDio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(_baseOptions(config.apiBaseUrl));
  dio.interceptors.add(
    AuthInterceptor(
      dio,
      ref.watch(sessionManagerProvider),
      ref.watch(tokenRefresherProvider),
    ),
  );
  if (config.environment != AppEnvironment.prod) {
    dio.interceptors.add(RedactedLogInterceptor(const DeveloperLogger()));
  }
  ref.onDispose(() => dio.close(force: true));
  return dio;
}

/// API-service providers can use this token and release it with the request.
CancelToken requestCancelToken(Ref ref, SessionManager session) {
  final token = CancelToken();
  session.trackRequest(token);
  ref.onDispose(() {
    token.cancel('Provider disposed');
    session.releaseRequest(token);
  });
  return token;
}
