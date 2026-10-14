import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_kind.dart';
import 'package:qoshni/features/business_platform/presentation/business_profile_controller.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_inventory_summary_section.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_profile_offerings_section.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessProfileDetailPage extends StatelessWidget {
  const BusinessProfileDetailPage({
    required this.profileId,
    super.key,
  });

  final String? profileId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessProfileController>();
    final id = profileId?.trim();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.businessProfileDetailTitle),
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final profile =
                  id == null ? null : controller.resolveProfile(l10n, id);
              if (profile == null || !profile.isEditable) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () => context.pushNamed(
                  RouteNames.businessProfileEdit,
                  pathParameters: {'profileId': profile.id},
                ),
                child: Text(l10n.businessProfileEditAction),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final profile = id == null || id.isEmpty
                ? null
                : controller.resolveProfile(l10n, id);

            if (profile == null) {
              return _BusinessProfileNotFound(l10n: l10n);
            }

            return ResponsiveLayout(
              phone: _BusinessProfileDetailBody(
                maxWidth: 520,
                l10n: l10n,
                profile: profile,
              ),
              tablet: _BusinessProfileDetailBody(
                maxWidth: 760,
                l10n: l10n,
                profile: profile,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BusinessProfileDetailBody extends StatelessWidget {
  const _BusinessProfileDetailBody({
    required this.maxWidth,
    required this.l10n,
    required this.profile,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final BusinessProfileDraft profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSample = profile.kind == BusinessProfileKind.sampleDemo;

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
                message: isSample
                    ? l10n.businessProfileSampleReadOnlyNotice
                    : l10n.businessProfileDraftLocalNotice,
                icon: isSample
                    ? Icons.visibility_outlined
                    : Icons.save_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.businessName,
                      style: textTheme.headlineSmall,
                    ),
                    if (isSample) ...[
                      const SizedBox(height: AppSpacing.xs),
                      const DemoContentBadge(),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _DetailField(
                      label: l10n.businessProfileFieldCategory,
                      value: serviceCategoryLabel(profile.categoryId, l10n),
                    ),
                    _DetailField(
                      label: l10n.businessProfileFieldDescription,
                      value: profile.description,
                    ),
                    _DetailField(
                      label: l10n.businessProfileFieldAddress,
                      value: profile.addressDescription,
                    ),
                    _DetailField(
                      label: l10n.businessProfileFieldHours,
                      value: profile.workingHours,
                    ),
                    if (profile.contactPhone != null &&
                        profile.contactPhone!.isNotEmpty)
                      _DetailField(
                        label: l10n.businessProfileFieldPhone,
                        value: profile.contactPhone!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              BusinessProfileOfferingsSection(
                l10n: l10n,
                profile: profile,
              ),
              BusinessInventorySummarySection(
                l10n: l10n,
                profile: profile,
              ),
              if (isSample) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    context.pushNamed(
                      RouteNames.businessProfileCreate,
                      extra: BusinessProfileFormSeed(
                        businessName: profile.businessName,
                        categoryId: profile.categoryId,
                        description: profile.description,
                        addressDescription: profile.addressDescription,
                        workingHours: profile.workingHours,
                        contactPhone: profile.contactPhone,
                      ),
                    );
                  },
                  child: Text(l10n.businessProfileCopySampleToDraft),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _BusinessProfileNotFound extends StatelessWidget {
  const _BusinessProfileNotFound({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.storefront_outlined,
        title: l10n.businessProfileNotFoundTitle,
        message: l10n.businessProfileNotFoundBody,
      ),
    );
  }
}
