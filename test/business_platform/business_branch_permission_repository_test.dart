import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_permission_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_staff_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_permission_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessStaffRepository staffRepo;
  late InMemoryBusinessBranchPermissionRepository permRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    branchRepo = InMemoryBusinessBranchRepository(ownerRepo);
    staffRepo = InMemoryBusinessStaffRepository(ownerRepo, branchRepo);
    permRepo = InMemoryBusinessBranchPermissionRepository(staffRepo, branchRepo);
    ownerRepo.ensureSessionProfile();
    branchRepo.listForCurrentScope();
    staffRepo.listForCurrentScope();
  });

  test('assigned branch has demo permissions', () {
    final perms = permRepo.permissionsFor(
      'demo-staff-branch-manager',
      'demo-branch-tashkent-center',
    );
    expect(perms, isNotEmpty);
    expect(perms, contains(BusinessBranchPermission.viewBranch));
  });

  test('unassigned branch has no permissions by default', () {
    expect(
      permRepo.isStaffAssignedToBranch(
        'demo-staff-branch-manager',
        'demo-branch-samarkand',
      ),
      isFalse,
    );
    expect(
      permRepo.permissionsFor(
        'demo-staff-branch-manager',
        'demo-branch-samarkand',
      ),
      isEmpty,
    );
  });

  test('cannot save permissions for unassigned branch', () {
    final result = permRepo.savePermissions(
      'demo-staff-branch-manager',
      'demo-branch-samarkand',
      {BusinessBranchPermission.viewBranch},
    );
    expect(result, BusinessBranchPermissionSaveResult.invalidScope);
  });

  test('invalid branch id rejected', () {
    final result = permRepo.savePermissions(
      'demo-staff-branch-manager',
      'unknown-branch',
      {BusinessBranchPermission.viewBranch},
    );
    expect(result, BusinessBranchPermissionSaveResult.notFound);
  });

  test('owner preview record not editable', () {
    final result = permRepo.savePermissions(
      'demo-staff-owner-preview',
      'demo-branch-tashkent-center',
      {BusinessBranchPermission.viewBranch},
    );
    expect(result, BusinessBranchPermissionSaveResult.notEditable);
  });

  test('read-only staff edits sanitized on save', () {
    final result = permRepo.savePermissions(
      'demo-staff-invite-pending',
      'demo-branch-samarkand',
      {
        BusinessBranchPermission.viewBranch,
        BusinessBranchPermission.editBranchProfile,
      },
    );
    expect(result, BusinessBranchPermissionSaveResult.success);
    final saved = permRepo.permissionsFor(
      'demo-staff-invite-pending',
      'demo-branch-samarkand',
    );
    expect(saved, contains(BusinessBranchPermission.viewBranch));
    expect(saved, isNot(contains(BusinessBranchPermission.editBranchProfile)));
  });

  test('failNextSave keeps prior permissions', () {
    final before = permRepo.permissionsFor(
      'demo-staff-branch-manager',
      'demo-branch-tashkent-center',
    );
    permRepo.failNextSave = true;
    final result = permRepo.savePermissions(
      'demo-staff-branch-manager',
      'demo-branch-tashkent-center',
      {BusinessBranchPermission.viewBranch},
    );
    expect(result, BusinessBranchPermissionSaveResult.failure);
    expect(
      permRepo.permissionsFor(
        'demo-staff-branch-manager',
        'demo-branch-tashkent-center',
      ),
      before,
    );
  });

  test('permission data isolated from onboarding ids', () {
    expect(permRepo.businessScopeId, 'session-owner-profile-demo');
    expect(permRepo.businessScopeId, isNot(contains('onboarding')));
  });
}
