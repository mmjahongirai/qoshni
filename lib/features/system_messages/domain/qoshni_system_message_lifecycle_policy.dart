import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';

/// Documented lifecycle transitions for demo system messages.
abstract final class QoshniSystemMessageLifecyclePolicy {
  static bool canTransition(
    QoshniSystemMessageLifecycleStatus from,
    QoshniSystemMessageLifecycleStatus to,
  ) {
    return switch (from) {
      QoshniSystemMessageLifecycleStatus.draft =>
        to == QoshniSystemMessageLifecycleStatus.published ||
            to == QoshniSystemMessageLifecycleStatus.archived,
      QoshniSystemMessageLifecycleStatus.published =>
        to == QoshniSystemMessageLifecycleStatus.withdrawn ||
            to == QoshniSystemMessageLifecycleStatus.archived,
      QoshniSystemMessageLifecycleStatus.withdrawn =>
        to == QoshniSystemMessageLifecycleStatus.archived,
      QoshniSystemMessageLifecycleStatus.archived => false,
    };
  }
}
