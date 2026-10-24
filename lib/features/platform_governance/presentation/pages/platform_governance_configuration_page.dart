import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_value_type.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_configuration_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_labels.dart';
import 'package:qoshni/features/platform_governance/presentation/widgets/platform_governance_active_admin_field.dart';

class PlatformGovernanceConfigurationPage extends StatelessWidget {
  const PlatformGovernanceConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = getIt<QoshniPlatformConfigurationController>();
    final governance = getIt<QoshniPlatformGovernanceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.platformGovernanceConfigurationTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([config, governance]),
          builder: (context, _) {
            final settings =
                config.settingsForViewer(governance.activeAdminId);
            final feedback = config.lastWriteResult;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AppMessageBanner(
                  message: l10n.platformGovernancePhase15Disclaimer,
                  icon: Icons.warning_amber_outlined,
                  tone: AppMessageTone.warning,
                ),
                const SizedBox(height: AppSpacing.md),
                PlatformGovernanceActiveAdminField(
                  governanceController: governance,
                ),
                if (feedback != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppMessageBanner(
                    message: qoshniPlatformWorkflowWriteOutcomeMessage(
                      l10n,
                      feedback,
                    ),
                    icon: Icons.info_outline,
                    tone: AppMessageTone.info,
                  ),
                ],
                for (final setting in settings)
                  AppSurfaceCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      title: Text(setting.settingKey),
                      subtitle: Text(
                        setting.isHighRiskRestricted
                            ? l10n.platformConfigRestrictedNotice
                            : '${l10n.platformConfigRevisionLabel(setting.revision)} — ${setting.currentValue}',
                      ),
                      isThreeLine: setting.isHighRiskRestricted,
                      trailing: setting.isHighRiskRestricted
                          ? const Icon(Icons.lock_outline)
                          : null,
                      onTap: setting.isHighRiskRestricted
                          ? null
                          : () {
                              config.selectSetting(setting.settingKey);
                              if (setting.valueType ==
                                  QoshniPlatformConfigurationValueType
                                      .booleanValue) {
                                config.updateBooleanSetting(
                                  adminId: governance.activeAdminId,
                                  settingKey: setting.settingKey,
                                  newValue: !(setting.currentValue as bool),
                                  reasonCode: 'demo_toggle',
                                  atUtc: DateTime.now().toUtc(),
                                );
                              }
                            },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
