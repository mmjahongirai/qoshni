import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_kind.dart';
import 'package:qoshni/features/business_platform/presentation/business_inventory_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_offerings_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessInventorySummarySection extends StatelessWidget {
  const BusinessInventorySummarySection({
    required this.l10n,
    required this.profile,
    super.key,
  });

  final AppLocalizations l10n;
  final BusinessProfileDraft profile;

  @override
  Widget build(BuildContext context) {
    if (profile.kind != BusinessProfileKind.userDraft) {
      return const SizedBox.shrink();
    }

    final inventoryController = getIt<BusinessInventoryController>();
    final offeringsController = getIt<BusinessOfferingsController>();

    return ListenableBuilder(
      listenable: Listenable.merge([
        inventoryController,
        offeringsController,
      ]),
      builder: (context, _) {
        inventoryController.pruneOrphansForProfile(profile.id);
        final summary = inventoryController.summaryForProfile(profile.id);
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.businessInventorySummaryTitle,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            AppSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Text(
                      l10n.businessInventorySummaryCounts(
                        summary.configuredCount,
                        summary.offeringCount,
                        summary.activeCount,
                        summary.pausedCount,
                      ),
                      style: textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.businessInventorySummaryNotice,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => context.pushNamed(
                        RouteNames.businessInventory,
                        pathParameters: {'profileId': profile.id},
                      ),
                      child: Text(l10n.businessInventoryManageAction),
                    ),
                  ],
                ),
            ),
          ],
        );
      },
    );
  }
}
