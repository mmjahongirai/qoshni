import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_value_type.dart';

class QoshniPlatformConfigurationRevision {
  const QoshniPlatformConfigurationRevision({
    required this.settingKey,
    required this.revision,
    required this.valueType,
    required this.previousValue,
    required this.newValue,
    required this.changedAt,
    required this.actorAdminReference,
    required this.reasonCode,
  });

  final String settingKey;
  final int revision;
  final QoshniPlatformConfigurationValueType valueType;
  final Object previousValue;
  final Object newValue;
  final DateTime changedAt;
  final String actorAdminReference;
  final String reasonCode;
}
