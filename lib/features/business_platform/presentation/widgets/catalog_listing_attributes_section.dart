import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_attribute_value_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_listing_attribute_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_attribute_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_validation.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_localized_name_fields.dart';

class CatalogListingAttributesSection extends StatelessWidget {
  const CatalogListingAttributesSection({
    required this.listingKind,
    required this.listingId,
    this.readOnly = false,
    super.key,
  });

  final BusinessCatalogListingKind listingKind;
  final String listingId;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogListingAttributeController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final attributes = controller.attributesForListing(
          listingKind: listingKind,
          listingId: listingId,
        );
        return AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.catalogListingAttributesSectionTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (attributes.isEmpty)
                Text(l10n.catalogListingAttributesEmptyBody)
              else
                ...attributes.map(
                  (attribute) => _AttributeTile(
                    l10n: l10n,
                    attribute: attribute,
                    readOnly: readOnly,
                    busy: controller.saveBusy,
                    onEdit: () => _editAttribute(context, attribute),
                    onDelete: () => _deleteAttribute(context, attribute.attributeId),
                  ),
                ),
              if (!readOnly) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: controller.saveBusy
                      ? null
                      : () => _editAttribute(context, null),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.catalogListingAttributeAddAction),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _editAttribute(
    BuildContext context,
    BusinessCatalogListingAttribute? existing,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _AttributeDialog(
        listingKind: listingKind,
        listingId: listingId,
        existing: existing,
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).catalogListingAttributeSaveSuccess),
        ),
      );
    }
  }

  Future<void> _deleteAttribute(BuildContext context, String attributeId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.catalogListingAttributeDeleteTitle),
        content: Text(l10n.catalogListingAttributeDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.catalogCategoryCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.catalogListingAttributeDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final result =
        await getIt<BusinessCatalogListingAttributeController>().deleteAttribute(
      attributeId,
    );
    if (!context.mounted) {
      return;
    }
    if (result != BusinessCatalogListingAttributeDeleteResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogListingAttributeDeleteFailed)),
      );
    }
  }
}

class _AttributeTile extends StatelessWidget {
  const _AttributeTile({
    required this.l10n,
    required this.attribute,
    required this.readOnly,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final BusinessCatalogListingAttribute attribute;
  final bool readOnly;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${attribute.displayLabel(l10n)} (${attribute.key})',
                  style: textTheme.titleSmall,
                ),
                Text(
                  '${attribute.valueKind.label(l10n)}: ${attribute.canonicalValueString()}',
                  style: textTheme.bodySmall,
                ),
                if (attribute.isDemoSeed)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xs),
                    child: DemoContentBadge(),
                  ),
              ],
            ),
          ),
          if (!readOnly) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: busy ? null : onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: busy ? null : onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

class _AttributeDialog extends StatefulWidget {
  const _AttributeDialog({
    required this.listingKind,
    required this.listingId,
    this.existing,
  });

  final BusinessCatalogListingKind listingKind;
  final String listingId;
  final BusinessCatalogListingAttribute? existing;

  @override
  State<_AttributeDialog> createState() => _AttributeDialogState();
}

