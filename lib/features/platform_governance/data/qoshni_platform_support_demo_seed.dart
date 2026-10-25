import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';

final DateTime kDemoPlatformSupportEpoch = DateTime.utc(2025, 5, 2, 12, 0);

List<QoshniPlatformSupportCase> buildQoshniPlatformSupportDemoSeed() {
  final epoch = kDemoPlatformSupportEpoch;
  return [
    QoshniPlatformSupportCase(
      caseId: 'sup-demo-001',
      syntheticRequesterReference: 'demo-customer-001',
      businessReference: kDemoPlatformGovernanceBusinessA,
      branchReference: kDemoPlatformGovernanceBranchA1,
      category: QoshniPlatformSupportCaseCategory.orderIssue,
      priority: QoshniPlatformSupportCasePriority.normal,
      status: QoshniPlatformSupportCaseStatus.open,
      safeSummary: 'Synthetic order delay question — demo case, no messaging sent.',
      createdAt: epoch,
      updatedAt: epoch,
      history: const [],
      internalNotes: const [],
    ),
    QoshniPlatformSupportCase(
      caseId: 'sup-demo-002',
      syntheticRequesterReference: 'demo-customer-002',
      category: QoshniPlatformSupportCaseCategory.policyQuestion,
      priority: QoshniPlatformSupportCasePriority.low,
      status: QoshniPlatformSupportCaseStatus.assigned,
      assignedRoleKey: 'support_agent',
      safeSummary: 'Demo policy FAQ case for support workflow preview.',
      createdAt: epoch.add(const Duration(hours: 1)),
      updatedAt: epoch.add(const Duration(hours: 2)),
      history: const [],
      internalNotes: const [],
    ),
  ];
}
