import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';
import 'package:qoshni/features/business_platform/presentation/business_owner_profile_controller.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessOwnerProfileOverviewPage extends StatelessWidget {
  const BusinessOwnerProfileOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessOwnerProfileController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.ownerProfileOverviewTitle),
        actions: [
          TextButton(
            onPressed: () =>
                context.push(RoutePaths.businessOwnerProfileEdit),
            child: Text(l10n.ownerProfileEditAction),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final profile = controller.profile;
            return ResponsiveLayout(
              phone: _OverviewBody(profile: profile, maxWidth: 520),
              tablet: _OverviewBody(profile: profile, maxWidth: 760),
            );
          },
        ),
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.profile,
    required this.maxWidth,
  });

  final BusinessOwnerProfile profile;
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
                message: l10n.ownerProfilePreviewNotice,
                icon: Icons.info_outline,
                tone: AppMessageTone.info,
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          colorScheme.primaryContainer.withValues(alpha: 0.5),
                      child: Icon(
                        Icons.storefront_outlined,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      profile.displayName,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (profile.isDemoSeed) ...[
                      const SizedBox(height: AppSpacing.xs),
                      const DemoContentBadge(),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      profile.legalBusinessName,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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
                      l10n.ownerProfileCompletenessLabel,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: profile.completenessFraction,
                      borderRadius: AppRadius.smAll,
                      minHeight: 8,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${(profile.completenessFraction * 100).round()}%',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoSection(
                title: l10n.ownerProfileSectionBasics,
                rows: [
                  _InfoRow(
                    label: l10n.ownerProfileStatusLabel,
                    value: l10n.ownerProfileStatusPreview,
                  ),
                  _InfoRow(
                    label: l10n.ownerProfileDescription,
                    value: profile.description,
                  ),
                  _InfoRow(
                    label: l10n.ownerProfileCategory,
                    value: serviceCategoryLabel(profile.categoryId, l10n),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoSection(
                title: l10n.ownerProfileSectionContact,
                rows: [
                  _InfoRow(
                    label: l10n.ownerProfileContactPhone,
                    value: profile.contactPhone ?? '—',
                  ),
                  _InfoRow(
                    label: l10n.ownerProfileContactEmail,
                    value: profile.contactEmail ?? '—',
                  ),
                  _InfoRow(
                    label: l10n.ownerProfileWebsite,
                    value: profile.websiteUrl ?? '—',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () =>
                    context.push(RoutePaths.businessOwnerProfileEdit),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.ownerProfileEditAction),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.ownerProfileViewAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
