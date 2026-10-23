import 'package:intl/intl.dart';

String formatQoshniNotificationTimestamp(DateTime utc, String locale) {
  final local = utc.toLocal();
  return DateFormat.yMMMd(locale).add_jm().format(local);
}
