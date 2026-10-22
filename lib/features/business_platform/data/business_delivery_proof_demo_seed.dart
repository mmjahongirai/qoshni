import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_delivery_task_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_method.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_of_delivery.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_status.dart';

const String kDemoDeliveryProofPhotoPendingId =
    'demo-delivery-proof-photo-pending-001';
const String kDemoDeliveryProofOtpVerifiedId =
    'demo-delivery-proof-otp-verified-002';
const String kDemoDeliveryProofSignatureRejectedId =
    'demo-delivery-proof-signature-rejected-003';
const String kDemoDeliveryProofDeliveredVerifiedId =
    'demo-delivery-proof-delivered-confirmed-004';

List<BusinessDeliveryProofOfDelivery> buildDemoDeliveryProofs({
  required String businessScopeId,
}) {
  final epoch = kDemoDeliveryTaskEpoch;
  return [
    BusinessDeliveryProofOfDelivery(
      proofId: kDemoDeliveryProofPhotoPendingId,
      deliveryTaskId: kDemoDeliveryTaskInTransitId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      method: BusinessDeliveryProofMethod.photo,
      status: BusinessDeliveryProofStatus.pending,
      demoEvidenceReference: 'demo-evidence-photo-slot-in-transit',
      description: 'Demo: placeholder photo evidence reference only',
      createdAt: epoch.add(const Duration(hours: 4, minutes: 30)),
      updatedAt: epoch.add(const Duration(hours: 4, minutes: 30)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessDeliveryProofOfDelivery(
      proofId: kDemoDeliveryProofOtpVerifiedId,
      deliveryTaskId: kDemoDeliveryTaskInTransitId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      method: BusinessDeliveryProofMethod.recipientOtp,
      status: BusinessDeliveryProofStatus.verified,
      demoEvidenceReference: 'demo-evidence-otp-session-ref',
      description: 'Demo: OTP flow not executed — operator verified manually',
      demoVerificationReason: 'Demo operator verification',
      verifiedAt: epoch.add(const Duration(hours: 4, minutes: 45)),
      createdAt: epoch.add(const Duration(hours: 4, minutes: 40)),
      updatedAt: epoch.add(const Duration(hours: 4, minutes: 45)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessDeliveryProofOfDelivery(
      proofId: kDemoDeliveryProofSignatureRejectedId,
      deliveryTaskId: kDemoDeliveryTaskFailedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      method: BusinessDeliveryProofMethod.signature,
      status: BusinessDeliveryProofStatus.rejected,
      demoEvidenceReference: 'demo-evidence-signature-capture-ref',
      description: 'Demo: signature capture not stored',
      demoVerificationReason: 'Demo: evidence incomplete',
      verifiedAt: epoch.add(const Duration(hours: 6, minutes: 10)),
      createdAt: epoch.add(const Duration(hours: 6)),
      updatedAt: epoch.add(const Duration(hours: 6, minutes: 10)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessDeliveryProofOfDelivery(
      proofId: kDemoDeliveryProofDeliveredVerifiedId,
      deliveryTaskId: kDemoDeliveryTaskDeliveredId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      method: BusinessDeliveryProofMethod.recipientConfirmation,
      status: BusinessDeliveryProofStatus.verified,
      demoEvidenceReference: 'demo-evidence-delivered-confirmation-ref',
      description: 'Demo: recipient confirmation metadata only',
      demoVerificationReason: 'Demo historical verification',
      verifiedAt: epoch.add(const Duration(days: 1)),
      createdAt: epoch.add(const Duration(hours: 23)),
      updatedAt: epoch.add(const Duration(days: 1)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
  ];
}

Map<String, List<BusinessDeliveryProofHistoryEvent>>
    buildDemoDeliveryProofHistory({
  required List<BusinessDeliveryProofOfDelivery> proofs,
}) {
  final map = <String, List<BusinessDeliveryProofHistoryEvent>>{};
  for (final proof in proofs) {
    map[proof.proofId] = [
      BusinessDeliveryProofHistoryEvent(
        eventId: '${proof.proofId}-created',
        proofId: proof.proofId,
        deliveryTaskId: proof.deliveryTaskId,
        action: BusinessDeliveryProofHistoryAction.created,
        newStatus: BusinessDeliveryProofStatus.pending,
        recordedAt: proof.createdAt,
      ),
      if (proof.status != BusinessDeliveryProofStatus.pending)
        BusinessDeliveryProofHistoryEvent(
          eventId: '${proof.proofId}-status',
          proofId: proof.proofId,
          deliveryTaskId: proof.deliveryTaskId,
          action: BusinessDeliveryProofHistoryAction.statusChanged,
          previousStatus: BusinessDeliveryProofStatus.pending,
          newStatus: proof.status,
          recordedAt: proof.verifiedAt ?? proof.updatedAt,
          reason: proof.demoVerificationReason,
        ),
    ];
  }
  return map;
}
