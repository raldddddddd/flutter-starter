import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/shared/presentation/failure_message_key.dart';

void main() {
  test('maps all typed failures to presentation meanings', () {
    final cases = <AppFailure, FailureMessageKey>{
      const NetworkFailure(kind: NetworkFailureKind.connection):
          FailureMessageKey.connection,
      const NetworkFailure(kind: NetworkFailureKind.timeout):
          FailureMessageKey.timeout,
      const NetworkFailure(): FailureMessageKey.networkUnavailable,
      const AuthenticationFailure(): FailureMessageKey.authentication,
      const AuthorizationFailure(): FailureMessageKey.authorization,
      const ValidationFailure(): FailureMessageKey.validation,
      const NotFoundFailure(): FailureMessageKey.notFound,
      const ConflictFailure(): FailureMessageKey.conflict,
      const ServerFailure(): FailureMessageKey.server,
      const StorageFailure(): FailureMessageKey.storage,
      UnknownFailure(cause: StateError('unexpected')):
          FailureMessageKey.unexpected,
    };

    for (final MapEntry(key: failure, value: expected) in cases.entries) {
      expect(messageKeyFor(failure), expected);
    }
  });
}
