import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_permission_preview.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_status.dart';

String staffRoleLabel(AppLocalizations l10n, BusinessStaffRole role) {
  switch (role) {
    case BusinessStaffRole.businessOwner:
      return l10n.staffRoleBusinessOwner;
    case BusinessStaffRole.businessAdmin:
      return l10n.staffRoleBusinessAdmin;
    case BusinessStaffRole.branchManager:
      return l10n.staffRoleBranchManager;
    case BusinessStaffRole.staff:
      return l10n.staffRoleStaff;
    case BusinessStaffRole.readOnly:
      return l10n.staffRoleReadOnly;
  }
}

String staffStatusLabel(
  AppLocalizations l10n,
  BusinessStaffMemberStatus status,
) {
  switch (status) {
    case BusinessStaffMemberStatus.activePreview:
      return l10n.staffStatusActivePreview;
    case BusinessStaffMemberStatus.invitePendingPreview:
      return l10n.staffStatusInvitePendingPreview;
    case BusinessStaffMemberStatus.removedPreview:
      return l10n.staffStatusRemovedPreview;
  }
}

String permissionSummary(AppLocalizations l10n, BusinessStaffRole role) {
  switch (role) {
    case BusinessStaffRole.businessOwner:
      return l10n.staffPermSummaryOwner;
    case BusinessStaffRole.businessAdmin:
      return l10n.staffPermSummaryAdmin;
    case BusinessStaffRole.branchManager:
      return l10n.staffPermSummaryBranchManager;
    case BusinessStaffRole.staff:
      return l10n.staffPermSummaryStaff;
    case BusinessStaffRole.readOnly:
      return l10n.staffPermSummaryReadOnly;
  }
}

List<String> permissionBulletLabels(
  AppLocalizations l10n,
  BusinessStaffRole role,
) {
  final preview = permissionPreviewForRole(role);
  return preview.permissionKeys.map((key) {
    switch (key) {
      case 'staffPermManageBusiness':
        return l10n.staffPermManageBusiness;
      case 'staffPermManageBranches':
        return l10n.staffPermManageBranches;
      case 'staffPermManageStaff':
        return l10n.staffPermManageStaff;
      case 'staffPermViewReports':
        return l10n.staffPermViewReports;
      case 'staffPermManageAssignedBranches':
        return l10n.staffPermManageAssignedBranches;
      case 'staffPermViewBranchReports':
        return l10n.staffPermViewBranchReports;
      case 'staffPermExecuteAssignedTasks':
        return l10n.staffPermExecuteAssignedTasks;
      case 'staffPermViewAssignedBranch':
        return l10n.staffPermViewAssignedBranch;
      case 'staffPermViewBusinessPreview':
        return l10n.staffPermViewBusinessPreview;
      default:
        return key;
    }
  }).toList();
}
