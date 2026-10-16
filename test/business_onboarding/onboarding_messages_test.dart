import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_failure.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_messages.dart';

void main() {
  test('failure messages avoid echoing raw server secrets', () {
    final l10n = AppLocalizationsEn();
    const failure = OnboardingFailure(
      code: OnboardingErrorCode.validationFailed,
      message: 'legal_business_name is required',
    );
    final message = onboardingFailureMessage(l10n, failure);
    expect(message, contains('legal_business_name'));
    expect(message.toLowerCase(), isNot(contains('bearer')));
    expect(message.toLowerCase(), isNot(contains('storage_object_key')));
  });

  test('status and rejection labels map known backend codes', () {
    final l10n = AppLocalizationsEn();
    expect(onboardingStatusLabel(l10n, 'under_review'), isNotEmpty);
    expect(onboardingRejectionLabel(l10n, 'incomplete_information'), isNotEmpty);
  });
}
