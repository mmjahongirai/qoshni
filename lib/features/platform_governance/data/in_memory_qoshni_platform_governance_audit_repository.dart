import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_audit_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_event.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_outcome.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_audit_repository.dart';

class InMemoryQoshniPlatformGovernanceAuditRepository
    implements QoshniPlatformGovernanceAuditRepository {
  InMemoryQoshniPlatformGovernanceAuditRepository({
    List<QoshniPlatformGovernanceAuditEvent>? seed,
  }) : _events = List.of(seed ?? buildQoshniPlatformGovernanceAuditDemoSeed());

  final List<QoshniPlatformGovernanceAuditEvent> _events;
  final Set<String> _correlationReferences = {};
  final Set<String> _eventIds = {};

  bool failNextAppend = false;

  void _indexExisting() {
    _correlationReferences.clear();
    _eventIds.clear();
    for (final event in _events) {
      _eventIds.add(event.auditEventId);
      if (event.correlationReference.isNotEmpty) {
        _correlationReferences.add(event.correlationReference);
      }
    }
  }

  @override
  List<QoshniPlatformGovernanceAuditEvent> list({
    String? actorAdminReference,
    QoshniPlatformGovernanceAuditOperationType? operationType,
    QoshniPlatformGovernanceAuditEntityType? entityType,
    QoshniPlatformGovernanceAuditOutcome? outcome,
    DateTime? recordedAfterUtc,
    DateTime? recordedBeforeUtc,
  }) {
    _indexExisting();
    final filtered = _events.where((event) {
      if (actorAdminReference != null &&
          event.actorAdminReference != actorAdminReference) {
        return false;
      }
      if (operationType != null && event.operationType != operationType) {
        return false;
      }
      if (entityType != null && event.entityType != entityType) {
        return false;
      }
      if (outcome != null && event.outcome != outcome) {
        return false;
      }
      if (recordedAfterUtc != null &&
          event.recordedAt.isBefore(recordedAfterUtc.toUtc())) {
        return false;
      }
      if (recordedBeforeUtc != null &&
          event.recordedAt.isAfter(recordedBeforeUtc.toUtc())) {
        return false;
      }
      return true;
    }).toList(growable: false);
    filtered.sort(
      (a, b) {
        final byTime = a.recordedAt.compareTo(b.recordedAt);
        if (byTime != 0) {
          return byTime;
        }
        return a.auditEventId.compareTo(b.auditEventId);
      },
    );
    return filtered;
  }

  @override
  QoshniPlatformGovernanceAuditEvent? find(String auditEventId) {
    for (final event in _events) {
      if (event.auditEventId == auditEventId) {
        return event;
      }
    }
    return null;
  }

  @override
  bool hasCorrelationReference(String correlationReference) {
    final normalized = correlationReference.trim();
    if (normalized.isEmpty) {
      return false;
    }
    return _events.any((e) => e.correlationReference == normalized);
  }

  @override
  QoshniPlatformGovernanceAuditAppendResult append(
    QoshniPlatformGovernanceAuditEvent event,
  ) {
    if (failNextAppend) {
      failNextAppend = false;
      return QoshniPlatformGovernanceAuditAppendResult.failure;
    }
    if (event.auditEventId.trim().isEmpty ||
        event.targetReference.trim().isEmpty ||
        event.correlationReference.trim().isEmpty ||
        event.safeSummary.trim().isEmpty) {
      return QoshniPlatformGovernanceAuditAppendResult.invalidInput;
    }
    if (_events.any((e) => e.auditEventId == event.auditEventId)) {
      return QoshniPlatformGovernanceAuditAppendResult.invalidInput;
    }
    if (hasCorrelationReference(event.correlationReference)) {
      return QoshniPlatformGovernanceAuditAppendResult
          .duplicateCorrelationReference;
    }
    _events.add(event);
    return QoshniPlatformGovernanceAuditAppendResult.success;
  }
}
