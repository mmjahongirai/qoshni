import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_permission_repository.dart';

class BusinessBranchPermissionController extends ChangeNotifier {
  BusinessBranchPermissionController(this._repository);

  final BusinessBranchPermissionRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  Set<BusinessBranchPermission> permissionsFor(
    String staffId,
    String branchId,
  ) {
    return _repository.permissionsFor(staffId, branchId);
  }

  bool isStaffAssignedToBranch(String staffId, String branchId) {
    return _repository.isStaffAssignedToBranch(staffId, branchId);
  }

  Future<BusinessBranchPermissionSaveResult> savePermissions(
    String staffId,
    String branchId,
    Set<BusinessBranchPermission> permissions,
  ) async {
    if (_saveBusy) {
      return BusinessBranchPermissionSaveResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result =
        _repository.savePermissions(staffId, branchId, permissions);
    _saveBusy = false;
    notifyListeners();
    return result;
  }
}
