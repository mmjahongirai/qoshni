import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/wallet/application/wallet_controller.dart';
import 'package:qoshni/features/wallet/domain/wallet.dart';
import 'package:qoshni/features/wallet/presentation/wallet_amount_format.dart';
import 'package:qoshni/routing/route_paths.dart';

/// Read-only wallet balances for the signed-in user. No money actions.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key, this.controller});

  /// Tests pass their own controller; the app creates one per page.
  final WalletController? controller;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final WalletController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? getIt<WalletController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.load();
      }
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(RouteNames.profile);
                }
              },
            ),
            title: Text(l10n.walletTitle),
            actions: [
              if (state == WalletViewState.loaded)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: l10n.walletRefreshAction,
                  onPressed: _controller.load,
                ),
            ],
          ),
          body: _body(context, l10n, state),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    WalletViewState state,
  ) {
    final wallet = _controller.wallet;
    return switch (state) {
      WalletViewState.idle ||
      WalletViewState.loading =>
        const Center(child: CircularProgressIndicator()),
      WalletViewState.loaded when wallet != null =>
        _WalletBalances(wallet: wallet, onRefresh: _controller.load),
      WalletViewState.signedOut => Center(
          child: SingleChildScrollView(
            child: AppEmptyState(
              icon: Icons.lock_outline_rounded,
              title: l10n.walletSignInTitle,
              message: l10n.walletSignInMessage,
              action: FilledButton.icon(
                icon: const Icon(Icons.login_rounded),
                label: Text(l10n.authSignInAction),
                onPressed: () => context.pushNamed(RouteNames.authSignIn),
              ),
            ),
          ),
        ),
      WalletViewState.notFound => _retryState(
          l10n,
          icon: Icons.account_balance_wallet_outlined,
          title: l10n.walletNotFoundTitle,
          message: l10n.walletNotFoundMessage,
        ),
      WalletViewState.apiNotConfigured => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppMessageBanner(
              message: l10n.walletApiNotConfigured,
              icon: Icons.cloud_off_outlined,
              tone: AppMessageTone.warning,
            ),
          ),
        ),
      WalletViewState.unavailable || WalletViewState.loaded => _retryState(
          l10n,
          icon: Icons.cloud_off_outlined,
          title: l10n.walletUnavailableTitle,
          message: l10n.walletUnavailableMessage,
        ),
    };
  }

  Widget _retryState(
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: AppEmptyState(
          icon: icon,
          title: title,
          message: message,
          action: OutlinedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.walletRetryAction),
            onPressed: _controller.load,
          ),
        ),
      ),
    );
  }
}

class _WalletBalances extends StatelessWidget {
  const _WalletBalances({required this.wallet, required this.onRefresh});

  final WalletBalance wallet;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    String amount(int minor) =>
        formatWalletAmount(l10n, minor, wallet.currencyCode);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSurfaceCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                l10n.walletAvailableBalance,
                                style: textTheme.titleSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            _StatusChip(status: wallet.status),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          amount(wallet.availableMinor),
                          key: const Key('wallet-available-amount'),
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppSurfaceCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.lock_clock_outlined,
                          label: l10n.walletHoldBalance,
                          value: amount(wallet.holdMinor),
                          valueKey: const Key('wallet-hold-amount'),
                        ),
                        const Divider(height: 1),
                        _DetailRow(
                          icon: Icons.schedule_rounded,
                          label: l10n.walletPendingBalance,
                          value: amount(wallet.pendingMinor),
                          valueKey: const Key('wallet-pending-amount'),
                        ),
                        const Divider(height: 1),
                        _DetailRow(
                          icon: Icons.payments_outlined,
                          label: l10n.walletCurrencyLabel,
                          value: wallet.currencyCode,
                        ),
                        const Divider(height: 1),
                        _DetailRow(
                          icon: Icons.verified_user_outlined,
                          label: l10n.walletStatusLabel,
                          value: _statusLabel(l10n, wallet.status),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.walletServerValuesNote,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(AppLocalizations l10n, WalletStatus status) {
  return switch (status) {
    WalletStatus.active => l10n.walletStatusActive,
    WalletStatus.frozen => l10n.walletStatusFrozen,
    WalletStatus.unknown => l10n.walletStatusUnknown,
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final WalletStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      WalletStatus.active => (scheme.primaryContainer, scheme.onPrimaryContainer),
      WalletStatus.frozen => (scheme.errorContainer, scheme.onErrorContainer),
      WalletStatus.unknown => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        _statusLabel(l10n, status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
            ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueKey,
  });

  final IconData icon;
  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      leading: Icon(icon, color: scheme.primary),
      title: Text(label),
      trailing: Text(
        value,
        key: valueKey,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
