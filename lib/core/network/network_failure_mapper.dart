import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

AppFailure mapNetworkError(Object error, {StackTrace? stackTrace}) {
  if (error is AppFailure) return error;
  if (error is! DioException) {
    return UnknownFailure(cause: error, stackTrace: stackTrace);
  }
  if (error.error is AppFailure) return error.error! as AppFailure;
  final cause = error;
  final trace = stackTrace ?? error.stackTrace;
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return NetworkFailure(
        kind: NetworkFailureKind.timeout,
        cause: cause,
        stackTrace: trace,
      );
    case DioExceptionType.connectionError:
      return NetworkFailure(
        kind: NetworkFailureKind.connection,
        cause: cause,
        stackTrace: trace,
      );
    case DioExceptionType.badResponse:
      return switch (error.response?.statusCode) {
        401 => AuthenticationFailure(cause: cause, stackTrace: trace),
        403 => AuthorizationFailure(cause: cause, stackTrace: trace),
        400 || 422 => ValidationFailure(cause: cause, stackTrace: trace),
        404 => NotFoundFailure(cause: cause, stackTrace: trace),
        409 => ConflictFailure(cause: cause, stackTrace: trace),
        final int status when status >= 500 => ServerFailure(
          cause: cause,
          stackTrace: trace,
        ),
        _ => NetworkFailure(cause: cause, stackTrace: trace),
      };
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return NetworkFailure(cause: cause, stackTrace: trace);
  }
}
