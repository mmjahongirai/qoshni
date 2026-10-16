import 'package:qoshni/features/business_platform/domain/business_branch.dart';

enum BusinessBranchSaveResult {
  success,
  notFound,
  failure,
}

abstract class BusinessBranchRepository {
  /// Owner profile session id / future business_id scope.
  String get businessScopeId;

  List<BusinessBranch> listForCurrentScope();

  BusinessBranch? findById(String branchId);

  BusinessBranchSaveResult createBranch(BusinessBranchInput input);

  BusinessBranchSaveResult updateBranch(
    String branchId,
    BusinessBranchInput input,
  );

  void resetScopeToDemoSeed();
}
