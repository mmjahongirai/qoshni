import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class HomeNotificationsHeaderButton extends StatelessWidget {
  const HomeNotificationsHeaderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<QoshniNotificationController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final count = controller.unreadCount;
        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: IconButton(
            tooltip: l10n.notificationInboxOpenTooltip,
            visualDensity: VisualDensity.compact,
            onPressed: () => context.pushNamed(RouteNames.notificationsInbox),
            icon: const Icon(Icons.notifications_outlined),
          ),
        );
      },
    );
  }
}
