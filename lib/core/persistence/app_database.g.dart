// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CacheMetadataEntriesTable extends CacheMetadataEntries
    with TableInfo<$CacheMetadataEntriesTable, CacheMetadataEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMetadataEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceKeyMeta = const VerificationMeta(
    'resourceKey',
  );
  @override
  late final GeneratedColumn<String> resourceKey = GeneratedColumn<String>(
    'resource_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastFetchedAtMeta = const VerificationMeta(
    'lastFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetchedAt =
      GeneratedColumn<DateTime>(
        'last_fetched_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [accountId, resourceKey, lastFetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_metadata_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheMetadataEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('resource_key')) {
      context.handle(
        _resourceKeyMeta,
        resourceKey.isAcceptableOrUnknown(
          data['resource_key']!,
          _resourceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceKeyMeta);
    }
    if (data.containsKey('last_fetched_at')) {
      context.handle(
        _lastFetchedAtMeta,
        lastFetchedAt.isAcceptableOrUnknown(
          data['last_fetched_at']!,
          _lastFetchedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastFetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, resourceKey};
  @override
  CacheMetadataEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheMetadataEntry(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      resourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_key'],
      )!,
      lastFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched_at'],
      )!,
    );
  }

  @override
  $CacheMetadataEntriesTable createAlias(String alias) {
    return $CacheMetadataEntriesTable(attachedDatabase, alias);
  }
}

