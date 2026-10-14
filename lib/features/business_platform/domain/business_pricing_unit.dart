import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';

enum BusinessPricingUnit {
  perItem,
  perHour,
  perDay;

  String label(AppLocalizations l10n) {
    return switch (this) {
      BusinessPricingUnit.perItem => l10n.businessPricingUnitPerItem,
      BusinessPricingUnit.perHour => l10n.businessPricingUnitPerHour,
      BusinessPricingUnit.perDay => l10n.businessPricingUnitPerDay,
    };
  }

  static BusinessPricingUnit defaultFor(BusinessOfferingKind kind) {
    return switch (kind) {
      BusinessOfferingKind.product => BusinessPricingUnit.perItem,
      BusinessOfferingKind.service => BusinessPricingUnit.perHour,
      BusinessOfferingKind.rental => BusinessPricingUnit.perDay,
    };
  }
}
