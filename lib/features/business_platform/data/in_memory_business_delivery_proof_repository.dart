import 'package:qoshni/features/business_platform/data/business_delivery_proof_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_of_delivery.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_proof_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_proof_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_proof_validation.dart';

class InMemoryBusinessDeliveryProofRepository
    implements BusinessDeliveryProofRepository {
  InMemoryBusinessDeliveryProofRepository(
    this._ownerProfileRepository,
    this._deliveryTaskRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessDeliveryTaskRepository _deliveryTaskRepository;

  final Map<String, List<BusinessDeliveryProofOfDelivery>> _byScope = {};
  final Map<String, Map<String, List<BusinessDeliveryProofHistoryEvent>>>
      _historyByScope = {};

  int _proofCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessDeliveryProofOfDelivery> listForCurrentScope({
    String? branchId,
    String? deliveryTaskId,
  }) {
    var list = List<BusinessDeliveryProofOfDelivery>.from(_ensureScopeList());
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list.where((p) => p.branchId == id).toList();
    }
    if (deliveryTaskId != null && deliveryTaskId.trim().isNotEmpty) {
      final id = deliveryTaskId.trim();
      list = list.where((p) => p.deliveryTaskId == id).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessDeliveryProofOfDelivery? findById(String proofId) {
    try {
      return _ensureScopeList().firstWhere((p) => p.proofId == proofId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessDeliveryProofCreateResult createProof(
    BusinessDeliveryProofCreateInput input,
  ) {
    final validation = catalogDeliveryProofCreateValidationError(input);
    if (validation == 'empty_evidence' ||
        validation == 'evidence_too_long' ||
        validation == 'evidence_looks_like_url' ||
        validation == 'evidence_looks_like_otp') {
      return BusinessDeliveryProofCreateResult.invalidEvidence;
    }
    if (validation == 'empty_description' || validation == 'description_too_long') {
      return BusinessDeliveryProofCreateResult.invalidDescription;
    }
    if (validation != null) {
      return BusinessDeliveryProofCreateResult.failure;
    }

    final task = _deliveryTaskRepository.findById(input.deliveryTaskId.trim());
    if (task == null) {
      return BusinessDeliveryProofCreateResult.taskNotFound;
    }
    if (task.businessScopeId != businessScopeId) {
      return BusinessDeliveryProofCreateResult.scopeMismatch;
    }
    if (task.fulfillmentType != BusinessFulfillmentType.delivery) {
      return BusinessDeliveryProofCreateResult.nonDeliveryTask;
    }

    if (failNextSave) {
      failNextSave = false;
      return BusinessDeliveryProofCreateResult.failure;
    }

    final now = DateTime.now().toUtc();
    _proofCounter++;
    final id = 'session-delivery-proof-$_proofCounter';

    final proof = BusinessDeliveryProofOfDelivery(
      proofId: id,
      deliveryTaskId: task.deliveryTaskId,
      businessScopeId: businessScopeId,
      branchId: task.branchId,
      method: input.method,
      status: BusinessDeliveryProofStatus.pending,
      demoEvidenceReference: input.demoEvidenceReference.trim(),
      description: input.description.trim(),
      createdAt: now,
      updatedAt: now,
      dataSource: BusinessCatalogProductDataSource.userSession,
    );

    _ensureScopeList().add(proof);
    _appendHistory(
      BusinessDeliveryProofHistoryEvent(
        eventId: _nextEventId(),
        proofId: id,
        deliveryTaskId: task.deliveryTaskId,
        action: BusinessDeliveryProofHistoryAction.created,
        newStatus: BusinessDeliveryProofStatus.pending,
        recordedAt: now,
      ),
    );
    return BusinessDeliveryProofCreateResult.success;
  }

  @override
  BusinessDeliveryProofTransitionResult applyTransition({
    required String proofId,
    required BusinessDeliveryProofTransitionRequest request,
  }) {
    final list = _ensureScopeList();
    final index = list.indexWhere((p) => p.proofId == proofId);
    if (index < 0) {
      return BusinessDeliveryProofTransitionResult.notFound;
    }
    final proof = list[index];
    final from = proof.status;
    final to = request.targetStatus;

    if (from == to) {
      return BusinessDeliveryProofTransitionResult.duplicateStatus;
    }
    if (!catalogDeliveryProofTransitionAllowed(from: from, to: to)) {
      return BusinessDeliveryProofTransitionResult.invalidTransition;
    }

    final now = DateTime.now().toUtc();
    final reason = request.demoVerificationReason?.trim();
    final updated = proof.copyWith(
      status: to,
      updatedAt: now,
      demoVerificationReason: reason,
      verifiedAt: to == BusinessDeliveryProofStatus.verified ||
              to == BusinessDeliveryProofStatus.rejected
          ? now
          : null,
      clearVerifiedAt: to == BusinessDeliveryProofStatus.superseded,
      clearDemoVerificationReason: to == BusinessDeliveryProofStatus.superseded,
    );

    final event = BusinessDeliveryProofHistoryEvent(
      eventId: _nextEventId(),
      proofId: proofId,
      deliveryTaskId: proof.deliveryTaskId,
      action: BusinessDeliveryProofHistoryAction.statusChanged,
      previousStatus: from,
      newStatus: to,
      recordedAt: now,
      reason: reason,
    );

    if (failNextSave) {
      failNextSave = false;
      return BusinessDeliveryProofTransitionResult.failure;
    }

    list[index] = updated;
    _appendHistory(event);
    return BusinessDeliveryProofTransitionResult.success;
  }

  @override
  List<BusinessDeliveryProofHistoryEvent> proofHistory(String proofId) {
    final events = _ensureScopeHistory()[proofId];
    if (events == null) {
      return const [];
    }
    return List.unmodifiable(events);
  }

  void _appendHistory(BusinessDeliveryProofHistoryEvent event) {
    _ensureScopeHistory().putIfAbsent(event.proofId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-delivery-proof-event-$_eventCounter';
  }

  List<BusinessDeliveryProofOfDelivery> _ensureScopeList() {
    return _byScope.putIfAbsent(businessScopeId, () {
      final items = buildDemoDeliveryProofs(businessScopeId: businessScopeId);
      _historyByScope[businessScopeId] =
          buildDemoDeliveryProofHistory(proofs: items);
      return items;
    });
  }

  Map<String, List<BusinessDeliveryProofHistoryEvent>> _ensureScopeHistory() {
    _ensureScopeList();
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}
