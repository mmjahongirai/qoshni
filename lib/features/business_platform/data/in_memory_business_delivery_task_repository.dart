import 'package:qoshni/features/business_platform/data/business_delivery_task_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_fulfillment_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_task_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_task_validation.dart';

class InMemoryBusinessDeliveryTaskRepository
    implements BusinessDeliveryTaskRepository {
  InMemoryBusinessDeliveryTaskRepository(
    this._ownerProfileRepository,
    this._branchRepository,
    this._fulfillmentRepository,
  );

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessBranchRepository _branchRepository;
  final BusinessFulfillmentRepository _fulfillmentRepository;

  final Map<String, List<BusinessDeliveryTask>> _byScope = {};
  final Map<String, Map<String, List<BusinessDeliveryTaskHistoryEvent>>>
      _historyByScope = {};

  int _taskCounter = 0;
  int _eventCounter = 0;

  bool failNextSave = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessDeliveryTask> listForCurrentScope({
    String? branchId,
    BusinessDeliveryTaskStatus? status,
  }) {
    var list = List<BusinessDeliveryTask>.from(_ensureScopeList());
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list.where((t) => t.branchId == id).toList();
    }
    if (status != null) {
      list = list.where((t) => t.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessDeliveryTask? findById(String deliveryTaskId) {
    try {
      return _ensureScopeList()
          .firstWhere((t) => t.deliveryTaskId == deliveryTaskId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessDeliveryTaskCreateResult createDemoTask(
    BusinessDeliveryTaskCreateInput input,
  ) {
    if (catalogDeliveryTaskCreateValidationError(input) != null) {
      if (input.fulfillmentType != BusinessFulfillmentType.delivery) {
        return BusinessDeliveryTaskCreateResult.nonDeliveryFulfillmentType;
      }
      if (input.branchId.trim().isEmpty ||
          _branchRepository.findById(input.branchId.trim()) == null) {
        return BusinessDeliveryTaskCreateResult.invalidBranch;
      }
      return BusinessDeliveryTaskCreateResult.failure;
    }
    final branchId = input.branchId.trim();
    if (_branchRepository.findById(branchId) == null) {
      return BusinessDeliveryTaskCreateResult.invalidBranch;
    }
    final configId = input.fulfillmentConfigurationId?.trim();
    if (configId != null && configId.isNotEmpty) {
      final config = _fulfillmentRepository.findById(configId);
      if (config == null ||
          config.businessScopeId != businessScopeId ||
          config.branchId != branchId) {
        return BusinessDeliveryTaskCreateResult.invalidFulfillmentLink;
      }
      if (!config.supportedFulfillmentTypes
          .contains(BusinessFulfillmentType.delivery)) {
        return BusinessDeliveryTaskCreateResult.invalidFulfillmentLink;
      }
    }

    if (failNextSave) {
      failNextSave = false;
      return BusinessDeliveryTaskCreateResult.failure;
    }

    final now = DateTime.now().toUtc();
    _taskCounter++;
    final taskId = 'session-delivery-task-$_taskCounter';
    final reference = input.demoTaskReference?.trim().isNotEmpty == true
        ? input.demoTaskReference!.trim()
        : 'DT-S$_taskCounter';

    final task = BusinessDeliveryTask(
      deliveryTaskId: taskId,
      demoTaskReference: reference,
      businessScopeId: businessScopeId,
      branchId: branchId,
      fulfillmentConfigurationId:
          configId != null && configId.isNotEmpty ? configId : null,
      fulfillmentType: BusinessFulfillmentType.delivery,
      status: BusinessDeliveryTaskStatus.created,
      demoPickupLabel: input.demoPickupLabel.trim(),
      demoDropOffLabel: input.demoDropOffLabel.trim(),
      demoExternalOrderReference: input.demoExternalOrderReference?.trim(),
      createdAt: now,
      updatedAt: now,
      dataSource: BusinessCatalogProductDataSource.userSession,
    );

    _ensureScopeList().add(task);
    _appendHistory(
      BusinessDeliveryTaskHistoryEvent(
        eventId: _nextEventId(),
        deliveryTaskId: taskId,
        action: BusinessDeliveryTaskHistoryAction.created,
        newStatus: BusinessDeliveryTaskStatus.created,
        recordedAt: now,
      ),
    );
    return BusinessDeliveryTaskCreateResult.success;
  }

  @override
  BusinessDeliveryTaskTransitionResult applyTransition({
    required String deliveryTaskId,
    required BusinessDeliveryTaskTransitionRequest request,
  }) {
    final list = _ensureScopeList();
    final index = list.indexWhere((t) => t.deliveryTaskId == deliveryTaskId);
    if (index < 0) {
      return BusinessDeliveryTaskTransitionResult.notFound;
    }
    final task = list[index];
    final from = task.status;
    final to = request.targetStatus;

    if (businessDeliveryTaskStatusTerminal(from)) {
      return BusinessDeliveryTaskTransitionResult.terminalTask;
    }
    if (from == to) {
      return BusinessDeliveryTaskTransitionResult.duplicateStatus;
    }
    if (!catalogDeliveryTaskTransitionAllowed(from: from, to: to)) {
      return BusinessDeliveryTaskTransitionResult.invalidTransition;
    }
    if (to == BusinessDeliveryTaskStatus.failed) {
      if (catalogDeliveryTaskFailureReasonValidationError(
            request.failureReason,
          ) !=
          null) {
        return BusinessDeliveryTaskTransitionResult.failureReasonRequired;
      }
    }

    final now = DateTime.now().toUtc();
    BusinessDeliveryTask updated;
    if (to == BusinessDeliveryTaskStatus.assigned) {
      final assignment = request.demoAssignmentReference?.trim();
      updated = task.copyWith(
        status: to,
        updatedAt: now,
        clearFailureReason: true,
        demoAssignmentReference: assignment != null && assignment.isNotEmpty
            ? assignment
            : (task.demoAssignmentReference ?? 'Demo courier slot'),
      );
    } else if (to == BusinessDeliveryTaskStatus.failed) {
      updated = task.copyWith(
        status: to,
        updatedAt: now,
        failureReason: request.failureReason!.trim(),
      );
    } else if (to == BusinessDeliveryTaskStatus.readyForPickup &&
        from == BusinessDeliveryTaskStatus.failed) {
      updated = task.copyWith(
        status: to,
        updatedAt: now,
        clearFailureReason: true,
        clearDemoAssignmentReference: true,
      );
    } else {
      updated = task.copyWith(
        status: to,
        updatedAt: now,
        clearFailureReason: true,
      );
    }

    final event = BusinessDeliveryTaskHistoryEvent(
      eventId: _nextEventId(),
      deliveryTaskId: deliveryTaskId,
      action: BusinessDeliveryTaskHistoryAction.statusChanged,
      previousStatus: from,
      newStatus: to,
      recordedAt: now,
      reason: to == BusinessDeliveryTaskStatus.failed
          ? request.failureReason!.trim()
          : null,
    );

    if (failNextSave) {
      failNextSave = false;
      return BusinessDeliveryTaskTransitionResult.failure;
    }

    list[index] = updated;
    _appendHistory(event);
    return BusinessDeliveryTaskTransitionResult.success;
  }

  @override
  List<BusinessDeliveryTaskHistoryEvent> taskHistory(String deliveryTaskId) {
    final events = _ensureScopeHistory()[deliveryTaskId];
    if (events == null) {
      return const [];
    }
    return List.unmodifiable(events);
  }

  void _appendHistory(BusinessDeliveryTaskHistoryEvent event) {
    _ensureScopeHistory()
        .putIfAbsent(event.deliveryTaskId, () => [])
        .add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-delivery-event-$_eventCounter';
  }

  List<BusinessDeliveryTask> _ensureScopeList() {
    return _byScope.putIfAbsent(businessScopeId, () {
      final tasks = buildDemoDeliveryTasks(businessScopeId: businessScopeId);
      _historyByScope[businessScopeId] =
          buildDemoDeliveryTaskHistory(tasks: tasks);
      return tasks;
    });
  }

  Map<String, List<BusinessDeliveryTaskHistoryEvent>> _ensureScopeHistory() {
    _ensureScopeList();
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}
