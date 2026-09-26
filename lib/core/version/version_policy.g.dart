// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_policy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(versionPolicySource)
final versionPolicySourceProvider = VersionPolicySourceProvider._();

final class VersionPolicySourceProvider
    extends
        $FunctionalProvider<
          VersionPolicySource,
          VersionPolicySource,
          VersionPolicySource
        >
    with $Provider<VersionPolicySource> {
  VersionPolicySourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'versionPolicySourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$versionPolicySourceHash();

  @$internal
  @override
  $ProviderElement<VersionPolicySource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VersionPolicySource create(Ref ref) {
    return versionPolicySource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VersionPolicySource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VersionPolicySource>(value),
    );
  }
}

String _$versionPolicySourceHash() =>
    r'51ee65f0c3c055a8f9418387a91417552cd149ce';

@ProviderFor(versionPolicyStatus)
final versionPolicyStatusProvider = VersionPolicyStatusProvider._();

final class VersionPolicyStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<VersionPolicyStatus>,
          VersionPolicyStatus,
          FutureOr<VersionPolicyStatus>
        >
    with
        $FutureModifier<VersionPolicyStatus>,
        $FutureProvider<VersionPolicyStatus> {
  VersionPolicyStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'versionPolicyStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$versionPolicyStatusHash();

  @$internal
  @override
  $FutureProviderElement<VersionPolicyStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VersionPolicyStatus> create(Ref ref) {
    return versionPolicyStatus(ref);
  }
}

String _$versionPolicyStatusHash() =>
    r'b17e8855518aa6e4299f41fa2a8b988f70f618da';
