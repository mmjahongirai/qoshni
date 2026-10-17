import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';

String branchPermissionLabel(
  AppLocalizations l10n,
  BusinessBranchPermission permission,
) {
  switch (permission) {
    case BusinessBranchPermission.viewBranch:
      return l10n.branchPermViewBranch;
    case BusinessBranchPermission.editBranchProfile:
      return l10n.branchPermEditBranchProfile;
    case BusinessBranchPermission.manageBranchHours:
      return l10n.branchPermManageBranchHours;
    case BusinessBranchPermission.viewStaff:
      return l10n.branchPermViewStaff;
    case BusinessBranchPermission.manageBranchStaff:
      return l10n.branchPermManageBranchStaff;
    case BusinessBranchPermission.viewBusinessProfile:
      return l10n.branchPermViewBusinessProfile;
  }
}

String branchPermissionGroupLabel(
  AppLocalizations l10n,
  BusinessBranchPermissionGroup group,
) {
  switch (group) {
    case BusinessBranchPermissionGroup.view:
      return l10n.branchPermGroupView;
    case BusinessBranchPermissionGroup.edit:
      return l10n.branchPermGroupEdit;
    case BusinessBranchPermissionGroup.staffManagement:
      return l10n.branchPermGroupStaff;
  }
}

String branchPermissionDescription(
  AppLocalizations l10n,
  BusinessBranchPermission permission,
) {
  switch (permission) {
    case BusinessBranchPermission.viewBranch:
      return l10n.branchPermDescViewBranch;
    case BusinessBranchPermission.editBranchProfile:
      return l10n.branchPermDescEditBranchProfile;
    case BusinessBranchPermission.manageBranchHours:
      return l10n.branchPermDescManageBranchHours;
    case BusinessBranchPermission.viewStaff:
      return l10n.branchPermDescViewStaff;
    case BusinessBranchPermission.manageBranchStaff:
      return l10n.branchPermDescManageBranchStaff;
    case BusinessBranchPermission.viewBusinessProfile:
      return l10n.branchPermDescViewBusinessProfile;
  }
}
