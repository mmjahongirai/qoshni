/// Explainable ranking factors (deterministic demo engine — not ML).
enum QoshniSearchRankReason {
  textMatch,
  categoryImpliedMatch,
  titlePrefixMatch,
  availabilityOpen,
  distanceNear,
  ratingHigh,
  trustScoreHigh,
  sponsoredBoostCapped,
}
