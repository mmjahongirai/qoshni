import 'package:qoshni/features/conversations/domain/qoshni_conversation_lifecycle_state.dart';

abstract final class QoshniConversationLifecyclePolicy {
  static bool canTransition(
    QoshniConversationLifecycleState from,
    QoshniConversationLifecycleState to,
  ) {
    return switch (from) {
      QoshniConversationLifecycleState.open =>
        to == QoshniConversationLifecycleState.closed ||
            to == QoshniConversationLifecycleState.archived,
      QoshniConversationLifecycleState.closed =>
        to == QoshniConversationLifecycleState.open ||
            to == QoshniConversationLifecycleState.archived,
      QoshniConversationLifecycleState.archived => false,
    };
  }

  static bool allowsSending(QoshniConversationLifecycleState state) {
    return state == QoshniConversationLifecycleState.open;
  }
}
