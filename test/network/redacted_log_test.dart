import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';
import 'package:flutter_starter/core/network/redacted_log_interceptor.dart';

import 'token_refresh_test.dart' show CallbackAdapter;

class MessageLogger implements AppLogger {
  final messages = <String>[];

  @override
  void debug(String message) => messages.add(message);

  @override
  void info(String message) => messages.add(message);

  @override
  void warning(String message) => messages.add(message);

  @override
  void error(
    String message, {
    required Object error,
    required StackTrace stackTrace,
  }) => messages.add(message);
}

void main() {
  test('development logs omit credentials, URL and body', () async {
    final logger = MessageLogger();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    dio.interceptors.add(RedactedLogInterceptor(logger));
    dio.httpClientAdapter = CallbackAdapter(
      (options, body) async => ResponseBody.fromString(
        '{}',
        200,
        headers: {
          'content-type': ['application/json'],
        },
      ),
    );
    addTearDown(dio.close);

    await dio.post<Map<String, dynamic>>(
      '/private-account-id',
      data: {'password': 'secret-body'},
      options: Options(headers: {'Authorization': 'Bearer secret-token'}),
    );

    final output = logger.messages.join(' ');
    expect(output, contains('POST'));
    expect(output, isNot(contains('secret-token')));
    expect(output, isNot(contains('secret-body')));
    expect(output, isNot(contains('private-account-id')));
  });
}
