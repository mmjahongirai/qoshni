import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_moderation_queue_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_labels.dart';
import 'package:qoshni/features/platform_governance/presentation/widgets/platform_governance_active_admin_field.dart';

class PlatformModerationQueuePage extends StatelessWidget {
  const PlatformModerationQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queue = getIt<QoshniPlatformModerationQueueController>();
    final governance = getIt<QoshniPlatformGovernanceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.platformModerationTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([queue, governance]),
          builder: (context, _) {
            final selected = queue.selectedCase;
            final feedback = queue.lastWriteResult;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AppMessageBanner(
                  message: l10n.platformGovernanceWorkflowDisclaimer,
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
                for (final item in queue.cases)
                  AppSurfaceCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      selected: queue.selectedCaseId == item.caseId,
                      title: Text(item.caseId),
                      subtitle: Text(
                        '${qoshniPlatformModerationStatusLabel(l10n, item.status)}\n${item.safeSummary}',
                      ),
                      isThreeLine: true,
                      onTap: () => queue.selectCase(item.caseId),
                    ),
                  ),
                if (selected != null &&
                    selected.status ==
                        QoshniPlatformModerationCaseStatus.pending)
                  FilledButton(
                    onPressed: () => queue.transitionSelected(
                      adminId: governance.activeAdminId,
                      toStatus: QoshniPlatformModerationCaseStatus.underReview,
                      reasonCode: 'triage',
                      atUtc: DateTime.now().toUtc(),
                    ),
                    child: Text(l10n.platformModActionBeginReview),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
