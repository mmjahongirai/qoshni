import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_controller.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_messages.dart';
import 'package:qoshni/features/business_onboarding/presentation/widgets/onboarding_auth_gate.dart';
import 'package:qoshni/routing/route_paths.dart';

class OnboardingHubPage extends StatefulWidget {
  const OnboardingHubPage({super.key});

  @override
  State<OnboardingHubPage> createState() => _OnboardingHubPageState();
}

class _OnboardingHubPageState extends State<OnboardingHubPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<OnboardingController>().refreshApplications();
    });
  }

  Future<void> _createApplication() async {
    final controller = getIt<OnboardingController>();
    final created = await controller.createApplication();
    if (!mounted || created == null) {
      return;
    }
    context.pushNamed(
      RouteNames.businessOnboardingApplication,
      pathParameters: {'applicationId': created.applicationId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    final l10n = AppLocalizations.of(context);

    return OnboardingAuthGate(
      apiConfigured: config.apiConfigured,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.onboardingHubTitle),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: getIt<OnboardingController>(),
            builder: (context, _) {
              final controller = getIt<OnboardingController>();
              return ResponsiveLayout(
                phone: _HubBody(
                  maxWidth: 520,
                  l10n: l10n,
                  controller: controller,
                  onOpen: (id) => context.pushNamed(
                    RouteNames.businessOnboardingApplication,
                    pathParameters: {'applicationId': id},
                  ),
                  onRetry: controller.refreshApplications,
                ),
                tablet: _HubBody(
                  maxWidth: 760,
                  l10n: l10n,
                  controller: controller,
                  onOpen: (id) => context.pushNamed(
                    RouteNames.businessOnboardingApplication,
                    pathParameters: {'applicationId': id},
                  ),
                  onRetry: controller.refreshApplications,
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: getIt<OnboardingController>().saveBusy ? null : _createApplication,
          icon: const Icon(Icons.add),
          label: Text(l10n.onboardingCreateApplication),
        ),
      ),
    );
  }
}

class _HubBody extends StatelessWidget {
  const _HubBody({
    required this.maxWidth,
    required this.l10n,
    required this.controller,
    required this.onOpen,
    required this.onRetry,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final OnboardingController controller;
  final void Function(String applicationId) onOpen;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final failure = controller.lastFailure;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.onboardingHubIntroTitle,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingHubIntroBody,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (failure != null &&
                  controller.listState == OnboardingLoadState.error) ...[
                AppMessageBanner(
                  message: onboardingFailureMessage(l10n, failure),
                  icon: Icons.error_outline,
                  tone: AppMessageTone.error,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.listBusy ? null : onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.userProfileRetryAction),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (controller.listState == OnboardingLoadState.loading &&
                  controller.applications.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (controller.applications.isEmpty)
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.onboardingHubEmptyTitle,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.onboardingHubEmptyBody,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (var i = 0; i < controller.applications.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _ApplicationTile(
                    l10n: l10n,
                    application: controller.applications[i],
                    onTap: () => onOpen(controller.applications[i].applicationId),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({
    required this.l10n,
    required this.application,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final OwnerApplicationViewDto application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = application.legalBusinessName?.trim().isNotEmpty == true
        ? application.legalBusinessName!
        : application.tradeDisplayName?.trim().isNotEmpty == true
            ? application.tradeDisplayName!
            : l10n.onboardingUntitledApplication;

    return AppSurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  onboardingStatusLabel(l10n, application.verificationStatus),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
