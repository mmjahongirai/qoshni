import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_role_labels.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_staff_permission_card.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessStaffDetailPage extends StatelessWidget {
  const BusinessStaffDetailPage({required this.staffId, super.key});

  final String? staffId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final staffController = getIt<BusinessStaffController>();
    final id = staffId?.trim();
    final member = id == null || id.isEmpty ? null : staffController.memberById(id);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.staffDetailTitle),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: responsivePagePadding(context),
              child: AppSurfaceCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.staffNotFoundTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.staffNotFoundBody),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () => context.go(RoutePaths.businessStaff),
                      child: Text(l10n.staffBackToListAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final canEdit = member.role != BusinessStaffRole.businessOwner;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.staffDetailTitle),
        actions: [
          if (canEdit)
            TextButton(
              onPressed: () =>
                  context.push(RoutePaths.businessStaffEditPath(member.staffId)),
              child: Text(l10n.staffEditAction),
            ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            staffController,
            getIt<BusinessBranchController>(),
          ]),
          builder: (context, _) {
            final current = staffController.memberById(member.staffId) ?? member;
            final branches = getIt<BusinessBranchController>().branches;
            final branchNames = current.assignedBranchIds
                .map((id) {
                  for (final branch in branches) {
                    if (branch.branchId == id) {
                      return branch.name;
                    }
                  }
                  return id;
                })
                .join(', ');

            return ResponsiveLayout(
              phone: _DetailBody(
                maxWidth: 520,
                displayName: current.displayName,
                isDemo: current.isDemoSeed,
                role: current.role,
                status: current.status,
                phone: current.contactPhone,
                email: current.contactEmail,
                branchNames: branchNames,
              ),
              tablet: _DetailBody(
                maxWidth: 760,
                displayName: current.displayName,
                isDemo: current.isDemoSeed,
                role: current.role,
                status: current.status,
                phone: current.contactPhone,
                email: current.contactEmail,
                branchNames: branchNames,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.maxWidth,
    required this.displayName,
    required this.isDemo,
    required this.role,
    required this.status,
    required this.phone,
    required this.email,
    required this.branchNames,
  });

  final double maxWidth;
  final String displayName;
  final bool isDemo;
  final BusinessStaffRole role;
  final BusinessStaffMemberStatus status;
  final String phone;
  final String? email;
  final String branchNames;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                message: l10n.staffPreviewNotice,
                icon: Icons.info_outline,
                tone: AppMessageTone.info,
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                        ),
                        if (isDemo) const DemoContentBadge(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(staffRoleLabel(l10n, role)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(staffStatusLabel(l10n, status)),
                    const SizedBox(height: AppSpacing.md),
                    Text('${l10n.staffFieldPhone}: $phone'),
                    if (email != null) Text('${l10n.staffFieldEmail}: $email'),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.staffBranchesLabel(branchNames)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              BusinessStaffPermissionCard(role: role),
            ],
          ),
        ),
      ),
    );
  }
}
