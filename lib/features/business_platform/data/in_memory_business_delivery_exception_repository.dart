import 'package:qoshni/features/business_platform/data/business_delivery_exception_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_exception_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_exception_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_exception_validation.dart';

class InMemoryBusinessDeliveryExceptionRepository
    implements BusinessDeliveryExceptionRepository {
  InMemoryBusinessDeliveryExceptionRepository(
    this._ownerProfileRepository,
    this._deliveryTaskRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessDeliveryTaskRepository _deliveryTaskRepository;

  final Map<String, List<BusinessDeliveryException>> _byScope = {};
  final Map<String, Map<String, List<BusinessDeliveryExceptionHistoryEvent>>>
      _historyByScope = {};

  int _exceptionCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessDeliveryException> listForCurrentScope({
    String? branchId,
    String? deliveryTaskId,
  }) {
    var list = List<BusinessDeliveryException>.from(_ensureScopeList());
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list.where((e) => e.branchId == id).toList();
    }
    if (deliveryTaskId != null && deliveryTaskId.trim().isNotEmpty) {
      final id = deliveryTaskId.trim();
      list = list.where((e) => e.deliveryTaskId == id).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessDeliveryException? findById(String exceptionId) {
    try {
      return _ensureScopeList()
          .firstWhere((e) => e.exceptionId == exceptionId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessDeliveryExceptionCreateResult createException(
    BusinessDeliveryExceptionCreateInput input,
  ) {
    if (catalogDeliveryExceptionCreateValidationError(input) != null) {
      return BusinessDeliveryExceptionCreateResult.invalidReason;
    }
    final task = _deliveryTaskRepository.findById(input.deliveryTaskId.trim());
    if (task == null) {
      return BusinessDeliveryExceptionCreateResult.taskNotFound;
    }
    if (task.businessScopeId != businessScopeId) {
      return BusinessDeliveryExceptionCreateResult.scopeMismatch;
    }
    if (task.fulfillmentType != BusinessFulfillmentType.delivery) {
      return BusinessDeliveryExceptionCreateResult.nonDeliveryTask;
    }

    if (failNextSave) {
      failNextSave = false;
      return BusinessDeliveryExceptionCreateResult.failure;
    }

    final now = DateTime.now().toUtc();
    _exceptionCounter++;
    final id = 'session-delivery-exception-$_exceptionCounter';

    final exception = BusinessDeliveryException(
      exceptionId: id,
      deliveryTaskId: task.deliveryTaskId,
      businessScopeId: businessScopeId,
      branchId: task.branchId,
      category: input.category,
      severity: input.severity,
      reason: input.reason.trim(),
      status: BusinessDeliveryExceptionStatus.open,
      createdAt: now,
      updatedAt: now,
      dataSource: BusinessCatalogProductDataSource.userSession,
    );

    _ensureScopeList().add(exception);
    _appendHistory(
      BusinessDeliveryExceptionHistoryEvent(
        eventId: _nextEventId(),
        exceptionId: id,
        deliveryTaskId: task.deliveryTaskId,
        action: BusinessDeliveryExceptionHistoryAction.created,
        newStatus: BusinessDeliveryExceptionStatus.open,
        recordedAt: now,
      ),
    );
    return BusinessDeliveryExceptionCreateResult.success;
  }

  @override
  BusinessDeliveryExceptionTransitionResult applyTransition({
    required String exceptionId,
    required BusinessDeliveryExceptionTransitionRequest request,
  }) {
    final list = _ensureScopeList();
    final index = list.indexWhere((e) => e.exceptionId == exceptionId);
    if (index < 0) {
      return BusinessDeliveryExceptionTransitionResult.notFound;
    }
    final exception = list[index];
    final from = exception.status;
    final to = request.targetStatus;

    if (from == to) {
      return BusinessDeliveryExceptionTransitionResult.duplicateStatus;
    }
    if (!catalogDeliveryExceptionTransitionAllowed(from: from, to: to)) {
      return BusinessDeliveryExceptionTransitionResult.invalidTransition;
    }
    if (to == BusinessDeliveryExceptionStatus.resolved) {
      if (catalogDeliveryExceptionResolutionNoteValidationError(
            request.resolutionNote,
          ) !=
          null) {
        return BusinessDeliveryExceptionTransitionResult
            .resolutionNoteRequired;
      }
    }

    final now = DateTime.now().toUtc();
    BusinessDeliveryException updated;
    BusinessDeliveryExceptionHistoryAction action =
        BusinessDeliveryExceptionHistoryAction.statusChanged;
    String? historyReason;

    if (to == BusinessDeliveryExceptionStatus.open) {
      action = BusinessDeliveryExceptionHistoryAction.reopened;
      historyReason = request.reopenNote?.trim();
      updated = exception.copyWith(
        status: to,
        clearResolutionNote: true,
        clearResolvedAt: true,
        updatedAt: now,
      );
    } else if (to == BusinessDeliveryExceptionStatus.resolved) {
      final note = request.resolutionNote!.trim();
      updated = exception.copyWith(
        status: to,
        resolutionNote: note,
        resolvedAt: now,
        updatedAt: now,
      );
      historyReason = note;
    } else {
      updated = exception.copyWith(
        status: to,
        updatedAt: now,
      );
      historyReason = request.reopenNote?.trim();
    }

    final event = BusinessDeliveryExceptionHistoryEvent(
      eventId: _nextEventId(),
      exceptionId: exceptionId,
      deliveryTaskId: exception.deliveryTaskId,
      action: action,
      previousStatus: from,
      newStatus: to,
      recordedAt: now,
      reason: historyReason,
    );

    if (failNextSave) {
      failNextSave = false;
      return BusinessDeliveryExceptionTransitionResult.failure;
    }

    list[index] = updated;
    _appendHistory(event);
    return BusinessDeliveryExceptionTransitionResult.success;
  }

  @override
  List<BusinessDeliveryExceptionHistoryEvent> exceptionHistory(
    String exceptionId,
  ) {
    final events = _ensureScopeHistory()[exceptionId];
    if (events == null) {
      return const [];
    }
    return List.unmodifiable(events);
  }

  void _appendHistory(BusinessDeliveryExceptionHistoryEvent event) {
    _ensureScopeHistory()
        .putIfAbsent(event.exceptionId, () => [])
        .add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-delivery-exception-event-$_eventCounter';
  }

  List<BusinessDeliveryException> _ensureScopeList() {
    return _byScope.putIfAbsent(businessScopeId, () {
      final items =
          buildDemoDeliveryExceptions(businessScopeId: businessScopeId);
      _historyByScope[businessScopeId] =
          buildDemoDeliveryExceptionHistory(exceptions: items);
      return items;
    });
  }

  Map<String, List<BusinessDeliveryExceptionHistoryEvent>>
      _ensureScopeHistory() {
    _ensureScopeList();
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}
