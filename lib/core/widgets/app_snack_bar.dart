import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/theme/app_colors.dart';

class AppSnackBar {
  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionTap,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.success,
      borderColor: AppColors.successBorder,
      icon: Icons.check_circle_outline_rounded,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionTap,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.info,
      borderColor: AppColors.infoBorder,
      icon: Icons.info_outline_rounded,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionTap,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.warning,
      borderColor: AppColors.warningBorder,
      icon: Icons.warning_amber_rounded,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionTap,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.danger,
      borderColor: AppColors.dangerBorder,
      icon: Icons.error_outline_rounded,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
      duration: duration,
    );
  }

  static void showCustom(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color borderColor,
    IconData icon = Icons.notifications_none_rounded,
    String? actionLabel,
    VoidCallback? onActionTap,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      icon: icon,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onActionTap,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: MotionIcon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 1.2),
          borderRadius: BorderRadius.circular(14),
        ),
        action: actionLabel == null || onActionTap == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onActionTap,
              ),
      ),
    );
  }
}
