import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/theme_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/home/presentation/favorites/favorites_controller.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_controller.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/primary_navigation_shell.dart';
import 'package:qoshni/core/widgets/profile_avatar_fallback.dart';
import 'package:qoshni/features/user_profile/data/user_profile_dtos.dart';
import 'package:qoshni/features/user_profile/presentation/user_profile_controller.dart';
import 'package:qoshni/features/user_profile/presentation/user_profile_messages.dart';
import 'package:qoshni/routing/route_paths.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = getIt<UserProfileController>();
      if (getIt<AuthController>().isSignedIn) {
        userProfile.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeController = getIt<ThemeController>();
    final localeController = getIt<LocaleController>();
    final favoritesController = getIt<FavoritesController>();
    final demoOrderController = getIt<DemoOrderController>();
    final authController = getIt<AuthController>();
    final userProfileController = getIt<UserProfileController>();

    return PrimaryNavigationShell(
      destination: PrimaryNavDestination.profile,
      body: Scaffold(
        appBar: AppBar(
          leading: primaryTabLeading(context),
          title: Text(l10n.profileTitle),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([
              themeController,
              localeController,
              favoritesController,
              demoOrderController,
              authController,
              userProfileController,
            ]),
            builder: (context, _) {
              return ResponsiveLayout(
                phone: _ProfileBody(
                  maxWidth: 520,
                  l10n: l10n,
                  themeController: themeController,
                  localeController: localeController,
                  favoritesController: favoritesController,
                  demoOrderController: demoOrderController,
                  authController: authController,
                  userProfileController: userProfileController,
                ),
                tablet: _ProfileBody(
                  maxWidth: 760,
                  l10n: l10n,
                  themeController: themeController,
                  localeController: localeController,
                  favoritesController: favoritesController,
                  demoOrderController: demoOrderController,
                  authController: authController,
                  userProfileController: userProfileController,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.maxWidth,
    required this.l10n,
    required this.themeController,
    required this.localeController,
    required this.favoritesController,
    required this.demoOrderController,
    required this.authController,
    required this.userProfileController,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final ThemeController themeController;
  final LocaleController localeController;
  final FavoritesController favoritesController;
  final DemoOrderController demoOrderController;
  final AuthController authController;
  final UserProfileController userProfileController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final favoriteCount = favoritesController.favoriteIds.length;
    final demoOrderCount = demoOrderController.orderCount;
    final signedIn = authController.isSignedIn;
    final displayName = userProfileController.profile?.displayName;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSurfaceCard(
                child: Column(
                  children: [
                    ProfileAvatarFallback(
                      signedIn: signedIn,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (signedIn && userProfileController.loading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: LinearProgressIndicator(),
                      ),
                    Text(
                      signedIn
                          ? (displayName?.isNotEmpty == true
                              ? displayName!
                              : l10n.userProfileDisplayNameEmpty)
                          : l10n.profileGuestTitle,
                      style: textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      signedIn
                          ? l10n.authSignedInBody
                          : l10n.profileGuestBody,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (signedIn) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: userProfileController.savingProfile
                                ? null
                                : () => _showEditDisplayNameDialog(context),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(l10n.userProfileEditDisplayNameAction),
                          ),
                          if (displayName?.isNotEmpty == true)
                            TextButton(
                              onPressed: userProfileController.savingProfile
                                  ? null
                                  : userProfileController.clearDisplayName,
                              child: Text(l10n.userProfileClearDisplayNameAction),
                            ),
                        ],
                      ),
                      if (userProfileController.savingProfile)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            l10n.userProfileSaving,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      if (userProfileController.profileSaveSucceeded)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: AppMessageBanner(
                            message: l10n.userProfileSaveSuccess,
                            icon: Icons.check_circle_outline,
                            tone: AppMessageTone.info,
                          ),
                        ),
                      if (userProfileController.profileSaveFailure != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: AppMessageBanner(
                            message: localizedUserProfileFailure(
                              l10n,
                              userProfileController.profileSaveFailure!,
                            ),
                            icon: Icons.error_outline,
                            tone: AppMessageTone.error,
                          ),
                        ),
                    ],
                    if (authController.status == AuthStatus.sessionExpired) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppMessageBanner(
                        message: l10n.authSessionExpiredNotice,
                        icon: Icons.lock_clock_outlined,
                        tone: AppMessageTone.warning,
                      ),
                    ],
                    if (signedIn && userProfileController.loadFailure != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppMessageBanner(
                        message: localizedUserProfileFailure(
                          l10n,
                          userProfileController.loadFailure!,
                        ),
                        icon: Icons.cloud_off_outlined,
                        tone: AppMessageTone.warning,
                      ),
                      TextButton.icon(
                        onPressed: userProfileController.loading
                            ? null
                            : userProfileController.refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.userProfileRetryAction),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileSettingsCard(
                title: l10n.profileSectionShortcuts,
                child: Column(
                  children: [
                    if (signedIn) ...[
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(
                          Icons.devices_other_outlined,
                          color: colorScheme.primary,
                        ),
                        title: Text(l10n.authSessionsAction),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.pushNamed(RouteNames.authSessions),
                      ),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(
                          Icons.logout_rounded,
                          color: colorScheme.primary,
                        ),
                        title: Text(l10n.authSignOutAction),
                        onTap: authController.busy ? null : authController.signOut,
                      ),
                    ] else
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(
                          Icons.login_rounded,
                          color: colorScheme.primary,
                        ),
                        title: Text(l10n.authSignInAction),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.pushNamed(RouteNames.authSignIn),
                      ),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      leading: Icon(
                        Icons.favorite_border_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text(l10n.favoritesTitle),
                      subtitle: Text(
                        l10n.profileFavoritesSavedCount(favoriteCount),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.pushNamed(RouteNames.favorites),
                    ),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      leading: Icon(
                        Icons.receipt_long_outlined,
                        color: colorScheme.primary,
                      ),
                      title: Text(l10n.demoOrdersTitle),
                      subtitle: Text(
                        l10n.profileDemoOrdersSavedCount(demoOrderCount),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.pushNamed(RouteNames.demoOrders),
                    ),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      leading: Icon(
                        Icons.storefront_outlined,
                        color: colorScheme.primary,
                      ),
                      title: Text(l10n.businessCenterTitle),
                      subtitle: Text(l10n.profileBusinessCenterSubtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.pushNamed(RouteNames.businessCenter),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ProfileSettingsCard(
                title: l10n.profileSectionAppearance,
                child: Column(
                  children: [
                    _ThemeModeTile(
                      label: l10n.profileThemeSystem,
                      mode: ThemeMode.system,
                      groupValue: themeController.themeMode,
                      onSelect: themeController.setThemeMode,
                    ),
                    _ThemeModeTile(
                      label: l10n.profileThemeLight,
                      mode: ThemeMode.light,
                      groupValue: themeController.themeMode,
                      onSelect: themeController.setThemeMode,
                    ),
                    _ThemeModeTile(
                      label: l10n.profileThemeDark,
                      mode: ThemeMode.dark,
                      groupValue: themeController.themeMode,
                      onSelect: themeController.setThemeMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ProfileSettingsCard(
                title: l10n.profileSectionLanguage,
                child: Column(
                  children: [
                    _LocaleTile(
                      label: l10n.profileLanguageSystem,
                      value: null,
                      groupValue: localeController.locale,
                      onSelect: (value) => _onLocaleSelected(value),
                    ),
                    _LocaleTile(
                      label: l10n.profileLanguageUz,
                      value: const Locale('uz'),
                      groupValue: localeController.locale,
                      onSelect: (value) => _onLocaleSelected(value),
                    ),
                    _LocaleTile(
                      label: l10n.profileLanguageRu,
                      value: const Locale('ru'),
                      groupValue: localeController.locale,
                      onSelect: (value) => _onLocaleSelected(value),
                    ),
                    _LocaleTile(
                      label: l10n.profileLanguageEn,
                      value: const Locale('en'),
                      groupValue: localeController.locale,
                      onSelect: (value) => _onLocaleSelected(value),
                    ),
                    if (signedIn &&
                        userProfileController.preferencesSaveFailure != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: AppMessageBanner(
                          message: localizedUserProfileFailure(
                            l10n,
                            userProfileController.preferencesSaveFailure!,
                          ),
                          icon: Icons.error_outline,
                          tone: AppMessageTone.error,
                        ),
                      ),
                    if (signedIn &&
                        userProfileController.preferencesSaveSucceeded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: AppMessageBanner(
                          message: l10n.userProfilePreferencesSaveSuccess,
                          icon: Icons.check_circle_outline,
                          tone: AppMessageTone.info,
                        ),
                      ),
                  ],
                ),
              ),
              if (signedIn) ...[
                const SizedBox(height: 12),
                _ProfileSettingsCard(
                  title: l10n.userProfileSectionPersonalization,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(l10n.userProfilePersonalizationTitle),
                        subtitle: Text(
                          l10n.userProfilePersonalizationBody,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        value: userProfileController
                                .preferences?.personalizationEnabled ??
                            false,
                        onChanged: userProfileController.savingPreferences ||
                                userProfileController.loading
                            ? null
                            : userProfileController.setPersonalizationEnabled,
                      ),
                      if (userProfileController.savingPreferences)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Text(
                            l10n.userProfileSaving,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _ProfileSettingsCard(
                title: l10n.profileAboutTitle,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.homeSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.profileAboutGuestNote,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _onLocaleSelected(Locale? value) {
    if (value == null) {
      localeController.setLocale(null);
      return;
    }
    if (authController.isSignedIn) {
      final code = PreferredLanguageCode.tryParse(value.languageCode);
      if (code != null) {
        userProfileController.updatePreferredLanguage(code);
        return;
      }
    }
    localeController.setLocale(value);
  }

  Future<void> _showEditDisplayNameDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: userProfileController.profile?.displayName ?? '',
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.userProfileEditDisplayNameAction),
          content: TextField(
            controller: controller,
            maxLength: 64,
            decoration: InputDecoration(
              labelText: l10n.userProfileDisplayNameHint,
            ),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => Navigator.of(context).pop(true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.userProfileCancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.userProfileSaveAction),
            ),
          ],
        );
      },
    );
    if (saved == true && context.mounted) {
      await userProfileController.updateDisplayName(controller.text);
    }
    controller.dispose();
  }
}

class _ProfileSettingsCard extends StatelessWidget {
  const _ProfileSettingsCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          child,
        ],
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.label,
    required this.mode,
    required this.groupValue,
    required this.onSelect,
  });

  final String label;
  final ThemeMode mode;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(label),
      value: mode,
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) {
          onSelect(value);
        }
      },
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelect,
  });

  final String label;
  final Locale? value;
  final Locale? groupValue;
  final ValueChanged<Locale?> onSelect;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<Locale?>(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: (selected) => onSelect(selected),
    );
  }
}
