import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_labels.dart';
import 'package:qoshni/routing/route_paths.dart';

class PlatformAdminRolesPage extends StatefulWidget {
  const PlatformAdminRolesPage({super.key});

  @override
  State<PlatformAdminRolesPage> createState() => _PlatformAdminRolesPageState();
}

class _PlatformAdminRolesPageState extends State<PlatformAdminRolesPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<QoshniPlatformGovernanceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.platformAdminRolesTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final admins = controller.admins;
            final roles = controller.roles;
            final selectedRole = controller.selectedRole;
            final decision = controller.previewAuthorizationForSelectedAdmin();

            return ResponsiveLayout(
              phone: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  AppMessageBanner(
                    message: l10n.platformAdminGovernanceDisclaimer,
                    icon: Icons.admin_panel_settings_outlined,
                    tone: AppMessageTone.warning,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.platformAdminHighRiskBoundaryNotice,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppSurfaceCard(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(l10n.platformAdminNavBusinessVerification),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.pushNamed(
                            RouteNames.platformAdminBusinessVerification,
                          ),
                        ),
                        ListTile(
                          title: Text(l10n.platformAdminNavModeration),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.pushNamed(
                            RouteNames.platformAdminModeration,
                          ),
                        ),
                        ListTile(
                          title: Text(l10n.platformAdminNavSupportCases),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.pushNamed(
                            RouteNames.platformAdminSupportCases,
                          ),
                        ),
                        ListTile(
                          title: Text(l10n.platformAdminNavAudit),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.pushNamed(
                            RouteNames.platformAdminGovernanceAudit,
                          ),
                        ),
                        ListTile(
                          title: Text(l10n.platformAdminNavConfiguration),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.pushNamed(
                            RouteNames.platformAdminGovernanceConfiguration,
                          ),
                        ),
                        ListTile(
                          title: Text(l10n.platformAdminNavApprovals),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.pushNamed(
                            RouteNames.platformAdminGovernanceApprovals,
                          ),
                        ),
                        ListTile(
                          title: Text(l10n.platformAdminNavOperations),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.pushNamed(
                            RouteNames.platformAdminGovernanceOperations,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.platformAdminIdentitiesSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (admins.isEmpty)
                    Text(l10n.platformAdminIdentitiesEmpty)
                  else
                    ...admins.map(
                      (admin) => AppSurfaceCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          selected: controller.selectedAdminId == admin.adminId,
                          title: Text(admin.displayLabel),
                          subtitle: Text(
                            '${admin.syntheticReference}\n${qoshniPlatformAdminStatusLabel(l10n, admin.status)}',
                          ),
                          isThreeLine: true,
                          onTap: () => controller.selectAdmin(admin.adminId),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.platformAdminRolesSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (roles.isEmpty)
                    Text(l10n.platformAdminRolesEmpty)
                  else
                    ...roles.map(
                      (role) => AppSurfaceCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          selected: controller.selectedRoleId == role.roleId,
                          title: Text(qoshniPlatformRoleDisplayName(l10n, role)),
                          subtitle: Text(
                            '${qoshniPlatformRoleStatusLabel(l10n, role.status)}\n${role.permissionIds.length} ${l10n.platformAdminPermissionCountLabel}',
                          ),
                          isThreeLine: true,
                          onTap: () => controller.selectRole(role.roleId),
                        ),
                      ),
                    ),
                  if (selectedRole != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.platformAdminRoleDetailTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(qoshniPlatformRolePurpose(l10n, selectedRole)),
                    const SizedBox(height: AppSpacing.sm),
                    ...selectedRole.permissions.map(
                      (permission) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${qoshniPlatformPermissionLabel(l10n, permission)}',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.platformAdminAuthPreviewTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.platformAdminAuthPreviewHint),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<QoshniPlatformPermission>(
                    key: ValueKey(controller.previewPermission),
                    initialValue: controller.previewPermission,
                    decoration: InputDecoration(
                      labelText: l10n.platformAdminAuthPreviewPermissionLabel,
                    ),
                    items: QoshniPlatformPermission.values
                        .map(
                          (permission) => DropdownMenuItem(
                            value: permission,
                            child: Text(
                              qoshniPlatformPermissionLabel(l10n, permission),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setPreviewPermission(value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<QoshniPlatformResourceScopeKind>(
                    key: ValueKey(controller.previewScopeKind),
                    initialValue: controller.previewScopeKind,
                    decoration: InputDecoration(
                      labelText: l10n.platformAdminAuthPreviewScopeKindLabel,
                    ),
                    items: QoshniPlatformResourceScopeKind.values
                        .map(
                          (kind) => DropdownMenuItem(
                            value: kind,
                            child: Text(
                              switch (kind) {
                                QoshniPlatformResourceScopeKind.platform =>
                                  l10n.platformScopeKindPlatform,
                                QoshniPlatformResourceScopeKind.business =>
                                  l10n.platformScopeKindBusiness,
                                QoshniPlatformResourceScopeKind.branch =>
                                  l10n.platformScopeKindBranch,
                              },
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setPreviewScopeKind(value);
                      }
                    },
                  ),
                  if (controller.previewScopeKind !=
                      QoshniPlatformResourceScopeKind.platform) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      initialValue: controller.previewBusinessReference,
                      decoration: InputDecoration(
                        labelText: l10n.platformAdminAuthPreviewBusinessRefLabel,
                        hintText: kDemoPlatformGovernanceBusinessA,
                      ),
                      onChanged: controller.setPreviewBusinessReference,
                    ),
                  ],
                  if (controller.previewScopeKind ==
                      QoshniPlatformResourceScopeKind.branch) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      initialValue: controller.previewBranchReference,
                      decoration: InputDecoration(
                        labelText: l10n.platformAdminAuthPreviewBranchRefLabel,
                        hintText: kDemoPlatformGovernanceBranchA1,
                      ),
                      onChanged: controller.setPreviewBranchReference,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    initialValue: controller.previewActionLabel,
                    decoration: InputDecoration(
                      labelText: l10n.platformAdminAuthPreviewActionLabel,
                    ),
                    onChanged: controller.setPreviewActionLabel,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (controller.selectedAdmin == null)
                    Text(l10n.platformAdminAuthPreviewSelectAdmin)
                  else if (decision == null)
                    Text(l10n.platformAdminAuthPreviewError)
                  else
                    AppSurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              decision.isAllowed
                                  ? l10n.platformAdminAuthDecisionAllowed
                                  : l10n.platformAdminAuthDecisionDenied,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: decision.isAllowed
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              qoshniPlatformAuthorizationReasonLabel(
                                l10n,
                                decision.reason,
                              ),
                            ),
                            if (decision.matchedRoleId != null)
                              Text(
                                l10n.platformAdminAuthMatchedRole(
                                  decision.matchedRoleId!,
                                ),
                              ),
                            if (controller.selectedAdmin!.status ==
                                QoshniPlatformAdminStatus.suspended)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
                                child: Text(
                                  l10n.platformAdminSuspendedNotice,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
