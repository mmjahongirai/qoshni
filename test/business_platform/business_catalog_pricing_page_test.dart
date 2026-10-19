import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_pricing_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_pricing_repository.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_pricing_page.dart';

Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
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

  testWidgets('shows demo prices and disclaimer', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogPricingPage()));
    await tester.pumpAndSettle();

    expect(find.text('Pricing'), findsOneWidget);
    expect(
      find.textContaining('not connected to live checkout'),
      findsOneWidget,
    );
    expect(find.textContaining('8 000 UZS'), findsWidgets);
  });

  testWidgets('save error keeps editor dialog open', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    (getIt<BusinessCatalogPricingRepository>()
            as InMemoryBusinessCatalogPricingRepository)
        .failNextSave = true;

    await tester.pumpWidget(_app(const BusinessCatalogPricingPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add price rule'));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    final stringDropdowns = find.descendant(
      of: dialog,
      matching: find.byType(DropdownButtonFormField<String>),
    );
    await tester.tap(stringDropdowns.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fresh bread').last);
    await tester.pumpAndSettle();

    await tester.tap(stringDropdowns.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demo — Tashkent Center').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '12000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('New price rule'), findsOneWidget);
    expect(find.text('Could not save. Check your entries.'), findsOneWidget);
  });
}
