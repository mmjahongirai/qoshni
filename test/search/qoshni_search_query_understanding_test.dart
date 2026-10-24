import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/application/qoshni_search_autocomplete_service.dart';
import 'package:qoshni/features/search/application/qoshni_search_query_processor.dart';
import 'package:qoshni/features/search/application/qoshni_search_text_normalizer.dart';
import 'package:qoshni/features/search/data/in_memory_qoshni_search_vocabulary_repository.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_validation.dart';

void main() {
  late QoshniSearchQueryProcessor processor;
  late QoshniSearchAutocompleteService autocomplete;

  setUp(() {
    final vocabulary = InMemoryQoshniSearchVocabularyRepository();
    processor = QoshniSearchQueryProcessor(vocabulary);
    autocomplete = QoshniSearchAutocompleteService(vocabulary);
  });

  test('empty and whitespace-only input are not searchable', () {
    expect(processor.understand(rawQuery: '').isSearchable, isFalse);
    expect(processor.understand(rawQuery: '   ').isSearchable, isFalse);
    expect(
      processor.parse(rawQuery: '').validationIssue,
      QoshniSearchQueryValidationIssue.empty,
    );
  });

  test('preserves original text while normalizing', () {
    const raw = '  Dorixona   ';
    final understanding = processor.understand(rawQuery: raw);
    expect(understanding.originalText, raw);
    expect(understanding.normalizedText, 'dorixona');
  });

  test('uzbek latin normalization collapses whitespace', () {
    expect(qoshniSearchNormalizeQueryText('  oshxona   restoran'), 'oshxona restoran');
  });

  test('cyrillic pharmacy synonym implies pharmacy category', () {
    final understanding = processor.understand(rawQuery: 'дорихона');
    expect(
      understanding.impliedCategoryIds,
      contains(ServiceCategoryId.pharmacy),
    );
  });

  test('cross-script pharmacy aliases share match terms', () {
    final latin = processor.understand(rawQuery: 'apteka');
    final cyrillic = processor.understand(rawQuery: 'аптека');
    expect(latin.matchTerms, contains('apteka'));
    expect(cyrillic.matchTerms, contains('аптека'));
    expect(
      latin.impliedCategoryIds,
      contains(ServiceCategoryId.pharmacy),
    );
  });

  test('autocomplete is deterministic and prefix based', () {
    final first = autocomplete.suggest(rawQuery: 'apt');
    final second = autocomplete.suggest(rawQuery: 'apt');
    expect(
      first.map((s) => s.displayText).toList(),
      second.map((s) => s.displayText).toList(),
    );
    expect(first, isNotEmpty);
    expect(
      qoshniSearchNormalizeQueryText(first.first.displayText),
      startsWith('apt'),
    );
  });

  test('empty query returns no autocomplete suggestions', () {
    expect(autocomplete.suggest(rawQuery: ''), isEmpty);
    expect(autocomplete.suggest(rawQuery: '   '), isEmpty);
  });

  test('autocomplete respects limit', () {
    final many = autocomplete.suggest(rawQuery: 'a', limit: 2);
    expect(many.length <= 2, isTrue);
  });

  test('typo correction suggests known word without replacing original', () {
    final understanding = processor.understand(rawQuery: 'dorixono');
    expect(understanding.originalText, 'dorixono');
    expect(understanding.spellingCorrection, isNotNull);
    expect(
      understanding.spellingCorrection!.normalizedSuggestedText,
      'dorixona',
    );
  });

  test('excessive input is rejected', () {
    final tooLong = 'a' * (kQoshniSearchQueryMaxLength + 1);
    expect(
      processor.parse(rawQuery: tooLong).validationIssue,
      QoshniSearchQueryValidationIssue.tooLong,
    );
  });

  test('same input produces same understanding match terms', () {
    final a = processor.understand(rawQuery: 'dorixona');
    final b = processor.understand(rawQuery: 'dorixona');
    expect(a.matchTerms, b.matchTerms);
    expect(a.impliedCategoryIds, b.impliedCategoryIds);
  });
}
