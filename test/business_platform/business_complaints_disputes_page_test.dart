import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_complaints_disputes_page.dart';

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

  testWidgets('shows demo disclaimer on complaints tab', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessComplaintsDisputesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Complaints & disputes'), findsOneWidget);
    expect(
      find.text(
        'Demo complaints and disputes only — synthetic cases and evidence; no real customer cases.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('complaint save error keeps dialog open', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    (getIt<BusinessComplaintRepository>() as InMemoryBusinessComplaintRepository)
        .failNextSave = true;

    await tester.pumpWidget(_app(const BusinessComplaintsDisputesPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create demo complaint'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Save'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Could not save complaint'), findsOneWidget);
  });
}
