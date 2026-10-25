import 'package:qoshni/features/conversations/data/qoshni_conversation_demo_seed.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_lifecycle_policy.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_lifecycle_state.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_message.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_operation_result.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant_role.dart';
import 'package:qoshni/features/conversations/domain/repositories/qoshni_conversation_repository.dart';
import 'package:qoshni/features/conversations/presentation/qoshni_conversation_validation.dart';

class InMemoryQoshniConversationRepository implements QoshniConversationRepository {
  InMemoryQoshniConversationRepository({
    QoshniConversationDemoSeed? seed,
  }) : _seed = seed ?? buildQoshniConversationDemoSeed() {
    _conversations = _seed.conversations.map(_cloneConversation).toList();
    _messages = {
      for (final entry in _seed.messagesByConversationId.entries)
        entry.key: entry.value.map(_cloneMessage).toList(growable: true),
    };
    _validateInitialState();
  }

  final QoshniConversationDemoSeed _seed;
  late List<QoshniConversation> _conversations;
  late Map<String, List<QoshniConversationMessage>> _messages;
  final Map<String, DateTime> _lastReadAtByParticipantConversation = {};

  bool failNextMutation = false;

  void _validateInitialState() {
    final seenConvIds = <String>{};
    final seenDemoRefs = <String>{};
    for (final conversation in _conversations) {
      if (!seenConvIds.add(conversation.conversationId)) {
        throw StateError('duplicate conversation id');
      }
      if (!seenDemoRefs.add(conversation.demoReference)) {
        throw StateError('duplicate conversation demo reference');
      }
    }
    final seenMessageIds = <String>{};
    for (final entry in _messages.entries) {
      for (final message in entry.value) {
        if (message.conversationId != entry.key) {
          throw StateError('cross conversation message seed leak');
        }
        if (!seenMessageIds.add(message.messageId)) {
          throw StateError('duplicate message id');
        }
      }
    }
  }

  @override
  List<QoshniConversation> listForParticipant(String participantReference) {
    if (qoshniConversationParticipantReferenceValidationError(
          participantReference,
        ) !=
        null) {
      return const [];
    }
    final ref = participantReference.trim();
    final result = _conversations
        .where((c) => c.includesParticipant(ref))
        .toList(growable: true)
      ..sort((a, b) {
        final aTime = a.lastMessageAt ?? a.updatedAt;
        final bTime = b.lastMessageAt ?? b.updatedAt;
        return bTime.compareTo(aTime);
      });
    return List.unmodifiable(result.map(_cloneConversation));
  }

  @override
  QoshniConversation? getConversation(
    String conversationId, {
    required String participantReference,
  }) {
    final conversation = _findConversation(conversationId);
    if (conversation == null) {
      return null;
    }
    if (!conversation.includesParticipant(participantReference.trim())) {
      return null;
    }
    return _cloneConversation(conversation);
  }

  @override
  List<QoshniConversationMessage> listMessages(
    String conversationId, {
    required String participantReference,
  }) {
    final conversation = getConversation(
      conversationId,
      participantReference: participantReference,
    );
    if (conversation == null) {
      return const [];
    }
    final messages = _messages[conversationId];
    if (messages == null) {
      return const [];
    }
    final sorted = List<QoshniConversationMessage>.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(sorted.map(_cloneMessage));
  }

  @override
  QoshniConversationSendMessageResult sendMessage({
    required String conversationId,
    required String senderReference,
    required QoshniConversationParticipantRole senderRole,
    required String rawBody,
    required DateTime createdAtUtc,
    required String messageId,
    String? replyToMessageId,
  }) {
    if (failNextMutation) {
      return QoshniConversationSendMessageResult.validationFailed;
    }
    if (qoshniConversationMessageIdValidationError(messageId) != null) {
      return QoshniConversationSendMessageResult.validationFailed;
    }
    if (qoshniConversationParticipantReferenceValidationError(senderReference) !=
        null) {
      return QoshniConversationSendMessageResult.validationFailed;
    }
    final bodyError = qoshniConversationMessageBodyValidationError(rawBody);
    if (bodyError != null) {
      return QoshniConversationSendMessageResult.validationFailed;
    }

    final index = _indexOfConversation(conversationId);
    if (index == null) {
      return QoshniConversationSendMessageResult.notFound;
    }
    final conversation = _conversations[index];
    if (!conversation.includesParticipant(senderReference.trim())) {
      return QoshniConversationSendMessageResult.notParticipant;
    }
    if (!QoshniConversationLifecyclePolicy.allowsSending(
      conversation.lifecycleState,
    )) {
      return QoshniConversationSendMessageResult.conversationNotOpen;
    }

    final participant = conversation.participants.firstWhere(
      (p) => p.participantReference == senderReference.trim(),
    );
    if (participant.role != senderRole) {
      return QoshniConversationSendMessageResult.validationFailed;
    }

    final messages = _messages.putIfAbsent(
      conversationId,
      () => <QoshniConversationMessage>[],
    );
    if (messages.any((m) => m.messageId == messageId)) {
      return QoshniConversationSendMessageResult.validationFailed;
    }

    if (replyToMessageId != null) {
      final target = messages
          .where((m) => m.messageId == replyToMessageId.trim())
          .firstOrNull;
      if (target == null) {
        return QoshniConversationSendMessageResult.invalidReplyTarget;
      }
    }

    final body = normalizeQoshniConversationMessageBody(rawBody);
    final message = QoshniConversationMessage(
      messageId: messageId.trim(),
      conversationId: conversationId.trim(),
      senderReference: senderReference.trim(),
      senderRole: senderRole,
      body: body,
      createdAt: createdAtUtc.toUtc(),
      replyToMessageId: replyToMessageId?.trim(),
    );
    messages.add(message);

    _conversations[index] = conversation.copyWith(
      updatedAt: createdAtUtc.toUtc(),
      lastMessageId: message.messageId,
      lastMessagePreview: previewFromMessageBody(body),
      lastMessageAt: createdAtUtc.toUtc(),
    );

    return QoshniConversationSendMessageResult.success;
  }

