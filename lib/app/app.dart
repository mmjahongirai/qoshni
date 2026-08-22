import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/theme/app_theme.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QoshniApp extends StatelessWidget {
  const QoshniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    final themeController = getIt<ThemeController>();
    final localeController = getIt<LocaleController>();
    final router = getIt<AppRouter>().router;

    return ListenableBuilder(
      listenable: Listenable.merge([themeController, localeController]),
      builder: (context, _) {
        return MaterialApp.router(
          title: config.appName,
          debugShowCheckedModeBanner: config.environment.isDevelopment,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeController.themeMode,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
          builder: (context, child) {
            final brightness = Theme.of(context).brightness;
            final overlay = brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlay,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context).textScaler.clamp(
                        minScaleFactor: 0.9,
                        maxScaleFactor: 1.3,
                      ),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
