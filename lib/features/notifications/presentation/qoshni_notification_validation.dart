import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_internal_navigation.dart';

const int kQoshniNotificationTitleMaxLength = 120;
const int kQoshniNotificationBodyMaxLength = 500;
const int kQoshniNotificationDeduplicationMaxLength = 200;
const int kQoshniNotificationRecipientMaxLength = 80;

String? qoshniNotificationDeliverValidationError(
  QoshniNotificationDeliverInput input,
) {
  final recipient = input.demoRecipientReference.trim();
  if (recipient.isEmpty || recipient.length > kQoshniNotificationRecipientMaxLength) {
    return 'invalid_recipient';
  }
  if (!_isSafeReferenceToken(recipient)) {
    return 'unsafe_recipient';
  }

  final title = input.title.trim();
  if (title.isEmpty || title.length > kQoshniNotificationTitleMaxLength) {
    return 'invalid_title';
  }
  if (!_isSafeNotificationText(title)) {
    return 'unsafe_title';
  }

  final body = input.body.trim();
  if (body.isEmpty || body.length > kQoshniNotificationBodyMaxLength) {
    return 'invalid_body';
  }
  if (!_isSafeNotificationText(body)) {
    return 'unsafe_body';
  }

  final route = input.internalNavigationRoute?.trim();
  if (route != null &&
      route.isNotEmpty &&
      !isAllowedQoshniNotificationInternalRoute(route)) {
    return 'invalid_navigation_route';
  }

  final dedupe = input.deduplicationReference?.trim();
  if (dedupe != null) {
    if (dedupe.isEmpty || dedupe.length > kQoshniNotificationDeduplicationMaxLength) {
      return 'invalid_deduplication';
    }
    if (!_isSafeReferenceToken(dedupe)) {
      return 'unsafe_deduplication';
    }
  }

  return null;
}

String? qoshniNotificationIdValidationError(String notificationId) {
  final id = notificationId.trim();
  if (id.isEmpty || id.length > 120) {
    return 'invalid_id';
  }
  if (!_isSafeReferenceToken(id)) {
    return 'unsafe_id';
  }
  return null;
}

bool _isSafeReferenceToken(String value) {
  if (value.contains('@') || value.contains('+998')) {
    return false;
  }
  final lower = value.toLowerCase();
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('javascript:')) {
    return false;
  }
  return true;
}

bool _isSafeNotificationText(String value) {
  if (!_isSafeReferenceToken(value)) {
    return false;
  }
  final lower = value.toLowerCase();
  if (lower.contains('password') ||
      lower.contains('credit card') ||
      lower.contains('iban')) {
    return false;
  }
  return true;
}
