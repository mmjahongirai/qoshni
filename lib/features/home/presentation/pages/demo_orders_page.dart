import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/cart/cart_currency_format.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_controller.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_date_format.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_record.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/app_price_text.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/features/home/presentation/widgets/demo_order_status_chip.dart';
import 'package:qoshni/routing/route_paths.dart';

class DemoOrdersPage extends StatelessWidget {
  const DemoOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final demoOrderController = getIt<DemoOrderController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.demoOrdersTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: demoOrderController,
          builder: (context, _) {
            return ResponsiveLayout(
              phone: _DemoOrdersBody(
                maxWidth: 520,
                l10n: l10n,
                demoOrderController: demoOrderController,
              ),
              tablet: _DemoOrdersBody(
                maxWidth: 760,
                l10n: l10n,
                demoOrderController: demoOrderController,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DemoOrdersBody extends StatelessWidget {
  const _DemoOrdersBody({
    required this.maxWidth,
    required this.l10n,
    required this.demoOrderController,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final DemoOrderController demoOrderController;

  @override
  Widget build(BuildContext context) {
    if (demoOrderController.isEmpty) {
      return _DemoOrdersEmptyState(l10n: l10n);
    }

    final orders = demoOrderController.orders;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _DemoOrderListTile(
                l10n: l10n,
                record: orders[index],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DemoOrderListTile extends StatelessWidget {
  const _DemoOrderListTile({
    required this.l10n,
    required this.record,
  });

  final AppLocalizations l10n;
  final DemoOrderRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final snapshot = record.snapshot;

    return AppSurfaceCard(
      onTap: () => context.pushNamed(
        RouteNames.demoOrderDetail,
        pathParameters: {'referenceId': snapshot.referenceId},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n.demoOrderReferenceLabel(snapshot.referenceId),
                  style: textTheme.titleSmall,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatDemoOrderDateTime(context, snapshot.confirmedAt),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.demoOrdersListSummary(snapshot.lineCount, snapshot.totalUnits),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          AppPriceText(
            label: l10n.cartEstimatedTotalLabel(
              formatCartDemoMoney(l10n, snapshot.totalUzs),
            ),
            emphasis: PriceEmphasis.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          DemoOrderStatusChip(l10n: l10n, status: record.status),
        ],
      ),
    );
  }
}

class _DemoOrdersEmptyState extends StatelessWidget {
  const _DemoOrdersEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.demoOrdersEmptyTitle,
        message: l10n.demoOrdersEmptyBody,
        action: FilledButton(
          onPressed: () => context.go(RoutePaths.home),
          child: Text(l10n.cartBrowseHome),
        ),
      ),
    );
  }
}
