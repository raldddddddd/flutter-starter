import '../../core/errors/app_failure.dart';

/// Presentation resolves these meanings through localization when l10n exists.
enum FailureMessageKey {
  connection,
  timeout,
  networkUnavailable,
  authentication,
  authorization,
  validation,
  notFound,
  conflict,
  server,
  storage,
  unexpected,
}

FailureMessageKey messageKeyFor(AppFailure failure) => switch (failure) {
  NetworkFailure(kind: NetworkFailureKind.connection) =>
    FailureMessageKey.connection,
  NetworkFailure(kind: NetworkFailureKind.timeout) => FailureMessageKey.timeout,
  NetworkFailure() => FailureMessageKey.networkUnavailable,
  AuthenticationFailure() => FailureMessageKey.authentication,
  AuthorizationFailure() => FailureMessageKey.authorization,
  ValidationFailure() => FailureMessageKey.validation,
  NotFoundFailure() => FailureMessageKey.notFound,
  ConflictFailure() => FailureMessageKey.conflict,
  ServerFailure() => FailureMessageKey.server,
  StorageFailure() => FailureMessageKey.storage,
  UnknownFailure() => FailureMessageKey.unexpected,
};
