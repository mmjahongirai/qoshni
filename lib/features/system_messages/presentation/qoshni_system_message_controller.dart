import 'package:flutter/foundation.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/system_messages/data/qoshni_system_message_demo_seed.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_category.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_content_resolver.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_mutation_result.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_resolved_content.dart';
import 'package:qoshni/features/system_messages/domain/repositories/qoshni_system_message_repository.dart';

typedef QoshniSystemMessageClock = DateTime Function();

class QoshniSystemMessageController extends ChangeNotifier {
  QoshniSystemMessageController(
    this._repository, {
    QoshniSystemMessageClock? clock,
  }) : _clock = clock ?? DateTime.now;

  final QoshniSystemMessageRepository _repository;
  final QoshniSystemMessageClock _clock;

  String _demoRecipientReference = kDemoSystemMessageRecipientPrimary;
  QoshniSystemMessageCategory? _categoryFilter;
  QoshniNotificationTemplateLocale _previewLocale =
      QoshniNotificationTemplateLocale.en;
  String? _lastOperationKey;

  String get demoRecipientReference => _demoRecipientReference;
  QoshniSystemMessageCategory? get categoryFilter => _categoryFilter;
  QoshniNotificationTemplateLocale get previewLocale => _previewLocale;
  String? get lastOperationKey => _lastOperationKey;

  DateTime get evaluationUtc => _clock().toUtc();

  void setDemoRecipientReference(String reference) {
    final trimmed = reference.trim();
    if (_demoRecipientReference == trimmed) {
      return;
    }
    _demoRecipientReference = trimmed;
    notifyListeners();
  }

  void setCategoryFilter(QoshniSystemMessageCategory? category) {
    if (_categoryFilter == category) {
      return;
    }
    _categoryFilter = category;
    notifyListeners();
  }

  void setPreviewLocale(QoshniNotificationTemplateLocale locale) {
    if (_previewLocale == locale) {
      return;
    }
    _previewLocale = locale;
    notifyListeners();
  }

  List<QoshniSystemMessage> get visibleMessages => _repository.visibleMessages(
        evaluationUtc: evaluationUtc,
        category: _categoryFilter,
        demoRecipientReference: _demoRecipientReference,
      );

  int get unreadCount => _repository.unreadCount(
        demoRecipientReference: _demoRecipientReference,
        evaluationUtc: evaluationUtc,
      );

  bool isUnread(QoshniSystemMessage message) {
    return !_repository.isRead(
      demoRecipientReference: _demoRecipientReference,
      messageId: message.messageId,
    );
  }

  QoshniSystemMessageResolvedContent? resolvedContent(
    QoshniSystemMessage message,
  ) {
    return QoshniSystemMessageContentResolver.resolve(
      message: message,
      requestedLocale: _previewLocale,
    );
  }

  void markRead(String messageId) {
    final result = _repository.markRead(
      demoRecipientReference: _demoRecipientReference,
      messageId: messageId,
      readAtUtc: evaluationUtc,
    );
    _lastOperationKey = switch (result) {
      QoshniSystemMessageReadResult.success => 'markReadSuccess',
      QoshniSystemMessageReadResult.alreadyRead => 'markReadAlready',
      QoshniSystemMessageReadResult.notFound => 'markReadNotFound',
      QoshniSystemMessageReadResult.invalidRecipient => 'markReadInvalid',
    };
    notifyListeners();
  }

  void markAllVisibleRead() {
    final result = _repository.markAllVisibleRead(
      demoRecipientReference: _demoRecipientReference,
      evaluationUtc: evaluationUtc,
      readAtUtc: evaluationUtc,
    );
    _lastOperationKey = switch (result) {
      QoshniSystemMessageReadResult.success => 'markAllReadSuccess',
      _ => 'markAllReadFailure',
    };
    notifyListeners();
  }

  QoshniSystemMessageMutationResult publishDraft(String messageId) {
    final result = _repository.publish(
      messageId: messageId,
      publishedAtUtc: evaluationUtc,
    );
    notifyListeners();
    return result;
  }

  QoshniSystemMessageMutationResult withdrawMessage(String messageId) {
    final result = _repository.withdraw(
      messageId: messageId,
      updatedAtUtc: evaluationUtc,
    );
    notifyListeners();
    return result;
  }

  QoshniSystemMessageMutationResult archiveMessage(String messageId) {
    final result = _repository.archive(
      messageId: messageId,
      updatedAtUtc: evaluationUtc,
    );
    notifyListeners();
    return result;
  }

  List<QoshniSystemMessage> managementList() {
    return _repository.list();
  }
}
