import 'package:dio/dio.dart';

import '../errors/app_failure.dart';
import '../session/session_manager.dart';
import '../session/token_refresh.dart';

const _retryKey = 'session.authRetried';
const skipAuthenticationKey = 'session.skipAuthentication';

/// This interceptor depends on the session store, never an auth repository.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._dio,
    this._session,
    this._refresher, {
    this.loginPath = '/auth/login',
    this.refreshPath = '/auth/refresh',
  });

  final Dio _dio;
  final SessionManager _session;
  final TokenRefresher _refresher;
  final String loginPath;
  final String refreshPath;

  bool _skipsAuth(RequestOptions options) {
    final path = Uri.parse(options.path).path;
    return options.extra[skipAuthenticationKey] == true ||
        path == loginPath ||
        path == refreshPath;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_skipsAuth(options)) {
      final token = _session.accessToken;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      final cancelToken = options.cancelToken ??= CancelToken();
      _session.trackRequest(cancelToken);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _session.releaseRequest(response.requestOptions.cancelToken);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        _skipsAuth(options) ||
        options.extra[_retryKey] == true ||
        _session.snapshot.accountId == null) {
      _session.releaseRequest(options.cancelToken);
      handler.next(err);
      return;
    }
    _retryAfterRefresh(err, handler);
  }

  Future<void> _retryAfterRefresh(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final options = error.requestOptions;
    try {
      final usedToken = _bearerToken(options.headers['Authorization']);
      var current = _session.accessToken;
      if (current == null || current == usedToken) {
        final failure = await _session.refreshAccessToken(_refresher);
        if (failure != null) {
          handler.reject(error.copyWith(error: failure));
          return;
        }
        current = _session.accessToken;
      }
      if (current == null || options.cancelToken?.isCancelled == true) {
        handler.reject(error.copyWith(error: const AuthenticationFailure()));
        return;
      }
      final data = options.data;
      if (data is Stream) {
        handler.reject(error.copyWith(error: const NetworkFailure()));
        return;
      }
      final retry = options.copyWith(
        data: switch (data) {
          FormData body => body.clone(),
          MultipartFile file => file.clone(),
          _ => data,
        },
        headers: {...options.headers, 'Authorization': 'Bearer $current'},
        extra: {...options.extra, _retryKey: true},
      );
      handler.resolve(await _dio.fetch<dynamic>(retry));
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (other, stackTrace) {
      handler.reject(
        error.copyWith(
          error: NetworkFailure(cause: other, stackTrace: stackTrace),
        ),
      );
    } finally {
      _session.releaseRequest(options.cancelToken);
    }
  }

  String? _bearerToken(Object? header) {
    if (header is! String || !header.startsWith('Bearer ')) return null;
    return header.substring(7);
  }
}
