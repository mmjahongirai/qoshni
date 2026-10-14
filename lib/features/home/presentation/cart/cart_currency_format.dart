import 'package:intl/intl.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';

String formatUzsGrouped(int amountUzs, String localeName) {
  return NumberFormat.decimalPattern(localeName).format(amountUzs);
}

String formatCartDemoMoney(AppLocalizations l10n, int amountUzs) {
  return l10n.cartDemoAmountUzs(formatUzsGrouped(amountUzs, l10n.localeName));
}
