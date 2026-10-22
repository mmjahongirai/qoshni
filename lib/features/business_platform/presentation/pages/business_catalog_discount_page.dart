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
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_service.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_discount_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_resolver.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_status_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_resolver.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_variant_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_service_controller.dart';

class BusinessCatalogDiscountPage extends StatefulWidget {
  const BusinessCatalogDiscountPage({super.key});

  @override
  State<BusinessCatalogDiscountPage> createState() =>
      _BusinessCatalogDiscountPageState();
}

class _BusinessCatalogDiscountPageState extends State<BusinessCatalogDiscountPage> {
  String? _branchFilter;
  BusinessCatalogDiscountTargetScope? _scopeFilter;
  BusinessCatalogPriceStatus? _statusFilter;
  String? _expandedHistoryId;
  DateTime _previewAsOf = kDemoCatalogPricingEpoch;
  String _previewListingId = kDemoCatalogProductBreadId;
  BusinessCatalogListingKind _previewKind = BusinessCatalogListingKind.product;
  String? _previewSubtotalText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessCatalogDiscountController>().refreshList();
      getIt<BusinessCatalogPricingController>().refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final discountController = getIt<BusinessCatalogDiscountController>();
    final pricingController = getIt<BusinessCatalogPricingController>();
    final branchController = getIt<BusinessBranchController>();
    final productController = getIt<BusinessCatalogProductController>();
    final serviceController = getIt<BusinessCatalogServiceController>();
    final variantController = getIt<BusinessCatalogProductVariantController>();

