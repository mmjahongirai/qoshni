import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_scope_kind.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_setting.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_value_type.dart';

List<QoshniPlatformConfigurationSetting>
    buildQoshniPlatformConfigurationDemoSeed() {
  final epoch = kDemoPlatformGovernanceEpoch;
  const actor = 'demo-platform-admin-operations';
  return [
    QoshniPlatformConfigurationSetting(
      settingKey: 'platform.demo.announcement_banner_enabled',
      categoryKey: 'platformConfigCategoryUx',
      descriptionKey: 'platformConfigAnnouncementBannerDesc',
      valueType: QoshniPlatformConfigurationValueType.booleanValue,
      scopeKind: QoshniPlatformConfigurationScopeKind.platformWide,
      currentValue: false,
      defaultValue: false,
      revision: 1,
      updatedAt: epoch,
      updatedByAdminReference: actor,
    ),
    QoshniPlatformConfigurationSetting(
      settingKey: 'platform.demo.support_queue_display_threshold',
      categoryKey: 'platformConfigCategorySupport',
      descriptionKey: 'platformConfigSupportThresholdDesc',
      valueType: QoshniPlatformConfigurationValueType.integerValue,
      scopeKind: QoshniPlatformConfigurationScopeKind.platformWide,
      currentValue: 10,
      defaultValue: 10,
      minInt: 1,
      maxInt: 100,
      revision: 1,
      updatedAt: epoch,
      updatedByAdminReference: actor,
    ),
    QoshniPlatformConfigurationSetting(
      settingKey: 'platform.demo.moderation_queue_refresh_seconds',
      categoryKey: 'platformConfigCategoryModeration',
      descriptionKey: 'platformConfigModerationRefreshDesc',
      valueType: QoshniPlatformConfigurationValueType.integerValue,
      scopeKind: QoshniPlatformConfigurationScopeKind.platformWide,
      currentValue: 30,
      defaultValue: 30,
      minInt: 15,
      maxInt: 300,
      revision: 1,
      updatedAt: epoch,
      updatedByAdminReference: actor,
    ),
    QoshniPlatformConfigurationSetting(
      settingKey: 'platform.demo.feature_flag_synthetic_reviews',
      categoryKey: 'platformConfigCategoryFeatures',
      descriptionKey: 'platformConfigFeatureFlagReviewsDesc',
      valueType: QoshniPlatformConfigurationValueType.booleanValue,
      scopeKind: QoshniPlatformConfigurationScopeKind.platformWide,
      currentValue: true,
      defaultValue: false,
      revision: 1,
      updatedAt: epoch,
      updatedByAdminReference: actor,
    ),
    QoshniPlatformConfigurationSetting(
      settingKey: 'platform.demo.business_a_banner_enabled',
      categoryKey: 'platformConfigCategoryUx',
      descriptionKey: 'platformConfigBusinessBannerDesc',
      valueType: QoshniPlatformConfigurationValueType.booleanValue,
      scopeKind: QoshniPlatformConfigurationScopeKind.business,
      businessReference: kDemoPlatformGovernanceBusinessA,
      currentValue: false,
      defaultValue: false,
      revision: 1,
      updatedAt: epoch,
      updatedByAdminReference: actor,
    ),
    QoshniPlatformConfigurationSetting(
      settingKey: 'platform.restricted.payment_provider_mode',
      categoryKey: 'platformConfigCategoryRestricted',
      descriptionKey: 'platformConfigRestrictedPaymentDesc',
      valueType: QoshniPlatformConfigurationValueType.booleanValue,
      scopeKind: QoshniPlatformConfigurationScopeKind.platformWide,
      currentValue: false,
      defaultValue: false,
      revision: 1,
      updatedAt: epoch,
      updatedByAdminReference: actor,
      isHighRiskRestricted: true,
    ),
  ];
}
