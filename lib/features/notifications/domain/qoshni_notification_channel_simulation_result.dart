enum QoshniNotificationChannelSimulationStatus {
  simulatedSuccess,
  simulatedFailure,
}

class QoshniNotificationChannelSimulationResult {
  const QoshniNotificationChannelSimulationResult({
    required this.status,
    required this.message,
  });

  final QoshniNotificationChannelSimulationStatus status;
  final String message;

  bool get isSimulatedSuccess =>
      status == QoshniNotificationChannelSimulationStatus.simulatedSuccess;
}
