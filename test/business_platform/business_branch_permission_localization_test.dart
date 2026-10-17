import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';
import 'package:qoshni/core/localization/generated/app_localizations_ru.dart';
import 'package:qoshni/core/localization/generated/app_localizations_uz.dart';

void main() {
  test('branch permission preview notice localized', () {
    expect(
      AppLocalizationsEn().branchPermPreviewNotice,
      contains('Preview'),
    );
    expect(
      AppLocalizationsUz().branchPermPreviewNotice,
      contains('sessiyada'),
    );
    expect(AppLocalizationsRu().branchPermPreviewNotice, isNotEmpty);
  });
}
