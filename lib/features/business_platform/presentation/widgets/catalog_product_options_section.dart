import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_group.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_validation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_selection_mode.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_option_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_option_controller.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_localized_name_fields.dart';

class CatalogProductOptionsSection extends StatelessWidget {
  const CatalogProductOptionsSection({
    required this.productId,
    this.readOnly = false,
    super.key,
  });

  final String productId;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogProductOptionController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final groups = controller.groupsForProduct(productId, includeArchived: readOnly);
        return AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.catalogProductOptionsSectionTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (groups.isEmpty)
                Text(l10n.catalogProductOptionsEmptyBody)
              else
                ...groups.map(
                  (group) => _GroupTile(
                    l10n: l10n,
                    group: group,
                    readOnly: readOnly,
                    busy: controller.saveBusy,
                    onEdit: () => _editGroup(context, group),
                    onArchive: () => _archiveGroup(context, group.groupId),
                    onAddOption: () => _editOption(context, group: group),
                    onEditOption: (option) => _editOption(
                      context,
                      group: group,
                      existing: option,
                    ),
                    onToggleOption: (option, active) => _toggleOption(
                      context,
                      option,
                      active,
                    ),
                  ),
                ),
              if (!readOnly) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: controller.saveBusy
                      ? null
                      : () => _editGroup(context, null),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.catalogProductOptionGroupAddAction),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _editGroup(
    BuildContext context,
    BusinessCatalogOptionGroup? existing,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _OptionGroupDialog(
        productId: productId,
        existing: existing,
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).catalogProductOptionGroupSaveSuccess),
        ),
      );
    }
  }

  Future<void> _archiveGroup(BuildContext context, String groupId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.catalogProductOptionGroupArchiveTitle),
        content: Text(l10n.catalogProductOptionGroupArchiveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.catalogCategoryCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.catalogProductOptionGroupArchiveConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final result =
        await getIt<BusinessCatalogProductOptionController>().archiveGroup(groupId);
    if (!context.mounted) {
      return;
    }
    if (result == BusinessCatalogOptionGroupArchiveResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogProductOptionGroupArchiveSuccess)),
      );
    }
  }

  Future<void> _editOption(
    BuildContext context, {
    required BusinessCatalogOptionGroup group,
    BusinessCatalogOption? existing,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _OptionDialog(
        groupId: group.groupId,
        existing: existing,
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).catalogProductOptionSaveSuccess),
        ),
      );
    }
  }

  Future<void> _toggleOption(
    BuildContext context,
    BusinessCatalogOption option,
    bool active,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await getIt<BusinessCatalogProductOptionController>().setOptionActive(
      optionId: option.optionId,
      isActive: active,
    );
    if (!context.mounted) {
      return;
    }
    if (result != BusinessCatalogOptionSaveResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogProductOptionSaveFailed)),
      );
    }
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.l10n,
    required this.group,
    required this.readOnly,
    required this.busy,
    required this.onEdit,
    required this.onArchive,
    required this.onAddOption,
    required this.onEditOption,
    required this.onToggleOption,
  });

  final AppLocalizations l10n;
  final BusinessCatalogOptionGroup group;
  final bool readOnly;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onAddOption;
  final ValueChanged<BusinessCatalogOption> onEditOption;
  final void Function(BusinessCatalogOption option, bool active) onToggleOption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.displayName(l10n),
                  style: textTheme.titleSmall,
                ),
              ),
              if (!readOnly) ...[
                IconButton(
                  tooltip: l10n.catalogCategoryEditAction,
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.catalogProductOptionGroupArchiveConfirm,
                  onPressed: busy ? null : onArchive,
                  icon: const Icon(Icons.archive_outlined),
                ),
              ],
            ],
          ),
          Text(
            '${group.selectionMode.label(l10n)} · '
            '${group.required ? l10n.catalogProductOptionGroupRequired : l10n.catalogProductOptionGroupOptional} · '
            '${l10n.catalogProductOptionSelectionLimits(group.minSelections, group.maxSelections)}',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final option in group.options)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(displayFromLocalized(option.localized, l10n)),
              subtitle: option.isActive
                  ? null
                  : Text(l10n.catalogProductOptionInactiveLabel),
              value: option.isActive,
              secondary: readOnly
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: busy ? null : () => onEditOption(option),
                    ),
              onChanged: readOnly || busy
                  ? null
                  : (v) => onToggleOption(option, v),
            ),
          if (!readOnly)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: busy ? null : onAddOption,
                icon: const Icon(Icons.add),
                label: Text(l10n.catalogProductOptionAddAction),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionGroupDialog extends StatefulWidget {
  const _OptionGroupDialog({required this.productId, this.existing});

  final String productId;
  final BusinessCatalogOptionGroup? existing;

  @override
  State<_OptionGroupDialog> createState() => _OptionGroupDialogState();
}

