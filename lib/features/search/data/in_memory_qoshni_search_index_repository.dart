import 'package:qoshni/features/search/domain/qoshni_search_index_record.dart';
import 'package:qoshni/features/search/domain/repositories/qoshni_search_index_repository.dart';

class InMemoryQoshniSearchIndexRepository implements QoshniSearchIndexRepository {
  InMemoryQoshniSearchIndexRepository({
    List<QoshniSearchIndexRecord>? seed,
    int catalogGeneration = 1,
  })  : _records = List.of(seed ?? const []),
        _catalogGeneration = catalogGeneration;

  final List<QoshniSearchIndexRecord> _records;
  int _catalogGeneration;

  void replaceIndex(List<QoshniSearchIndexRecord> records) {
    _records
      ..clear()
      ..addAll(records);
    _catalogGeneration++;
  }

  @override
  int get catalogGeneration => _catalogGeneration;

  @override
  List<QoshniSearchIndexRecord> listRecords() => List.unmodifiable(_records);

  @override
  QoshniSearchIndexRecord? findByStableId(String stableId) {
    for (final record in _records) {
      if (record.stableId == stableId) {
        return record;
      }
    }
    return null;
  }
}
