import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';
import 'package:qoshni/core/localization/generated/app_localizations_ru.dart';
import 'package:qoshni/core/localization/generated/app_localizations_uz.dart';

void main() {
  test('branch preview notice localized', () {
    expect(AppLocalizationsEn().branchPreviewNotice, contains('Preview'));
    expect(AppLocalizationsRu().branchPreviewNotice, isNotEmpty);
    expect(AppLocalizationsUz().branchPreviewNotice, isNotEmpty);
  });
}
