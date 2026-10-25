import 'package:flutter/foundation.dart';
import 'package:qoshni/features/conversations/data/qoshni_conversation_demo_seed.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_message.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_operation_result.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant_role.dart';
import 'package:qoshni/features/conversations/domain/repositories/qoshni_conversation_repository.dart';

typedef QoshniConversationClock = DateTime Function();
class QoshniConversationController extends ChangeNotifier {
  QoshniConversationController(
    this._repository, {
    QoshniConversationClock? clock,
  }) : _clock = clock ?? DateTime.now;

  final QoshniConversationRepository _repository;
  final QoshniConversationClock _clock;

  String _activeParticipant = kDemoConversationCustomerParticipant;
  int _messageCounter = 0;
  String? _lastSendErrorCode;

  String get activeParticipant => _activeParticipant;
  String? get lastSendErrorCode => _lastSendErrorCode;

  void setActiveParticipant(String participantReference) {
    final trimmed = participantReference.trim();
    if (_activeParticipant == trimmed) {
      return;
    }
    _activeParticipant = trimmed;
    notifyListeners();
  }

  List<QoshniConversation> get conversations =>
      _repository.listForParticipant(_activeParticipant);

  int get unreadCount => _repository.unreadMessageCount(
        participantReference: _activeParticipant,
      );

  QoshniConversation? conversation(String conversationId) {
    return _repository.getConversation(
      conversationId,
      participantReference: _activeParticipant,
    );
  }

  List<QoshniConversationMessage> messages(String conversationId) {
    return _repository.listMessages(
      conversationId,
      participantReference: _activeParticipant,
    );
  }

  void markRead(String conversationId) {
    _repository.markConversationRead(
      conversationId: conversationId,
      participantReference: _activeParticipant,
      readAtUtc: _clock().toUtc(),
    );
    notifyListeners();
  }

  bool sendMessage({
    required String conversationId,
    required String rawBody,
  }) {
    _lastSendErrorCode = null;
    final result = _repository.sendMessage(
      conversationId: conversationId,
      senderReference: _activeParticipant,
      senderRole: QoshniConversationParticipantRole.customer,
      rawBody: rawBody,
      createdAtUtc: _clock().toUtc(),
      messageId: nextMessageId(),
    );
    switch (result) {
      case QoshniConversationSendMessageResult.success:
        notifyListeners();
        return true;
      case QoshniConversationSendMessageResult.conversationNotOpen:
        _lastSendErrorCode = 'conversation_not_open';
      case QoshniConversationSendMessageResult.validationFailed:
        _lastSendErrorCode = 'validation_failed';
      case QoshniConversationSendMessageResult.notParticipant:
        _lastSendErrorCode = 'not_participant';
      case QoshniConversationSendMessageResult.notFound:
        _lastSendErrorCode = 'not_found';
      case QoshniConversationSendMessageResult.invalidReplyTarget:
        _lastSendErrorCode = 'invalid_reply';
    }
    notifyListeners();
    return false;
  }

  String nextMessageId() {
    _messageCounter++;
    return 'demo-msg-${_messageCounter.toString().padLeft(6, '0')}';
  }
}
