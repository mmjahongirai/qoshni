import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/breakpoints.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/presentation/business_profile_controller.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_planned_capabilities_section.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_profile_summary_card.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCenterPage extends StatelessWidget {
  const BusinessCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessProfileController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.businessCenterTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return ResponsiveLayout(
              phone: _BusinessCenterBody(
                maxWidth: 520,
                l10n: l10n,
                controller: controller,
              ),
              tablet: _BusinessCenterBody(
                maxWidth: 760,
                l10n: l10n,
                controller: controller,
              ),
            );
          },
        ),
      ),
      floatingActionButton: _CreateProfileFab(l10n: l10n),
    );
  }
}

class _BusinessCenterBody extends StatelessWidget {
  const _BusinessCenterBody({
    required this.maxWidth,
    required this.l10n,
    required this.controller,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final BusinessProfileController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final drafts = controller.userDrafts;
    final samples = controller.sampleProfiles(l10n);

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSurfaceCard(
                onTap: () => context.push(RoutePaths.businessOnboardingHub),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.businessCenterOnboardingTitle,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.businessCenterOnboardingBody,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.businessCenterIntroTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.businessCenterIntroBody,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.businessCenterSessionNotice,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.businessCenterYourProfilesTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              if (drafts.isEmpty)
                _UserDraftsEmptyCard(l10n: l10n)
              else
                for (var i = 0; i < drafts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  BusinessProfileSummaryCard(
                    l10n: l10n,
                    profile: drafts[i],
                    onTap: () => context.pushNamed(
                      RouteNames.businessProfileDetail,
                      pathParameters: {'profileId': drafts[i].id},
                    ),
                  ),
                ],
              if (samples.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.businessCenterSampleSectionTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.businessCenterSampleSectionBody,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < samples.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  BusinessProfileSummaryCard(
                    l10n: l10n,
                    profile: samples[i],
                    onTap: () => context.pushNamed(
                      RouteNames.businessProfileDetail,
                      pathParameters: {'profileId': samples[i].id},
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              BusinessPlannedCapabilitiesSection(l10n: l10n),
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateProfileFab extends StatelessWidget {
  const _CreateProfileFab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final onCreate = () => context.push(RoutePaths.businessProfileCreate);
    final useCompact = MediaQuery.sizeOf(context).width <= Breakpoints.phoneMax;

    if (useCompact) {
      return FloatingActionButton(
        onPressed: onCreate,
        tooltip: l10n.businessCenterCreateProfile,
        child: const Icon(Icons.add_business_outlined),
      );
    }

    return FloatingActionButton.extended(
      onPressed: onCreate,
      icon: const Icon(Icons.add_business_outlined),
      label: Text(l10n.businessCenterCreateProfile),
    );
  }
}

class _UserDraftsEmptyCard extends StatelessWidget {
  const _UserDraftsEmptyCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.businessCenterEmptyDraftsTitle,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.businessCenterEmptyDraftsBody,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
