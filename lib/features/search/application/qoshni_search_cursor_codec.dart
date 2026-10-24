import 'dart:convert';

import 'package:qoshni/features/search/domain/qoshni_search_ranked_candidate.dart';

const int kQoshniSearchCursorVersion = 1;

class QoshniSearchCursorPayload {
  const QoshniSearchCursorPayload({
    required this.version,
    required this.queryFingerprint,
    required this.catalogGeneration,
    required this.afterTotalScore,
    required this.afterRelevanceScore,
    required this.afterStableId,
  });

  final int version;
  final String queryFingerprint;
  final int catalogGeneration;
  final double afterTotalScore;
  final double afterRelevanceScore;
  final String afterStableId;
}

String? qoshniSearchEncodeCursor(QoshniSearchCursorPayload payload) {
  final map = {
    'v': payload.version,
    'q': payload.queryFingerprint,
    'g': payload.catalogGeneration,
    't': payload.afterTotalScore,
    'r': payload.afterRelevanceScore,
    's': payload.afterStableId,
  };
  return base64Url.encode(utf8.encode(jsonEncode(map)));
}

QoshniSearchCursorPayload? qoshniSearchDecodeCursor(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  try {
    final decoded = utf8.decode(base64Url.decode(raw));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    final version = map['v'];
    if (version is! int || version != kQoshniSearchCursorVersion) {
      return null;
    }
    final queryFingerprint = map['q'];
    final generation = map['g'];
    final total = map['t'];
    final relevance = map['r'];
    final stableId = map['s'];
    if (queryFingerprint is! String ||
        generation is! int ||
        total is! num ||
        relevance is! num ||
        stableId is! String) {
      return null;
    }
    return QoshniSearchCursorPayload(
      version: version,
      queryFingerprint: queryFingerprint,
      catalogGeneration: generation,
      afterTotalScore: total.toDouble(),
      afterRelevanceScore: relevance.toDouble(),
      afterStableId: stableId,
    );
  } on FormatException {
    return null;
  } on ArgumentError {
    return null;
  }
}

bool qoshniSearchCursorIsAfterCandidate({
  required QoshniSearchCursorPayload cursor,
  required QoshniSearchRankedCandidate candidate,
}) {
  final t = candidate.totalScore.compareTo(cursor.afterTotalScore);
  if (t < 0) {
    return true;
  }
  if (t > 0) {
    return false;
  }
  final r = candidate.relevanceScore.compareTo(cursor.afterRelevanceScore);
  if (r < 0) {
    return true;
  }
  if (r > 0) {
    return false;
  }
  return candidate.record.stableId.compareTo(cursor.afterStableId) > 0;
}
