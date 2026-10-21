import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_exception_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_proof_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_exception_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_proof_repository.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_delivery_task_page.dart';

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

  testWidgets('shows exception and proof demo disclaimers on task card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessDeliveryTaskPage()));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Demo delivery exceptions'),
      findsWidgets,
    );
    expect(
      find.text(
        'Demo proof only — no real photo upload, OTP verification or signature storage.',
      ),
      findsWidgets,
    );
  });

  testWidgets('exception save error keeps dialog open', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    (getIt<BusinessDeliveryExceptionRepository>()
            as InMemoryBusinessDeliveryExceptionRepository)
        .failNextSave = true;

    await tester.pumpWidget(_app(const BusinessDeliveryTaskPage()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Log exception').first);
    await tester.tap(find.text('Log exception').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Demo issue at drop-off',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Save'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Could not save exception'), findsOneWidget);
  });

  testWidgets('proof save error keeps dialog open', (tester) async {
    tester.view.physicalSize = const Size(800, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    (getIt<BusinessDeliveryProofRepository>()
            as InMemoryBusinessDeliveryProofRepository)
        .failNextSave = true;

    await tester.pumpWidget(_app(const BusinessDeliveryTaskPage()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Add demo proof').first,
      300,
    );
    await tester.tap(find.text('Add demo proof').first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Save'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Could not save proof'), findsOneWidget);
  });
}
