import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/persistence/app_database.dart';

import '../generated_migrations/schema.dart';

void main() {
  test('fresh version 2 schema matches the exported schema', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final freshDatabase = AppDatabase(NativeDatabase.memory());
    try {
      await verifier.migrateAndValidate(freshDatabase, 2);
    } finally {
      await freshDatabase.close();
    }

    final connection = await verifier.startAt(1);
    final database = AppDatabase(connection);
    try {
      await verifier.migrateAndValidate(database, 2);
      expect(database.schemaVersion, 2);
      expect(await database.sampleItemsFor('alice'), isEmpty);
    } finally {
      await database.close();
    }
  });
}
