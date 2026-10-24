import 'package:qoshni/features/search/domain/qoshni_search_request.dart';

class QoshniSearchRequestValidation {
  const QoshniSearchRequestValidation.valid()
      : isValid = true,
        pageSize = kQoshniSearchDefaultPageSize;

  const QoshniSearchRequestValidation.invalid()
      : isValid = false,
        pageSize = kQoshniSearchDefaultPageSize;

  const QoshniSearchRequestValidation._({
    required this.isValid,
    required this.pageSize,
  });

  final bool isValid;
  final int pageSize;
}

QoshniSearchRequestValidation qoshniSearchValidateRequest(
  QoshniSearchRequest request,
) {
  final size = request.pageSize;
  if (size < kQoshniSearchMinPageSize || size > kQoshniSearchMaxPageSize) {
    return const QoshniSearchRequestValidation.invalid();
  }
  if (request.filters.maxDistanceMeters != null &&
      request.filters.maxDistanceMeters! < 0) {
    return const QoshniSearchRequestValidation.invalid();
  }
  return QoshniSearchRequestValidation._(isValid: true, pageSize: size);
}
