import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_revision.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_setting.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_mutation_result.dart';

abstract class QoshniPlatformConfigurationRepository {
  List<QoshniPlatformConfigurationSetting> listSettings();

  QoshniPlatformConfigurationSetting? findSetting(String settingKey);

  List<QoshniPlatformConfigurationRevision> revisionHistory(String settingKey);

  QoshniPlatformConfigurationMutationResult updateSetting({
    required String settingKey,
    required Object newValue,
    required String actorAdminReference,
    required String reasonCode,
    required DateTime updatedAtUtc,
    String? businessReferenceForScope,
  });
}
