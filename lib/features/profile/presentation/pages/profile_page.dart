import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/theme/theme_controller.dart';
import '../../../../core/utils/logger.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../register/domain/usecases/get_profile.dart';
import '../../../register/presentation/bloc/register_bloc.dart';
import '../../../register/presentation/bloc/register_event.dart';
import '../../../register/presentation/bloc/register_state.dart';
import '../widgets/appearance_modal.dart';
import '../widgets/language_modal.dart';
import '../widgets/logout_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<AuthUser?> _userFuture;
  // Notification toggle - temporarily disabled for Play Market submission
  // bool _notificationsEnabled = false; // Notification holati

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
    // ThemeController o'zgarishlarini kuzatish
    ThemeController.instance.addListener(_onThemeChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Page'ga kirganda yoki app ochilganda profile'ni yangilash
    // Doimiy ravishda serverdan yuklash (email va boshqa ma'lumotlar yangilanishi uchun)
    _userFuture.then((user) {
      if (user != null) {
        // Email bo'sh bo'lsa yoki page birinchi marta ochilganda yangilash
        if (user.email == null || user.email!.isEmpty) {
          AppLogger.debug(
              '📱 PROFILE_PAGE: didChangeDependencies - Email is empty, reloading...');
          _reloadUser();
        }
      }
    });
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        // Theme o'zgarganda UI yangilanadi
      });
    }
  }

  String _getThemeModeText() {
    switch (ThemeController.instance.mode) {
      case ThemeMode.light:
        return tr('light_mode');
      case ThemeMode.dark:
        return tr('dark_mode');
      case ThemeMode.system:
        return tr('system_mode');
    }
  }

  String _getLanguageText() {
    final locale = context.locale;
    if (locale.languageCode == 'uz' && locale.countryCode == 'CYR') {
      return "O'zbek (Kirill)";
    }
    if (locale.languageCode == 'uz') {
      return "O'zbekcha";
    }
    if (locale.languageCode == 'ru') {
      return "Русский";
    }
    if (locale.languageCode == 'en') {
      return "English";
    }
    return locale.toLanguageTag();
  }

  Future<AuthUser?> _loadUser() async {
    final storedUser = await AuthService.instance.getStoredUser();
    AppLogger.debug(
        '📱 PROFILE_PAGE: _loadUser - storedUser exists: ${storedUser != null}');
    if (storedUser != null) {
      AppLogger.debug(
          '📱 PROFILE_PAGE: _loadUser - storedUser.email: ${storedUser.email ?? "null"}');
      AppLogger.debug(
          '📱 PROFILE_PAGE: _loadUser - storedUser.phone: ${storedUser.phone ?? "null"}');

      // Doimiy ravishda serverdan yuklash (email va boshqa ma'lumotlar yangilanishi uchun)
      // Agar ism yoki email bo'sh bo'lsa, serverdan yuklashga harakat qilish
      final needsRefresh = storedUser.firstName.isEmpty ||
          storedUser.lastName.isEmpty ||
          (storedUser.email == null || storedUser.email!.isEmpty);

      AppLogger.debug(
          '📱 PROFILE_PAGE: _loadUser - needsRefresh: $needsRefresh');

      // Doimiy ravishda API'dan profile yuklash (email va boshqa ma'lumotlar yangilanishi uchun)
      try {
        AppLogger.debug(
            '📱 PROFILE_PAGE: _loadUser - Loading profile from API...');
        final getProfile = ServiceLocator.resolve<GetProfile>();
        final profile = await getProfile();
        AppLogger.debug('📱 PROFILE_PAGE: _loadUser - Profile loaded from API');
        AppLogger.debug(
            '📱 PROFILE_PAGE: _loadUser - Profile.email: ${profile.email ?? "null"}');
        AppLogger.debug(
            '📱 PROFILE_PAGE: _loadUser - Profile.phone: ${profile.phone ?? "null"}');
        AppLogger.debug(
            '📱 PROFILE_PAGE: _loadUser - Profile.regionName: ${profile.regionName ?? "null"}');

        final updatedUser = AuthUser(
          firstName: profile.firstName,
          lastName: profile.lastName,
          contact: profile.email ?? profile.phone ?? storedUser.contact,
          password: storedUser.password,
          region: profile.regionName ?? storedUser.region,
          email: profile.email,
          phone: profile.phone != null && profile.phone!.isNotEmpty
              ? AuthService.normalizeContact(profile.phone!)
              : null,
        );

        AppLogger.debug(
            '📱 PROFILE_PAGE: _loadUser - UpdatedUser.email: ${updatedUser.email ?? "null"}');
        AppLogger.debug(
            '📱 PROFILE_PAGE: _loadUser - UpdatedUser.phone: ${updatedUser.phone ?? "null"}');
        AppLogger.debug(
            '📱 PROFILE_PAGE: _loadUser - UpdatedUser.region: ${updatedUser.region ?? "null"}');

        await AuthService.instance.saveProfile(updatedUser);
        AppLogger.debug(
            '📱 PROFILE_PAGE: _loadUser - Profile saved successfully');
        return updatedUser;
      } catch (e) {
        AppLogger.warning(
            '📱 PROFILE_PAGE: _loadUser - Failed to load profile: $e');
        // Xatolik bo'lsa, mavjud ma'lumotlarni qaytarish
        return storedUser;
      }
    }

    AppLogger.debug(
        '📱 PROFILE_PAGE: _loadUser - No storedUser, fetching activeUser');
    final activeUser = await AuthService.instance.fetchActiveUser();
    return activeUser;
  }

  Future<void> _reloadUser() async {
    setState(() {
      _userFuture = _loadUser();
    });
  }

  Future<int> _getBookingsCount() async {
    try {
      // Hozircha 0 qaytaramiz, keyin API dan haqiqiy sonni olish mumkin
      // TODO: API dan bronlar sonini olish
      return 0;
    } catch (e) {
      AppLogger.warning('📱 PROFILE_PAGE: _getBookingsCount - Error: $e');
      return 0;
    }
  }

  void _handleMyOrdersTap(BuildContext context) {
    _showComingSoonDialog(context);
  }

  void _showComingSoonDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'common.coming_soon_title'.tr(),
          style: AppTypography.headingL(context).copyWith(
            fontSize: 20.sp,
          ),
        ),
        content: Text(
          'common.coming_soon_message'.tr(),
          style: AppTypography.bodyPrimary(context).copyWith(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            child: Text(
              'common.close'.tr(),
              style: AppTypography.buttonPrimary(context).copyWith(
                fontSize: 16.sp,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    // API orqali logout qilish
    try {
      final registerBloc = ServiceLocator.resolve<RegisterBloc>();
      registerBloc.add(const LogoutRequested());
    } catch (e) {
      // Bloc topilmasa, faqat local logout qilish
      // Ignore error - local logout will still work
    }

    // Local logout ham qilish
    await AuthService.instance.logout();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('profile.logout_success')),
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
    await _reloadUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.resolve<RegisterBloc>(),
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.failure &&
              state.flow == RegisterFlow.logout) {
            // Logout xatolik bo'lsa ham local logout qilish
            AuthService.instance.logout();
          }
        },
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                toolbarHeight: 50.h,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                centerTitle: true,
                scrolledUnderElevation: 0,
                title: Text(
                  tr('profile.title'),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color ??
                        (isDark ? AppColors.white : AppColors.black),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: FutureBuilder<AuthUser?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error);
              }

              final user = snapshot.data;
              return _buildProfileContent(context, user);
            },
          ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthUser? user) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (user == null) _buildCompactLoginSection(context),
          if (user == null) SizedBox(height: 18.h),
          if (user != null) _buildUserInfoCard(user),
          if (user != null) SizedBox(height: 18.h),
          _buildSectionHeader(tr('profile.account_info')),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                _buildSettingItem(
                  icon: Icons.person_outline,
                  title: tr('profile.edit_profile'),
                  onTap: user != null
                      ? () => context.router.push(const ProfileEditRoute())
                      : () => context.router.push(const LoginRoute()),
                ),
                // Notification toggle - temporarily disabled for Play Market submission
                // TODO: Implement backend API integration before enabling
                /*
                _buildSettingItem(
                  icon: Icons.notifications_outlined,
                  title: tr('profile.notifications'),
                  trailingWidget: Transform.scale(
                    scale: 0.7,
                    child: SizedBox(
                      height: 18.h,
                      child: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                        inactiveThumbColor: Theme.of(context).cardColor,
                        inactiveTrackColor: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _notificationsEnabled = !_notificationsEnabled;
                    });
                  },
                ),
                */
                _buildSettingItem(
                  icon: Icons.work_outline,
                  title: tr('profile.my_bookings'),
                  trailingWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder<int>(
                        future: _getBookingsCount(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          if (count > 0) {
                            return _buildBookingBadge(count: count);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      Icon(
                        Icons.chevron_right, 
                        color: Theme.of(context).iconTheme.color ?? AppColors.grayText,
                      ),
                    ],
                  ),
                  onTap: () => _handleMyOrdersTap(context),
                ),
                _buildSettingItem(
                  icon: Icons.nightlight_round,
                  title: tr('profile.appearance'),
                  trailingText: _getThemeModeText(),
                  onTap: () {
                    showAppearanceModal(context);
                  },
                ),
                _buildSettingItem(
                  icon: Icons.language,
                  title: tr('profile.language'),
                  trailingText: _getLanguageText(),
                  onTap: () async {
                    await showLanguageModal(context);
                    // Locale o'zgarganda UI ni yangilash
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                _buildSettingItem(
                  icon: Icons.security,
                  title: tr('profile.security'),
                  onTap: () {
                    context.router.push(const SecurityRoute());
                  },
                ),
                _buildSettingItem(
                  icon: Icons.headset_mic_outlined,
                  title: tr('profile.support'),
                  onTap: () => _showComingSoonDialog(context),
                ),
                _buildSettingItem(
                  icon: Icons.info_outline,
                  title: tr('profile.about_app'),
                  onTap: () => context.router.push(const AboutAppRoute()),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
          if (user != null) ...[
            SizedBox(height: 18.h),
            _buildLogoutButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactLoginSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isStackedLayout = constraints.maxWidth < 400;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: isStackedLayout
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: AppColors.primaryBlue,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildLoginSectionTexts(context)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(child: _buildLoginButton(context)),
                        SizedBox(width: 8.w),
                        Expanded(child: _buildRegisterButton(context)),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildLoginSectionTexts(context)),
                    SizedBox(width: 8.w),
                    _buildLoginButton(context),
                    SizedBox(width: 8.w),
                    _buildRegisterButton(context),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLoginSectionTexts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tr('profile.login_section.title'),
          style: AppTypography.bodyPrimary(context).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          tr('profile.login_section.subtitle'),
          style: AppTypography.bodyPrimary(context).copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grayText,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primaryBlue,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.router.push(const LoginRoute()),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            constraints: BoxConstraints(minHeight: 36.h),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tr('profile.login_section.login'),
                style: AppTypography.bodyPrimary(context).copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightBlue, AppColors.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.white.withOpacity(0.3), 
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.router.push(const RegisterRoute()),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            constraints: BoxConstraints(minHeight: 36.h),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tr('profile.login_section.register'),
                style: AppTypography.bodyPrimary(context).copyWith(
                  color: AppColors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline, 
              color: AppColors.dangerRed, 
              size: 40.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              tr('profile.error_loading'),
              style: AppTypography.bodyPrimary(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              '$error',
              style: AppTypography.caption(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _reloadUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(tr('profile.retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(AuthUser user) {
    final displayName = user.fullName.isNotEmpty
        ? user.fullName
        : user.contact.isNotEmpty
            ? user.contact
            : tr('profile.user');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 50.w,
            height: 50.w,
            child: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                user.initials,
                style: AppTypography.headingL(context).copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTypography.headingL(context).copyWith(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                if (user.email != null && user.email!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            user.email!,
                            style: AppTypography.bodyPrimary(context).copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (user.phone != null && user.phone!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            user.phone!,
                            style: AppTypography.bodyPrimary(context).copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if ((user.email == null || user.email!.isEmpty) &&
                    (user.phone == null || user.phone!.isEmpty) &&
                    user.contact.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      user.contact,
                      style: AppTypography.bodyPrimary(context).copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 5.h),
      child: Text(
        title,
        style: AppTypography.bodyPrimary(context).copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color ??
              AppColors.grayText,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailingWidget,
    String? trailingText,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool shouldShowChevron =
        showArrow && trailingWidget == null && trailingText == null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.2),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyPrimary(context).copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      (isDark ? AppColors.white : AppColors.black),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: AppTypography.bodyPrimary(context).copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      AppColors.grayText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (trailingWidget != null) trailingWidget,
            if (shouldShowChevron)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).iconTheme.color ?? AppColors.grayText,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingBadge({required int count}) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        count.toString(),
        style: AppTypography.bodyPrimary(context).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton.icon(
        onPressed: () {
          showLogoutDialog(context, _handleLogout);
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          tr('profile.logout'),
          style: AppTypography.bodyPrimary(context).copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dangerRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
