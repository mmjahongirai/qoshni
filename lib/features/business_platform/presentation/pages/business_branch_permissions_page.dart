import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_permission.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_permission_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_permission_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_permission_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_permission_policy.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_controller.dart';

class BusinessBranchPermissionsPage extends StatefulWidget {
  const BusinessBranchPermissionsPage({
    this.initialStaffId,
    this.initialBranchId,
    super.key,
  });

  final String? initialStaffId;
  final String? initialBranchId;

  @override
  State<BusinessBranchPermissionsPage> createState() =>
      _BusinessBranchPermissionsPageState();
}

class _BusinessBranchPermissionsPageState
    extends State<BusinessBranchPermissionsPage> {
  String? _staffId;
  String? _branchId;
  Set<BusinessBranchPermission> _draft = {};
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final staffController = getIt<BusinessStaffController>();
    final branchController = getIt<BusinessBranchController>();
    final members = staffController.members;
    final branches = branchController.branches;
    _staffId = widget.initialStaffId;
    _branchId = widget.initialBranchId;
    if (_staffId == null && members.isNotEmpty) {
      final nonOwner = members
          .where((m) => m.role != BusinessStaffRole.businessOwner)
          .toList();
      _staffId = nonOwner.isNotEmpty
          ? nonOwner.first.staffId
          : members.first.staffId;
    }
    if (_branchId == null && branches.isNotEmpty) {
      _branchId = branches.first.branchId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraftFromRepo());
  }

  void _loadDraftFromRepo() {
    final staffId = _staffId;
    final branchId = _branchId;
    if (staffId == null || branchId == null) {
      return;
    }
    final controller = getIt<BusinessBranchPermissionController>();
    setState(() {
      _draft = Set.from(controller.permissionsFor(staffId, branchId));
      _dirty = false;
    });
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
    }
  }

  Future<void> _onCancel() async {
    if (!_dirty) {
      if (mounted) {
        context.pop();
      }
      return;
    }
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.branchPermDiscardConfirmTitle),
        content: Text(l10n.branchPermDiscardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.branchPermCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.branchPermDiscardConfirmAction),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      context.pop();
    }
  }

  Future<void> _onSave() async {
    final l10n = AppLocalizations.of(context);
    final staffId = _staffId;
    final branchId = _branchId;
    if (staffId == null || branchId == null) {
      return;
    }
    final controller = getIt<BusinessBranchPermissionController>();
    final result = await controller.savePermissions(staffId, branchId, _draft);
    if (!mounted) {
      return;
    }
    switch (result) {
      case BusinessBranchPermissionSaveResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.branchPermSaveSuccess)),
        );
        setState(() => _dirty = false);
      case BusinessBranchPermissionSaveResult.notEditable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.branchPermOwnerNotEditable)),
        );
      case BusinessBranchPermissionSaveResult.invalidScope:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.branchPermInvalidScopeMessage)),
        );
      case BusinessBranchPermissionSaveResult.notFound:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.branchPermInvalidScopeMessage)),
        );
      case BusinessBranchPermissionSaveResult.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.branchPermSaveFailed)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final staffController = getIt<BusinessStaffController>();
    final branchController = getIt<BusinessBranchController>();
    final permController = getIt<BusinessBranchPermissionController>();

    final members = staffController.members;
    final branches = branchController.branches;

    final selectedMember = _staffId == null
        ? null
        : staffController.memberById(_staffId!);
    final selectedBranch = _branchId == null
        ? null
        : branchController.branchById(_branchId!);

    final invalidSelection =
        selectedMember == null || selectedBranch == null;
    final assigned = !invalidSelection &&
        permController.isStaffAssignedToBranch(_staffId!, _branchId!);
    final editable = assigned &&
        selectedMember.role != BusinessStaffRole.businessOwner;
    final assignable = selectedMember == null
        ? <BusinessBranchPermission>{}
        : assignablePermissionsForRole(selectedMember.role);
    final suggested = selectedMember == null
        ? <BusinessBranchPermission>{}
        : suggestedPermissionsForRole(selectedMember.role);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _onCancel();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _onCancel),
          title: Text(l10n.branchPermPageTitle),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([
              staffController,
              branchController,
              permController,
            ]),
            builder: (context, _) {
              return ResponsiveLayout(
                phone: _PermissionsBody(
                  maxWidth: 520,
                  l10n: l10n,
                  members: members,
                  branches: branches,
                  staffId: _staffId,
                  branchId: _branchId,
                  draft: _draft,
                  assigned: assigned,
                  editable: editable,
                  assignable: assignable,
                  suggested: suggested,
                  saveBusy: permController.saveBusy,
                  onStaffChanged: (value) {
                    setState(() {
                      _staffId = value;
                      _loadDraftFromRepo();
                    });
                  },
                  onBranchChanged: (value) {
                    setState(() {
                      _branchId = value;
                      _loadDraftFromRepo();
                    });
                  },
                  onPermissionChanged: (permission, enabled) {
                    setState(() {
                      if (enabled) {
                        _draft.add(permission);
                      } else {
                        _draft.remove(permission);
                      }
                      _markDirty();
                    });
                  },
                  onSave: editable && !permController.saveBusy ? _onSave : null,
                  onCancel: _onCancel,
                ),
                tablet: _PermissionsBody(
                  maxWidth: 760,
                  l10n: l10n,
                  members: members,
                  branches: branches,
                  staffId: _staffId,
                  branchId: _branchId,
                  draft: _draft,
                  assigned: assigned,
                  editable: editable,
                  assignable: assignable,
                  suggested: suggested,
                  saveBusy: permController.saveBusy,
                  onStaffChanged: (value) {
                    setState(() {
                      _staffId = value;
                      _loadDraftFromRepo();
                    });
                  },
                  onBranchChanged: (value) {
                    setState(() {
                      _branchId = value;
                      _loadDraftFromRepo();
                    });
                  },
                  onPermissionChanged: (permission, enabled) {
                    setState(() {
                      if (enabled) {
                        _draft.add(permission);
                      } else {
                        _draft.remove(permission);
                      }
                      _markDirty();
                    });
                  },
                  onSave: editable && !permController.saveBusy ? _onSave : null,
                  onCancel: _onCancel,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PermissionsBody extends StatelessWidget {
  const _PermissionsBody({
    required this.maxWidth,
    required this.l10n,
    required this.members,
    required this.branches,
    required this.staffId,
    required this.branchId,
    required this.draft,
    required this.assigned,
    required this.editable,
    required this.assignable,
    required this.suggested,
    required this.saveBusy,
    required this.onStaffChanged,
    required this.onBranchChanged,
    required this.onPermissionChanged,
    required this.onSave,
    required this.onCancel,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessStaffMember> members;
  final List<BusinessBranch> branches;
  final String? staffId;
  final String? branchId;
  final Set<BusinessBranchPermission> draft;
  final bool assigned;
  final bool editable;
  final Set<BusinessBranchPermission> assignable;
  final Set<BusinessBranchPermission> suggested;
  final bool saveBusy;
  final ValueChanged<String?> onStaffChanged;
  final ValueChanged<String?> onBranchChanged;
  final void Function(BusinessBranchPermission permission, bool enabled)
      onPermissionChanged;
  final VoidCallback? onSave;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppMessageBanner(
                message: l10n.branchPermPreviewNotice,
                icon: Icons.info_outline,
                tone: AppMessageTone.info,
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: staffId,
                      decoration: InputDecoration(
                        labelText: l10n.branchPermSelectStaff,
                      ),
                      items: [
                        for (final member in members)
                          DropdownMenuItem(
                            value: member.staffId,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member.displayName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (member.isDemoSeed) const DemoContentBadge(),
                              ],
                            ),
                          ),
                      ],
                      onChanged: onStaffChanged,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: branchId,
                      decoration: InputDecoration(
                        labelText: l10n.branchPermSelectBranch,
                      ),
                      items: [
                        for (final branch in branches)
                          DropdownMenuItem(
                            value: branch.branchId,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    branch.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (branch.isDemoSeed) const DemoContentBadge(),
                              ],
                            ),
                          ),
                      ],
                      onChanged: onBranchChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.branchPermAccessStatusTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      assigned
                          ? l10n.branchPermAccessGrantedPreview
                          : l10n.branchPermAccessNonePreview,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: assigned
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                    ),
                    if (!assigned) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.branchPermUnassignedBranchHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                      ),
                    ],
                    if (!editable && assigned) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.branchPermOwnerNotEditable,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.branchPermRoleSuggestedHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final group in BusinessBranchPermissionGroup.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branchPermissionGroupLabel(l10n, group),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final permission in allBusinessBranchPermissions)
                          if (groupForPermission(permission) == group)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                branchPermissionLabel(l10n, permission),
                              ),
                              subtitle: Text(
                                branchPermissionDescription(l10n, permission),
                              ),
                              value: draft.contains(permission),
                              onChanged: editable &&
                                      assignable.contains(permission)
                                  ? (value) =>
                                      onPermissionChanged(permission, value)
                                  : null,
                            ),
                      ],
                    ),
                  ),
                ),
              if (suggested.isNotEmpty) ...[
                AppMessageBanner(
                  message: l10n.branchPermSuggestedVsExplicitNotice,
                  icon: Icons.lightbulb_outline,
                  tone: AppMessageTone.warning,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              FilledButton(
                onPressed: onSave,
                child: saveBusy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.branchPermSaveAction),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: saveBusy ? null : onCancel,
                child: Text(l10n.branchPermCancelAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
