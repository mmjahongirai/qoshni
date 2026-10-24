import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('platform governance domain does not import business staff modules', () {
    final dir = Directory('lib/features/platform_governance');
    expect(dir.existsSync(), isTrue);
    final violations = <String>[];
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final content = entity.readAsStringSync();
      if (content.contains('business_staff') ||
          content.contains('BusinessStaffRole')) {
        violations.add(entity.path);
      }
    }
    expect(violations, isEmpty);
  });
}
