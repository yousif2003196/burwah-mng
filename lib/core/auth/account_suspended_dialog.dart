import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// رسالة "حسابك معلّق من قبل المدير التنفيذي" ومعاها رسالة المدير التنفيذي.
Future<void> showAccountSuspendedDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        icon: Icon(Icons.pause_circle_outline, size: 40, color: AppColors.warningDark),
        title: const Text('الحساب معلّق', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Text(
            message,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 14, height: 1.7, color: AppColors.ink),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark),
              child: const Text('حسنًا'),
            ),
          ),
        ],
      ),
    ),
  );
}
