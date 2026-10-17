/// Multilingual catalog copy (business-scoped categories, not [ServiceCategoryId]).
class BusinessCatalogLocalizedFields {
  const BusinessCatalogLocalizedFields({
    this.nameUz = '',
    this.nameRu = '',
    this.nameEn = '',
    this.descriptionUz = '',
    this.descriptionRu = '',
    this.descriptionEn = '',
  });

  final String nameUz;
  final String nameRu;
  final String nameEn;
  final String descriptionUz;
  final String descriptionRu;
  final String descriptionEn;

  bool get hasAnyName {
    return nameUz.trim().isNotEmpty ||
        nameRu.trim().isNotEmpty ||
        nameEn.trim().isNotEmpty;
  }

  BusinessCatalogLocalizedFields trimmed() {
    return BusinessCatalogLocalizedFields(
      nameUz: nameUz.trim(),
      nameRu: nameRu.trim(),
      nameEn: nameEn.trim(),
      descriptionUz: descriptionUz.trim(),
      descriptionRu: descriptionRu.trim(),
      descriptionEn: descriptionEn.trim(),
    );
  }

  Iterable<String> get nonEmptyNormalizedNames sync* {
    for (final raw in [nameUz, nameRu, nameEn]) {
      final t = raw.trim();
      if (t.isNotEmpty) {
        yield t.toLowerCase();
      }
    }
  }

  BusinessCatalogLocalizedFields copyWith({
    String? nameUz,
    String? nameRu,
    String? nameEn,
    String? descriptionUz,
    String? descriptionRu,
    String? descriptionEn,
  }) {
    return BusinessCatalogLocalizedFields(
      nameUz: nameUz ?? this.nameUz,
      nameRu: nameRu ?? this.nameRu,
      nameEn: nameEn ?? this.nameEn,
      descriptionUz: descriptionUz ?? this.descriptionUz,
      descriptionRu: descriptionRu ?? this.descriptionRu,
      descriptionEn: descriptionEn ?? this.descriptionEn,
    );
  }
}
