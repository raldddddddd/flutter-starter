import 'dart:convert';
import 'dart:io';

const _flavors = ['dev', 'staging', 'prod'];
const _currentManifest = 'tool/app_identity.current.json';

final class AppIdentity {
  AppIdentity.fromJson(Map<String, dynamic> json)
    : displayName = _string(json, 'displayName'),
      dartPackageName = _string(json, 'dartPackageName'),
      androidNamespace = _string(json, 'androidNamespace'),
      androidApplicationIds = _flavorMap(json, 'androidApplicationIds'),
      iosBundleIds = _flavorMap(json, 'iosBundleIds'),
      flavorDisplayNames = _flavorMap(json, 'flavorDisplayNames') {
    _validate();
  }

  final String displayName;
  final String dartPackageName;
  final String androidNamespace;
  final Map<String, String> androidApplicationIds;
  final Map<String, String> iosBundleIds;
  final Map<String, String> flavorDisplayNames;

  Map<String, Object> toJson() => {
    'displayName': displayName,
    'dartPackageName': dartPackageName,
    'androidNamespace': androidNamespace,
    'androidApplicationIds': androidApplicationIds,
    'iosBundleIds': iosBundleIds,
    'flavorDisplayNames': flavorDisplayNames,
  };

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a nonempty string.');
    }
    return value;
  }

  static Map<String, String> _flavorMap(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! Map<String, dynamic> ||
        value.keys.toSet().difference(_flavors.toSet()).isNotEmpty) {
      throw FormatException('$key must contain exactly dev, staging, prod.');
    }
    return {for (final flavor in _flavors) flavor: _string(value, flavor)};
  }

  void _validate() {
    final dartName = RegExp(r'^[a-z][a-z0-9_]*$');
    final androidId = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$');
    final iosId = RegExp(r'^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$');
    if (!dartName.hasMatch(dartPackageName)) {
      throw FormatException('Invalid Dart package name: $dartPackageName');
    }
    if (!androidId.hasMatch(androidNamespace) ||
        androidApplicationIds.values.any((id) => !androidId.hasMatch(id))) {
      throw const FormatException(
        'Android namespace and IDs must be dotted lowercase identifiers.',
      );
    }
    if (iosBundleIds.values.any((id) => !iosId.hasMatch(id))) {
      throw const FormatException('iOS bundle IDs must be dotted identifiers.');
    }
    if (androidApplicationIds.values.toSet().length != 3 ||
        iosBundleIds.values.toSet().length != 3) {
      throw const FormatException(
        'Flavor application and bundle IDs must be unique.',
      );
    }
    for (final name in [displayName, ...flavorDisplayNames.values]) {
      if (name.contains(RegExp(r'["\\\n\r]'))) {
        throw const FormatException(
          'Display names cannot contain quotes, backslashes, or newlines.',
        );
      }
    }
  }
}

AppIdentity readIdentity(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Identity config must be a JSON object.');
  }
  return AppIdentity.fromJson(decoded);
}

final class IdentityPlan {
  IdentityPlan(this.root, this.current, this.desired);

  final Directory root;
  final AppIdentity current;
  final AppIdentity desired;
  final edits = <String, String>{};
  final moves = <String, String>{};

  File file(String path) => File('${root.path}/$path');

  void edit(String path, String Function(String) transform) {
    final before = file(path).readAsStringSync();
    final after = transform(before);
    if (after != before) edits[path] = after;
  }

  void apply() {
    for (final entry in edits.entries) {
      file(entry.key).writeAsStringSync(entry.value);
    }
    for (final entry in moves.entries) {
      final destination = file(entry.value);
      destination.parent.createSync(recursive: true);
      file(entry.key).renameSync(destination.path);
    }
  }
}

String _replaceRequired(
  String source,
  String before,
  String after,
  String path,
) {
  if (!source.contains(before)) {
    throw StateError('Expected text not found in $path: $before');
  }
  return source.replaceAll(before, after);
}

String _replaceSingleMatch(
  String source,
  RegExp pattern,
  String Function(Match) replacement,
  String path,
) {
  final matches = pattern.allMatches(source).toList();
  if (matches.length != 1) {
    throw StateError('Expected one match in $path, found ${matches.length}.');
  }
  final match = matches.single;
  return source.replaceRange(match.start, match.end, replacement(match));
}

