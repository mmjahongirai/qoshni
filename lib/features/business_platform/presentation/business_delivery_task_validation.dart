import 'package:qoshni/features/business_platform/domain/business_delivery_task.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';

String? catalogDeliveryTaskCreateValidationError(
  BusinessDeliveryTaskCreateInput input,
) {
  if (input.fulfillmentType != BusinessFulfillmentType.delivery) {
    return 'non_delivery_type';
  }
  if (input.branchId.trim().isEmpty) {
    return 'invalid_branch';
  }
  if (input.demoPickupLabel.trim().isEmpty ||
      input.demoDropOffLabel.trim().isEmpty) {
    return 'empty_label';
  }
  return null;
}

String? catalogDeliveryTaskFailureReasonValidationError(String? reason) {
  final trimmed = reason?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'failure_reason_required';
  }
  if (trimmed.length > 240) {
    return 'failure_reason_too_long';
  }
  return null;
}

String catalogDeliveryTaskTransitionActionKey({
  required BusinessDeliveryTaskStatus from,
  required BusinessDeliveryTaskStatus to,
}) {
  return '${from.name}->${to.name}';
}
