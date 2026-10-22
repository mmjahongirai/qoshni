import 'package:qoshni/features/business_platform/domain/business_delivery_proof_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_of_delivery.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_status.dart';

enum BusinessDeliveryProofCreateResult {
  success,
  taskNotFound,
  nonDeliveryTask,
  scopeMismatch,
  invalidEvidence,
  invalidDescription,
  failure,
}

enum BusinessDeliveryProofTransitionResult {
  success,
  notFound,
  invalidTransition,
  duplicateStatus,
  failure,
}

class BusinessDeliveryProofTransitionRequest {
  const BusinessDeliveryProofTransitionRequest({
    required this.targetStatus,
    this.demoVerificationReason,
  });

  final BusinessDeliveryProofStatus targetStatus;
  final String? demoVerificationReason;
}

abstract class BusinessDeliveryProofRepository {
  String get businessScopeId;

  List<BusinessDeliveryProofOfDelivery> listForCurrentScope({
    String? branchId,
    String? deliveryTaskId,
  });

  BusinessDeliveryProofOfDelivery? findById(String proofId);

  BusinessDeliveryProofCreateResult createProof(
    BusinessDeliveryProofCreateInput input,
  );

  BusinessDeliveryProofTransitionResult applyTransition({
    required String proofId,
    required BusinessDeliveryProofTransitionRequest request,
  });

  List<BusinessDeliveryProofHistoryEvent> proofHistory(String proofId);
}
