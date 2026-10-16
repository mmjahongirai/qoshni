import 'package:qoshni/features/business_platform/domain/business_branch_status.dart';

/// Single day opening hours for a branch.
class BranchDaySchedule {
  const BranchDaySchedule({
    required this.weekday,
    required this.isClosed,
    this.openTime,
    this.closeTime,
  });

  /// 1 = Monday … 7 = Sunday (ISO weekday).
  final int weekday;
  final bool isClosed;
  final String? openTime;
  final String? closeTime;

  BranchDaySchedule copyWith({
    bool? isClosed,
    String? openTime,
    String? closeTime,
    bool clearOpenTime = false,
    bool clearCloseTime = false,
  }) {
    return BranchDaySchedule(
      weekday: weekday,
      isClosed: isClosed ?? this.isClosed,
      openTime: clearOpenTime ? null : (openTime ?? this.openTime),
      closeTime: clearCloseTime ? null : (closeTime ?? this.closeTime),
    );
  }
}

/// Branch location (demo-only until map/geocoding backend exists).
class BranchLocationPreview {
  const BranchLocationPreview({
    this.latitude,
    this.longitude,
  });

  final double? latitude;
  final double? longitude;

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.abs() <= 90 &&
      longitude!.abs() <= 180;
}

class BusinessBranch {
  const BusinessBranch({
    required this.branchId,
    required this.businessScopeId,
    required this.dataSource,
    required this.status,
    required this.name,
    required this.city,
    required this.addressLine,
    this.contactPhone,
    required this.weeklySchedule,
    this.locationPreview = const BranchLocationPreview(),
    required this.createdAt,
    required this.updatedAt,
  });

  final String branchId;
  final String businessScopeId;
  final BusinessBranchDataSource dataSource;
  final BusinessBranchLifecycleStatus status;
  final String name;
  final String city;
  final String addressLine;
  final String? contactPhone;
  final List<BranchDaySchedule> weeklySchedule;
  final BranchLocationPreview locationPreview;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessBranchDataSource.demoSeed;

  bool get isActive => status == BusinessBranchLifecycleStatus.active;

  String scheduleSummary({required String Function(int weekday) weekdayLabel}) {
    final openDays = weeklySchedule.where((d) => !d.isClosed).toList();
    if (openDays.isEmpty) {
      return weekdayLabel(0);
    }
    if (openDays.length == 7 &&
        openDays.every(
          (d) =>
              d.openTime == openDays.first.openTime &&
              d.closeTime == openDays.first.closeTime,
        )) {
      return '${openDays.first.openTime}–${openDays.first.closeTime}';
    }
    final first = openDays.first;
    return '${weekdayLabel(first.weekday)} ${first.openTime}–${first.closeTime}';
  }

  BusinessBranch copyWith({
    BusinessBranchDataSource? dataSource,
    BusinessBranchLifecycleStatus? status,
    String? name,
    String? city,
    String? addressLine,
    String? contactPhone,
    List<BranchDaySchedule>? weeklySchedule,
    BranchLocationPreview? locationPreview,
    bool clearContactPhone = false,
    DateTime? updatedAt,
  }) {
    return BusinessBranch(
      branchId: branchId,
      businessScopeId: businessScopeId,
      dataSource: dataSource ?? this.dataSource,
      status: status ?? this.status,
      name: name ?? this.name,
      city: city ?? this.city,
      addressLine: addressLine ?? this.addressLine,
      contactPhone:
          clearContactPhone ? null : (contactPhone ?? this.contactPhone),
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      locationPreview: locationPreview ?? this.locationPreview,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessBranchInput {
  const BusinessBranchInput({
    required this.name,
    required this.city,
    required this.addressLine,
    this.contactPhone,
    required this.status,
    required this.weeklySchedule,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String city;
  final String addressLine;
  final String? contactPhone;
  final BusinessBranchLifecycleStatus status;
  final List<BranchDaySchedule> weeklySchedule;
  final double? latitude;
  final double? longitude;
}

/// Default Mon–Fri 09:00–18:00, Sat–Sun closed.
List<BranchDaySchedule> defaultWeeklySchedule() {
  return [
    for (var day = 1; day <= 7; day++)
      BranchDaySchedule(
        weekday: day,
        isClosed: day >= 6,
        openTime: day < 6 ? '09:00' : null,
        closeTime: day < 6 ? '18:00' : null,
      ),
  ];
}
