import 'package:qoshni/features/business_platform/data/business_staff_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_staff_repository.dart';

class InMemoryBusinessStaffRepository implements BusinessStaffRepository {
  InMemoryBusinessStaffRepository(
    this._ownerProfileRepository,
    this._branchRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessBranchRepository _branchRepository;

  final Map<String, List<BusinessStaffMember>> _membersByScope = {};
  int _userStaffCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessStaffMember> listForCurrentScope() {
    return List.unmodifiable(_ensureScopeList());
  }

  @override
  BusinessStaffMember? findById(String staffId) {
    try {
      return _ensureScopeList().firstWhere((m) => m.staffId == staffId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessStaffSaveResult createMember(BusinessStaffMemberInput input) {
    if (!_validateScope(input)) {
      return BusinessStaffSaveResult.invalidScope;
    }
    if (failNextSave) {
      failNextSave = false;
      return BusinessStaffSaveResult.failure;
    }
    final now = DateTime.now();
    _userStaffCounter++;
    final member = BusinessStaffMember(
      staffId: 'session-staff-$_userStaffCounter',
      businessScopeId: businessScopeId,
      dataSource: BusinessStaffDataSource.userSession,
      status: input.resolveStatus(),
      firstName: input.firstName.trim(),
      lastName: input.lastName.trim(),
      contactPhone: _normalizePhone(input.contactPhone)!,
      contactEmail: _normalizeOptional(input.contactEmail),
      role: input.role,
      assignedBranchIds: List.from(input.assignedBranchIds),
      createdAt: now,
      updatedAt: now,
    );
    _ensureScopeList().add(member);
    return BusinessStaffSaveResult.success;
  }

  @override
  BusinessStaffSaveResult updateMember(
    String staffId,
    BusinessStaffMemberInput input,
  ) {
    if (!_validateScope(input)) {
      return BusinessStaffSaveResult.invalidScope;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((m) => m.staffId == staffId);
    if (index < 0) {
      return BusinessStaffSaveResult.notFound;
    }
    final existing = list[index];
    if (existing.role == BusinessStaffRole.businessOwner) {
      return BusinessStaffSaveResult.failure;
    }
    if (failNextSave) {
      failNextSave = false;
      return BusinessStaffSaveResult.failure;
    }
    final now = DateTime.now();
    list[index] = existing.copyWith(
      dataSource: BusinessStaffDataSource.userSession,
      status: input.resolveStatus(),
      firstName: input.firstName.trim(),
      lastName: input.lastName.trim(),
      contactPhone: _normalizePhone(input.contactPhone)!,
      contactEmail: _normalizeOptional(input.contactEmail),
      clearContactEmail:
          input.contactEmail == null || input.contactEmail!.trim().isEmpty,
      role: input.role,
      assignedBranchIds: List.from(input.assignedBranchIds),
      updatedAt: now,
    );
    return BusinessStaffSaveResult.success;
  }

  @override
  void resetScopeToDemoSeed() {
    _membersByScope[businessScopeId] =
        buildDemoStaffMembers(businessScopeId: businessScopeId);
  }

  List<BusinessStaffMember> _ensureScopeList() {
    final scope = businessScopeId;
    if (scope != _branchRepository.businessScopeId) {
      return _membersByScope.putIfAbsent(
        scope,
        () => buildDemoStaffMembers(businessScopeId: scope),
      );
    }
    return _membersByScope.putIfAbsent(
      scope,
      () => buildDemoStaffMembers(businessScopeId: scope),
    );
  }

  bool _validateScope(BusinessStaffMemberInput input) {
    if (!isAssignableBusinessStaffRole(input.role)) {
      return false;
    }
    if (input.assignedBranchIds.isEmpty) {
      return false;
    }
    for (final branchId in input.assignedBranchIds) {
      if (_branchRepository.findById(branchId) == null) {
        return false;
      }
    }
    return true;
  }

  String? _normalizeOptional(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _normalizePhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
