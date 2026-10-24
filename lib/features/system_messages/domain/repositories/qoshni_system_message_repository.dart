import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_category.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_mutation_result.dart';

abstract class QoshniSystemMessageRepository {
  List<QoshniSystemMessage> list({
    QoshniSystemMessageLifecycleStatus? lifecycleStatus,
    QoshniSystemMessageCategory? category,
  });

  QoshniSystemMessage? getById(String messageId);

  List<QoshniSystemMessage> visibleMessages({
    required DateTime evaluationUtc,
    QoshniSystemMessageCategory? category,
    required String demoRecipientReference,
  });

  QoshniSystemMessageMutationResult publish({
    required String messageId,
    required DateTime publishedAtUtc,
  });

  QoshniSystemMessageMutationResult withdraw({
    required String messageId,
    required DateTime updatedAtUtc,
  });

  QoshniSystemMessageMutationResult archive({
    required String messageId,
    required DateTime updatedAtUtc,
  });

  QoshniSystemMessageReadResult markRead({
    required String demoRecipientReference,
    required String messageId,
    required DateTime readAtUtc,
  });

  QoshniSystemMessageReadResult markAllVisibleRead({
    required String demoRecipientReference,
    required DateTime evaluationUtc,
    required DateTime readAtUtc,
  });

  bool isRead({
    required String demoRecipientReference,
    required String messageId,
  });

  int unreadCount({
    required String demoRecipientReference,
    required DateTime evaluationUtc,
  });

  DateTime? readAt({
    required String demoRecipientReference,
    required String messageId,
  });
}
