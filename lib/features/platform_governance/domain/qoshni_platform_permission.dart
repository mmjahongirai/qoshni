/// Typed platform-admin permission identifiers (Phase 15 catalog).
///
/// Deliberately excludes financial adjustments, wallet access, secret/private-AI
/// content, and unrestricted user-data access — those require later phases and
/// backend enforcement.
enum QoshniPlatformPermission {
  viewPlatformAdminDashboard,
  viewBusinessVerificationQueue,
  reviewBusinessVerificationSubmissions,
  viewModerationQueue,
  performPermittedModerationActions,
  viewSupportCases,
  respondToSupportCases,
  viewPlatformConfiguration,
  manageLowRiskPlatformConfiguration,
  viewAuditRecords,
  submitHighRiskAdministrativeProposal,
  decideHighRiskAdministrativeProposal,
}

extension QoshniPlatformPermissionStableId on QoshniPlatformPermission {
  String get permissionId => switch (this) {
        QoshniPlatformPermission.viewPlatformAdminDashboard =>
          'platform.admin.dashboard.view',
        QoshniPlatformPermission.viewBusinessVerificationQueue =>
          'platform.admin.business_verification.queue.view',
        QoshniPlatformPermission.reviewBusinessVerificationSubmissions =>
          'platform.admin.business_verification.review',
        QoshniPlatformPermission.viewModerationQueue =>
          'platform.admin.moderation.queue.view',
        QoshniPlatformPermission.performPermittedModerationActions =>
          'platform.admin.moderation.action.perform',
        QoshniPlatformPermission.viewSupportCases =>
          'platform.admin.support.cases.view',
        QoshniPlatformPermission.respondToSupportCases =>
          'platform.admin.support.cases.respond',
        QoshniPlatformPermission.viewPlatformConfiguration =>
          'platform.admin.configuration.view',
        QoshniPlatformPermission.manageLowRiskPlatformConfiguration =>
          'platform.admin.configuration.manage_low_risk',
        QoshniPlatformPermission.viewAuditRecords =>
          'platform.admin.audit.records.view',
        QoshniPlatformPermission.submitHighRiskAdministrativeProposal =>
          'platform.admin.approval.proposal.submit',
        QoshniPlatformPermission.decideHighRiskAdministrativeProposal =>
          'platform.admin.approval.proposal.decide',
      };
}

QoshniPlatformPermission? qoshniPlatformPermissionFromId(String id) {
  final normalized = id.trim();
  for (final value in QoshniPlatformPermission.values) {
    if (value.permissionId == normalized) {
      return value;
    }
  }
  return null;
}
