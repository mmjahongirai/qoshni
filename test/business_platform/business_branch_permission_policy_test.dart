import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_permission_policy.dart';

void main() {
  test('read-only role cannot be assigned edit permissions', () {
    final sanitized = sanitizePermissionsForRole(
      BusinessStaffRole.readOnly,
      allBusinessBranchPermissions.toSet(),
    );
    expect(sanitized, contains(BusinessBranchPermission.viewBranch));
    expect(sanitized, isNot(contains(BusinessBranchPermission.editBranchProfile)));
    expect(sanitized, isNot(contains(BusinessBranchPermission.manageBranchStaff)));
  });

  test('business owner permissions not editable via policy', () {
    expect(canEditBranchPermissions(BusinessStaffRole.businessOwner), isFalse);
    expect(canEditBranchPermissions(BusinessStaffRole.staff), isTrue);
  });
}
