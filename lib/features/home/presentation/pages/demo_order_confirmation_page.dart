import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/cart/demo_order_snapshot.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_controller.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_local_status.dart';
import 'package:qoshni/features/home/presentation/widgets/cart_demo_total_footer.dart';
import 'package:qoshni/features/home/presentation/widgets/demo_order_line_card.dart';
import 'package:qoshni/features/home/presentation/widgets/demo_order_status_chip.dart';
import 'package:qoshni/routing/route_paths.dart';

class DemoOrderConfirmationPage extends StatelessWidget {
  const DemoOrderConfirmationPage({
    required this.snapshot,
    super.key,
  });

  final DemoOrderSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final demoOrderController = getIt<DemoOrderController>();

    final fromExtra = snapshot;
    DemoOrderSnapshot? order = fromExtra;
    DemoOrderLocalStatus status = DemoOrderLocalStatus.preparedNotSent;

    if (order != null) {
      final record = demoOrderController.orderByReference(order.referenceId);
      if (record != null) {
        status = record.status;
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.demoOrderConfirmationTitle),
      ),
      body: SafeArea(
        child: order == null
            ? _DemoOrderInvalidState(l10n: l10n)
            : ResponsiveLayout(
                phone: _DemoOrderConfirmationBody(
                  maxWidth: 520,
                  l10n: l10n,
                  snapshot: order,
                  status: status,
                ),
                tablet: _DemoOrderConfirmationBody(
                  maxWidth: 760,
                  l10n: l10n,
                  snapshot: order,
                  status: status,
                ),
              ),
      ),
    );
  }
}

class _DemoOrderConfirmationBody extends StatelessWidget {
  const _DemoOrderConfirmationBody({
    required this.maxWidth,
    required this.l10n,
    required this.snapshot,
    required this.status,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final DemoOrderSnapshot snapshot;
  final DemoOrderLocalStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 56,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.demoOrderPreparedHeading,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.demoOrderReferenceLabel(snapshot.referenceId),
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DemoOrderStatusChip(l10n: l10n, status: status),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppMessageBanner(
                message: l10n.demoOrderNoRealSubmissionNotice,
                icon: Icons.info_outline,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < snapshot.lines.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                DemoOrderLineCard(l10n: l10n, line: snapshot.lines[i]),
              ],
              const SizedBox(height: 14),
              CartDemoTotalFooter(
                l10n: l10n,
                totalUzs: snapshot.totalUzs,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go(RoutePaths.home),
                child: Text(l10n.demoOrderReturnHome),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.pushNamed(RouteNames.demoOrders),
                child: Text(l10n.demoOrderViewHistory),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoOrderInvalidState extends StatelessWidget {
  const _DemoOrderInvalidState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.error_outline,
        title: l10n.demoOrderInvalidTitle,
        message: l10n.demoOrderInvalidBody,
        action: FilledButton(
          onPressed: () => context.go(RoutePaths.home),
          child: Text(l10n.demoOrderReturnHome),
        ),
      ),
    );
  }
}
