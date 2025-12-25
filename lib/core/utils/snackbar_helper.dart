import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_colors.dart';

/// Snackbar helper - tepadan chiqadigan snackbar'lar uchun
class SnackbarHelper {
  SnackbarHelper._();

  /// Umumiy helper funksiya - tepadan chiqadigan snackbar
  static void _showTopSnackbar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    // Context mounted ekanligini tekshirish
    if (!context.mounted) {
      return;
    }

    final mediaQuery = MediaQuery.of(context);
    final safeAreaTop = mediaQuery.padding.top;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Theme-aware shadow color
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.25);

    overlayEntry = OverlayEntry(
      builder: (context) {
        // Context mounted ekanligini tekshirish
        if (!context.mounted) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: safeAreaTop + 10,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: isDark ? 12 : 10,
                            spreadRadius: isDark ? 1 : 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          if (action != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextButton(
                                onPressed: () {
                                  if (overlayEntry.mounted) {
                                    overlayEntry.remove();
                                  }
                                  action.onPressed();
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  action.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextButton(
                                onPressed: () {
                                  if (overlayEntry.mounted) {
                                    overlayEntry.remove();
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'common.close'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    // Auto-hide after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });

    // Context unmounted bo'lganda snackbar'ni olib tashlash
    // Sahifa o'zgarganda overlay entry'ni olib tashlash uchun
    // periodic tekshiruv qilamiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Context mounted ekanligini tekshirish
      if (!context.mounted) {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
        return;
      }

      // Periodic tekshiruv - context unmounted bo'lganda snackbar'ni olib tashlash
      final checkInterval = const Duration(milliseconds: 100);
      Timer.periodic(checkInterval, (timer) {
        if (!context.mounted || !overlayEntry.mounted) {
          timer.cancel();
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
          return;
        }
        // Agar duration o'tib ketgan bo'lsa, timer'ni to'xtatish
        if (timer.tick * checkInterval.inMilliseconds >=
            duration.inMilliseconds) {
          timer.cancel();
        }
      });
    });
  }

  /// Tepadan chiqadigan error snackbar
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark mode uchun yanada yorug' va kontrastli rang
    final errorColor = isDark
        ? const Color(0xFFE53935) // To'q qizil - dark mode uchun
        : const Color(0xFFDC3545); // Oddiy qizil - light mode uchun

    _showTopSnackbar(
      context,
      message,
      backgroundColor: errorColor,
      icon: Icons.error_outline_rounded,
      duration: duration,
      action: action,
    );
  }

  /// Tepadan chiqadigan success snackbar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark mode uchun yanada yorug' yashil rang
    final successColor = isDark
        ? const Color(0xFF28A745) // To'q yashil - dark mode uchun
        : const Color(0xFF34C759); // Yorug' yashil - light mode uchun

    _showTopSnackbar(
      context,
      message,
      backgroundColor: successColor,
      icon: Icons.check_circle_outline_rounded,
      duration: duration,
      action: action,
    );
  }

  /// Tepadan chiqadigan info snackbar
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark mode uchun yanada yorug' ko'k rang
    final infoColor = isDark
        ? AppColors.primaryBlue // Dark mode uchun asosiy ko'k
        : const Color(0xFF0D6EFD); // Light mode uchun yorug' ko'k

    _showTopSnackbar(
      context,
      message,
      backgroundColor: infoColor,
      icon: Icons.info_outline_rounded,
      duration: duration,
      action: action,
    );
  }

  /// Tepadan chiqadigan warning snackbar
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark mode uchun yanada yorug' sariq rang
    final warningColor = isDark
        ? const Color(0xFFFF9800) // To'q sariq - dark mode uchun
        : const Color(0xFFFFB800); // Yorug' sariq - light mode uchun

    _showTopSnackbar(
      context,
      message,
      backgroundColor: warningColor,
      icon: Icons.warning_amber_rounded,
      duration: duration,
      action: action,
    );
  }

  /// Custom snackbar - tepadan chiqadigan
  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default rang - theme-aware
    final defaultColor = backgroundColor ??
        (isDark ? const Color(0xFF424242) : const Color(0xFF6C757D));

    _showTopSnackbar(
      context,
      message,
      backgroundColor: defaultColor,
      icon: icon ?? Icons.info_outline_rounded,
      duration: duration,
      action: action,
    );
  }
}
