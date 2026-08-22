import 'package:flutter/material.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/di/injection.dart';

/// Minimal shell screen proving routing, theme, locale, and responsive layout.
/// No business features are implemented here.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = getIt<AppConfig>();
    final themeController = getIt<ThemeController>();
    final localeController = getIt<LocaleController>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: themeController.toggleLightDark,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          PopupMenuButton<Locale?>(
            tooltip: 'Language',
            icon: const Icon(Icons.language),
            onSelected: localeController.setLocale,
            itemBuilder: (context) => const [
              PopupMenuItem(value: Locale('uz'), child: Text('O‘zbekcha')),
              PopupMenuItem(value: Locale('ru'), child: Text('Русский')),
              PopupMenuItem(value: Locale('en'), child: Text('English')),
              PopupMenuItem(value: null, child: Text('System')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          phone: _HomeBody(
            padding: responsivePagePadding(context),
            headline: l10n.homeHeadline,
            subtitle: l10n.homeSubtitle,
            environmentLabel: l10n.environmentLabel(config.environment.label),
            textTheme: textTheme,
            colorScheme: colorScheme,
            maxWidth: 480,
          ),
          tablet: _HomeBody(
            padding: responsivePagePadding(context),
            headline: l10n.homeHeadline,
            subtitle: l10n.homeSubtitle,
            environmentLabel: l10n.environmentLabel(config.environment.label),
            textTheme: textTheme,
            colorScheme: colorScheme,
            maxWidth: 640,
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.padding,
    required this.headline,
    required this.subtitle,
    required this.environmentLabel,
    required this.textTheme,
    required this.colorScheme,
    required this.maxWidth,
  });

  final EdgeInsets padding;
  final String headline;
  final String subtitle;
  final String environmentLabel;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(headline, style: textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                label: environmentLabel,
                child: Chip(
                  avatar: Icon(Icons.cloud_outlined, color: colorScheme.primary),
                  label: Text(environmentLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
