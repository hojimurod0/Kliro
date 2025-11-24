import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/theme/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../register/domain/usecases/get_profile.dart';
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
  bool _notificationsEnabled = false; // Notification holati

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
    // ThemeController o'zgarishlarini kuzatish
    ThemeController.instance.addListener(_onThemeChanged);
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
      return "O'zbek tili (Kiril)";
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
    if (storedUser != null) {
      // Agar ism bo'sh bo'lsa, serverdan yuklashga harakat qilish
      if (storedUser.firstName.isEmpty || storedUser.lastName.isEmpty) {
        try {
          final getProfile = ServiceLocator.resolve<GetProfile>();
          final profile = await getProfile();
          final updatedUser = AuthUser(
            firstName: profile.firstName,
            lastName: profile.lastName,
            contact: profile.email ?? profile.phone ?? storedUser.contact,
            password: storedUser.password,
            region: profile.regionName ?? storedUser.region,
          );
          await AuthService.instance.saveProfile(updatedUser);
          return updatedUser;
        } catch (e) {
          // Xatolik bo'lsa, mavjud ma'lumotlarni qaytarish
          return storedUser;
        }
      }
      return storedUser;
    }

    final activeUser = await AuthService.instance.fetchActiveUser();
    return activeUser;
  }

  Future<void> _reloadUser() async {
    setState(() {
      _userFuture = _loadUser();
    });
  }

  Future<void> _handleLogout() async {
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 50.h,
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text(
          tr('profile.title'),
          style: TextStyle(
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
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
                _buildDivider(),
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
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.work_outline,
                  title: tr('profile.my_bookings'),
                  trailingWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBookingBadge(count: 12),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    context.router.push(const MyOrdersRoute());
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.nightlight_round,
                  title: tr('profile.appearance'),
                  trailingText: _getThemeModeText(),
                  onTap: () {
                    showAppearanceModal(context);
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.language,
                  title: tr('profile.language'),
                  trailingText: _getLanguageText(),
                  onTap: () {
                    showLanguageModal(context);
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.security,
                  title: tr('profile.security'),
                  onTap: () {
                    context.router.push(const SecurityRoute());
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.headset_mic_outlined,
                  title: tr('profile.support'),
                  onTap: () {
                    context.router.push(const SupportRoute());
                  },
                ),
                _buildDivider(),
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
          style: AppTypography.bodyPrimary.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          tr('profile.login_section.subtitle'),
          style: AppTypography.bodyPrimary.copyWith(
            color: Colors.grey.shade600,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.router.push(const LoginRoute()),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primaryBlue, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        minimumSize: Size(0, 36.h),
      ),
      child: Text(
        tr('profile.login_section.login'),
        style: AppTypography.bodyPrimary.copyWith(
          color: AppColors.primaryBlue,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.router.push(const RegisterRoute()),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        minimumSize: Size(0, 36.h),
      ),
      child: Text(
        tr('profile.login_section.register'),
        style: AppTypography.bodyPrimary.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
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
            Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
            SizedBox(height: 12.h),
            Text(
              tr('profile.error_loading'),
              style: AppTypography.bodyPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              '$error',
              style: AppTypography.caption,
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
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Text(
              user.initials,
              style: AppTypography.headingL.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18.sp,
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
                  style: AppTypography.headingL.copyWith(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                if (user.fullName.isNotEmpty && user.contact.isNotEmpty)
                  Text(
                    user.contact,
                    style: AppTypography.bodyPrimary.copyWith(
                      color: Theme.of(context).colorScheme.primary,
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
        style: AppTypography.bodyPrimary.copyWith(
          color:
              Theme.of(context).textTheme.bodySmall?.color ??
              Colors.grey.shade600,
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
                style: AppTypography.bodyPrimary.copyWith(
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black87,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: AppTypography.bodyPrimary.copyWith(
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.grey.shade500,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (trailingWidget != null) trailingWidget,
            if (shouldShowChevron)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).iconTheme.color ?? Colors.grey,
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
        style: AppTypography.bodyPrimary.copyWith(
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
          style: AppTypography.bodyPrimary.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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

  Widget _buildDivider() => Divider(
    height: 18.h,
    thickness: 1,
    color: AppColors.divider,
    indent: 16.w,
    endIndent: 16.w,
  );
}
