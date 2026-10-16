import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_weekday_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_owner_profile_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessBranchListPage extends StatelessWidget {
  const BusinessBranchListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final branchController = getIt<BusinessBranchController>();
    final ownerController = getIt<BusinessOwnerProfileController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.branchListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.businessBranchCreate),
        icon: const Icon(Icons.add),
        label: Text(l10n.branchAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([branchController, ownerController]),
          builder: (context, _) {
            final profile = ownerController.profile;
            final profileReady = profile.legalBusinessName.trim().isNotEmpty &&
                profile.displayName.trim().isNotEmpty;
            final branches = branchController.branches;

            return ResponsiveLayout(
              phone: _BranchListBody(
                maxWidth: 520,
                profileReady: profileReady,
                branches: branches,
                l10n: l10n,
              ),
              tablet: _BranchListBody(
                maxWidth: 760,
                profileReady: profileReady,
                branches: branches,
                l10n: l10n,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BranchListBody extends StatelessWidget {
  const _BranchListBody({
    required this.maxWidth,
    required this.profileReady,
    required this.branches,
    required this.l10n,
  });

  final double maxWidth;
  final bool profileReady;
  final List<BusinessBranch> branches;
  final AppLocalizations l10n;

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
                message: l10n.branchPreviewNotice,
                icon: Icons.info_outline,
                tone: AppMessageTone.info,
              ),
              if (!profileReady) ...[
                const SizedBox(height: AppSpacing.md),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppMessageBanner(
                        message: l10n.branchProfileIncompleteNotice,
                        icon: Icons.business_outlined,
                        tone: AppMessageTone.warning,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () =>
                              context.push(RoutePaths.businessOwnerProfile),
                          child: Text(l10n.branchOpenBusinessProfileAction),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (branches.isEmpty)
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.branchEmptyTitle,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.branchEmptyBody,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: () =>
                            context.push(RoutePaths.businessBranchCreate),
                        child: Text(l10n.branchAddAction),
                      ),
                    ],
                  ),
                )
              else
                for (final branch in branches)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _BranchListTile(branch: branch, l10n: l10n),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchListTile extends StatelessWidget {
  const _BranchListTile({
    required this.branch,
    required this.l10n,
  });

  final BusinessBranch branch;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final scheduleSummary = branch.scheduleSummary(
      weekdayLabel: (weekday) => weekday == 0
          ? l10n.branchScheduleClosedAllWeek
          : branchWeekdayLabel(l10n, weekday),
    );

    return AppSurfaceCard(
      onTap: () => context.push(
        RoutePaths.businessBranchDetailPath(branch.branchId),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  branch.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (branch.isDemoSeed) const DemoContentBadge(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${branch.city} · ${branch.addressLine}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _StatusChip(
                label: branch.isActive
                    ? l10n.branchStatusActive
                    : l10n.branchStatusInactive,
                active: branch.isActive,
              ),
              if (branch.contactPhone != null)
                Text(
                  branch.contactPhone!,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              Text(
                scheduleSummary,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = active ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final fg = active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
