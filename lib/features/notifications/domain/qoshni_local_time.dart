/// Clock time in local hours/minutes (demo quiet-hours use device-local interpretation).
class QoshniLocalTime {
  const QoshniLocalTime({
    required this.hour,
    required this.minute,
  }) : assert(hour >= 0 && hour <= 23),
       assert(minute >= 0 && minute <= 59);

  final int hour;
  final int minute;

  int get minutesSinceMidnight => hour * 60 + minute;

  @override
  bool operator ==(Object other) {
    return other is QoshniLocalTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  QoshniLocalTime copyWith({int? hour, int? minute}) {
    return QoshniLocalTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}
