import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Snackbar helper - tepadan chiqadigan snackbar'lar uchun
class SnackbarHelper {
  SnackbarHelper._();

  /// Umumiy helper funksiya - tepadan chiqadigan snackbar
  static OverlayEntry? _currentEntry;
  static Timer? _currentTimer;

  static void _closeCurrentSnackbar() {
    if (_currentEntry?.mounted ?? false) {
      _currentEntry?.remove();
    }
    _currentTimer?.cancel();
    _currentEntry = null;
    _currentTimer = null;
  }

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

    // Remove existing snackbar if acts
    _closeCurrentSnackbar();

    final mediaQuery = MediaQuery.of(context);
    final safeAreaTop = mediaQuery.padding.top;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Theme-aware shadow color
    final shadowColor =
        AppColors.black.withOpacity(isDark ? 0.5 : 0.25);

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
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack, // Bouncy effect for "falling" feel
              builder: (context, value, child) {
                return Transform.translate(
                  // Start from -200 (fully offscreen) -> 0
                  offset: Offset(0, -200 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
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
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: AppTypography.bodyMedium(context).copyWith(
                                color: AppColors.white,
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
                                  _closeCurrentSnackbar();
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
                                      AppColors.white.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  action.label,
                                  style: AppTypography.bodyPrimary(context).copyWith(
                                    color: AppColors.white,
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
                                 _closeCurrentSnackbar();
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
                                      AppColors.white.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'common.close'.tr(),
                                  style: AppTypography.bodyPrimary(context).copyWith(
                                    color: AppColors.white,
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

    _currentEntry = overlayEntry;
    overlay.insert(overlayEntry);

    // Auto-hide after duration (using safe timer handling)
    _currentTimer = Timer(duration, () {
      _closeCurrentSnackbar();
    });

    // Handle context unmounting safety purely via Flutter Widget lifecycle if possible,
    // but since this is overlapping, we keep a simple check.
    // The previous aggressive periodic timer is removed as it might be overkill/glitchy.
  }

  /// Tepadan chiqadigan error snackbar
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark mode uchun yanada yorug' va kontrastli rang - qizil
    final errorColor = isDark
        ? AppColors.errorRedDark // To'q qizil - dark mode uchun
        : AppColors.errorRedLight; // Yorug' qizil - light mode uchun

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
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark mode uchun yanada yorug' yashil rang
    final successColor = isDark
        ? AppColors.successGreenDark // To'q yashil - dark mode uchun
        : AppColors.successGreenLight; // Yorug' yashil - light mode uchun

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
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark mode uchun yanada yorug' ko'k rang
    final infoColor = isDark
        ? AppColors.primaryBlue // Dark mode uchun asosiy ko'k
        : AppColors.infoBlueLight; // Light mode uchun yorug' ko'k

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
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark mode uchun yanada yorug' sariq rang
    final warningColor = isDark
        ? AppColors.orangeWarning // To'q sariq - dark mode uchun
        : AppColors.warningOrangeLight; // Yorug' sariq - light mode uchun

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
        (isDark ? AppColors.defaultGrayDark : AppColors.defaultGrayLight);

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
