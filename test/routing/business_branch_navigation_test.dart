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

  test('branch routes are registered under business center', () {
    expect(RoutePaths.businessBranches, '/business-center/branches');
    expect(
      RoutePaths.businessBranchCreate,
      '/business-center/branches/new',
    );
    expect(
      RoutePaths.businessBranchDetailPath('demo-branch-tashkent-center'),
      '/business-center/branches/demo-branch-tashkent-center',
    );
  });

  testWidgets('business center opens branch list', (tester) async {
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
      find.text('Branches'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Branches').first);
    await tester.pumpAndSettle();

    expect(find.text('Demo — Tashkent Center'), findsOneWidget);
  });

  testWidgets('invalid branch id shows not found', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(
      RoutePaths.businessBranchDetailPath('unknown-branch-id'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Branch not found'), findsOneWidget);
  });

  testWidgets('branch list title readable in dark theme', (tester) async {
    getIt<ThemeController>().setThemeMode(ThemeMode.dark);
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(RoutePaths.businessBranches);
    await tester.pumpAndSettle();

    final scheme = AppTheme.dark().colorScheme;
    final title = tester.widget<Text>(
      find.text('Demo — Tashkent Center').first,
    );
    expect(title.style?.color, scheme.onSurface);
  });
}
