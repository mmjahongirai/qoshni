/// Optional navigation intent for the full-screen map route.
class QoshniMapRouteIntent {
  const QoshniMapRouteIntent({this.requestDeviceLocationOnOpen = false});

  /// When true, the map screen starts the explicit device-location flow on open
  /// (for example after the user taps Open map on home).
  final bool requestDeviceLocationOnOpen;
}
