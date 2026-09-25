import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/core/errors/result.dart';

String describe(Result<int> result) => switch (result) {
  Success<int>(value: final value) => 'value:$value',
  Failure<int>(failure: NetworkFailure()) => 'network',
  Failure<int>() => 'other failure',
};

void main() {
  test('success keeps a typed value', () {
    const result = Success<int>(42);
    expect(describe(result), 'value:42');
    expect(result.value, 42);
  });

  test('failure keeps the typed operational failure', () {
    const result = Failure<int>(NetworkFailure());
    expect(describe(result), 'network');
    expect(result.failure, isA<NetworkFailure>());
  });
}
