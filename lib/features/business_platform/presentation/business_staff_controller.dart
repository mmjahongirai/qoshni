import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_staff_repository.dart';

class BusinessStaffController extends ChangeNotifier {
  BusinessStaffController(this._repository);

  final BusinessStaffRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  String get businessScopeId => _repository.businessScopeId;

  List<BusinessStaffMember> get members => _repository.listForCurrentScope();

  BusinessStaffMember? memberById(String staffId) =>
      _repository.findById(staffId);

  Future<BusinessStaffSaveResult> createMember(
    BusinessStaffMemberInput input,
  ) async {
    return _save(() => _repository.createMember(input));
  }

  Future<BusinessStaffSaveResult> updateMember(
    String staffId,
    BusinessStaffMemberInput input,
  ) async {
    return _save(() => _repository.updateMember(staffId, input));
  }

  Future<BusinessStaffSaveResult> _save(
    BusinessStaffSaveResult Function() action,
  ) async {
    if (_saveBusy) {
      return BusinessStaffSaveResult.failure;
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
