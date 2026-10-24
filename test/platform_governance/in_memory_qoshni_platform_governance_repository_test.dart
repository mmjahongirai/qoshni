import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_mutation_result.dart';

void main() {
  test('seed data is deterministic', () {
    final a = InMemoryQoshniPlatformGovernanceRepository();
    final b = InMemoryQoshniPlatformGovernanceRepository();
    expect(a.listAdmins().map((e) => e.adminId).toList(),
        b.listAdmins().map((e) => e.adminId).toList());
    expect(a.listRoles().map((e) => e.roleId).toList(),
        b.listRoles().map((e) => e.roleId).toList());
  });

  test('duplicate role assignment does not mutate admin', () {
    final repo = InMemoryQoshniPlatformGovernanceRepository();
    final before = repo.findAdmin('admin-demo-viewer')!.roleIds.length;
    final result = repo.assignRoleToAdmin(
      adminId: 'admin-demo-viewer',
      roleId: 'role-platform-viewer',
      updatedAtUtc: kDemoPlatformGovernanceEpoch,
    );
    expect(result, QoshniPlatformGovernanceMutationResult.duplicateAssignment);
    expect(repo.findAdmin('admin-demo-viewer')!.roleIds.length, before);
  });

  test('invalid role reference leaves admin unchanged', () {
    final repo = InMemoryQoshniPlatformGovernanceRepository();
    final before = repo.findAdmin('admin-demo-viewer')!.roleIds;
    final result = repo.assignRoleToAdmin(
      adminId: 'admin-demo-viewer',
      roleId: 'role-does-not-exist',
      updatedAtUtc: kDemoPlatformGovernanceEpoch,
    );
    expect(result, QoshniPlatformGovernanceMutationResult.invalidRoleReference);
    expect(repo.findAdmin('admin-demo-viewer')!.roleIds, before);
  });

  test('failNextMutation leaves state unchanged', () {
    final repo = InMemoryQoshniPlatformGovernanceRepository();
    repo.failNextMutation = true;
    final beforeStatus = repo.findAdmin('admin-demo-viewer')!.status;
    final result = repo.setAdminStatus(
      adminId: 'admin-demo-viewer',
      status: QoshniPlatformAdminStatus.suspended,
      updatedAtUtc: kDemoPlatformGovernanceEpoch,
    );
    expect(result, QoshniPlatformGovernanceMutationResult.failure);
    expect(repo.findAdmin('admin-demo-viewer')!.status, beforeStatus);
  });
}
