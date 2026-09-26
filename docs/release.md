# Release builds and symbols

The starter does not provide signing credentials or a publishing pipeline. Set
those up for each product before distribution. Use the matching `prod` flavor
and compile-time configuration for a production build.

For a release where Dart code obfuscation is appropriate, use both
`--obfuscate` and `--split-debug-info`. Choose a unique symbol directory for
each product version, platform, and build. The example `1.0.0+1-abc1234`
should be replaced with the actual version/build number and commit identifier:

```sh
flutter build appbundle --release --flavor prod \
  --dart-define-from-file=config/prod.json \
  --obfuscate --split-debug-info=build/symbols/android/1.0.0+1-abc1234

flutter build ipa --release --flavor prod \
  --dart-define-from-file=config/prod.json \
  --obfuscate --split-debug-info=build/symbols/ios/1.0.0+1-abc1234
```

Run the iOS command on a Mac with the product's signing and export settings.
These commands are release examples, not CI checks. CI builds the `dev` flavor
without signing or obfuscation.

**Archive the entire matching symbol directory as a release artifact before
cleaning `build/` or the CI workspace.** Record its product, version, build
number, platform, flavor, and source commit alongside the shipped binary. Keep
it in durable, access-controlled artifact storage for the period in which
crash reports may arrive. Each obfuscated build needs its own symbols for
readable stack traces; symbols from another build are not interchangeable.

Obfuscation changes Dart symbol names and can make reverse engineering harder.
It does **not** protect API keys, credentials, or other secrets. Do not embed
secrets in the app or its `--dart-define` files. Production logic must not
classify errors or otherwise branch on source/runtime type-name strings.

See [Flutter's obfuscation guide](https://docs.flutter.dev/deployment/obfuscate)
for symbolication and platform-specific behavior.

## Validation status

Automated accessibility tests and hosted CI have passed. Manual VoiceOver (iOS)
and TalkBack (Android) accessibility validation has not yet been completed.
