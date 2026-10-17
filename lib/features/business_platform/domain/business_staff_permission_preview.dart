import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';

class BusinessStaffPermissionPreview {
  const BusinessStaffPermissionPreview({
    required this.role,
    required this.summaryKey,
    required this.permissionKeys,
  });

  final BusinessStaffRole role;
  final String summaryKey;
  final List<String> permissionKeys;
}

/// Client-side permission hints for demo UI (not enforced server-side).
BusinessStaffPermissionPreview permissionPreviewForRole(
  BusinessStaffRole role,
) {
  switch (role) {
    case BusinessStaffRole.businessOwner:
      return const BusinessStaffPermissionPreview(
        role: BusinessStaffRole.businessOwner,
        summaryKey: 'staffPermSummaryOwner',
        permissionKeys: [
          'staffPermManageBusiness',
          'staffPermManageBranches',
          'staffPermManageStaff',
          'staffPermViewReports',
        ],
      );
    case BusinessStaffRole.businessAdmin:
      return const BusinessStaffPermissionPreview(
        role: BusinessStaffRole.businessAdmin,
        summaryKey: 'staffPermSummaryAdmin',
        permissionKeys: [
          'staffPermManageBranches',
          'staffPermManageStaff',
          'staffPermViewReports',
        ],
      );
    case BusinessStaffRole.branchManager:
      return const BusinessStaffPermissionPreview(
        role: BusinessStaffRole.branchManager,
        summaryKey: 'staffPermSummaryBranchManager',
        permissionKeys: [
          'staffPermManageAssignedBranches',
          'staffPermViewBranchReports',
        ],
      );
    case BusinessStaffRole.staff:
      return const BusinessStaffPermissionPreview(
        role: BusinessStaffRole.staff,
        summaryKey: 'staffPermSummaryStaff',
        permissionKeys: [
          'staffPermExecuteAssignedTasks',
          'staffPermViewAssignedBranch',
        ],
      );
    case BusinessStaffRole.readOnly:
      return const BusinessStaffPermissionPreview(
        role: BusinessStaffRole.readOnly,
        summaryKey: 'staffPermSummaryReadOnly',
        permissionKeys: [
          'staffPermViewBusinessPreview',
        ],
      );
  }
}
