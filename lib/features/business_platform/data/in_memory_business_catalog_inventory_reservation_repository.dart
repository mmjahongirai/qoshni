import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_lifecycle_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_reconciliation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_reservation_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_reservation_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_reservation_validation.dart';

class InMemoryBusinessCatalogInventoryReservationRepository
    implements BusinessCatalogInventoryReservationRepository {
  InMemoryBusinessCatalogInventoryReservationRepository(
    this._ownerProfileRepository,
    this._inventoryRepository,
    {DateTime Function()? clock}
  ) : _clock = clock ?? DateTime.now;

  final BusinessOwnerProfileRepository _ownerProfileRepository;
  final BusinessCatalogInventoryRepository _inventoryRepository;
  final DateTime Function() _clock;

  final Map<String, List<BusinessCatalogInventoryReservation>> _byScope = {};
  final Map<String, Map<String, List<BusinessCatalogInventoryReservationLifecycleEvent>>>
      _historyByScope = {};

  int _reservationCounter = 0;
  int _eventCounter = 0;

  bool failNextOperation = false;

  InMemoryBusinessCatalogInventoryRepository get _inventoryInMemory =>
      _inventoryRepository as InMemoryBusinessCatalogInventoryRepository;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessCatalogInventoryReservation> listForCurrentScope({
    BusinessCatalogInventoryReservationStatus? status,
    String? branchId,
    String? inventoryItemId,
  }) {
    var list = List<BusinessCatalogInventoryReservation>.from(_ensureScopeList());
    if (status != null) {
      list = list.where((r) => r.status == status).toList();
    }
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list.where((r) => r.branchId == id).toList();
    }
    if (inventoryItemId != null && inventoryItemId.trim().isNotEmpty) {
      final id = inventoryItemId.trim();
      list = list.where((r) => r.inventoryItemId == id).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  BusinessCatalogInventoryReservation? findById(String reservationId) {
    try {
      return _ensureScopeList().firstWhere((r) => r.reservationId == reservationId);
    } on StateError {
      return null;
    }
  }

  @override
  BusinessCatalogInventoryReservationReserveResult reserve({
    required BusinessCatalogInventoryReservationInput input,
    DateTime? now,
  }) {
    if (failNextOperation) {
      failNextOperation = false;
      return BusinessCatalogInventoryReservationReserveResult.failure;
    }

    final timestamp = now ?? _clock();
    final opRef = input.operationReference?.trim();
    if (opRef != null && opRef.isNotEmpty) {
      final existing = _findByOperationReference(opRef);
      if (existing != null) {
        return BusinessCatalogInventoryReservationReserveResult.idempotentReplay;
      }
    }

    final item = _inventoryRepository.findById(input.inventoryItemId.trim());
    final validationError = catalogInventoryReservationInputValidationError(
      quantity: input.quantity,
      expiresAt: input.expiresAt,
      now: timestamp,
      item: item,
      businessScopeId: businessScopeId,
    );
    switch (validationError) {
      case 'invalid_quantity':
        return BusinessCatalogInventoryReservationReserveResult.invalidQuantity;
      case 'invalid_expiry':
        return BusinessCatalogInventoryReservationReserveResult.invalidExpiry;
      case 'not_found':
        return BusinessCatalogInventoryReservationReserveResult.notFound;
      case 'invalid_scope':
        return BusinessCatalogInventoryReservationReserveResult.invalidScope;
      case 'item_unavailable':
        return BusinessCatalogInventoryReservationReserveResult.itemUnavailable;
      case 'insufficient_available':
        return BusinessCatalogInventoryReservationReserveResult.insufficientAvailable;
      case null:
        break;
      default:
        return BusinessCatalogInventoryReservationReserveResult.failure;
    }

    final current = item!;
    final nextReserved = current.reservedQuantity + input.quantity;
    final updateResult = _inventoryInMemory.setQuantitiesForLifecycle(
      inventoryItemId: current.inventoryItemId,
      onHandQuantity: current.onHandQuantity,
      reservedQuantity: nextReserved,
    );
    if (updateResult != CatalogInventoryLifecycleQuantityResult.success) {
      return BusinessCatalogInventoryReservationReserveResult.failure;
    }

    _reservationCounter++;
    final reservation = BusinessCatalogInventoryReservation(
      reservationId: 'session-catalog-reservation-$_reservationCounter',
      inventoryItemId: current.inventoryItemId,
      productId: current.productId,
      variantId: current.variantId,
      businessScopeId: businessScopeId,
      branchId: current.branchId,
      quantity: input.quantity,
      status: BusinessCatalogInventoryReservationStatus.reserved,
      createdAt: timestamp,
      expiresAt: input.expiresAt,
      operationReference: opRef?.isEmpty ?? true ? null : opRef,
      dataSource: BusinessCatalogProductDataSource.userSession,
    );
    _ensureScopeList().add(reservation);
    _appendHistory(
      reservation.reservationId,
      BusinessCatalogInventoryReservationLifecycleEvent(
        eventId: _nextEventId(),
        reservationId: reservation.reservationId,
        action: BusinessCatalogInventoryReservationLifecycleAction.reserve,
        statusBefore: BusinessCatalogInventoryReservationStatus.reserved,
        statusAfter: BusinessCatalogInventoryReservationStatus.reserved,
        quantity: input.quantity,
        recordedAt: timestamp,
        reason: 'Reserved for demo preview',
      ),
    );
    return BusinessCatalogInventoryReservationReserveResult.success;
  }

  @override
  BusinessCatalogInventoryReservationReleaseResult release({
    required String reservationId,
    DateTime? now,
  }) {
    if (failNextOperation) {
      failNextOperation = false;
      return BusinessCatalogInventoryReservationReleaseResult.failure;
    }
    final timestamp = now ?? _clock();
    final reservation = findById(reservationId);
    if (reservation == null) {
      return BusinessCatalogInventoryReservationReleaseResult.notFound;
    }
    if (reservation.status == BusinessCatalogInventoryReservationStatus.released) {
      return BusinessCatalogInventoryReservationReleaseResult.idempotentReplay;
    }
    if (!catalogReservationCanRelease(reservation) ||
        reservation.status != BusinessCatalogInventoryReservationStatus.reserved) {
      return BusinessCatalogInventoryReservationReleaseResult.invalidTransition;
    }

    final item = _inventoryRepository.findById(reservation.inventoryItemId);
    if (item == null || item.businessScopeId != businessScopeId) {
      return BusinessCatalogInventoryReservationReleaseResult.failure;
    }

    final nextReserved = item.reservedQuantity - reservation.quantity;
    final updateResult = _inventoryInMemory.setQuantitiesForLifecycle(
      inventoryItemId: item.inventoryItemId,
      onHandQuantity: item.onHandQuantity,
      reservedQuantity: nextReserved,
    );
    if (updateResult != CatalogInventoryLifecycleQuantityResult.success) {
      return BusinessCatalogInventoryReservationReleaseResult.failure;
    }

    _updateReservationStatus(
      reservationId,
      BusinessCatalogInventoryReservationStatus.released,
    );
    _appendHistory(
      reservationId,
      BusinessCatalogInventoryReservationLifecycleEvent(
        eventId: _nextEventId(),
        reservationId: reservationId,
        action: BusinessCatalogInventoryReservationLifecycleAction.release,
        statusBefore: BusinessCatalogInventoryReservationStatus.reserved,
        statusAfter: BusinessCatalogInventoryReservationStatus.released,
        quantity: reservation.quantity,
        recordedAt: timestamp,
        reason: 'Released in demo preview',
      ),
    );
    return BusinessCatalogInventoryReservationReleaseResult.success;
  }

  @override
  BusinessCatalogInventoryReservationConfirmResult confirm({
    required String reservationId,
    DateTime? now,
  }) {
    if (failNextOperation) {
      failNextOperation = false;
      return BusinessCatalogInventoryReservationConfirmResult.failure;
    }
    final timestamp = now ?? _clock();
    final reservation = findById(reservationId);
    if (reservation == null) {
      return BusinessCatalogInventoryReservationConfirmResult.notFound;
    }
    if (reservation.status ==
        BusinessCatalogInventoryReservationStatus.confirmed) {
      return BusinessCatalogInventoryReservationConfirmResult.idempotentReplay;
    }
    if (catalogReservationIsExpiredByTime(reservation, timestamp)) {
      return BusinessCatalogInventoryReservationConfirmResult.expired;
    }
    if (!catalogReservationCanConfirm(reservation, timestamp) ||
        reservation.status != BusinessCatalogInventoryReservationStatus.reserved) {
      return BusinessCatalogInventoryReservationConfirmResult.invalidTransition;
    }

    final item = _inventoryRepository.findById(reservation.inventoryItemId);
    if (item == null || item.businessScopeId != businessScopeId) {
      return BusinessCatalogInventoryReservationConfirmResult.failure;
    }

    final nextOnHand = item.onHandQuantity - reservation.quantity;
    final nextReserved = item.reservedQuantity - reservation.quantity;
    final updateResult = _inventoryInMemory.setQuantitiesForLifecycle(
      inventoryItemId: item.inventoryItemId,
      onHandQuantity: nextOnHand,
      reservedQuantity: nextReserved,
    );
    if (updateResult != CatalogInventoryLifecycleQuantityResult.success) {
      return BusinessCatalogInventoryReservationConfirmResult.failure;
    }

    _updateReservationStatus(
      reservationId,
      BusinessCatalogInventoryReservationStatus.confirmed,
    );
    _appendHistory(
      reservationId,
      BusinessCatalogInventoryReservationLifecycleEvent(
        eventId: _nextEventId(),
        reservationId: reservationId,
        action: BusinessCatalogInventoryReservationLifecycleAction.confirm,
        statusBefore: BusinessCatalogInventoryReservationStatus.reserved,
        statusAfter: BusinessCatalogInventoryReservationStatus.confirmed,
        quantity: reservation.quantity,
        recordedAt: timestamp,
        reason: 'Confirmed as demo sale',
      ),
    );
    return BusinessCatalogInventoryReservationConfirmResult.success;
  }

  @override
  BusinessCatalogInventoryReservationExpireResult expireReservation({
    required String reservationId,
    DateTime? now,
  }) {
    if (failNextOperation) {
      failNextOperation = false;
      return BusinessCatalogInventoryReservationExpireResult.failure;
    }
    final timestamp = now ?? _clock();
    final reservation = findById(reservationId);
    if (reservation == null) {
      return BusinessCatalogInventoryReservationExpireResult.notFound;
    }
    if (reservation.status == BusinessCatalogInventoryReservationStatus.expired) {
      return BusinessCatalogInventoryReservationExpireResult.idempotentReplay;
    }
    if (!catalogReservationCanExpire(reservation, timestamp) ||
        reservation.status != BusinessCatalogInventoryReservationStatus.reserved) {
      return BusinessCatalogInventoryReservationExpireResult.invalidTransition;
    }

    final item = _inventoryRepository.findById(reservation.inventoryItemId);
    if (item == null || item.businessScopeId != businessScopeId) {
      return BusinessCatalogInventoryReservationExpireResult.failure;
    }

    final nextReserved = item.reservedQuantity - reservation.quantity;
    final updateResult = _inventoryInMemory.setQuantitiesForLifecycle(
      inventoryItemId: item.inventoryItemId,
      onHandQuantity: item.onHandQuantity,
      reservedQuantity: nextReserved,
    );
    if (updateResult != CatalogInventoryLifecycleQuantityResult.success) {
      return BusinessCatalogInventoryReservationExpireResult.failure;
    }

    _updateReservationStatus(
      reservationId,
      BusinessCatalogInventoryReservationStatus.expired,
    );
    _appendHistory(
      reservationId,
      BusinessCatalogInventoryReservationLifecycleEvent(
        eventId: _nextEventId(),
        reservationId: reservationId,
        action: BusinessCatalogInventoryReservationLifecycleAction.expire,
        statusBefore: BusinessCatalogInventoryReservationStatus.reserved,
        statusAfter: BusinessCatalogInventoryReservationStatus.expired,
        quantity: reservation.quantity,
        recordedAt: timestamp,
        reason: 'Expired in demo preview',
      ),
    );
    return BusinessCatalogInventoryReservationExpireResult.success;
  }

  @override
  int expireAllDueReservations({DateTime? now}) {
    final timestamp = now ?? _clock();
    final due = listForCurrentScope(
      status: BusinessCatalogInventoryReservationStatus.reserved,
    ).where((r) => catalogReservationIsExpiredByTime(r, timestamp));

    var count = 0;
    for (final r in due) {
      if (expireReservation(reservationId: r.reservationId, now: timestamp) ==
          BusinessCatalogInventoryReservationExpireResult.success) {
        count++;
      }
    }
    return count;
  }

  @override
  BusinessCatalogInventoryReservationReconciliationReport reconcileReservedQuantities({
    DateTime? now,
  }) {
    final timestamp = now ?? _clock();
    final activeByItem = <String, int>{};
    for (final r in listForCurrentScope(
      status: BusinessCatalogInventoryReservationStatus.reserved,
    )) {
      if (catalogReservationIsExpiredByTime(r, timestamp)) {
        continue;
      }
      activeByItem[r.inventoryItemId] =
          (activeByItem[r.inventoryItemId] ?? 0) + r.quantity;
    }

    final discrepancies = <BusinessCatalogInventoryReservationReconciliationLine>[];
    for (final item in _inventoryRepository.listForCurrentScope()) {
      final expected = activeByItem[item.inventoryItemId] ?? 0;
      if (expected != item.reservedQuantity) {
        discrepancies.add(
          BusinessCatalogInventoryReservationReconciliationLine(
            inventoryItemId: item.inventoryItemId,
            expectedReservedQuantity: expected,
            actualReservedQuantity: item.reservedQuantity,
          ),
        );
      }
    }

    return BusinessCatalogInventoryReservationReconciliationReport(
      checkedAt: timestamp,
      discrepancies: discrepancies,
      isDemoAuditOnly: true,
    );
  }

  @override
  List<BusinessCatalogInventoryReservationLifecycleEvent> lifecycleHistory(
    String reservationId,
  ) {
    if (findById(reservationId) == null) {
      return const [];
    }
    final scopeHistory = _ensureScopeHistory();
    return List.unmodifiable(scopeHistory[reservationId] ?? const []);
  }

  BusinessCatalogInventoryReservation? _findByOperationReference(String opRef) {
    try {
      return _ensureScopeList().firstWhere(
        (r) =>
            r.operationReference == opRef &&
            (r.status == BusinessCatalogInventoryReservationStatus.reserved ||
                r.status == BusinessCatalogInventoryReservationStatus.confirmed),
      );
    } on StateError {
      return null;
    }
  }

  void _updateReservationStatus(
    String reservationId,
    BusinessCatalogInventoryReservationStatus status,
  ) {
    final list = _ensureScopeList();
    final index = list.indexWhere((r) => r.reservationId == reservationId);
    if (index >= 0) {
      list[index] = list[index].copyWith(status: status);
    }
  }

  void _appendHistory(
    String reservationId,
    BusinessCatalogInventoryReservationLifecycleEvent event,
  ) {
    final scopeHistory = _ensureScopeHistory();
    scopeHistory.putIfAbsent(reservationId, () => []).add(event);
  }

  String _nextEventId() {
    _eventCounter++;
    return 'session-catalog-reservation-event-$_eventCounter';
  }

  List<BusinessCatalogInventoryReservation> _ensureScopeList() {
    return _byScope.putIfAbsent(businessScopeId, () => []);
  }

  Map<String, List<BusinessCatalogInventoryReservationLifecycleEvent>>
      _ensureScopeHistory() {
    return _historyByScope.putIfAbsent(businessScopeId, () => {});
  }
}
