import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';

enum QoshniNotificationEligibilityReason {
  eligible,
  suppressedCategoryDisabled,
  suppressedChannelDisabled,
  suppressedPromotionalConsentDisabled,
  suppressedQuietHours,
  suppressedInvalidInput,
}

class QoshniNotificationEligibilityInput {
  const QoshniNotificationEligibilityInput({
    required this.category,
    required this.channel,
    required this.priority,
  });

  final QoshniNotificationCategory category;
  final QoshniNotificationChannel channel;
  final QoshniNotificationPriority priority;
}

class QoshniNotificationEligibilityResult {
  const QoshniNotificationEligibilityResult({
    required this.isEligible,
    required this.reason,
  });

  final bool isEligible;
  final QoshniNotificationEligibilityReason reason;
}
