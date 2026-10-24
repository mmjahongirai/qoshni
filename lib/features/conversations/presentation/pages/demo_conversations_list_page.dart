import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation.dart';
import 'package:qoshni/features/conversations/presentation/qoshni_conversation_controller.dart';
import 'package:qoshni/features/conversations/presentation/qoshni_conversation_labels.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_date_format.dart';
import 'package:qoshni/routing/route_paths.dart';

class DemoConversationsListPage extends StatelessWidget {
  const DemoConversationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final controller = getIt<QoshniConversationController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.demoConversationsListTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final conversations = controller.conversations;
            return ResponsiveLayout(
              phone: _Body(
                maxWidth: 520,
                l10n: l10n,
                locale: locale,
                conversations: conversations,
              ),
              tablet: _Body(
                maxWidth: 720,
                l10n: l10n,
                locale: locale,
                conversations: conversations,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.maxWidth,
    required this.l10n,
    required this.locale,
    required this.conversations,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final String locale;
  final List<QoshniConversation> conversations;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.demoConversationsDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            if (conversations.isEmpty)
              AppSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(l10n.demoConversationsEmpty),
                ),
              )
            else
              for (final conversation in conversations)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppSurfaceCard(
                    onTap: () => context.push(
                      RoutePaths.demoConversationDetailPath(
                        conversation.conversationId,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.businessScopeLabel ??
                                qoshniConversationTypeLabel(
                                  l10n,
                                  conversation.type,
                                ),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            l10n.demoConversationListMetaLine(
                              qoshniConversationLifecycleLabel(
                                l10n,
                                conversation.lifecycleState,
                              ),
                              conversation.lastMessagePreview ?? '—',
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (conversation.lastMessageAt != null)
                            Text(
                              formatQoshniNotificationTimestamp(
                                conversation.lastMessageAt!,
                                locale,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
