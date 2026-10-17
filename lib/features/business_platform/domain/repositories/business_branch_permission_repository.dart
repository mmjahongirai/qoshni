import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';

enum BusinessBranchPermissionSaveResult {
  success,
  notFound,
  invalidScope,
  notEditable,
  failure,
}

abstract class BusinessBranchPermissionRepository {
  String get businessScopeId;

  Set<BusinessBranchPermission> permissionsFor(
    String staffId,
    String branchId,
  );

  bool isStaffAssignedToBranch(String staffId, String branchId);

  BusinessBranchPermissionSaveResult savePermissions(
    String staffId,
    String branchId,
    Set<BusinessBranchPermission> permissions,
  );
}
