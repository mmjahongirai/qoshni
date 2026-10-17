import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';

void main() {
  test('permission wire ids match backend contract names', () {
    expect(BusinessBranchPermission.viewBranch.wireId, 'view_branch');
    expect(
      BusinessBranchPermission.manageBranchStaff.wireId,
      'manage_branch_staff',
    );
  });
}
