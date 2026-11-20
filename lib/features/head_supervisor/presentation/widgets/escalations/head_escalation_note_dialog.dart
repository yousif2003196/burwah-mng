import 'package:flutter/material.dart';

/// يطلب سببًا/ملاحظة قبل تنفيذ قرار على تصعيد. يرجع `null` عند الإلغاء.
Future<String?> askHeadEscalationNote(
  BuildContext context, {
  required String title,
  String hint = 'اكتب السبب / الملاحظة',
  String confirmLabel = 'تأكيد',
  int minLength = 1,
  bool required = true,
}) async {
  final controller = TextEditingController();
  try {
    return await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (required && text.length < minLength) return;
              Navigator.of(ctx).pop(text);
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}
