import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/app/app.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/theme/app_theme.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/di/injection.dart';
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

  test('onboarding routes stay under business center', () {
    expect(RoutePaths.businessOnboardingHub, '/business-center/onboarding');
    expect(
      RoutePaths.businessOnboardingApplication,
      '/business-center/onboarding/:applicationId',
    );
    expect(RoutePaths.businessCenter, '/business-center');
  });

  testWidgets('profile opens business center', (tester) async {
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

    expect(find.text('Manage your business (preview)'), findsOneWidget);
    expect(find.text('Business registration'), findsOneWidget);
  });

  testWidgets('business registration card opens onboarding hub', (tester) async {
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

    await tester.tap(find.text('Business registration').first);
    await tester.pumpAndSettle();

    expect(find.text('Business registration'), findsWidgets);
    expect(find.text('Manage your business (preview)'), findsNothing);
    expect(find.text('New business profile'), findsNothing);
    expect(
      find.text(
        'Registration server is not configured for this build. '
        'Set QOSHNI_API_BASE_URL at compile time.',
      ).evaluate().isNotEmpty ||
          find.text(
            'Sign in to view and manage your business registration applications.',
          ).evaluate().isNotEmpty ||
          find.text('Register your business').evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('business center section titles use readable colors in dark theme', (
    tester,
  ) async {
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

    final scheme = AppTheme.dark().colorScheme;

    final previewTitle = tester.widget<Text>(
      find.text('Manage your business (preview)'),
    );
    expect(previewTitle.style?.color, scheme.onSurface);

    final registrationTitle = tester.widget<Text>(
      find.text('Business registration'),
    );
    expect(registrationTitle.style?.color, scheme.onSurface);

    final emptyDraftsTitle = tester.widget<Text>(find.text('No drafts yet'));
    expect(emptyDraftsTitle.style?.color, scheme.onSurface);
  });
}
