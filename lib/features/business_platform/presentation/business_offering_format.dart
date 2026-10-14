import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';
import 'package:qoshni/features/home/presentation/cart/cart_currency_format.dart';

String formatBusinessOfferingPriceLine(
  AppLocalizations l10n,
  BusinessProfileOffering offering,
) {
  final price = offering.samplePriceUzs;
  if (price == null) {
    return l10n.businessOfferingNoDemoPrice;
  }
  final unit = offering.pricingUnit.label(l10n);
  return l10n.businessOfferingDemoPriceLine(
    formatCartDemoMoney(l10n, price),
    unit,
  );
}

String? formatBusinessOfferingDepositLine(
  AppLocalizations l10n,
  BusinessProfileOffering offering,
) {
  final deposit = offering.demoDepositUzs;
  if (deposit == null) {
    return null;
  }
  return l10n.businessOfferingDemoDepositLine(
    formatCartDemoMoney(l10n, deposit),
  );
}
