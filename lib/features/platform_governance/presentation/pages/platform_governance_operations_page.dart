import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_operations_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_labels.dart';
import 'package:qoshni/features/platform_governance/presentation/widgets/platform_governance_active_admin_field.dart';

class PlatformGovernanceOperationsPage extends StatefulWidget {
  const PlatformGovernanceOperationsPage({super.key});

  @override
  State<PlatformGovernanceOperationsPage> createState() =>
      _PlatformGovernanceOperationsPageState();
}

class _PlatformGovernanceOperationsPageState
    extends State<PlatformGovernanceOperationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  void _refresh() {
    getIt<QoshniPlatformGovernanceOperationsController>().refresh(
      getIt<QoshniPlatformGovernanceController>().activeAdminId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ops = getIt<QoshniPlatformGovernanceOperationsController>();
    final governance = getIt<QoshniPlatformGovernanceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.platformGovernanceOperationsTitle),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.platformGovernanceOperationsRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([ops, governance]),
          builder: (context, _) {
            final summary = ops.summary;
            final denied = ops.lastAccessDeniedReasonKey;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AppMessageBanner(
                  message: l10n.platformGovernancePhase15Disclaimer,
                  icon: Icons.warning_amber_outlined,
                  tone: AppMessageTone.warning,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.platformGovernanceOperationsSyntheticNotice,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                PlatformGovernanceActiveAdminField(
                  governanceController: governance,
                ),
                if (denied != null)
                  AppMessageBanner(
                    message: l10n.platformGovernanceAccessDenied,
                    icon: Icons.lock_outline,
                    tone: AppMessageTone.info,
                  )
                else if (summary == null)
                  Text(l10n.platformGovernanceOperationsEmpty)
                else ...[
                  AppSurfaceCard(
                    child: ListTile(
                      title: Text(l10n.platformGovernanceOperationsAsOf),
                      subtitle: Text(summary.asOfUtc.toIso8601String()),
                    ),
                  ),
                  AppSurfaceCard(
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    child: ListTile(
                      title: Text(l10n.platformGovernanceOperationsPendingApprovals),
                      trailing: Text('${summary.pendingApprovalCount}'),
                    ),
                  ),
                  AppSurfaceCard(
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    child: ListTile(
                      title: Text(
                        l10n.platformGovernanceOperationsConfigRevisions,
                      ),
                      trailing: Text(
                        '${summary.recentConfigurationRevisions}',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.platformGovernanceOperationsVerificationSection,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  for (final entry in summary.verificationByStatus.entries)
                    if (entry.value > 0)
                      Text(
                        '${qoshniPlatformBusinessVerificationStatusLabel(l10n, entry.key)}: ${entry.value}',
                      ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.platformGovernanceOperationsModerationSection,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  for (final entry in summary.moderationByStatus.entries)
                    if (entry.value > 0)
                      Text(
                        '${qoshniPlatformModerationStatusLabel(l10n, entry.key)}: ${entry.value}',
                      ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
