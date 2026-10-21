import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/review_transaction_evidence.dart';

const String kDemoReviewTxEvidenceBreadCompleted =
    'demo-tx-evidence-bread-completed';
const String kDemoReviewTxEvidencePackingCompleted =
    'demo-tx-evidence-packing-completed';
const String kDemoReviewTxEvidenceBusinessCompleted =
    'demo-tx-evidence-business-completed';
const String kDemoReviewTxEvidenceIncomplete =
    'demo-tx-evidence-incomplete-pending';
const String kDemoReviewTxEvidenceWrongBranch =
    'demo-tx-evidence-wrong-branch';
const String kDemoReviewTxEvidenceDuplicateTaken =
    'demo-tx-evidence-duplicate-taken';
const String kDemoReviewTxEvidenceSessionCreate =
    'demo-tx-evidence-session-create-only';

const String kDemoReviewReviewerA = 'demo-reviewer-ref-a';
const String kDemoReviewReviewerB = 'demo-reviewer-ref-b';
const String kDemoReviewReviewerC = 'demo-reviewer-ref-c';

List<ReviewTransactionEvidence> buildDemoReviewTransactionEvidenceCatalog({
  required String businessScopeId,
}) {
  return [
    ReviewTransactionEvidence(
      transactionEvidenceReference: kDemoReviewTxEvidenceBreadCompleted,
      isSynthetic: true,
      isCompleted: true,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductBreadId,
      demoReviewerReference: kDemoReviewReviewerA,
    ),
    ReviewTransactionEvidence(
      transactionEvidenceReference: kDemoReviewTxEvidencePackingCompleted,
      isSynthetic: true,
      isCompleted: true,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.service,
      targetId: kDemoCatalogServicePackingId,
      demoReviewerReference: kDemoReviewReviewerB,
    ),
    ReviewTransactionEvidence(
      transactionEvidenceReference: kDemoReviewTxEvidenceBusinessCompleted,
      isSynthetic: true,
      isCompleted: true,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      targetType: BusinessReviewTargetType.business,
      targetId: businessScopeId,
      demoReviewerReference: kDemoReviewReviewerC,
    ),
    ReviewTransactionEvidence(
      transactionEvidenceReference: kDemoReviewTxEvidenceIncomplete,
      isSynthetic: true,
      isCompleted: false,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductBreadId,
      demoReviewerReference: kDemoReviewReviewerA,
    ),
    ReviewTransactionEvidence(
      transactionEvidenceReference: kDemoReviewTxEvidenceWrongBranch,
      isSynthetic: true,
      isCompleted: true,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductBreadId,
      demoReviewerReference: kDemoReviewReviewerA,
    ),
    ReviewTransactionEvidence(
      transactionEvidenceReference: kDemoReviewTxEvidenceDuplicateTaken,
      isSynthetic: true,
      isCompleted: true,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductPlovId,
      demoReviewerReference: kDemoReviewReviewerB,
    ),
    ReviewTransactionEvidence(
      transactionEvidenceReference: 'demo-tx-evidence-plov-completed',
      isSynthetic: true,
      isCompleted: true,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductPlovId,
      demoReviewerReference: kDemoReviewReviewerB,
    ),
    ReviewTransactionEvidence(
      transactionEvidenceReference: 'demo-tx-evidence-basket-new',
      isSynthetic: true,
      isCompleted: true,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductDailyBasketId,
      demoReviewerReference: kDemoReviewReviewerC,
    ),
    ReviewTransactionEvidence(
      transactionEvidenceReference: kDemoReviewTxEvidenceSessionCreate,
      isSynthetic: true,
      isCompleted: true,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      targetType: BusinessReviewTargetType.product,
      targetId: kDemoCatalogProductBreadId,
      demoReviewerReference: kDemoReviewReviewerA,
    ),
  ];
}
