import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_validation.dart';

void main() {
  test('valid seed admins and roles pass validation', () {
    for (final admin in buildQoshniPlatformAdminIdentityDemoSeed()) {
      expect(qoshniPlatformAdminIdentityValidationError(admin), isNull);
    }
    for (final role in buildQoshniPlatformAdminRoleDemoSeed()) {
      expect(qoshniPlatformAdminRoleValidationError(role), isNull);
    }
  });

  test('duplicate role references on admin fail validation', () {
    final admin = buildQoshniPlatformAdminIdentityDemoSeed().first;
    final invalid = admin.copyWith(roleIds: ['role-platform-viewer', 'role-platform-viewer']);
    expect(qoshniPlatformAdminIdentityValidationError(invalid), isNotNull);
  });
}
