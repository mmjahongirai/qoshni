import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_history_event.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_exception_repository.dart';

class BusinessDeliveryExceptionController extends ChangeNotifier {
  BusinessDeliveryExceptionController(this._repository);

  final BusinessDeliveryExceptionRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  List<BusinessDeliveryException> exceptions({
    String? branchId,
    String? deliveryTaskId,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        deliveryTaskId: deliveryTaskId,
      );

  List<BusinessDeliveryExceptionHistoryEvent> historyFor(String exceptionId) =>
      _repository.exceptionHistory(exceptionId);

  Future<BusinessDeliveryExceptionCreateResult> createException(
    BusinessDeliveryExceptionCreateInput input,
  ) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.createException(input);
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessDeliveryExceptionTransitionResult> applyTransition({
    required String exceptionId,
    required BusinessDeliveryExceptionTransitionRequest request,
  }) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.applyTransition(
      exceptionId: exceptionId,
      request: request,
    );
    _saveBusy = false;
    notifyListeners();
    return result;
  }
}
