import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_lifecycle_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_reconciliation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_reservation_repository.dart';

class BusinessCatalogInventoryReservationController extends ChangeNotifier {
  BusinessCatalogInventoryReservationController(this._repository);

  final BusinessCatalogInventoryReservationRepository _repository;

  bool _listLoading = true;
  bool _operationBusy = false;
  BusinessCatalogInventoryReservationReconciliationReport? _lastReconciliation;

  bool get listLoading => _listLoading;
  bool get operationBusy => _operationBusy;
  BusinessCatalogInventoryReservationReconciliationReport? get lastReconciliation =>
      _lastReconciliation;

  List<BusinessCatalogInventoryReservation> reservations({
    BusinessCatalogInventoryReservationStatus? status,
    String? branchId,
  }) =>
      _repository.listForCurrentScope(status: status, branchId: branchId);

  BusinessCatalogInventoryReservation? reservationById(String id) =>
      _repository.findById(id);

  List<BusinessCatalogInventoryReservationLifecycleEvent> historyFor(
    String reservationId,
  ) =>
      _repository.lifecycleHistory(reservationId);

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _repository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }

  Future<BusinessCatalogInventoryReservationReserveResult> reserve(
    BusinessCatalogInventoryReservationInput input,
  ) async {
    if (_operationBusy) {
      return BusinessCatalogInventoryReservationReserveResult.failure;
    }
    _operationBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.reserve(input: input);
    _operationBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogInventoryReservationReleaseResult> release(
    String reservationId,
  ) async {
    if (_operationBusy) {
      return BusinessCatalogInventoryReservationReleaseResult.failure;
    }
    _operationBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.release(reservationId: reservationId);
    _operationBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogInventoryReservationConfirmResult> confirm(
    String reservationId,
  ) async {
    if (_operationBusy) {
      return BusinessCatalogInventoryReservationConfirmResult.failure;
    }
    _operationBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.confirm(reservationId: reservationId);
    _operationBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessCatalogInventoryReservationExpireResult> expire(
    String reservationId,
  ) async {
    if (_operationBusy) {
      return BusinessCatalogInventoryReservationExpireResult.failure;
    }
    _operationBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.expireReservation(reservationId: reservationId);
    _operationBusy = false;
    notifyListeners();
    return result;
  }

  Future<int> expireAllDue() async {
    if (_operationBusy) {
      return 0;
    }
    _operationBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final count = _repository.expireAllDueReservations();
    _operationBusy = false;
    notifyListeners();
    return count;
  }

  Future<BusinessCatalogInventoryReservationReconciliationReport>
      runReconciliation() async {
    if (_operationBusy) {
      return _lastReconciliation ??
          BusinessCatalogInventoryReservationReconciliationReport(
            checkedAt: DateTime.now(),
            discrepancies: const [],
            isDemoAuditOnly: true,
          );
    }
    _operationBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _lastReconciliation = _repository.reconcileReservedQuantities();
    _operationBusy = false;
    notifyListeners();
    return _lastReconciliation!;
  }
}