class _OptionGroupDialogState extends State<_OptionGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameUz;
  late final TextEditingController _nameRu;
  late final TextEditingController _nameEn;
  late final TextEditingController _descUz;
  late final TextEditingController _descRu;
  late final TextEditingController _descEn;
  late BusinessCatalogOptionSelectionMode _mode;
  late bool _required;
  late final TextEditingController _min;
  late final TextEditingController _max;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final loc = widget.existing?.localized ?? const BusinessCatalogLocalizedFields();
    final desc = widget.existing?.description ?? const BusinessCatalogLocalizedFields();
    _nameUz = TextEditingController(text: loc.nameUz);
    _nameRu = TextEditingController(text: loc.nameRu);
    _nameEn = TextEditingController(text: loc.nameEn);
    _descUz = TextEditingController(text: desc.descriptionUz);
    _descRu = TextEditingController(text: desc.descriptionRu);
    _descEn = TextEditingController(text: desc.descriptionEn);
    _mode = widget.existing?.selectionMode ?? BusinessCatalogOptionSelectionMode.single;
    _required = widget.existing?.required ?? false;
    _min = TextEditingController(
      text: '${widget.existing?.minSelections ?? (_required ? 1 : 0)}',
    );
    _max = TextEditingController(
      text: '${widget.existing?.maxSelections ?? 1}',
    );
  }

  @override
  void dispose() {
    _nameUz.dispose();
    _nameRu.dispose();
    _nameEn.dispose();
    _descUz.dispose();
    _descRu.dispose();
    _descEn.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
    }
  }

  BusinessCatalogOptionGroupInput _input() {
    return BusinessCatalogOptionGroupInput(
      localized: BusinessCatalogLocalizedFields(
        nameUz: _nameUz.text,
        nameRu: _nameRu.text,
        nameEn: _nameEn.text,
      ),
      description: BusinessCatalogLocalizedFields(
        descriptionUz: _descUz.text,
        descriptionRu: _descRu.text,
        descriptionEn: _descEn.text,
      ),
      selectionMode: _mode,
      required: _required,
      minSelections: int.tryParse(_min.text.trim()) ?? 0,
      maxSelections: int.tryParse(_max.text.trim()) ?? 0,
      status: widget.existing?.status ?? BusinessCatalogListingStatus.active,
    );
  }

  Future<void> _close() async {
    if (!_dirty) {
      if (mounted) {
        Navigator.of(context).pop(false);
      }
      return;
    }
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.catalogCategoryDiscardConfirmTitle),
        content: Text(l10n.catalogCategoryDiscardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.catalogCategoryDiscardCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.catalogCategoryDiscardConfirmAction),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogProductOptionController>();
    final input = _input();
    final result = widget.existing == null
        ? await controller.createGroup(productId: widget.productId, input: input)
        : await controller.updateGroup(groupId: widget.existing!.groupId, input: input);
    if (!mounted) {
      return;
    }
    switch (result) {
      case BusinessCatalogOptionGroupSaveResult.success:
        Navigator.of(context).pop(true);
      case BusinessCatalogOptionGroupSaveResult.invalidInput:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogProductOptionGroupInvalidInput)),
        );
      case BusinessCatalogOptionGroupSaveResult.invalidProduct:
      case BusinessCatalogOptionGroupSaveResult.notFound:
      case BusinessCatalogOptionGroupSaveResult.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogProductOptionGroupSaveFailed)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = getIt<BusinessCatalogProductOptionController>().saveBusy;
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.catalogProductOptionGroupCreateTitle
            : l10n.catalogProductOptionGroupEditTitle,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatalogLocalizedNameFields(
                  l10n: l10n,
                  nameUz: _nameUz,
                  nameRu: _nameRu,
                  nameEn: _nameEn,
                  descUz: _descUz,
                  descRu: _descRu,
                  descEn: _descEn,
                  onChanged: _markDirty,
                  nameValidator: () {
                    final loc = BusinessCatalogLocalizedFields(
                      nameUz: _nameUz.text,
                      nameRu: _nameRu.text,
                      nameEn: _nameEn.text,
                    );
                    if (!catalogListingHasName(loc)) {
                      return l10n.catalogCategoryNameRequiredHint;
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<BusinessCatalogOptionSelectionMode>(
                  value: _mode,
                  decoration: InputDecoration(
                    labelText: l10n.catalogProductOptionSelectionModeLabel,
                  ),
                  items: BusinessCatalogOptionSelectionMode.values
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.label(l10n)),
                        ),
                      )
                      .toList(),
                  onChanged: busy
                      ? null
                      : (v) {
                          if (v != null) {
                            _markDirty();
                            setState(() => _mode = v);
                          }
                        },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.catalogProductOptionGroupRequired),
                  value: _required,
                  onChanged: busy
                      ? null
                      : (v) {
                          _markDirty();
                          setState(() => _required = v);
                        },
                ),
                TextFormField(
                  controller: _min,
                  decoration: InputDecoration(
                    labelText: l10n.catalogProductOptionMinSelectionsLabel,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _markDirty(),
                ),
                TextFormField(
                  controller: _max,
                  decoration: InputDecoration(
                    labelText: l10n.catalogProductOptionMaxSelectionsLabel,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _markDirty(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: busy ? null : _close, child: Text(l10n.catalogCategoryCancelAction)),
        FilledButton(onPressed: busy ? null : _save, child: Text(l10n.catalogCategorySaveAction)),
      ],
    );
  }
}

