# Flutter Starter

A reusable Android and iOS Flutter foundation for a product with local data,
session handling, network access, routing, localization, and a small design
system. The dev flavor includes a fake API sample and Component Showcase. The
staging and prod API URLs are placeholders; configure a real backend before
using them for a product.

The architecture and phase boundaries are defined in [docs/spec.md](docs/spec.md)
and [docs/implementation_plan.md](docs/implementation_plan.md).

## SDK and first setup

Use Flutter **3.47.5**, pinned in [.fvmrc](.fvmrc), with its Dart **3.13.4**
SDK. Install that Flutter version directly or select it with FVM. The commands
below use `flutter` and `dart`; with FVM, use `fvm flutter` and `fvm dart` (or
put the selected SDK on `PATH`). Use the committed `pubspec.lock`.

Install the Android SDK for Android development. For iOS development, use a Mac
with Xcode and an iOS simulator. Check the local platform setup with
`flutter doctor`, then fetch packages:

```sh
flutter pub get
```

## Flavors and running

The three native flavors are `dev`, `staging`, and `prod`. Keep each native
flavor paired with its matching public compile-time configuration:

| Flavor | Android application ID | iOS bundle ID | Configuration |
| --- | --- | --- | --- |
| dev | `com.example.flutter_starter.dev` | `com.example.flutterStarter.dev` | `config/dev.json` |
| staging | `com.example.flutter_starter.staging` | `com.example.flutterStarter.staging` | `config/staging.json` |
| prod | `com.example.flutter_starter` | `com.example.flutterStarter` | `config/prod.json` |

```sh
flutter run --flavor dev --dart-define-from-file=config/dev.json
flutter run --flavor staging --dart-define-from-file=config/staging.json
flutter run --flavor prod --dart-define-from-file=config/prod.json
```

`dev` is the default flavor. The app checks flavor/configuration alignment in
debug builds. `config/*.json` contains public settings only, including
`APP_ENV`, `API_BASE_URL`, and the dev Component Showcase flag. Never put
secrets in Dart defines. The example API hosts use `.invalid`; the dev sample
uses a local fake transport, while real staging/prod authentication and API
endpoints must be supplied by the new product.

## Generation and verification

Localization source is `lib/l10n/app_en.arb`. Riverpod, Freezed, JSON, and
Drift generated files come from their source files. After changing those
sources, regenerate them:

```sh
flutter gen-l10n
dart run build_runner build
```

For a Drift schema change, also follow [docs/local_storage.md](docs/local_storage.md):
increment the schema version, add the migration, and export the schema and
migration tests. Keep the exported historical schemas.

Run the single local verification command before handing off changes:

```sh
./tool/verify.sh
```

It fetches locked dependencies, regenerates localization and code, checks
formatting, runs static analysis, and runs the full test suite. To run a
focused test, use `flutter test test/<path>_test.dart`. Platform builds are
separate because they take longer; for example:

```sh
flutter build apk --flavor dev --dart-define-from-file=config/dev.json --debug
flutter build ios --flavor dev --dart-define-from-file=config/dev.json --no-codesign
```

## Architecture at a glance

- `lib/app/` owns startup, configuration, and the root widget.
- `lib/core/` owns the unified session/version gate, router, network client,
  persistence, logging, and shared app services.
- `lib/features/sample/` shows a local-first feature using the fake dev API.
- `lib/shared/` contains reusable UI and the dev Component Showcase.
- `lib/l10n/` contains localization source and generated delegates.
- `test/` covers migrations, session races, routing, UI, and tooling.

The app gate combines session restoration and version policy. The default
version policy allows the current build. A product can replace
`VersionPolicySource` in `lib/core/version/version_policy.dart` with a source
that evaluates its own minimum supported and recommended versions. A required
update leads to the localized update screen; a recommendation does not block
navigation. No remote configuration provider is built in.

## Create a new product

1. Copy `tool/app_identity.example.json` and set the display name, Dart package
   name, Android namespace, each Android application ID, each iOS bundle ID,
   and the three flavor display names. Keep flavor IDs unique.
2. Preview the identity changes, then apply and review them:

   ```sh
   dart run tool/app_identity.dart --config path/to/identity.json
   dart run tool/app_identity.dart --config path/to/identity.json --apply
   git diff
   ```

   The tool updates native flavor settings, the Kotlin package path, package
   imports, app title, local database naming, and its current identity
   manifest. The preview writes nothing. Run it on a clean tree so the diff
   is easy to review.
3. Replace the example URLs in `config/*.json`, connect the product's session
   and API implementation, and adapt or remove the sample feature. Set brand
   colors and shared UI in `lib/core/design/` and `lib/shared/`.
4. Run `./tool/verify.sh`, then build and inspect each desired platform/flavor.
   Set the product's signing credentials and store metadata outside this
   starter before distribution.

Read [docs/spec.md](docs/spec.md) for architectural contracts and
[docs/implementation_plan.md](docs/implementation_plan.md) for scoped work.
