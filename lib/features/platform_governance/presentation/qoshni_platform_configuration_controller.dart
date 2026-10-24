import 'package:flutter/foundation.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_audit_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_workflow_audit.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_write_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_mutation_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_setting.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_entity_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_audit_operation_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_configuration_repository.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_configuration_validation.dart';

class QoshniPlatformConfigurationController extends ChangeNotifier {
  QoshniPlatformConfigurationController({
    required QoshniPlatformConfigurationRepository repository,
    required QoshniPlatformGovernanceRepository governanceRepository,
    required QoshniPlatformGovernanceAuthorizer authorizer,
    QoshniPlatformGovernanceAuditService? auditService,
  })  : _repository = repository,
        _governanceRepository = governanceRepository,
        _authorizer = authorizer,
        _workflowAudit = QoshniPlatformGovernanceWorkflowAudit(auditService);

  final QoshniPlatformConfigurationRepository _repository;
  final QoshniPlatformGovernanceRepository _governanceRepository;
  final QoshniPlatformGovernanceAuthorizer _authorizer;
  final QoshniPlatformGovernanceWorkflowAudit _workflowAudit;

  String? selectedSettingKey;
  QoshniPlatformGovernanceWriteResult? lastWriteResult;
  String? lastAccessDeniedReasonKey;

  List<QoshniPlatformConfigurationSetting> settingsForViewer(String adminId) {
    final decision = _authorizer.authorize(
      adminId: adminId,
      permission: QoshniPlatformPermission.viewPlatformConfiguration,
      resourceScope: const QoshniPlatformResourceScope.platform(),
      actionLabel: 'configuration_list',
    );
    if (!decision.isAllowed) {
      lastAccessDeniedReasonKey = decision.reason.name;
      notifyListeners();
      return const [];
    }
    lastAccessDeniedReasonKey = null;
    return _repository.listSettings();
  }

  QoshniPlatformConfigurationSetting? get selectedSetting {
    final key = selectedSettingKey;
    if (key == null) {
      return null;
    }
    return _repository.findSetting(key);
  }

  void selectSetting(String? settingKey) {
    selectedSettingKey = settingKey;
    notifyListeners();
  }

  QoshniPlatformGovernanceWriteResult updateBooleanSetting({
    required String adminId,
    required String settingKey,
    required bool newValue,
    required String reasonCode,
    required DateTime atUtc,
  }) {
    return _updateSetting(
      adminId: adminId,
      settingKey: settingKey,
      newValue: newValue,
      reasonCode: reasonCode,
      atUtc: atUtc,
    );
  }

  QoshniPlatformGovernanceWriteResult updateIntegerSetting({
    required String adminId,
    required String settingKey,
    required int newValue,
    required String reasonCode,
    required DateTime atUtc,
  }) {
    return _updateSetting(
      adminId: adminId,
      settingKey: settingKey,
      newValue: newValue,
      reasonCode: reasonCode,
      atUtc: atUtc,
    );
  }

  QoshniPlatformGovernanceWriteResult _updateSetting({
    required String adminId,
    required String settingKey,
    required Object newValue,
    required String reasonCode,
    required DateTime atUtc,
  }) {
    lastWriteResult = null;
    final setting = _repository.findSetting(settingKey);
    if (setting == null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.notFound,
      );
    }
    if (reasonCode.trim().isEmpty) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final scope = setting.isPlatformWide
        ? const QoshniPlatformResourceScope.platform()
        : QoshniPlatformResourceScope(
            kind: QoshniPlatformResourceScopeKind.business,
            businessReference: setting.businessReference,
          );

    final decision = _authorizer.authorize(
      adminId: adminId,
      permission: QoshniPlatformPermission.manageLowRiskPlatformConfiguration,
      resourceScope: scope,
      actionLabel: 'configuration_update',
    );
    if (!decision.isAllowed) {
      _workflowAudit.recordAuthorizationDenied(
        adminId: adminId,
        operationType:
            QoshniPlatformGovernanceAuditOperationType.configurationUpdate,
        entityType: QoshniPlatformGovernanceAuditEntityType.platformConfiguration,
        targetReference: settingKey,
        permission: QoshniPlatformPermission.manageLowRiskPlatformConfiguration,
        decision: decision,
        correlationReference:
            'cfg-deny-$settingKey-${atUtc.toIso8601String()}',
        safeSummary: 'Denied configuration update (demo).',
        recordedAtUtc: atUtc,
        scope: scope,
      );
      lastWriteResult = QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.authorizationDenied,
        authorizationDecision: decision,
      );
      notifyListeners();
      return lastWriteResult!;
    }

    final actor = _governanceRepository.findAdmin(adminId)?.syntheticReference;
    if (actor == null) {
      return const QoshniPlatformGovernanceWriteResult(
        outcome: QoshniPlatformGovernanceWriteOutcome.invalidInput,
      );
    }

    final mutation = _repository.updateSetting(
      settingKey: settingKey,
      newValue: newValue,
      actorAdminReference: actor,
      reasonCode: reasonCode,
      updatedAtUtc: atUtc,
      businessReferenceForScope: setting.businessReference,
    );

    final writeOutcome = switch (mutation) {
      QoshniPlatformConfigurationMutationResult.success =>
        QoshniPlatformGovernanceWriteOutcome.success,
      QoshniPlatformConfigurationMutationResult.restrictedSetting ||
      QoshniPlatformConfigurationMutationResult.secretLikeValueRejected ||
      QoshniPlatformConfigurationMutationResult.scopeMismatch ||
      QoshniPlatformConfigurationMutationResult.invalidInput =>
        QoshniPlatformGovernanceWriteOutcome.invalidInput,
      QoshniPlatformConfigurationMutationResult.notFound =>
        QoshniPlatformGovernanceWriteOutcome.notFound,
      QoshniPlatformConfigurationMutationResult.failure =>
        QoshniPlatformGovernanceWriteOutcome.failure,
    };

    lastWriteResult = _workflowAudit.finalizeMutation(
      adminId: adminId,
      operationType:
          QoshniPlatformGovernanceAuditOperationType.configurationUpdate,
      entityType: QoshniPlatformGovernanceAuditEntityType.platformConfiguration,
      targetReference: settingKey,
      permission: QoshniPlatformPermission.manageLowRiskPlatformConfiguration,
      decision: decision,
      mutationSucceeded:
          writeOutcome == QoshniPlatformGovernanceWriteOutcome.success,
      baseOutcome: writeOutcome,
      correlationReference: 'cfg-$settingKey-${atUtc.toIso8601String()}',
      safeSummary: 'Configuration update (demo).',
      recordedAtUtc: atUtc,
      scope: scope,
    );
    notifyListeners();
    return lastWriteResult!;
  }

  bool looksSecretLike(Object value) =>
      qoshniPlatformConfigurationValueLooksSecretLike(value);
}
