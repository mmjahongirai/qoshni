import 'package:qoshni/features/business_platform/domain/business_review.dart';

String? catalogBusinessReviewRatingValidationError(int rating) {
  if (rating < 1 || rating > 5) {
    return 'invalid_rating';
  }
  return null;
}

String? catalogBusinessReviewTextValidationError({
  String? title,
  String? reviewText,
}) {
  final t = title?.trim();
  if (t != null && t.length > 120) {
    return 'title_too_long';
  }
  final body = reviewText?.trim();
  if (body != null && body.length > 2000) {
    return 'text_too_long';
  }
  return null;
}

String? catalogBusinessReviewCreateValidationError(
  BusinessReviewCreateInput input,
) {
  if (catalogBusinessReviewRatingValidationError(input.rating) != null) {
    return 'invalid_rating';
  }
  if (input.targetId.trim().isEmpty) {
    return 'invalid_target';
  }
  if (input.demoReviewerReference.trim().isEmpty) {
    return 'invalid_reviewer';
  }
  if (input.transactionEvidenceReference.trim().isEmpty) {
    return 'invalid_evidence';
  }
  return catalogBusinessReviewTextValidationError(
    title: input.title,
    reviewText: input.reviewText,
  );
}
