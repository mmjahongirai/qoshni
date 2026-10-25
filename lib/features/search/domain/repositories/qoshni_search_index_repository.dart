import 'package:qoshni/features/search/domain/qoshni_search_index_record.dart';

abstract class QoshniSearchIndexRepository {
  int get catalogGeneration;

  List<QoshniSearchIndexRecord> listRecords();

  QoshniSearchIndexRecord? findByStableId(String stableId);
}
