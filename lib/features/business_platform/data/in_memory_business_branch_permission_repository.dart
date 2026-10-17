import 'package:qoshni/features/business_platform/data/business_branch_permission_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_permission_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_staff_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_permission_policy.dart';

class InMemoryBusinessBranchPermissionRepository
    implements BusinessBranchPermissionRepository {
  InMemoryBusinessBranchPermissionRepository(
    this._staffRepository,
    this._branchRepository,
  );

  final BusinessStaffRepository _staffRepository;
  final BusinessBranchRepository _branchRepository;

  final Map<String, Map<String, Set<BusinessBranchPermission>>> _byScope = {};

  bool failNextSave = false;

  @override
  String get businessScopeId => _staffRepository.businessScopeId;

  @override
  Set<BusinessBranchPermission> permissionsFor(
    String staffId,
    String branchId,
  ) {
    if (!_validateIds(staffId, branchId)) {
      return {};
    }
    if (!isStaffAssignedToBranch(staffId, branchId)) {
      return {};
    }
    return Set.unmodifiable(
      _ensureScopeMap()[branchPermissionKey(staffId, branchId)] ?? {},
    );
  }

  @override
  bool isStaffAssignedToBranch(String staffId, String branchId) {
    final member = _staffRepository.findById(staffId);
    if (member == null || member.businessScopeId != businessScopeId) {
      return false;
    }
    return member.assignedBranchIds.contains(branchId);
  }

  @override
  BusinessBranchPermissionSaveResult savePermissions(
    String staffId,
    String branchId,
    Set<BusinessBranchPermission> permissions,
  ) {
    final member = _staffRepository.findById(staffId);
    final branch = _branchRepository.findById(branchId);
    if (member == null || branch == null) {
      return BusinessBranchPermissionSaveResult.notFound;
    }
    if (member.businessScopeId != businessScopeId ||
        branch.businessScopeId != businessScopeId) {
      return BusinessBranchPermissionSaveResult.invalidScope;
    }
    if (member.role == BusinessStaffRole.businessOwner) {
      return BusinessBranchPermissionSaveResult.notEditable;
    }
    if (!member.assignedBranchIds.contains(branchId)) {
      return BusinessBranchPermissionSaveResult.invalidScope;
    }
    if (failNextSave) {
      failNextSave = false;
      return BusinessBranchPermissionSaveResult.failure;
    }

    final sanitized = sanitizePermissionsForRole(member.role, permissions);
    _ensureScopeMap()[branchPermissionKey(staffId, branchId)] =
        Set.from(sanitized);
    return BusinessBranchPermissionSaveResult.success;
  }

  void resetScopeToDemoSeed() {
    _byScope[businessScopeId] = buildDemoBranchPermissionMap(
      businessScopeId: businessScopeId,
    );
  }

  Map<String, Set<BusinessBranchPermission>> _ensureScopeMap() {
    return _byScope.putIfAbsent(
      businessScopeId,
      () => buildDemoBranchPermissionMap(businessScopeId: businessScopeId),
    );
  }

  bool _validateIds(String staffId, String branchId) {
    final member = _staffRepository.findById(staffId);
    final branch = _branchRepository.findById(branchId);
    if (member == null || branch == null) {
      return false;
    }
    return member.businessScopeId == businessScopeId &&
        branch.businessScopeId == businessScopeId;
  }
}
