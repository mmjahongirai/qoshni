import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';

class BusinessOwnerProfileController extends ChangeNotifier {
  BusinessOwnerProfileController(this._repository);

  final BusinessOwnerProfileRepository _repository;

  bool _saveBusy = false;
  BusinessOwnerProfileSaveResult? _lastSaveResult;

  bool get saveBusy => _saveBusy;
  BusinessOwnerProfileSaveResult? get lastSaveResult => _lastSaveResult;

  BusinessOwnerProfile get profile => _repository.ensureSessionProfile();

  void refresh() {
    _repository.ensureSessionProfile();
    notifyListeners();
  }

  Future<BusinessOwnerProfileSaveResult> save(
    BusinessOwnerProfileInput input,
  ) async {
    if (_saveBusy) {
      return BusinessOwnerProfileSaveResult.failure;
    }
    _saveBusy = true;
    _lastSaveResult = null;
    notifyListeners();

    await Future<void>.delayed(Duration.zero);
    final result = _repository.saveSessionProfile(input);
    _lastSaveResult = result;
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  void resetToDemoSeed() {
    _repository.resetSessionToDemoSeed();
    _lastSaveResult = null;
    notifyListeners();
  }

  void clearLastSaveResult() {
    _lastSaveResult = null;
    notifyListeners();
  }
}