  @override
  QoshniConversationMutationResult closeConversation({
    required String conversationId,
    required String actorReference,
    required DateTime updatedAtUtc,
  }) {
    return _transition(
      conversationId: conversationId,
      actorReference: actorReference,
      to: QoshniConversationLifecycleState.closed,
      updatedAtUtc: updatedAtUtc,
    );
  }

  @override
  QoshniConversationMutationResult reopenConversation({
    required String conversationId,
    required String actorReference,
    required DateTime updatedAtUtc,
  }) {
    return _transition(
      conversationId: conversationId,
      actorReference: actorReference,
      to: QoshniConversationLifecycleState.open,
      updatedAtUtc: updatedAtUtc,
    );
  }

  @override
  QoshniConversationMutationResult archiveConversation({
    required String conversationId,
    required String actorReference,
    required DateTime updatedAtUtc,
  }) {
    return _transition(
      conversationId: conversationId,
      actorReference: actorReference,
      to: QoshniConversationLifecycleState.archived,
      updatedAtUtc: updatedAtUtc,
    );
  }

  QoshniConversationMutationResult _transition({
    required String conversationId,
    required String actorReference,
    required QoshniConversationLifecycleState to,
    required DateTime updatedAtUtc,
  }) {
    if (failNextMutation) {
      return QoshniConversationMutationResult.validationFailed;
    }
    final index = _indexOfConversation(conversationId);
    if (index == null) {
      return QoshniConversationMutationResult.notFound;
    }
    final conversation = _conversations[index];
    if (!conversation.includesParticipant(actorReference.trim())) {
      return QoshniConversationMutationResult.notParticipant;
    }
    if (!QoshniConversationLifecyclePolicy.canTransition(
      conversation.lifecycleState,
      to,
    )) {
      return QoshniConversationMutationResult.invalidTransition;
    }
    _conversations[index] = conversation.copyWith(
      lifecycleState: to,
      updatedAt: updatedAtUtc.toUtc(),
    );
    return QoshniConversationMutationResult.success;
  }

  @override
  void markConversationRead({
    required String conversationId,
    required String participantReference,
    required DateTime readAtUtc,
  }) {
    final conversation = getConversation(
      conversationId,
      participantReference: participantReference,
    );
    if (conversation == null) {
      return;
    }
    final key = _readKey(participantReference, conversationId);
    _lastReadAtByParticipantConversation[key] = readAtUtc.toUtc();
  }

  @override
  int unreadMessageCount({required String participantReference}) {
    final ref = participantReference.trim();
    var count = 0;
    for (final conversation in listForParticipant(ref)) {
      final messages = _messages[conversation.conversationId] ?? const [];
      final lastRead = _lastReadAtByParticipantConversation[
          _readKey(ref, conversation.conversationId)];
      for (final message in messages) {
        if (message.senderReference == ref) {
          continue;
        }
        if (lastRead == null || message.createdAt.isAfter(lastRead)) {
          count++;
        }
      }
    }
    return count;
  }

  String _readKey(String participantReference, String conversationId) {
    return '${participantReference.trim()}::${conversationId.trim()}';
  }

  QoshniConversation? _findConversation(String conversationId) {
    return _conversations
        .where((c) => c.conversationId == conversationId.trim())
        .firstOrNull;
  }

  int? _indexOfConversation(String conversationId) {
    final id = conversationId.trim();
    for (var i = 0; i < _conversations.length; i++) {
      if (_conversations[i].conversationId == id) {
        return i;
      }
    }
    return null;
  }

  static QoshniConversation _cloneConversation(QoshniConversation c) {
    return QoshniConversation(
      conversationId: c.conversationId,
      demoReference: c.demoReference,
      type: c.type,
      lifecycleState: c.lifecycleState,
      participants: List.unmodifiable(c.participants),
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      businessScopeLabel: c.businessScopeLabel,
      branchScopeLabel: c.branchScopeLabel,
      lastMessageId: c.lastMessageId,
      lastMessagePreview: c.lastMessagePreview,
      lastMessageAt: c.lastMessageAt,
    );
  }

  static QoshniConversationMessage _cloneMessage(QoshniConversationMessage m) {
    return QoshniConversationMessage(
      messageId: m.messageId,
      conversationId: m.conversationId,
      senderReference: m.senderReference,
      senderRole: m.senderRole,
      body: m.body,
      createdAt: m.createdAt,
      replyToMessageId: m.replyToMessageId,
      status: m.status,
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
