import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission_definition.dart';

void main() {
  test('permission catalog is stable and typed', () {
    final catalog = buildQoshniPlatformPermissionCatalog();
    expect(catalog.length, QoshniPlatformPermission.values.length);
    final ids = catalog.map((d) => d.permissionId).toSet();
    expect(ids.length, catalog.length);
    for (final definition in catalog) {
      expect(definition.permissionId, startsWith('platform.admin.'));
    }
  });

  test('catalog excludes financial wallet and unrestricted private permissions', () {
    final ids = buildQoshniPlatformPermissionCatalog()
        .map((d) => d.permissionId)
        .join('\n');
    expect(ids, isNot(contains('wallet')));
    expect(ids, isNot(contains('financial')));
    expect(ids, isNot(contains('payment')));
    expect(ids, isNot(contains('private_ai')));
    expect(ids, isNot(contains('unrestricted_user_data')));
  });

  test('support respond permission id is distinct from financial patterns', () {
    expect(
      QoshniPlatformPermission.respondToSupportCases.permissionId,
      'platform.admin.support.cases.respond',
    );
    expect(
      QoshniPlatformPermission.viewSupportCases.permissionId,
      isNot(contains('wallet')),
    );
  });
}
