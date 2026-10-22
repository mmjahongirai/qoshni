import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_pricing_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_price_status_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_resolver.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_variant_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_service_controller.dart';

class BusinessCatalogPricingPage extends StatefulWidget {
  const BusinessCatalogPricingPage({super.key});

  @override
  State<BusinessCatalogPricingPage> createState() =>
      _BusinessCatalogPricingPageState();
}

class _BusinessCatalogPricingPageState extends State<BusinessCatalogPricingPage> {
  String? _branchFilter;
  BusinessCatalogListingKind? _kindFilter;
  BusinessCatalogPriceStatus? _statusFilter;
  String? _expandedHistoryId;
  DateTime _previewAsOf = kDemoCatalogPricingEpoch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessCatalogPricingController>().refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogPricingController>();
    final branchController = getIt<BusinessBranchController>();
    final productController = getIt<BusinessCatalogProductController>();
    final serviceController = getIt<BusinessCatalogServiceController>();
    final variantController = getIt<BusinessCatalogProductVariantController>();

    String listingLabel(BusinessCatalogPrice p) {
      switch (p.listingKind) {
        case BusinessCatalogListingKind.product:
          return productController.productById(p.listingId)?.displayName(l10n) ??
              p.listingId;
        case BusinessCatalogListingKind.service:
          return serviceController.serviceById(p.listingId)?.displayName(l10n) ??
              p.listingId;
      }
    }

