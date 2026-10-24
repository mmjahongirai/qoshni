import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_scope_kind.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_value_type.dart';

class QoshniPlatformConfigurationSetting {
  const QoshniPlatformConfigurationSetting({
    required this.settingKey,
    required this.categoryKey,
    required this.descriptionKey,
    required this.valueType,
    required this.scopeKind,
    required this.currentValue,
    required this.defaultValue,
    required this.revision,
    required this.updatedAt,
    required this.updatedByAdminReference,
    this.businessReference,
    this.minInt,
    this.maxInt,
    this.isHighRiskRestricted = false,
  });

  final String settingKey;
  final String categoryKey;
  final String descriptionKey;
  final QoshniPlatformConfigurationValueType valueType;
  final QoshniPlatformConfigurationScopeKind scopeKind;
  final Object currentValue;
  final Object defaultValue;
  final int revision;
  final DateTime updatedAt;
  final String updatedByAdminReference;
  final String? businessReference;
  final int? minInt;
  final int? maxInt;
  final bool isHighRiskRestricted;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;

  bool get isPlatformWide =>
      scopeKind == QoshniPlatformConfigurationScopeKind.platformWide;
}