    String listingLabelForRule(BusinessCatalogDiscountRule rule) {
      if (rule.targetScope == BusinessCatalogDiscountTargetScope.businessWide) {
        return l10n.catalogDiscountScopeBusinessWide;
      }
      final id = rule.listingId;
      if (id == null) {
        return '—';
      }
      switch (rule.targetScope) {
        case BusinessCatalogDiscountTargetScope.product:
          return productController.productById(id)?.displayName(l10n) ?? id;
        case BusinessCatalogDiscountTargetScope.service:
          return serviceController.serviceById(id)?.displayName(l10n) ?? id;
        case BusinessCatalogDiscountTargetScope.businessWide:
          return l10n.catalogDiscountScopeBusinessWide;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogDiscountListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: discountController.saveBusy
            ? null
            : () => _openEditor(context, l10n, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogDiscountAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            discountController,
            pricingController,
            branchController,
            productController,
            serviceController,
            variantController,
          ]),
          builder: (context, _) {
            if (discountController.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = discountController.rules();
            final filtered = discountController.rules(
              branchId: _branchFilter,
              targetScope: _scopeFilter,
              status: _statusFilter,
            );
            final previewBranch =
                _branchFilter ?? kDemoBranchTashkentCenterId;
            final subtotal = int.tryParse(_previewSubtotalText?.trim() ?? '');
            final priceResolution = pricingController.resolveEffectivePrice(
              listingKind: _previewKind,
              listingId: _previewListingId,
              branchId: previewBranch,
              asOf: _previewAsOf,
            );
            final baseAmount = priceResolution.status ==
                    CatalogPriceResolutionStatus.found
                ? priceResolution.price!.amountSom
                : null;
            final discountResolution = baseAmount == null
                ? null
                : discountController.resolveDiscount(
                    listingKind: _previewKind,
                    listingId: _previewListingId,
                    branchId: previewBranch,
                    basePriceAmountSom: baseAmount,
                    qualifyingSubtotalAmountSom: subtotal,
                    asOf: _previewAsOf,
                  );

            return ResponsiveLayout(
              phone: _DiscountBody(
                maxWidth: 520,
                l10n: l10n,
                rules: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                scopeFilter: _scopeFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: discountController.saveBusy,
                previewAsOf: _previewAsOf,
                previewKind: _previewKind,
                previewListingId: _previewListingId,
                previewSubtotalText: _previewSubtotalText,
                baseAmount: baseAmount,
                priceResolution: priceResolution,
                discountResolution: discountResolution,
                products: productController.products,
                services: serviceController.services,
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onScopeChanged: (v) => setState(() => _scopeFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onPreviewAsOfChanged: (d) => setState(() => _previewAsOf = d),
                onPreviewKindChanged: (k) => setState(() {
                  _previewKind = k;
                  _previewListingId = k == BusinessCatalogListingKind.product
                      ? kDemoCatalogProductBreadId
                      : kDemoCatalogServicePackingId;
                }),
                onPreviewListingChanged: (id) =>
                    setState(() => _previewListingId = id),
                onPreviewSubtotalChanged: (v) =>
                    setState(() => _previewSubtotalText = v),
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                listingLabelForRule: listingLabelForRule,
                variantLabel: (id) =>
                    variantController.variantById(id)?.label ?? id,
                historyFor: discountController.historyFor,
                onEdit: (r) => _openEditor(context, l10n, r),
                onActivate: (r) => _activate(l10n, r),
                onArchive: (r) => _archive(r),
              ),
              tablet: _DiscountBody(
                maxWidth: 760,
                l10n: l10n,
                rules: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                scopeFilter: _scopeFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: discountController.saveBusy,
                previewAsOf: _previewAsOf,
                previewKind: _previewKind,
                previewListingId: _previewListingId,
                previewSubtotalText: _previewSubtotalText,
                baseAmount: baseAmount,
                priceResolution: priceResolution,
                discountResolution: discountResolution,
                products: productController.products,
                services: serviceController.services,
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onScopeChanged: (v) => setState(() => _scopeFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onPreviewAsOfChanged: (d) => setState(() => _previewAsOf = d),
                onPreviewKindChanged: (k) => setState(() {
                  _previewKind = k;
                  _previewListingId = k == BusinessCatalogListingKind.product
                      ? kDemoCatalogProductBreadId
                      : kDemoCatalogServicePackingId;
                }),
                onPreviewListingChanged: (id) =>
                    setState(() => _previewListingId = id),
                onPreviewSubtotalChanged: (v) =>
                    setState(() => _previewSubtotalText = v),
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                listingLabelForRule: listingLabelForRule,
                variantLabel: (id) =>
                    variantController.variantById(id)?.label ?? id,
                historyFor: discountController.historyFor,
                onEdit: (r) => _openEditor(context, l10n, r),
                onActivate: (r) => _activate(l10n, r),
                onArchive: (r) => _archive(r),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _activate(
    AppLocalizations l10n,
    BusinessCatalogDiscountRule rule,
  ) async {
    final result =
        await getIt<BusinessCatalogDiscountController>().activateRule(
      rule.discountRuleId,
    );
    if (!mounted) {
      return;
    }
    if (result ==
        BusinessCatalogDiscountStatusChangeResult.activeIntervalOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogDiscountActivateOverlapError)),
      );
    }
  }

  Future<void> _archive(BusinessCatalogDiscountRule rule) async {
    await getIt<BusinessCatalogDiscountController>()
        .archiveRule(rule.discountRuleId);
  }

  Future<void> _openEditor(
    BuildContext context,
    AppLocalizations l10n,
    BusinessCatalogDiscountRule? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _DiscountEditorDialog(l10n: l10n, existing: existing),
    );
  }
}

class _DiscountBody extends StatelessWidget {
  const _DiscountBody({
    required this.maxWidth,
    required this.l10n,
    required this.rules,
    required this.allCount,
    required this.branches,
    required this.branchFilter,
    required this.scopeFilter,
    required this.statusFilter,
    required this.expandedHistoryId,
    required this.saveBusy,
    required this.previewAsOf,
    required this.previewKind,
    required this.previewListingId,
    required this.previewSubtotalText,
    required this.baseAmount,
    required this.priceResolution,
    required this.discountResolution,
    required this.products,
    required this.services,
    required this.onBranchChanged,
    required this.onScopeChanged,
    required this.onStatusChanged,
    required this.onToggleHistory,
    required this.onPreviewAsOfChanged,
    required this.onPreviewKindChanged,
    required this.onPreviewListingChanged,
    required this.onPreviewSubtotalChanged,
    required this.branchLabel,
    required this.listingLabelForRule,
    required this.variantLabel,
    required this.historyFor,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessCatalogDiscountRule> rules;
  final int allCount;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessCatalogDiscountTargetScope? scopeFilter;
  final BusinessCatalogPriceStatus? statusFilter;
  final String? expandedHistoryId;
  final bool saveBusy;
  final DateTime previewAsOf;
  final BusinessCatalogListingKind previewKind;
  final String previewListingId;
  final String? previewSubtotalText;
  final int? baseAmount;
  final CatalogPriceResolution priceResolution;
  final CatalogDiscountResolution? discountResolution;
  final List<BusinessCatalogProduct> products;
  final List<BusinessCatalogService> services;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<BusinessCatalogDiscountTargetScope?> onScopeChanged;
  final ValueChanged<BusinessCatalogPriceStatus?> onStatusChanged;
  final ValueChanged<String> onToggleHistory;
  final ValueChanged<DateTime> onPreviewAsOfChanged;
  final ValueChanged<BusinessCatalogListingKind> onPreviewKindChanged;
  final ValueChanged<String> onPreviewListingChanged;
  final ValueChanged<String?> onPreviewSubtotalChanged;
  final String Function(String branchId) branchLabel;
  final String Function(BusinessCatalogDiscountRule) listingLabelForRule;
  final String Function(String id) variantLabel;
  final List<BusinessCatalogDiscountHistoryEvent> Function(String) historyFor;
  final void Function(BusinessCatalogDiscountRule) onEdit;
  final void Function(BusinessCatalogDiscountRule) onActivate;
  final void Function(BusinessCatalogDiscountRule) onArchive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String previewLine;
    if (baseAmount == null) {
      previewLine = l10n.catalogDiscountPreviewNoBasePrice;
    } else if (discountResolution == null) {
      previewLine = l10n.catalogDiscountPreviewNoDiscount;
    } else {
      switch (discountResolution!.status) {
        case CatalogDiscountResolutionStatus.applied:
          previewLine = l10n.catalogDiscountPreviewApplied(
            formatCatalogPriceAmountSom(baseAmount!),
            formatCatalogPriceAmountSom(discountResolution!.discountAmountSom),
            formatCatalogPriceAmountSom(discountResolution!.finalAmountSom),
          );
        case CatalogDiscountResolutionStatus.ambiguous:
          previewLine = l10n.catalogDiscountPreviewAmbiguous;
        case CatalogDiscountResolutionStatus.notApplied:
          previewLine = l10n.catalogDiscountPreviewNotApplied;
      }
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.catalogDiscountDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.catalogDiscountPreviewTitle,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  DropdownButtonFormField<BusinessCatalogListingKind>(
                    isExpanded: true,
                    value: previewKind,
                    decoration: InputDecoration(
                      labelText: l10n.catalogDiscountPreviewListingKind,
                    ),
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
                    onChanged: saveBusy ? null : (v) {
                      if (v != null) {
                        onPreviewKindChanged(v);
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: previewListingId,
                    decoration: InputDecoration(
                      labelText: l10n.catalogDiscountPreviewListing,
                    ),
                    items: [
                      if (previewKind == BusinessCatalogListingKind.product)
                        for (final p in products)
                          DropdownMenuItem(
                            value: p.productId,
                            child: Text(p.displayName(l10n)),
                          )
                      else
                        for (final s in services)
                          DropdownMenuItem(
                            value: s.serviceId,
                            child: Text(s.displayName(l10n)),
                          ),
                    ],
                    onChanged: saveBusy
                        ? null
                        : (v) {
                            if (v != null) {
                              onPreviewListingChanged(v);
                            }
                          },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.catalogDiscountPreviewSubtotal,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: onPreviewSubtotalChanged,
                  ),
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
                  Text(previewLine, style: textTheme.bodyMedium),
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
                      labelText: l10n.catalogDiscountBranchFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogDiscountAllBranches),
                      ),
                      for (final b in branches)
                        DropdownMenuItem(
                          value: b.branchId,
                          child: Text(b.name),
                        ),
                    ],
                    onChanged: saveBusy ? null : onBranchChanged,
                  ),
                  DropdownButtonFormField<
                      BusinessCatalogDiscountTargetScope?>(
                    isExpanded: true,
                    value: scopeFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogDiscountScopeFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogDiscountAllScopes),
                      ),
                      for (final s in BusinessCatalogDiscountTargetScope.values)
                        DropdownMenuItem(
                          value: s,
                          child: Text(s.label(l10n)),
                        ),
                    ],
                    onChanged: saveBusy ? null : onScopeChanged,
                  ),
                  DropdownButtonFormField<BusinessCatalogPriceStatus?>(
                    isExpanded: true,
                    value: statusFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogDiscountStatusFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogDiscountAllStatuses),
                      ),
                      for (final s in BusinessCatalogPriceStatus.values)
                        if (s != BusinessCatalogPriceStatus.archived)
                          DropdownMenuItem(
                            value: s,
                            child: Text(s.discountStatusLabel(l10n)),
                          ),
                    ],
                    onChanged: saveBusy ? null : onStatusChanged,
                  ),
                  Text(
                    l10n.catalogListingFilteredCount(rules.length, allCount),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (rules.isEmpty)
              AppSurfaceCard(child: Text(l10n.catalogDiscountEmptyBody))
            else
              for (final r in rules) ...[
                _DiscountCard(
                  l10n: l10n,
                  rule: r,
                  branchName: branchLabel(r.branchId),
                  listingName: listingLabelForRule(r),
                  variantName: r.variantId != null && r.variantId!.isNotEmpty
                      ? variantLabel(r.variantId!)
                      : null,
                  historyExpanded: expandedHistoryId == r.discountRuleId,
                  history: historyFor(r.discountRuleId),
                  saveBusy: saveBusy,
                  onToggleHistory: () => onToggleHistory(r.discountRuleId),
                  onEdit: () => onEdit(r),
                  onActivate: () => onActivate(r),
                  onArchive: () => onArchive(r),
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

class _DiscountCard extends StatelessWidget {
  const _DiscountCard({
    required this.l10n,
    required this.rule,
    required this.branchName,
    required this.listingName,
    required this.variantName,
    required this.historyExpanded,
    required this.history,
    required this.saveBusy,
    required this.onToggleHistory,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final AppLocalizations l10n;
  final BusinessCatalogDiscountRule rule;
  final String branchName;
  final String listingName;
  final String? variantName;
  final bool historyExpanded;
  final List<BusinessCatalogDiscountHistoryEvent> history;
  final bool saveBusy;
  final VoidCallback onToggleHistory;
  final VoidCallback onEdit;
  final VoidCallback onActivate;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final valueLabel = rule.discountType ==
            BusinessCatalogDiscountType.percentage
        ? l10n.catalogDiscountPercentLabel(
            (rule.percentBasisPoints ?? 0) ~/ 100,
          )
        : l10n.catalogDiscountFixedLabel(
            formatCatalogPriceAmountSom(rule.fixedAmountSom ?? 0),
          );

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            listingName,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(rule.targetScope.label(l10n)),
          if (variantName != null)
            Text(l10n.catalogPricingVariantLabel(variantName!)),
          Text(l10n.catalogPricingBranchLabel(branchName)),
          Text(rule.discountType.label(l10n)),
          Text(valueLabel),
          if (rule.minimumBasketAmountSom != null)
            Text(
              l10n.catalogDiscountMinBasketLabel(
                formatCatalogPriceAmountSom(rule.minimumBasketAmountSom!),
              ),
            ),
          Text(l10n.catalogDiscountPriorityLabel(rule.priority)),
          Text(rule.status.discountStatusLabel(l10n)),
          Text(
            l10n.catalogPricingEffectiveIntervalLabel(
              _formatDate(rule.effectiveFrom),
              rule.effectiveUntil != null
                  ? _formatDate(rule.effectiveUntil!)
                  : l10n.catalogPricingOpenEnded,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (rule.status == BusinessCatalogPriceStatus.draft)
                FilledButton.tonal(
                  onPressed: saveBusy ? null : onEdit,
                  child: Text(l10n.catalogDiscountEditAction),
                ),
              if (rule.status == BusinessCatalogPriceStatus.draft)
                FilledButton(
                  onPressed: saveBusy ? null : onActivate,
                  child: Text(l10n.catalogDiscountActivateAction),
                ),
              if (rule.status == BusinessCatalogPriceStatus.active)
                OutlinedButton(
                  onPressed: saveBusy ? null : onArchive,
                  child: Text(l10n.catalogDiscountArchiveAction),
                ),
              TextButton(
                onPressed: saveBusy ? null : onToggleHistory,
                child: Text(
                  historyExpanded
                      ? l10n.catalogDiscountHideHistoryAction
                      : l10n.catalogDiscountShowHistoryAction,
                ),
              ),
            ],
          ),
          if (historyExpanded) ...[
            const Divider(),
            if (history.isEmpty)
              Text(l10n.catalogDiscountHistoryEmpty)
            else
              for (final e in history)
                Text(
                  l10n.catalogDiscountHistoryLine(
                    e.action.name,
                    e.previousRevision?.toString() ?? '—',
                    e.newRevision?.toString() ?? '—',
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

class _DiscountEditorDialog extends StatefulWidget {
  const _DiscountEditorDialog({required this.l10n, required this.existing});

  final AppLocalizations l10n;
  final BusinessCatalogDiscountRule? existing;

  @override
  State<_DiscountEditorDialog> createState() => _DiscountEditorDialogState();
}

class _DiscountEditorDialogState extends State<_DiscountEditorDialog> {
  late BusinessCatalogDiscountTargetScope _scope;
  String? _branchId;
  String? _listingId;
  String? _variantId;
  late BusinessCatalogDiscountType _discountType;
  late TextEditingController _valueController;
  late TextEditingController _minBasketController;
  late TextEditingController _priorityController;
  late TextEditingController _fromController;
  late TextEditingController _untilController;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _scope = e?.targetScope ?? BusinessCatalogDiscountTargetScope.product;
    _branchId = e?.branchId;
    _listingId = e?.listingId;
    _variantId = e?.variantId;
    _discountType = e?.discountType ?? BusinessCatalogDiscountType.percentage;
    _valueController = TextEditingController(
      text: e == null
          ? '1000'
          : (e.discountType == BusinessCatalogDiscountType.percentage
              ? e.percentBasisPoints.toString()
              : e.fixedAmountSom.toString()),
    );
    _minBasketController = TextEditingController(
      text: e?.minimumBasketAmountSom?.toString() ?? '',
    );
    _priorityController = TextEditingController(
      text: e?.priority.toString() ?? '10',
    );
    _fromController = TextEditingController(
      text: e != null
          ? _formatDate(e.effectiveFrom)
          : _formatDate(kDemoCatalogPricingEpoch),
    );
    _untilController = TextEditingController(
      text: e?.effectiveUntil != null ? _formatDate(e!.effectiveUntil!) : '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _minBasketController.dispose();
    _priorityController.dispose();
    _fromController.dispose();
    _untilController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final controller = getIt<BusinessCatalogDiscountController>();
    final branchController = getIt<BusinessBranchController>();
    final productController = getIt<BusinessCatalogProductController>();
    final serviceController = getIt<BusinessCatalogServiceController>();
    final variantController = getIt<BusinessCatalogProductVariantController>();

    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.catalogDiscountCreateTitle
            : l10n.catalogDiscountEditTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorKey != null)
              Text(
                _mapError(l10n, _errorKey!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            DropdownButtonFormField<BusinessCatalogDiscountTargetScope>(
              isExpanded: true,
              value: _scope,
              decoration: InputDecoration(labelText: l10n.catalogDiscountScopeFilter),
              items: [
                for (final s in BusinessCatalogDiscountTargetScope.values)
                  DropdownMenuItem(value: s, child: Text(s.label(l10n))),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) {
                      if (v == null) {
                        return;
                      }
                      setState(() {
                        _scope = v;
                        _listingId = null;
                        _variantId = null;
                      });
                    },
            ),
            if (_scope != BusinessCatalogDiscountTargetScope.businessWide) ...[
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _listingId,
                decoration: InputDecoration(
                  labelText: _scope == BusinessCatalogDiscountTargetScope.product
                      ? l10n.catalogProductListTitle
                      : l10n.catalogServiceListTitle,
                ),
                items: [
                  if (_scope == BusinessCatalogDiscountTargetScope.product)
                    for (final p in productController.products)
                      DropdownMenuItem(
                        value: p.productId,
                        child: Text(p.displayName(l10n)),
                      )
                  else
                    for (final s in serviceController.services)
                      DropdownMenuItem(
                        value: s.serviceId,
                        child: Text(s.displayName(l10n)),
                      ),
                ],
                onChanged: controller.saveBusy
                    ? null
                    : (v) => setState(() {
                          _listingId = v;
                          _variantId = null;
                        }),
              ),
            ],
            if (_scope == BusinessCatalogDiscountTargetScope.product) ...[
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
                    for (final v
                        in variantController.variantsForProduct(_listingId!))
                      DropdownMenuItem(value: v.variantId, child: Text(v.label)),
                ],
                onChanged: controller.saveBusy
                    ? null
                    : (v) => setState(() => _variantId = v),
              ),
            ],
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _branchId,
              decoration: InputDecoration(labelText: l10n.catalogDiscountBranchFilter),
              items: [
                for (final b in branchController.branches)
                  DropdownMenuItem(value: b.branchId, child: Text(b.name)),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) => setState(() => _branchId = v),
            ),
            DropdownButtonFormField<BusinessCatalogDiscountType>(
              isExpanded: true,
              value: _discountType,
              decoration: InputDecoration(labelText: l10n.catalogDiscountTypeFilter),
              items: [
                for (final t in BusinessCatalogDiscountType.values)
                  DropdownMenuItem(value: t, child: Text(t.label(l10n))),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) {
                      if (v != null) {
                        setState(() => _discountType = v);
                      }
                    },
            ),
            TextField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: _discountType == BusinessCatalogDiscountType.percentage
                    ? l10n.catalogDiscountBasisPointsField
                    : l10n.catalogDiscountFixedAmountField,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextField(
              controller: _minBasketController,
              decoration: InputDecoration(
                labelText: l10n.catalogDiscountMinBasketField,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextField(
              controller: _priorityController,
              decoration: InputDecoration(labelText: l10n.catalogDiscountPriorityField),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextField(
              controller: _fromController,
              decoration: InputDecoration(
                labelText: l10n.catalogPricingEffectiveFromField,
              ),
            ),
            TextField(
              controller: _untilController,
              decoration: InputDecoration(
                labelText: l10n.catalogPricingEffectiveUntilField,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: controller.saveBusy
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(l10n.catalogPricingCancelAction),
        ),
        FilledButton(
          onPressed: controller.saveBusy ? null : _save,
          child: controller.saveBusy
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
    final branchId = _branchId?.trim();
    if (branchId == null || branchId.isEmpty) {
      setState(() => _errorKey = 'scope');
      return;
    }
    final value = int.tryParse(_valueController.text.trim());
    final priority = int.tryParse(_priorityController.text.trim());
    if (value == null || priority == null) {
      setState(() => _errorKey = 'value');
      return;
    }
    final from = _parseDate(_fromController.text.trim());
    if (from == null) {
      setState(() => _errorKey = 'date');
      return;
    }
    final untilText = _untilController.text.trim();
    final until = untilText.isEmpty ? null : _parseDate(untilText);
    if (untilText.isNotEmpty && until == null) {
      setState(() => _errorKey = 'date');
      return;
    }
    final minText = _minBasketController.text.trim();
    final minBasket = minText.isEmpty ? null : int.tryParse(minText);

    final input = BusinessCatalogDiscountRuleInput(
      branchId: branchId,
      targetScope: _scope,
      listingId: _scope == BusinessCatalogDiscountTargetScope.businessWide
          ? null
          : _listingId,
      variantId: _variantId,
      discountType: _discountType,
      percentBasisPoints: _discountType == BusinessCatalogDiscountType.percentage
          ? value
          : null,
      fixedAmountSom: _discountType == BusinessCatalogDiscountType.fixedAmount
          ? value
          : null,
      minimumBasketAmountSom: minBasket,
      effectiveFrom: from,
      effectiveUntil: until,
      priority: priority,
    );

    final discountController = getIt<BusinessCatalogDiscountController>();
    final existing = widget.existing;
    final BusinessCatalogDiscountSaveResult result;
    if (existing == null) {
      result = await discountController.createDraft(input);
    } else if (existing.status == BusinessCatalogPriceStatus.draft) {
      result = await discountController.updateDraft(
        discountRuleId: existing.discountRuleId,
        input: input,
      );
    } else {
      setState(() => _errorKey = 'immutable');
      return;
    }

    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogDiscountSaveResult.success) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _errorKey = result.name);
  }

  String _mapError(AppLocalizations l10n, String key) {
    switch (key) {
      case 'scope':
        return l10n.catalogDiscountScopeRequired;
      case 'value':
        return l10n.catalogDiscountValueInvalid;
      case 'date':
        return l10n.catalogPricingDateInvalid;
      case 'immutable':
      case 'activeImmutable':
        return l10n.catalogDiscountActiveImmutable;
      case 'failure':
        return l10n.catalogDiscountSaveFailed;
      default:
        return l10n.catalogDiscountSaveFailed;
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
