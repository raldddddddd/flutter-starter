/// Technical failure categories. User-facing copy belongs in presentation.
sealed class AppFailure implements Exception {
  const AppFailure({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;
}

enum NetworkFailureKind { connection, timeout, unavailable }

final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    this.kind = NetworkFailureKind.unavailable,
    super.cause,
    super.stackTrace,
  });

  final NetworkFailureKind kind;
}

final class AuthenticationFailure extends AppFailure {
  const AuthenticationFailure({super.cause, super.stackTrace});
}

final class AuthorizationFailure extends AppFailure {
  const AuthorizationFailure({super.cause, super.stackTrace});
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure({super.cause, super.stackTrace});
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({super.cause, super.stackTrace});
}

final class ConflictFailure extends AppFailure {
  const ConflictFailure({super.cause, super.stackTrace});
}

final class ServerFailure extends AppFailure {
  const ServerFailure({super.cause, super.stackTrace});
}

final class StorageFailure extends AppFailure {
  const StorageFailure({super.cause, super.stackTrace});
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure({required Object cause, super.stackTrace})
    : super(cause: cause);
}
