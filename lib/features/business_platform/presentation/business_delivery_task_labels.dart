import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';

extension BusinessDeliveryTaskStatusLabels on AppLocalizations {
  String businessDeliveryTaskStatusLabel(BusinessDeliveryTaskStatus status) {
    switch (status) {
      case BusinessDeliveryTaskStatus.created:
        return businessDeliveryTaskStatusCreated;
      case BusinessDeliveryTaskStatus.readyForPickup:
        return businessDeliveryTaskStatusReadyForPickup;
      case BusinessDeliveryTaskStatus.assigned:
        return businessDeliveryTaskStatusAssigned;
      case BusinessDeliveryTaskStatus.pickedUp:
        return businessDeliveryTaskStatusPickedUp;
      case BusinessDeliveryTaskStatus.inTransit:
        return businessDeliveryTaskStatusInTransit;
      case BusinessDeliveryTaskStatus.delivered:
        return businessDeliveryTaskStatusDelivered;
      case BusinessDeliveryTaskStatus.failed:
        return businessDeliveryTaskStatusFailed;
      case BusinessDeliveryTaskStatus.cancelled:
        return businessDeliveryTaskStatusCancelled;
    }
  }

  String businessDeliveryTaskActionLabel(
    BusinessDeliveryTaskStatus targetStatus,
  ) {
    switch (targetStatus) {
      case BusinessDeliveryTaskStatus.readyForPickup:
        return businessDeliveryTaskActionReadyForPickup;
      case BusinessDeliveryTaskStatus.assigned:
        return businessDeliveryTaskActionAssignDemo;
      case BusinessDeliveryTaskStatus.pickedUp:
        return businessDeliveryTaskActionConfirmPickup;
      case BusinessDeliveryTaskStatus.inTransit:
        return businessDeliveryTaskActionMarkInTransit;
      case BusinessDeliveryTaskStatus.delivered:
        return businessDeliveryTaskActionMarkDelivered;
      case BusinessDeliveryTaskStatus.failed:
        return businessDeliveryTaskActionMarkFailed;
      case BusinessDeliveryTaskStatus.cancelled:
        return businessDeliveryTaskActionCancel;
      case BusinessDeliveryTaskStatus.created:
        return businessDeliveryTaskStatusCreated;
    }
  }
}
