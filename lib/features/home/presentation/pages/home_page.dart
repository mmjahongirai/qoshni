import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/widgets/home_header.dart';
import 'package:qoshni/features/home/presentation/widgets/home_search_field.dart';
import 'package:qoshni/features/home/presentation/widgets/home_section_title.dart';
import 'package:qoshni/features/home/presentation/widgets/map_preview_card.dart';
import 'package:qoshni/features/home/presentation/widgets/nearby_business_section.dart';
import 'package:qoshni/features/home/presentation/widgets/service_category_grid.dart';
import 'package:qoshni/core/widgets/primary_navigation_shell.dart';
import 'package:qoshni/routing/route_paths.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeController = getIt<ThemeController>();
    final localeController = getIt<LocaleController>();
    final colorScheme = Theme.of(context).colorScheme;
    final categories = buildServiceCategories(l10n);
    final nearbyBusinesses = buildNearbyBusinesses(l10n, colorScheme);

    return PrimaryNavigationShell(
      destination: PrimaryNavDestination.home,
      body: SafeArea(
        child: ResponsiveLayout(
          phone: _HomeScrollContent(
            maxWidth: 520,
            l10n: l10n,
            themeController: themeController,
            localeController: localeController,
            categories: categories,
            nearbyBusinesses: nearbyBusinesses,
          ),
          tablet: _HomeScrollContent(
            maxWidth: 760,
            l10n: l10n,
            themeController: themeController,
            localeController: localeController,
            categories: categories,
            nearbyBusinesses: nearbyBusinesses,
          ),
        ),
      ),
    );
  }
}

class _HomeScrollContent extends StatelessWidget {
  const _HomeScrollContent({
    required this.maxWidth,
    required this.l10n,
    required this.themeController,
    required this.localeController,
    required this.categories,
    required this.nearbyBusinesses,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final ThemeController themeController;
  final LocaleController localeController;
  final List<HomeServiceCategoryItem> categories;
  final List<NearbyBusinessItem> nearbyBusinesses;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                themeController: themeController,
                localeController: localeController,
              ),
              const SizedBox(height: 22),
              HomeSearchField(
                hintText: l10n.homeSearchHint,
                onTap: () => context.pushNamed(RouteNames.search),
              ),
              const SizedBox(height: 28),
              HomeSectionTitle(title: l10n.homeMainHeading),
              const SizedBox(height: 16),
              ServiceCategoryGrid(
                categories: categories,
                onCategorySelected: (categoryId) => context.pushNamed(
                  RouteNames.categoryListing,
                  pathParameters: {'categoryId': categoryId.name},
                ),
              ),
              const SizedBox(height: 28),
              NearbyBusinessSection(
                title: l10n.homeNearbyTitle,
                businesses: nearbyBusinesses,
              ),
              const SizedBox(height: 28),
              MapPreviewCard(
                title: l10n.mapPreviewTitle,
                subtitle: l10n.mapPreviewSubtitle,
                buttonLabel: l10n.openMap,
                onOpenMap: () => context.pushNamed(RouteNames.map),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
