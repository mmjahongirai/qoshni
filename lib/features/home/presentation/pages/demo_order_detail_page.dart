import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_controller.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_date_format.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_record.dart';
import 'package:qoshni/features/home/presentation/widgets/cart_demo_total_footer.dart';
import 'package:qoshni/features/home/presentation/widgets/demo_order_line_card.dart';
import 'package:qoshni/features/home/presentation/widgets/demo_order_status_chip.dart';
import 'package:qoshni/routing/route_paths.dart';

class DemoOrderDetailPage extends StatelessWidget {
  const DemoOrderDetailPage({
    required this.referenceId,
    super.key,
  });

  final String? referenceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final demoOrderController = getIt<DemoOrderController>();
    final ref = referenceId?.trim();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.demoOrderDetailTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: demoOrderController,
          builder: (context, _) {
            final record = ref == null || ref.isEmpty
                ? null
                : demoOrderController.orderByReference(ref);

            if (record == null) {
              return _DemoOrderDetailMissingState(l10n: l10n);
            }

            return ResponsiveLayout(
              phone: _DemoOrderDetailBody(
                maxWidth: 520,
                l10n: l10n,
                record: record,
              ),
              tablet: _DemoOrderDetailBody(
                maxWidth: 760,
                l10n: l10n,
                record: record,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DemoOrderDetailBody extends StatelessWidget {
  const _DemoOrderDetailBody({
    required this.maxWidth,
    required this.l10n,
    required this.record,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final DemoOrderRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final snapshot = record.snapshot;

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
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.demoOrderReferenceLabel(snapshot.referenceId),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      formatDemoOrderDateTime(context, snapshot.confirmedAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DemoOrderStatusChip(l10n: l10n, status: record.status),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.demoOrderStatusLocalOnlyNote,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
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
              CartDemoTotalFooter(l10n: l10n, totalUzs: snapshot.totalUzs),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoOrderDetailMissingState extends StatelessWidget {
  const _DemoOrderDetailMissingState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.demoOrderDetailNotFoundTitle,
        message: l10n.demoOrderDetailNotFoundBody,
        action: FilledButton(
          onPressed: () => context.go(RoutePaths.home),
          child: Text(l10n.demoOrderReturnHome),
        ),
      ),
    );
  }
}
