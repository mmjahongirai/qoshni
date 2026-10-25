import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_audit_trail_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_labels.dart';
import 'package:qoshni/features/platform_governance/presentation/widgets/platform_governance_active_admin_field.dart';

class PlatformGovernanceAuditTrailPage extends StatefulWidget {
  const PlatformGovernanceAuditTrailPage({super.key});

  @override
  State<PlatformGovernanceAuditTrailPage> createState() =>
      _PlatformGovernanceAuditTrailPageState();
}

class _PlatformGovernanceAuditTrailPageState
    extends State<PlatformGovernanceAuditTrailPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final audit = getIt<QoshniPlatformGovernanceAuditTrailController>();
    final governance = getIt<QoshniPlatformGovernanceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.platformGovernanceAuditTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([audit, governance]),
          builder: (context, _) {
            final events = audit.eventsForViewer(governance.activeAdminId);
            final denied = audit.lastAccessDeniedReasonKey;
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
                if (denied != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppMessageBanner(
                    message: l10n.platformGovernanceAccessDenied,
                    icon: Icons.lock_outline,
                    tone: AppMessageTone.info,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                if (events.isEmpty)
                  Text(l10n.platformGovernanceAuditEmpty)
                else
                  ...events.map(
                    (event) => AppSurfaceCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        selected: audit.selectedEventId == event.auditEventId,
                        title: Text(event.auditEventId),
                        subtitle: Text(
                          '${event.safeSummary}\n${qoshniPlatformPermissionLabel(l10n, event.permission)}',
                        ),
                        isThreeLine: true,
                        trailing: event.isSeedRecord
                            ? Chip(label: Text(l10n.platformGovernanceSeedBadge))
                            : null,
                        onTap: () => audit.selectEvent(event.auditEventId),
                      ),
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
