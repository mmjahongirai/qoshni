import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_role_labels.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessStaffListPage extends StatelessWidget {
  const BusinessStaffListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final staffController = getIt<BusinessStaffController>();
    final branchController = getIt<BusinessBranchController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.staffListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.businessStaffCreate),
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l10n.staffAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([staffController, branchController]),
          builder: (context, _) {
            final members = staffController.members;
            final branches = branchController.branches;
            String branchLabel(String id) {
              final match = branches.where((b) => b.branchId == id);
              if (match.isEmpty) {
                return id;
              }
              return match.first.name;
            }

            return ResponsiveLayout(
              phone: _StaffListBody(
                maxWidth: 520,
                l10n: l10n,
                members: members,
                branchLabel: branchLabel,
              ),
              tablet: _StaffListBody(
                maxWidth: 760,
                l10n: l10n,
                members: members,
                branchLabel: branchLabel,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StaffListBody extends StatelessWidget {
  const _StaffListBody({
    required this.maxWidth,
    required this.l10n,
    required this.members,
    required this.branchLabel,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessStaffMember> members;
  final String Function(String branchId) branchLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppMessageBanner(
                message: l10n.staffPreviewNotice,
                icon: Icons.info_outline,
                tone: AppMessageTone.info,
              ),
              const SizedBox(height: AppSpacing.md),
              if (members.isEmpty)
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.staffEmptyTitle,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.staffEmptyBody,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: () =>
                            context.push(RoutePaths.businessStaffCreate),
                        child: Text(l10n.staffAddAction),
                      ),
                    ],
                  ),
                )
              else
                for (final member in members)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _StaffTile(
                      member: member,
                      l10n: l10n,
                      branchLabel: branchLabel,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({
    required this.member,
    required this.l10n,
    required this.branchLabel,
  });

  final BusinessStaffMember member;
  final AppLocalizations l10n;
  final String Function(String branchId) branchLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final branchesText = member.assignedBranchIds.map(branchLabel).join(', ');

    return AppSurfaceCard(
      onTap: () => context.push(
        RoutePaths.businessStaffDetailPath(member.staffId),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  member.displayName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (member.isDemoSeed) const DemoContentBadge(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            staffRoleLabel(l10n, member.role),
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            member.contactPhone,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (member.contactEmail != null) ...[
            const SizedBox(height: 2),
            Text(
              member.contactEmail!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.staffBranchesLabel(branchesText),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            staffStatusLabel(l10n, member.status),
            style: textTheme.labelMedium?.copyWith(
              color: member.status == BusinessStaffMemberStatus.removedPreview
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          if (member.role != BusinessStaffRole.businessOwner) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(
                  RoutePaths.businessStaffEditPath(member.staffId),
                ),
                child: Text(l10n.staffEditAction),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
