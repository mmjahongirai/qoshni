import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';

/// Demo UI caps — not server authorization policy.
Set<BusinessBranchPermission> suggestedPermissionsForRole(
  BusinessStaffRole role,
) {
  switch (role) {
    case BusinessStaffRole.businessOwner:
      return allBusinessBranchPermissions.toSet();
    case BusinessStaffRole.businessAdmin:
      return allBusinessBranchPermissions.toSet();
    case BusinessStaffRole.branchManager:
      return {
        BusinessBranchPermission.viewBranch,
        BusinessBranchPermission.editBranchProfile,
        BusinessBranchPermission.manageBranchHours,
        BusinessBranchPermission.viewStaff,
        BusinessBranchPermission.manageBranchStaff,
        BusinessBranchPermission.viewBusinessProfile,
      };
    case BusinessStaffRole.staff:
      return {
        BusinessBranchPermission.viewBranch,
        BusinessBranchPermission.viewStaff,
      };
    case BusinessStaffRole.readOnly:
      return {
        BusinessBranchPermission.viewBranch,
        BusinessBranchPermission.viewStaff,
        BusinessBranchPermission.viewBusinessProfile,
      };
  }
}

Set<BusinessBranchPermission> assignablePermissionsForRole(
  BusinessStaffRole role,
) {
  if (role == BusinessStaffRole.readOnly) {
    return suggestedPermissionsForRole(role);
  }
  if (role == BusinessStaffRole.staff) {
    return {
      BusinessBranchPermission.viewBranch,
      BusinessBranchPermission.viewStaff,
      BusinessBranchPermission.viewBusinessProfile,
    };
  }
  if (role == BusinessStaffRole.branchManager) {
    return suggestedPermissionsForRole(role);
  }
  if (role == BusinessStaffRole.businessAdmin) {
    return allBusinessBranchPermissions.toSet();
  }
  return {};
}

bool canEditBranchPermissions(BusinessStaffRole role) {
  return role != BusinessStaffRole.businessOwner;
}

Set<BusinessBranchPermission> sanitizePermissionsForRole(
  BusinessStaffRole role,
  Set<BusinessBranchPermission> requested,
) {
  final allowed = assignablePermissionsForRole(role);
  return requested.intersection(allowed);
}
