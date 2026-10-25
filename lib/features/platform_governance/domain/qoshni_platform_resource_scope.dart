enum QoshniPlatformResourceScopeKind {
  platform,
  business,
  branch,
}

class QoshniPlatformResourceScope {
  const QoshniPlatformResourceScope({
    required this.kind,
    this.businessReference,
    this.branchReference,
  });

  const QoshniPlatformResourceScope.platform()
      : kind = QoshniPlatformResourceScopeKind.platform,
        businessReference = null,
        branchReference = null;

  final QoshniPlatformResourceScopeKind kind;
  final String? businessReference;
  final String? branchReference;

  @override
  bool operator ==(Object other) {
    return other is QoshniPlatformResourceScope &&
        other.kind == kind &&
        other.businessReference == businessReference &&
        other.branchReference == branchReference;
  }

  @override
  int get hashCode => Object.hash(kind, businessReference, branchReference);
}
