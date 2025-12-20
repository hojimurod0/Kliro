import 'package:flutter/material.dart';

/// Custom ScaffoldMessengerState that automatically positions all snackbars at the top
class TopSnackbarMessengerState extends ScaffoldMessengerState {
  @override
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    SnackBar snackBar, {
    AnimationStyle? snackBarAnimationStyle,
  }) {
    // Modify snackbar to show from top if not already positioned
    final modifiedSnackBar = _modifySnackBarForTop(snackBar);
    return super.showSnackBar(
      modifiedSnackBar,
      snackBarAnimationStyle: snackBarAnimationStyle,
    );
  }

  SnackBar _modifySnackBarForTop(SnackBar original) {
    // If already positioned at top (has top margin > 0), return as is
    if (original.behavior == SnackBarBehavior.floating &&
        original.margin != null) {
      final margin = original.margin!;
      if (margin is EdgeInsets && margin.top > 0 && margin.bottom == 0) {
        // Already positioned at top, don't modify
        return original;
      }
    }

    // Get safe area top padding
    final mediaQuery = MediaQuery.of(context);
    final safeAreaTop = mediaQuery.padding.top;

    // Extract existing margin values if available
    double left = 16;
    double right = 16;
    if (original.margin != null && original.margin is EdgeInsets) {
      final margin = original.margin as EdgeInsets;
      left = margin.left;
      right = margin.right;
    }

    // Create new snackbar positioned at top
    // Always convert to floating behavior with top margin
    return SnackBar(
      content: original.content,
      backgroundColor: original.backgroundColor,
      duration: original.duration,
      action: original.action,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        top: safeAreaTop + 8,
        left: left,
        right: right,
        bottom: 0,
      ),
      shape: original.shape,
      elevation: original.elevation,
      width: original.width,
      padding: original.padding,
      dismissDirection: original.dismissDirection,
      clipBehavior: original.clipBehavior,
      onVisible: original.onVisible,
      animation: original.animation,
    );
  }
}

/// Custom ScaffoldMessenger that uses TopSnackbarMessengerState
class TopSnackbarMessenger extends ScaffoldMessenger {
  const TopSnackbarMessenger({
    super.key,
    required super.child,
  });

  @override
  ScaffoldMessengerState createState() => TopSnackbarMessengerState();
}
