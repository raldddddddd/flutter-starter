// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_gate.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appGate)
final appGateProvider = AppGateProvider._();

final class AppGateProvider
    extends $FunctionalProvider<AppGateState, AppGateState, AppGateState>
    with $Provider<AppGateState> {
  AppGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appGateHash();

  @$internal
  @override
  $ProviderElement<AppGateState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppGateState create(Ref ref) {
    return appGate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppGateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppGateState>(value),
    );
  }
}

String _$appGateHash() => r'a1bca90922a341ccbf95ce4ed1ff05a4531c92ab';
