import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';

class AuthSessionsPage extends StatefulWidget {
  const AuthSessionsPage({super.key});

  @override
  State<AuthSessionsPage> createState() => _AuthSessionsPageState();
}

class _AuthSessionsPageState extends State<AuthSessionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AuthController>().refreshSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = getIt<AuthController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.authSessionsTitle),
      ),
      body: ListenableBuilder(
        listenable: auth,
        builder: (context, _) {
          if (!auth.isSignedIn) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppMessageBanner(
                  message: l10n.authSessionExpiredNotice,
                  icon: Icons.lock_clock_outlined,
                  tone: AppMessageTone.warning,
                ),
              ),
            );
          }
          if (auth.sessions.isEmpty) {
            return Center(
              child: AppEmptyState(
                icon: Icons.devices_other_outlined,
                title: l10n.authSessionsEmpty,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: auth.sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final session = auth.sessions[index];
              final label = session.deviceLabel ?? l10n.authSessionUnknownDevice;
              final stateLabel = switch (session.state) {
                'active' => l10n.authSessionStateActive,
                'expired' => l10n.authSessionStateExpired,
                'revoked' => l10n.authSessionStateRevoked,
                _ => session.state,
              };
              return AppSurfaceCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  subtitle: Text(stateLabel),
                  trailing: session.isCurrent
                      ? Chip(label: Text(l10n.authSessionCurrentBadge))
                      : IconButton(
                          icon: const Icon(Icons.logout),
                          tooltip: l10n.authSignOutAction,
                          onPressed: auth.busy
                              ? null
                              : () => auth.revokeOwnedSession(session.sessionId),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
