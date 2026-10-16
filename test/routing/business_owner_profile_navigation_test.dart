import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/app/app.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/theme/app_theme.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/routing/app_router.dart';
import 'package:qoshni/routing/route_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
    getIt<LocaleController>().setLocale(const Locale('en'));
    getIt<ThemeController>().setThemeMode(ThemeMode.light);
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('owner profile routes are under business center', () {
    expect(RoutePaths.businessOwnerProfile, '/business-center/business-profile');
    expect(
      RoutePaths.businessOwnerProfileEdit,
      '/business-center/business-profile/edit',
    );
  });

  testWidgets('business center opens owner profile overview', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Business Center'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Business Center'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Business profile'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Business profile').first);
    await tester.pumpAndSettle();

    expect(find.text('Preview draft'), findsOneWidget);
    expect(find.text('Manage your business (preview)'), findsNothing);
  });

  testWidgets('direct route opens owner profile overview', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(RoutePaths.businessOwnerProfile);
    await tester.pumpAndSettle();

    expect(find.text('Preview draft'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Edit profile'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('overview uses readable title color in dark theme', (tester) async {
    getIt<ThemeController>().setThemeMode(ThemeMode.dark);
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Business Center'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Business Center'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Business profile'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Business profile').first);
    await tester.pumpAndSettle();

    final scheme = AppTheme.dark().colorScheme;
    final title = tester.widget<Text>(find.text('Demo Services').first);
    expect(title.style?.color, scheme.onSurface);
  });
}
