import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/app/app.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/di/injection.dart';

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

  testWidgets('Home screen renders core discovery content', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    expect(find.text("QO'SHNI"), findsWidgets);
    expect(find.text('What do you need right now?'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Near you'), findsOneWidget);
    expect(find.text('Open map'), findsOneWidget);
    expect(find.text('Nearby chains & essentials'), findsOneWidget);
    expect(
      find.text(
        'Mapbox map preview — add MAPBOX_ACCESS_TOKEN to enable the live map.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Theme and language controls remain available', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.language_outlined), findsOneWidget);

    final themeController = getIt<ThemeController>();
    themeController.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(themeController.themeMode, ThemeMode.dark);

    final localeController = getIt<LocaleController>();
    localeController.setLocale(const Locale('uz'));
    await tester.pumpAndSettle();

    expect(localeController.locale, const Locale('uz'));
    expect(find.text('Sizga hozir nima kerak?'), findsOneWidget);
  });

  testWidgets('Map preview navigates to placeholder map screen', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Open map'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Open map'));
    await tester.pumpAndSettle();

    expect(find.text('Map'), findsWidgets);
    expect(find.text('Mapbox access token required'), findsOneWidget);
  });
}
