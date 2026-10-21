enum BusinessReviewStatus {
  draft,
  pendingModeration,
  published,
  rejected,
  hidden,
}

bool businessReviewStatusCountsTowardRatingSummary(
  BusinessReviewStatus status,
) {
  return status == BusinessReviewStatus.published;
}

bool businessReviewStatusTerminalForModeration(BusinessReviewStatus status) {
  return status == BusinessReviewStatus.rejected ||
      status == BusinessReviewStatus.hidden;
}
