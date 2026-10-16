/// Business-scoped staff roles (demo UI). Not platform reviewer/admin roles.
enum BusinessStaffRole {
  businessOwner,
  businessAdmin,
  branchManager,
  staff,
  readOnly,
}

/// Roles assignable through the staff editor (owner is session-only demo).
const assignableBusinessStaffRoles = <BusinessStaffRole>[
  BusinessStaffRole.businessAdmin,
  BusinessStaffRole.branchManager,
  BusinessStaffRole.staff,
  BusinessStaffRole.readOnly,
];

bool isAssignableBusinessStaffRole(BusinessStaffRole role) {
  return assignableBusinessStaffRoles.contains(role);
}
