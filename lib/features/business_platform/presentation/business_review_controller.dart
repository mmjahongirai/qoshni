import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_rating_summary.dart';
import 'package:qoshni/features/business_platform/domain/business_review.dart';
import 'package:qoshni/features/business_platform/domain/business_review_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_review_repository.dart';
import 'package:qoshni/features/business_platform/domain/review_eligibility_result.dart';

class BusinessReviewController extends ChangeNotifier {
  BusinessReviewController(this._repository);

  final BusinessReviewRepository _repository;

  bool _listLoading = true;
  bool _saveBusy = false;

  bool get listLoading => _listLoading;
  bool get saveBusy => _saveBusy;

  List<BusinessReview> reviews({
    String? branchId,
    BusinessReviewTargetType? targetType,
    BusinessReviewStatus? status,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        targetType: targetType,
        status: status,
      );

  BusinessRatingSummary ratingSummary({
    String? branchId,
    BusinessReviewTargetType? targetType,
    String? targetId,
  }) =>
      _repository.ratingSummary(
        branchId: branchId,
        targetType: targetType,
        targetId: targetId,
      );

  List<BusinessReviewHistoryEvent> historyFor(String reviewId) =>
      _repository.reviewHistory(reviewId);

  ReviewEligibilityResult previewEligibility(BusinessReviewCreateInput input) =>
      _repository.previewEligibility(input);

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _repository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessReviewCreateResult> createReview(
    BusinessReviewCreateInput input,
  ) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.createReview(input);
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessReviewTransitionResult> applyTransition({
    required String reviewId,
    required BusinessReviewTransitionRequest request,
  }) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.applyTransition(
      reviewId: reviewId,
      request: request,
    );
    _saveBusy = false;
    notifyListeners();
    return result;
  }
}
