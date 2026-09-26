import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main Android manifest grants network access in release builds', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(
      RegExp(
        r'<uses-permission\s+android:name="android.permission.INTERNET"\s*/>',
      ).hasMatch(manifest),
      isTrue,
    );
  });
}
