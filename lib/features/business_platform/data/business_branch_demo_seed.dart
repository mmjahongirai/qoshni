import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_status.dart';

/// Demo branches scoped to [businessScopeId] — not public catalog or onboarding data.
List<BusinessBranch> buildDemoBranches({
  required String businessScopeId,
  DateTime? now,
}) {
  final timestamp = now ?? DateTime.now();
  return [
    BusinessBranch(
      branchId: 'demo-branch-tashkent-center',
      businessScopeId: businessScopeId,
      dataSource: BusinessBranchDataSource.demoSeed,
      status: BusinessBranchLifecycleStatus.active,
      name: 'Demo — Tashkent Center',
      city: 'Tashkent',
      addressLine: 'Amir Temur Avenue 12 (preview)',
      contactPhone: '+998901112233',
      weeklySchedule: [
        for (var day = 1; day <= 5; day++)
          BranchDaySchedule(
            weekday: day,
            isClosed: false,
            openTime: '09:00',
            closeTime: '20:00',
          ),
        const BranchDaySchedule(weekday: 6, isClosed: false, openTime: '10:00', closeTime: '16:00'),
        const BranchDaySchedule(weekday: 7, isClosed: true),
      ],
      locationPreview: const BranchLocationPreview(
        latitude: 41.3111,
        longitude: 69.2797,
      ),
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
    BusinessBranch(
      branchId: 'demo-branch-samarkand',
      businessScopeId: businessScopeId,
      dataSource: BusinessBranchDataSource.demoSeed,
      status: BusinessBranchLifecycleStatus.inactive,
      name: 'Demo — Samarkand',
      city: 'Samarkand',
      addressLine: 'Registan district (preview)',
      contactPhone: null,
      weeklySchedule: defaultWeeklySchedule(),
      locationPreview: const BranchLocationPreview(),
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
  ];
}
