import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_proposal_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request_status.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_approval_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_labels.dart';
import 'package:qoshni/features/platform_governance/presentation/widgets/platform_governance_active_admin_field.dart';

class PlatformGovernanceApprovalsPage extends StatelessWidget {
  const PlatformGovernanceApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final approvals = getIt<QoshniPlatformApprovalController>();
    final governance = getIt<QoshniPlatformGovernanceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.platformGovernanceApprovalsTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([approvals, governance]),
          builder: (context, _) {
            final feedback = approvals.lastWriteResult;
            final selected = approvals.selectedRequest;
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
                  l10n.platformGovernanceApprovalNoExecutionNotice,
                  style: Theme.of(context).textTheme.bodySmall,
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
                FilledButton(
                  onPressed: () => approvals.createProposal(
                    adminId: governance.activeAdminId,
                    proposalType: QoshniPlatformApprovalProposalType
                        .hypotheticalWalletAdjustment,
                    targetReference: 'demo-wallet-ledger-synthetic-new',
                    reasonCode: 'demo_proposal',
                    atUtc: DateTime.now().toUtc(),
                  ),
                  child: Text(l10n.platformGovernanceApprovalCreateAction),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final request in approvals.requests)
                  AppSurfaceCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      selected:
                          approvals.selectedRequestId == request.requestId,
                      title: Text(request.requestId),
                      subtitle: Text(
                        '${request.status.name}\n${request.targetReference}',
                      ),
                      isThreeLine: true,
                      onTap: () => approvals.selectRequest(request.requestId),
                    ),
                  ),
                if (selected != null &&
                    selected.status ==
                        QoshniPlatformApprovalRequestStatus.pending) ...[
                  OutlinedButton(
                    onPressed: () => approvals.decideSelected(
                      adminId: governance.activeAdminId,
                      toStatus: QoshniPlatformApprovalRequestStatus.approved,
                      decisionReasonCode: 'demo_approve',
                      atUtc: DateTime.now().toUtc(),
                    ),
                    child: Text(l10n.platformGovernanceApprovalApproveAction),
                  ),
                  OutlinedButton(
                    onPressed: () => approvals.decideSelected(
                      adminId: governance.activeAdminId,
                      toStatus: QoshniPlatformApprovalRequestStatus.rejected,
                      decisionReasonCode: 'demo_reject',
                      atUtc: DateTime.now().toUtc(),
                    ),
                    child: Text(l10n.platformGovernanceApprovalRejectAction),
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
