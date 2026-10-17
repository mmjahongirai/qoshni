import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/theme/app_theme.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_product_media_gallery_section.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_product_options_section.dart';

Widget _wrap(Widget child, ThemeMode mode) {
  getIt<ThemeController>().setThemeMode(mode);
  return MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: mode,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
    getIt<LocaleController>().setLocale(const Locale('en'));
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('options section shows demo bread group in English', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatalogProductOptionsSection(
          productId: kDemoCatalogProductBreadId,
          readOnly: true,
        ),
        ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Options & add-ons'), findsOneWidget);
    expect(find.text('Bread size'), findsOneWidget);
    expect(find.text('Small'), findsOneWidget);
  });

  testWidgets('media gallery shows preview-only notice and demo placeholder', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatalogProductMediaGallerySection(
          productId: kDemoCatalogProductBreadId,
          readOnly: true,
        ),
        ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Media gallery'), findsOneWidget);
    expect(
      find.textContaining('Preview only'),
      findsOneWidget,
    );
    expect(find.text('Demo bread preview'), findsWidgets);
  });

  testWidgets('media empty state for product without media', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatalogProductMediaGallerySection(
          productId: kDemoCatalogProductPlovId,
          readOnly: true,
        ),
        ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No images yet. Add a local preview image for this session.'), findsOneWidget);
  });

  testWidgets('sections render in dark theme', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _wrap(
        const CatalogProductOptionsSection(
          productId: kDemoCatalogProductBreadId,
          readOnly: true,
        ),
        ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Options & add-ons'), findsOneWidget);
    expect(find.text('Bread size'), findsOneWidget);
  });
}
