class QoshniPlatformGovernanceHistoryEntry {
  const QoshniPlatformGovernanceHistoryEntry({
    required this.recordedAt,
    required this.actorAdminReference,
    required this.operation,
    required this.fromStatus,
    required this.toStatus,
    required this.reasonCode,
    required this.note,
  });

  final DateTime recordedAt;
  final String actorAdminReference;
  final String operation;
  final String fromStatus;
  final String toStatus;
  final String reasonCode;
  final String note;
}
