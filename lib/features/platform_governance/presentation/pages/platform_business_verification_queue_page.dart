import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_business_verification_queue_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_labels.dart';
import 'package:qoshni/features/platform_governance/presentation/widgets/platform_governance_active_admin_field.dart';

class PlatformBusinessVerificationQueuePage extends StatefulWidget {
  const PlatformBusinessVerificationQueuePage({super.key});

  @override
  State<PlatformBusinessVerificationQueuePage> createState() =>
      _PlatformBusinessVerificationQueuePageState();
}

class _PlatformBusinessVerificationQueuePageState
    extends State<PlatformBusinessVerificationQueuePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queue = getIt<QoshniPlatformBusinessVerificationQueueController>();
    final governance = getIt<QoshniPlatformGovernanceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.platformBusinessVerificationTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([queue, governance]),
          builder: (context, _) {
            final selected = queue.selectedSubmission;
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
                const SizedBox(height: AppSpacing.md),
                if (feedback != null)
                  AppMessageBanner(
                    message: qoshniPlatformWorkflowWriteOutcomeMessage(
                      l10n,
                      feedback,
                    ),
                    icon: feedback.isSuccess
                        ? Icons.check_circle_outline
                        : Icons.block,
                    tone: feedback.isSuccess
                        ? AppMessageTone.info
                        : AppMessageTone.error,
                  ),
                const SizedBox(height: AppSpacing.sm),
                for (final submission in queue.submissions)
                  AppSurfaceCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      selected:
                          queue.selectedSubmissionId == submission.submissionId,
                      title: Text(submission.submissionId),
                      subtitle: Text(
                        '${qoshniPlatformBusinessVerificationStatusLabel(l10n, submission.status)}\n${submission.safeSummary}',
                      ),
                      isThreeLine: true,
                      onTap: () =>
                          queue.selectSubmission(submission.submissionId),
                    ),
                  ),
                if (selected != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.platformWorkflowHistoryTitle),
                  for (final entry in selected.history)
                    Text(
                      '${entry.operation} · ${entry.fromStatus} → ${entry.toStatus} · ${entry.reasonCode}',
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (selected.status ==
                          QoshniPlatformBusinessVerificationSubmissionStatus
                              .pending)
                        FilledButton(
                          onPressed: () => _transition(
                            queue,
                            governance.activeAdminId,
                            QoshniPlatformBusinessVerificationSubmissionStatus
                                .underReview,
                            'queue_triage',
                          ),
                          child: Text(l10n.platformBverActionBeginReview),
                        ),
                      if (selected.status ==
                          QoshniPlatformBusinessVerificationSubmissionStatus
                              .underReview) ...[
                        FilledButton(
                          onPressed: () => _transition(
                            queue,
                            governance.activeAdminId,
                            QoshniPlatformBusinessVerificationSubmissionStatus
                                .approved,
                            'demo_approve',
                          ),
                          child: Text(l10n.platformBverActionApprove),
                        ),
                        OutlinedButton(
                          onPressed: () => _transition(
                            queue,
                            governance.activeAdminId,
                            QoshniPlatformBusinessVerificationSubmissionStatus
                                .rejected,
                            'demo_reject',
                          ),
                          child: Text(l10n.platformBverActionReject),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _transition(
    QoshniPlatformBusinessVerificationQueueController queue,
    String adminId,
    QoshniPlatformBusinessVerificationSubmissionStatus to,
    String reason,
  ) {
    queue.transitionSelected(
      adminId: adminId,
      toStatus: to,
      reasonCode: reason,
      atUtc: DateTime.now().toUtc(),
    );
  }
}
