import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_task_repository.dart';

class BusinessDeliveryTaskController extends ChangeNotifier {
  BusinessDeliveryTaskController(this._repository);

  final BusinessDeliveryTaskRepository _repository;

  bool _listLoading = true;
  bool _transitionBusy = false;

  bool get listLoading => _listLoading;
  bool get transitionBusy => _transitionBusy;

  List<BusinessDeliveryTask> tasks({
    String? branchId,
    BusinessDeliveryTaskStatus? status,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        status: status,
      );

  BusinessDeliveryTask? taskById(String deliveryTaskId) =>
      _repository.findById(deliveryTaskId);

  List<BusinessDeliveryTaskHistoryEvent> historyFor(String deliveryTaskId) =>
      _repository.taskHistory(deliveryTaskId);

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _repository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessDeliveryTaskTransitionResult> applyTransition({
    required String deliveryTaskId,
    required BusinessDeliveryTaskTransitionRequest request,
  }) async {
    _transitionBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.applyTransition(
      deliveryTaskId: deliveryTaskId,
      request: request,
    );
    _transitionBusy = false;
    notifyListeners();
    return result;
  }
}
