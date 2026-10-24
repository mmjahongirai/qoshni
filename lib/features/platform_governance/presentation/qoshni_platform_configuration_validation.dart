import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_setting.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_configuration_value_type.dart';

const _secretLikePatterns = [
  'api_key',
  'apikey',
  'password',
  'secret',
  'token',
  'connection_string',
  'credential',
];

bool qoshniPlatformConfigurationValueLooksSecretLike(Object value) {
  final text = value.toString().toLowerCase();
  for (final pattern in _secretLikePatterns) {
    if (text.contains(pattern)) {
      return true;
    }
  }
  return false;
}

String? qoshniPlatformConfigurationValueValidationError(
  QoshniPlatformConfigurationSetting setting,
  Object newValue,
) {
  if (qoshniPlatformConfigurationValueLooksSecretLike(newValue)) {
    return 'secretLikeValueRejected';
  }
  return switch (setting.valueType) {
    QoshniPlatformConfigurationValueType.booleanValue =>
      newValue is bool ? null : 'invalidBoolean',
    QoshniPlatformConfigurationValueType.integerValue => () {
        if (newValue is! int) {
          return 'invalidInteger';
        }
        final min = setting.minInt;
        final max = setting.maxInt;
        if (min != null && newValue < min) {
          return 'belowMin';
        }
        if (max != null && newValue > max) {
          return 'aboveMax';
        }
        return null;
      }(),
  };
}
