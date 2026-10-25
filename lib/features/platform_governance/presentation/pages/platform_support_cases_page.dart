import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_support_case_status.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_support_case_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_workflow_labels.dart';
import 'package:qoshni/features/platform_governance/presentation/widgets/platform_governance_active_admin_field.dart';

class PlatformSupportCasesPage extends StatefulWidget {
  const PlatformSupportCasesPage({super.key});

  @override
  State<PlatformSupportCasesPage> createState() =>
      _PlatformSupportCasesPageState();
}

class _PlatformSupportCasesPageState extends State<PlatformSupportCasesPage> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cases = getIt<QoshniPlatformSupportCaseController>();
    final governance = getIt<QoshniPlatformGovernanceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.platformSupportCasesTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([cases, governance]),
          builder: (context, _) {
            final selected = cases.selectedCase;
            final feedback = cases.lastWriteResult;
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
                for (final item in cases.cases)
                  AppSurfaceCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      selected: cases.selectedCaseId == item.caseId,
                      title: Text(item.caseId),
                      subtitle: Text(
                        '${qoshniPlatformSupportStatusLabel(l10n, item.status)}\n${item.safeSummary}',
                      ),
                      isThreeLine: true,
                      onTap: () => cases.selectCase(item.caseId),
                    ),
                  ),
                if (selected != null) ...[
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: l10n.platformSupportNoteHint,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => cases.addNoteSelected(
                      adminId: governance.activeAdminId,
                      noteBody: _noteController.text,
                      noteId: 'note-${DateTime.now().millisecondsSinceEpoch}',
                      atUtc: DateTime.now().toUtc(),
                    ),
                    child: Text(l10n.platformSupportAddNoteAction),
                  ),
                  if (selected.status == QoshniPlatformSupportCaseStatus.open)
                    OutlinedButton(
                      onPressed: () => cases.assignSelected(
                        adminId: governance.activeAdminId,
                        roleKey: 'support_agent',
                        atUtc: DateTime.now().toUtc(),
                      ),
                      child: Text(l10n.platformSupportAssignAction),
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
