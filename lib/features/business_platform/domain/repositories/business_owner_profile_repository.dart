import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';

enum BusinessOwnerProfileSaveResult {
  success,
  notFound,
  failure,
}

/// Session-scoped business owner profile (API implementation later).
abstract class BusinessOwnerProfileRepository {
  BusinessOwnerProfile? get sessionProfile;

  BusinessOwnerProfile ensureSessionProfile();

  BusinessOwnerProfileSaveResult saveSessionProfile(BusinessOwnerProfileInput input);

  void resetSessionToDemoSeed();
}
