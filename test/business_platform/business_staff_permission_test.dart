import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_permission_preview.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_role_labels.dart';

void main() {
  test('branch manager preview lists branch-scoped permissions', () {
    final preview = permissionPreviewForRole(BusinessStaffRole.branchManager);
    expect(preview.permissionKeys, contains('staffPermManageAssignedBranches'));
    expect(preview.permissionKeys, isNot(contains('staffPermManageBusiness')));
  });

  test('read-only preview is view-only', () {
    final preview = permissionPreviewForRole(BusinessStaffRole.readOnly);
    expect(preview.permissionKeys, ['staffPermViewBusinessPreview']);
  });

  test('permission bullets localized for admin role', () {
    final l10n = AppLocalizationsEn();
    final bullets = permissionBulletLabels(l10n, BusinessStaffRole.businessAdmin);
    expect(bullets, isNotEmpty);
    expect(bullets.join(' '), isNot(contains('staffPerm')));
  });
}
