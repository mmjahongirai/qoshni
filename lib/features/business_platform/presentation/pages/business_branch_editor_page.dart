import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_weekday_labels.dart';

class BusinessBranchEditorPage extends StatefulWidget {
  const BusinessBranchEditorPage({this.branchId, super.key});

  final String? branchId;

  bool get isEdit => branchId != null && branchId!.trim().isNotEmpty;

  @override
  State<BusinessBranchEditorPage> createState() =>
      _BusinessBranchEditorPageState();
}

class _BusinessBranchEditorPageState extends State<BusinessBranchEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late BusinessBranchLifecycleStatus _status;
  late List<BranchDaySchedule> _schedule;
  bool _dirty = false;
  Map<int, String> _scheduleErrors = const {};

  @override
  void initState() {
    super.initState();
    final controller = getIt<BusinessBranchController>();
    BusinessBranch? existing;
    if (widget.isEdit) {
      existing = controller.branchById(widget.branchId!.trim());
    }
    _nameController = TextEditingController(text: existing?.name ?? '');
    _cityController = TextEditingController(text: existing?.city ?? '');
    _addressController =
        TextEditingController(text: existing?.addressLine ?? '');
    _phoneController =
        TextEditingController(text: existing?.contactPhone ?? '');
    _latitudeController = TextEditingController(
      text: existing?.locationPreview.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: existing?.locationPreview.longitude?.toString() ?? '',
    );
    _status = existing?.status ?? BusinessBranchLifecycleStatus.active;
    _schedule = existing != null
        ? List.from(existing.weeklySchedule)
        : defaultWeeklySchedule();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
    }
  }

  BusinessBranchInput _buildInput() {
    return BusinessBranchInput(
      name: _nameController.text,
      city: _cityController.text,
      addressLine: _addressController.text,
      contactPhone: _phoneController.text,
      status: _status,
      weeklySchedule: _schedule,
      latitude: _parseOptionalDouble(_latitudeController.text),
      longitude: _parseOptionalDouble(_longitudeController.text),
    );
  }

  double? _parseOptionalDouble(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed);
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
        title: Text(l10n.branchDiscardConfirmTitle),
        content: Text(l10n.branchDiscardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.branchCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.branchDiscardConfirmAction),
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
    final validation = validateBusinessBranchInput(
      input,
      nameRequired: () => l10n.branchValidationName,
      cityRequired: () => l10n.branchValidationCity,
      addressRequired: () => l10n.branchValidationAddress,
      phoneInvalid: () => l10n.branchValidationPhone,
      timeInvalid: () => l10n.branchValidationTime,
      timeOrderInvalid: () => l10n.branchValidationTimeOrder,
      coordinateInvalid: () => l10n.branchValidationCoordinates,
    );
    if (!validation.isValid) {
      setState(() => _scheduleErrors = validation.scheduleErrorsByWeekday);
      _formKey.currentState?.validate();
      return;
    }
    setState(() => _scheduleErrors = const {});

    final controller = getIt<BusinessBranchController>();
    final BusinessBranchSaveResult result;
    if (widget.isEdit) {
      result = await controller.updateBranch(widget.branchId!.trim(), input);
    } else {
      result = await controller.createBranch(input);
    }
    if (!mounted) {
      return;
    }
    if (result == BusinessBranchSaveResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.branchSaveSuccess)),
      );
      context.pop();
      return;
    }
    if (result == BusinessBranchSaveResult.notFound) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.branchNotFoundBody)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.branchSaveFailed)),
    );
  }

  void _updateDay(int weekday, BranchDaySchedule updated) {
    setState(() {
      _schedule = [
        for (final day in _schedule)
          if (day.weekday == weekday) updated else day,
      ];
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final branchController = getIt<BusinessBranchController>();

    if (widget.isEdit && branchController.branchById(widget.branchId!) == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.branchEditorEditTitle),
        ),
        body: Center(child: Text(l10n.branchNotFoundBody)),
      );
    }

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
                ? l10n.branchEditorEditTitle
                : l10n.branchEditorCreateTitle,
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: branchController,
            builder: (context, _) {
              return ResponsiveLayout(
                phone: _EditorForm(
                  maxWidth: 520,
                  formKey: _formKey,
                  saveBusy: branchController.saveBusy,
                  l10n: l10n,
                  nameController: _nameController,
                  cityController: _cityController,
                  addressController: _addressController,
                  phoneController: _phoneController,
                  latitudeController: _latitudeController,
                  longitudeController: _longitudeController,
                  status: _status,
                  schedule: _schedule,
                  scheduleErrors: _scheduleErrors,
                  onStatusChanged: (value) {
                    setState(() => _status = value);
                    _markDirty();
                  },
                  onDayChanged: _updateDay,
                  onFieldChanged: _markDirty,
                  onSave: branchController.saveBusy ? null : _onSave,
                  onCancel: _onCancel,
                ),
                tablet: _EditorForm(
                  maxWidth: 760,
                  formKey: _formKey,
                  saveBusy: branchController.saveBusy,
                  l10n: l10n,
                  nameController: _nameController,
                  cityController: _cityController,
                  addressController: _addressController,
                  phoneController: _phoneController,
                  latitudeController: _latitudeController,
                  longitudeController: _longitudeController,
                  status: _status,
                  schedule: _schedule,
                  scheduleErrors: _scheduleErrors,
                  onStatusChanged: (value) {
                    setState(() => _status = value);
                    _markDirty();
                  },
                  onDayChanged: _updateDay,
                  onFieldChanged: _markDirty,
                  onSave: branchController.saveBusy ? null : _onSave,
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

class _EditorForm extends StatelessWidget {
  const _EditorForm({
    required this.maxWidth,
    required this.formKey,
    required this.saveBusy,
    required this.l10n,
    required this.nameController,
    required this.cityController,
    required this.addressController,
    required this.phoneController,
    required this.latitudeController,
    required this.longitudeController,
    required this.status,
    required this.schedule,
    required this.scheduleErrors,
    required this.onStatusChanged,
    required this.onDayChanged,
    required this.onFieldChanged,
    required this.onSave,
    required this.onCancel,
  });

  final double maxWidth;
  final GlobalKey<FormState> formKey;
  final bool saveBusy;
  final AppLocalizations l10n;
  final TextEditingController nameController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final BusinessBranchLifecycleStatus status;
  final List<BranchDaySchedule> schedule;
  final Map<int, String> scheduleErrors;
  final ValueChanged<BusinessBranchLifecycleStatus> onStatusChanged;
  final void Function(int weekday, BranchDaySchedule updated) onDayChanged;
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
                  message: l10n.branchPreviewNotice,
                  icon: Icons.info_outline,
                  tone: AppMessageTone.info,
                ),
                const SizedBox(height: AppSpacing.md),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.branchSectionBasics,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.branchFieldName,
                        ),
                        onChanged: (_) => onFieldChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.branchValidationName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: cityController,
                        decoration: InputDecoration(
                          labelText: l10n.branchFieldCity,
                        ),
                        onChanged: (_) => onFieldChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.branchValidationCity;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: l10n.branchFieldAddress,
                        ),
                        onChanged: (_) => onFieldChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.branchValidationAddress;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: l10n.branchFieldPhone,
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => onFieldChanged(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<BusinessBranchLifecycleStatus>(
                        isExpanded: true,
                        value: status,
                        decoration: InputDecoration(
                          labelText: l10n.branchFieldStatus,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: BusinessBranchLifecycleStatus.active,
                            child: Text(l10n.branchStatusActive),
                          ),
                          DropdownMenuItem(
                            value: BusinessBranchLifecycleStatus.inactive,
                            child: Text(l10n.branchStatusInactive),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            onStatusChanged(value);
                          }
                        },
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
                        l10n.branchSectionHours,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final day in schedule)
                        _DayScheduleRow(
                          l10n: l10n,
                          day: day,
                          errorText: scheduleErrors[day.weekday],
                          onChanged: (updated) =>
                              onDayChanged(day.weekday, updated),
                          onFieldChanged: onFieldChanged,
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
                        l10n.branchSectionLocation,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.branchLocationDemoHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: latitudeController,
                        decoration: InputDecoration(
                          labelText: l10n.branchFieldLatitude,
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => onFieldChanged(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: longitudeController,
                        decoration: InputDecoration(
                          labelText: l10n.branchFieldLongitude,
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => onFieldChanged(),
                      ),
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
                      : Text(l10n.branchSaveAction),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: saveBusy ? null : onCancel,
                  child: Text(l10n.branchCancelAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayScheduleRow extends StatelessWidget {
  const _DayScheduleRow({
    required this.l10n,
    required this.day,
    required this.onChanged,
    required this.onFieldChanged,
    this.errorText,
  });

  final AppLocalizations l10n;
  final BranchDaySchedule day;
  final ValueChanged<BranchDaySchedule> onChanged;
  final VoidCallback onFieldChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(branchWeekdayLabel(l10n, day.weekday)),
            subtitle: day.isClosed ? Text(l10n.branchDayClosed) : null,
            value: day.isClosed,
            onChanged: (closed) {
              onChanged(
                day.copyWith(
                  isClosed: closed,
                  clearOpenTime: closed,
                  clearCloseTime: closed,
                  openTime: closed ? null : (day.openTime ?? '09:00'),
                  closeTime: closed ? null : (day.closeTime ?? '18:00'),
                ),
              );
              onFieldChanged();
            },
          ),
          if (!day.isClosed)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: day.openTime ?? '',
                    decoration: InputDecoration(
                      labelText: l10n.branchFieldOpenTime,
                      hintText: '09:00',
                    ),
                    onChanged: (value) {
                      onChanged(day.copyWith(openTime: value));
                      onFieldChanged();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    initialValue: day.closeTime ?? '',
                    decoration: InputDecoration(
                      labelText: l10n.branchFieldCloseTime,
                      hintText: '18:00',
                    ),
                    onChanged: (value) {
                      onChanged(day.copyWith(closeTime: value));
                      onFieldChanged();
                    },
                  ),
                ),
              ],
            ),
          if (errorText != null)
            Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
        ],
      ),
    );
  }
}
