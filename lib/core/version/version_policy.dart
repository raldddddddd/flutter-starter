import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'version_policy.g.dart';

enum VersionPolicyStatus { allowed, updateRecommended, updateRequired }

/// A policy source can later obtain minimum/recommended versions from any
/// product-owned service. The default source permits the current build.
abstract interface class VersionPolicySource {
  Future<VersionPolicyStatus> evaluate();
}

final class AllowCurrentVersionPolicy implements VersionPolicySource {
  const AllowCurrentVersionPolicy();

  @override
  Future<VersionPolicyStatus> evaluate() async => VersionPolicyStatus.allowed;
}

@Riverpod(keepAlive: true)
VersionPolicySource versionPolicySource(Ref ref) =>
    const AllowCurrentVersionPolicy();

@Riverpod(keepAlive: true)
Future<VersionPolicyStatus> versionPolicyStatus(Ref ref) =>
    ref.watch(versionPolicySourceProvider).evaluate();
