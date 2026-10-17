enum BusinessStaffDataSource {
  demoSeed,
  userSession,
}

/// Preview-only lifecycle — no real invites or server verification.
enum BusinessStaffMemberStatus {
  activePreview,
  invitePendingPreview,
  removedPreview,
}
