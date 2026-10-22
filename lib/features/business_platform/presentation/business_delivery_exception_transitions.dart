import 'package:qoshni/features/business_platform/domain/business_delivery_exception_status.dart';

bool catalogDeliveryExceptionTransitionAllowed({
  required BusinessDeliveryExceptionStatus from,
  required BusinessDeliveryExceptionStatus to,
}) {
  if (from == to) {
    return false;
  }
  switch (from) {
    case BusinessDeliveryExceptionStatus.open:
      return to == BusinessDeliveryExceptionStatus.resolved ||
          to == BusinessDeliveryExceptionStatus.dismissed;
    case BusinessDeliveryExceptionStatus.resolved:
    case BusinessDeliveryExceptionStatus.dismissed:
      return to == BusinessDeliveryExceptionStatus.open;
  }
}
