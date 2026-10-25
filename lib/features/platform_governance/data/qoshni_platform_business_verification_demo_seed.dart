import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';

final DateTime kDemoPlatformBusinessVerificationEpoch =
    DateTime.utc(2025, 5, 2, 10, 0);

List<QoshniPlatformBusinessVerificationSubmission>
    buildQoshniPlatformBusinessVerificationDemoSeed() {
  final epoch = kDemoPlatformBusinessVerificationEpoch;
  return [
    QoshniPlatformBusinessVerificationSubmission(
      submissionId: 'bver-demo-001',
      syntheticApplicationReference: 'demo-onboarding-app-001',
      businessReference: kDemoPlatformGovernanceBusinessA,
      branchReference: kDemoPlatformGovernanceBranchA1,
      documentCategoryKey: 'registration_certificate',
      safeSummary:
          'Synthetic registration packet for demo bakery — metadata only, no documents attached.',
      status: QoshniPlatformBusinessVerificationSubmissionStatus.pending,
      submittedAt: epoch,
      updatedAt: epoch,
      history: const [],
    ),
    QoshniPlatformBusinessVerificationSubmission(
      submissionId: 'bver-demo-002',
      syntheticApplicationReference: 'demo-onboarding-app-002',
      businessReference: kDemoPlatformGovernanceBusinessB,
      documentCategoryKey: 'tax_registration',
      safeSummary:
          'Demo tax identifier check — synthetic summary for queue review training.',
      status: QoshniPlatformBusinessVerificationSubmissionStatus.underReview,
      submittedAt: epoch.add(const Duration(hours: 2)),
      updatedAt: epoch.add(const Duration(hours: 3)),
      history: [
        QoshniPlatformGovernanceHistoryEntry(
          recordedAt: epoch.add(const Duration(hours: 3)),
          actorAdminReference: 'demo-platform-admin-verifier',
          operation: 'begin_review',
          fromStatus: 'pending',
          toStatus: 'under_review',
          reasonCode: 'queue_triage',
          note: 'Demo review started.',
        ),
      ],
    ),
  ];
}
