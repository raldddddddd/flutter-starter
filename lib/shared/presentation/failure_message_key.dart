import '../../core/errors/app_failure.dart';
import '../../l10n/generated/app_localizations.dart';

/// Technical failures are mapped to user-facing localized presentation copy.
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

String localizedFailureMessage(AppLocalizations l10n, AppFailure failure) =>
    switch (messageKeyFor(failure)) {
      FailureMessageKey.connection => l10n.failureConnection,
      FailureMessageKey.timeout => l10n.failureTimeout,
      FailureMessageKey.networkUnavailable => l10n.failureNetworkUnavailable,
      FailureMessageKey.authentication => l10n.failureAuthentication,
      FailureMessageKey.authorization => l10n.failureAuthorization,
      FailureMessageKey.validation => l10n.failureValidation,
      FailureMessageKey.notFound => l10n.failureNotFound,
      FailureMessageKey.conflict => l10n.failureConflict,
      FailureMessageKey.server => l10n.failureServer,
      FailureMessageKey.storage => l10n.failureStorage,
      FailureMessageKey.unexpected => l10n.failureUnexpected,
    };
