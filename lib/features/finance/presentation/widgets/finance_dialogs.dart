import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/currency_formatter.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class FinanceDialogs {
  const FinanceDialogs._();

  /// 1. نافذة تأكيد الاعتماد وإرسال الطلب للإدارة
  static Future<bool> showApprovalDialog(
    BuildContext context, {
    required String title,
    required String description,
    String? confirmText,
  }) async {
    final isArabic = AppLocaleController.instance.isArabic;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            MotionIcon(Icons.check_circle_outline, color: AppColors.success, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmText ?? (isArabic ? 'تأكيد وإرسال للإدارة' : 'Approve & Send to Admin'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 2. نافذة إدخال سبب الرفض ليتم إرساله لرئيس المشرفين
  static Future<String?> showRejectionDialog(
    BuildContext context, {
    String? title,
    String? hint,
    String? description,
  }) async {
    final isArabic = AppLocaleController.instance.isArabic;
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            MotionIcon(Icons.cancel_outlined, color: AppColors.danger, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title ?? (isArabic ? 'سبب رفض الطلب' : 'Rejection Reason'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description ??
                  (isArabic
                      ? 'سيتم إرسال هذا السبب إلى رئيس المشرفين لمراجعة وتدقيق الطلب المرفوض.'
                      : 'This reason will be submitted to the Head of Supervisors for audit and review.'),
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hint ?? (isArabic ? 'اكتب سبب الرفض بالتفصيل هنا...' : 'Enter rejection reason...'),
                hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(isArabic ? 'تراجع' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx, text);
              }
            },
            child: Text(
              isArabic ? 'إرسال الرفض' : 'Submit Rejection',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. نافذة تجميد الطلب مؤقتاً
  static Future<bool> showFreezeDialog(
    BuildContext context, {
    required String requestTitle,
    String? description,
  }) async {
    final isArabic = AppLocaleController.instance.isArabic;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            MotionIcon(Icons.pause_circle_outline, color: AppColors.warning, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isArabic ? 'تجميد الطلب احترازياً' : 'Precautionary Freeze',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          description ??
              (isArabic
                  ? 'هل تريد تجميد "$requestTitle" مؤقتاً ونقله إلى قائمة الأرصدة المعلقة تحت التدقيق الرقابي؟'
                  : 'Do you want to temporarily freeze "$requestTitle" and move it to the audit inspection list?'),
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isArabic ? 'تأكيد التجميد' : 'Confirm Freeze',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 4. نافذة فك التجميد وإعادة العمل للصرف
  static Future<bool> showUnfreezeDialog(
    BuildContext context, {
    required String title,
    required double amount,
  }) async {
    final isArabic = AppLocaleController.instance.isArabic;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            MotionIcon(Icons.lock_open, color: AppColors.info, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isArabic ? 'فك التجميد وإرسال أمر الصرف' : 'Unfreeze & Send Payout Order',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'سيتم فك تجميد طلب "$title" بقيمة ${CurrencyFormatter.format(amount)} وإرسال أمر الصرف فوراً إلى مستخدم الإدارة للمصادقة النهائية عليه.'
                  : 'This will unfreeze the request "$title" for ${CurrencyFormatter.format(amount)} and dispatch the payout order to Admin for final approval.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isArabic ? 'تراجع' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isArabic ? 'تأكيد وإرسال للإدارة' : 'Send to Admin',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 5. حوار عرض سجل عمليات السحب والإيداع لعميل داخل القسم التشغيلي
  static Future<void> showDepartmentTransactionsDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double availableBalance,
    required double pendingBalance,
  }) async {
    final isArabic = AppLocaleController.instance.isArabic;

    final mockOps = [
      {'type': 'deposit', 'title': isArabic ? 'إيداع مبيعات يومية' : 'Daily Sales Deposit', 'amount': 14200.0, 'date': '2026/09/28 - 11:20 ص', 'bank': 'مصرف الراجحي'},
      {'type': 'withdraw', 'title': isArabic ? 'سحب أرباح دورية' : 'Periodic Profit Withdrawal', 'amount': -8500.0, 'date': '2026/09/25 - 03:45 م', 'bank': 'الأهلي التجاري'},
      {'type': 'deposit', 'title': isArabic ? 'إيداع عربون وتأمين' : 'Escrow Deposit', 'amount': 6000.0, 'date': '2026/09/22 - 09:10 ص', 'bank': 'بنك الرياض'},
      {'type': 'withdraw', 'title': isArabic ? 'تحويل تسوية مستحقات' : 'Settlement Transfer', 'amount': -3200.0, 'date': '2026/09/18 - 01:15 م', 'bank': 'مصرف الراجحي'},
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: MotionIcon(Icons.receipt_long, color: AppColors.ink, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isArabic ? 'المتاح للسحب' : 'Available', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          CountText(CurrencyFormatter.format(availableBalance), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 28, color: AppColors.cardBorder),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isArabic ? 'الرصيد المعلق' : 'Pending', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          CountText(CurrencyFormatter.format(pendingBalance), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warning)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isArabic ? 'سجل عمليات السحب والإيداع الأخيرة:' : 'Recent Deposits & Withdrawals:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: mockOps.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final op = mockOps[index];
                    final isDeposit = op['type'] == 'deposit';
                    final amount = op['amount'] as double;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: isDeposit ? AppColors.successLight : AppColors.dangerLight,
                            child: MotionIcon(
                              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isDeposit ? AppColors.success : AppColors.danger,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(op['title'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                Text('${op['date']} • ${op['bank']}', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          CountText(
                            CurrencyFormatter.format(amount.abs()),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDeposit ? AppColors.successDark : AppColors.dangerDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إغلاق' : 'Close', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