IdentityPlan planIdentityChange(
  Directory root,
  AppIdentity current,
  AppIdentity desired,
) {
  final plan = IdentityPlan(root, current, desired);
  final oldPackage = current.dartPackageName;
  final newPackage = desired.dartPackageName;

  plan.edit(
    'pubspec.yaml',
    (source) => _replaceRequired(
      source,
      'name: $oldPackage\n',
      'name: $newPackage\n',
      'pubspec.yaml',
    ),
  );
  plan.edit(
    'lib/l10n/app_en.arb',
    (source) => _replaceRequired(
      source,
      '"appTitle": ${jsonEncode(current.displayName)}',
      '"appTitle": ${jsonEncode(desired.displayName)}',
      'lib/l10n/app_en.arb',
    ),
  );
  plan.edit(
    'lib/core/persistence/app_database.dart',
    (source) => _replaceRequired(
      source,
      "name: '$oldPackage'",
      "name: '$newPackage'",
      'lib/core/persistence/app_database.dart',
    ),
  );
  plan.edit(
    'lib/core/logging/app_logger.dart',
    (source) => _replaceRequired(
      source,
      "name: '$oldPackage'",
      "name: '$newPackage'",
      'lib/core/logging/app_logger.dart',
    ),
  );
  plan.edit(
    'ios/Runner/Info.plist',
    (source) => _replaceRequired(
      source,
      '<string>$oldPackage</string>',
      '<string>$newPackage</string>',
      'ios/Runner/Info.plist',
    ),
  );
  for (final path in [
    'android/app/src/main/res/xml/backup_rules.xml',
    'android/app/src/main/res/xml/data_extraction_rules.xml',
    'docs/local_storage.md',
  ]) {
    plan.edit(
      path,
      (source) => _replaceRequired(
        source,
        '$oldPackage.sqlite',
        '$newPackage.sqlite',
        path,
      ),
    );
  }

  final kotlinPath =
      'android/app/src/main/kotlin/'
      '${current.androidNamespace.replaceAll('.', '/')}/MainActivity.kt';
  final newKotlinPath =
      'android/app/src/main/kotlin/'
      '${desired.androidNamespace.replaceAll('.', '/')}/MainActivity.kt';
  plan.edit(
    kotlinPath,
    (source) => _replaceRequired(
      source,
      'package ${current.androidNamespace}',
      'package ${desired.androidNamespace}',
      kotlinPath,
    ),
  );
  if (kotlinPath != newKotlinPath) {
    if (plan.file(newKotlinPath).existsSync()) {
      throw StateError('Target Kotlin file already exists: $newKotlinPath');
    }
    plan.moves[kotlinPath] = newKotlinPath;
  }

  plan.edit('android/app/build.gradle.kts', (source) {
    const path = 'android/app/build.gradle.kts';
    var result = _replaceRequired(
      source,
      'namespace = "${current.androidNamespace}"',
      'namespace = "${desired.androidNamespace}"',
      path,
    );
    result = _replaceSingleMatch(
      result,
      RegExp(r'defaultConfig \{[\s\S]*?\n    \}'),
      (match) => _replaceRequired(
        match.group(0)!,
        'applicationId = "${current.androidApplicationIds['prod']}"',
        'applicationId = "${desired.androidApplicationIds['prod']}"',
        path,
      ),
      path,
    );
    for (final flavor in _flavors) {
      result = _replaceSingleMatch(
        result,
        RegExp('create\\("$flavor"\\) \\{[\\s\\S]*?\\n        \\}'),
        (match) {
          var block = match.group(0)!;
          block = block.replaceAll(
            RegExp(
              r'^[ \t]*applicationId(?:Suffix)? = "[^"]*"\n',
              multiLine: true,
            ),
            '',
          );
          block = _replaceRequired(
            block,
            'dimension = "environment"\n',
            'dimension = "environment"\n'
                '            applicationId = "${desired.androidApplicationIds[flavor]}"\n',
            path,
          );
          block = _replaceSingleMatch(
            block,
            RegExp(r'resValue\("string", "app_name", "[^"]*"\)'),
            (_) =>
                'resValue("string", "app_name", '
                '"${desired.flavorDisplayNames[flavor]}")',
            path,
          );
          return block;
        },
        path,
      );
    }
    return result;
  });

  plan.edit('ios/Runner.xcodeproj/project.pbxproj', (source) {
    const path = 'ios/Runner.xcodeproj/project.pbxproj';
    final counts = {for (final flavor in _flavors) flavor: 0};
    final result = source.replaceAllMapped(
      RegExp(r'buildSettings = \{[\s\S]*?\n\t\t\t\};'),
      (match) {
        var block = match.group(0)!;
        final idMatch = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);')
            .firstMatch(block);
        if (idMatch == null) return block;
        final oldId = idMatch.group(1)!;
        for (final flavor in _flavors) {
          final appId = current.iosBundleIds[flavor]!;
          final testId = '$appId.RunnerTests';
          if (oldId != appId && oldId != testId) continue;
          counts[flavor] = counts[flavor]! + 1;
          final newId = desired.iosBundleIds[flavor]!;
          block = block.replaceFirst(
            'PRODUCT_BUNDLE_IDENTIFIER = $oldId;',
            'PRODUCT_BUNDLE_IDENTIFIER = '
                '${oldId == testId ? '$newId.RunnerTests' : newId};',
          );
          if (oldId == appId) {
            final displayName = desired.flavorDisplayNames[flavor]!;
            if (block.contains('APP_DISPLAY_NAME = ')) {
              block = _replaceSingleMatch(
                block,
                RegExp(r'APP_DISPLAY_NAME = "[^"]*";'),
                (_) => 'APP_DISPLAY_NAME = "$displayName";',
                path,
              );
            } else {
              block = block.replaceFirst(
                'buildSettings = {\n',
                'buildSettings = {\n\t\t\t\tAPP_DISPLAY_NAME = "$displayName";\n',
              );
            }
          }
          return block;
        }
        return block;
      },
    );
    if (counts.values.any((count) => count == 0)) {
      throw StateError(
        'Missing iOS bundle identifiers for one or more flavors.',
      );
    }
    return result;
  });

  for (final folder in ['lib', 'test']) {
    final directory = Directory('${root.path}/$folder');
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.endsWith('.g.dart') ||
          entity.path.endsWith('.freezed.dart')) {
        continue;
      }
      final path = entity.path.substring(root.path.length + 1);
      final source = entity.readAsStringSync();
      final updated = source.replaceAll(
        'package:$oldPackage/',
        'package:$newPackage/',
      );
      if (updated != source) plan.edits[path] = updated;
    }
  }
  final readme = plan.file('README.md');
  if (readme.existsSync()) {
    plan.edit(
      'README.md',
      (source) => source.replaceFirst(
        '# ${current.displayName}\n',
        '# ${desired.displayName}\n',
      ),
    );
  }
  plan.edits[_currentManifest] =
      '${const JsonEncoder.withIndent('  ').convert(desired.toJson())}\n';
  if (plan.edits[_currentManifest] ==
      plan.file(_currentManifest).readAsStringSync()) {
    plan.edits.remove(_currentManifest);
  }
  return plan;
}

