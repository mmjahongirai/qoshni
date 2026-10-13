import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/favorites/favorites_controller.dart';
import 'package:qoshni/features/home/presentation/widgets/search_result_tile.dart';
import 'package:qoshni/routing/route_paths.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favoritesController = getIt<FavoritesController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.favoritesEmptyTitle,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.favoritesEmptyBody,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go(RoutePaths.home),
              child: Text(l10n.favoritesGoHome),
            ),
          ],
        ),
      ),
    );
  }
}
