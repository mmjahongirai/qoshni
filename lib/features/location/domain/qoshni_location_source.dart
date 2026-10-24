/// How a coordinate fix was produced (not an address or saved place).
enum QoshniLocationSource {
  /// Satellite / high-accuracy device sensor when distinguishable.
  gps,

  /// Network- or cell-derived device fix when distinguishable.
  network,

  /// Platform fused fix when the OS does not expose GPS vs network.
  fused,

  /// User picked a point on the map (not device GPS).
  mapSelection,

  /// Source could not be determined.
  unknown,
}
