import 'package:qoshni/features/business_platform/domain/business_delivery_proof_status.dart';

bool catalogDeliveryProofTransitionAllowed({
  required BusinessDeliveryProofStatus from,
  required BusinessDeliveryProofStatus to,
}) {
  if (from == to) {
    return false;
  }
  if (businessDeliveryProofStatusTerminal(from)) {
    return false;
  }
  switch (from) {
    case BusinessDeliveryProofStatus.pending:
      return to == BusinessDeliveryProofStatus.verified ||
          to == BusinessDeliveryProofStatus.rejected ||
          to == BusinessDeliveryProofStatus.superseded;
    case BusinessDeliveryProofStatus.verified:
    case BusinessDeliveryProofStatus.rejected:
    case BusinessDeliveryProofStatus.superseded:
      return false;
  }
}
