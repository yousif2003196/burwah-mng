import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';

/// نافذة تغيير كلمة المرور (`POST api/Account/ChangePassword`).
/// ترجع true لما تتغير الكلمة فعلًا.
Future<bool> showChangePasswordDialog(BuildContext context, {required bool arabic}) async {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  String? error;
  var saving = false;
  final changed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        Future<void> submit() async {
          if (current.text.isEmpty || next.text.isEmpty) {
            setDialogState(() => error = arabic ? 'املأ كل الحقول' : 'Fill all fields');
            return;
          }
          if (next.text != confirm.text) {
            setDialogState(() => error = arabic ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match');
            return;
          }
          if (next.text == current.text) {
            setDialogState(() => error = arabic
                ? 'كلمة المرور الجديدة يجب أن تختلف عن الحالية'
                : 'New password must differ from the current one');
            return;
          }
          setDialogState(() {
            saving = true;
            error = null;
          });
          try {
            await sl<ApiConsumer>(instanceName: 'berwah').post<Object>(
              ApiEndpoints.accountChangePassword,
              data: {
                'currentPassword': current.text,
                'newPassword': next.text,
                'confirmPassword': confirm.text,
              },
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext, true);
          } on DioException catch (e) {
            final data = e.response?.data;
            final message = data is Map ? '${data['message'] ?? ''}' : '';
            setDialogState(() {
              saving = false;
              error = message.isEmpty
                  ? (arabic ? 'تعذر تغيير كلمة المرور' : 'Could not change the password')
                  : message;
            });
          }
        }

        Widget field(TextEditingController c, String label) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: c,
                obscureText: true,
                decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
              ),
            );

        return AlertDialog(
          title: Text(arabic ? 'تغيير كلمة المرور' : 'Change password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(current, arabic ? 'كلمة المرور الحالية' : 'Current password'),
                field(next, arabic ? 'كلمة المرور الجديدة' : 'New password'),
                field(confirm, arabic ? 'تأكيد كلمة المرور' : 'Confirm password'),
                if (error != null)
                  Text(error!, style: TextStyle(color: AppColors.danger, fontSize: 12)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext, false),
              child: Text(arabic ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: saving ? null : submit,
              child: saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(arabic ? 'حفظ' : 'Save'),
            ),
          ],
        );
      },
    ),
  );
  current.dispose();
  next.dispose();
  confirm.dispose();
  return changed == true;
}
