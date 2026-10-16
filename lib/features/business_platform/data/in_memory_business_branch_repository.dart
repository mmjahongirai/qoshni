import 'package:qoshni/features/business_platform/data/business_branch_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';

class InMemoryBusinessBranchRepository implements BusinessBranchRepository {
  InMemoryBusinessBranchRepository(this._ownerProfileRepository);

  final BusinessOwnerProfileRepository _ownerProfileRepository;

  final Map<String, List<BusinessBranch>> _branchesByScope = {};
  int _userBranchCounter = 0;

  /// Test-only: next save returns [BusinessBranchSaveResult.failure].
  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessBranch> listForCurrentScope() {
    return List.unmodifiable(_ensureScopeList());
  }

  @override
  BusinessBranch? findById(String branchId) {
    try {
      return _ensureScopeList().firstWhere((b) => b.branchId == branchId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessBranchSaveResult createBranch(BusinessBranchInput input) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessBranchSaveResult.failure;
    }
    final now = DateTime.now();
    _userBranchCounter++;
    final branch = BusinessBranch(
      branchId: 'session-branch-$_userBranchCounter',
      businessScopeId: businessScopeId,
      dataSource: BusinessBranchDataSource.userSession,
      status: input.status,
      name: input.name.trim(),
      city: input.city.trim(),
      addressLine: input.addressLine.trim(),
      contactPhone: _normalizeOptional(input.contactPhone),
      weeklySchedule: List.from(input.weeklySchedule),
      locationPreview: BranchLocationPreview(
        latitude: input.latitude,
        longitude: input.longitude,
      ),
      createdAt: now,
      updatedAt: now,
    );
    _ensureScopeList().add(branch);
    return BusinessBranchSaveResult.success;
  }

  @override
  BusinessBranchSaveResult updateBranch(
    String branchId,
    BusinessBranchInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessBranchSaveResult.failure;
    }
    final list = _ensureScopeList();
    final index = list.indexWhere((b) => b.branchId == branchId);
    if (index < 0) {
      return BusinessBranchSaveResult.notFound;
    }
    final existing = list[index];
    final now = DateTime.now();
    list[index] = existing.copyWith(
      dataSource: BusinessBranchDataSource.userSession,
      status: input.status,
      name: input.name.trim(),
      city: input.city.trim(),
      addressLine: input.addressLine.trim(),
      contactPhone: _normalizeOptional(input.contactPhone),
      clearContactPhone:
          input.contactPhone == null || input.contactPhone!.trim().isEmpty,
      weeklySchedule: List.from(input.weeklySchedule),
      locationPreview: BranchLocationPreview(
        latitude: input.latitude,
        longitude: input.longitude,
      ),
      updatedAt: now,
    );
    return BusinessBranchSaveResult.success;
  }

  @override
  void resetScopeToDemoSeed() {
    _branchesByScope[businessScopeId] =
        buildDemoBranches(businessScopeId: businessScopeId);
  }

  List<BusinessBranch> _ensureScopeList() {
    final scope = businessScopeId;
    return _branchesByScope.putIfAbsent(
      scope,
      () => buildDemoBranches(businessScopeId: scope),
    );
  }

  String? _normalizeOptional(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
