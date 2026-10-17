import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_category_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogCategoryEditorPage extends StatefulWidget {
  const BusinessCatalogCategoryEditorPage({this.categoryId, super.key});

  final String? categoryId;

  bool get isEdit => categoryId != null && categoryId!.trim().isNotEmpty;

  @override
  State<BusinessCatalogCategoryEditorPage> createState() =>
      _BusinessCatalogCategoryEditorPageState();
}

class _BusinessCatalogCategoryEditorPageState
    extends State<BusinessCatalogCategoryEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameUz;
  late final TextEditingController _nameRu;
  late final TextEditingController _nameEn;
  late final TextEditingController _descUz;
  late final TextEditingController _descRu;
  late final TextEditingController _descEn;
  late BusinessCatalogCategoryStatus _status;
  String? _parentCategoryId;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final controller = getIt<BusinessCatalogCategoryController>();
    BusinessCatalogCategory? existing;
    if (widget.isEdit) {
      existing = controller.categoryById(widget.categoryId!.trim());
    }
    final loc = existing?.localized ?? const BusinessCatalogLocalizedFields();
    _nameUz = TextEditingController(text: loc.nameUz);
    _nameRu = TextEditingController(text: loc.nameRu);
    _nameEn = TextEditingController(text: loc.nameEn);
    _descUz = TextEditingController(text: loc.descriptionUz);
    _descRu = TextEditingController(text: loc.descriptionRu);
    _descEn = TextEditingController(text: loc.descriptionEn);
    _status = existing?.status ?? BusinessCatalogCategoryStatus.draft;
    _parentCategoryId = existing?.parentCategoryId;
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

  BusinessCatalogCategoryInput _buildInput() {
    return BusinessCatalogCategoryInput(
      localized: BusinessCatalogLocalizedFields(
        nameUz: _nameUz.text,
        nameRu: _nameRu.text,
        nameEn: _nameEn.text,
        descriptionUz: _descUz.text,
        descriptionRu: _descRu.text,
        descriptionEn: _descEn.text,
      ),
      status: _status,
      parentCategoryId: _parentCategoryId,
    );
  }

  Future<void> _onCancel() async {
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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogCategoryController>();
    final input = _buildInput();
    final BusinessCatalogCategorySaveResult result;
    if (widget.isEdit) {
      result = await controller.updateCategory(widget.categoryId!.trim(), input);
    } else {
      result = await controller.createCategory(input);
    }

    if (!mounted) {
      return;
    }

    switch (result) {
      case BusinessCatalogCategorySaveResult.success:
        getIt<BusinessCatalogController>().refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogCategorySaveSuccess)),
        );
        context.pop();
      case BusinessCatalogCategorySaveResult.duplicateName:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogCategoryDuplicateNameError)),
        );
      case BusinessCatalogCategorySaveResult.invalidParent:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogCategoryInvalidParentError)),
        );
      case BusinessCatalogCategorySaveResult.notFound:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogCategoryNotFoundBody)),
        );
      case BusinessCatalogCategorySaveResult.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogCategorySaveFailed)),
        );
    }
  }

  String? _validateAtLeastOneName() {
    final loc = BusinessCatalogLocalizedFields(
      nameUz: _nameUz.text,
      nameRu: _nameRu.text,
      nameEn: _nameEn.text,
    );
    if (!loc.trimmed().hasAnyName) {
      return AppLocalizations.of(context).catalogCategoryNameRequiredHint;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryController = getIt<BusinessCatalogCategoryController>();

    if (widget.isEdit &&
        categoryController.categoryById(widget.categoryId!.trim()) == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.catalogCategoryEditTitle),
        ),
        body: SafeArea(
          child: Center(
            child: AppSurfaceCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.catalogCategoryNotFoundTitle),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () =>
                        context.go(RoutePaths.businessCatalogCategories),
                    child: Text(l10n.catalogCategoryBackToListAction),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _onCancel();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _onCancel),
          title: Text(
            widget.isEdit
                ? l10n.catalogCategoryEditTitle
                : l10n.catalogCategoryCreateTitle,
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: categoryController,
            builder: (context, _) {
              final busy = categoryController.saveBusy;
              final parentOptions = categoryController.categories
                  .where(
                    (c) =>
                        !widget.isEdit || c.categoryId != widget.categoryId,
                  )
                  .toList(growable: false);

              return ResponsiveLayout(
                phone: _EditorBody(
                  maxWidth: 520,
                  l10n: l10n,
                  formKey: _formKey,
                  busy: busy,
                  nameUz: _nameUz,
                  nameRu: _nameRu,
                  nameEn: _nameEn,
                  descUz: _descUz,
                  descRu: _descRu,
                  descEn: _descEn,
                  status: _status,
                  parentCategoryId: _parentCategoryId,
                  parentOptions: parentOptions,
                  onMarkDirty: _markDirty,
                  onStatusChanged: (v) {
                    _markDirty();
                    setState(() => _status = v);
                  },
                  onParentChanged: (v) {
                    _markDirty();
                    setState(() => _parentCategoryId = v);
                  },
                  validateNames: _validateAtLeastOneName,
                  onSave: busy ? null : _onSave,
                  onCancel: busy ? null : _onCancel,
                ),
                tablet: _EditorBody(
                  maxWidth: 760,
                  l10n: l10n,
                  formKey: _formKey,
                  busy: busy,
                  nameUz: _nameUz,
                  nameRu: _nameRu,
                  nameEn: _nameEn,
                  descUz: _descUz,
                  descRu: _descRu,
                  descEn: _descEn,
                  status: _status,
                  parentCategoryId: _parentCategoryId,
                  parentOptions: parentOptions,
                  onMarkDirty: _markDirty,
                  onStatusChanged: (v) {
                    _markDirty();
                    setState(() => _status = v);
                  },
                  onParentChanged: (v) {
                    _markDirty();
                    setState(() => _parentCategoryId = v);
                  },
                  validateNames: _validateAtLeastOneName,
                  onSave: busy ? null : _onSave,
                  onCancel: busy ? null : _onCancel,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.maxWidth,
    required this.l10n,
    required this.formKey,
    required this.busy,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.descUz,
    required this.descRu,
    required this.descEn,
    required this.status,
    required this.parentCategoryId,
    required this.parentOptions,
    required this.onMarkDirty,
    required this.onStatusChanged,
    required this.onParentChanged,
    required this.validateNames,
    required this.onSave,
    required this.onCancel,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final bool busy;
  final TextEditingController nameUz;
  final TextEditingController nameRu;
  final TextEditingController nameEn;
  final TextEditingController descUz;
  final TextEditingController descRu;
  final TextEditingController descEn;
  final BusinessCatalogCategoryStatus status;
  final String? parentCategoryId;
  final List<BusinessCatalogCategory> parentOptions;
  final VoidCallback onMarkDirty;
  final ValueChanged<BusinessCatalogCategoryStatus> onStatusChanged;
  final ValueChanged<String?> onParentChanged;
  final String? Function() validateNames;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

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
                Text(
                  l10n.catalogCategoryFormNameHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: nameUz,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryNameUzLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => onMarkDirty(),
                  validator: (_) => validateNames(),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: nameRu,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryNameRuLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => onMarkDirty(),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: nameEn,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryNameEnLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => onMarkDirty(),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: descUz,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryDescUzLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => onMarkDirty(),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: descRu,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryDescRuLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => onMarkDirty(),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: descEn,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryDescEnLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => onMarkDirty(),
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<BusinessCatalogCategoryStatus>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryStatusLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: BusinessCatalogCategoryStatus.values
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
                            onStatusChanged(v);
                          }
                        },
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String?>(
                  value: parentCategoryId,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryParentFieldLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.catalogCategoryNoParent),
                    ),
                    ...parentOptions.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.categoryId,
                        child: Text(c.displayName(l10n)),
                      ),
                    ),
                  ],
                  onChanged: busy ? null : onParentChanged,
                ),
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
