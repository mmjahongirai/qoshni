import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_decision.dart';

enum QoshniPlatformGovernanceWriteOutcome {
  success,
  authorizationDenied,
  invalidInput,
  invalidTransition,
  notFound,
  failure,
  auditPersistFailure,
}

class QoshniPlatformGovernanceWriteResult {
  const QoshniPlatformGovernanceWriteResult({
    required this.outcome,
    this.authorizationDecision,
    this.auditRecorded = true,
  });

  final QoshniPlatformGovernanceWriteOutcome outcome;
  final QoshniPlatformAuthorizationDecision? authorizationDecision;

  /// False when an audit append was required but failed (in-memory demo).
  final bool auditRecorded;

  bool get isSuccess => outcome == QoshniPlatformGovernanceWriteOutcome.success;
}
