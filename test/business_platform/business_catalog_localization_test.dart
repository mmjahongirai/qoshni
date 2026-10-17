import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';

void main() {
  testWidgets('catalog preview notice localized in uz', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('uz'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(l10n.catalogPreviewNotice);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Preview'), findsOneWidget);
    expect(find.textContaining('sessiyada'), findsOneWidget);
  });
}
