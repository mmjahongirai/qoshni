import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_owner_profile_controller.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

void main() {
  test('save notifies listeners and returns success', () async {
    final repo = InMemoryBusinessOwnerProfileRepository();
    final controller = BusinessOwnerProfileController(repo);
    var notifications = 0;
    controller.addListener(() => notifications++);

    final result = await controller.save(
      const BusinessOwnerProfileInput(
        legalBusinessName: 'Legal',
        displayName: 'Display',
        description: 'Body',
        categoryId: ServiceCategoryId.shops,
      ),
    );

    expect(result, BusinessOwnerProfileSaveResult.success);
    expect(notifications, greaterThan(0));
    expect(controller.profile.displayName, 'Display');
  });

  test('save failure leaves prior profile unchanged', () async {
    final repo = InMemoryBusinessOwnerProfileRepository()..failNextSave = true;
    final controller = BusinessOwnerProfileController(repo);
    final before = controller.profile.displayName;

    final result = await controller.save(
      const BusinessOwnerProfileInput(
        legalBusinessName: 'Legal',
        displayName: 'New name',
        description: 'Body',
        categoryId: ServiceCategoryId.shops,
      ),
    );

    expect(result, BusinessOwnerProfileSaveResult.failure);
    expect(controller.profile.displayName, before);
  });
}
