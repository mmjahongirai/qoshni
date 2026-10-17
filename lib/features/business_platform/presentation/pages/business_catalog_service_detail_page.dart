import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_service_controller.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_listing_attributes_section.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_listing_placeholder.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogServiceDetailPage extends StatelessWidget {
  const BusinessCatalogServiceDetailPage({required this.serviceId, super.key});

  final String? serviceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogServiceController>();
    final id = serviceId?.trim();
    final service = id == null ? null : controller.serviceById(id);

    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.catalogServiceDetailTitle)),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go(RoutePaths.businessCatalogServices),
            child: Text(l10n.catalogServiceBackToListAction),
          ),
        ),
      );
    }

    final category = getIt<BusinessCatalogCategoryController>()
        .categoryById(service.categoryId);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogServiceDetailTitle),
        actions: [
          TextButton(
            onPressed: () => context.push(
              RoutePaths.businessCatalogServiceEditPath(service.serviceId),
            ),
            child: Text(l10n.catalogCategoryEditAction),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: responsivePagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CatalogListingPlaceholder(),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.displayName(l10n),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(service.status.label(l10n)),
                    if (category != null)
                      Text(l10n.catalogListingCategoryLabel(category.displayName(l10n))),
                    if (service.durationMinutes != null)
                      Text(l10n.catalogServiceDurationLabel(service.durationMinutes!)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CatalogListingAttributesSection(
                listingKind: BusinessCatalogListingKind.service,
                listingId: service.serviceId,
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
