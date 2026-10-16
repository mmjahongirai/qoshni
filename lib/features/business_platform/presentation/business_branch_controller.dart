import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';

class BusinessBranchController extends ChangeNotifier {
  BusinessBranchController(this._repository);

  final BusinessBranchRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  String get businessScopeId => _repository.businessScopeId;

  List<BusinessBranch> get branches => _repository.listForCurrentScope();

  BusinessBranch? branchById(String branchId) =>
      _repository.findById(branchId);

  void refresh() {
    notifyListeners();
  }

  Future<BusinessBranchSaveResult> createBranch(
    BusinessBranchInput input,
  ) async {
    return _save(() => _repository.createBranch(input));
  }

  Future<BusinessBranchSaveResult> updateBranch(
    String branchId,
    BusinessBranchInput input,
  ) async {
    return _save(() => _repository.updateBranch(branchId, input));
  }

  Future<BusinessBranchSaveResult> _save(
    BusinessBranchSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessBranchSaveResult.failure;
    }
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = action();
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  void resetToDemoSeed() {
    _repository.resetScopeToDemoSeed();
    notifyListeners();
  }
}
