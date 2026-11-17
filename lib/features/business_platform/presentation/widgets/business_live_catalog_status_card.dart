import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/application/business_catalog_integration_controller.dart';

/// States whether the live owner catalog is linked. Sample profiles stay on
/// the rest of the page and are not described as that catalog.
class BusinessLiveCatalogStatusCard extends StatefulWidget {
  const BusinessLiveCatalogStatusCard({super.key});

  @override
  State<BusinessLiveCatalogStatusCard> createState() =>
      _BusinessLiveCatalogStatusCardState();
}

class _BusinessLiveCatalogStatusCardState
    extends State<BusinessLiveCatalogStatusCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessCatalogIntegrationController>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogIntegrationController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final message = switch (controller.blocker) {
          null when controller.phase == BusinessCatalogLinkPhase.ready =>
            l10n.businessLiveCatalogReady(controller.applicationId!),
          BusinessCatalogLinkBlocker.apiNotConfigured =>
            l10n.businessLiveCatalogApiOff,
          BusinessCatalogLinkBlocker.signedOut =>
            l10n.businessLiveCatalogSignedOut,
          BusinessCatalogLinkBlocker.sessionExpired =>
            l10n.businessLiveCatalogSessionEnded,
          BusinessCatalogLinkBlocker.noVerifiedApplication =>
            l10n.businessLiveCatalogNoApplication,
          BusinessCatalogLinkBlocker.ambiguousApplication =>
            l10n.businessLiveCatalogAmbiguous,
          BusinessCatalogLinkBlocker.forbidden =>
            l10n.businessLiveCatalogForbidden,
          _ => l10n.businessLiveCatalogLoading,
        };
        return AppSurfaceCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                controller.phase == BusinessCatalogLinkPhase.ready
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_off_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.businessLiveCatalogTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
