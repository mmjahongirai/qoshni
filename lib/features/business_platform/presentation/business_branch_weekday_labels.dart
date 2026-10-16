import 'package:qoshni/core/localization/generated/app_localizations.dart';

String branchWeekdayLabel(AppLocalizations l10n, int weekday) {
  switch (weekday) {
    case 1:
      return l10n.branchWeekdayMonday;
    case 2:
      return l10n.branchWeekdayTuesday;
    case 3:
      return l10n.branchWeekdayWednesday;
    case 4:
      return l10n.branchWeekdayThursday;
    case 5:
      return l10n.branchWeekdayFriday;
    case 6:
      return l10n.branchWeekdaySaturday;
    case 7:
      return l10n.branchWeekdaySunday;
    default:
      return '';
  }
}
