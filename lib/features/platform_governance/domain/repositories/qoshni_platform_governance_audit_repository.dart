import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_event.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_outcome.dart';

enum QoshniPlatformGovernanceAuditAppendResult {
  success,
  invalidInput,
  duplicateCorrelationReference,
  failure,
}

abstract class QoshniPlatformGovernanceAuditRepository {
  List<QoshniPlatformGovernanceAuditEvent> list({
    String? actorAdminReference,
    QoshniPlatformGovernanceAuditOperationType? operationType,
    QoshniPlatformGovernanceAuditEntityType? entityType,
    QoshniPlatformGovernanceAuditOutcome? outcome,
    DateTime? recordedAfterUtc,
    DateTime? recordedBeforeUtc,
  });

  QoshniPlatformGovernanceAuditEvent? find(String auditEventId);

  bool hasCorrelationReference(String correlationReference);

  QoshniPlatformGovernanceAuditAppendResult append(
    QoshniPlatformGovernanceAuditEvent event,
  );
}
