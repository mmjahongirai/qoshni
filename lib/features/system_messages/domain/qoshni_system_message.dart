import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_category.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_locale_content.dart';

/// Synthetic audience scope for demo system messages (not real targeting).
class QoshniSystemMessage {
  const QoshniSystemMessage({
    required this.messageId,
    required this.messageKey,
    required this.audienceScope,
    required this.category,
    required this.lifecycleStatus,
    required this.localizedContent,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.visibleFrom,
    this.visibleUntil,
    this.internalNavigationRoute,
  });

  final String messageId;
  final String messageKey;
  final String audienceScope;
  final QoshniSystemMessageCategory category;
  final QoshniSystemMessageLifecycleStatus lifecycleStatus;
  final Map<QoshniNotificationTemplateLocale, QoshniSystemMessageLocaleContent>
      localizedContent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final DateTime? visibleFrom;
  final DateTime? visibleUntil;
  final String? internalNavigationRoute;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;

  QoshniSystemMessage copyWith({
    QoshniSystemMessageLifecycleStatus? lifecycleStatus,
    DateTime? publishedAt,
    DateTime? visibleFrom,
    DateTime? visibleUntil,
    DateTime? updatedAt,
    String? internalNavigationRoute,
  }) {
    return QoshniSystemMessage(
      messageId: messageId,
      messageKey: messageKey,
      audienceScope: audienceScope,
      category: category,
      lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
      localizedContent: localizedContent,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      visibleFrom: visibleFrom ?? this.visibleFrom,
      visibleUntil: visibleUntil ?? this.visibleUntil,
      internalNavigationRoute:
          internalNavigationRoute ?? this.internalNavigationRoute,
    );
  }
}
