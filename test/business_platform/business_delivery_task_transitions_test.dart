import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_task_transitions.dart';

void main() {
  group('allowed transitions', () {
    final cases = <BusinessDeliveryTaskStatus, List<BusinessDeliveryTaskStatus>>{
      BusinessDeliveryTaskStatus.created: [
        BusinessDeliveryTaskStatus.readyForPickup,
        BusinessDeliveryTaskStatus.cancelled,
      ],
      BusinessDeliveryTaskStatus.readyForPickup: [
        BusinessDeliveryTaskStatus.assigned,
        BusinessDeliveryTaskStatus.cancelled,
      ],
      BusinessDeliveryTaskStatus.assigned: [
        BusinessDeliveryTaskStatus.pickedUp,
        BusinessDeliveryTaskStatus.failed,
        BusinessDeliveryTaskStatus.cancelled,
      ],
      BusinessDeliveryTaskStatus.pickedUp: [
        BusinessDeliveryTaskStatus.inTransit,
        BusinessDeliveryTaskStatus.failed,
      ],
      BusinessDeliveryTaskStatus.inTransit: [
        BusinessDeliveryTaskStatus.delivered,
        BusinessDeliveryTaskStatus.failed,
      ],
      BusinessDeliveryTaskStatus.failed: [
        BusinessDeliveryTaskStatus.readyForPickup,
        BusinessDeliveryTaskStatus.cancelled,
      ],
    };

    for (final entry in cases.entries) {
      for (final to in entry.value) {
        test('${entry.key.name} -> ${to.name}', () {
          expect(
            catalogDeliveryTaskTransitionAllowed(from: entry.key, to: to),
            isTrue,
          );
        });
      }
    }
  });

  test('terminal delivered has no outgoing transitions', () {
    for (final to in BusinessDeliveryTaskStatus.values) {
      expect(
        catalogDeliveryTaskTransitionAllowed(
          from: BusinessDeliveryTaskStatus.delivered,
          to: to,
        ),
        isFalse,
      );
    }
  });

  test('picked up cannot cancel', () {
    expect(
      catalogDeliveryTaskTransitionAllowed(
        from: BusinessDeliveryTaskStatus.pickedUp,
        to: BusinessDeliveryTaskStatus.cancelled,
      ),
      isFalse,
    );
  });

  test('in transit cannot cancel', () {
    expect(
      catalogDeliveryTaskTransitionAllowed(
        from: BusinessDeliveryTaskStatus.inTransit,
        to: BusinessDeliveryTaskStatus.cancelled,
      ),
      isFalse,
    );
  });

  test('same status is not allowed', () {
    expect(
      catalogDeliveryTaskTransitionAllowed(
        from: BusinessDeliveryTaskStatus.created,
        to: BusinessDeliveryTaskStatus.created,
      ),
      isFalse,
    );
  });
}
