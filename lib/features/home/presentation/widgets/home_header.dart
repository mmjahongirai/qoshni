import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/routing/route_paths.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/features/home/presentation/widgets/home_cart_header_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.themeController,
    required this.localeController,
    super.key,
  });

  final ThemeController themeController;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBrightness = Theme.of(context).brightness;
    final isDark = effectiveBrightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appTitle,
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.homeSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(
                tooltip: l10n.profileOpenTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: () => context.pushNamed(RouteNames.profile),
                icon: const Icon(Icons.person_outline_rounded),
              ),
              IconButton(
                tooltip: l10n.favoritesTitle,
                visualDensity: VisualDensity.compact,
                onPressed: () => context.pushNamed(RouteNames.favorites),
                icon: const Icon(Icons.favorite_border_rounded),
              ),
              const HomeCartHeaderButton(),
              IconButton(
                tooltip: l10n.toggleThemeTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: () => themeController.toggleLightDark(
                  effectiveBrightness,
                ),
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
              ),
              PopupMenuButton<Locale?>(
                tooltip: l10n.languageTooltip,
                icon: const Icon(Icons.language_outlined),
                onSelected: localeController.setLocale,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: const Locale('uz'),
                    child: Text(l10n.profileLanguageUz),
                  ),
                  PopupMenuItem(
                    value: const Locale('ru'),
                    child: Text(l10n.profileLanguageRu),
                  ),
                  PopupMenuItem(
                    value: const Locale('en'),
                    child: Text(l10n.profileLanguageEn),
                  ),
                  PopupMenuItem(
                    value: null,
                    child: Text(l10n.profileLanguageSystem),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