class _OptionDialog extends StatefulWidget {
  const _OptionDialog({required this.groupId, this.existing});

  final String groupId;
  final BusinessCatalogOption? existing;

  @override
  State<_OptionDialog> createState() => _OptionDialogState();
}

class _OptionDialogState extends State<_OptionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameUz;
  late final TextEditingController _nameRu;
  late final TextEditingController _nameEn;
  late final TextEditingController _descUz;
  late final TextEditingController _descRu;
  late final TextEditingController _descEn;
  late bool _active;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final loc = widget.existing?.localized ?? const BusinessCatalogLocalizedFields();
    _nameUz = TextEditingController(text: loc.nameUz);
    _nameRu = TextEditingController(text: loc.nameRu);
    _nameEn = TextEditingController(text: loc.nameEn);
    _descUz = TextEditingController();
    _descRu = TextEditingController();
    _descEn = TextEditingController();
    _active = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameUz.dispose();
    _nameRu.dispose();
    _nameEn.dispose();
    _descUz.dispose();
    _descRu.dispose();
    _descEn.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
    }
  }

  Future<void> _close() async {
    if (!_dirty) {
      if (mounted) {
        Navigator.of(context).pop(false);
      }
      return;
    }
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.catalogCategoryDiscardConfirmTitle),
        content: Text(l10n.catalogCategoryDiscardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.catalogCategoryDiscardCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.catalogCategoryDiscardConfirmAction),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final input = BusinessCatalogOptionInput(
      localized: BusinessCatalogLocalizedFields(
        nameUz: _nameUz.text,
        nameRu: _nameRu.text,
        nameEn: _nameEn.text,
      ),
      isActive: _active,
    );
    final controller = getIt<BusinessCatalogProductOptionController>();
    final result = widget.existing == null
        ? await controller.createOption(groupId: widget.groupId, input: input)
        : await controller.updateOption(optionId: widget.existing!.optionId, input: input);
    if (!mounted) {
      return;
    }
    switch (result) {
      case BusinessCatalogOptionSaveResult.success:
        Navigator.of(context).pop(true);
      case BusinessCatalogOptionSaveResult.invalidInput:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogProductOptionInvalidInput)),
        );
      case BusinessCatalogOptionSaveResult.invalidGroup:
      case BusinessCatalogOptionSaveResult.invalidProduct:
      case BusinessCatalogOptionSaveResult.notFound:
      case BusinessCatalogOptionSaveResult.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogProductOptionSaveFailed)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = getIt<BusinessCatalogProductOptionController>().saveBusy;
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.catalogProductOptionCreateTitle
            : l10n.catalogProductOptionEditTitle,
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatalogLocalizedNameFields(
                l10n: l10n,
                nameUz: _nameUz,
                nameRu: _nameRu,
                nameEn: _nameEn,
                descUz: _descUz,
                descRu: _descRu,
                descEn: _descEn,
                includeDescriptions: false,
                onChanged: _markDirty,
                nameValidator: () {
                  final loc = BusinessCatalogLocalizedFields(
                    nameUz: _nameUz.text,
                    nameRu: _nameRu.text,
                    nameEn: _nameEn.text,
                  );
                  if (!catalogListingHasName(loc)) {
                    return l10n.catalogCategoryNameRequiredHint;
                  }
                  return null;
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.catalogProductOptionActiveLabel),
                value: _active,
                onChanged: busy
                    ? null
                    : (v) {
                        _markDirty();
                        setState(() => _active = v);
                      },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: busy ? null : _close, child: Text(l10n.catalogCategoryCancelAction)),
        FilledButton(onPressed: busy ? null : _save, child: Text(l10n.catalogCategorySaveAction)),
      ],
    );
  }
}
