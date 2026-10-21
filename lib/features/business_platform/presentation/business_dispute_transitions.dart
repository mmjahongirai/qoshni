import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';

bool catalogBusinessDisputeTransitionAllowed({
  required BusinessDisputeStatus from,
  required BusinessDisputeStatus to,
}) {
  if (from == to) {
    return false;
  }
  switch (from) {
    case BusinessDisputeStatus.filed:
      return to == BusinessDisputeStatus.underReview ||
          to == BusinessDisputeStatus.dismissed;
    case BusinessDisputeStatus.underReview:
      return to == BusinessDisputeStatus.resolvedForBusiness ||
          to == BusinessDisputeStatus.resolvedForReporter ||
          to == BusinessDisputeStatus.dismissed;
    case BusinessDisputeStatus.resolvedForBusiness:
    case BusinessDisputeStatus.resolvedForReporter:
    case BusinessDisputeStatus.dismissed:
      return false;
  }
}
