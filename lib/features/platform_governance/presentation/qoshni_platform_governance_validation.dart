import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_identity.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_role.dart';

const int kQoshniPlatformAdminIdMaxLength = 80;
const int kQoshniPlatformSyntheticReferenceMaxLength = 80;
const int kQoshniPlatformDisplayLabelMaxLength = 120;
const int kQoshniPlatformRoleIdMaxLength = 80;
const int kQoshniPlatformDemoReferenceSegmentMaxLength = 64;

String? qoshniPlatformAdminIdentityValidationError(
  QoshniPlatformAdminIdentity admin,
) {
  if (admin.adminId.trim().isEmpty ||
      admin.adminId.length > kQoshniPlatformAdminIdMaxLength) {
    return 'invalid_admin_id';
  }
  if (admin.syntheticReference.trim().isEmpty ||
      admin.syntheticReference.length > kQoshniPlatformSyntheticReferenceMaxLength) {
    return 'invalid_synthetic_reference';
  }
  if (admin.displayLabel.trim().isEmpty ||
      admin.displayLabel.length > kQoshniPlatformDisplayLabelMaxLength) {
    return 'invalid_display_label';
  }
  if (admin.roleIds.isEmpty) {
    return 'missing_role_assignment';
  }
  final seenRoles = <String>{};
  for (final roleId in admin.roleIds) {
    if (roleId.trim().isEmpty || roleId.length > kQoshniPlatformRoleIdMaxLength) {
      return 'invalid_role_reference';
    }
    if (!seenRoles.add(roleId)) {
      return 'duplicate_role_reference';
    }
  }
  for (final ref in admin.assignedBusinessReferences) {
    if (_demoScopeReferenceError(ref) != null) {
      return 'invalid_business_assignment';
    }
  }
  for (final ref in admin.assignedBranchReferences) {
    if (_demoScopeReferenceError(ref) != null) {
      return 'invalid_branch_assignment';
    }
  }
  return null;
}

String? qoshniPlatformAdminRoleValidationError(QoshniPlatformAdminRole role) {
  if (role.roleId.trim().isEmpty ||
      role.roleId.length > kQoshniPlatformRoleIdMaxLength) {
    return 'invalid_role_id';
  }
  if (role.roleKey.trim().isEmpty) {
    return 'invalid_role_key';
  }
  if (role.permissionIds.isEmpty) {
    return 'missing_permissions';
  }
  final seen = <String>{};
  for (final permissionId in role.permissionIds) {
    if (permissionId.trim().isEmpty) {
      return 'invalid_permission_id';
    }
    if (!seen.add(permissionId)) {
      return 'duplicate_permission_id';
    }
  }
  return null;
}

String? _demoScopeReferenceError(String reference) {
  final ref = reference.trim();
  if (ref.isEmpty || ref.length > kQoshniPlatformDemoReferenceSegmentMaxLength) {
    return 'invalid';
  }
  if (ref.contains(' ') || ref.contains('@')) {
    return 'invalid';
  }
  if (!ref.startsWith('demo-')) {
    return 'invalid';
  }
  return null;
}
