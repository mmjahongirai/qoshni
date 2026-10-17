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

  test('staff routes registered under business center', () {
    expect(RoutePaths.businessStaff, '/business-center/staff');
    expect(
      RoutePaths.businessStaffDetailPath('demo-staff-branch-manager'),
      '/business-center/staff/demo-staff-branch-manager',
    );
  });

  testWidgets('business center opens staff list', (tester) async {
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
      find.text('Staff & roles'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Staff & roles').first);
    await tester.pumpAndSettle();

    expect(find.text('Dilnoza Karimova'), findsOneWidget);
  });

  testWidgets('invalid staff id shows not found', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(
      RoutePaths.businessStaffDetailPath('unknown-staff'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Staff member not found'), findsOneWidget);
  });

  testWidgets('staff name readable in dark theme', (tester) async {
    getIt<ThemeController>().setThemeMode(ThemeMode.dark);
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(RoutePaths.businessStaff);
    await tester.pumpAndSettle();

    final scheme = AppTheme.dark().colorScheme;
    final name = tester.widget<Text>(find.text('Dilnoza Karimova').first);
    expect(name.style?.color, scheme.onSurface);
  });
}
