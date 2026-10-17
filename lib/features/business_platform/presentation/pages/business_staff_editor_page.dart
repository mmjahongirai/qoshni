import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_staff_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_role_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_validation.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_staff_permission_card.dart';

class BusinessStaffEditorPage extends StatefulWidget {
  const BusinessStaffEditorPage({this.staffId, super.key});

  final String? staffId;

  bool get isEdit => staffId != null && staffId!.trim().isNotEmpty;

  @override
  State<BusinessStaffEditorPage> createState() =>
      _BusinessStaffEditorPageState();
}

class _BusinessStaffEditorPageState extends State<BusinessStaffEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late BusinessStaffRole _role;
  late Set<String> _selectedBranchIds;
  late bool _isActive;
  bool _dirty = false;
  String? _branchSelectionError;

  @override
  void initState() {
    super.initState();
    final controller = getIt<BusinessStaffController>();
    final existing = widget.isEdit
        ? controller.memberById(widget.staffId!.trim())
        : null;
    _firstNameController =
        TextEditingController(text: existing?.firstName ?? '');
    _lastNameController = TextEditingController(text: existing?.lastName ?? '');
    _phoneController =
        TextEditingController(text: existing?.contactPhone ?? '');
    _emailController =
        TextEditingController(text: existing?.contactEmail ?? '');
    _role = existing?.role ?? BusinessStaffRole.staff;
    if (_role == BusinessStaffRole.businessOwner) {
      _role = BusinessStaffRole.staff;
    }
    _selectedBranchIds = Set.from(existing?.assignedBranchIds ?? const []);
    _isActive = existing == null ||
        existing.status != BusinessStaffMemberStatus.removedPreview;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
    }
  }

  BusinessStaffMemberInput _buildInput() {
    return BusinessStaffMemberInput(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      contactPhone: _phoneController.text,
      contactEmail: _emailController.text,
      role: _role,
      assignedBranchIds: _selectedBranchIds.toList(),
      isActive: _isActive,
    );
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
        title: Text(l10n.staffDiscardConfirmTitle),
        content: Text(l10n.staffDiscardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.staffCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.staffDiscardConfirmAction),
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
    final input = _buildInput();
    final validation = validateBusinessStaffInput(
      input,
      firstNameRequired: () => l10n.staffValidationFirstName,
      phoneInvalid: () => l10n.staffValidationPhone,
      emailInvalid: () => l10n.staffValidationEmail,
      roleNotAssignable: () => l10n.staffValidationRoleNotAssignable,
      branchRequired: () => l10n.staffValidationBranchRequired,
    );
    if (!validation.isValid) {
      setState(() {
        _branchSelectionError = validation.branchError;
      });
      _formKey.currentState?.validate();
      return;
    }
    setState(() => _branchSelectionError = null);

    final controller = getIt<BusinessStaffController>();
    final BusinessStaffSaveResult result;
    if (widget.isEdit) {
      result = await controller.updateMember(widget.staffId!.trim(), input);
    } else {
      result = await controller.createMember(input);
    }
    if (!mounted) {
      return;
    }
    if (result == BusinessStaffSaveResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.staffSaveSuccess)),
      );
      context.pop();
      return;
    }
    if (result == BusinessStaffSaveResult.invalidScope) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.staffInvalidScopeMessage)),
      );
      return;
    }
    if (result == BusinessStaffSaveResult.notFound) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.staffNotFoundBody)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.staffSaveFailed)),
    );
  }

  void _toggleBranch(String branchId, bool selected) {
    setState(() {
      if (selected) {
        _selectedBranchIds.add(branchId);
      } else {
        _selectedBranchIds.remove(branchId);
      }
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final staffController = getIt<BusinessStaffController>();
    final branchController = getIt<BusinessBranchController>();

    if (widget.isEdit) {
      final existing = staffController.memberById(widget.staffId!);
      if (existing == null) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: Text(l10n.staffEditorEditTitle),
          ),
          body: Center(child: Text(l10n.staffNotFoundBody)),
        );
      }
      if (existing.role == BusinessStaffRole.businessOwner) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: Text(l10n.staffEditorEditTitle),
          ),
          body: Center(child: Text(l10n.staffOwnerNotEditableMessage)),
        );
      }
    }

    final branches = branchController.branches;

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
          title: Text(
            widget.isEdit
                ? l10n.staffEditorEditTitle
                : l10n.staffEditorCreateTitle,
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([staffController, branchController]),
            builder: (context, _) {
              return ResponsiveLayout(
                phone: _StaffEditorForm(
                  maxWidth: 520,
                  formKey: _formKey,
                  saveBusy: staffController.saveBusy,
                  l10n: l10n,
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  role: _role,
                  isActive: _isActive,
                  branches: branches,
                  selectedBranchIds: _selectedBranchIds,
                  branchSelectionError: _branchSelectionError,
                  onRoleChanged: (role) {
                    setState(() => _role = role);
                    _markDirty();
                  },
                  onActiveChanged: (value) {
                    setState(() => _isActive = value);
                    _markDirty();
                  },
                  onBranchToggle: _toggleBranch,
                  onFieldChanged: _markDirty,
                  onSave: staffController.saveBusy ? null : _onSave,
                  onCancel: _onCancel,
                ),
                tablet: _StaffEditorForm(
                  maxWidth: 760,
                  formKey: _formKey,
                  saveBusy: staffController.saveBusy,
                  l10n: l10n,
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  role: _role,
                  isActive: _isActive,
                  branches: branches,
                  selectedBranchIds: _selectedBranchIds,
                  branchSelectionError: _branchSelectionError,
                  onRoleChanged: (role) {
                    setState(() => _role = role);
                    _markDirty();
                  },
                  onActiveChanged: (value) {
                    setState(() => _isActive = value);
                    _markDirty();
                  },
                  onBranchToggle: _toggleBranch,
                  onFieldChanged: _markDirty,
                  onSave: staffController.saveBusy ? null : _onSave,
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

class _StaffEditorForm extends StatelessWidget {
  const _StaffEditorForm({
    required this.maxWidth,
    required this.formKey,
    required this.saveBusy,
    required this.l10n,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.role,
    required this.isActive,
    required this.branches,
    required this.selectedBranchIds,
    required this.branchSelectionError,
    required this.onRoleChanged,
    required this.onActiveChanged,
    required this.onBranchToggle,
    required this.onFieldChanged,
    required this.onSave,
    required this.onCancel,
  });

  final double maxWidth;
  final GlobalKey<FormState> formKey;
  final bool saveBusy;
  final AppLocalizations l10n;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final BusinessStaffRole role;
  final bool isActive;
  final List<BusinessBranch> branches;
  final Set<String> selectedBranchIds;
  final String? branchSelectionError;
  final ValueChanged<BusinessStaffRole> onRoleChanged;
  final ValueChanged<bool> onActiveChanged;
  final void Function(String branchId, bool selected) onBranchToggle;
  final VoidCallback onFieldChanged;
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
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppMessageBanner(
                  message: l10n.staffPreviewNotice,
                  icon: Icons.info_outline,
                  tone: AppMessageTone.info,
                ),
                const SizedBox(height: AppSpacing.md),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.staffSectionBasics,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: l10n.staffFieldFirstName,
                        ),
                        onChanged: (_) => onFieldChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.staffValidationFirstName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: l10n.staffFieldLastName,
                        ),
                        onChanged: (_) => onFieldChanged(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: l10n.staffFieldPhone,
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => onFieldChanged(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: l10n.staffFieldEmailOptional,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => onFieldChanged(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.staffFieldActive),
                        subtitle: Text(l10n.staffFieldActiveHint),
                        value: isActive,
                        onChanged: (value) => onActiveChanged(value),
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
                        l10n.staffSectionRole,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<BusinessStaffRole>(
                        isExpanded: true,
                        value: role,
                        decoration: InputDecoration(
                          labelText: l10n.staffFieldRole,
                        ),
                        items: [
                          for (final assignable in assignableBusinessStaffRoles)
                            DropdownMenuItem(
                              value: assignable,
                              child: Text(staffRoleLabel(l10n, assignable)),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            onRoleChanged(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                BusinessStaffPermissionCard(role: role),
                const SizedBox(height: AppSpacing.md),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.staffSectionBranches,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.staffBranchSelectionHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (branches.isEmpty)
                        Text(l10n.staffNoBranchesAvailable)
                      else
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            for (final branch in branches)
                              FilterChip(
                                label: Text(branch.name),
                                selected:
                                    selectedBranchIds.contains(branch.branchId),
                                onSelected: (selected) => onBranchToggle(
                                  branch.branchId,
                                  selected,
                                ),
                              ),
                          ],
                        ),
                      if (branchSelectionError != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          branchSelectionError!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onSave,
                  child: saveBusy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.staffSaveAction),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: saveBusy ? null : onCancel,
                  child: Text(l10n.staffCancelAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
