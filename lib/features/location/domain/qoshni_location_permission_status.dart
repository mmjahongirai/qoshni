/// App-facing permission state (includes “not yet asked” via session flag).
enum QoshniLocationPermissionStatus {
  notYetRequested,
  granted,
  denied,
  permanentlyDenied,
  limited,
}
