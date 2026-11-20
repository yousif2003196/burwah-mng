import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

class BossLoadingView extends StatelessWidget {
  const BossLoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// خطأ تحميل: رسالة الخادم/الشبكة كما هي + زر إعادة المحاولة.
class BossErrorView extends StatelessWidget {
  const BossErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          MotionIcon(Icons.cloud_off_outlined, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            message.isEmpty
                ? headSupervisorText(context,
                    arabic: 'تعذر تحميل البيانات.',
                    english: 'Could not load the data.')
                : message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const MotionIcon(Icons.refresh, size: 18),
            label: Text(headSupervisorText(context,
                arabic: 'إعادة المحاولة', english: 'Retry')),
          ),
        ]),
      ),
    );
  }
}

class BossEmptyView extends StatelessWidget {
  const BossEmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Column(children: [
        MotionIcon(icon, size: 44, color: AppColors.textMuted),
        const SizedBox(height: 10),
        Text(message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ]),
    );
  }
}

/// يعرض رسالة نتيجة إجراء. رسالة الخادم تُعرض كما هي، ولو فاضية نعرض [fallback].
void showBossMessage(BuildContext context, String message, String fallback) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message.isEmpty ? fallback : message)),
  );
}
