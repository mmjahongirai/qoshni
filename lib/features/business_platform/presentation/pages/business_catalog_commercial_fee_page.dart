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
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_rule.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_commercial_fee_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_preview.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_price_status_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

class BusinessCatalogCommercialFeePage extends StatefulWidget {
  const BusinessCatalogCommercialFeePage({super.key});

  @override
  State<BusinessCatalogCommercialFeePage> createState() =>
      _BusinessCatalogCommercialFeePageState();
}

class _BusinessCatalogCommercialFeePageState
    extends State<BusinessCatalogCommercialFeePage> {
  String? _branchFilter;
  BusinessCatalogCommercialFeeType? _typeFilter;
  BusinessCatalogPriceStatus? _statusFilter;
  String? _expandedHistoryId;
  DateTime _previewAsOf = kDemoCatalogPricingEpoch;
  String _previewBranch = kDemoBranchTashkentCenterId;
  String _listingBaseText = '8000';
  String _serviceText = '5000';
  String _deliveryText = '12000';
  String _commissionText = '8000';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessCatalogCommercialFeeController>().refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feeController = getIt<BusinessCatalogCommercialFeeController>();
    final branchController = getIt<BusinessBranchController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogCommercialFeeListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: feeController.saveBusy
            ? null
            : () => _openEditor(context, l10n, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogCommercialFeeAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([feeController, branchController]),
          builder: (context, _) {
            if (feeController.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = feeController.rules();
            final filtered = feeController.rules(
              branchId: _branchFilter,
              feeType: _typeFilter,
              status: _statusFilter,
            );
            final preview = feeController.previewFees(
              branchId: _previewBranch,
              asOf: _previewAsOf,
              listingBaseAmountSom: int.tryParse(_listingBaseText.trim()),
              serviceAmountSom: int.tryParse(_serviceText.trim()),
              deliveryBasisAmountSom: int.tryParse(_deliveryText.trim()),
              commissionBasisAmountSom: int.tryParse(_commissionText.trim()),
            );

            return ResponsiveLayout(
              phone: _FeeBody(
                maxWidth: 520,
                l10n: l10n,
                rules: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                typeFilter: _typeFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: feeController.saveBusy,
                previewAsOf: _previewAsOf,
                preview: preview,
                listingBaseText: _listingBaseText,
                serviceText: _serviceText,
                deliveryText: _deliveryText,
                commissionText: _commissionText,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: feeController.historyFor,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onTypeFilterChanged: (v) => setState(() => _typeFilter = v),
                onStatusFilterChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onPreviewAsOfChanged: (d) => setState(() => _previewAsOf = d),
                onListingBaseChanged: (v) => setState(() => _listingBaseText = v),
                onServiceChanged: (v) => setState(() => _serviceText = v),
                onDeliveryChanged: (v) => setState(() => _deliveryText = v),
                onCommissionChanged: (v) => setState(() => _commissionText = v),
                onEdit: (r) => _openEditor(context, l10n, r),
                onActivate: (r) => _activate(l10n, r),
                onArchive: (r) => feeController.archiveRule(r.feeRuleId),
              ),
              tablet: _FeeBody(
                maxWidth: 760,
                l10n: l10n,
                rules: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                typeFilter: _typeFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: feeController.saveBusy,
                previewAsOf: _previewAsOf,
                preview: preview,
                listingBaseText: _listingBaseText,
                serviceText: _serviceText,
                deliveryText: _deliveryText,
                commissionText: _commissionText,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: feeController.historyFor,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onTypeFilterChanged: (v) => setState(() => _typeFilter = v),
                onStatusFilterChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onPreviewAsOfChanged: (d) => setState(() => _previewAsOf = d),
                onListingBaseChanged: (v) => setState(() => _listingBaseText = v),
                onServiceChanged: (v) => setState(() => _serviceText = v),
                onDeliveryChanged: (v) => setState(() => _deliveryText = v),
                onCommissionChanged: (v) => setState(() => _commissionText = v),
                onEdit: (r) => _openEditor(context, l10n, r),
                onActivate: (r) => _activate(l10n, r),
                onArchive: (r) => feeController.archiveRule(r.feeRuleId),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _activate(
    AppLocalizations l10n,
    BusinessCatalogCommercialFeeRule rule,
  ) async {
    final result =
        await getIt<BusinessCatalogCommercialFeeController>().activateRule(
      rule.feeRuleId,
    );
    if (!mounted) {
      return;
    }
    if (result ==
        BusinessCatalogCommercialFeeStatusChangeResult.activeIntervalOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogCommercialFeeActivateOverlapError)),
      );
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    AppLocalizations l10n,
    BusinessCatalogCommercialFeeRule? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _FeeEditorDialog(l10n: l10n, existing: existing),
    );
  }
}

class _FeeBody extends StatelessWidget {
  const _FeeBody({
    required this.maxWidth,
    required this.l10n,
    required this.rules,
    required this.allCount,
    required this.branches,
    required this.branchFilter,
    required this.typeFilter,
    required this.statusFilter,
    required this.expandedHistoryId,
    required this.saveBusy,
    required this.previewAsOf,
    required this.preview,
    required this.listingBaseText,
    required this.serviceText,
    required this.deliveryText,
    required this.commissionText,
    required this.branchLabel,
    required this.historyFor,
    required this.onBranchFilterChanged,
    required this.onTypeFilterChanged,
    required this.onStatusFilterChanged,
    required this.onToggleHistory,
    required this.onPreviewAsOfChanged,
    required this.onListingBaseChanged,
    required this.onServiceChanged,
    required this.onDeliveryChanged,
    required this.onCommissionChanged,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessCatalogCommercialFeeRule> rules;
  final int allCount;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessCatalogCommercialFeeType? typeFilter;
  final BusinessCatalogPriceStatus? statusFilter;
  final String? expandedHistoryId;
  final bool saveBusy;
  final DateTime previewAsOf;
  final CommercialFeesPreviewResult preview;
  final String listingBaseText;
  final String serviceText;
  final String deliveryText;
  final String commissionText;
  final String Function(String id) branchLabel;
  final List<BusinessCatalogCommercialFeeHistoryEvent> Function(String)
      historyFor;
  final ValueChanged<String?> onBranchFilterChanged;
  final ValueChanged<BusinessCatalogCommercialFeeType?> onTypeFilterChanged;
  final ValueChanged<BusinessCatalogPriceStatus?> onStatusFilterChanged;
  final ValueChanged<String> onToggleHistory;
  final ValueChanged<DateTime> onPreviewAsOfChanged;
  final ValueChanged<String> onListingBaseChanged;
  final ValueChanged<String> onServiceChanged;
  final ValueChanged<String> onDeliveryChanged;
  final ValueChanged<String> onCommissionChanged;
  final void Function(BusinessCatalogCommercialFeeRule) onEdit;
  final void Function(BusinessCatalogCommercialFeeRule) onActivate;
  final void Function(BusinessCatalogCommercialFeeRule) onArchive;

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
              message: l10n.catalogCommercialFeeDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.catalogCommercialFeePreviewTitle,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  _amountField(l10n.catalogCommercialFeePreviewListingBase,
                      listingBaseText, onListingBaseChanged),
                  _amountField(l10n.catalogCommercialFeePreviewService,
                      serviceText, onServiceChanged),
                  _amountField(l10n.catalogCommercialFeePreviewDelivery,
                      deliveryText, onDeliveryChanged),
                  _amountField(l10n.catalogCommercialFeePreviewCommission,
                      commissionText, onCommissionChanged),
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
                    label: Text(l10n.catalogPricingPreviewAsOfLabel(
                        _formatDate(previewAsOf))),
                  ),
                  if (preview.status == CommercialFeesPreviewStatus.ambiguous)
                    Text(l10n.catalogCommercialFeePreviewAmbiguous(
                      preview.ambiguousFeeTypes
                          .map((t) => t.label(l10n))
                          .join(', '),
                    )),
                  for (final line in preview.lines) Text(line.summaryLine(l10n)),
                  Text(l10n.catalogCommercialFeePreviewTotal(
                    formatCatalogPriceAmountSom(preview.totalComputedFeeSom),
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
                    decoration: InputDecoration(
                        labelText: l10n.catalogCommercialFeeBranchFilter),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text(l10n.catalogCommercialFeeAllBranches)),
                      for (final b in branches)
                        DropdownMenuItem(value: b.branchId, child: Text(b.name)),
                    ],
                    onChanged: saveBusy ? null : onBranchFilterChanged,
                  ),
                  DropdownButtonFormField<BusinessCatalogCommercialFeeType?>(
                    isExpanded: true,
                    value: typeFilter,
                    decoration: InputDecoration(
                        labelText: l10n.catalogCommercialFeeTypeFilter),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text(l10n.catalogCommercialFeeAllTypes)),
                      for (final t in BusinessCatalogCommercialFeeType.values)
                        DropdownMenuItem(value: t, child: Text(t.label(l10n))),
                    ],
                    onChanged: saveBusy ? null : onTypeFilterChanged,
                  ),
                  DropdownButtonFormField<BusinessCatalogPriceStatus?>(
                    isExpanded: true,
                    value: statusFilter,
                    decoration: InputDecoration(
                        labelText: l10n.catalogCommercialFeeStatusFilter),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text(l10n.catalogCommercialFeeAllStatuses)),
                      for (final s in BusinessCatalogPriceStatus.values)
                        if (s != BusinessCatalogPriceStatus.archived)
                          DropdownMenuItem(value: s, child: Text(s.label(l10n))),
                    ],
                    onChanged: saveBusy ? null : onStatusFilterChanged,
                  ),
                  Text(l10n.catalogListingFilteredCount(rules.length, allCount),
                      style: textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (rules.isEmpty)
              AppSurfaceCard(child: Text(l10n.catalogCommercialFeeEmptyBody))
            else
              for (final r in rules) ...[
                _FeeCard(
                  l10n: l10n,
                  rule: r,
                  branchName: r.branchId != null ? branchLabel(r.branchId!) : '—',
                  historyExpanded: expandedHistoryId == r.feeRuleId,
                  history: historyFor(r.feeRuleId),
                  saveBusy: saveBusy,
                  onToggleHistory: () => onToggleHistory(r.feeRuleId),
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

  Widget _amountField(
    String label,
    String initial,
    ValueChanged<String> onChanged,
  ) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: TextEditingController(text: initial),
      onChanged: onChanged,
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _FeeCard extends StatelessWidget {
  const _FeeCard({
    required this.l10n,
    required this.rule,
    required this.branchName,
    required this.historyExpanded,
    required this.history,
    required this.saveBusy,
    required this.onToggleHistory,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final AppLocalizations l10n;
  final BusinessCatalogCommercialFeeRule rule;
  final String branchName;
  final bool historyExpanded;
  final List<BusinessCatalogCommercialFeeHistoryEvent> history;
  final bool saveBusy;
  final VoidCallback onToggleHistory;
  final VoidCallback onEdit;
  final VoidCallback onActivate;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final valueLabel = rule.calculationType ==
            BusinessCatalogCommercialFeeCalculationType.percentage
        ? '${(rule.percentBasisPoints ?? 0) ~/ 100}%'
        : formatCatalogPriceAmountSom(rule.fixedAmountSom ?? 0);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(rule.feeType.label(l10n),
              style: Theme.of(context).textTheme.titleSmall),
          Text(rule.chargeBearer.label(l10n)),
          Text(rule.calculationType.label(l10n)),
          Text(valueLabel),
          Text(rule.applicationBasis.label(l10n)),
          Text(l10n.catalogPricingBranchLabel(branchName)),
          Text(rule.status.label(l10n)),
          Text(l10n.catalogCommercialFeePriorityLabel(rule.priority)),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (rule.status == BusinessCatalogPriceStatus.draft)
                FilledButton.tonal(
                    onPressed: saveBusy ? null : onEdit,
                    child: Text(l10n.catalogCommercialFeeEditAction)),
              if (rule.status == BusinessCatalogPriceStatus.draft)
                FilledButton(
                    onPressed: saveBusy ? null : onActivate,
                    child: Text(l10n.catalogCommercialFeeActivateAction)),
              if (rule.status == BusinessCatalogPriceStatus.active)
                OutlinedButton(
                    onPressed: saveBusy ? null : onArchive,
                    child: Text(l10n.catalogCommercialFeeArchiveAction)),
              TextButton(
                  onPressed: saveBusy ? null : onToggleHistory,
                  child: Text(historyExpanded
                      ? l10n.catalogCommercialFeeHideHistoryAction
                      : l10n.catalogCommercialFeeShowHistoryAction)),
            ],
          ),
          if (historyExpanded)
            for (final e in history)
              Text('${e.action.name} rev ${e.newRevision ?? ''}'),
        ],
      ),
    );
  }
}

