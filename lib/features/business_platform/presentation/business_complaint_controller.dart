import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_category.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_complaint_repository.dart';

class BusinessComplaintController extends ChangeNotifier {
  BusinessComplaintController(this._repository);

  final BusinessComplaintRepository _repository;

  bool _listLoading = true;
  bool _saveBusy = false;

  bool get listLoading => _listLoading;
  bool get saveBusy => _saveBusy;

  List<BusinessComplaint> complaints({
    String? branchId,
    BusinessReviewTargetType? targetType,
    BusinessComplaintCategory? category,
    BusinessComplaintStatus? status,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        targetType: targetType,
        category: category,
        status: status,
      );

  List<BusinessComplaintHistoryEvent> historyFor(String complaintId) =>
      _repository.complaintHistory(complaintId);

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _repository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessComplaintCreateResult> createComplaint(
    BusinessComplaintCreateInput input,
  ) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.createComplaint(input);
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessComplaintTransitionResult> applyTransition({
    required String complaintId,
    required BusinessComplaintTransitionRequest request,
  }) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.applyTransition(
      complaintId: complaintId,
      request: request,
    );
    _saveBusy = false;
    notifyListeners();
    return result;
  }
}
