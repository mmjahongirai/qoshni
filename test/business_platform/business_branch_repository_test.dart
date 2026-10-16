import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository ownerRepo;
  late InMemoryBusinessBranchRepository branchRepo;

  setUp(() {
    ownerRepo = InMemoryBusinessOwnerProfileRepository();
    branchRepo = InMemoryBusinessBranchRepository(ownerRepo);
    ownerRepo.ensureSessionProfile();
  });

  test('lists demo branches scoped to owner profile session id', () {
    final branches = branchRepo.listForCurrentScope();
    expect(branches, isNotEmpty);
    expect(branches.every((b) => b.isDemoSeed), isTrue);
    expect(
      branchRepo.businessScopeId,
      'session-owner-profile-demo',
    );
    expect(branches.first.branchId, startsWith('demo-branch-'));
  });

  test('demo branches are separate from onboarding profile drafts', () {
    final branches = branchRepo.listForCurrentScope();
    for (final branch in branches) {
      expect(branch.branchId, isNot(contains('onboarding')));
      expect(branch.businessScopeId, isNot(contains('profile-draft')));
    }
  });

  test('create and update branch in session', () {
    const input = BusinessBranchInput(
      name: 'New spot',
      city: 'Bukhara',
      addressLine: 'Old city',
      status: BusinessBranchLifecycleStatus.active,
      weeklySchedule: [
        BranchDaySchedule(
          weekday: 1,
          isClosed: false,
          openTime: '10:00',
          closeTime: '19:00',
        ),
      ],
    );

    expect(branchRepo.createBranch(input), BusinessBranchSaveResult.success);
    final created = branchRepo.listForCurrentScope().last;
    expect(created.dataSource, BusinessBranchDataSource.userSession);
    expect(created.name, 'New spot');

    final update = BusinessBranchInput(
      name: 'Renamed',
      city: created.city,
      addressLine: created.addressLine,
      status: BusinessBranchLifecycleStatus.inactive,
      weeklySchedule: created.weeklySchedule,
    );
    expect(
      branchRepo.updateBranch(created.branchId, update),
      BusinessBranchSaveResult.success,
    );
    expect(branchRepo.findById(created.branchId)!.name, 'Renamed');
  });

  test('failNextSave does not mutate branch', () {
    final before = branchRepo.findById('demo-branch-tashkent-center')!;
    branchRepo.failNextSave = true;
    final result = branchRepo.updateBranch(
      before.branchId,
      BusinessBranchInput(
        name: 'Should not apply',
        city: before.city,
        addressLine: before.addressLine,
        status: before.status,
        weeklySchedule: before.weeklySchedule,
      ),
    );
    expect(result, BusinessBranchSaveResult.failure);
    expect(branchRepo.findById(before.branchId)!.name, before.name);
  });

  test('update unknown id returns notFound', () {
    final result = branchRepo.updateBranch(
      'missing-branch',
      BusinessBranchInput(
        name: 'X',
        city: 'Y',
        addressLine: 'Z',
        status: BusinessBranchLifecycleStatus.active,
        weeklySchedule: defaultWeeklySchedule(),
      ),
    );
    expect(result, BusinessBranchSaveResult.notFound);
  });
}