class _FeeEditorDialog extends StatefulWidget {
  const _FeeEditorDialog({required this.l10n, required this.existing});
  final AppLocalizations l10n;
  final BusinessCatalogCommercialFeeRule? existing;

  @override
  State<_FeeEditorDialog> createState() => _FeeEditorDialogState();
}

class _FeeEditorDialogState extends State<_FeeEditorDialog> {
  String? _branchId;
  BusinessCatalogCommercialFeeType _feeType =
      BusinessCatalogCommercialFeeType.platformFee;
  BusinessCatalogCommercialFeeChargeBearer _bearer =
      BusinessCatalogCommercialFeeChargeBearer.customer;
  BusinessCatalogCommercialFeeCalculationType _calcType =
      BusinessCatalogCommercialFeeCalculationType.fixedAmount;
  BusinessCatalogCommercialFeeApplicationBasis _basis =
      BusinessCatalogCommercialFeeApplicationBasis.listingBase;
  late TextEditingController _fixedController;
  late TextEditingController _bpController;
  late TextEditingController _priorityController;
  late TextEditingController _fromController;
  late TextEditingController _untilController;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _branchId = e?.branchId ?? kDemoBranchTashkentCenterId;
    if (e != null) {
      _feeType = e.feeType;
      _bearer = e.chargeBearer;
      _calcType = e.calculationType;
      _basis = e.applicationBasis;
    }
    _fixedController =
        TextEditingController(text: e?.fixedAmountSom?.toString() ?? '500');
    _bpController =
        TextEditingController(text: e?.percentBasisPoints?.toString() ?? '500');
    _priorityController =
        TextEditingController(text: e?.priority.toString() ?? '100');
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
    _fixedController.dispose();
    _bpController.dispose();
    _priorityController.dispose();
    _fromController.dispose();
    _untilController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final controller = getIt<BusinessCatalogCommercialFeeController>();
    final branchController = getIt<BusinessBranchController>();

