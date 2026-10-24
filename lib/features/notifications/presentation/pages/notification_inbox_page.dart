import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_repository.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_controller.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_date_format.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_internal_navigation.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_labels.dart';
import 'package:qoshni/routing/route_paths.dart';

class NotificationInboxPage extends StatefulWidget {
  const NotificationInboxPage({super.key});

  @override
  State<NotificationInboxPage> createState() => _NotificationInboxPageState();
}

class _NotificationInboxPageState extends State<NotificationInboxPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<QoshniNotificationController>().refresh();
    });
  }

  String? _operationMessage(AppLocalizations l10n, String? key) {
    return switch (key) {
      'markReadSuccess' => l10n.notificationMarkReadSuccess,
      'markReadAlready' => l10n.notificationMarkReadAlready,
      'markReadNotFound' => l10n.notificationMarkReadNotFound,
      'markReadInvalid' => l10n.notificationMarkReadInvalid,
      'markReadFailure' => l10n.notificationMarkReadFailure,
      'markAllReadSuccess' => l10n.notificationMarkAllReadSuccess,
      'markAllReadFailure' => l10n.notificationMarkAllReadFailure,
      _ => null,
    };
  }

  void _showOperationFeedback(QoshniNotificationController controller) {
    final l10n = AppLocalizations.of(context);
    final message = _operationMessage(l10n, controller.lastOperationMessageKey);
    if (message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<QoshniNotificationController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.notificationInboxTitle),
        actions: [
          IconButton(
            tooltip: l10n.systemMessagesOpenTooltip,
            icon: const Icon(Icons.campaign_outlined),
            onPressed: () => context.pushNamed(RouteNames.systemMessages),
          ),
          IconButton(
            tooltip: l10n.notificationDispatchDiagnosticsOpenTooltip,
            icon: const Icon(Icons.send_outlined),
            onPressed: () => context.pushNamed(
              RouteNames.notificationDispatchDiagnostics,
            ),
          ),
          IconButton(
            tooltip: l10n.notificationPreferencesOpenTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                context.pushNamed(RouteNames.notificationPreferences),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return TextButton(
                onPressed: controller.unreadCount == 0
                    ? null
                    : () {
                        controller.markAllRead();
                        _showOperationFeedback(controller);
                      },
                child: Text(l10n.notificationMarkAllReadAction),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final notifications = controller.notifications;
            final unreadCount = controller.unreadCount;

            return ResponsiveLayout(
              phone: _InboxBody(
                maxWidth: 520,
                l10n: l10n,
                controller: controller,
                notifications: notifications,
                unreadCount: unreadCount,
                onMarkRead: (id) {
                  controller.markRead(id);
                  _showOperationFeedback(controller);
                },
                onOpenNotification: _openNotification,
              ),
              tablet: _InboxBody(
                maxWidth: 720,
                l10n: l10n,
                controller: controller,
                notifications: notifications,
                unreadCount: unreadCount,
                onMarkRead: (id) {
                  controller.markRead(id);
                  _showOperationFeedback(controller);
                },
                onOpenNotification: _openNotification,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openNotification(QoshniNotification notification) {
    final controller = getIt<QoshniNotificationController>();
    if (notification.isUnread) {
      controller.markRead(notification.notificationId);
    }
    final route = notification.internalNavigationRoute?.trim();
    if (route != null &&
        route.isNotEmpty &&
        isAllowedQoshniNotificationInternalRoute(route)) {
      context.push(route);
    }
  }
}

class _InboxBody extends StatelessWidget {
  const _InboxBody({
    required this.maxWidth,
    required this.l10n,
    required this.controller,
    required this.notifications,
    required this.unreadCount,
    required this.onMarkRead,
    required this.onOpenNotification,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final QoshniNotificationController controller;
  final List<QoshniNotification> notifications;
  final int unreadCount;
  final ValueChanged<String> onMarkRead;
  final ValueChanged<QoshniNotification> onOpenNotification;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.notificationInboxDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.notificationInboxUnreadCount(unreadCount),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<QoshniNotificationReadFilter>(
              segments: [
                ButtonSegment(
                  value: QoshniNotificationReadFilter.all,
                  label: Text(l10n.notificationFilterAll),
                ),
                ButtonSegment(
                  value: QoshniNotificationReadFilter.unreadOnly,
                  label: Text(l10n.notificationFilterUnread),
                ),
              ],
              selected: {controller.readFilter},
              onSelectionChanged: (selection) {
                controller.setReadFilter(selection.first);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<QoshniNotificationCategory?>(
              isExpanded: true,
              initialValue: controller.categoryFilter,
              decoration: InputDecoration(
                labelText: l10n.notificationCategoryFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.notificationCategoryAll),
                ),
                for (final category in QoshniNotificationCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(qoshniNotificationCategoryLabel(l10n, category)),
                  ),
              ],
              onChanged: controller.setCategoryFilter,
            ),
            if (controller.readFilter != QoshniNotificationReadFilter.all ||
                controller.categoryFilter != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: controller.clearFilters,
                  child: Text(l10n.notificationClearFilters),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (notifications.isEmpty)
              AppSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    l10n.notificationInboxEmptyBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...notifications.map(
                (notification) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _NotificationCard(
                    l10n: l10n,
                    locale: locale,
                    notification: notification,
                    onMarkRead: onMarkRead,
                    onOpen: () => onOpenNotification(notification),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.l10n,
    required this.locale,
    required this.notification,
    required this.onMarkRead,
    required this.onOpen,
  });

  final AppLocalizations l10n;
  final String locale;
  final QoshniNotification notification;
  final ValueChanged<String> onMarkRead;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final unread = notification.isUnread;
    final timestamp = formatQoshniNotificationTimestamp(
      notification.createdAt,
      locale,
    );
    final categoryLabel =
        qoshniNotificationCategoryLabel(l10n, notification.category);
    final route = notification.internalNavigationRoute?.trim();
    final canNavigate = route != null &&
        route.isNotEmpty &&
        isAllowedQoshniNotificationInternalRoute(route);

    return AppSurfaceCard(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    unread
                        ? Icons.mark_email_unread_outlined
                        : Icons.drafts_outlined,
                    color: unread ? colorScheme.primary : colorScheme.outline,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.notificationCardMetaLine(
                            categoryLabel,
                            timestamp,
                            unread
                                ? l10n.notificationStatusUnread
                                : l10n.notificationStatusRead,
                          ),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(notification.body),
              if (notification.isSyntheticDemo) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.notificationSyntheticBadge,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
              if (canNavigate) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.notificationOpenLinkedRouteAction,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
              if (unread) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => onMarkRead(notification.notificationId),
                    child: Text(l10n.notificationMarkReadAction),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
