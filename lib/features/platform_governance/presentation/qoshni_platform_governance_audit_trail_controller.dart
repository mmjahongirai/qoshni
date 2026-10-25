import 'package:flutter/foundation.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_event.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_outcome.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_audit_repository.dart';

class QoshniPlatformGovernanceAuditTrailController extends ChangeNotifier {
  QoshniPlatformGovernanceAuditTrailController({
    required QoshniPlatformGovernanceAuditRepository auditRepository,
    required QoshniPlatformGovernanceAuthorizer authorizer,
  })  : _auditRepository = auditRepository,
        _authorizer = authorizer;

  final QoshniPlatformGovernanceAuditRepository _auditRepository;
  final QoshniPlatformGovernanceAuthorizer _authorizer;

  QoshniPlatformGovernanceAuditOutcome? outcomeFilter;
  QoshniPlatformGovernanceAuditEntityType? entityTypeFilter;
  String? selectedEventId;
  String? lastAccessDeniedReasonKey;

  List<QoshniPlatformGovernanceAuditEvent> eventsForViewer(String adminId) {
    final decision = _authorizer.authorize(
      adminId: adminId,
      permission: QoshniPlatformPermission.viewAuditRecords,
      resourceScope: const QoshniPlatformResourceScope.platform(),
      actionLabel: 'audit_list',
    );
    if (!decision.isAllowed) {
      lastAccessDeniedReasonKey = decision.reason.name;
      notifyListeners();
      return const [];
    }
    lastAccessDeniedReasonKey = null;
    return _auditRepository.list(
      entityType: entityTypeFilter,
      outcome: outcomeFilter,
    );
  }

  QoshniPlatformGovernanceAuditEvent? selectedEvent(String adminId) {
    final id = selectedEventId;
    if (id == null) {
      return null;
    }
    final events = eventsForViewer(adminId);
    for (final event in events) {
      if (event.auditEventId == id) {
        return event;
      }
    }
    return _auditRepository.find(id);
  }

  void setOutcomeFilter(QoshniPlatformGovernanceAuditOutcome? value) {
    outcomeFilter = value;
    notifyListeners();
  }

  void setEntityTypeFilter(QoshniPlatformGovernanceAuditEntityType? value) {
    entityTypeFilter = value;
    notifyListeners();
  }

  void selectEvent(String? auditEventId) {
    selectedEventId = auditEventId;
    notifyListeners();
  }
}
