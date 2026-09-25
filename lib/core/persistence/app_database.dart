import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Cache and business tables are user-scoped by default.
/// No device-scoped tables are defined in schema v1.
class CacheMetadataEntries extends Table {
  TextColumn get accountId => text()();
  TextColumn get resourceKey => text()();
  DateTimeColumn get lastFetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, resourceKey};
}

@DriftDatabase(tables: [CacheMetadataEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'flutter_starter',
              native: const DriftNativeOptions(
                databaseDirectory: getApplicationSupportDirectory,
              ),
            ),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) {
      throw StateError('Missing explicit Drift migration from $from to $to.');
    },
  );

  Future<CacheMetadataEntry?> metadataFor(
    String accountId,
    String resourceKey,
  ) =>
      (select(cacheMetadataEntries)..where(
            (entry) =>
                entry.accountId.equals(accountId) &
                entry.resourceKey.equals(resourceKey),
          ))
          .getSingleOrNull();

  Stream<CacheMetadataEntry?> watchMetadata(
    String accountId,
    String resourceKey,
  ) =>
      (select(cacheMetadataEntries)..where(
            (entry) =>
                entry.accountId.equals(accountId) &
                entry.resourceKey.equals(resourceKey),
          ))
          .watchSingleOrNull();

  Future<void> markFetched(
    String accountId,
    String resourceKey,
    DateTime fetchedAt,
  ) async {
    await into(cacheMetadataEntries).insertOnConflictUpdate(
      CacheMetadataEntriesCompanion.insert(
        accountId: accountId,
        resourceKey: resourceKey,
        lastFetchedAt: fetchedAt,
      ),
    );
  }

  Future<int> clearAccountMetadata(String accountId) => (delete(
    cacheMetadataEntries,
  )..where((entry) => entry.accountId.equals(accountId))).go();
}
