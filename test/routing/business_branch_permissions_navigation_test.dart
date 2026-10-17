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

  test('branch permissions route registered', () {
    expect(
      RoutePaths.businessBranchPermissions,
      '/business-center/branch-permissions',
    );
  });

  testWidgets('business center opens branch permissions', (tester) async {
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
      find.text('Branch permissions'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Branch permissions').first);
    await tester.pumpAndSettle();

    expect(find.text('View branch'), findsWidgets);
  });

  testWidgets('deep link selects staff and branch query', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(
      '${RoutePaths.businessBranchPermissions}?staffId=demo-staff-branch-manager&branchId=demo-branch-tashkent-center',
    );
    await tester.pumpAndSettle();

    expect(find.text('Assigned to this branch (preview)'), findsOneWidget);
  });

  testWidgets('permissions readable in dark theme', (tester) async {
    getIt<ThemeController>().setThemeMode(ThemeMode.dark);
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(RoutePaths.businessBranchPermissions);
    await tester.pumpAndSettle();

    final scheme = AppTheme.dark().colorScheme;
    final label = tester.widget<Text>(find.text('Branch access').first);
    expect(label.style?.color, scheme.onSurface);
  });
}
