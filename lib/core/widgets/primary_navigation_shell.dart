import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/breakpoints.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/routing/route_paths.dart';

enum PrimaryNavDestination { home, search, favorites, profile }

/// Bottom navigation for primary discovery tabs (phone-first; rail on wide web).
class PrimaryNavigationShell extends StatelessWidget {
  const PrimaryNavigationShell({
    required this.destination,
    required this.body,
    this.floatingAction,
    super.key,
  });

  final PrimaryNavDestination destination;
  final Widget body;
  final Widget? floatingAction;

  static void goTo(BuildContext context, PrimaryNavDestination dest) {
    final path = switch (dest) {
      PrimaryNavDestination.home => RoutePaths.home,
      PrimaryNavDestination.search => RoutePaths.search,
      PrimaryNavDestination.favorites => RoutePaths.favorites,
      PrimaryNavDestination.profile => RoutePaths.profile,
    };
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDesktop = Breakpoints.isDesktopWidth(context);
    final selectedIndex = destination.index;

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded, color: scheme.primary),
        label: l10n.navHome,
      ),
      NavigationDestination(
        icon: const Icon(Icons.search_rounded),
        selectedIcon: Icon(Icons.search_rounded, color: scheme.primary),
        label: l10n.searchTitle,
      ),
      NavigationDestination(
        icon: const Icon(Icons.favorite_border_rounded),
        selectedIcon: Icon(Icons.favorite_rounded, color: scheme.primary),
        label: l10n.favoritesTitle,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded, color: scheme.primary),
        label: l10n.profileTitle,
      ),
    ];

    if (isDesktop) {
      return Scaffold(
        floatingActionButton: floatingAction,
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1100,
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) =>
                  goTo(context, PrimaryNavDestination.values[i]),
              labelType: NavigationRailLabelType.none,
              destinations: [
                for (final dest in destinations)
                  NavigationRailDestination(
                    icon: dest.icon,
                    selectedIcon: dest.selectedIcon,
                    label: Text(dest.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: floatingAction,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        animationDuration: appAnimationDuration(context, AppDurations.normal),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) =>
            goTo(context, PrimaryNavDestination.values[i]),
        destinations: destinations,
      ),
    );
  }
}

/// App bar leading: back when stack allows pop, otherwise hidden for tab roots.
Widget? primaryTabLeading(BuildContext context) {
  if (context.canPop()) {
    return const BackButton();
  }
  return null;
}
