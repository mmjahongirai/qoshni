import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_controller.dart';
import 'package:qoshni/features/business_onboarding/presentation/tabs/onboarding_documents_tab.dart';
import 'package:qoshni/features/business_onboarding/presentation/tabs/onboarding_form_tab.dart';
import 'package:qoshni/features/business_onboarding/presentation/tabs/onboarding_verification_tab.dart';
import 'package:qoshni/features/business_onboarding/presentation/widgets/onboarding_auth_gate.dart';

class OnboardingApplicationPage extends StatefulWidget {
  const OnboardingApplicationPage({required this.applicationId, super.key});

  final String applicationId;

  @override
  State<OnboardingApplicationPage> createState() =>
      _OnboardingApplicationPageState();
}

class _OnboardingApplicationPageState extends State<OnboardingApplicationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<OnboardingController>().loadApplicationDetail(widget.applicationId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await getIt<OnboardingController>().loadApplicationDetail(
      widget.applicationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    final l10n = AppLocalizations.of(context);

    return OnboardingAuthGate(
      apiConfigured: config.apiConfigured,
      child: ListenableBuilder(
        listenable: getIt<OnboardingController>(),
        builder: (context, _) {
          final controller = getIt<OnboardingController>();
          final app = controller.selectedApplication;
          final loading = controller.detailBusy && app == null;

          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: Text(l10n.onboardingApplicationTitle),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.onboardingTabForm),
                  Tab(text: l10n.onboardingTabDocuments),
                  Tab(text: l10n.onboardingTabStatus),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: controller.detailBusy ? null : _reload,
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.userProfileRetryAction,
                ),
              ],
            ),
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : app == null
                    ? Center(child: Text(l10n.onboardingErrorNotFound))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          OnboardingFormTab(
                            applicationId: widget.applicationId,
                            application: app,
                          ),
                          OnboardingDocumentsTab(
                            applicationId: widget.applicationId,
                          ),
                          OnboardingVerificationTab(
                            applicationId: widget.applicationId,
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }
}
