import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_status.dart';

/// Demo staff scoped to [businessScopeId] — isolated from onboarding/catalog.
List<BusinessStaffMember> buildDemoStaffMembers({
  required String businessScopeId,
  DateTime? now,
}) {
  final timestamp = now ?? DateTime.now();
  return [
    BusinessStaffMember(
      staffId: 'demo-staff-owner-preview',
      businessScopeId: businessScopeId,
      dataSource: BusinessStaffDataSource.demoSeed,
      status: BusinessStaffMemberStatus.activePreview,
      firstName: 'Demo',
      lastName: 'Owner (preview)',
      contactPhone: '+998901112233',
      contactEmail: 'owner-preview@example.invalid',
      role: BusinessStaffRole.businessOwner,
      assignedBranchIds: const [
        'demo-branch-tashkent-center',
        'demo-branch-samarkand',
      ],
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
    BusinessStaffMember(
      staffId: 'demo-staff-branch-manager',
      businessScopeId: businessScopeId,
      dataSource: BusinessStaffDataSource.demoSeed,
      status: BusinessStaffMemberStatus.activePreview,
      firstName: 'Dilnoza',
      lastName: 'Karimova',
      contactPhone: '+998909876543',
      role: BusinessStaffRole.branchManager,
      assignedBranchIds: const ['demo-branch-tashkent-center'],
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
    BusinessStaffMember(
      staffId: 'demo-staff-invite-pending',
      businessScopeId: businessScopeId,
      dataSource: BusinessStaffDataSource.demoSeed,
      status: BusinessStaffMemberStatus.invitePendingPreview,
      firstName: 'Jasur',
      lastName: 'Aliyev',
      contactPhone: '+998935551122',
      contactEmail: 'jasur.preview@example.invalid',
      role: BusinessStaffRole.staff,
      assignedBranchIds: const ['demo-branch-samarkand'],
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
  ];
}
