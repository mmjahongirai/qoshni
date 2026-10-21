import 'package:qoshni/features/business_platform/domain/business_delivery_exception.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_status.dart';

enum BusinessDeliveryExceptionCreateResult {
  success,
  taskNotFound,
  nonDeliveryTask,
  scopeMismatch,
  invalidReason,
  failure,
}

enum BusinessDeliveryExceptionTransitionResult {
  success,
  notFound,
  invalidTransition,
  resolutionNoteRequired,
  duplicateStatus,
  failure,
}

class BusinessDeliveryExceptionTransitionRequest {
  const BusinessDeliveryExceptionTransitionRequest({
    required this.targetStatus,
    this.resolutionNote,
    this.reopenNote,
  });

  final BusinessDeliveryExceptionStatus targetStatus;
  final String? resolutionNote;
  final String? reopenNote;
}

abstract class BusinessDeliveryExceptionRepository {
  String get businessScopeId;

  List<BusinessDeliveryException> listForCurrentScope({
    String? branchId,
    String? deliveryTaskId,
  });

  BusinessDeliveryException? findById(String exceptionId);

  BusinessDeliveryExceptionCreateResult createException(
    BusinessDeliveryExceptionCreateInput input,
  );

  BusinessDeliveryExceptionTransitionResult applyTransition({
    required String exceptionId,
    required BusinessDeliveryExceptionTransitionRequest request,
  });

  List<BusinessDeliveryExceptionHistoryEvent> exceptionHistory(
    String exceptionId,
  );
}
