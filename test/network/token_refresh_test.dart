import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/core/session/token_refresh.dart';

class CallbackAdapter implements HttpClientAdapter {
  CallbackAdapter(this.handle);

  final Future<ResponseBody> Function(RequestOptions options, List<int> body)
  handle;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = <int>[];
    await for (final chunk
        in requestStream ?? const Stream<Uint8List>.empty()) {
      bytes.addAll(chunk);
    }
    return handle(options, bytes);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('refresh accepts a valid token response through separate Dio', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    dio.httpClientAdapter = CallbackAdapter((options, body) async {
      expect(options.path, '/auth/refresh');
      expect(String.fromCharCodes(body), contains('old-refresh'));
      return ResponseBody.fromString(
        '{"accessToken":"new-access","refreshToken":"new-refresh"}',
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });
    addTearDown(dio.close);

    final outcome = await DioTokenRefresher(dio).refresh('old-refresh');
    expect(outcome, isA<RefreshAccepted>());
    expect((outcome as RefreshAccepted).accessToken, 'new-access');
    expect(outcome.refreshToken, 'new-refresh');
  });

  test('refresh rejection differs from temporary server failure', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    var status = 401;
    dio.httpClientAdapter = CallbackAdapter(
      (options, body) async => ResponseBody.fromString(
        '{}',
        status,
        headers: {
          'content-type': ['application/json'],
        },
      ),
    );
    addTearDown(dio.close);
    final refresher = DioTokenRefresher(dio);

    expect(await refresher.refresh('secret'), isA<RefreshRejected>());
    status = 503;
    final outcome = await refresher.refresh('secret');
    expect(outcome, isA<RefreshUnavailable>());
    expect((outcome as RefreshUnavailable).failure, isA<NetworkFailure>());
  });
}
