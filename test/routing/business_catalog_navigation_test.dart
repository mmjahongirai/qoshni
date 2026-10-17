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

  test('catalog routes registered', () {
    expect(RoutePaths.businessCatalog, '/business-center/catalog');
    expect(
      RoutePaths.businessCatalogCategories,
      '/business-center/catalog/categories',
    );
  });

  testWidgets('business center opens catalog home', (tester) async {
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
      find.text('Catalog'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Catalog').first);
    await tester.pumpAndSettle();

    expect(find.text('Manage categories'), findsOneWidget);
    expect(find.text('Categories'), findsWidgets);
  });

  testWidgets('invalid category id shows error state', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(
      '/business-center/catalog/categories/not-a-real-category',
    );
    await tester.pumpAndSettle();

    expect(find.text('Category not found'), findsOneWidget);
    expect(find.text('Back to categories'), findsOneWidget);
  });

  testWidgets('catalog home readable in dark theme', (tester) async {
    getIt<ThemeController>().setThemeMode(ThemeMode.dark);
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(RoutePaths.businessCatalog);
    await tester.pumpAndSettle();

    final scheme = AppTheme.dark().colorScheme;
    expect(scheme.brightness, Brightness.dark);
    expect(find.text('Manage categories'), findsOneWidget);
  });
}
