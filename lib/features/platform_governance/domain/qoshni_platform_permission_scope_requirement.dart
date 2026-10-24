import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';

/// How a permission may be exercised relative to resource scope.
enum QoshniPlatformPermissionScopeRequirement {
  /// Must use explicit platform-wide scope (never inferred from empty scope).
  platformWideOnly,

  /// May use platform-wide scope or a matching assigned business scope.
  platformOrAssignedBusiness,

  /// May use platform-wide, assigned business, or matching branch scope.
  platformOrAssignedBusinessOrBranch,
}

QoshniPlatformPermissionScopeRequirement
    qoshniPlatformPermissionScopeRequirement(
  QoshniPlatformPermission permission,
) {
  return switch (permission) {
    QoshniPlatformPermission.viewPlatformAdminDashboard ||
    QoshniPlatformPermission.viewBusinessVerificationQueue ||
    QoshniPlatformPermission.viewModerationQueue ||
    QoshniPlatformPermission.viewPlatformConfiguration ||
    QoshniPlatformPermission.manageLowRiskPlatformConfiguration ||
    QoshniPlatformPermission.viewAuditRecords ||
    QoshniPlatformPermission.submitHighRiskAdministrativeProposal ||
    QoshniPlatformPermission.decideHighRiskAdministrativeProposal =>
      QoshniPlatformPermissionScopeRequirement.platformWideOnly,
    QoshniPlatformPermission.reviewBusinessVerificationSubmissions ||
    QoshniPlatformPermission.performPermittedModerationActions ||
    QoshniPlatformPermission.viewSupportCases =>
      QoshniPlatformPermissionScopeRequirement.platformOrAssignedBusiness,
    QoshniPlatformPermission.respondToSupportCases =>
      QoshniPlatformPermissionScopeRequirement
          .platformOrAssignedBusinessOrBranch,
  };
}
