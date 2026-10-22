import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_pricing_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_discount_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_promo_code_usage_record.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_promo_code_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_discount_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_price_status_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_resolver.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_code_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_eligibility.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_promo_eligibility_labels.dart';

class BusinessCatalogPromoCodePage extends StatefulWidget {
  const BusinessCatalogPromoCodePage({super.key});

  @override
  State<BusinessCatalogPromoCodePage> createState() =>
      _BusinessCatalogPromoCodePageState();
}

class _BusinessCatalogPromoCodePageState
    extends State<BusinessCatalogPromoCodePage> {
  String? _branchFilter;
  BusinessCatalogPriceStatus? _statusFilter;
  String? _expandedHistoryId;
  String? _expandedUsageId;

  late final TextEditingController _previewCodeController;
  DateTime _previewAsOf = kDemoCatalogPricingEpoch;
  String _previewBranch = kDemoBranchTashkentCenterId;
  BusinessCatalogListingKind _previewKind = BusinessCatalogListingKind.product;
  String _previewListingId = kDemoCatalogProductBreadId;
  String? _previewSubtotal;
  String? _previewCustomerRef;

  @override
  void initState() {
    super.initState();
    _previewCodeController = TextEditingController(text: 'NON10');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessCatalogPromoCodeController>().refreshList();
      getIt<BusinessCatalogPricingController>().refreshList();
      getIt<BusinessCatalogDiscountController>().refreshList();
    });
  }

  @override
  void dispose() {
    _previewCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final promoController = getIt<BusinessCatalogPromoCodeController>();
    final pricingController = getIt<BusinessCatalogPricingController>();
    final discountController = getIt<BusinessCatalogDiscountController>();
    final branchController = getIt<BusinessBranchController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogPromoListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: promoController.saveBusy
            ? null
            : () => _openEditor(context, l10n, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogPromoAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            promoController,
            pricingController,
            discountController,
            branchController,
          ]),
          builder: (context, _) {
            if (promoController.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = promoController.promoCodes();
            final filtered = promoController.promoCodes(
              branchId: _branchFilter,
              status: _statusFilter,
            );
            final discounts = discountController.allRulesIncludingArchived();
            final priceResolution = pricingController.resolveEffectivePrice(
              listingKind: _previewKind,
              listingId: _previewListingId,
              branchId: _previewBranch,
              asOf: _previewAsOf,
            );
            final baseAmount =
                priceResolution.status == CatalogPriceResolutionStatus.found
                    ? priceResolution.price!.amountSom
                    : null;
            final subtotal = int.tryParse(_previewSubtotal?.trim() ?? '');
            final eligibility = promoController.evaluateEligibility(
              enteredCode: _previewCodeController.text,
              branchId: _previewBranch,
              listingKind: _previewKind,
              listingId: _previewListingId,
              asOf: _previewAsOf,
              basePriceAmountSom: baseAmount,
              qualifyingSubtotalAmountSom: subtotal,
              demoCustomerReference: _previewCustomerRef,
            );
            final usageBeforePreview = _snapshotBeforePreview(promoController);

            return ResponsiveLayout(
              phone: _PromoBody(
                maxWidth: 520,
                l10n: l10n,
                promos: filtered,
                allCount: all.length,
                branches: branchController.branches,
                discounts: discounts,
                branchFilter: _branchFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                expandedUsageId: _expandedUsageId,
                saveBusy: promoController.saveBusy,
                previewCodeController: _previewCodeController,
                previewAsOf: _previewAsOf,
                eligibility: eligibility,
                usageBeforePreview: usageBeforePreview,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onStatusFilterChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onToggleUsage: (id) => setState(() {
                  _expandedUsageId = _expandedUsageId == id ? null : id;
                }),
                onPreviewCodeChanged: (_) => setState(() {}),
                onPreviewAsOfChanged: (d) => setState(() => _previewAsOf = d),
                onPreviewCustomerChanged: (v) =>
                    setState(() => _previewCustomerRef = v),
                onPreviewSubtotalChanged: (v) =>
                    setState(() => _previewSubtotal = v),
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                discountLabel: (id) =>
                    discounts
                        .where((d) => d.discountRuleId == id)
                        .map((d) => d.discountRuleId)
                        .firstOrNull ??
                    id,
                historyFor: promoController.historyFor,
                usageFor: promoController.usageFor,
                onEdit: (p) => _openEditor(context, l10n, p),
                onActivate: (p) => _activate(l10n, p),
                onArchive: (p) => _archive(p),
              ),
              tablet: _PromoBody(
                maxWidth: 760,
                l10n: l10n,
                promos: filtered,
                allCount: all.length,
                branches: branchController.branches,
                discounts: discounts,
                branchFilter: _branchFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                expandedUsageId: _expandedUsageId,
                saveBusy: promoController.saveBusy,
                previewCodeController: _previewCodeController,
                previewAsOf: _previewAsOf,
                eligibility: eligibility,
                usageBeforePreview: usageBeforePreview,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onStatusFilterChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onToggleUsage: (id) => setState(() {
                  _expandedUsageId = _expandedUsageId == id ? null : id;
                }),
                onPreviewCodeChanged: (_) => setState(() {}),
                onPreviewAsOfChanged: (d) => setState(() => _previewAsOf = d),
                onPreviewCustomerChanged: (v) =>
                    setState(() => _previewCustomerRef = v),
                onPreviewSubtotalChanged: (v) =>
                    setState(() => _previewSubtotal = v),
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                discountLabel: (id) => id,
                historyFor: promoController.historyFor,
                usageFor: promoController.usageFor,
                onEdit: (p) => _openEditor(context, l10n, p),
                onActivate: (p) => _activate(l10n, p),
                onArchive: (p) => _archive(p),
              ),
            );
          },
        ),
      ),
    );
  }

  CatalogPromoUsageSnapshot? _snapshotBeforePreview(
    BusinessCatalogPromoCodeController controller,
  ) {
    final promo = getIt<BusinessCatalogPromoCodeRepository>()
        .findByNormalizedCode(_previewCodeController.text);
    if (promo == null) {
      return null;
    }
    return controller.usageSnapshot(
      promoCodeId: promo.promoCodeId,
      demoCustomerReference: _previewCustomerRef,
    );
  }

  Future<void> _activate(AppLocalizations l10n, BusinessCatalogPromoCode promo) async {
    final result = await getIt<BusinessCatalogPromoCodeController>()
        .activatePromo(promo.promoCodeId);
    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogPromoCodeStatusChangeResult.discountIntervalMismatch ||
        result == BusinessCatalogPromoCodeStatusChangeResult.discountLinkInactive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogPromoActivateDiscountError)),
      );
    }
  }

  Future<void> _archive(BusinessCatalogPromoCode promo) async {
    await getIt<BusinessCatalogPromoCodeController>()
        .archivePromo(promo.promoCodeId);
  }

  Future<void> _openEditor(
    BuildContext context,
    AppLocalizations l10n,
    BusinessCatalogPromoCode? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _PromoEditorDialog(l10n: l10n, existing: existing),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}

