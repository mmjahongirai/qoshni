import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/auth/domain/auth_failure.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/auth/presentation/phone_e164.dart';

class AuthSignInPage extends StatefulWidget {
  const AuthSignInPage({super.key});

  @override
  State<AuthSignInPage> createState() => _AuthSignInPageState();
}

class _AuthSignInPageState extends State<AuthSignInPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = getIt<AuthController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.authSignInTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: auth,
          builder: (context, _) {
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: responsivePagePadding(context),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!auth.apiConfigured) ...[
                          AppMessageBanner(
                            message: l10n.authApiNotConfigured,
                            icon: Icons.cloud_off_outlined,
                            tone: AppMessageTone.warning,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (auth.status == AuthStatus.otpPending) ...[
                          Text(
                            l10n.authOtpPrompt,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: auth.otpCodeLength ?? 8,
                            decoration: InputDecoration(
                              labelText: l10n.authOtpFieldLabel,
                              counterText: '',
                            ),
                            enabled: !auth.busy,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          FilledButton(
                            onPressed: auth.busy
                                ? null
                                : () async {
                                    await auth.verifyOtp(_codeController.text);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    if (auth.isSignedIn) {
                                      context.pop(true);
                                    }
                                  },
                            child: auth.busy
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(l10n.authVerifyAction),
                          ),
                          TextButton(
                            onPressed: auth.busy ? null : auth.resetOtpFlow,
                            child: Text(l10n.authChangePhoneAction),
                          ),
                        ] else ...[
                          Text(
                            l10n.authPhonePrompt,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: l10n.authPhoneFieldLabel,
                              hintText: l10n.authPhoneHint,
                            ),
                            enabled: !auth.busy,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          FilledButton(
                            onPressed: auth.busy
                                ? null
                                : () async {
                                    final normalized =
                                        tryNormalizePhoneE164(_phoneController.text);
                                    if (normalized == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.authPhoneInvalid)),
                                      );
                                      return;
                                    }
                                    await auth.requestOtp(normalized);
                                  },
                            child: auth.busy
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(l10n.authRequestOtpAction),
                          ),
                        ],
                        if (auth.lastFailure != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          AppMessageBanner(
                            message: _localizedFailure(l10n, auth.lastFailure!),
                            icon: Icons.info_outline,
                            tone: _toneForFailure(auth.lastFailure!),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(l10n.authContinueAsGuest),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AppMessageTone _toneForFailure(AuthFailure failure) {
    return switch (failure.code) {
      AuthErrorCode.serviceUnavailable ||
      AuthErrorCode.apiNotConfigured ||
      AuthErrorCode.network =>
        AppMessageTone.warning,
      AuthErrorCode.codeIncorrect ||
      AuthErrorCode.challengeExpired ||
      AuthErrorCode.challengeLocked =>
        AppMessageTone.error,
      _ => AppMessageTone.info,
    };
  }

  String _localizedFailure(AppLocalizations l10n, AuthFailure failure) {
    return switch (failure.code) {
      AuthErrorCode.apiNotConfigured => l10n.authApiNotConfigured,
      AuthErrorCode.serviceUnavailable => l10n.authErrorServiceUnavailable,
      AuthErrorCode.rateLimited => l10n.authErrorRateLimited,
      AuthErrorCode.codeIncorrect => l10n.authErrorCodeIncorrect,
      AuthErrorCode.challengeExpired => l10n.authErrorChallengeExpired,
      AuthErrorCode.challengeLocked => l10n.authErrorChallengeLocked,
      AuthErrorCode.network => l10n.authErrorNetwork,
      _ => l10n.authErrorGeneric,
    };
  }
}
