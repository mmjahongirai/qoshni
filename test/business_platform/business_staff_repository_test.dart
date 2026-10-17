import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_staff_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_staff_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessBranchRepository branchRepo;
  late InMemoryBusinessStaffRepository staffRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    branchRepo = InMemoryBusinessBranchRepository(ownerRepo);
    staffRepo = InMemoryBusinessStaffRepository(ownerRepo, branchRepo);
    ownerRepo.ensureSessionProfile();
    branchRepo.listForCurrentScope();
  });

  test('demo staff scoped to business profile session id', () {
    final members = staffRepo.listForCurrentScope();
    expect(members, isNotEmpty);
    expect(staffRepo.businessScopeId, 'session-owner-profile-demo');
    expect(members.every((m) => m.staffId.startsWith('demo-staff-')), isTrue);
  });

  test('demo staff separate from onboarding identifiers', () {
    for (final member in staffRepo.listForCurrentScope()) {
      expect(member.staffId, isNot(contains('onboarding')));
      expect(member.businessScopeId, isNot(contains('profile-draft')));
    }
  });

  test('create links to existing branch ids', () {
    const input = BusinessStaffMemberInput(
      firstName: 'New',
      lastName: 'Member',
      contactPhone: '+998909090909',
      role: BusinessStaffRole.branchManager,
      assignedBranchIds: ['demo-branch-tashkent-center'],
      isActive: true,
    );
    expect(staffRepo.createMember(input), BusinessStaffSaveResult.success);
    final created = staffRepo.listForCurrentScope().last;
    expect(created.assignedBranchIds, ['demo-branch-tashkent-center']);
  });

  test('invalid branch id rejected', () {
    const input = BusinessStaffMemberInput(
      firstName: 'Bad',
      lastName: 'Scope',
      contactPhone: '+998909090909',
      role: BusinessStaffRole.staff,
      assignedBranchIds: ['unknown-branch'],
      isActive: true,
    );
    expect(staffRepo.createMember(input), BusinessStaffSaveResult.invalidScope);
  });

  test('cannot update demo business owner', () {
    const input = BusinessStaffMemberInput(
      firstName: 'Hack',
      lastName: '',
      contactPhone: '+998909090909',
      role: BusinessStaffRole.businessAdmin,
      assignedBranchIds: ['demo-branch-tashkent-center'],
      isActive: true,
    );
    expect(
      staffRepo.updateMember('demo-staff-owner-preview', input),
      BusinessStaffSaveResult.failure,
    );
  });

  test('failNextSave preserves member data', () {
    final before = staffRepo.findById('demo-staff-branch-manager')!;
    staffRepo.failNextSave = true;
    final result = staffRepo.updateMember(
      before.staffId,
      BusinessStaffMemberInput(
        firstName: 'Should not apply',
        lastName: before.lastName,
        contactPhone: before.contactPhone,
        role: before.role,
        assignedBranchIds: before.assignedBranchIds,
        isActive: true,
      ),
    );
    expect(result, BusinessStaffSaveResult.failure);
    expect(staffRepo.findById(before.staffId)!.firstName, before.firstName);
  });
}
