import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';
import 'package:qoshni/core/localization/generated/app_localizations_ru.dart';
import 'package:qoshni/core/localization/generated/app_localizations_uz.dart';

void main() {
  test('staff preview notice localized', () {
    expect(AppLocalizationsEn().staffPreviewNotice, contains('Preview'));
    expect(AppLocalizationsRu().staffPreviewNotice, isNotEmpty);
    expect(AppLocalizationsUz().staffPreviewNotice, isNotEmpty);
  });
}
