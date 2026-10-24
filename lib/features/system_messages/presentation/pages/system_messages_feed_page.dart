import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_request.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_source.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_date_format.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_dispatch_controller.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_dispatch_labels.dart';
import 'package:qoshni/features/system_messages/data/qoshni_system_message_demo_seed.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_category.dart';
import 'package:qoshni/features/system_messages/presentation/qoshni_system_message_controller.dart';
import 'package:qoshni/features/system_messages/presentation/qoshni_system_message_labels.dart';
import 'package:qoshni/routing/route_paths.dart';

class SystemMessagesFeedPage extends StatefulWidget {
  const SystemMessagesFeedPage({super.key});

  @override
  State<SystemMessagesFeedPage> createState() => _SystemMessagesFeedPageState();
}

class _SystemMessagesFeedPageState extends State<SystemMessagesFeedPage> {
  String? _operationFeedback(AppLocalizations l10n, String? key) {
    return switch (key) {
      'markReadSuccess' => l10n.systemMessageMarkReadSuccess,
      'markReadAlready' => l10n.systemMessageMarkReadAlready,
      'markAllReadSuccess' => l10n.systemMessageMarkAllReadSuccess,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final controller = getIt<QoshniSystemMessageController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.systemMessagesFeedTitle),
        actions: [
          IconButton(
            tooltip: l10n.systemMessagesDemoLifecycleTooltip,
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => context.push(RoutePaths.systemMessagesDemoLifecycle),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final messages = controller.visibleMessages;
            final unread = controller.unreadCount;

            return ResponsiveLayout(
              phone: _FeedBody(
                maxWidth: 520,
                l10n: l10n,
                localeTag: localeTag,
                controller: controller,
                messages: messages,
                unreadCount: unread,
                onShowFeedback: () {
                  final message = _operationFeedback(
                    l10n,
                    controller.lastOperationKey,
                  );
                  if (message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
              ),
              tablet: _FeedBody(
                maxWidth: 720,
                l10n: l10n,
                localeTag: localeTag,
                controller: controller,
                messages: messages,
                unreadCount: unread,
                onShowFeedback: () {
                  final message = _operationFeedback(
                    l10n,
                    controller.lastOperationKey,
                  );
                  if (message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeedBody extends StatelessWidget {
  const _FeedBody({
    required this.maxWidth,
    required this.l10n,
    required this.localeTag,
    required this.controller,
    required this.messages,
    required this.unreadCount,
    required this.onShowFeedback,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final String localeTag;
  final QoshniSystemMessageController controller;
  final List<QoshniSystemMessage> messages;
  final int unreadCount;
  final VoidCallback onShowFeedback;

  @override
  Widget build(BuildContext context) {
    final requestedLocale =
        QoshniNotificationTemplateLocale.fromLanguageCode(localeTag) ??
            QoshniNotificationTemplateLocale.en;
    if (controller.previewLocale != requestedLocale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setPreviewLocale(requestedLocale);
      });
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.systemMessagesDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.systemMessageUnreadCount(unreadCount),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<QoshniSystemMessageCategory?>(
              isExpanded: true,
              initialValue: controller.categoryFilter,
              decoration: InputDecoration(
                labelText: l10n.systemMessageCategoryFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.notificationDispatchFilterAll),
                ),
                for (final category in QoshniSystemMessageCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(
                      qoshniSystemMessageCategoryLabel(l10n, category),
                    ),
                  ),
              ],
              onChanged: controller.setCategoryFilter,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  controller.markAllVisibleRead();
                  onShowFeedback();
                },
                child: Text(l10n.systemMessageMarkAllReadAction),
              ),
            ),
            if (messages.isEmpty)
              AppSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(l10n.systemMessagesFeedEmpty),
                ),
              )
            else
              for (final message in messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _MessageCard(
                    l10n: l10n,
                    localeTag: localeTag,
                    controller: controller,
                    message: message,
                    unread: controller.isUnread(message),
                    onMarkRead: () {
                      controller.markRead(message.messageId);
                      onShowFeedback();
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.l10n,
    required this.localeTag,
    required this.controller,
    required this.message,
    required this.unread,
    required this.onMarkRead,
  });

  final AppLocalizations l10n;
  final String localeTag;
  final QoshniSystemMessageController controller;
  final QoshniSystemMessage message;
  final bool unread;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final resolved = controller.resolvedContent(message);
    if (resolved == null) {
      return AppMessageBanner(
        message: l10n.systemMessageContentUnavailable,
        icon: Icons.warning_amber_outlined,
        tone: AppMessageTone.warning,
      );
    }

    final published = message.publishedAt ?? message.createdAt;

    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  unread
                      ? Icons.mark_email_unread_outlined
                      : Icons.drafts_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    resolved.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight:
                              unread ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.systemMessageMetaLine(
                qoshniSystemMessageCategoryLabel(l10n, message.category),
                formatQoshniNotificationTimestamp(published, localeTag),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (resolved.resolution.usedFallback)
              Text(
                l10n.notificationTemplatesLocaleFallbackLine(
                  qoshniSystemMessageLocaleLabel(
                    l10n,
                    resolved.resolution.requestedLocale,
                  ),
                  qoshniSystemMessageLocaleLabel(
                    l10n,
                    resolved.resolution.resolvedLocale,
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(resolved.body),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (unread)
                  OutlinedButton(
                    onPressed: onMarkRead,
                    child: Text(l10n.systemMessageMarkReadAction),
                  ),
                if (message.internalNavigationRoute != null)
                  OutlinedButton(
                    onPressed: () =>
                        context.push(message.internalNavigationRoute!),
                    child: Text(l10n.systemMessageOpenAction),
                  ),
                OutlinedButton(
                  onPressed: () => _simulateNotification(context, resolved.title, resolved.body),
                  child: Text(l10n.systemMessageSimulateNotificationAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _simulateNotification(
    BuildContext context,
    String title,
    String body,
  ) {
    final dispatch = getIt<QoshniNotificationDispatchController>();
    final eval = controller.evaluationUtc.toLocal();
    final suffix = message.messageId.replaceAll('.', '-');
    final result = dispatch.dispatch(
      QoshniNotificationDispatchRequest(
        demoRecipientReference: kDemoSystemMessageRecipientPrimary,
        category: _notificationCategory(message.category),
        channel: QoshniNotificationChannel.inApp,
        priority: QoshniNotificationPriority.normal,
        title: title,
        body: body,
        idempotencyReference: 'sys-msg-sim-$suffix-${eval.millisecondsSinceEpoch}',
        correlationReference: 'sys-msg-corr-$suffix',
        source: QoshniNotificationDispatchSource.demoDiagnostics,
        evaluationLocalDateTime: eval,
        internalNavigationRoute: message.internalNavigationRoute,
      ),
    );
    final outcome = result.outcome;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            qoshniNotificationDispatchOutcomeLabel(l10n, outcome),
          ),
        ),
      );
    }
  }

  QoshniNotificationCategory _notificationCategory(
    QoshniSystemMessageCategory category,
  ) {
    return switch (category) {
      QoshniSystemMessageCategory.policyInformation =>
        QoshniNotificationCategory.security,
      QoshniSystemMessageCategory.maintenanceNotice =>
        QoshniNotificationCategory.business,
      QoshniSystemMessageCategory.serviceUpdate =>
        QoshniNotificationCategory.business,
      QoshniSystemMessageCategory.generalAnnouncement =>
        QoshniNotificationCategory.business,
    };
  }
}
