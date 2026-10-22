import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';

extension BusinessFulfillmentTypeLabels on BusinessFulfillmentType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessFulfillmentType.delivery:
        return l10n.businessFulfillmentTypeDelivery;
      case BusinessFulfillmentType.pickup:
        return l10n.businessFulfillmentTypePickup;
      case BusinessFulfillmentType.serviceAtLocation:
        return l10n.businessFulfillmentTypeServiceAtLocation;
    }
  }
}

extension BusinessFulfillmentTargetScopeLabels on BusinessFulfillmentTargetScope {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessFulfillmentTargetScope.businessWide:
        return l10n.businessFulfillmentScopeBusinessWide;
      case BusinessFulfillmentTargetScope.product:
        return l10n.businessFulfillmentScopeProduct;
      case BusinessFulfillmentTargetScope.service:
        return l10n.businessFulfillmentScopeService;
    }
  }
}

String businessFulfillmentTypesPreviewLabel(
  AppLocalizations l10n,
  List<BusinessFulfillmentType> types,
) {
  if (types.isEmpty) {
    return l10n.businessFulfillmentPreviewEmpty;
  }
  return types.map((t) => t.label(l10n)).join(' · ');
}