class CacheMetadataEntry extends DataClass
    implements Insertable<CacheMetadataEntry> {
  final String accountId;
  final String resourceKey;
  final DateTime lastFetchedAt;
  const CacheMetadataEntry({
    required this.accountId,
    required this.resourceKey,
    required this.lastFetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['resource_key'] = Variable<String>(resourceKey);
    map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt);
    return map;
  }

  CacheMetadataEntriesCompanion toCompanion(bool nullToAbsent) {
    return CacheMetadataEntriesCompanion(
      accountId: Value(accountId),
      resourceKey: Value(resourceKey),
      lastFetchedAt: Value(lastFetchedAt),
    );
  }

  factory CacheMetadataEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheMetadataEntry(
      accountId: serializer.fromJson<String>(json['accountId']),
      resourceKey: serializer.fromJson<String>(json['resourceKey']),
      lastFetchedAt: serializer.fromJson<DateTime>(json['lastFetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'resourceKey': serializer.toJson<String>(resourceKey),
      'lastFetchedAt': serializer.toJson<DateTime>(lastFetchedAt),
    };
  }

  CacheMetadataEntry copyWith({
    String? accountId,
    String? resourceKey,
    DateTime? lastFetchedAt,
  }) => CacheMetadataEntry(
    accountId: accountId ?? this.accountId,
    resourceKey: resourceKey ?? this.resourceKey,
    lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
  );
  CacheMetadataEntry copyWithCompanion(CacheMetadataEntriesCompanion data) {
    return CacheMetadataEntry(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      resourceKey: data.resourceKey.present
          ? data.resourceKey.value
          : this.resourceKey,
      lastFetchedAt: data.lastFetchedAt.present
          ? data.lastFetchedAt.value
          : this.lastFetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetadataEntry(')
          ..write('accountId: $accountId, ')
          ..write('resourceKey: $resourceKey, ')
          ..write('lastFetchedAt: $lastFetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountId, resourceKey, lastFetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheMetadataEntry &&
          other.accountId == this.accountId &&
          other.resourceKey == this.resourceKey &&
          other.lastFetchedAt == this.lastFetchedAt);
}

class CacheMetadataEntriesCompanion
    extends UpdateCompanion<CacheMetadataEntry> {
  final Value<String> accountId;
  final Value<String> resourceKey;
  final Value<DateTime> lastFetchedAt;
  final Value<int> rowid;
  const CacheMetadataEntriesCompanion({
    this.accountId = const Value.absent(),
    this.resourceKey = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMetadataEntriesCompanion.insert({
    required String accountId,
    required String resourceKey,
    required DateTime lastFetchedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       resourceKey = Value(resourceKey),
       lastFetchedAt = Value(lastFetchedAt);
  static Insertable<CacheMetadataEntry> custom({
    Expression<String>? accountId,
    Expression<String>? resourceKey,
    Expression<DateTime>? lastFetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (resourceKey != null) 'resource_key': resourceKey,
      if (lastFetchedAt != null) 'last_fetched_at': lastFetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheMetadataEntriesCompanion copyWith({
    Value<String>? accountId,
    Value<String>? resourceKey,
    Value<DateTime>? lastFetchedAt,
    Value<int>? rowid,
  }) {
    return CacheMetadataEntriesCompanion(
      accountId: accountId ?? this.accountId,
      resourceKey: resourceKey ?? this.resourceKey,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (resourceKey.present) {
      map['resource_key'] = Variable<String>(resourceKey.value);
    }
    if (lastFetchedAt.present) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetadataEntriesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('resourceKey: $resourceKey, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CacheMetadataEntriesTable cacheMetadataEntries =
      $CacheMetadataEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cacheMetadataEntries];
}

typedef $$CacheMetadataEntriesTableCreateCompanionBuilder =
    CacheMetadataEntriesCompanion Function({
      required String accountId,
      required String resourceKey,
      required DateTime lastFetchedAt,
      Value<int> rowid,
    });
typedef $$CacheMetadataEntriesTableUpdateCompanionBuilder =
    CacheMetadataEntriesCompanion Function({
      Value<String> accountId,
      Value<String> resourceKey,
      Value<DateTime> lastFetchedAt,
      Value<int> rowid,
    });

class $$CacheMetadataEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CacheMetadataEntriesTable> {
  $$CacheMetadataEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceKey => $composableBuilder(
    column: $table.resourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheMetadataEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheMetadataEntriesTable> {
  $$CacheMetadataEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceKey => $composableBuilder(
    column: $table.resourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheMetadataEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheMetadataEntriesTable> {
  $$CacheMetadataEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get resourceKey => $composableBuilder(
    column: $table.resourceKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => column,
  );
}

class $$CacheMetadataEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheMetadataEntriesTable,
          CacheMetadataEntry,
          $$CacheMetadataEntriesTableFilterComposer,
          $$CacheMetadataEntriesTableOrderingComposer,
          $$CacheMetadataEntriesTableAnnotationComposer,
          $$CacheMetadataEntriesTableCreateCompanionBuilder,
          $$CacheMetadataEntriesTableUpdateCompanionBuilder,
          (
            CacheMetadataEntry,
            BaseReferences<
              _$AppDatabase,
              $CacheMetadataEntriesTable,
              CacheMetadataEntry
            >,
          ),
          CacheMetadataEntry,
          PrefetchHooks Function()
        > {
  $$CacheMetadataEntriesTableTableManager(
    _$AppDatabase db,
    $CacheMetadataEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMetadataEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheMetadataEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CacheMetadataEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> resourceKey = const Value.absent(),
                Value<DateTime> lastFetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMetadataEntriesCompanion(
                accountId: accountId,
                resourceKey: resourceKey,
                lastFetchedAt: lastFetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String resourceKey,
                required DateTime lastFetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CacheMetadataEntriesCompanion.insert(
                accountId: accountId,
                resourceKey: resourceKey,
                lastFetchedAt: lastFetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CacheMetadataEntriesTable, CacheMetadataEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CacheMetadataEntriesTable,
                    CacheMetadataEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheMetadataEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheMetadataEntriesTable,
      CacheMetadataEntry,
      $$CacheMetadataEntriesTableFilterComposer,
      $$CacheMetadataEntriesTableOrderingComposer,
      $$CacheMetadataEntriesTableAnnotationComposer,
      $$CacheMetadataEntriesTableCreateCompanionBuilder,
      $$CacheMetadataEntriesTableUpdateCompanionBuilder,
      (
        CacheMetadataEntry,
        BaseReferences<
          _$AppDatabase,
          $CacheMetadataEntriesTable,
          CacheMetadataEntry
        >,
      ),
      CacheMetadataEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CacheMetadataEntriesTableTableManager get cacheMetadataEntries =>
      $$CacheMetadataEntriesTableTableManager(_db, _db.cacheMetadataEntries);
}
