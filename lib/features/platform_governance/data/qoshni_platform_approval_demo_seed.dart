import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_proposal_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';

List<QoshniPlatformApprovalRequest> buildQoshniPlatformApprovalDemoSeed() {
  final epoch = kDemoPlatformGovernanceEpoch.add(const Duration(hours: 2));
  return [
    QoshniPlatformApprovalRequest(
      requestId: 'approval-demo-seed-001',
      proposalType:
          QoshniPlatformApprovalProposalType.hypotheticalWalletAdjustment,
      status: QoshniPlatformApprovalRequestStatus.pending,
      requesterAdminReference: 'demo-platform-admin-operations',
      targetReference: 'demo-wallet-ledger-synthetic-001',
      requiredPermission:
          QoshniPlatformPermission.decideHighRiskAdministrativeProposal,
      reasonCode: 'seed_demo_pending',
      createdAt: epoch,
      updatedAt: epoch,
      isSeedRecord: true,
    ),
  ];
}
