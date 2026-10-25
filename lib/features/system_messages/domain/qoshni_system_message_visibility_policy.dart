import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';

/// Visibility rules for the public announcement feed:
/// - only [published] messages;
/// - evaluation time must be on/after [visibleFrom] (or [publishedAt] when from is null);
/// - evaluation time must be strictly before [visibleUntil] when set.
abstract final class QoshniSystemMessageVisibilityPolicy {
  static bool isCurrentlyVisible({
    required QoshniSystemMessage message,
    required DateTime evaluationUtc,
  }) {
    if (message.lifecycleStatus != QoshniSystemMessageLifecycleStatus.published) {
      return false;
    }

    final eval = evaluationUtc.toUtc();
    final start = (message.visibleFrom ?? message.publishedAt)?.toUtc();
    if (start != null && eval.isBefore(start)) {
      return false;
    }

    final end = message.visibleUntil?.toUtc();
    if (end != null && !eval.isBefore(end)) {
      return false;
    }

    return true;
  }
}
