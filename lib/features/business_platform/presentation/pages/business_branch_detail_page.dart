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
import 'package:qoshni/routing/route_paths.dart';

class BusinessBranchDetailPage extends StatelessWidget {
  const BusinessBranchDetailPage({required this.branchId, super.key});

  final String? branchId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessBranchController>();
    final id = branchId?.trim();
    final branch = id == null || id.isEmpty ? null : controller.branchById(id);

    if (branch == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.branchDetailTitle),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: responsivePagePadding(context),
              child: AppSurfaceCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.branchNotFoundTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.branchNotFoundBody),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () => context.go(RoutePaths.businessBranches),
                      child: Text(l10n.branchBackToListAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.branchDetailTitle),
        actions: [
          TextButton(
            onPressed: () => context.push(
              RoutePaths.businessBranchEditPath(branch.branchId),
            ),
            child: Text(l10n.branchEditAction),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final current = controller.branchById(branch.branchId) ?? branch;
            return ResponsiveLayout(
              phone: _BranchDetailBody(branch: current, maxWidth: 520),
              tablet: _BranchDetailBody(branch: current, maxWidth: 760),
            );
          },
        ),
      ),
    );
  }
}

class _BranchDetailBody extends StatelessWidget {
  const _BranchDetailBody({
    required this.branch,
    required this.maxWidth,
  });

  final BusinessBranch branch;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            branch.name,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (branch.isDemoSeed) const DemoContentBadge(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      branch.isActive
                          ? l10n.branchStatusActive
                          : l10n.branchStatusInactive,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DetailRow(
                      label: l10n.branchFieldCity,
                      value: branch.city,
                    ),
                    _DetailRow(
                      label: l10n.branchFieldAddress,
                      value: branch.addressLine,
                    ),
                    if (branch.contactPhone != null)
                      _DetailRow(
                        label: l10n.branchFieldPhone,
                        value: branch.contactPhone!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.branchSectionHours,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final day in branch.weeklySchedule)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                branchWeekdayLabel(l10n, day.weekday),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                day.isClosed
                                    ? l10n.branchDayClosed
                                    : '${day.openTime} – ${day.closeTime}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (branch.locationPreview.hasCoordinates) ...[
                const SizedBox(height: AppSpacing.md),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.branchSectionLocation,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.branchLocationDemoHint,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${branch.locationPreview.latitude}, ${branch.locationPreview.longitude}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
