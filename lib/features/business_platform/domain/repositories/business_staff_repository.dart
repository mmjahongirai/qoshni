import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';

enum BusinessStaffSaveResult {
  success,
  notFound,
  invalidScope,
  failure,
}

abstract class BusinessStaffRepository {
  String get businessScopeId;

  List<BusinessStaffMember> listForCurrentScope();

  BusinessStaffMember? findById(String staffId);

  BusinessStaffSaveResult createMember(BusinessStaffMemberInput input);

  BusinessStaffSaveResult updateMember(
    String staffId,
    BusinessStaffMemberInput input,
  );

  void resetScopeToDemoSeed();
}
