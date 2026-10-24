import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_policy.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';

void main() {
  test('allows draft to published and blocks archived transitions', () {
    expect(
      QoshniSystemMessageLifecyclePolicy.canTransition(
        QoshniSystemMessageLifecycleStatus.draft,
        QoshniSystemMessageLifecycleStatus.published,
      ),
      isTrue,
    );
    expect(
      QoshniSystemMessageLifecyclePolicy.canTransition(
        QoshniSystemMessageLifecycleStatus.archived,
        QoshniSystemMessageLifecycleStatus.published,
      ),
      isFalse,
    );
  });
}
