import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_inventory.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';
import 'package:qoshni/features/business_platform/presentation/business_inventory_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_inventory_format.dart';
import 'package:qoshni/features/business_platform/presentation/business_offerings_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_profile_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessInventoryPage extends StatelessWidget {
  const BusinessInventoryPage({
    required this.profileId,
    super.key,
  });

  final String? profileId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = profileId?.trim();
    final profileController = getIt<BusinessProfileController>();
    final draft = id == null ? null : profileController.userDraftById(id);

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.businessInventoryPageTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.businessInventoryProfileNotEditable,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final inventoryController = getIt<BusinessInventoryController>();
    final offeringsController = getIt<BusinessOfferingsController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.businessInventoryPageTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            inventoryController,
            offeringsController,
          ]),
          builder: (context, _) {
            inventoryController.pruneOrphansForProfile(draft.id);
            final offerings =
                offeringsController.offeringsForProfile(draft.id);

            return ResponsiveLayout(
              phone: _InventoryBody(
                maxWidth: 520,
                l10n: l10n,
                profileId: draft.id,
                offerings: offerings,
              ),
              tablet: _InventoryBody(
                maxWidth: 760,
                l10n: l10n,
                profileId: draft.id,
                offerings: offerings,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InventoryBody extends StatelessWidget {
  const _InventoryBody({
    required this.maxWidth,
    required this.l10n,
    required this.profileId,
    required this.offerings,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final String profileId;
  final List<BusinessProfileOffering> offerings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final inventoryController = getIt<BusinessInventoryController>();

    if (offerings.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.inventory_2_outlined,
          title: l10n.businessInventoryNoOfferingsTitle,
          message: l10n.businessInventoryNoOfferingsBody,
          action: FilledButton(
            onPressed: () => context.pop(),
            child: Text(l10n.businessInventoryBackToProfile),
          ),
        ),
      );
    }

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
                l10n.businessInventoryPageIntro,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < offerings.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _InventoryOfferingCard(
                  l10n: l10n,
                  profileId: profileId,
                  offering: offerings[i],
                  inventory: inventoryController.inventoryFor(
                    businessProfileId: profileId,
                    offeringId: offerings[i].id,
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

class _InventoryOfferingCard extends StatelessWidget {
  const _InventoryOfferingCard({
    required this.l10n,
    required this.profileId,
    required this.offering,
    required this.inventory,
  });

  final AppLocalizations l10n;
  final String profileId;
  final BusinessProfileOffering offering;
  final BusinessOfferingInventory? inventory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offering.name,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            offering.kind.label(l10n),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatInventoryStatusLine(l10n, offering, inventory),
            style: textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.pushNamed(
                RouteNames.businessInventoryEdit,
                pathParameters: {
                  'profileId': profileId,
                  'offeringId': offering.id,
                },
              ),
              child: Text(
                inventory == null
                    ? l10n.businessInventoryConfigureAction
                    : l10n.businessInventoryEditAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
