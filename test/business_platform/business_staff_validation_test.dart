import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_validation.dart';

void main() {
  test('valid staff input passes', () {
    const input = BusinessStaffMemberInput(
      firstName: 'Ali',
      lastName: 'Valiyev',
      contactPhone: '+998901234567',
      role: BusinessStaffRole.staff,
      assignedBranchIds: ['demo-branch-tashkent-center'],
      isActive: true,
    );

    final result = validateBusinessStaffInput(
      input,
      firstNameRequired: () => 'name',
      phoneInvalid: () => 'phone',
      emailInvalid: () => 'email',
      roleNotAssignable: () => 'role',
      branchRequired: () => 'branch',
    );

    expect(result.isValid, isTrue);
  });

  test('business owner role is not assignable', () {
    const input = BusinessStaffMemberInput(
      firstName: 'X',
      lastName: '',
      contactPhone: '+998901234567',
      role: BusinessStaffRole.businessOwner,
      assignedBranchIds: ['demo-branch-tashkent-center'],
      isActive: true,
    );

    final result = validateBusinessStaffInput(
      input,
      firstNameRequired: () => 'name',
      phoneInvalid: () => 'phone',
      emailInvalid: () => 'email',
      roleNotAssignable: () => 'role',
      branchRequired: () => 'branch',
    );

    expect(result.isValid, isFalse);
    expect(result.roleError, isNotNull);
  });

  test('missing branch fails validation', () {
    const input = BusinessStaffMemberInput(
      firstName: 'X',
      lastName: '',
      contactPhone: '+998901234567',
      role: BusinessStaffRole.readOnly,
      assignedBranchIds: [],
      isActive: true,
    );

    final result = validateBusinessStaffInput(
      input,
      firstNameRequired: () => 'name',
      phoneInvalid: () => 'phone',
      emailInvalid: () => 'email',
      roleNotAssignable: () => 'role',
      branchRequired: () => 'branch',
    );

    expect(result.branchError, isNotNull);
  });
}
