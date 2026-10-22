import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_dispute_repository.dart';

class BusinessDisputeController extends ChangeNotifier {
  BusinessDisputeController(this._repository);

  final BusinessDisputeRepository _repository;

  bool _listLoading = true;
  bool _saveBusy = false;

  bool get listLoading => _listLoading;
  bool get saveBusy => _saveBusy;

  List<BusinessDispute> disputes({
    String? branchId,
    String? complaintId,
    BusinessDisputeStatus? status,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        complaintId: complaintId,
        status: status,
      );

  BusinessDispute? disputeForComplaint(String complaintId) =>
      _repository.findByComplaintId(complaintId);

  List<BusinessDisputeHistoryEvent> historyFor(String disputeId) =>
      _repository.disputeHistory(disputeId);

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _repository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessDisputeCreateResult> createDispute(
    BusinessDisputeCreateInput input,
  ) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.createDispute(input);
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessDisputeTransitionResult> applyTransition({
    required String disputeId,
    required BusinessDisputeTransitionRequest request,
  }) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.applyTransition(
      disputeId: disputeId,
      request: request,
    );
    _saveBusy = false;
    notifyListeners();
    return result;
  }
}
