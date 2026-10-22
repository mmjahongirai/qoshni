import 'package:qoshni/features/business_platform/data/business_complaint_dispute_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_dispute_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_dispute_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_dispute_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_reputation_signal_collector.dart';

class InMemoryBusinessDisputeRepository implements BusinessDisputeRepository {
  InMemoryBusinessDisputeRepository(
    this._ownerProfileRepository,
    this._complaintRepository, {
    BusinessReputationSignalCollector? signalCollector,
  }) : _signalCollector = signalCollector;

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessComplaintRepository _complaintRepository;
  final BusinessReputationSignalCollector? _signalCollector;

  final Map<String, List<BusinessDispute>> _byScope = {};
  final Map<String, Map<String, List<BusinessDisputeHistoryEvent>>>
      _historyByScope = {};

  int _disputeCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessDispute> listForCurrentScope({
    String? branchId,
    String? complaintId,
    BusinessDisputeStatus? status,
  }) {
    var list = List<BusinessDispute>.from(_ensureScopeList());
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list
          .where((d) => d.branchId == id || d.branchId == null)
          .toList();
    }
    if (complaintId != null && complaintId.trim().isNotEmpty) {
      final id = complaintId.trim();
      list = list.where((d) => d.complaintId == id).toList();
    }
    if (status != null) {
      list = list.where((d) => d.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessDispute? findById(String disputeId) {
    try {
      return _ensureScopeList().firstWhere((d) => d.disputeId == disputeId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessDispute? findByComplaintId(String complaintId) {
    try {
      return _ensureScopeList().firstWhere((d) => d.complaintId == complaintId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessDisputeCreateResult createDispute(BusinessDisputeCreateInput input) {
    if (catalogBusinessDisputeCreateValidationError(input) != null) {
      return BusinessDisputeCreateResult.invalidInput;
    }

    final complaint =
        _complaintRepository.findById(input.complaintId.trim());
    if (complaint == null) {
      return BusinessDisputeCreateResult.complaintNotFound;
    }
    if (complaint.businessScopeId != businessScopeId) {
      return BusinessDisputeCreateResult.scopeMismatch;
    }
    if (complaint.status == BusinessComplaintStatus.resolved ||
        complaint.status == BusinessComplaintStatus.dismissed) {
      return BusinessDisputeCreateResult.complaintNotEligible;
    }
    if (findByComplaintId(complaint.complaintId) != null) {
      return BusinessDisputeCreateResult.duplicateForComplaint;
    }

    if (failNextSave) {
      failNextSave = false;
      return BusinessDisputeCreateResult.failure;
    }

    final now = DateTime.now().toUtc();
    _disputeCounter++;
    final id = 'session-dispute-$_disputeCounter';

    final dispute = BusinessDispute(
      disputeId: id,
      businessScopeId: businessScopeId,
      branchId: complaint.branchId,
      complaintId: complaint.complaintId,
      demoBusinessInitiatorReference:
          input.demoBusinessInitiatorReference.trim(),
      summary: input.summary.trim(),
      syntheticEvidenceReferences: input.syntheticEvidenceReferences
          .map((r) => r.trim())
          .toList(growable: false),
      status: BusinessDisputeStatus.filed,
      provenance: BusinessReviewProvenance.syntheticDemo,
      createdAt: now,
      updatedAt: now,
      dataSource: BusinessCatalogProductDataSource.userSession,
    );

    _ensureScopeList().add(dispute);
    final historyEvent = BusinessDisputeHistoryEvent(
      eventId: _nextEventId(),
      disputeId: id,
      complaintId: complaint.complaintId,
      action: BusinessDisputeHistoryAction.created,
      newStatus: BusinessDisputeStatus.filed,
      recordedAt: now,
    );
    _appendHistory(historyEvent);
    _signalCollector?.recordDisputeOpened(
      dispute: dispute,
      occurredAt: now,
      sourceHistoryEventId: historyEvent.eventId,
    );
    return BusinessDisputeCreateResult.success;
  }

  @override
  BusinessDisputeTransitionResult applyTransition({
    required String disputeId,
    required BusinessDisputeTransitionRequest request,
  }) {
    final list = _ensureScopeList();
    final index = list.indexWhere((d) => d.disputeId == disputeId);
    if (index < 0) {
      return BusinessDisputeTransitionResult.notFound;
    }
    final dispute = list[index];
    final from = dispute.status;
    final to = request.targetStatus;

    if (from == to) {
      return BusinessDisputeTransitionResult.duplicateStatus;
    }
    if (!catalogBusinessDisputeTransitionAllowed(from: from, to: to)) {
      return BusinessDisputeTransitionResult.invalidTransition;
    }
    final needsNote = to == BusinessDisputeStatus.resolvedForBusiness ||
        to == BusinessDisputeStatus.resolvedForReporter ||
        to == BusinessDisputeStatus.dismissed;
    if (needsNote &&
        catalogBusinessDisputeResolutionNoteValidationError(
              request.resolutionNote,
            ) !=
            null) {
      return BusinessDisputeTransitionResult.resolutionNoteRequired;
    }

    final now = DateTime.now().toUtc();
    final note = request.resolutionNote?.trim();
    final isResolved = to == BusinessDisputeStatus.resolvedForBusiness ||
        to == BusinessDisputeStatus.resolvedForReporter;
    final updated = dispute.copyWith(
      status: to,
      updatedAt: now,
      resolvedAt: isResolved ? now : dispute.resolvedAt,
      resolutionNote: note,
      clearResolutionNote: note == null || note.isEmpty,
    );

    final event = BusinessDisputeHistoryEvent(
      eventId: _nextEventId(),
      disputeId: disputeId,
      complaintId: dispute.complaintId,
      action: BusinessDisputeHistoryAction.statusChanged,
      previousStatus: from,
      newStatus: to,
      recordedAt: now,
      reason: note,
    );

    if (failNextSave) {
      failNextSave = false;
      return BusinessDisputeTransitionResult.failure;
    }

    list[index] = updated;
    _appendHistory(event);
    _signalCollector?.recordDisputeStatusChanged(
      dispute: updated,
      previousStatus: from,
      newStatus: to,
      occurredAt: now,
      sourceHistoryEventId: event.eventId,
    );
    return BusinessDisputeTransitionResult.success;
  }

  @override
  List<BusinessDisputeHistoryEvent> disputeHistory(String disputeId) {
    final events = _ensureScopeHistory()[disputeId];
    if (events == null) {
      return const [];
    }
    return List.unmodifiable(events);
  }

  void _appendHistory(BusinessDisputeHistoryEvent event) {
    _ensureScopeHistory().putIfAbsent(event.disputeId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-dispute-event-$_eventCounter';
  }

  List<BusinessDispute> _ensureScopeList() {
    return _byScope.putIfAbsent(businessScopeId, () {
      final disputes =
          buildDemoBusinessDisputes(businessScopeId: businessScopeId);
      _historyByScope[businessScopeId] =
          buildDemoBusinessDisputeHistory(disputes: disputes);
      return disputes;
    });
  }

  Map<String, List<BusinessDisputeHistoryEvent>> _ensureScopeHistory() {
    _ensureScopeList();
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}
