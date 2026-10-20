import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_fulfillment_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_fulfillment_repository.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_fulfillment_page.dart';

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

  testWidgets('shows disclaimer and seed modes', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessFulfillmentPage()));
    await tester.pumpAndSettle();

    expect(find.text('Fulfillment'), findsOneWidget);
    expect(
      find.text('Demo fulfillment settings — not connected to live orders or delivery.'),
      findsOneWidget,
    );
    expect(find.textContaining('Delivery'), findsWidgets);
  });

  testWidgets('save error keeps dialog open', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    (getIt<BusinessFulfillmentRepository>()
            as InMemoryBusinessFulfillmentRepository)
        .failNextSave = true;

    await tester.pumpWidget(_app(const BusinessFulfillmentPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add configuration'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Could not save'), findsOneWidget);
  });
}
