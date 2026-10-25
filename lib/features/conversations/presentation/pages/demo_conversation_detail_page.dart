import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_lifecycle_policy.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_message.dart';
import 'package:qoshni/features/conversations/presentation/qoshni_conversation_controller.dart';
import 'package:qoshni/features/conversations/presentation/qoshni_conversation_labels.dart';
import 'package:qoshni/features/conversations/presentation/qoshni_conversation_validation.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_date_format.dart';

class DemoConversationDetailPage extends StatefulWidget {
  const DemoConversationDetailPage({
    super.key,
    required this.conversationId,
  });

  final String? conversationId;

  @override
  State<DemoConversationDetailPage> createState() =>
      _DemoConversationDetailPageState();
}

class _DemoConversationDetailPageState extends State<DemoConversationDetailPage> {
  final _composerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.conversationId;
      if (id != null) {
        getIt<QoshniConversationController>().markRead(id);
      }
    });
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final controller = getIt<QoshniConversationController>();
    final conversationId = widget.conversationId?.trim();

    if (conversationId == null || conversationId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.demoConversationDetailTitle),
        ),
        body: Center(child: Text(l10n.demoConversationNotFound)),
      );
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final conversation = controller.conversation(conversationId);
        if (conversation == null) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: Text(l10n.demoConversationDetailTitle),
            ),
            body: Center(child: Text(l10n.demoConversationNotFound)),
          );
        }

        final messages = controller.messages(conversationId);
        final canSend = QoshniConversationLifecyclePolicy.allowsSending(
          conversation.lifecycleState,
        );
        final bodyError = qoshniConversationMessageBodyValidationError(
          _composerController.text,
        );

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: Text(
              conversation.businessScopeLabel ??
                  qoshniConversationTypeLabel(l10n, conversation.type),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppMessageBanner(
                    message: l10n.demoConversationsDisclaimer,
                    icon: Icons.info_outline,
                    tone: AppMessageTone.info,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      qoshniConversationLifecycleLabel(
                        l10n,
                        conversation.lifecycleState,
                      ),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _MessageBubble(
                        l10n: l10n,
                        locale: locale,
                        message: message,
                        isMine: message.senderReference ==
                            controller.activeParticipant,
                      );
                    },
                  ),
                ),
                if (!canSend)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(l10n.demoConversationComposerDisabledClosed),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _composerController,
                          enabled: canSend,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: l10n.demoConversationComposerHint,
                            errorText: bodyError != null && _composerController.text.isNotEmpty
                                ? qoshniConversationSendErrorLabel(
                                    l10n,
                                    bodyError,
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        onPressed: !canSend || bodyError != null
                            ? null
                            : () {
                                final ok = controller.sendMessage(
                                  conversationId: conversationId,
                                  rawBody: _composerController.text,
                                );
                                if (ok) {
                                  _composerController.clear();
                                  setState(() {});
                                  return;
                                }
                                final code =
                                    controller.lastSendErrorCode ?? 'failed';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      qoshniConversationSendErrorLabel(
                                        l10n,
                                        code == 'validation_failed'
                                            ? (bodyError ?? code)
                                            : code,
                                      ),
                                    ),
                                  ),
                                );
                              },
                        child: Text(l10n.demoConversationSendAction),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.l10n,
    required this.locale,
    required this.message,
    required this.isMine,
  });

  final AppLocalizations l10n;
  final String locale;
  final QoshniConversationMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMine
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AppSurfaceCard(
          child: Container(
            color: color,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qoshniConversationParticipantRoleLabel(
                    l10n,
                    message.senderRole,
                  ),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(message.body),
                Text(
                  formatQoshniNotificationTimestamp(message.createdAt, locale),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
