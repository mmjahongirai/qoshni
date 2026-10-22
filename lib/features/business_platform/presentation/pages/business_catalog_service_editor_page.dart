import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_service.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_service_controller.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_listing_attributes_section.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_localized_name_fields.dart';

class BusinessCatalogServiceEditorPage extends StatefulWidget {
  const BusinessCatalogServiceEditorPage({this.serviceId, super.key});

  final String? serviceId;

  bool get isEdit => serviceId != null && serviceId!.trim().isNotEmpty;

  @override
  State<BusinessCatalogServiceEditorPage> createState() =>
      _BusinessCatalogServiceEditorPageState();
}

class _BusinessCatalogServiceEditorPageState
    extends State<BusinessCatalogServiceEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameUz;
  late final TextEditingController _nameRu;
  late final TextEditingController _nameEn;
  late final TextEditingController _descUz;
  late final TextEditingController _descRu;
  late final TextEditingController _descEn;
  late final TextEditingController _duration;
  late String? _categoryId;
  late BusinessCatalogListingStatus _status;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.isEdit
        ? getIt<BusinessCatalogServiceController>()
            .serviceById(widget.serviceId!.trim())
        : null;
    final loc = existing?.localized ?? const BusinessCatalogLocalizedFields();
    _nameUz = TextEditingController(text: loc.nameUz);
    _nameRu = TextEditingController(text: loc.nameRu);
    _nameEn = TextEditingController(text: loc.nameEn);
    _descUz = TextEditingController(text: loc.descriptionUz);
    _descRu = TextEditingController(text: loc.descriptionRu);
    _descEn = TextEditingController(text: loc.descriptionEn);
    _duration = TextEditingController(
      text: existing?.durationMinutes?.toString() ?? '',
    );
    _categoryId = existing?.categoryId;
    _status = existing?.status ?? BusinessCatalogListingStatus.draft;
  }

  @override
  void dispose() {
    _nameUz.dispose();
    _nameRu.dispose();
    _nameEn.dispose();
    _descUz.dispose();
    _descRu.dispose();
    _descEn.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
    }
  }

  int? _parseDuration() {
    final t = _duration.text.trim();
    if (t.isEmpty) {
      return null;
    }
    return int.tryParse(t);
  }

  BusinessCatalogServiceInput _input() {
    return BusinessCatalogServiceInput(
      categoryId: _categoryId ?? '',
      localized: BusinessCatalogLocalizedFields(
        nameUz: _nameUz.text,
        nameRu: _nameRu.text,
        nameEn: _nameEn.text,
        descriptionUz: _descUz.text,
        descriptionRu: _descRu.text,
        descriptionEn: _descEn.text,
      ),
      status: _status,
      durationMinutes: _parseDuration(),
    );
  }

  Future<void> _cancel() async {
    if (!_dirty) {
      if (mounted) {
        context.pop();
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
      context.pop();
    }
  }

  Future<void> _save() async {
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).catalogListingCategoryRequired),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogServiceController>();
    final result = widget.isEdit
        ? await controller.updateService(widget.serviceId!.trim(), _input())
        : await controller.createService(_input());
    if (!mounted) {
      return;
    }
    switch (result) {
      case BusinessCatalogServiceSaveResult.success:
        getIt<BusinessCatalogController>().refresh();
        setState(() => _dirty = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogServiceSaveSuccess)),
        );
        context.pop();
      case BusinessCatalogServiceSaveResult.invalidDuration:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogServiceInvalidDuration)),
        );
      case BusinessCatalogServiceSaveResult.invalidCategory:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogListingInvalidCategory)),
        );
      case BusinessCatalogServiceSaveResult.notFound:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogServiceSaveFailed)),
        );
      case BusinessCatalogServiceSaveResult.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogServiceSaveFailed)),
        );
    }
  }

  String? _nameValidator() {
    if (!catalogListingHasName(BusinessCatalogLocalizedFields(
      nameUz: _nameUz.text,
      nameRu: _nameRu.text,
      nameEn: _nameEn.text,
    ))) {
      return AppLocalizations.of(context).catalogCategoryNameRequiredHint;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryController = getIt<BusinessCatalogCategoryController>();
    final serviceController = getIt<BusinessCatalogServiceController>();

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await _cancel();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _cancel),
          title: Text(
            widget.isEdit
                ? l10n.catalogServiceEditTitle
                : l10n.catalogServiceCreateTitle,
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: categoryController,
            builder: (context, _) {
              final categories = categoryController.categories;
              final busy = serviceController.saveBusy;
              return ResponsiveLayout(
                phone: _Form(
                  maxWidth: 520,
                  l10n: l10n,
                  formKey: _formKey,
                  busy: busy,
                  categories: categories,
                  categoryId: _categoryId,
                  status: _status,
                  nameUz: _nameUz,
                  nameRu: _nameRu,
                  nameEn: _nameEn,
                  descUz: _descUz,
                  descRu: _descRu,
                  descEn: _descEn,
                  duration: _duration,
                  onMarkDirty: _markDirty,
                  onCategory: (v) {
                    _markDirty();
                    setState(() => _categoryId = v);
                  },
                  onStatus: (v) {
                    _markDirty();
                    setState(() => _status = v);
                  },
                  nameValidator: _nameValidator,
                  onSave: busy ? null : _save,
                  onCancel: busy ? null : _cancel,
                  serviceId: widget.isEdit ? widget.serviceId!.trim() : null,
                ),
                tablet: _Form(
                  maxWidth: 760,
                  l10n: l10n,
                  formKey: _formKey,
                  busy: busy,
                  categories: categories,
                  categoryId: _categoryId,
                  status: _status,
                  nameUz: _nameUz,
                  nameRu: _nameRu,
                  nameEn: _nameEn,
                  descUz: _descUz,
                  descRu: _descRu,
                  descEn: _descEn,
                  duration: _duration,
                  onMarkDirty: _markDirty,
                  onCategory: (v) {
                    _markDirty();
                    setState(() => _categoryId = v);
                  },
                  onStatus: (v) {
                    _markDirty();
                    setState(() => _status = v);
                  },
                  nameValidator: _nameValidator,
                  onSave: busy ? null : _save,
                  onCancel: busy ? null : _cancel,
                  serviceId: widget.isEdit ? widget.serviceId!.trim() : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.maxWidth,
    required this.l10n,
    required this.formKey,
    required this.busy,
    required this.categories,
    required this.categoryId,
    required this.status,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.descUz,
    required this.descRu,
    required this.descEn,
    required this.duration,
    required this.onMarkDirty,
    required this.onCategory,
    required this.onStatus,
    required this.nameValidator,
    required this.onSave,
    required this.onCancel,
    this.serviceId,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final bool busy;
  final List<BusinessCatalogCategory> categories;
  final String? categoryId;
  final BusinessCatalogListingStatus status;
  final TextEditingController nameUz;
  final TextEditingController nameRu;
  final TextEditingController nameEn;
  final TextEditingController descUz;
  final TextEditingController descRu;
  final TextEditingController descEn;
  final TextEditingController duration;
  final VoidCallback onMarkDirty;
  final ValueChanged<String?> onCategory;
  final ValueChanged<BusinessCatalogListingStatus> onStatus;
  final String? Function() nameValidator;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String? serviceId;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppMessageBanner(
                  message: l10n.catalogPreviewNotice,
                  icon: Icons.info_outline,
                  tone: AppMessageTone.info,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String?>(
                  value: categoryId,
                  decoration: InputDecoration(
                    labelText: l10n.catalogListingCategoryField,
                    border: const OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem<String?>(
                          value: c.categoryId,
                          child: Text(c.displayName(l10n)),
                        ),
                      )
                      .toList(),
                  onChanged: busy ? null : onCategory,
                ),
                const SizedBox(height: AppSpacing.md),
                CatalogLocalizedNameFields(
                  l10n: l10n,
                  nameUz: nameUz,
                  nameRu: nameRu,
                  nameEn: nameEn,
                  descUz: descUz,
                  descRu: descRu,
                  descEn: descEn,
                  onChanged: onMarkDirty,
                  nameValidator: nameValidator,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: duration,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.catalogServiceDurationFieldOptional,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => onMarkDirty(),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<BusinessCatalogListingStatus>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryStatusLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: BusinessCatalogListingStatus.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label(l10n)),
                        ),
                      )
                      .toList(),
                  onChanged: busy
                      ? null
                      : (v) {
                          if (v != null) {
                            onStatus(v);
                          }
                        },
                ),
                if (serviceId != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  CatalogListingAttributesSection(
                    listingKind: BusinessCatalogListingKind.service,
                    listingId: serviceId!,
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppMessageBanner(
                    message: l10n.catalogProductOptionsRequiresSaveHint,
                    icon: Icons.tune_outlined,
                    tone: AppMessageTone.info,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                if (busy)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          child: Text(l10n.catalogCategoryCancelAction),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: onSave,
                          child: Text(l10n.catalogCategorySaveAction),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
