import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/app/app.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/routing/app_router.dart';
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

  testWidgets('invalid product id shows not found', (tester) async {
    await tester.pumpWidget(const QoshniApp());
    await tester.pumpAndSettle();

    getIt<AppRouter>().router.go(
      '/business-center/catalog/products/not-a-product',
    );
    await tester.pumpAndSettle();

    expect(find.text('Product not found'), findsOneWidget);
  });
}
