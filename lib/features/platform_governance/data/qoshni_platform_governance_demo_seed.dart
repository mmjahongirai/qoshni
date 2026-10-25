import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_identity.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_role.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_role_status.dart';

const String kDemoPlatformGovernanceBusinessA = 'demo-business-001';
const String kDemoPlatformGovernanceBusinessB = 'demo-business-002';
const String kDemoPlatformGovernanceBranchA1 = 'demo-branch-001';
const String kDemoPlatformGovernanceBranchB1 = 'demo-branch-002';

final DateTime kDemoPlatformGovernanceEpoch = DateTime.utc(2025, 5, 1, 9, 0);

List<QoshniPlatformAdminRole> buildQoshniPlatformAdminRoleDemoSeed() {
  final epoch = kDemoPlatformGovernanceEpoch;
  return [
    QoshniPlatformAdminRole(
      roleId: 'role-platform-viewer',
      roleKey: 'platform_viewer',
      displayNameKey: 'platformRoleViewerName',
      purposeKey: 'platformRoleViewerPurpose',
      permissionIds: [
        QoshniPlatformPermission.viewPlatformAdminDashboard.permissionId,
        QoshniPlatformPermission.viewAuditRecords.permissionId,
      ],
      status: QoshniPlatformRoleStatus.enabled,
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminRole(
      roleId: 'role-business-verification-reviewer',
      roleKey: 'business_verification_reviewer',
      displayNameKey: 'platformRoleVerificationReviewerName',
      purposeKey: 'platformRoleVerificationReviewerPurpose',
      permissionIds: [
        QoshniPlatformPermission.viewBusinessVerificationQueue.permissionId,
        QoshniPlatformPermission.reviewBusinessVerificationSubmissions
            .permissionId,
      ],
      status: QoshniPlatformRoleStatus.enabled,
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminRole(
      roleId: 'role-content-moderator',
      roleKey: 'content_moderator',
      displayNameKey: 'platformRoleModeratorName',
      purposeKey: 'platformRoleModeratorPurpose',
      permissionIds: [
        QoshniPlatformPermission.viewModerationQueue.permissionId,
        QoshniPlatformPermission.performPermittedModerationActions.permissionId,
      ],
      status: QoshniPlatformRoleStatus.enabled,
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminRole(
      roleId: 'role-support-agent',
      roleKey: 'support_agent',
      displayNameKey: 'platformRoleSupportAgentName',
      purposeKey: 'platformRoleSupportAgentPurpose',
      permissionIds: [
        QoshniPlatformPermission.viewSupportCases.permissionId,
        QoshniPlatformPermission.respondToSupportCases.permissionId,
      ],
      status: QoshniPlatformRoleStatus.enabled,
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminRole(
      roleId: 'role-platform-operations-admin',
      roleKey: 'platform_operations_admin',
      displayNameKey: 'platformRoleOperationsAdminName',
      purposeKey: 'platformRoleOperationsAdminPurpose',
      permissionIds: [
        QoshniPlatformPermission.viewPlatformAdminDashboard.permissionId,
        QoshniPlatformPermission.viewPlatformConfiguration.permissionId,
        QoshniPlatformPermission.manageLowRiskPlatformConfiguration
            .permissionId,
        QoshniPlatformPermission.viewAuditRecords.permissionId,
        QoshniPlatformPermission.submitHighRiskAdministrativeProposal
            .permissionId,
      ],
      status: QoshniPlatformRoleStatus.enabled,
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminRole(
      roleId: 'role-governance-approver',
      roleKey: 'governance_approver',
      displayNameKey: 'platformRoleGovernanceApproverName',
      purposeKey: 'platformRoleGovernanceApproverPurpose',
      permissionIds: [
        QoshniPlatformPermission.decideHighRiskAdministrativeProposal
            .permissionId,
      ],
      status: QoshniPlatformRoleStatus.enabled,
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminRole(
      roleId: 'role-disabled-audit',
      roleKey: 'disabled_audit',
      displayNameKey: 'platformRoleDisabledAuditName',
      purposeKey: 'platformRoleDisabledAuditPurpose',
      permissionIds: [
        QoshniPlatformPermission.viewAuditRecords.permissionId,
      ],
      status: QoshniPlatformRoleStatus.disabled,
      createdAt: epoch,
      updatedAt: epoch,
    ),
  ];
}

List<QoshniPlatformAdminIdentity> buildQoshniPlatformAdminIdentityDemoSeed() {
  final epoch = kDemoPlatformGovernanceEpoch;
  return [
    QoshniPlatformAdminIdentity(
      adminId: 'admin-demo-viewer',
      syntheticReference: 'demo-platform-admin-viewer',
      displayLabel: 'Demo Platform Viewer',
      status: QoshniPlatformAdminStatus.active,
      roleIds: ['role-platform-viewer'],
      assignedBusinessReferences: const [],
      assignedBranchReferences: const [],
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminIdentity(
      adminId: 'admin-demo-verifier',
      syntheticReference: 'demo-platform-admin-verifier',
      displayLabel: 'Demo Verification Reviewer',
      status: QoshniPlatformAdminStatus.active,
      roleIds: ['role-business-verification-reviewer'],
      assignedBusinessReferences: [kDemoPlatformGovernanceBusinessA],
      assignedBranchReferences: const [],
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminIdentity(
      adminId: 'admin-demo-moderator',
      syntheticReference: 'demo-platform-admin-moderator',
      displayLabel: 'Demo Content Moderator',
      status: QoshniPlatformAdminStatus.active,
      roleIds: ['role-content-moderator'],
      assignedBusinessReferences: const [],
      assignedBranchReferences: const [],
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminIdentity(
      adminId: 'admin-demo-support',
      syntheticReference: 'demo-platform-admin-support',
      displayLabel: 'Demo Support Agent',
      status: QoshniPlatformAdminStatus.active,
      roleIds: ['role-support-agent'],
      assignedBusinessReferences: [kDemoPlatformGovernanceBusinessA],
      assignedBranchReferences: [kDemoPlatformGovernanceBranchA1],
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminIdentity(
      adminId: 'admin-demo-operations',
      syntheticReference: 'demo-platform-admin-operations',
      displayLabel: 'Demo Operations Admin',
      status: QoshniPlatformAdminStatus.active,
      roleIds: ['role-platform-operations-admin'],
      assignedBusinessReferences: const [],
      assignedBranchReferences: const [],
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminIdentity(
      adminId: 'admin-demo-suspended',
      syntheticReference: 'demo-platform-admin-suspended',
      displayLabel: 'Demo Suspended Admin',
      status: QoshniPlatformAdminStatus.suspended,
      roleIds: ['role-platform-operations-admin'],
      assignedBusinessReferences: const [],
      assignedBranchReferences: const [],
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminIdentity(
      adminId: 'admin-demo-disabled-role',
      syntheticReference: 'demo-platform-admin-disabled-role',
      displayLabel: 'Demo Admin With Disabled Role',
      status: QoshniPlatformAdminStatus.active,
      roleIds: ['role-disabled-audit'],
      assignedBusinessReferences: const [],
      assignedBranchReferences: const [],
      createdAt: epoch,
      updatedAt: epoch,
    ),
    QoshniPlatformAdminIdentity(
      adminId: 'admin-demo-approver',
      syntheticReference: 'demo-platform-admin-approver',
      displayLabel: 'Demo Governance Approver',
      status: QoshniPlatformAdminStatus.active,
      roleIds: ['role-governance-approver'],
      assignedBusinessReferences: const [],
      assignedBranchReferences: const [],
      createdAt: epoch,
      updatedAt: epoch,
    ),
  ];
}
