import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';

enum BusinessBranchPermissionDataSource {
  demoSeed,
  userSession,
}

/// Staff access to a branch within a business scope (preview assignments).
class BusinessBranchPermissionAssignment {
  const BusinessBranchPermissionAssignment({
    required this.staffId,
    required this.branchId,
    required this.businessScopeId,
    required this.permissions,
    required this.dataSource,
    required this.updatedAt,
  });

  final String staffId;
  final String branchId;
  final String businessScopeId;
  final Set<BusinessBranchPermission> permissions;
  final BusinessBranchPermissionDataSource dataSource;
  final DateTime updatedAt;

  bool get isDemoSeed =>
      dataSource == BusinessBranchPermissionDataSource.demoSeed;

  bool get hasAccess => permissions.isNotEmpty;
}
