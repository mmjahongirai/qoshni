import 'package:qoshni/features/business_platform/domain/business_branch_access.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_permission_policy.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';

String branchPermissionKey(String staffId, String branchId) =>
    '$staffId|$branchId';

Map<String, Set<BusinessBranchPermission>> buildDemoBranchPermissionMap({
  required String businessScopeId,
}) {
  void seed(
    Map<String, Set<BusinessBranchPermission>> map,
    String staffId,
    String branchId,
    BusinessStaffRole role,
  ) {
    map[branchPermissionKey(staffId, branchId)] =
        suggestedPermissionsForRole(role);
  }

  final map = <String, Set<BusinessBranchPermission>>{};
  seed(
    map,
    'demo-staff-owner-preview',
    'demo-branch-tashkent-center',
    BusinessStaffRole.businessOwner,
  );
  seed(
    map,
    'demo-staff-owner-preview',
    'demo-branch-samarkand',
    BusinessStaffRole.businessOwner,
  );
  seed(
    map,
    'demo-staff-branch-manager',
    'demo-branch-tashkent-center',
    BusinessStaffRole.branchManager,
  );
  seed(
    map,
    'demo-staff-invite-pending',
    'demo-branch-samarkand',
    BusinessStaffRole.staff,
  );
  return map;
}

BusinessBranchPermissionAssignment assignmentFromEntry({
  required String staffId,
  required String branchId,
  required String businessScopeId,
  required Set<BusinessBranchPermission> permissions,
  required DateTime updatedAt,
}) {
  return BusinessBranchPermissionAssignment(
    staffId: staffId,
    branchId: branchId,
    businessScopeId: businessScopeId,
    permissions: permissions,
    dataSource: BusinessBranchPermissionDataSource.demoSeed,
    updatedAt: updatedAt,
  );
}
