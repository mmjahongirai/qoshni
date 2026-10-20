import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';

bool catalogDeliveryTaskTransitionAllowed({
  required BusinessDeliveryTaskStatus from,
  required BusinessDeliveryTaskStatus to,
}) {
  if (from == to) {
    return false;
  }
  if (businessDeliveryTaskStatusTerminal(from)) {
    return false;
  }
  switch (from) {
    case BusinessDeliveryTaskStatus.created:
      return to == BusinessDeliveryTaskStatus.readyForPickup ||
          to == BusinessDeliveryTaskStatus.cancelled;
    case BusinessDeliveryTaskStatus.readyForPickup:
      return to == BusinessDeliveryTaskStatus.assigned ||
          to == BusinessDeliveryTaskStatus.cancelled;
    case BusinessDeliveryTaskStatus.assigned:
      return to == BusinessDeliveryTaskStatus.pickedUp ||
          to == BusinessDeliveryTaskStatus.failed ||
          to == BusinessDeliveryTaskStatus.cancelled;
    case BusinessDeliveryTaskStatus.pickedUp:
      return to == BusinessDeliveryTaskStatus.inTransit ||
          to == BusinessDeliveryTaskStatus.failed;
    case BusinessDeliveryTaskStatus.inTransit:
      return to == BusinessDeliveryTaskStatus.delivered ||
          to == BusinessDeliveryTaskStatus.failed;
    case BusinessDeliveryTaskStatus.failed:
      return to == BusinessDeliveryTaskStatus.readyForPickup ||
          to == BusinessDeliveryTaskStatus.cancelled;
    case BusinessDeliveryTaskStatus.delivered:
    case BusinessDeliveryTaskStatus.cancelled:
      return false;
  }
}

List<BusinessDeliveryTaskStatus> catalogDeliveryTaskAllowedTargets(
  BusinessDeliveryTaskStatus from,
) {
  return BusinessDeliveryTaskStatus.values
      .where((to) => catalogDeliveryTaskTransitionAllowed(from: from, to: to))
      .toList(growable: false);
}
