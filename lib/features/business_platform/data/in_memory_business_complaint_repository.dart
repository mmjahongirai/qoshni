import 'package:qoshni/features/business_platform/data/business_complaint_dispute_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_category.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_review_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_complaint_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_complaint_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_reputation_signal_collector.dart';

class InMemoryBusinessComplaintRepository implements BusinessComplaintRepository {
  InMemoryBusinessComplaintRepository(
    this._ownerProfileRepository,
    this._reviewRepository, {
    BusinessReputationSignalCollector? signalCollector,
  }) : _signalCollector = signalCollector;

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessReviewRepository _reviewRepository;
  final BusinessReputationSignalCollector? _signalCollector;

  final Map<String, List<BusinessComplaint>> _byScope = {};
  final Map<String, Map<String, List<BusinessComplaintHistoryEvent>>>
      _historyByScope = {};

  int _complaintCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessComplaint> listForCurrentScope({
    String? branchId,
    BusinessReviewTargetType? targetType,
    BusinessComplaintCategory? category,
    BusinessComplaintStatus? status,
  }) {
    var list = List<BusinessComplaint>.from(_ensureScopeList());
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list
          .where((c) => c.branchId == id || c.branchId == null)
          .toList();
    }
    if (targetType != null) {
      list = list.where((c) => c.targetType == targetType).toList();
    }
    if (category != null) {
      list = list.where((c) => c.category == category).toList();
    }
    if (status != null) {
      list = list.where((c) => c.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessComplaint? findById(String complaintId) {
    try {
      return _ensureScopeList().firstWhere((c) => c.complaintId == complaintId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessComplaintCreateResult createComplaint(
    BusinessComplaintCreateInput input,
  ) {
    if (catalogBusinessComplaintCreateValidationError(input) != null) {
      return BusinessComplaintCreateResult.invalidInput;
    }
    for (final ref in input.syntheticEvidenceReferences) {
      if (!catalogBusinessComplaintSyntheticEvidenceAllowed(ref)) {
        return BusinessComplaintCreateResult.invalidEvidence;
      }
    }
    final related = input.relatedReviewId?.trim();
    if (related != null && related.isNotEmpty) {
      final review = _reviewRepository.findById(related);
      if (review == null || review.businessScopeId != businessScopeId) {
        return BusinessComplaintCreateResult.relatedReviewNotFound;
      }
    }

    if (failNextSave) {
      failNextSave = false;
      return BusinessComplaintCreateResult.failure;
    }

    final now = DateTime.now().toUtc();
    _complaintCounter++;
    final id = 'session-complaint-$_complaintCounter';

    final complaint = BusinessComplaint(
      complaintId: id,
      businessScopeId: businessScopeId,
      branchId: input.branchId?.trim(),
      targetType: input.targetType,
      targetId: input.targetId.trim(),
      demoReporterReference: input.demoReporterReference.trim(),
      category: input.category,
      description: input.description.trim(),
      syntheticEvidenceReferences: input.syntheticEvidenceReferences
          .map((r) => r.trim())
          .toList(growable: false),
      relatedReviewId:
          related == null || related.isEmpty ? null : related,
      status: BusinessComplaintStatus.submitted,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: now,
      updatedAt: now,
      dataSource: BusinessCatalogProductDataSource.userSession,
    );

    _ensureScopeList().add(complaint);
    final historyEvent = BusinessComplaintHistoryEvent(
      eventId: _nextEventId(),
      complaintId: id,
      action: BusinessComplaintHistoryAction.created,
      newStatus: BusinessComplaintStatus.submitted,
      recordedAt: now,
    );
    _appendHistory(historyEvent);
    _signalCollector?.recordComplaintCreated(
      complaint: complaint,
      occurredAt: now,
      sourceHistoryEventId: historyEvent.eventId,
    );
    return BusinessComplaintCreateResult.success;
  }

  @override
  BusinessComplaintTransitionResult applyTransition({
    required String complaintId,
    required BusinessComplaintTransitionRequest request,
  }) {
    final list = _ensureScopeList();
    final index = list.indexWhere((c) => c.complaintId == complaintId);
    if (index < 0) {
      return BusinessComplaintTransitionResult.notFound;
    }
    final complaint = list[index];
    final from = complaint.status;
    final to = request.targetStatus;

    if (from == to) {
      return BusinessComplaintTransitionResult.duplicateStatus;
    }
    if (!catalogBusinessComplaintTransitionAllowed(from: from, to: to)) {
      return BusinessComplaintTransitionResult.invalidTransition;
    }
    if (to == BusinessComplaintStatus.resolved ||
        to == BusinessComplaintStatus.dismissed) {
      if (catalogBusinessComplaintResolutionNoteValidationError(
            request.resolutionNote,
          ) !=
          null) {
        return BusinessComplaintTransitionResult.resolutionNoteRequired;
      }
    }

    final now = DateTime.now().toUtc();
    final note = request.resolutionNote?.trim();
    final updated = complaint.copyWith(
      status: to,
      updatedAt: now,
      resolvedAt: to == BusinessComplaintStatus.resolved ? now : complaint.resolvedAt,
      resolutionNote: note,
      clearResolutionNote: note == null || note.isEmpty,
    );

    final event = BusinessComplaintHistoryEvent(
      eventId: _nextEventId(),
      complaintId: complaintId,
      action: BusinessComplaintHistoryAction.statusChanged,
      previousStatus: from,
      newStatus: to,
      recordedAt: now,
      reason: note,
    );

    if (failNextSave) {
      failNextSave = false;
      return BusinessComplaintTransitionResult.failure;
    }

    list[index] = updated;
    _appendHistory(event);
    _signalCollector?.recordComplaintStatusChanged(
      complaint: updated,
      previousStatus: from,
      newStatus: to,
      occurredAt: now,
      sourceHistoryEventId: event.eventId,
    );
    return BusinessComplaintTransitionResult.success;
  }

  @override
  List<BusinessComplaintHistoryEvent> complaintHistory(String complaintId) {
    final events = _ensureScopeHistory()[complaintId];
    if (events == null) {
      return const [];
    }
    return List.unmodifiable(events);
  }

  void _appendHistory(BusinessComplaintHistoryEvent event) {
    _ensureScopeHistory().putIfAbsent(event.complaintId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-complaint-event-$_eventCounter';
  }

  List<BusinessComplaint> _ensureScopeList() {
    return _byScope.putIfAbsent(businessScopeId, () {
      final complaints =
          buildDemoBusinessComplaints(businessScopeId: businessScopeId);
      _historyByScope[businessScopeId] =
          buildDemoBusinessComplaintHistory(complaints: complaints);
      return complaints;
    });
  }

  Map<String, List<BusinessComplaintHistoryEvent>> _ensureScopeHistory() {
    _ensureScopeList();
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}
