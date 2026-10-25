import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';

String? qoshniLocalTimeValidationError(QoshniLocalTime time) {
  if (time.hour < 0 || time.hour > 23) {
    return 'invalid_hour';
  }
  if (time.minute < 0 || time.minute > 59) {
    return 'invalid_minute';
  }
  return null;
}

String? qoshniQuietHoursValidationError({
  required QoshniLocalTime start,
  required QoshniLocalTime end,
}) {
  final startError = qoshniLocalTimeValidationError(start);
  if (startError != null) {
    return startError;
  }
  final endError = qoshniLocalTimeValidationError(end);
  if (endError != null) {
    return endError;
  }
  return null;
}
