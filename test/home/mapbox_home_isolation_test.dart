import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home feature does not import Phase 13 trust modules', () {
    final homeDir = Directory('lib/features/home');
    expect(homeDir.existsSync(), isTrue);
    final violations = <String>[];
    for (final entity in homeDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final content = entity.readAsStringSync();
      if (content.contains('business_review') ||
          content.contains('business_complaint') ||
          content.contains('business_dispute') ||
          content.contains('business_reputation')) {
        violations.add(entity.path);
      }
    }
    expect(violations, isEmpty);
  });
}
