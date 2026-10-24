import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';

class QoshniPlatformAuthorizationDecision {
  const QoshniPlatformAuthorizationDecision({
    required this.isAllowed,
    required this.reason,
    required this.permission,
    this.matchedRoleId,
  });

  final bool isAllowed;
  final QoshniPlatformAuthorizationReason reason;
  final QoshniPlatformPermission permission;
  final String? matchedRoleId;
}
