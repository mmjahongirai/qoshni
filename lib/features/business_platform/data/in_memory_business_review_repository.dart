import 'package:qoshni/features/business_platform/data/business_review_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_rating_summary.dart';
import 'package:qoshni/features/business_platform/domain/business_review.dart';
import 'package:qoshni/features/business_platform/domain/business_review_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_review_repository.dart';
import 'package:qoshni/features/business_platform/domain/review_eligibility_result.dart';
import 'package:qoshni/features/business_platform/domain/review_transaction_eligibility_provider.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_rating_summary_calculator.dart';
import 'package:qoshni/features/business_platform/presentation/business_review_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_review_validation.dart';

class InMemoryBusinessReviewRepository implements BusinessReviewRepository {
  InMemoryBusinessReviewRepository(
    this._ownerProfileRepository,
    this._eligibilityProvider,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final ReviewTransactionEligibilityProvider _eligibilityProvider;

  final Map<String, List<BusinessReview>> _byScope = {};
  final Map<String, Map<String, List<BusinessReviewHistoryEvent>>>
      _historyByScope = {};

  int _reviewCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessReview> listForCurrentScope({
    String? branchId,
    BusinessReviewTargetType? targetType,
    BusinessReviewStatus? status,
  }) {
    var list = List<BusinessReview>.from(_ensureScopeList());
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list
          .where((r) => r.branchId == id || r.branchId == null)
          .toList();
    }
    if (targetType != null) {
      list = list.where((r) => r.targetType == targetType).toList();
    }
    if (status != null) {
      list = list.where((r) => r.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessReview? findById(String reviewId) {
    try {
      return _ensureScopeList().firstWhere((r) => r.reviewId == reviewId);
    } on StateError {
      return null;
    }
  }

  @override
  ReviewEligibilityResult previewEligibility(BusinessReviewCreateInput input) {
    return _evaluateEligibility(input);
  }

  @override
  BusinessReviewCreateResult createReview(BusinessReviewCreateInput input) {
    if (catalogBusinessReviewCreateValidationError(input) != null) {
      return BusinessReviewCreateResult.invalidInput;
    }
    final eligibility = _evaluateEligibility(input);
    if (!eligibility.isEligible) {
      return BusinessReviewCreateResult.ineligible;
    }

    if (failNextSave) {
      failNextSave = false;
      return BusinessReviewCreateResult.failure;
    }

    final evidence = eligibility.evidence!;
    final now = DateTime.now().toUtc();
    _reviewCounter++;
    final id = 'session-review-$_reviewCounter';

    final review = BusinessReview(
      reviewId: id,
      businessScopeId: businessScopeId,
      branchId: evidence.branchId,
      targetType: input.targetType,
      targetId: input.targetId.trim(),
      demoReviewerReference: input.demoReviewerReference.trim(),
      transactionEvidenceReference: evidence.transactionEvidenceReference,
      rating: input.rating,
      title: input.title?.trim(),
      reviewText: input.reviewText?.trim(),
      status: BusinessReviewStatus.draft,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: now,
      updatedAt: now,
      dataSource: BusinessCatalogProductDataSource.userSession,
    );

    _ensureScopeList().add(review);
    _appendHistory(
      BusinessReviewHistoryEvent(
        eventId: _nextEventId(),
        reviewId: id,
        action: BusinessReviewHistoryAction.created,
        newStatus: BusinessReviewStatus.draft,
        recordedAt: now,
      ),
    );
    return BusinessReviewCreateResult.success;
  }

  @override
  BusinessReviewTransitionResult applyTransition({
    required String reviewId,
    required BusinessReviewTransitionRequest request,
  }) {
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.reviewId == reviewId);
    if (index < 0) {
      return BusinessReviewTransitionResult.notFound;
    }
    final review = list[index];
    final from = review.status;
    final to = request.targetStatus;

    if (from == to) {
      return BusinessReviewTransitionResult.duplicateStatus;
    }
    if (!catalogBusinessReviewTransitionAllowed(from: from, to: to)) {
      return BusinessReviewTransitionResult.invalidTransition;
    }

    final now = DateTime.now().toUtc();
    final reason = request.moderationReason?.trim();
    final updated = review.copyWith(
      status: to,
      updatedAt: now,
      moderatedAt:
          to == BusinessReviewStatus.published ||
                  to == BusinessReviewStatus.rejected ||
                  to == BusinessReviewStatus.hidden
              ? now
              : review.moderatedAt,
      moderationReason: reason,
      clearModerationReason: reason == null || reason.isEmpty,
    );

    final event = BusinessReviewHistoryEvent(
      eventId: _nextEventId(),
      reviewId: reviewId,
      action: BusinessReviewHistoryAction.statusChanged,
      previousStatus: from,
      newStatus: to,
      recordedAt: now,
      reason: reason,
    );

    if (failNextSave) {
      failNextSave = false;
      return BusinessReviewTransitionResult.failure;
    }

    list[index] = updated;
    _appendHistory(event);
    return BusinessReviewTransitionResult.success;
  }

  @override
  List<BusinessReviewHistoryEvent> reviewHistory(String reviewId) {
    final events = _ensureScopeHistory()[reviewId];
    if (events == null) {
      return const [];
    }
    return List.unmodifiable(events);
  }

  @override
  BusinessRatingSummary ratingSummary({
    String? branchId,
    BusinessReviewTargetType? targetType,
    String? targetId,
  }) {
    var list = listForCurrentScope(
      branchId: branchId,
      targetType: targetType,
    );
    if (targetId != null && targetId.trim().isNotEmpty) {
      final id = targetId.trim();
      list = list.where((r) => r.targetId == id).toList();
    }
    return computeBusinessRatingSummary(list);
  }

  ReviewEligibilityResult _evaluateEligibility(BusinessReviewCreateInput input) {
    final duplicate = _ensureScopeList().any(
      (r) =>
          r.transactionEvidenceReference ==
              input.transactionEvidenceReference.trim() &&
          r.demoReviewerReference == input.demoReviewerReference.trim(),
    );
    return _eligibilityProvider.evaluate(
      transactionEvidenceReference: input.transactionEvidenceReference,
      demoReviewerReference: input.demoReviewerReference,
      businessScopeId: businessScopeId,
      branchId: input.branchId,
      targetType: input.targetType,
      targetId: input.targetId.trim(),
      hasExistingReviewForEvidenceAndReviewer: duplicate,
    );
  }

  void _appendHistory(BusinessReviewHistoryEvent event) {
    _ensureScopeHistory().putIfAbsent(event.reviewId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-review-event-$_eventCounter';
  }

  List<BusinessReview> _ensureScopeList() {
    return _byScope.putIfAbsent(businessScopeId, () {
      final reviews = buildDemoBusinessReviews(businessScopeId: businessScopeId);
      _historyByScope[businessScopeId] =
          buildDemoBusinessReviewHistory(reviews: reviews);
      return reviews;
    });
  }

  Map<String, List<BusinessReviewHistoryEvent>> _ensureScopeHistory() {
    _ensureScopeList();
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}
