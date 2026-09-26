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

/// This reference list has one authoritative scope per account.
class SampleItems extends Table {
  TextColumn get accountId => text()();
  TextColumn get itemId => text()();
  TextColumn get title => text()();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, itemId};
}

@DriftDatabase(tables: [CacheMetadataEntries, SampleItems])
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from == 1 && to == 2) {
        await migrator.createTable(sampleItems);
        return;
      }
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

  Stream<List<SampleItem>> watchSampleItems(String accountId) =>
      (select(sampleItems)
            ..where((entry) => entry.accountId.equals(accountId))
            ..orderBy([(entry) => OrderingTerm.asc(entry.position)]))
          .watch();

  Future<List<SampleItem>> sampleItemsFor(String accountId) =>
      (select(sampleItems)
            ..where((entry) => entry.accountId.equals(accountId))
            ..orderBy([(entry) => OrderingTerm.asc(entry.position)]))
          .get();

  Future<void> replaceSampleItems(
    String accountId,
    List<SampleItemsCompanion> items,
  ) async {
    await (delete(
      sampleItems,
    )..where((entry) => entry.accountId.equals(accountId))).go();
    await batch((batch) => batch.insertAll(sampleItems, items));
  }

  Future<void> clearAccountData(String accountId) => transaction(() async {
    await (delete(
      sampleItems,
    )..where((entry) => entry.accountId.equals(accountId))).go();
    await clearAccountMetadata(accountId);
  });

  /// Used when secure session identity is definitively missing or corrupt.
  Future<void> clearAllAccountData() => transaction(() async {
    await delete(sampleItems).go();
    await delete(cacheMetadataEntries).go();
  });
}
