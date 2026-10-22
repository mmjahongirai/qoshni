import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_method.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_status.dart';

class BusinessDeliveryProofOfDelivery {
  const BusinessDeliveryProofOfDelivery({
    required this.proofId,
    required this.deliveryTaskId,
    required this.businessScopeId,
    required this.branchId,
    required this.method,
    required this.status,
    required this.demoEvidenceReference,
    required this.description,
    this.demoVerificationReason,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.dataSource,
  });

  final String proofId;
  final String deliveryTaskId;
  final String businessScopeId;
  final String branchId;
  final BusinessDeliveryProofMethod method;
  final BusinessDeliveryProofStatus status;
  /// Synthetic demo slot — not a real media URL, OTP value, or signature blob.
  final String demoEvidenceReference;
  final String description;
  final String? demoVerificationReason;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BusinessCatalogProductDataSource dataSource;

  BusinessDeliveryProofOfDelivery copyWith({
    BusinessDeliveryProofStatus? status,
    String? demoVerificationReason,
    bool clearDemoVerificationReason = false,
    DateTime? verifiedAt,
    bool clearVerifiedAt = false,
    DateTime? updatedAt,
  }) {
    return BusinessDeliveryProofOfDelivery(
      proofId: proofId,
      deliveryTaskId: deliveryTaskId,
      businessScopeId: businessScopeId,
      branchId: branchId,
      method: method,
      status: status ?? this.status,
      demoEvidenceReference: demoEvidenceReference,
      description: description,
      demoVerificationReason: clearDemoVerificationReason
          ? null
          : (demoVerificationReason ?? this.demoVerificationReason),
      verifiedAt: clearVerifiedAt ? null : (verifiedAt ?? this.verifiedAt),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dataSource: dataSource,
    );
  }
}

class BusinessDeliveryProofCreateInput {
  const BusinessDeliveryProofCreateInput({
    required this.deliveryTaskId,
    required this.method,
    required this.demoEvidenceReference,
    required this.description,
  });

  final String deliveryTaskId;
  final BusinessDeliveryProofMethod method;
  final String demoEvidenceReference;
  final String description;
}
