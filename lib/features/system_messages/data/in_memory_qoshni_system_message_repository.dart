import 'package:qoshni/features/system_messages/data/qoshni_system_message_demo_seed.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_category.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_policy.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_mutation_result.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_visibility_policy.dart';
import 'package:qoshni/features/system_messages/domain/repositories/qoshni_system_message_repository.dart';
import 'package:qoshni/features/system_messages/presentation/qoshni_system_message_validation.dart';

class InMemoryQoshniSystemMessageRepository
    implements QoshniSystemMessageRepository {
  InMemoryQoshniSystemMessageRepository({
    List<QoshniSystemMessage>? seed,
  }) : _messages = _validateSeed(seed ?? buildQoshniSystemMessageDemoSeed());

  final List<QoshniSystemMessage> _messages;
  final Map<String, Map<String, DateTime>> _readStateByRecipient = {};

  bool failNextMutation = false;

  static List<QoshniSystemMessage> _validateSeed(
    List<QoshniSystemMessage> seed,
  ) {
    final seenIds = <String>{};
    final seenKeys = <String>{};
    for (final message in seed) {
      if (!seenIds.add(message.messageId)) {
        throw StateError('duplicate message id: ${message.messageId}');
      }
      if (!seenKeys.add(message.messageKey)) {
        throw StateError('duplicate message key: ${message.messageKey}');
      }
      final contentError = qoshniSystemMessageLocalizedContentValidationError(
        message.localizedContent,
      );
      if (contentError != null &&
          message.lifecycleStatus ==
              QoshniSystemMessageLifecycleStatus.published) {
        throw StateError(
          'invalid published seed ${message.messageId}: $contentError',
        );
      }
      final routeError = qoshniSystemMessageNavigationRouteValidationError(
        message.internalNavigationRoute,
      );
      if (routeError != null) {
        throw StateError(
          'invalid route on ${message.messageId}: $routeError',
        );
      }
    }
    return seed.map(_cloneMessage).toList(growable: true);
  }

  static QoshniSystemMessage _cloneMessage(QoshniSystemMessage message) {
    return QoshniSystemMessage(
      messageId: message.messageId,
      messageKey: message.messageKey,
      audienceScope: message.audienceScope,
      category: message.category,
      lifecycleStatus: message.lifecycleStatus,
      localizedContent: Map.unmodifiable(message.localizedContent),
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
      publishedAt: message.publishedAt,
      visibleFrom: message.visibleFrom,
      visibleUntil: message.visibleUntil,
      internalNavigationRoute: message.internalNavigationRoute,
    );
  }

  @override
  List<QoshniSystemMessage> list({
    QoshniSystemMessageLifecycleStatus? lifecycleStatus,
    QoshniSystemMessageCategory? category,
  }) {
    var result = List<QoshniSystemMessage>.from(_messages);
    if (lifecycleStatus != null) {
      result =
          result.where((m) => m.lifecycleStatus == lifecycleStatus).toList(
                growable: true,
              );
    }
    if (category != null) {
      result = result.where((m) => m.category == category).toList(growable: true);
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(result);
  }

  @override
  QoshniSystemMessage? getById(String messageId) {
    final id = messageId.trim();
    for (final message in _messages) {
      if (message.messageId == id) {
        return _cloneMessage(message);
      }
    }
    return null;
  }

  @override
  List<QoshniSystemMessage> visibleMessages({
    required DateTime evaluationUtc,
    QoshniSystemMessageCategory? category,
    required String demoRecipientReference,
  }) {
    if (qoshniSystemMessageRecipientValidationError(demoRecipientReference) !=
        null) {
      return const [];
    }
    var result = _messages.where(
      (m) => QoshniSystemMessageVisibilityPolicy.isCurrentlyVisible(
        message: m,
        evaluationUtc: evaluationUtc,
      ),
    );
    if (category != null) {
      result = result.where((m) => m.category == category);
    }
    final sorted = result.toList(growable: true)
      ..sort((a, b) {
        final aTime = a.publishedAt ?? a.createdAt;
        final bTime = b.publishedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
    return List.unmodifiable(sorted.map(_cloneMessage));
  }

  @override
  QoshniSystemMessageMutationResult publish({
    required String messageId,
    required DateTime publishedAtUtc,
  }) {
    if (failNextMutation) {
      return QoshniSystemMessageMutationResult.validationFailed;
    }
    final index = _indexOf(messageId);
    if (index == null) {
      return QoshniSystemMessageMutationResult.notFound;
    }
    final current = _messages[index];
    if (!QoshniSystemMessageLifecyclePolicy.canTransition(
      current.lifecycleStatus,
      QoshniSystemMessageLifecycleStatus.published,
    )) {
      return QoshniSystemMessageMutationResult.invalidTransition;
    }
    final contentError = qoshniSystemMessageLocalizedContentValidationError(
      current.localizedContent,
    );
    if (contentError != null) {
      return QoshniSystemMessageMutationResult.validationFailed;
    }
    final windowError = qoshniSystemMessageWindowValidationError(
      visibleFrom: current.visibleFrom,
      visibleUntil: current.visibleUntil,
      publishedAt: publishedAtUtc.toUtc(),
    );
    if (windowError != null) {
      return QoshniSystemMessageMutationResult.validationFailed;
    }
    final routeError = qoshniSystemMessageNavigationRouteValidationError(
      current.internalNavigationRoute,
    );
    if (routeError != null) {
      return QoshniSystemMessageMutationResult.validationFailed;
    }
    final candidate = current.copyWith(
      lifecycleStatus: QoshniSystemMessageLifecycleStatus.published,
      publishedAt: publishedAtUtc.toUtc(),
      updatedAt: publishedAtUtc.toUtc(),
    );
    _messages[index] = candidate;
    return QoshniSystemMessageMutationResult.success;
  }

  @override
  QoshniSystemMessageMutationResult withdraw({
    required String messageId,
    required DateTime updatedAtUtc,
  }) {
    return _transition(
      messageId: messageId,
      to: QoshniSystemMessageLifecycleStatus.withdrawn,
      updatedAtUtc: updatedAtUtc,
    );
  }

  @override
  QoshniSystemMessageMutationResult archive({
    required String messageId,
    required DateTime updatedAtUtc,
  }) {
    return _transition(
      messageId: messageId,
      to: QoshniSystemMessageLifecycleStatus.archived,
      updatedAtUtc: updatedAtUtc,
    );
  }

  QoshniSystemMessageMutationResult _transition({
    required String messageId,
    required QoshniSystemMessageLifecycleStatus to,
    required DateTime updatedAtUtc,
  }) {
    if (failNextMutation) {
      return QoshniSystemMessageMutationResult.validationFailed;
    }
    final index = _indexOf(messageId);
    if (index == null) {
      return QoshniSystemMessageMutationResult.notFound;
    }
    final current = _messages[index];
    if (!QoshniSystemMessageLifecyclePolicy.canTransition(
      current.lifecycleStatus,
      to,
    )) {
      return QoshniSystemMessageMutationResult.invalidTransition;
    }
    _messages[index] = current.copyWith(
      lifecycleStatus: to,
      updatedAt: updatedAtUtc.toUtc(),
    );
    return QoshniSystemMessageMutationResult.success;
  }

  @override
  QoshniSystemMessageReadResult markRead({
    required String demoRecipientReference,
    required String messageId,
    required DateTime readAtUtc,
  }) {
    if (qoshniSystemMessageRecipientValidationError(demoRecipientReference) !=
        null) {
      return QoshniSystemMessageReadResult.invalidRecipient;
    }
    if (_indexOf(messageId) == null) {
      return QoshniSystemMessageReadResult.notFound;
    }
    final reads = _readsFor(demoRecipientReference);
    if (reads.containsKey(messageId)) {
      return QoshniSystemMessageReadResult.alreadyRead;
    }
    reads[messageId] = readAtUtc.toUtc();
    return QoshniSystemMessageReadResult.success;
  }

  @override
  QoshniSystemMessageReadResult markAllVisibleRead({
    required String demoRecipientReference,
    required DateTime evaluationUtc,
    required DateTime readAtUtc,
  }) {
    if (qoshniSystemMessageRecipientValidationError(demoRecipientReference) !=
        null) {
      return QoshniSystemMessageReadResult.invalidRecipient;
    }
    final visible = visibleMessages(
      evaluationUtc: evaluationUtc,
      demoRecipientReference: demoRecipientReference,
    );
    final reads = _readsFor(demoRecipientReference);
    for (final message in visible) {
      reads.putIfAbsent(message.messageId, () => readAtUtc.toUtc());
    }
    return QoshniSystemMessageReadResult.success;
  }

  @override
  bool isRead({
    required String demoRecipientReference,
    required String messageId,
  }) {
    return _readsFor(demoRecipientReference).containsKey(messageId);
  }

  @override
  int unreadCount({
    required String demoRecipientReference,
    required DateTime evaluationUtc,
  }) {
    final visible = visibleMessages(
      evaluationUtc: evaluationUtc,
      demoRecipientReference: demoRecipientReference,
    );
    final reads = _readsFor(demoRecipientReference);
    var count = 0;
    for (final message in visible) {
      if (!reads.containsKey(message.messageId)) {
        count++;
      }
    }
    return count;
  }

  @override
  DateTime? readAt({
    required String demoRecipientReference,
    required String messageId,
  }) {
    return _readsFor(demoRecipientReference)[messageId];
  }

  Map<String, DateTime> _readsFor(String demoRecipientReference) {
    return _readStateByRecipient.putIfAbsent(
      demoRecipientReference.trim(),
      () => {},
    );
  }

  int? _indexOf(String messageId) {
    final id = messageId.trim();
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[i].messageId == id) {
        return i;
      }
    }
    return null;
  }
}
