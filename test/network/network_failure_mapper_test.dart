import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/core/network/network_failure_mapper.dart';

void main() {
  final request = RequestOptions(path: '/items');

  DioException status(int code) => DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(requestOptions: request, statusCode: code),
  );

  test('maps HTTP statuses to typed failures', () {
    expect(mapNetworkError(status(401)), isA<AuthenticationFailure>());
    expect(mapNetworkError(status(403)), isA<AuthorizationFailure>());
    expect(mapNetworkError(status(422)), isA<ValidationFailure>());
    expect(mapNetworkError(status(404)), isA<NotFoundFailure>());
    expect(mapNetworkError(status(409)), isA<ConflictFailure>());
    expect(mapNetworkError(status(503)), isA<ServerFailure>());
  });

  test('maps connection and timeout separately', () {
    final timeout = mapNetworkError(
      DioException(
        requestOptions: request,
        type: DioExceptionType.receiveTimeout,
      ),
    );
    final connection = mapNetworkError(
      DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      ),
    );
    expect((timeout as NetworkFailure).kind, NetworkFailureKind.timeout);
    expect((connection as NetworkFailure).kind, NetworkFailureKind.connection);
  });

  test('preserves failure embedded by auth interceptor', () {
    const failure = NetworkFailure(kind: NetworkFailureKind.connection);
    final error = DioException(requestOptions: request, error: failure);
    expect(mapNetworkError(error), same(failure));
  });
}
