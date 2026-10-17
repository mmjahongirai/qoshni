import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';

class CatalogLocalizedNameFields extends StatelessWidget {
  const CatalogLocalizedNameFields({
    required this.l10n,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.descUz,
    required this.descRu,
    required this.descEn,
    required this.onChanged,
    required this.nameValidator,
    super.key,
  });

  final AppLocalizations l10n;
  final TextEditingController nameUz;
  final TextEditingController nameRu;
  final TextEditingController nameEn;
  final TextEditingController descUz;
  final TextEditingController descRu;
  final TextEditingController descEn;
  final VoidCallback onChanged;
  final String? Function() nameValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.catalogCategoryFormNameHint),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: nameUz,
          decoration: InputDecoration(
            labelText: l10n.catalogCategoryNameUzLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => onChanged(),
          validator: (_) => nameValidator(),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: nameRu,
          decoration: InputDecoration(
            labelText: l10n.catalogCategoryNameRuLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: nameEn,
          decoration: InputDecoration(
            labelText: l10n.catalogCategoryNameEnLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextFormField(
          controller: descUz,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.catalogCategoryDescUzLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: descRu,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.catalogCategoryDescRuLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: descEn,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.catalogCategoryDescEnLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
