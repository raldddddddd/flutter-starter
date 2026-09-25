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

class $SampleItemsTable extends SampleItems
    with TableInfo<$SampleItemsTable, SampleItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SampleItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [accountId, itemId, title, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sample_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SampleItem> instance, {
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
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, itemId};
  @override
  SampleItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SampleItem(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $SampleItemsTable createAlias(String alias) {
    return $SampleItemsTable(attachedDatabase, alias);
  }
}

class SampleItem extends DataClass implements Insertable<SampleItem> {
  final String accountId;
  final String itemId;
  final String title;
  final int position;
  const SampleItem({
    required this.accountId,
    required this.itemId,
    required this.title,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['item_id'] = Variable<String>(itemId);
    map['title'] = Variable<String>(title);
    map['position'] = Variable<int>(position);
    return map;
  }

  SampleItemsCompanion toCompanion(bool nullToAbsent) {
    return SampleItemsCompanion(
      accountId: Value(accountId),
      itemId: Value(itemId),
      title: Value(title),
      position: Value(position),
    );
  }

  factory SampleItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SampleItem(
      accountId: serializer.fromJson<String>(json['accountId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      title: serializer.fromJson<String>(json['title']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'itemId': serializer.toJson<String>(itemId),
      'title': serializer.toJson<String>(title),
      'position': serializer.toJson<int>(position),
    };
  }

  SampleItem copyWith({
    String? accountId,
    String? itemId,
    String? title,
    int? position,
  }) => SampleItem(
    accountId: accountId ?? this.accountId,
    itemId: itemId ?? this.itemId,
    title: title ?? this.title,
    position: position ?? this.position,
  );
  SampleItem copyWithCompanion(SampleItemsCompanion data) {
    return SampleItem(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      title: data.title.present ? data.title.value : this.title,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SampleItem(')
          ..write('accountId: $accountId, ')
          ..write('itemId: $itemId, ')
          ..write('title: $title, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountId, itemId, title, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SampleItem &&
          other.accountId == this.accountId &&
          other.itemId == this.itemId &&
          other.title == this.title &&
          other.position == this.position);
}

class SampleItemsCompanion extends UpdateCompanion<SampleItem> {
  final Value<String> accountId;
  final Value<String> itemId;
  final Value<String> title;
  final Value<int> position;
  final Value<int> rowid;
  const SampleItemsCompanion({
    this.accountId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.title = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SampleItemsCompanion.insert({
    required String accountId,
    required String itemId,
    required String title,
    required int position,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       itemId = Value(itemId),
       title = Value(title),
       position = Value(position);
  static Insertable<SampleItem> custom({
    Expression<String>? accountId,
    Expression<String>? itemId,
    Expression<String>? title,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (itemId != null) 'item_id': itemId,
      if (title != null) 'title': title,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SampleItemsCompanion copyWith({
    Value<String>? accountId,
    Value<String>? itemId,
    Value<String>? title,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return SampleItemsCompanion(
      accountId: accountId ?? this.accountId,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SampleItemsCompanion(')
          ..write('accountId: $accountId, ')
          ..write('itemId: $itemId, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
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
  late final $SampleItemsTable sampleItems = $SampleItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cacheMetadataEntries,
    sampleItems,
  ];
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
typedef $$SampleItemsTableCreateCompanionBuilder =
    SampleItemsCompanion Function({
      required String accountId,
      required String itemId,
      required String title,
      required int position,
      Value<int> rowid,
    });
typedef $$SampleItemsTableUpdateCompanionBuilder =
    SampleItemsCompanion Function({
      Value<String> accountId,
      Value<String> itemId,
      Value<String> title,
      Value<int> position,
      Value<int> rowid,
    });

class $$SampleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SampleItemsTable> {
  $$SampleItemsTableFilterComposer({
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

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SampleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SampleItemsTable> {
  $$SampleItemsTableOrderingComposer({
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

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SampleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SampleItemsTable> {
  $$SampleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$SampleItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SampleItemsTable,
          SampleItem,
          $$SampleItemsTableFilterComposer,
          $$SampleItemsTableOrderingComposer,
          $$SampleItemsTableAnnotationComposer,
          $$SampleItemsTableCreateCompanionBuilder,
          $$SampleItemsTableUpdateCompanionBuilder,
          (
            SampleItem,
            BaseReferences<_$AppDatabase, $SampleItemsTable, SampleItem>,
          ),
          SampleItem,
          PrefetchHooks Function()
        > {
  $$SampleItemsTableTableManager(_$AppDatabase db, $SampleItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SampleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SampleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SampleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SampleItemsCompanion(
                accountId: accountId,
                itemId: itemId,
                title: title,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String itemId,
                required String title,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => SampleItemsCompanion.insert(
                accountId: accountId,
                itemId: itemId,
                title: title,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SampleItemsTable, SampleItem>(table),
                  BaseReferences<_$AppDatabase, $SampleItemsTable, SampleItem>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SampleItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SampleItemsTable,
      SampleItem,
      $$SampleItemsTableFilterComposer,
      $$SampleItemsTableOrderingComposer,
      $$SampleItemsTableAnnotationComposer,
      $$SampleItemsTableCreateCompanionBuilder,
      $$SampleItemsTableUpdateCompanionBuilder,
      (
        SampleItem,
        BaseReferences<_$AppDatabase, $SampleItemsTable, SampleItem>,
      ),
      SampleItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CacheMetadataEntriesTableTableManager get cacheMetadataEntries =>
      $$CacheMetadataEntriesTableTableManager(_db, _db.cacheMetadataEntries);
  $$SampleItemsTableTableManager get sampleItems =>
      $$SampleItemsTableTableManager(_db, _db.sampleItems);
}
