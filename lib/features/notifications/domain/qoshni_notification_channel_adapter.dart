import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel_simulation_result.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_request.dart';

abstract class QoshniNotificationChannelAdapter {
  QoshniNotificationChannel get channel;

  QoshniNotificationChannelSimulationResult simulate(
    QoshniNotificationDispatchRequest request,
  );
}
