import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_method.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_status.dart';

extension BusinessDeliveryProofLabels on AppLocalizations {
  String businessDeliveryProofMethodLabel(BusinessDeliveryProofMethod method) {
    switch (method) {
      case BusinessDeliveryProofMethod.photo:
        return businessDeliveryProofMethodPhoto;
      case BusinessDeliveryProofMethod.recipientOtp:
        return businessDeliveryProofMethodRecipientOtp;
      case BusinessDeliveryProofMethod.signature:
        return businessDeliveryProofMethodSignature;
      case BusinessDeliveryProofMethod.recipientConfirmation:
        return businessDeliveryProofMethodRecipientConfirmation;
    }
  }

  String businessDeliveryProofStatusLabel(BusinessDeliveryProofStatus status) {
    switch (status) {
      case BusinessDeliveryProofStatus.pending:
        return businessDeliveryProofStatusPending;
      case BusinessDeliveryProofStatus.verified:
        return businessDeliveryProofStatusVerified;
      case BusinessDeliveryProofStatus.rejected:
        return businessDeliveryProofStatusRejected;
      case BusinessDeliveryProofStatus.superseded:
        return businessDeliveryProofStatusSuperseded;
    }
  }
}
