import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils/logger.dart';

class GoogleOAuthWebViewPage extends StatefulWidget {
  final String initialUrl;

  const GoogleOAuthWebViewPage({
    super.key,
    required this.initialUrl,
  });

  @override
  State<GoogleOAuthWebViewPage> createState() => _GoogleOAuthWebViewPageState();
}

class _GoogleOAuthWebViewPageState extends State<GoogleOAuthWebViewPage>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  String? _errorMessage;
  bool _browserOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openChromeCustomTab();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // App resumed bo'lsa (browser'dan qaytgan bo'lishi mumkin)
    if (state == AppLifecycleState.resumed && _browserOpened) {
      if (kDebugMode) {
        AppLogger.debug(
            '🔄 App resumed - callback URL tekshirilishi kerak (deeplink service handle qiladi)');
      }

      // Deeplink service allaqachon callback'ni handle qiladi
      // Bu yerda faqat foydalanuvchiga xabar beramiz
      if (mounted) {
        // Agar sahifa hali ochiq bo'lsa, yopamiz (callback deeplink service tomonidan handle qilingan)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  Future<void> _openChromeCustomTab() async {
    try {
      final uri = Uri.parse(widget.initialUrl);

      AppLogger.debug('🌐 Opening Chrome Custom Tab: ${widget.initialUrl}');

      // Chrome Custom Tabs orqali ochish (Google OAuth uchun talab qilinadi)
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Chrome Custom Tabs ishlatadi
      );

      if (launched) {
        AppLogger.debug('✅ Chrome Custom Tab opened successfully');
        _browserOpened = true;
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        // Debug: Browser ochilganidan keyin callback URL'ni kutamiz
        if (kDebugMode) {
          AppLogger.debug(
            '📱 Browser ochildi. Callback URL qaytganda deeplink service avtomatik handle qiladi.\n'
            '   Callback URL: ${ApiPaths.googleCallbackUrl}\n'
            '   Kutish: User Google\'da login bo\'ladi, keyin app\'ga qaytadi',
          );
        }
      } else {
        AppLogger.error(
          'Failed to open Chrome Custom Tab',
          'Could not launch URL',
          StackTrace.current,
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'URL ochib bo\'lmadi';
          });
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error opening Chrome Custom Tab',
        e.toString(),
        stackTrace,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Xatolik: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('auth.common.google'.tr()),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
        ],
      ),
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppColors.dangerRed,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Xatolik yuz berdi',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      _errorMessage ?? 'Noma\'lum xatolik',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? AppColors.grayText : AppColors.bodyText,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      _openChromeCustomTab();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    )
                  else
                    Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 64.sp,
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Google sign-in sahifasi ochildi',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.white : AppColors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Brauzerda Google hisobingiz bilan kiring.\nCallback URL avtomatik ravishda qayta ishlanadi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.grayText
                                : AppColors.bodyText,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
