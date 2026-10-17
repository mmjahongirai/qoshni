/// Branch-scoped permission identifiers (preview until backend enforcement).
enum BusinessBranchPermission {
  viewBranch,
  editBranchProfile,
  manageBranchHours,
  viewStaff,
  manageBranchStaff,
  viewBusinessProfile,
}

extension BusinessBranchPermissionWire on BusinessBranchPermission {
  String get wireId {
    switch (this) {
      case BusinessBranchPermission.viewBranch:
        return 'view_branch';
      case BusinessBranchPermission.editBranchProfile:
        return 'edit_branch_profile';
      case BusinessBranchPermission.manageBranchHours:
        return 'manage_branch_hours';
      case BusinessBranchPermission.viewStaff:
        return 'view_staff';
      case BusinessBranchPermission.manageBranchStaff:
        return 'manage_branch_staff';
      case BusinessBranchPermission.viewBusinessProfile:
        return 'view_business_profile';
    }
  }
}

enum BusinessBranchPermissionGroup {
  view,
  edit,
  staffManagement,
}

BusinessBranchPermissionGroup groupForPermission(
  BusinessBranchPermission permission,
) {
  switch (permission) {
    case BusinessBranchPermission.viewBranch:
    case BusinessBranchPermission.viewStaff:
    case BusinessBranchPermission.viewBusinessProfile:
      return BusinessBranchPermissionGroup.view;
    case BusinessBranchPermission.editBranchProfile:
    case BusinessBranchPermission.manageBranchHours:
      return BusinessBranchPermissionGroup.edit;
    case BusinessBranchPermission.manageBranchStaff:
      return BusinessBranchPermissionGroup.staffManagement;
  }
}

const allBusinessBranchPermissions = BusinessBranchPermission.values;
