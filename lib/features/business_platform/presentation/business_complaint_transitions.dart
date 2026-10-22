import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';

bool catalogBusinessComplaintTransitionAllowed({
  required BusinessComplaintStatus from,
  required BusinessComplaintStatus to,
}) {
  if (from == to) {
    return false;
  }
  switch (from) {
    case BusinessComplaintStatus.submitted:
      return to == BusinessComplaintStatus.underReview ||
          to == BusinessComplaintStatus.dismissed;
    case BusinessComplaintStatus.underReview:
      return to == BusinessComplaintStatus.resolved ||
          to == BusinessComplaintStatus.dismissed;
    case BusinessComplaintStatus.resolved:
    case BusinessComplaintStatus.dismissed:
      return false;
  }
}
