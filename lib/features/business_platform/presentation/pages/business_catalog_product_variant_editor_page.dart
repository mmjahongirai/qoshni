import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_variant.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_variant_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_variant_controller.dart';

class BusinessCatalogProductVariantEditorPage extends StatefulWidget {
  const BusinessCatalogProductVariantEditorPage({
    required this.productId,
    this.variantId,
    super.key,
  });

  final String? productId;
  final String? variantId;

  bool get isEdit => variantId != null && variantId!.trim().isNotEmpty;

  @override
  State<BusinessCatalogProductVariantEditorPage> createState() =>
      _BusinessCatalogProductVariantEditorPageState();
}

class _BusinessCatalogProductVariantEditorPageState
    extends State<BusinessCatalogProductVariantEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _label;
  late final TextEditingController _sku;
  late BusinessCatalogListingStatus _status;

  @override
  void initState() {
    super.initState();
    final existing = widget.isEdit
        ? getIt<BusinessCatalogProductVariantController>()
            .variantById(widget.variantId!.trim())
        : null;
    _label = TextEditingController(text: existing?.label ?? '');
    _sku = TextEditingController(text: existing?.sku ?? '');
    _status = existing?.status ?? BusinessCatalogListingStatus.active;
  }

  @override
  void dispose() {
    _label.dispose();
    _sku.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogProductVariantController>();
    final input = BusinessCatalogProductVariantInput(
      label: _label.text,
      sku: _sku.text,
      status: _status,
    );
    final result = widget.isEdit
        ? await controller.updateVariant(
            variantId: widget.variantId!.trim(),
            input: input,
          )
        : await controller.createVariant(
            productId: widget.productId!.trim(),
            input: input,
          );
    if (!mounted) {
      return;
    }
    switch (result) {
      case BusinessCatalogProductVariantSaveResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogVariantSaveSuccess)),
        );
        context.pop();
      case BusinessCatalogProductVariantSaveResult.duplicateSku:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogVariantDuplicateSku)),
        );
      case BusinessCatalogProductVariantSaveResult.invalidProduct:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogProductNotFoundTitle)),
        );
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catalogVariantSaveFailed)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit
              ? l10n.catalogVariantEditTitle
              : l10n.catalogVariantCreateTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: responsivePagePadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppMessageBanner(
                  message: l10n.catalogPreviewNotice,
                  icon: Icons.info_outline,
                  tone: AppMessageTone.info,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _label,
                  decoration: InputDecoration(
                    labelText: l10n.catalogVariantLabelField,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.catalogVariantLabelRequired : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _sku,
                  decoration: InputDecoration(
                    labelText: l10n.catalogVariantSkuField,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.catalogVariantSkuRequired : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<BusinessCatalogListingStatus>(
                  value: _status,
                  items: BusinessCatalogListingStatus.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label(l10n)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _status = v);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _save,
                  child: Text(l10n.catalogCategorySaveAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
