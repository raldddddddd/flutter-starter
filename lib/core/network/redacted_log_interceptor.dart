import 'package:dio/dio.dart';

import '../logging/app_logger.dart';

/// Logs method and outcome only. Headers, URLs, bodies and token text are omitted.
final class RedactedLogInterceptor extends Interceptor {
  RedactedLogInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug('HTTP ${options.method} started');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      'HTTP ${response.requestOptions.method} ${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning('HTTP ${err.requestOptions.method} failed');
    handler.next(err);
  }
}
