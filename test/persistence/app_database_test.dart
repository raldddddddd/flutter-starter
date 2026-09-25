import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/persistence/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('creates schema version 2 and distinguishes never fetched', () async {
    expect(database.schemaVersion, 2);
    expect(await database.metadataFor('alice', 'feed'), isNull);
    expect(
      await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE name = 'cache_metadata_entries'",
          )
          .get(),
      hasLength(1),
    );
  });

  test(
    'metadata is scoped to account and can represent fetched empty',
    () async {
      final fetchedAt = DateTime.utc(2026, 1, 2, 3, 4, 5);
      await database.markFetched('alice', 'feed', fetchedAt);

      expect(
        (await database.metadataFor(
          'alice',
          'feed',
        ))!.lastFetchedAt.isAtSameMomentAs(fetchedAt),
        isTrue,
      );
      expect(await database.metadataFor('bob', 'feed'), isNull);
      expect(await database.metadataFor('alice', 'profile'), isNull);

      await database.markFetched('bob', 'feed', fetchedAt);
      expect(await database.clearAccountMetadata('alice'), 1);
      expect(await database.metadataFor('alice', 'feed'), isNull);
      expect(await database.metadataFor('bob', 'feed'), isNotNull);
    },
  );

  test('transaction rolls back metadata on failure', () async {
    final fetchedAt = DateTime.utc(2026, 1, 2);
    await expectLater(
      database.transaction(() async {
        await database.markFetched('alice', 'feed', fetchedAt);
        throw StateError('rollback');
      }),
      throwsStateError,
    );
    expect(await database.metadataFor('alice', 'feed'), isNull);
  });
}
