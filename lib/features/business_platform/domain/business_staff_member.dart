import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_status.dart';

class BusinessStaffMember {
  const BusinessStaffMember({
    required this.staffId,
    required this.businessScopeId,
    required this.dataSource,
    required this.status,
    required this.firstName,
    required this.lastName,
    required this.contactPhone,
    this.contactEmail,
    required this.role,
    required this.assignedBranchIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String staffId;
  final String businessScopeId;
  final BusinessStaffDataSource dataSource;
  final BusinessStaffMemberStatus status;
  final String firstName;
  final String lastName;
  final String contactPhone;
  final String? contactEmail;
  final BusinessStaffRole role;
  final List<String> assignedBranchIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessStaffDataSource.demoSeed;

  String get displayName => '$firstName $lastName'.trim();

  bool get isActivePreview =>
      status == BusinessStaffMemberStatus.activePreview;

  BusinessStaffMember copyWith({
    BusinessStaffDataSource? dataSource,
    BusinessStaffMemberStatus? status,
    String? firstName,
    String? lastName,
    String? contactPhone,
    String? contactEmail,
    BusinessStaffRole? role,
    List<String>? assignedBranchIds,
    bool clearContactEmail = false,
    DateTime? updatedAt,
  }) {
    return BusinessStaffMember(
      staffId: staffId,
      businessScopeId: businessScopeId,
      dataSource: dataSource ?? this.dataSource,
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail:
          clearContactEmail ? null : (contactEmail ?? this.contactEmail),
      role: role ?? this.role,
      assignedBranchIds: assignedBranchIds ?? this.assignedBranchIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessStaffMemberInput {
  const BusinessStaffMemberInput({
    required this.firstName,
    required this.lastName,
    required this.contactPhone,
    this.contactEmail,
    required this.role,
    required this.assignedBranchIds,
    required this.isActive,
  });

  final String firstName;
  final String lastName;
  final String contactPhone;
  final String? contactEmail;
  final BusinessStaffRole role;
  final List<String> assignedBranchIds;
  final bool isActive;

  BusinessStaffMemberStatus resolveStatus() {
    if (!isActive) {
      return BusinessStaffMemberStatus.removedPreview;
    }
    return BusinessStaffMemberStatus.activePreview;
  }
}
