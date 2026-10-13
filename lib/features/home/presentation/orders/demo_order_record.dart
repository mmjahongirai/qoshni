import 'package:qoshni/features/home/presentation/cart/demo_order_snapshot.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_local_status.dart';

class DemoOrderRecord {
  DemoOrderRecord({
    required this.snapshot,
    this.status = DemoOrderLocalStatus.preparedNotSent,
  });

  final DemoOrderSnapshot snapshot;
  DemoOrderLocalStatus status;
}
