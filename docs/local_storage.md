# Local storage contract (Phase 3)

The application uses `SharedPreferencesAsync` for small, non-sensitive values.
Keys are explicitly prefixed `device.` or `user.`. A logout must clear the
`user.` namespace; `device.` settings normally survive logout. The
`device.installationMarker` key marks a known installation.

On startup, if that marker is absent, `FreshInstallPolicy` clears the dedicated
secure session store before writing the marker. Secure storage is recoverable
session material, never the sole home of irreplaceable data. Phase 4 should use
the same default `FlutterSecureStorage` configuration for session credentials.

Schema v1 has only `cache_metadata_entries`. Its composite key is
`(account_id, resource_key)`, and the presence of a row with
`last_fetched_at` distinguishes a successful empty fetch from never fetched.
Schema v2 adds the account-scoped `sample_items` reference list, keyed by
`(account_id, item_id)` with a stable position. Its v1-to-v2 migration creates
the table without dropping existing cache metadata. The sample repository
replaces the complete one-scope list in a transaction and clears its rows on
logout. All future cache and business tables are user-scoped by default. There
are no device-scoped tables; any future exception needs explicit documentation.
Repositories should access the database through `appDatabaseProvider` and
check the session epoch inside transactions before writing user data.

## Android backup paths

The pinned `shared_preferences_android` 2.4.28 default DataStore is named
`FlutterSharedPreferences` and lives under `files/datastore/`. This single
file mixes the installation marker and other preferences, so the entire
DataStore directory is excluded from backup. Device theme/locale preferences
therefore do not restore from backup yet.

The pinned `flutter_secure_storage` 11.2.0 default uses Android
`SharedPreferences` files for encrypted values, key wrapping, and
configuration (including `FlutterSecureStorage.xml`,
`FlutterSecureKeyStorage.xml`, and configuration files). The whole
`shared_prefs/` directory is excluded to cover those files and package
migration variants.

`drift_flutter` 0.3.1 places `flutter_starter.sqlite` in
`getApplicationSupportDirectory()`, which maps to Android `filesDir` with
`path_provider_android` 2.3.1. Backup rules exclude the database plus SQLite
WAL, SHM, and journal sidecars. These exclusions apply to both cloud backup
and device transfer on Android 12+, with a separate Android 11-and-lower file.
Other application files remain eligible for backup.

When changing these packages or file locations, recheck their Android
implementations and both backup rule files before release.

## Schema workflow

After changing the Drift schema, increment `schemaVersion`, add an explicit
migration, and run:

```sh
dart run build_runner build
dart run drift_dev schema dump lib/core/persistence/app_database.dart drift_schemas/
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
flutter test
```

Keep every exported schema. The v1 baseline and v2 sample migration are
preserved in `drift_schemas/`.
