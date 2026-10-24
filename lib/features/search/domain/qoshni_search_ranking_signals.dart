/// Optional ranking inputs — null means unknown (never treated as zero-truth).
class QoshniSearchRankingSignals {
  const QoshniSearchRankingSignals({
    this.averageRating,
    this.demoTrustScore,
    this.distanceMeters,
    this.isOpen,
    this.isSponsored = false,
    this.latitude,
    this.longitude,
  });

  final double? averageRating;
  final double? demoTrustScore;
  final int? distanceMeters;
  final bool? isOpen;
  final bool isSponsored;
  final double? latitude;
  final double? longitude;
}
