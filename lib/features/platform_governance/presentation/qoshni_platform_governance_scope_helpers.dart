import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';

QoshniPlatformResourceScope qoshniPlatformBusinessScope({
  required String businessReference,
  String? branchReference,
}) {
  final branch = branchReference?.trim();
  if (branch != null && branch.isNotEmpty) {
    return QoshniPlatformResourceScope(
      kind: QoshniPlatformResourceScopeKind.branch,
      businessReference: businessReference.trim(),
      branchReference: branch,
    );
  }
  return QoshniPlatformResourceScope(
    kind: QoshniPlatformResourceScopeKind.business,
    businessReference: businessReference.trim(),
  );
}
