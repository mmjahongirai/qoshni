import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/app/app.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/wallet/presentation/pages/wallet_page.dart';
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

  test('wallet route lives under profile', () {
    expect(RoutePaths.wallet, '/profile/wallet');
    expect(RouteNames.wallet, 'wallet');
  });

  testWidgets('profile Wallet shortcut opens the wallet page', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    final shortcut = find.widgetWithText(ListTile, 'Wallet');
    await tester.scrollUntilVisible(
      shortcut,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Balance and payments'), findsOneWidget);
    expect(
      find.descendant(
        of: shortcut,
        matching: find.byIcon(Icons.account_balance_wallet_outlined),
      ),
      findsOneWidget,
    );

    await tester.tap(shortcut);
    await tester.pumpAndSettle();

    expect(find.byType(WalletPage), findsOneWidget);
    // This test build has no API URL, so no balance is requested or shown.
    expect(find.text('Wallet server is not configured for this build.'), findsOneWidget);
    expect(find.textContaining("so'm"), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(WalletPage), findsNothing);
    expect(find.text('Balance and payments'), findsOneWidget);
  });

  testWidgets('deep link to /profile/wallet opens the wallet page', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(RoutePaths.wallet);
    await tester.pumpAndSettle();

    expect(find.byType(WalletPage), findsOneWidget);
    expect(find.text('Wallet'), findsWidgets);

    // Back from a deep link returns to the profile page.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(WalletPage), findsNothing);
    expect(find.text('Balance and payments'), findsOneWidget);
  });
}
