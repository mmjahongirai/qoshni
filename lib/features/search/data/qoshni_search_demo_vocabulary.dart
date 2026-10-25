import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/application/qoshni_search_text_normalizer.dart';
import 'package:qoshni/features/search/domain/repositories/qoshni_search_vocabulary_repository.dart';

const String kQoshniSearchSynonymGroupPharmacy = 'synonym_pharmacy';
const String kQoshniSearchSynonymGroupRestaurant = 'synonym_restaurant';
const String kQoshniSearchSynonymGroupGroceries = 'synonym_groceries';

List<QoshniSearchVocabularyTerm> buildQoshniSearchDemoVocabulary() {
  QoshniSearchVocabularyTerm term({
    required String id,
    required List<String> forms,
    ServiceCategoryId? categoryId,
    String? synonymGroupId,
  }) {
    final normalized =
        forms.map(qoshniSearchNormalizeQueryText).toSet().toList(growable: false);
    return QoshniSearchVocabularyTerm(
      termId: id,
      displayForms: forms,
      normalizedForms: normalized,
      categoryId: categoryId,
      synonymGroupId: synonymGroupId,
    );
  }

  return [
    term(
      id: 'pharmacy_latin_uz',
      forms: ['dorixona', 'dori xona', 'apteka'],
      categoryId: ServiceCategoryId.pharmacy,
      synonymGroupId: kQoshniSearchSynonymGroupPharmacy,
    ),
    term(
      id: 'pharmacy_cyrillic_uz',
      forms: ['дорихона', 'аптека'],
      categoryId: ServiceCategoryId.pharmacy,
      synonymGroupId: kQoshniSearchSynonymGroupPharmacy,
    ),
    term(
      id: 'pharmacy_ru',
      forms: ['аптека', 'фармация'],
      categoryId: ServiceCategoryId.pharmacy,
      synonymGroupId: kQoshniSearchSynonymGroupPharmacy,
    ),
    term(
      id: 'restaurant_uz',
      forms: ['restoran', 'ресторан', 'oshxona', 'ошхона'],
      categoryId: ServiceCategoryId.restaurants,
      synonymGroupId: kQoshniSearchSynonymGroupRestaurant,
    ),
    term(
      id: 'groceries_uz',
      forms: ['bozor', 'магазин', 'groceries', 'supermarket'],
      categoryId: ServiceCategoryId.groceries,
      synonymGroupId: kQoshniSearchSynonymGroupGroceries,
    ),
    term(
      id: 'masters_uz',
      forms: ['usta', 'ustalar', 'master', 'handyman'],
      categoryId: ServiceCategoryId.masters,
    ),
    term(
      id: 'rent_uz',
      forms: ['ijara', 'rent', 'arenda', 'аренда'],
      categoryId: ServiceCategoryId.rent,
    ),
    term(
      id: 'shops_uz',
      forms: ['do\'kon', "do'kon", 'dokon', 'shop', 'магазин'],
      categoryId: ServiceCategoryId.shops,
    ),
  ];
}

Map<String, List<String>> buildQoshniSearchSynonymGroupIndex(
  List<QoshniSearchVocabularyTerm> terms,
) {
  final groups = <String, Set<String>>{};
  for (final term in terms) {
    final groupId = term.synonymGroupId;
    if (groupId == null) {
      continue;
    }
    groups.putIfAbsent(groupId, () => {}).addAll(term.normalizedForms);
  }
  return {
    for (final entry in groups.entries) entry.key: entry.value.toList()..sort(),
  };
}
