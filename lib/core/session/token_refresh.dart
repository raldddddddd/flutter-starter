import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

sealed class RefreshOutcome {
  const RefreshOutcome();
}

final class RefreshAccepted extends RefreshOutcome {
  const RefreshAccepted(this.accessToken, {this.refreshToken});

  final String accessToken;
  final String? refreshToken;
}

final class RefreshRejected extends RefreshOutcome {
  const RefreshRejected();
}

final class RefreshUnavailable extends RefreshOutcome {
  const RefreshUnavailable(this.failure);

  final NetworkFailure failure;
}

abstract interface class TokenRefresher {
  Future<RefreshOutcome> refresh(String refreshToken);
}

/// Only this transport calls the refresh endpoint; it has no auth interceptor.
final class DioTokenRefresher implements TokenRefresher {
  DioTokenRefresher(this._dio, {this.refreshPath = '/auth/refresh'});

  final Dio _dio;
  final String refreshPath;
  Future<RefreshOutcome>? _inFlight;
  String? _inFlightToken;

  @override
  Future<RefreshOutcome> refresh(String refreshToken) {
    if (_inFlight != null && _inFlightToken == refreshToken) return _inFlight!;
    final previous = _inFlight;
    final operation = previous == null
        ? _request(refreshToken)
        : previous.then((_) => _request(refreshToken));
    _inFlight = operation;
    _inFlightToken = refreshToken;
    operation.whenComplete(() {
      if (identical(_inFlight, operation)) {
        _inFlight = null;
        _inFlightToken = null;
      }
    }).ignore();
    return operation;
  }

  Future<RefreshOutcome> _request(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        refreshPath,
        data: {'refreshToken': refreshToken},
      );
      final body = response.data;
      final access = body?['accessToken'];
      final rotated = body?['refreshToken'];
      if (access is! String ||
          access.isEmpty ||
          (rotated != null && rotated is! String)) {
        return const RefreshUnavailable(NetworkFailure());
      }
      return RefreshAccepted(access, refreshToken: rotated as String?);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      final body = error.response?.data;
      if (status == 401 ||
          status == 403 ||
          (body is Map && body['error'] == 'invalid_grant')) {
        return const RefreshRejected();
      }
      final kind = switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.transformTimeout => NetworkFailureKind.timeout,
        DioExceptionType.connectionError => NetworkFailureKind.connection,
        _ => NetworkFailureKind.unavailable,
      };
      return RefreshUnavailable(
        NetworkFailure(kind: kind, cause: error, stackTrace: error.stackTrace),
      );
    } catch (error, stackTrace) {
      return RefreshUnavailable(
        NetworkFailure(cause: error, stackTrace: stackTrace),
      );
    }
  }
}
