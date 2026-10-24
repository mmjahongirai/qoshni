import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_target_type.dart';

final DateTime kDemoPlatformModerationEpoch = DateTime.utc(2025, 5, 2, 11, 0);

List<QoshniPlatformModerationCase> buildQoshniPlatformModerationDemoSeed() {
  final epoch = kDemoPlatformModerationEpoch;
  return [
    QoshniPlatformModerationCase(
      caseId: 'mod-demo-001',
      targetType: QoshniPlatformModerationTargetType.complaint,
      syntheticTargetReference: 'demo-complaint-submitted-001',
      businessReference: kDemoPlatformGovernanceBusinessA,
      reasonCategoryKey: 'policy_review',
      priority: QoshniPlatformModerationPriority.normal,
      syntheticSourceReference: 'demo-report-001',
      safeSummary:
          'Synthetic complaint reference — safe summary only; no customer PII.',
      status: QoshniPlatformModerationCaseStatus.pending,
      createdAt: epoch,
      updatedAt: epoch,
      history: const [],
    ),
    QoshniPlatformModerationCase(
      caseId: 'mod-demo-002',
      targetType: QoshniPlatformModerationTargetType.review,
      syntheticTargetReference: 'demo-review-product-001',
      businessReference: kDemoPlatformGovernanceBusinessB,
      reasonCategoryKey: 'content_quality',
      priority: QoshniPlatformModerationPriority.high,
      syntheticSourceReference: 'demo-report-002',
      safeSummary: 'Demo product review flag for moderation queue training.',
      status: QoshniPlatformModerationCaseStatus.underReview,
      createdAt: epoch.add(const Duration(hours: 1)),
      updatedAt: epoch.add(const Duration(hours: 2)),
      history: const [],
    ),
  ];
}