void main(List<String> arguments) {
  try {
    String? configPath;
    var root = Directory.current;
    var apply = false;
    for (var index = 0; index < arguments.length; index++) {
      switch (arguments[index]) {
        case '--config':
          configPath = arguments[++index];
        case '--root':
          root = Directory(arguments[++index]);
        case '--apply':
          apply = true;
        default:
          throw const FormatException(
            'Usage: dart run tool/app_identity.dart --config FILE [--apply] [--root DIR]',
          );
      }
    }
    if (configPath == null) {
      throw const FormatException(
        'Pass --config with a desired identity JSON file.',
      );
    }
    root = root.absolute;
    final configFile = File(configPath);
    final desired = readIdentity(
      configFile.isAbsolute ? configFile : File('${root.path}/$configPath'),
    );
    final current = readIdentity(File('${root.path}/$_currentManifest'));
    final plan = planIdentityChange(root, current, desired);
    stdout.writeln(apply ? 'Applying identity changes:' : 'Identity dry run:');
    stdout.writeln(
      '  display name: ${current.displayName} -> ${desired.displayName}',
    );
    stdout.writeln(
      '  Dart package: ${current.dartPackageName} -> ${desired.dartPackageName}',
    );
    stdout.writeln(
      '  Android namespace: ${current.androidNamespace} -> ${desired.androidNamespace}',
    );
    for (final flavor in _flavors) {
      stdout.writeln(
        '  $flavor Android ID: ${current.androidApplicationIds[flavor]} '
        '-> ${desired.androidApplicationIds[flavor]}',
      );
      stdout.writeln(
        '  $flavor iOS ID: ${current.iosBundleIds[flavor]} '
        '-> ${desired.iosBundleIds[flavor]}',
      );
      stdout.writeln(
        '  $flavor display name: ${current.flavorDisplayNames[flavor]} '
        '-> ${desired.flavorDisplayNames[flavor]}',
      );
    }
    for (final path in plan.edits.keys.toList()..sort()) {
      stdout.writeln('  edit $path');
    }
    for (final entry in plan.moves.entries) {
      stdout.writeln('  move ${entry.key} -> ${entry.value}');
    }
    if (apply) {
      plan.apply();
      stdout.writeln(
        'Review with git diff, then run flutter pub get and tool/verify.sh.',
      );
    } else {
      stdout.writeln('No files changed. Re-run with --apply after reviewing.');
    }
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
