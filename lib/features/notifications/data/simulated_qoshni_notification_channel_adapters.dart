import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel_adapter.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel_simulation_result.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_request.dart';

class SimulatedQoshniNotificationChannelAdapter
    implements QoshniNotificationChannelAdapter {
  SimulatedQoshniNotificationChannelAdapter(this.channel);

  @override
  final QoshniNotificationChannel channel;

  bool failNextSimulation = false;

  @override
  QoshniNotificationChannelSimulationResult simulate(
    QoshniNotificationDispatchRequest request,
  ) {
    if (failNextSimulation) {
      failNextSimulation = false;
      return QoshniNotificationChannelSimulationResult(
        status: QoshniNotificationChannelSimulationStatus.simulatedFailure,
        message:
            'Simulated $channel failure — no real provider was contacted.',
      );
    }

    final label = switch (channel) {
      QoshniNotificationChannel.inApp => 'in-app inbox',
      QoshniNotificationChannel.pushPreview => 'push preview',
      QoshniNotificationChannel.smsPreview => 'SMS preview',
      QoshniNotificationChannel.emailPreview => 'email preview',
    };

    return QoshniNotificationChannelSimulationResult(
      status: QoshniNotificationChannelSimulationStatus.simulatedSuccess,
      message:
          'Simulated $label delivery succeeded (demo only; not actually sent).',
    );
  }
}

Map<QoshniNotificationChannel, QoshniNotificationChannelAdapter>
    buildSimulatedQoshniNotificationChannelAdapters() {
  return {
    for (final channel in QoshniNotificationChannel.values)
      channel: SimulatedQoshniNotificationChannelAdapter(channel),
  };
}