class _PromoBody extends StatelessWidget {
  const _PromoBody({
    required this.maxWidth,
    required this.l10n,
    required this.promos,
    required this.allCount,
    required this.branches,
    required this.discounts,
    required this.branchFilter,
    required this.statusFilter,
    required this.expandedHistoryId,
    required this.expandedUsageId,
    required this.saveBusy,
    required this.previewCodeController,
    required this.previewAsOf,
    required this.eligibility,
    required this.usageBeforePreview,
    required this.onBranchFilterChanged,
    required this.onStatusFilterChanged,
    required this.onToggleHistory,
    required this.onToggleUsage,
    required this.onPreviewCodeChanged,
    required this.onPreviewAsOfChanged,
    required this.onPreviewCustomerChanged,
    required this.onPreviewSubtotalChanged,
    required this.branchLabel,
    required this.discountLabel,
    required this.historyFor,
    required this.usageFor,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessCatalogPromoCode> promos;
  final int allCount;
  final List<BusinessBranch> branches;
  final List<BusinessCatalogDiscountRule> discounts;
  final String? branchFilter;
  final BusinessCatalogPriceStatus? statusFilter;
  final String? expandedHistoryId;
  final String? expandedUsageId;
  final bool saveBusy;
  final TextEditingController previewCodeController;
  final DateTime previewAsOf;
  final CatalogPromoCodeEligibilityResult eligibility;
  final CatalogPromoUsageSnapshot? usageBeforePreview;
  final ValueChanged<String?> onBranchFilterChanged;
  final ValueChanged<BusinessCatalogPriceStatus?> onStatusFilterChanged;
  final ValueChanged<String> onToggleHistory;
  final ValueChanged<String> onToggleUsage;
  final ValueChanged<String> onPreviewCodeChanged;
  final ValueChanged<DateTime> onPreviewAsOfChanged;
  final ValueChanged<String?> onPreviewCustomerChanged;
  final ValueChanged<String?> onPreviewSubtotalChanged;
  final String Function(String id) branchLabel;
  final String Function(String id) discountLabel;
  final List<BusinessCatalogPromoCodeHistoryEvent> Function(String) historyFor;
  final List<BusinessCatalogPromoCodeUsageRecord> Function(String) usageFor;
  final void Function(BusinessCatalogPromoCode) onEdit;
  final void Function(BusinessCatalogPromoCode) onActivate;
  final void Function(BusinessCatalogPromoCode) onArchive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String previewLine = eligibility.status.label(l10n);
    if (eligibility.status == CatalogPromoCodeEligibilityStatus.eligible) {
      previewLine = l10n.catalogPromoPreviewApplied(
        formatCatalogPriceAmountSom(eligibility.baseAmountSom!),
        formatCatalogPriceAmountSom(eligibility.discountAmountSom!),
        formatCatalogPriceAmountSom(eligibility.finalAmountSom!),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.catalogPromoDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.catalogPromoPreviewTitle,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  TextField(
                    decoration: InputDecoration(labelText: l10n.catalogPromoPreviewCode),
                    controller: previewCodeController,
                    onChanged: onPreviewCodeChanged,
                  ),
                  TextField(
                    decoration:
                        InputDecoration(labelText: l10n.catalogPromoPreviewCustomer),
                    onChanged: onPreviewCustomerChanged,
                  ),
                  TextField(
                    decoration:
                        InputDecoration(labelText: l10n.catalogDiscountPreviewSubtotal),
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
                                DateTime.utc(picked.year, picked.month, picked.day),
                              );
                            }
                          },
                    icon: const Icon(Icons.event),
                    label: Text(l10n.catalogPricingPreviewAsOfLabel(_formatDate(previewAsOf))),
                  ),
                  Text(previewLine),
                  if (usageBeforePreview != null)
                    Text(l10n.catalogPromoUsageSnapshotLine(
                      usageBeforePreview!.totalUses,
                      usageBeforePreview!.usesForCustomer,
                    )),
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
                    decoration: InputDecoration(labelText: l10n.catalogPromoBranchFilter),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.catalogPromoAllBranches)),
                      for (final b in branches)
                        DropdownMenuItem(value: b.branchId, child: Text(b.name)),
                    ],
                    onChanged: saveBusy ? null : onBranchFilterChanged,
                  ),
                  DropdownButtonFormField<BusinessCatalogPriceStatus?>(
                    isExpanded: true,
                    value: statusFilter,
                    decoration: InputDecoration(labelText: l10n.catalogPromoStatusFilter),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.catalogPromoAllStatuses)),
                      for (final s in BusinessCatalogPriceStatus.values)
                        if (s != BusinessCatalogPriceStatus.archived)
                          DropdownMenuItem(value: s, child: Text(s.label(l10n))),
                    ],
                    onChanged: saveBusy ? null : onStatusFilterChanged,
                  ),
                  Text(l10n.catalogListingFilteredCount(promos.length, allCount),
                      style: textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (promos.isEmpty)
              AppSurfaceCard(child: Text(l10n.catalogPromoEmptyBody))
            else
              for (final p in promos) ...[
                _PromoCard(
                  l10n: l10n,
                  promo: p,
                  branchName: p.branchId != null ? branchLabel(p.branchId!) : '—',
                  discountName: discountLabel(p.discountRuleId),
                  historyExpanded: expandedHistoryId == p.promoCodeId,
                  usageExpanded: expandedUsageId == p.promoCodeId,
                  history: historyFor(p.promoCodeId),
                  usage: usageFor(p.promoCodeId),
                  saveBusy: saveBusy,
                  onToggleHistory: () => onToggleHistory(p.promoCodeId),
                  onToggleUsage: () => onToggleUsage(p.promoCodeId),
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

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.l10n,
    required this.promo,
    required this.branchName,
    required this.discountName,
    required this.historyExpanded,
    required this.usageExpanded,
    required this.history,
    required this.usage,
    required this.saveBusy,
    required this.onToggleHistory,
    required this.onToggleUsage,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final AppLocalizations l10n;
  final BusinessCatalogPromoCode promo;
  final String branchName;
  final String discountName;
  final bool historyExpanded;
  final bool usageExpanded;
  final List<BusinessCatalogPromoCodeHistoryEvent> history;
  final List<BusinessCatalogPromoCodeUsageRecord> usage;
  final bool saveBusy;
  final VoidCallback onToggleHistory;
  final VoidCallback onToggleUsage;
  final VoidCallback onEdit;
  final VoidCallback onActivate;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(promo.code, style: Theme.of(context).textTheme.titleSmall),
          Text(l10n.catalogPromoLinkedDiscountLabel(discountName)),
          Text(l10n.catalogPricingBranchLabel(branchName)),
          Text(promo.status.label(l10n)),
          if (promo.maxTotalUses != null)
            Text(l10n.catalogPromoMaxTotalUsesLabel(promo.maxTotalUses!)),
          if (promo.maxUsesPerCustomer != null)
            Text(l10n.catalogPromoMaxCustomerUsesLabel(promo.maxUsesPerCustomer!)),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (promo.status == BusinessCatalogPriceStatus.draft)
                FilledButton.tonal(onPressed: saveBusy ? null : onEdit, child: Text(l10n.catalogPromoEditAction)),
              if (promo.status == BusinessCatalogPriceStatus.draft)
                FilledButton(onPressed: saveBusy ? null : onActivate, child: Text(l10n.catalogPromoActivateAction)),
              if (promo.status == BusinessCatalogPriceStatus.active)
                OutlinedButton(onPressed: saveBusy ? null : onArchive, child: Text(l10n.catalogPromoArchiveAction)),
              TextButton(onPressed: saveBusy ? null : onToggleHistory, child: Text(l10n.catalogPromoShowHistoryAction)),
              TextButton(onPressed: saveBusy ? null : onToggleUsage, child: Text(l10n.catalogPromoShowUsageAction)),
            ],
          ),
          if (historyExpanded && history.isNotEmpty)
            for (final e in history)
              Text('${e.action.name} rev ${e.newRevision ?? ''}'),
          if (usageExpanded)
            for (final u in usage)
              Text(l10n.catalogPromoUsageLine(u.demoCustomerReference, u.demoRedemptionReference)),
        ],
      ),
    );
  }
}

