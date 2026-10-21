import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_category.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_severity.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_status.dart';

extension BusinessDeliveryExceptionLabels on AppLocalizations {
  String businessDeliveryExceptionCategoryLabel(
    BusinessDeliveryExceptionCategory category,
  ) {
    switch (category) {
      case BusinessDeliveryExceptionCategory.recipientUnavailable:
        return businessDeliveryExceptionCategoryRecipientUnavailable;
      case BusinessDeliveryExceptionCategory.addressOrLocationIssue:
        return businessDeliveryExceptionCategoryAddressIssue;
      case BusinessDeliveryExceptionCategory.accessBlocked:
        return businessDeliveryExceptionCategoryAccessBlocked;
      case BusinessDeliveryExceptionCategory.deliveryDelayed:
        return businessDeliveryExceptionCategoryDeliveryDelayed;
      case BusinessDeliveryExceptionCategory.itemOrPackageIssue:
        return businessDeliveryExceptionCategoryItemIssue;
      case BusinessDeliveryExceptionCategory.other:
        return businessDeliveryExceptionCategoryOther;
    }
  }

  String businessDeliveryExceptionStatusLabel(
    BusinessDeliveryExceptionStatus status,
  ) {
    switch (status) {
      case BusinessDeliveryExceptionStatus.open:
        return businessDeliveryExceptionStatusOpen;
      case BusinessDeliveryExceptionStatus.resolved:
        return businessDeliveryExceptionStatusResolved;
      case BusinessDeliveryExceptionStatus.dismissed:
        return businessDeliveryExceptionStatusDismissed;
    }
  }

  String businessDeliveryExceptionSeverityLabel(
    BusinessDeliveryExceptionSeverity severity,
  ) {
    switch (severity) {
      case BusinessDeliveryExceptionSeverity.low:
        return businessDeliveryExceptionSeverityLow;
      case BusinessDeliveryExceptionSeverity.medium:
        return businessDeliveryExceptionSeverityMedium;
      case BusinessDeliveryExceptionSeverity.high:
        return businessDeliveryExceptionSeverityHigh;
    }
  }
}
