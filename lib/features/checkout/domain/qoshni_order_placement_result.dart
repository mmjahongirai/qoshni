enum QoshniOrderPlacementOutcome {
  unavailableBackend,
  unauthenticated,
  validationFailed,
  catalogUnavailable,
  staleQuote,
  outOfStock,
  idempotencyConflict,
  unsupportedMultiBusiness,
  success,
}

class QoshniOrderPlacementResult {
  const QoshniOrderPlacementResult({
    required this.outcome,
    this.serverOrderId,
    this.idempotentReplay = false,
    this.message,
  });

  final QoshniOrderPlacementOutcome outcome;
  final String? serverOrderId;
  final bool idempotentReplay;
  final String? message;

  bool get isServerConfirmed =>
      outcome == QoshniOrderPlacementOutcome.success && serverOrderId != null;
}
