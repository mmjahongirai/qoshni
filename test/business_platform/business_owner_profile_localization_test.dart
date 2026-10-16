import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';
import 'package:qoshni/core/localization/generated/app_localizations_ru.dart';
import 'package:qoshni/core/localization/generated/app_localizations_uz.dart';

void main() {
  test('owner profile preview notice is localized', () {
    expect(
      AppLocalizationsEn().ownerProfilePreviewNotice,
      contains('Preview'),
    );
    expect(
      AppLocalizationsRu().ownerProfilePreviewNotice,
      isNotEmpty,
    );
    expect(
      AppLocalizationsUz().ownerProfilePreviewNotice,
      isNotEmpty,
    );
  });
}
