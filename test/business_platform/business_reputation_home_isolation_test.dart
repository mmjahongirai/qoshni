import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home feature does not import reputation event module', () {
    final homeDir = Directory('lib/features/home');
    expect(homeDir.existsSync(), isTrue);
    final violations = <String>[];
    for (final entity in homeDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final content = entity.readAsStringSync();
      if (content.contains('business_reputation') ||
          content.contains('BusinessReputation')) {
        violations.add(entity.path);
      }
    }
    expect(violations, isEmpty);
  });
}
