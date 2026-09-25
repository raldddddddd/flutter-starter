# Flutter Starter

The Android/iOS application shell and design foundation are in place. The
architecture and phase boundaries are defined in [docs/spec.md](docs/spec.md) and
[docs/implementation_plan.md](docs/implementation_plan.md).

Use Flutter **3.47.5** (pinned in `.fvmrc`) and the committed `pubspec.lock`.
FVM users can run the commands below with `fvm flutter` and `fvm dart`.

## Run

```sh
flutter run --flavor dev --dart-define-from-file=config/dev.json
flutter run --flavor staging --dart-define-from-file=config/staging.json
flutter run --flavor prod --dart-define-from-file=config/prod.json
```

`dev` is the default native flavor. Keep the native flavor and the matching
`APP_ENV` define together; the app asserts this in debug builds. These files
contain only public, compile-time settings. The dev configuration enables the
Component Showcase; the production route is excluded.

The brand seed and light/dark themes live in `lib/core/design/app_theme.dart`.
Spacing and radius tokens live in `lib/core/design/app_layout_tokens.dart`.
Reusable starter controls and states live in `lib/shared/widgets/`.

## Verify

```sh
dart run build_runner build
dart format lib test
dart analyze
flutter test
flutter build apk --flavor dev --dart-define-from-file=config/dev.json --debug
```
