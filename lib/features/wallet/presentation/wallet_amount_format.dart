import 'package:intl/intl.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';

/// Formats a server wallet amount for display.
///
/// QO'SHNI stores UZS as whole so'm in `*_minor` fields (as catalog prices
/// do), so the value is grouped but never divided, rounded, or recomputed.
String formatWalletAmount(
  AppLocalizations l10n,
  int amountMinor,
  String currencyCode,
) {
  final grouped = NumberFormat.decimalPattern(l10n.localeName).format(amountMinor);
  if (currencyCode == 'UZS') {
    return l10n.walletAmountUzs(grouped);
  }
  return '$grouped $currencyCode';
}
