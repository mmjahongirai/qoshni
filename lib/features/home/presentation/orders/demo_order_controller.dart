import 'package:flutter/foundation.dart';
import 'package:qoshni/features/home/presentation/cart/demo_order_snapshot.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_local_status.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_record.dart';

/// In-memory demo order history for the current session (not persisted).
class DemoOrderController extends ChangeNotifier {
  final List<DemoOrderRecord> _orders = [];
  final Set<String> _referenceIds = {};

  List<DemoOrderRecord> get orders => List<DemoOrderRecord>.unmodifiable(_orders);

  bool get isEmpty => _orders.isEmpty;

  int get orderCount => _orders.length;

  DemoOrderRecord? orderByReference(String referenceId) {
    for (final record in _orders) {
      if (record.snapshot.referenceId == referenceId) {
        return record;
      }
    }
    return null;
  }

  bool hasReference(String referenceId) => _referenceIds.contains(referenceId);

  /// Adds [snapshot] once. Returns `true` if newly recorded, `false` if duplicate.
  bool recordOrder(DemoOrderSnapshot snapshot) {
    if (_referenceIds.contains(snapshot.referenceId)) {
      return false;
    }
    _referenceIds.add(snapshot.referenceId);
    _orders.insert(
      0,
      DemoOrderRecord(snapshot: snapshot),
    );
    notifyListeners();
    return true;
  }

  void updateStatus(
    String referenceId,
    DemoOrderLocalStatus status,
  ) {
    final record = orderByReference(referenceId);
    if (record == null || record.status == status) {
      return;
    }
    record.status = status;
    notifyListeners();
  }
}
