/// Distinguishes transient map/device state from persisted saved places.
enum QoshniLocationKind {
  /// One-shot or session device fix (never overwrites saved addresses).
  deviceCurrent,

  /// Explicit map pick (not verified delivery address).
  mapSelected,
}
