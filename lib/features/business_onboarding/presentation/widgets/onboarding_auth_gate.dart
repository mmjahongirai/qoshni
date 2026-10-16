import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

/// Shows [child] when signed in; otherwise prompts for sign-in or API config.
class OnboardingAuthGate extends StatelessWidget {
  const OnboardingAuthGate({
    required this.child,
    this.apiConfigured = true,
    super.key,
  });

  final Widget child;
  final bool apiConfigured;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = getIt<AuthController>();

    if (!apiConfigured) {
      return _GateBody(
        title: l10n.onboardingHubTitle,
        message: l10n.onboardingErrorApiNotConfigured,
        icon: Icons.cloud_off_outlined,
      );
    }

    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        if (auth.isSignedIn) {
          return child;
        }
        return _GateBody(
          title: l10n.onboardingHubTitle,
          message: l10n.onboardingSignInPrompt,
          icon: Icons.lock_outline,
          actionLabel: l10n.authSignInAction,
          onAction: () => context.pushNamed(RouteNames.authSignIn),
        );
      },
    );
  }
}

class _GateBody extends StatelessWidget {
  const _GateBody({
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: responsivePagePadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppSurfaceCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(icon, size: 40),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(onPressed: onAction, child: Text(actionLabel!)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