class _AttributeDialogState extends State<_AttributeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _key;
  late final TextEditingController _nameUz;
  late final TextEditingController _nameRu;
  late final TextEditingController _nameEn;
  late final TextEditingController _descUz;
  late final TextEditingController _descRu;
  late final TextEditingController _descEn;
  late BusinessCatalogAttributeValueKind _valueKind;
  late final TextEditingController _textValue;
  late final TextEditingController _numberValue;
  late final TextEditingController _choiceValue;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _key = TextEditingController(text: existing?.key ?? '');
    final label = existing?.label ?? const BusinessCatalogLocalizedFields();
    _nameUz = TextEditingController(text: label.nameUz);
    _nameRu = TextEditingController(text: label.nameRu);
    _nameEn = TextEditingController(text: label.nameEn);
    _descUz = TextEditingController();
    _descRu = TextEditingController();
    _descEn = TextEditingController();
    _valueKind = existing?.valueKind ?? BusinessCatalogAttributeValueKind.text;
    _textValue = TextEditingController(text: existing?.textValue ?? '');
    _numberValue = TextEditingController(
      text: existing?.numberValue?.toString() ?? '',
    );
    _choiceValue = TextEditingController(text: existing?.choiceValue ?? '');
  }

  @override
  void dispose() {
    _key.dispose();
    _nameUz.dispose();
    _nameRu.dispose();
    _nameEn.dispose();
    _descUz.dispose();
    _descRu.dispose();
    _descEn.dispose();
    _textValue.dispose();
    _numberValue.dispose();
    _choiceValue.dispose();
    super.dispose();
  }

  BusinessCatalogListingAttributeInput _input() {
    return BusinessCatalogListingAttributeInput(
      key: _key.text,
      label: BusinessCatalogLocalizedFields(
        nameUz: _nameUz.text,
        nameRu: _nameRu.text,
        nameEn: _nameEn.text,
      ),
      valueKind: _valueKind,
      textValue: _textValue.text,
      numberValue: double.tryParse(_numberValue.text.trim()),
      choiceValue: _choiceValue.text,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogListingAttributeController>();
    final input = _input();
    final result = widget.existing == null
        ? await controller.createAttribute(
            listingKind: widget.listingKind,
            listingId: widget.listingId,
            input: input,
          )
        : await controller.updateAttribute(
            attributeId: widget.existing!.attributeId,
            input: input,
          );
    if (!mounted) {
      return;
    }
    switch (result) {
      case BusinessCatalogListingAttributeSaveResult.success:
        Navigator.of(context).pop(true);
      case BusinessCatalogListingAttributeSaveResult.duplicateKey:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogListingAttributeDuplicateKey)),
        );
      case BusinessCatalogListingAttributeSaveResult.invalidInput:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogListingAttributeInvalidInput)),
        );
      case BusinessCatalogListingAttributeSaveResult.invalidListing:
      case BusinessCatalogListingAttributeSaveResult.notFound:
      case BusinessCatalogListingAttributeSaveResult.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogListingAttributeSaveFailed)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = getIt<BusinessCatalogListingAttributeController>().saveBusy;
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.catalogListingAttributeCreateTitle
            : l10n.catalogListingAttributeEditTitle,
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _key,
                  decoration: InputDecoration(
                    labelText: l10n.catalogListingAttributeKeyLabel,
                    helperText: l10n.catalogListingAttributeKeyHint,
                  ),
                  enabled: widget.existing == null && !busy,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) {
                      return l10n.catalogListingAttributeKeyRequired;
                    }
                    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(t)) {
                      return l10n.catalogListingAttributeKeyInvalid;
                    }
                    return null;
                  },
                ),
                CatalogLocalizedNameFields(
                  l10n: l10n,
                  nameUz: _nameUz,
                  nameRu: _nameRu,
                  nameEn: _nameEn,
                  descUz: _descUz,
                  descRu: _descRu,
                  descEn: _descEn,
                  includeDescriptions: false,
                  onChanged: () {},
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
                DropdownButtonFormField<BusinessCatalogAttributeValueKind>(
                  value: _valueKind,
                  decoration: InputDecoration(
                    labelText: l10n.catalogListingAttributeValueKindLabel,
                  ),
                  items: BusinessCatalogAttributeValueKind.values
                      .map(
                        (k) => DropdownMenuItem(
                          value: k,
                          child: Text(k.label(l10n)),
                        ),
                      )
                      .toList(),
                  onChanged: busy
                      ? null
                      : (v) {
                          if (v != null) {
                            setState(() => _valueKind = v);
                          }
                        },
                ),
                if (_valueKind == BusinessCatalogAttributeValueKind.text)
                  TextFormField(
                    controller: _textValue,
                    decoration: InputDecoration(
                      labelText: l10n.catalogListingAttributeTextValueLabel,
                    ),
                  )
                else if (_valueKind == BusinessCatalogAttributeValueKind.number)
                  TextFormField(
                    controller: _numberValue,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.catalogListingAttributeNumberValueLabel,
                    ),
                  )
                else
                  TextFormField(
                    controller: _choiceValue,
                    decoration: InputDecoration(
                      labelText: l10n.catalogListingAttributeChoiceValueLabel,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.catalogCategoryCancelAction),
        ),
        FilledButton(
          onPressed: busy ? null : _save,
          child: Text(l10n.catalogCategorySaveAction),
        ),
      ],
    );
  }
}
