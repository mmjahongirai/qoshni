import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
enum BusinessCatalogCategoryValidationIssue {
  missingName,
  duplicateName,
  invalidParent,
  selfParent,
}

BusinessCatalogCategoryValidationIssue? validateCategoryInput({
  required BusinessCatalogCategoryInput input,
  required List<BusinessCatalogCategory> existing,
  String? editingCategoryId,
}) {
  final localized = input.localized.trimmed();
  if (!localized.hasAnyName) {
    return BusinessCatalogCategoryValidationIssue.missingName;
  }

  final parentId = input.parentCategoryId?.trim();
  if (parentId != null && parentId.isNotEmpty) {
    if (editingCategoryId != null && parentId == editingCategoryId) {
      return BusinessCatalogCategoryValidationIssue.selfParent;
    }
    final parent = existing.where((c) => c.categoryId == parentId).firstOrNull;
    if (parent == null) {
      return BusinessCatalogCategoryValidationIssue.invalidParent;
    }
    if (editingCategoryId != null &&
        _createsCycle(
          existing: existing,
          categoryId: editingCategoryId,
          newParentId: parentId,
        )) {
      return BusinessCatalogCategoryValidationIssue.invalidParent;
    }
  }

  final newNames = localized.nonEmptyNormalizedNames.toSet();
  for (final category in existing) {
    if (category.categoryId == editingCategoryId) {
      continue;
    }
    for (final name in category.localized.nonEmptyNormalizedNames) {
      if (newNames.contains(name)) {
        return BusinessCatalogCategoryValidationIssue.duplicateName;
      }
    }
  }

  return null;
}

bool _createsCycle({
  required List<BusinessCatalogCategory> existing,
  required String categoryId,
  required String newParentId,
}) {
  var current = newParentId;
  final visited = <String>{categoryId};
  while (current.isNotEmpty) {
    if (visited.contains(current)) {
      return true;
    }
    visited.add(current);
    if (current == categoryId) {
      return true;
    }
    final next = existing
        .where((c) => c.categoryId == current)
        .firstOrNull
        ?.parentCategoryId
        ?.trim();
    if (next == null || next.isEmpty) {
      return false;
    }
    current = next;
  }
  return false;
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
