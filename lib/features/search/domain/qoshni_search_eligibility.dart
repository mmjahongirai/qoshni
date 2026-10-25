enum QoshniSearchEligibilityStatus {
  eligible,
  suspended,
  removed,
}

class QoshniSearchEligibility {
  const QoshniSearchEligibility({required this.status, this.reasonCode});

  const QoshniSearchEligibility.eligible()
      : status = QoshniSearchEligibilityStatus.eligible,
        reasonCode = null;

  final QoshniSearchEligibilityStatus status;
  final String? reasonCode;

  bool get isEligible => status == QoshniSearchEligibilityStatus.eligible;
}
