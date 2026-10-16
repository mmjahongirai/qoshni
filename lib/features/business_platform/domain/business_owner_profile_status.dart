/// Lifecycle of a business-level profile (not branch or verification server state).
enum BusinessOwnerProfileLifecycleStatus {
  /// Editable preview only — not verified or published.
  previewDraft,
}

/// Where the current session profile values originated.
enum BusinessOwnerProfileDataSource {
  /// Initial demo seed; user has not saved edits yet.
  demoSeed,

  /// User saved edits in this app session (still not a server record).
  userSession,
}

/// Demo-only visibility toggle (no backend contract yet).
enum BusinessOwnerProfileVisibility {
  hiddenPreview,
  visibleInPreview,
}
