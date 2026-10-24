import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_role.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_role_status.dart';

String qoshniPlatformAdminStatusLabel(
  AppLocalizations l10n,
  QoshniPlatformAdminStatus status,
) {
  return switch (status) {
    QoshniPlatformAdminStatus.active => l10n.platformAdminStatusActive,
    QoshniPlatformAdminStatus.suspended => l10n.platformAdminStatusSuspended,
  };
}

String qoshniPlatformRoleStatusLabel(
  AppLocalizations l10n,
  QoshniPlatformRoleStatus status,
) {
  return switch (status) {
    QoshniPlatformRoleStatus.enabled => l10n.platformRoleStatusEnabled,
    QoshniPlatformRoleStatus.disabled => l10n.platformRoleStatusDisabled,
  };
}

String qoshniPlatformRoleDisplayName(
  AppLocalizations l10n,
  QoshniPlatformAdminRole role,
) {
  return switch (role.displayNameKey) {
    'platformRoleViewerName' => l10n.platformRoleViewerName,
    'platformRoleVerificationReviewerName' =>
      l10n.platformRoleVerificationReviewerName,
    'platformRoleModeratorName' => l10n.platformRoleModeratorName,
    'platformRoleSupportAgentName' => l10n.platformRoleSupportAgentName,
    'platformRoleOperationsAdminName' => l10n.platformRoleOperationsAdminName,
    'platformRoleDisabledAuditName' => l10n.platformRoleDisabledAuditName,
    'platformRoleGovernanceApproverName' =>
      l10n.platformRoleGovernanceApproverName,
    _ => role.displayNameKey,
  };
}

String qoshniPlatformRolePurpose(
  AppLocalizations l10n,
  QoshniPlatformAdminRole role,
) {
  return switch (role.purposeKey) {
    'platformRoleViewerPurpose' => l10n.platformRoleViewerPurpose,
    'platformRoleVerificationReviewerPurpose' =>
      l10n.platformRoleVerificationReviewerPurpose,
    'platformRoleModeratorPurpose' => l10n.platformRoleModeratorPurpose,
    'platformRoleSupportAgentPurpose' => l10n.platformRoleSupportAgentPurpose,
    'platformRoleOperationsAdminPurpose' =>
      l10n.platformRoleOperationsAdminPurpose,
    'platformRoleDisabledAuditPurpose' => l10n.platformRoleDisabledAuditPurpose,
    'platformRoleGovernanceApproverPurpose' =>
      l10n.platformRoleGovernanceApproverPurpose,
    _ => role.purposeKey,
  };
}

String qoshniPlatformPermissionLabel(
  AppLocalizations l10n,
  QoshniPlatformPermission permission,
) {
  return switch (permission) {
    QoshniPlatformPermission.viewPlatformAdminDashboard =>
      l10n.platformPermissionViewDashboard,
    QoshniPlatformPermission.viewBusinessVerificationQueue =>
      l10n.platformPermissionViewVerificationQueue,
    QoshniPlatformPermission.reviewBusinessVerificationSubmissions =>
      l10n.platformPermissionReviewVerification,
    QoshniPlatformPermission.viewModerationQueue =>
      l10n.platformPermissionViewModerationQueue,
    QoshniPlatformPermission.performPermittedModerationActions =>
      l10n.platformPermissionPerformModeration,
    QoshniPlatformPermission.viewSupportCases =>
      l10n.platformPermissionViewSupportCases,
    QoshniPlatformPermission.respondToSupportCases =>
      l10n.platformPermissionRespondSupportCases,
    QoshniPlatformPermission.viewPlatformConfiguration =>
      l10n.platformPermissionViewConfiguration,
    QoshniPlatformPermission.manageLowRiskPlatformConfiguration =>
      l10n.platformPermissionManageLowRiskConfiguration,
    QoshniPlatformPermission.viewAuditRecords =>
      l10n.platformPermissionViewAuditRecords,
    QoshniPlatformPermission.submitHighRiskAdministrativeProposal =>
      l10n.platformPermissionSubmitApprovalProposal,
    QoshniPlatformPermission.decideHighRiskAdministrativeProposal =>
      l10n.platformPermissionDecideApprovalProposal,
  };
}

String qoshniPlatformAuthorizationReasonLabel(
  AppLocalizations l10n,
  QoshniPlatformAuthorizationReason reason,
) {
  return switch (reason) {
    QoshniPlatformAuthorizationReason.allowedExplicitGrant =>
      l10n.platformAuthReasonAllowedExplicitGrant,
    QoshniPlatformAuthorizationReason.deniedInvalidInput =>
      l10n.platformAuthReasonDeniedInvalidInput,
    QoshniPlatformAuthorizationReason.deniedAdminSuspended =>
      l10n.platformAuthReasonDeniedAdminSuspended,
    QoshniPlatformAuthorizationReason.deniedAdminNotFound =>
      l10n.platformAuthReasonDeniedAdminNotFound,
    QoshniPlatformAuthorizationReason.deniedNoEnabledRoles =>
      l10n.platformAuthReasonDeniedNoEnabledRoles,
    QoshniPlatformAuthorizationReason.deniedRoleDisabled =>
      l10n.platformAuthReasonDeniedRoleDisabled,
    QoshniPlatformAuthorizationReason.deniedPermissionNotGranted =>
      l10n.platformAuthReasonDeniedPermissionNotGranted,
    QoshniPlatformAuthorizationReason.deniedScopePlatformWideRequired =>
      l10n.platformAuthReasonDeniedScopePlatformWideRequired,
    QoshniPlatformAuthorizationReason.deniedScopeBusinessReferenceRequired =>
      l10n.platformAuthReasonDeniedScopeBusinessReferenceRequired,
    QoshniPlatformAuthorizationReason.deniedScopeBranchReferenceRequired =>
      l10n.platformAuthReasonDeniedScopeBranchReferenceRequired,
    QoshniPlatformAuthorizationReason.deniedCrossBusinessAccess =>
      l10n.platformAuthReasonDeniedCrossBusinessAccess,
    QoshniPlatformAuthorizationReason.deniedCrossBranchAccess =>
      l10n.platformAuthReasonDeniedCrossBranchAccess,
    QoshniPlatformAuthorizationReason.deniedBusinessAssignmentRequired =>
      l10n.platformAuthReasonDeniedBusinessAssignmentRequired,
    QoshniPlatformAuthorizationReason.deniedBranchAssignmentRequired =>
      l10n.platformAuthReasonDeniedBranchAssignmentRequired,
  };
}