    String? variantLabel(BusinessCatalogPrice p) {
      final id = p.variantId;
      if (id == null || id.isEmpty) {
        return null;
      }
      return variantController.variantById(id)?.label ?? id;
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogPricingListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.saveBusy
            ? null
            : () => _openEditor(context, l10n, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogPricingAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            controller,
            branchController,
            productController,
            serviceController,
            variantController,
          ]),
          builder: (context, _) {
            if (controller.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = controller.prices();
            final filtered = controller.prices(
              branchId: _branchFilter,
              listingKind: _kindFilter,
              status: _statusFilter,
            );

            return ResponsiveLayout(
              phone: _PricingBody(
                maxWidth: 520,
                l10n: l10n,
                prices: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                kindFilter: _kindFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: controller.saveBusy,
                previewAsOf: _previewAsOf,
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onKindChanged: (v) => setState(() => _kindFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onPreviewAsOfChanged: (d) => setState(() => _previewAsOf = d),
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                listingLabel: listingLabel,
                variantLabel: variantLabel,
                historyFor: controller.historyFor,
                resolvePreview: controller.resolveEffectivePrice,
                onEdit: (p) => _openEditor(context, l10n, p),
                onActivate: (p) => _activate(l10n, p),
                onArchive: _archive,
              ),
              tablet: _PricingBody(
                maxWidth: 760,
                l10n: l10n,
                prices: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                kindFilter: _kindFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: controller.saveBusy,
                previewAsOf: _previewAsOf,
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onKindChanged: (v) => setState(() => _kindFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onPreviewAsOfChanged: (d) => setState(() => _previewAsOf = d),
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                listingLabel: listingLabel,
                variantLabel: variantLabel,
                historyFor: controller.historyFor,
                resolvePreview: controller.resolveEffectivePrice,
                onEdit: (p) => _openEditor(context, l10n, p),
                onActivate: (p) => _activate(l10n, p),
                onArchive: _archive,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _activate(AppLocalizations l10n, BusinessCatalogPrice price) async {
    final result =
        await getIt<BusinessCatalogPricingController>().activatePrice(price.priceId);
    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogPricingStatusChangeResult.activeIntervalOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogPricingActivateOverlapError)),
      );
    }
  }

  Future<void> _archive(BusinessCatalogPrice price) async {
    await getIt<BusinessCatalogPricingController>().archivePrice(price.priceId);
  }

  Future<void> _openEditor(
    BuildContext context,
    AppLocalizations l10n,
    BusinessCatalogPrice? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _PriceEditorDialog(l10n: l10n, existing: existing),
    );
  }
}

class _PricingBody extends StatelessWidget {
  const _PricingBody({
    required this.maxWidth,
    required this.l10n,
    required this.prices,
    required this.allCount,
    required this.branches,
    required this.branchFilter,
    required this.kindFilter,
    required this.statusFilter,
    required this.expandedHistoryId,
    required this.saveBusy,
    required this.previewAsOf,
    required this.onBranchChanged,
    required this.onKindChanged,
    required this.onStatusChanged,
    required this.onToggleHistory,
    required this.onPreviewAsOfChanged,
    required this.branchLabel,
    required this.listingLabel,
    required this.variantLabel,
    required this.historyFor,
    required this.resolvePreview,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessCatalogPrice> prices;
  final int allCount;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessCatalogListingKind? kindFilter;
  final BusinessCatalogPriceStatus? statusFilter;
  final String? expandedHistoryId;
  final bool saveBusy;
  final DateTime previewAsOf;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<BusinessCatalogListingKind?> onKindChanged;
  final ValueChanged<BusinessCatalogPriceStatus?> onStatusChanged;
  final ValueChanged<String> onToggleHistory;
  final ValueChanged<DateTime> onPreviewAsOfChanged;
  final String Function(String branchId) branchLabel;
  final String Function(BusinessCatalogPrice) listingLabel;
  final String? Function(BusinessCatalogPrice) variantLabel;
  final List<BusinessCatalogPriceHistoryEvent> Function(String) historyFor;
  final CatalogPriceResolution Function({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    required String branchId,
    String? variantId,
    required DateTime asOf,
  }) resolvePreview;
  final void Function(BusinessCatalogPrice) onEdit;
  final void Function(BusinessCatalogPrice) onActivate;
  final void Function(BusinessCatalogPrice) onArchive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.catalogPricingDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.catalogPricingPreviewTitle,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(l10n.catalogPricingPreviewBody),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: saveBusy
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: previewAsOf.toLocal(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              onPreviewAsOfChanged(
                                DateTime.utc(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.event),
                    label: Text(
                      l10n.catalogPricingPreviewAsOfLabel(
                        _formatDate(previewAsOf),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.catalogPricingPreviewHint,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    value: branchFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogPricingBranchFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogPricingAllBranches),
                      ),
                      for (final b in branches)
                        DropdownMenuItem(
                          value: b.branchId,
                          child: Text(b.name),
                        ),
                    ],
                    onChanged: saveBusy ? null : onBranchChanged,
                  ),
                  DropdownButtonFormField<BusinessCatalogListingKind?>(
                    isExpanded: true,
                    value: kindFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogPricingKindFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogPricingAllKinds),
                      ),
                      DropdownMenuItem(
                        value: BusinessCatalogListingKind.product,
                        child: Text(l10n.catalogPricingKindProduct),
                      ),
                      DropdownMenuItem(
                        value: BusinessCatalogListingKind.service,
                        child: Text(l10n.catalogPricingKindService),
                      ),
                    ],
                    onChanged: saveBusy ? null : onKindChanged,
                  ),
                  DropdownButtonFormField<BusinessCatalogPriceStatus?>(
                    isExpanded: true,
                    value: statusFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogPricingStatusFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogPricingAllStatuses),
                      ),
                      for (final s in BusinessCatalogPriceStatus.values)
                        if (s != BusinessCatalogPriceStatus.archived)
                          DropdownMenuItem(
                            value: s,
                            child: Text(s.label(l10n)),
                          ),
                    ],
                    onChanged: saveBusy ? null : onStatusChanged,
                  ),
                  Text(
                    l10n.catalogListingFilteredCount(prices.length, allCount),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (prices.isEmpty)
              AppSurfaceCard(child: Text(l10n.catalogPricingEmptyBody))
            else
              for (final p in prices) ...[
                _PriceCard(
                  l10n: l10n,
                  price: p,
                  branchName: branchLabel(p.branchId),
                  listingName: listingLabel(p),
                  variantName: variantLabel(p),
                  historyExpanded: expandedHistoryId == p.priceId,
                  history: historyFor(p.priceId),
                  saveBusy: saveBusy,
                  previewAsOf: previewAsOf,
                  resolvePreview: resolvePreview,
                  onToggleHistory: () => onToggleHistory(p.priceId),
                  onEdit: () => onEdit(p),
                  onActivate: () => onActivate(p),
                  onArchive: () => onArchive(p),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.l10n,
    required this.price,
    required this.branchName,
    required this.listingName,
    required this.variantName,
    required this.historyExpanded,
    required this.history,
    required this.saveBusy,
    required this.previewAsOf,
    required this.resolvePreview,
    required this.onToggleHistory,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final AppLocalizations l10n;
  final BusinessCatalogPrice price;
  final String branchName;
  final String listingName;
  final String? variantName;
  final bool historyExpanded;
  final List<BusinessCatalogPriceHistoryEvent> history;
  final bool saveBusy;
  final DateTime previewAsOf;
  final CatalogPriceResolution Function({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    required String branchId,
    String? variantId,
    required DateTime asOf,
  }) resolvePreview;
  final VoidCallback onToggleHistory;
  final VoidCallback onEdit;
  final VoidCallback onActivate;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effective = resolvePreview(
      listingKind: price.listingKind,
      listingId: price.listingId,
      branchId: price.branchId,
      variantId: price.variantId,
      asOf: previewAsOf,
    );
    String effectiveLabel;
    switch (effective.status) {
      case CatalogPriceResolutionStatus.found:
        effectiveLabel = l10n.catalogPricingEffectiveFound(
          formatCatalogPriceAmountSom(effective.price!.amountSom),
        );
      case CatalogPriceResolutionStatus.notFound:
        effectiveLabel = l10n.catalogPricingEffectiveNotFound;
      case CatalogPriceResolutionStatus.ambiguous:
        effectiveLabel = l10n.catalogPricingEffectiveAmbiguous;
    }

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            listingName,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            price.listingKind == BusinessCatalogListingKind.product
                ? l10n.catalogPricingKindProduct
                : l10n.catalogPricingKindService,
          ),
          if (variantName != null)
            Text(l10n.catalogPricingVariantLabel(variantName!)),
          Text(l10n.catalogPricingBranchLabel(branchName)),
          Text(
            l10n.catalogPricingAmountLabel(
              formatCatalogPriceAmountSom(price.amountSom, currencyCode: price.currencyCode),
            ),
          ),
          Text(price.status.label(l10n)),
          Text(
            l10n.catalogPricingEffectiveIntervalLabel(
              _formatDate(price.effectiveFrom),
              price.effectiveUntil != null
                  ? _formatDate(price.effectiveUntil!)
                  : l10n.catalogPricingOpenEnded,
            ),
          ),
          Text(l10n.catalogPricingRevisionLabel(price.revision)),
          Text(l10n.catalogPricingEffectivePreviewLine(effectiveLabel)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (price.status == BusinessCatalogPriceStatus.draft)
                FilledButton.tonal(
                  onPressed: saveBusy ? null : onEdit,
                  child: Text(l10n.catalogPricingEditAction),
                ),
              if (price.status == BusinessCatalogPriceStatus.draft)
                FilledButton(
                  onPressed: saveBusy ? null : onActivate,
                  child: Text(l10n.catalogPricingActivateAction),
                ),
              if (price.status == BusinessCatalogPriceStatus.active)
                OutlinedButton(
                  onPressed: saveBusy ? null : onArchive,
                  child: Text(l10n.catalogPricingArchiveAction),
                ),
              TextButton(
                onPressed: saveBusy ? null : onToggleHistory,
                child: Text(
                  historyExpanded
                      ? l10n.catalogPricingHideHistoryAction
                      : l10n.catalogPricingShowHistoryAction,
                ),
              ),
            ],
          ),
          if (historyExpanded) ...[
            const Divider(),
            if (history.isEmpty)
              Text(l10n.catalogPricingHistoryEmpty)
            else
              for (final e in history)
                Text(
                  l10n.catalogPricingHistoryLine(
                    e.action.name,
                    e.previousAmountSom?.toString() ?? '—',
                    e.newAmountSom?.toString() ?? '—',
                  ),
                ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _PriceEditorDialog extends StatefulWidget {
  const _PriceEditorDialog({required this.l10n, required this.existing});

  final AppLocalizations l10n;
  final BusinessCatalogPrice? existing;

  @override
  State<_PriceEditorDialog> createState() => _PriceEditorDialogState();
}

class _PriceEditorDialogState extends State<_PriceEditorDialog> {
  late BusinessCatalogListingKind _kind;
  String? _listingId;
  String? _variantId;
  String? _branchId;
  late TextEditingController _amountController;
  late TextEditingController _fromController;
  late TextEditingController _untilController;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kind = e?.listingKind ?? BusinessCatalogListingKind.product;
    _listingId = e?.listingId;
    _variantId = e?.variantId;
    _branchId = e?.branchId;
    _amountController = TextEditingController(
      text: e?.amountSom.toString() ?? '',
    );
    _fromController = TextEditingController(
      text: e != null ? _formatDate(e.effectiveFrom) : _formatDate(kDemoCatalogPricingEpoch),
    );
    _untilController = TextEditingController(
      text: e?.effectiveUntil != null ? _formatDate(e!.effectiveUntil!) : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _fromController.dispose();
    _untilController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final productController = getIt<BusinessCatalogProductController>();
    final serviceController = getIt<BusinessCatalogServiceController>();
    final variantController = getIt<BusinessCatalogProductVariantController>();
    final branchController = getIt<BusinessBranchController>();
    final pricingController = getIt<BusinessCatalogPricingController>();

    final products = productController.products;
    final services = serviceController.services;
    final branches = branchController.branches;

    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.catalogPricingCreateTitle
            : l10n.catalogPricingEditTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorKey != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  _mapError(l10n, _errorKey!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            DropdownButtonFormField<BusinessCatalogListingKind>(
              isExpanded: true,
              value: _kind,
              decoration: InputDecoration(labelText: l10n.catalogPricingKindFilter),
              items: [
                DropdownMenuItem(
                  value: BusinessCatalogListingKind.product,
                  child: Text(l10n.catalogPricingKindProduct),
                ),
                DropdownMenuItem(
                  value: BusinessCatalogListingKind.service,
                  child: Text(l10n.catalogPricingKindService),
                ),
              ],
              onChanged: pricingController.saveBusy
                  ? null
                  : (v) {
                      if (v == null) {
                        return;
                      }
                      setState(() {
                        _kind = v;
                        _listingId = null;
                        _variantId = null;
                      });
                    },
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _listingId,
              decoration: InputDecoration(
                labelText: _kind == BusinessCatalogListingKind.product
                    ? l10n.catalogProductListTitle
                    : l10n.catalogServiceListTitle,
              ),
              items: [
                for (final p in (_kind == BusinessCatalogListingKind.product
                    ? products.map((x) => (x.productId, x.displayName(l10n)))
                    : services.map((x) => (x.serviceId, x.displayName(l10n)))))
                  DropdownMenuItem(value: p.$1, child: Text(p.$2)),
              ],
              onChanged: pricingController.saveBusy
                  ? null
                  : (v) => setState(() {
                        _listingId = v;
                        _variantId = null;
                      }),
            ),
            if (_kind == BusinessCatalogListingKind.product) ...[
              DropdownButtonFormField<String?>(
                isExpanded: true,
                value: _variantId,
                decoration: InputDecoration(
                  labelText: l10n.catalogPricingVariantOptional,
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.catalogPricingBaseListingPrice),
                  ),
                  if (_listingId != null)
                    for (final v in variantController.variantsForProduct(_listingId!))
                      DropdownMenuItem(value: v.variantId, child: Text(v.label)),
                ],
                onChanged: pricingController.saveBusy
                    ? null
                    : (v) => setState(() => _variantId = v),
              ),
            ],
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _branchId,
              decoration: InputDecoration(labelText: l10n.catalogPricingBranchFilter),
              items: [
                for (final b in branches)
                  DropdownMenuItem(value: b.branchId, child: Text(b.name)),
              ],
              onChanged: pricingController.saveBusy
                  ? null
                  : (v) => setState(() => _branchId = v),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: l10n.catalogPricingAmountField),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextField(
              controller: _fromController,
              decoration: InputDecoration(labelText: l10n.catalogPricingEffectiveFromField),
            ),
            TextField(
              controller: _untilController,
              decoration: InputDecoration(labelText: l10n.catalogPricingEffectiveUntilField),
            ),
            Text(l10n.catalogPricingCurrencyHint),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: pricingController.saveBusy
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(l10n.catalogPricingCancelAction),
        ),
        FilledButton(
          onPressed: pricingController.saveBusy ? null : _save,
          child: pricingController.saveBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.catalogPricingSaveAction),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final listingId = _listingId?.trim();
    final branchId = _branchId?.trim();
    if (listingId == null ||
        listingId.isEmpty ||
        branchId == null ||
        branchId.isEmpty) {
      setState(() => _errorKey = 'scope');
      return;
    }
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null) {
      setState(() => _errorKey = 'amount');
      return;
    }
    final from = _parseDate(_fromController.text.trim());
    if (from == null) {
      setState(() => _errorKey = 'from');
      return;
    }
    final untilText = _untilController.text.trim();
    final until = untilText.isEmpty ? null : _parseDate(untilText);
    if (untilText.isNotEmpty && until == null) {
      setState(() => _errorKey = 'until');
      return;
    }

    final input = BusinessCatalogPriceInput(
      listingKind: _kind,
      listingId: listingId,
      variantId: _variantId,
      branchId: branchId,
      amountSom: amount,
      currencyCode: kBusinessCatalogPriceCurrencyUzs,
      effectiveFrom: from,
      effectiveUntil: until,
    );

    final controller = getIt<BusinessCatalogPricingController>();
    final existing = widget.existing;
    final BusinessCatalogPricingSaveResult result;
    if (existing == null) {
      result = await controller.createDraft(input);
    } else if (existing.status == BusinessCatalogPriceStatus.draft) {
      result = await controller.updateDraft(priceId: existing.priceId, input: input);
    } else {
      setState(() => _errorKey = 'immutable');
      return;
    }

    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogPricingSaveResult.success) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _errorKey = result.name);
  }

  String _mapError(AppLocalizations l10n, String key) {
    switch (key) {
      case 'scope':
        return l10n.catalogPricingScopeRequired;
      case 'amount':
        return l10n.catalogPricingAmountInvalid;
      case 'from':
      case 'until':
        return l10n.catalogPricingDateInvalid;
      case 'immutable':
        return l10n.catalogPricingActiveImmutable;
      case 'failure':
        return l10n.catalogPricingSaveFailed;
      case 'activeImmutable':
        return l10n.catalogPricingActiveImmutable;
      case 'invalidEffectiveRange':
        return l10n.catalogPricingEffectiveRangeInvalid;
      default:
        return l10n.catalogPricingSaveFailed;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime? _parseDate(String text) {
    final parts = text.split('-');
    if (parts.length != 3) {
      return null;
    }
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) {
      return null;
    }
    return DateTime.utc(y, m, d);
  }
}