class _PromoEditorDialog extends StatefulWidget {
  const _PromoEditorDialog({required this.l10n, required this.existing});
  final AppLocalizations l10n;
  final BusinessCatalogPromoCode? existing;

  @override
  State<_PromoEditorDialog> createState() => _PromoEditorDialogState();
}

class _PromoEditorDialogState extends State<_PromoEditorDialog> {
  late TextEditingController _codeController;
  String? _branchId;
  String? _discountRuleId;
  late TextEditingController _fromController;
  late TextEditingController _untilController;
  late TextEditingController _minBasketController;
  late TextEditingController _maxTotalController;
  late TextEditingController _maxCustomerController;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _codeController = TextEditingController(text: e?.code ?? 'NEWCODE');
    _branchId = e?.branchId;
    _discountRuleId = e?.discountRuleId;
    _fromController = TextEditingController(
      text: e != null ? _formatDate(e.effectiveFrom) : _formatDate(kDemoCatalogPricingEpoch),
    );
    _untilController = TextEditingController(
      text: e?.effectiveUntil != null ? _formatDate(e!.effectiveUntil!) : '',
    );
    _minBasketController = TextEditingController(text: e?.minimumBasketAmountSom?.toString() ?? '');
    _maxTotalController = TextEditingController(text: e?.maxTotalUses?.toString() ?? '');
    _maxCustomerController = TextEditingController(text: e?.maxUsesPerCustomer?.toString() ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _fromController.dispose();
    _untilController.dispose();
    _minBasketController.dispose();
    _maxTotalController.dispose();
    _maxCustomerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final controller = getIt<BusinessCatalogPromoCodeController>();
    final branchController = getIt<BusinessBranchController>();
    final discountController = getIt<BusinessCatalogDiscountController>();
    final rules = discountController.allRulesIncludingArchived();

    return AlertDialog(
      title: Text(existing == null ? l10n.catalogPromoCreateTitle : l10n.catalogPromoEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorKey != null)
              Text(
                _mapSaveError(l10n, _errorKey!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: l10n.catalogPromoCodeField),
              textCapitalization: TextCapitalization.characters,
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _branchId,
              decoration: InputDecoration(labelText: l10n.catalogPromoBranchFilter),
              items: [
                for (final b in branchController.branches)
                  DropdownMenuItem(value: b.branchId, child: Text(b.name)),
              ],
              onChanged: controller.saveBusy ? null : (v) => setState(() => _branchId = v),
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _discountRuleId,
              decoration: InputDecoration(labelText: l10n.catalogPromoLinkedDiscountLabel('')),
              items: [
                for (final r in rules)
                  DropdownMenuItem(value: r.discountRuleId, child: Text(r.discountRuleId)),
              ],
              onChanged: controller.saveBusy ? null : (v) => setState(() => _discountRuleId = v),
            ),
            TextField(controller: _fromController, decoration: InputDecoration(labelText: l10n.catalogPricingEffectiveFromField)),
            TextField(controller: _untilController, decoration: InputDecoration(labelText: l10n.catalogPricingEffectiveUntilField)),
            TextField(controller: _minBasketController, decoration: InputDecoration(labelText: l10n.catalogPromoMinBasketField)),
            TextField(controller: _maxTotalController, decoration: InputDecoration(labelText: l10n.catalogPromoMaxTotalUsesField)),
            TextField(controller: _maxCustomerController, decoration: InputDecoration(labelText: l10n.catalogPromoMaxCustomerUsesField)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: controller.saveBusy ? null : () => Navigator.pop(context), child: Text(l10n.catalogPricingCancelAction)),
        FilledButton(onPressed: controller.saveBusy ? null : _save, child: Text(l10n.catalogPricingSaveAction)),
      ],
    );
  }

  BusinessCatalogPromoCode? get existing => widget.existing;

  Future<void> _save() async {
    final discountRuleId = _discountRuleId?.trim();
    if (discountRuleId == null || discountRuleId.isEmpty) {
      setState(() => _errorKey = 'scope');
      return;
    }
    final from = _parseDate(_fromController.text.trim());
    if (from == null) {
      setState(() => _errorKey = 'date');
      return;
    }
    final untilText = _untilController.text.trim();
    final until = untilText.isEmpty ? null : _parseDate(untilText);
    int? parseOpt(String text) {
      final t = text.trim();
      if (t.isEmpty) {
        return null;
      }
      return int.tryParse(t);
    }

    final input = BusinessCatalogPromoCodeInput(
      branchId: _branchId,
      code: _codeController.text,
      discountRuleId: discountRuleId,
      effectiveFrom: from,
      effectiveUntil: until,
      minimumBasketAmountSom: parseOpt(_minBasketController.text),
      maxTotalUses: parseOpt(_maxTotalController.text),
      maxUsesPerCustomer: parseOpt(_maxCustomerController.text),
    );

    final ctrl = getIt<BusinessCatalogPromoCodeController>();
    final result = existing == null
        ? await ctrl.createDraft(input)
        : existing!.status == BusinessCatalogPriceStatus.draft
            ? await ctrl.updateDraft(promoCodeId: existing!.promoCodeId, input: input)
            : BusinessCatalogPromoCodeSaveResult.activeImmutable;

    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogPromoCodeSaveResult.success) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _errorKey = result == BusinessCatalogPromoCodeSaveResult.activeImmutable
          ? 'immutable'
          : result.name;
    });
  }

  String _mapSaveError(AppLocalizations l10n, String key) {
    if (key == 'immutable') {
      return l10n.catalogPromoActiveImmutable;
    }
    if (key == 'scope' || key == 'date') {
      return l10n.catalogPromoSaveFailed;
    }
    return l10n.catalogPromoSaveFailed;
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
