import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/favorites/favorites_controller.dart';
import 'package:qoshni/features/home/presentation/widgets/search_result_tile.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/primary_navigation_shell.dart';
import 'package:qoshni/routing/route_paths.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favoritesController = getIt<FavoritesController>();

    return PrimaryNavigationShell(
      destination: PrimaryNavDestination.favorites,
      body: Scaffold(
        appBar: AppBar(
          leading: primaryTabLeading(context),
          title: Text(l10n.favoritesTitle),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: favoritesController,
            builder: (context, _) {
              return ResponsiveLayout(
                phone: _FavoritesBody(
                  maxWidth: 520,
                  l10n: l10n,
                  favoritesController: favoritesController,
                ),
                tablet: _FavoritesBody(
                  maxWidth: 760,
                  l10n: l10n,
                  favoritesController: favoritesController,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody({
    required this.maxWidth,
    required this.l10n,
    required this.favoritesController,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final FavoritesController favoritesController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final favorites = favoritesController.favoriteIds
        .map((id) => findMockBusinessById(l10n, colorScheme, id))
        .whereType<NearbyBusinessItem>()
        .toList(growable: false);

    if (favorites.isEmpty) {
      return _FavoritesEmptyState(l10n: l10n);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView.separated(
            itemCount: favorites.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final business = favorites[index];
              final entry = searchCatalogEntryFromBusiness(business, l10n);
              return SearchResultTile(entry: entry);
            },
          ),
        ),
      ),
    );
  }
}

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.favorite_border_rounded,
        title: l10n.favoritesEmptyTitle,
        message: l10n.favoritesEmptyBody,
        action: FilledButton(
          onPressed: () => context.go(RoutePaths.home),
          child: Text(l10n.favoritesGoHome),
        ),
      ),
    );
  }
}
