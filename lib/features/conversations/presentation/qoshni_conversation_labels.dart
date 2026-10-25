import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_lifecycle_state.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant_role.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_type.dart';

String qoshniConversationTypeLabel(
  AppLocalizations l10n,
  QoshniConversationType type,
) {
  return switch (type) {
    QoshniConversationType.customerBusiness =>
      l10n.demoConversationTypeCustomerBusiness,
    QoshniConversationType.supportDemo => l10n.demoConversationTypeSupportDemo,
  };
}

String qoshniConversationLifecycleLabel(
  AppLocalizations l10n,
  QoshniConversationLifecycleState state,
) {
  return switch (state) {
    QoshniConversationLifecycleState.open => l10n.demoConversationStateOpen,
    QoshniConversationLifecycleState.closed => l10n.demoConversationStateClosed,
    QoshniConversationLifecycleState.archived =>
      l10n.demoConversationStateArchived,
  };
}

String qoshniConversationParticipantRoleLabel(
  AppLocalizations l10n,
  QoshniConversationParticipantRole role,
) {
  return switch (role) {
    QoshniConversationParticipantRole.customer =>
      l10n.demoConversationRoleCustomer,
    QoshniConversationParticipantRole.businessAgent =>
      l10n.demoConversationRoleBusinessAgent,
    QoshniConversationParticipantRole.supportAgent =>
      l10n.demoConversationRoleSupportAgent,
  };
}

String qoshniConversationSendErrorLabel(
  AppLocalizations l10n,
  String errorCode,
) {
  return switch (errorCode) {
    'empty_message' || 'message_too_long' => l10n.demoConversationSendValidationError,
    'conversation_not_open' => l10n.demoConversationSendNotOpen,
    'markup_not_allowed' || 'url_not_allowed' || 'sensitive_content' =>
      l10n.demoConversationSendUnsafeContent,
    _ => l10n.demoConversationSendFailure,
  };
}
