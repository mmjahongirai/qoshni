import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_identity.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_role.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_decision.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_request.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission_scope_requirement.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_role_status.dart';

/// Pure demo authorization evaluator — no I/O. Not production security.
abstract final class QoshniPlatformAuthorizationPolicy {
  static QoshniPlatformAuthorizationDecision evaluate(
    QoshniPlatformAuthorizationRequest request,
  ) {
    final permission = request.permission;
    if (request.actionLabel.trim().isEmpty) {
      return _deny(permission, QoshniPlatformAuthorizationReason.deniedInvalidInput);
    }

    final admin = request.admin;
    if (admin.status == QoshniPlatformAdminStatus.suspended) {
      return _deny(permission, QoshniPlatformAuthorizationReason.deniedAdminSuspended);
    }

    final scopeError = _scopeShapeValidationError(request.resourceScope);
    if (scopeError != null) {
      return _deny(permission, scopeError);
    }

    final enabledRoles = <QoshniPlatformAdminRole>[];
    for (final roleId in admin.roleIds) {
      final role = request.rolesById[roleId];
      if (role == null) {
        continue;
      }
      if (role.status == QoshniPlatformRoleStatus.disabled) {
        continue;
      }
      enabledRoles.add(role);
    }

    if (enabledRoles.isEmpty) {
      return _deny(permission, QoshniPlatformAuthorizationReason.deniedNoEnabledRoles);
    }

    QoshniPlatformAdminRole? grantingRole;
    for (final role in enabledRoles) {
      if (role.permissionIds.contains(permission.permissionId)) {
        grantingRole = role;
        break;
      }
    }

    if (grantingRole == null) {
      return _deny(
        permission,
        QoshniPlatformAuthorizationReason.deniedPermissionNotGranted,
      );
    }

    final scopeRequirement = qoshniPlatformPermissionScopeRequirement(permission);
    final scopeDecision = _evaluateScope(
      requirement: scopeRequirement,
      admin: admin,
      scope: request.resourceScope,
    );
    if (scopeDecision != null) {
      return QoshniPlatformAuthorizationDecision(
        isAllowed: false,
        reason: scopeDecision,
        permission: permission,
        matchedRoleId: grantingRole.roleId,
      );
    }

    return QoshniPlatformAuthorizationDecision(
      isAllowed: true,
      reason: QoshniPlatformAuthorizationReason.allowedExplicitGrant,
      permission: permission,
      matchedRoleId: grantingRole.roleId,
    );
  }

  static QoshniPlatformAuthorizationReason? _scopeShapeValidationError(
    QoshniPlatformResourceScope scope,
  ) {
    switch (scope.kind) {
      case QoshniPlatformResourceScopeKind.platform:
        if (scope.businessReference != null || scope.branchReference != null) {
          return QoshniPlatformAuthorizationReason.deniedInvalidInput;
        }
        return null;
      case QoshniPlatformResourceScopeKind.business:
        final ref = scope.businessReference?.trim() ?? '';
        if (ref.isEmpty) {
          return QoshniPlatformAuthorizationReason
              .deniedScopeBusinessReferenceRequired;
        }
        if (scope.branchReference != null) {
          return QoshniPlatformAuthorizationReason.deniedInvalidInput;
        }
        return null;
      case QoshniPlatformResourceScopeKind.branch:
        final business = scope.businessReference?.trim() ?? '';
        final branch = scope.branchReference?.trim() ?? '';
        if (business.isEmpty) {
          return QoshniPlatformAuthorizationReason
              .deniedScopeBusinessReferenceRequired;
        }
        if (branch.isEmpty) {
          return QoshniPlatformAuthorizationReason
              .deniedScopeBranchReferenceRequired;
        }
        return null;
    }
  }

  static QoshniPlatformAuthorizationReason? _evaluateScope({
    required QoshniPlatformPermissionScopeRequirement requirement,
    required QoshniPlatformAdminIdentity admin,
    required QoshniPlatformResourceScope scope,
  }) {
    switch (requirement) {
      case QoshniPlatformPermissionScopeRequirement.platformWideOnly:
        if (scope.kind != QoshniPlatformResourceScopeKind.platform) {
          return QoshniPlatformAuthorizationReason.deniedScopePlatformWideRequired;
        }
        return null;
      case QoshniPlatformPermissionScopeRequirement.platformOrAssignedBusiness:
        if (scope.kind == QoshniPlatformResourceScopeKind.platform) {
          return null;
        }
        if (scope.kind == QoshniPlatformResourceScopeKind.business) {
          return _businessAssignmentCheck(admin, scope.businessReference!);
        }
        return QoshniPlatformAuthorizationReason.deniedScopePlatformWideRequired;
      case QoshniPlatformPermissionScopeRequirement
            .platformOrAssignedBusinessOrBranch:
        if (scope.kind == QoshniPlatformResourceScopeKind.platform) {
          return null;
        }
        if (scope.kind == QoshniPlatformResourceScopeKind.business) {
          return _businessAssignmentCheck(admin, scope.businessReference!);
        }
        final businessRef = scope.businessReference!.trim();
        final branchRef = scope.branchReference!.trim();
        final businessDenied = _businessAssignmentCheck(admin, businessRef);
        if (businessDenied != null) {
          return businessDenied;
        }
        if (!admin.assignedBranchReferences.contains(branchRef)) {
          return QoshniPlatformAuthorizationReason.deniedCrossBranchAccess;
        }
        return null;
    }
  }

  static QoshniPlatformAuthorizationReason? _businessAssignmentCheck(
    QoshniPlatformAdminIdentity admin,
    String businessReference,
  ) {
    final ref = businessReference.trim();
    if (admin.assignedBusinessReferences.isEmpty) {
      return QoshniPlatformAuthorizationReason.deniedBusinessAssignmentRequired;
    }
    if (!admin.assignedBusinessReferences.contains(ref)) {
      return QoshniPlatformAuthorizationReason.deniedCrossBusinessAccess;
    }
    return null;
  }

  static QoshniPlatformAuthorizationDecision _deny(
    QoshniPlatformPermission permission,
    QoshniPlatformAuthorizationReason reason,
  ) {
    return QoshniPlatformAuthorizationDecision(
      isAllowed: false,
      reason: reason,
      permission: permission,
    );
  }
}
