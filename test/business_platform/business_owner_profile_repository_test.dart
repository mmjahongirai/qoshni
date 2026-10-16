import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

void main() {
  late InMemoryBusinessOwnerProfileRepository repo;

  setUp(() {
    repo = InMemoryBusinessOwnerProfileRepository();
  });

  test('ensureSessionProfile returns demo seed', () {
    final profile = repo.ensureSessionProfile();
    expect(profile.isDemoSeed, isTrue);
    expect(profile.sessionProfileId, 'session-owner-profile-demo');
    expect(profile.isVerified, isFalse);
  });

  test('save updates profile and marks user session source', () {
    repo.ensureSessionProfile();
    const input = BusinessOwnerProfileInput(
      legalBusinessName: 'New Legal',
      displayName: 'New Display',
      description: 'Updated description',
      categoryId: ServiceCategoryId.pharmacy,
      contactPhone: '+998901234567',
    );

    final result = repo.saveSessionProfile(input);
    expect(result, BusinessOwnerProfileSaveResult.success);

    final saved = repo.sessionProfile!;
    expect(saved.dataSource, BusinessOwnerProfileDataSource.userSession);
    expect(saved.legalBusinessName, 'New Legal');
    expect(saved.displayName, 'New Display');
  });

  test('resetSessionToDemoSeed restores demo data', () {
    repo.ensureSessionProfile();
    repo.saveSessionProfile(
      const BusinessOwnerProfileInput(
        legalBusinessName: 'X',
        displayName: 'Y',
        description: 'Z',
        categoryId: ServiceCategoryId.shops,
      ),
    );
    repo.resetSessionToDemoSeed();
    expect(repo.sessionProfile!.isDemoSeed, isTrue);
    expect(repo.sessionProfile!.legalBusinessName, 'Demo Services LLC');
  });

  test('demo session id is separate from onboarding profile drafts', () {
    final profile = repo.ensureSessionProfile();
    expect(profile.sessionProfileId, isNot(contains('onboarding')));
    expect(profile.sessionProfileId, startsWith('session-owner-profile'));
  });

  test('failNextSave returns failure without mutating profile', () {
    repo.ensureSessionProfile();
    final before = repo.sessionProfile!.displayName;
    repo.failNextSave = true;
    final result = repo.saveSessionProfile(
      const BusinessOwnerProfileInput(
        legalBusinessName: 'A',
        displayName: 'Changed',
        description: 'D',
        categoryId: ServiceCategoryId.shops,
      ),
    );
    expect(result, BusinessOwnerProfileSaveResult.failure);
    expect(repo.sessionProfile!.displayName, before);
  });
}
