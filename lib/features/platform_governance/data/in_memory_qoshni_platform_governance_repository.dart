import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_identity.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_role.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_mutation_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission_definition.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_validation.dart';

class InMemoryQoshniPlatformGovernanceRepository
    implements QoshniPlatformGovernanceRepository {
  InMemoryQoshniPlatformGovernanceRepository({
    List<QoshniPlatformAdminRole>? roleSeed,
    List<QoshniPlatformAdminIdentity>? adminSeed,
  })  : _roles = _validateRoleSeed(roleSeed ?? buildQoshniPlatformAdminRoleDemoSeed()),
        _admins = _validateAdminSeed(
          adminSeed ?? buildQoshniPlatformAdminIdentityDemoSeed(),
          roleSeed ?? buildQoshniPlatformAdminRoleDemoSeed(),
        );

  final List<QoshniPlatformAdminRole> _roles;
  final List<QoshniPlatformAdminIdentity> _admins;

  bool failNextMutation = false;

  static List<QoshniPlatformAdminRole> _validateRoleSeed(
    List<QoshniPlatformAdminRole> seed,
  ) {
    final seenIds = <String>{};
    final seenKeys = <String>{};
    for (final role in seed) {
      if (!seenIds.add(role.roleId)) {
        throw StateError('duplicate role id: ${role.roleId}');
      }
      if (!seenKeys.add(role.roleKey)) {
        throw StateError('duplicate role key: ${role.roleKey}');
      }
      final error = qoshniPlatformAdminRoleValidationError(role);
      if (error != null) {
        throw StateError('invalid role seed ${role.roleId}: $error');
      }
    }
    return seed.map(_cloneRole).toList(growable: true);
  }

  static List<QoshniPlatformAdminIdentity> _validateAdminSeed(
    List<QoshniPlatformAdminIdentity> seed,
    List<QoshniPlatformAdminRole> roles,
  ) {
    final roleIds = roles.map((r) => r.roleId).toSet();
    final seenIds = <String>{};
    final seenRefs = <String>{};
    for (final admin in seed) {
      if (!seenIds.add(admin.adminId)) {
        throw StateError('duplicate admin id: ${admin.adminId}');
      }
      if (!seenRefs.add(admin.syntheticReference)) {
        throw StateError('duplicate admin reference: ${admin.syntheticReference}');
      }
      final error = qoshniPlatformAdminIdentityValidationError(admin);
      if (error != null) {
        throw StateError('invalid admin seed ${admin.adminId}: $error');
      }
      for (final roleId in admin.roleIds) {
        if (!roleIds.contains(roleId)) {
          throw StateError('unknown role on admin ${admin.adminId}: $roleId');
        }
      }
    }
    return seed.map(_cloneAdmin).toList(growable: true);
  }

  static QoshniPlatformAdminRole _cloneRole(QoshniPlatformAdminRole role) {
    return QoshniPlatformAdminRole(
      roleId: role.roleId,
      roleKey: role.roleKey,
      displayNameKey: role.displayNameKey,
      purposeKey: role.purposeKey,
      permissionIds: List.unmodifiable(role.permissionIds),
      status: role.status,
      createdAt: role.createdAt,
      updatedAt: role.updatedAt,
    );
  }

  static QoshniPlatformAdminIdentity _cloneAdmin(
    QoshniPlatformAdminIdentity admin,
  ) {
    return QoshniPlatformAdminIdentity(
      adminId: admin.adminId,
      syntheticReference: admin.syntheticReference,
      displayLabel: admin.displayLabel,
      status: admin.status,
      roleIds: List.unmodifiable(admin.roleIds),
      assignedBusinessReferences:
          List.unmodifiable(admin.assignedBusinessReferences),
      assignedBranchReferences:
          List.unmodifiable(admin.assignedBranchReferences),
      createdAt: admin.createdAt,
      updatedAt: admin.updatedAt,
    );
  }

  @override
  List<QoshniPlatformPermissionDefinition> permissionCatalog() {
    return buildQoshniPlatformPermissionCatalog();
  }

  @override
  List<QoshniPlatformAdminIdentity> listAdmins() {
    return List.unmodifiable(_admins.map(_cloneAdmin));
  }

  @override
  QoshniPlatformAdminIdentity? findAdmin(String adminId) {
    for (final admin in _admins) {
      if (admin.adminId == adminId) {
        return _cloneAdmin(admin);
      }
    }
    return null;
  }

  @override
  List<QoshniPlatformAdminRole> listRoles() {
    return List.unmodifiable(_roles.map(_cloneRole));
  }

  @override
  QoshniPlatformAdminRole? findRole(String roleId) {
    for (final role in _roles) {
      if (role.roleId == roleId) {
        return _cloneRole(role);
      }
    }
    return null;
  }

  @override
  QoshniPlatformGovernanceMutationResult assignRoleToAdmin({
    required String adminId,
    required String roleId,
    required DateTime updatedAtUtc,
  }) {
    if (adminId.trim().isEmpty || roleId.trim().isEmpty) {
      return QoshniPlatformGovernanceMutationResult.invalidInput;
    }
    if (findRole(roleId) == null) {
      return QoshniPlatformGovernanceMutationResult.invalidRoleReference;
    }
    final index = _admins.indexWhere((a) => a.adminId == adminId);
    if (index < 0) {
      return QoshniPlatformGovernanceMutationResult.notFound;
    }
    final admin = _admins[index];
    if (admin.roleIds.contains(roleId)) {
      return QoshniPlatformGovernanceMutationResult.duplicateAssignment;
    }
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformGovernanceMutationResult.failure;
    }
    final updated = admin.copyWith(
      roleIds: [...admin.roleIds, roleId],
      updatedAt: updatedAtUtc.toUtc(),
    );
    if (qoshniPlatformAdminIdentityValidationError(updated) != null) {
      return QoshniPlatformGovernanceMutationResult.invalidInput;
    }
    _admins[index] = updated;
    return QoshniPlatformGovernanceMutationResult.success;
  }

  @override
  QoshniPlatformGovernanceMutationResult setAdminStatus({
    required String adminId,
    required QoshniPlatformAdminStatus status,
    required DateTime updatedAtUtc,
  }) {
    if (adminId.trim().isEmpty) {
      return QoshniPlatformGovernanceMutationResult.invalidInput;
    }
    final index = _admins.indexWhere((a) => a.adminId == adminId);
    if (index < 0) {
      return QoshniPlatformGovernanceMutationResult.notFound;
    }
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformGovernanceMutationResult.failure;
    }
    _admins[index] = _admins[index].copyWith(
      status: status,
      updatedAt: updatedAtUtc.toUtc(),
    );
    return QoshniPlatformGovernanceMutationResult.success;
  }
}