    return AlertDialog(
      title: Text(widget.existing == null
          ? l10n.catalogCommercialFeeCreateTitle
          : l10n.catalogCommercialFeeEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorKey != null)
              Text(l10n.catalogCommercialFeeSaveFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _branchId,
              items: [
                for (final b in branchController.branches)
                  DropdownMenuItem(value: b.branchId, child: Text(b.name)),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) => setState(() => _branchId = v),
            ),
            DropdownButtonFormField<BusinessCatalogCommercialFeeType>(
              isExpanded: true,
              value: _feeType,
              items: [
                for (final t in BusinessCatalogCommercialFeeType.values)
                  DropdownMenuItem(value: t, child: Text(t.label(l10n))),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) => setState(() => _feeType = v ?? _feeType),
            ),
            DropdownButtonFormField<BusinessCatalogCommercialFeeChargeBearer>(
              isExpanded: true,
              value: _bearer,
              items: [
                for (final b in BusinessCatalogCommercialFeeChargeBearer.values)
                  DropdownMenuItem(value: b, child: Text(b.label(l10n))),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) => setState(() => _bearer = v ?? _bearer),
            ),
            DropdownButtonFormField<
                BusinessCatalogCommercialFeeCalculationType>(
              isExpanded: true,
              value: _calcType,
              items: [
                for (final c
                    in BusinessCatalogCommercialFeeCalculationType.values)
                  DropdownMenuItem(value: c, child: Text(c.label(l10n))),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) => setState(() => _calcType = v ?? _calcType),
            ),
            if (_calcType ==
                BusinessCatalogCommercialFeeCalculationType.fixedAmount)
              TextField(
                controller: _fixedController,
                decoration:
                    InputDecoration(labelText: l10n.catalogCommercialFeeFixedField),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )
            else
              TextField(
                controller: _bpController,
                decoration: InputDecoration(
                    labelText: l10n.catalogCommercialFeeBasisPointsField),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            DropdownButtonFormField<
                BusinessCatalogCommercialFeeApplicationBasis>(
              isExpanded: true,
              value: _basis,
              items: [
                for (final b in BusinessCatalogCommercialFeeApplicationBasis.values)
                  DropdownMenuItem(value: b, child: Text(b.label(l10n))),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) => setState(() => _basis = v ?? _basis),
            ),
            TextField(
              controller: _priorityController,
              decoration:
                  InputDecoration(labelText: l10n.catalogCommercialFeePriorityField),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextField(
              controller: _fromController,
              decoration:
                  InputDecoration(labelText: l10n.catalogPricingEffectiveFromField),
            ),
            TextField(
              controller: _untilController,
              decoration:
                  InputDecoration(labelText: l10n.catalogPricingEffectiveUntilField),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: controller.saveBusy ? null : () => Navigator.pop(context),
          child: Text(l10n.catalogPricingCancelAction),
        ),
        FilledButton(
          onPressed: controller.saveBusy ? null : _save,
          child: Text(l10n.catalogPricingSaveAction),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final from = _parseDate(_fromController.text.trim());
    if (from == null) {
      setState(() => _errorKey = 'date');
      return;
    }
    final untilText = _untilController.text.trim();
    final until = untilText.isEmpty ? null : _parseDate(untilText);
    final priority = int.tryParse(_priorityController.text.trim()) ?? -1;

    final input = BusinessCatalogCommercialFeeRuleInput(
      branchId: _branchId,
      feeType: _feeType,
      chargeBearer: _bearer,
      calculationType: _calcType,
      fixedAmountSom: _calcType ==
              BusinessCatalogCommercialFeeCalculationType.fixedAmount
          ? int.tryParse(_fixedController.text.trim())
          : null,
      percentBasisPoints: _calcType ==
              BusinessCatalogCommercialFeeCalculationType.percentage
          ? int.tryParse(_bpController.text.trim())
          : null,
      applicationBasis: _basis,
      effectiveFrom: from,
      effectiveUntil: until,
      priority: priority,
    );

    final ctrl = getIt<BusinessCatalogCommercialFeeController>();
    final existing = widget.existing;
    final result = existing == null
        ? await ctrl.createDraft(input)
        : existing.status == BusinessCatalogPriceStatus.draft
            ? await ctrl.updateDraft(feeRuleId: existing.feeRuleId, input: input)
            : BusinessCatalogCommercialFeeSaveResult.activeImmutable;

    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogCommercialFeeSaveResult.success) {
      Navigator.pop(context);
      return;
    }
    setState(() => _errorKey = result.name);
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
