import 'package:flutter/foundation.dart';
import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_policy.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_preferences.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_preference_repository.dart';

class QoshniNotificationPreferenceController extends ChangeNotifier {
  QoshniNotificationPreferenceController(this._repository);

  final QoshniNotificationPreferenceRepository _repository;

  String? lastOperationMessageKey;

  QoshniNotificationPreferences get preferences => _repository.preferences;

  QoshniNotificationPreferenceUpdateResult setCategoryEnabled({
    required QoshniNotificationCategory category,
    required bool enabled,
  }) {
    final result = _repository.setCategoryEnabled(
      category: category,
      enabled: enabled,
    );
    _setOperationKey(_categoryKey(result));
    notifyListeners();
    return result;
  }

  QoshniNotificationPreferenceUpdateResult setChannelEnabled({
    required QoshniNotificationChannel channel,
    required bool enabled,
  }) {
    final result = _repository.setChannelEnabled(
      channel: channel,
      enabled: enabled,
    );
    _setOperationKey(_channelKey(result));
    notifyListeners();
    return result;
  }

  QoshniNotificationPreferenceUpdateResult setPromotionalMarketingConsent(
    bool consent,
  ) {
    final result = _repository.setPromotionalMarketingConsent(consent: consent);
    _setOperationKey(_promoKey(result));
    notifyListeners();
    return result;
  }

  QoshniNotificationPreferenceUpdateResult setQuietHours({
    required bool enabled,
    required QoshniLocalTime start,
    required QoshniLocalTime end,
  }) {
    final result = _repository.setQuietHours(
      enabled: enabled,
      start: start,
      end: end,
    );
    _setOperationKey(_quietHoursKey(result));
    notifyListeners();
    return result;
  }

  QoshniNotificationPreferenceUpdateResult restoreDemoDefaults() {
    final result = _repository.restoreDemoDefaults();
    _setOperationKey(_restoreKey(result));
    notifyListeners();
    return result;
  }

  QoshniNotificationEligibilityResult evaluateHypothetical({
    required QoshniNotificationEligibilityInput scenario,
    required DateTime evaluationLocalDateTime,
  }) {
    return QoshniNotificationDeliveryPolicy.evaluate(
      preferences: preferences,
      scenario: scenario,
      evaluationLocalDateTime: evaluationLocalDateTime,
    );
  }

  void _setOperationKey(String? key) {
    lastOperationMessageKey = key;
  }

  String? _categoryKey(QoshniNotificationPreferenceUpdateResult result) {
    return switch (result) {
      QoshniNotificationPreferenceUpdateResult.success =>
        'preferenceSaveSuccess',
      QoshniNotificationPreferenceUpdateResult.invalidInput =>
        'preferenceSaveInvalid',
      QoshniNotificationPreferenceUpdateResult.failure =>
        'preferenceSaveFailure',
    };
  }

  String? _channelKey(QoshniNotificationPreferenceUpdateResult result) =>
      _categoryKey(result);

  String? _promoKey(QoshniNotificationPreferenceUpdateResult result) =>
      _categoryKey(result);

  String? _quietHoursKey(QoshniNotificationPreferenceUpdateResult result) =>
      _categoryKey(result);

  String? _restoreKey(QoshniNotificationPreferenceUpdateResult result) {
    return switch (result) {
      QoshniNotificationPreferenceUpdateResult.success =>
        'preferenceRestoreSuccess',
      QoshniNotificationPreferenceUpdateResult.invalidInput =>
        'preferenceSaveInvalid',
      QoshniNotificationPreferenceUpdateResult.failure =>
        'preferenceSaveFailure',
    };
  }
}
