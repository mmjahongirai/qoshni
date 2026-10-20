import 'package:qoshni/features/business_platform/domain/business_delivery_task.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';

enum BusinessDeliveryTaskCreateResult {
  success,
  invalidBranch,
  invalidFulfillmentLink,
  nonDeliveryFulfillmentType,
  failure,
}

enum BusinessDeliveryTaskTransitionResult {
  success,
  notFound,
  invalidTransition,
  terminalTask,
  failureReasonRequired,
  duplicateStatus,
  failure,
}

class BusinessDeliveryTaskTransitionRequest {
  const BusinessDeliveryTaskTransitionRequest({
    required this.targetStatus,
    this.failureReason,
    this.demoAssignmentReference,
  });

  final BusinessDeliveryTaskStatus targetStatus;
  final String? failureReason;
  final String? demoAssignmentReference;
}

abstract class BusinessDeliveryTaskRepository {
  String get businessScopeId;

  List<BusinessDeliveryTask> listForCurrentScope({
    String? branchId,
    BusinessDeliveryTaskStatus? status,
  });

  BusinessDeliveryTask? findById(String deliveryTaskId);

  BusinessDeliveryTaskCreateResult createDemoTask(
    BusinessDeliveryTaskCreateInput input,
  );

  BusinessDeliveryTaskTransitionResult applyTransition({
    required String deliveryTaskId,
    required BusinessDeliveryTaskTransitionRequest request,
  });

  List<BusinessDeliveryTaskHistoryEvent> taskHistory(String deliveryTaskId);
}
