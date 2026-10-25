import 'package:intl/intl.dart';
import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';

String formatQoshniLocalTime(QoshniLocalTime time, String locale) {
  final dt = DateTime(2000, 1, 1, time.hour, time.minute);
  return DateFormat.jm(locale).format(dt);
}

QoshniLocalTime qoshniLocalTimeFromDateTime(DateTime dateTime) {
  return QoshniLocalTime(hour: dateTime.hour, minute: dateTime.minute);
}
