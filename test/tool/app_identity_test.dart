import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/app_identity.dart';

void main() {
  test('identity preview is read-only, apply updates every platform, and reruns cleanly', () {
    final fixture = Directory.systemTemp.createTempSync('identity-tool-');
    addTearDown(() => fixture.deleteSync(recursive: true));
    final source = Directory.current;
    const paths = [
      'README.md',
      'pubspec.yaml',
      'tool/app_identity.current.json',
      'tool/app_identity.example.json',
      'lib/l10n/app_en.arb',
      'lib/core/persistence/app_database.dart',
      'lib/core/logging/app_logger.dart',
      'test/widget_test.dart',
      'docs/local_storage.md',
      'android/app/build.gradle.kts',
      'android/app/src/main/kotlin/com/example/flutter_starter/MainActivity.kt',
      'android/app/src/main/res/xml/backup_rules.xml',
      'android/app/src/main/res/xml/data_extraction_rules.xml',
      'ios/Runner.xcodeproj/project.pbxproj',
      'ios/Runner/Info.plist',
    ];
    for (final path in paths) {
      final target = File('${fixture.path}/$path');
      target.parent.createSync(recursive: true);
      File('${source.path}/$path').copySync(target.path);
    }
    final current = readIdentity(
      File('${fixture.path}/tool/app_identity.current.json'),
    );
    final desired = readIdentity(
      File('${fixture.path}/tool/app_identity.example.json'),
    );
    final pubspec = File('${fixture.path}/pubspec.yaml');
    final before = pubspec.readAsStringSync();

    final plan = planIdentityChange(fixture, current, desired);
    expect(pubspec.readAsStringSync(), before);
    expect(plan.edits.keys, contains('ios/Runner.xcodeproj/project.pbxproj'));
    expect(
      plan.moves.values.single,
      'android/app/src/main/kotlin/com/acme/notes/MainActivity.kt',
    );
    plan.apply();

    expect(pubspec.readAsStringSync(), contains('name: acme_notes'));
    final gradle = File('${fixture.path}/android/app/build.gradle.kts')
        .readAsStringSync();
    expect(gradle, contains('namespace = "com.acme.notes"'));
    for (final flavor in ['dev', 'staging', 'prod']) {
      expect(
        gradle,
        contains('applicationId = "${desired.androidApplicationIds[flavor]}"'),
      );
    }
    expect(gradle, isNot(contains('applicationIdSuffix')));
    expect(gradle, contains('"Acme Notes Staging"'));
    final xcode = File('${fixture.path}/ios/Runner.xcodeproj/project.pbxproj')
        .readAsStringSync();
    expect(xcode, contains('PRODUCT_BUNDLE_IDENTIFIER = com.acme.notes.dev;'));
    expect(
      xcode,
      contains('PRODUCT_BUNDLE_IDENTIFIER = com.acme.notes.staging;'),
    );
    expect(xcode, contains('PRODUCT_BUNDLE_IDENTIFIER = com.acme.notes;'));
    expect(xcode, contains('com.acme.notes.dev.RunnerTests'));
    expect(xcode, contains('APP_DISPLAY_NAME = "Acme Notes Dev"'));
    expect(
      File('${fixture.path}/lib/l10n/app_en.arb').readAsStringSync(),
      contains('"appTitle": "Acme Notes"'),
    );
    expect(
      File('${fixture.path}/test/widget_test.dart').readAsStringSync(),
      contains('package:acme_notes/'),
    );
    expect(
      File(
        '${fixture.path}/android/app/src/main/kotlin/com/acme/notes/MainActivity.kt',
      ).readAsStringSync(),
      contains('package com.acme.notes'),
    );
    expect(
      File('${fixture.path}/android/app/src/main/res/xml/backup_rules.xml')
          .readAsStringSync(),
      contains('acme_notes.sqlite'),
    );

    final next = planIdentityChange(
      fixture,
      readIdentity(File('${fixture.path}/tool/app_identity.current.json')),
      desired,
    );
    expect(next.edits, isEmpty);
    expect(next.moves, isEmpty);
  });

  test('rejects duplicate flavor application IDs before editing', () {
    expect(
      () => AppIdentity.fromJson({
        'displayName': 'Example',
        'dartPackageName': 'example',
        'androidNamespace': 'com.example.app',
        'androidApplicationIds': {
          'dev': 'com.example.app',
          'staging': 'com.example.app',
          'prod': 'com.example.app',
        },
        'iosBundleIds': {
          'dev': 'com.example.app.dev',
          'staging': 'com.example.app.staging',
          'prod': 'com.example.app',
        },
        'flavorDisplayNames': {
          'dev': 'Example Dev',
          'staging': 'Example Staging',
          'prod': 'Example',
        },
      }),
      throwsFormatException,
    );
  });
}
