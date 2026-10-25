import 'package:qoshni/features/platform_governance/data/qoshni_platform_configuration_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_mutation_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_revision.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_scope_kind.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_setting.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_configuration_repository.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_configuration_validation.dart';

class InMemoryQoshniPlatformConfigurationRepository
    implements QoshniPlatformConfigurationRepository {
  InMemoryQoshniPlatformConfigurationRepository({
    List<QoshniPlatformConfigurationSetting>? seed,
  }) : _settings = (seed ?? buildQoshniPlatformConfigurationDemoSeed())
            .map(_cloneSetting)
            .toList(growable: true),
       _revisions = {};

  final List<QoshniPlatformConfigurationSetting> _settings;
  final Map<String, List<QoshniPlatformConfigurationRevision>> _revisions;

  bool failNextMutation = false;

  static QoshniPlatformConfigurationSetting _cloneSetting(
    QoshniPlatformConfigurationSetting setting,
  ) {
    return QoshniPlatformConfigurationSetting(
      settingKey: setting.settingKey,
      categoryKey: setting.categoryKey,
      descriptionKey: setting.descriptionKey,
      valueType: setting.valueType,
      scopeKind: setting.scopeKind,
      currentValue: setting.currentValue,
      defaultValue: setting.defaultValue,
      revision: setting.revision,
      updatedAt: setting.updatedAt,
      updatedByAdminReference: setting.updatedByAdminReference,
      businessReference: setting.businessReference,
      minInt: setting.minInt,
      maxInt: setting.maxInt,
      isHighRiskRestricted: setting.isHighRiskRestricted,
    );
  }

  @override
  List<QoshniPlatformConfigurationSetting> listSettings() {
    return List.unmodifiable(_settings);
  }

  @override
  QoshniPlatformConfigurationSetting? findSetting(String settingKey) {
    for (final setting in _settings) {
      if (setting.settingKey == settingKey) {
        return setting;
      }
    }
    return null;
  }

  @override
  List<QoshniPlatformConfigurationRevision> revisionHistory(String settingKey) {
    final history = _revisions[settingKey];
    if (history == null) {
      return const [];
    }
    return List.unmodifiable(history);
  }

  @override
  QoshniPlatformConfigurationMutationResult updateSetting({
    required String settingKey,
    required Object newValue,
    required String actorAdminReference,
    required String reasonCode,
    required DateTime updatedAtUtc,
    String? businessReferenceForScope,
  }) {
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformConfigurationMutationResult.failure;
    }
    final index = _settings.indexWhere((s) => s.settingKey == settingKey);
    if (index < 0) {
      return QoshniPlatformConfigurationMutationResult.notFound;
    }
    final existing = _settings[index];
    if (existing.isHighRiskRestricted) {
      return QoshniPlatformConfigurationMutationResult.restrictedSetting;
    }
    if (existing.scopeKind == QoshniPlatformConfigurationScopeKind.business) {
      if (businessReferenceForScope == null ||
          businessReferenceForScope != existing.businessReference) {
        return QoshniPlatformConfigurationMutationResult.scopeMismatch;
      }
    }
    if (reasonCode.trim().isEmpty || actorAdminReference.trim().isEmpty) {
      return QoshniPlatformConfigurationMutationResult.invalidInput;
    }
    final validationError =
        qoshniPlatformConfigurationValueValidationError(existing, newValue);
    if (validationError == 'secretLikeValueRejected') {
      return QoshniPlatformConfigurationMutationResult.secretLikeValueRejected;
    }
    if (validationError != null) {
      return QoshniPlatformConfigurationMutationResult.invalidInput;
    }
    if (existing.currentValue == newValue) {
      return QoshniPlatformConfigurationMutationResult.invalidInput;
    }

    final nextRevision = existing.revision + 1;
    final revisionEntry = QoshniPlatformConfigurationRevision(
      settingKey: settingKey,
      revision: nextRevision,
      valueType: existing.valueType,
      previousValue: existing.currentValue,
      newValue: newValue,
      changedAt: updatedAtUtc.toUtc(),
      actorAdminReference: actorAdminReference,
      reasonCode: reasonCode.trim(),
    );
    _revisions.putIfAbsent(settingKey, () => []).add(revisionEntry);

    _settings[index] = QoshniPlatformConfigurationSetting(
      settingKey: existing.settingKey,
      categoryKey: existing.categoryKey,
      descriptionKey: existing.descriptionKey,
      valueType: existing.valueType,
      scopeKind: existing.scopeKind,
      currentValue: newValue,
      defaultValue: existing.defaultValue,
      revision: nextRevision,
      updatedAt: updatedAtUtc.toUtc(),
      updatedByAdminReference: actorAdminReference,
      businessReference: existing.businessReference,
      minInt: existing.minInt,
      maxInt: existing.maxInt,
      isHighRiskRestricted: existing.isHighRiskRestricted,
    );
    return QoshniPlatformConfigurationMutationResult.success;
  }
}
