import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/head_escalations_cubits.dart';

/// يحدّث لوحة التصعيدات كل 45 ثانية وعند وصول إشعار لحظي من النوع [liveType].
class HeadEscalationsAutoRefresh<C extends HeadEscalationsCubit<Object?>>
    extends StatefulWidget {
  const HeadEscalationsAutoRefresh({
    super.key,
    required this.liveType,
    required this.child,
  });

  final String liveType;
  final Widget child;

  @override
  State<HeadEscalationsAutoRefresh<C>> createState() =>
      _HeadEscalationsAutoRefreshState<C>();
}

class _HeadEscalationsAutoRefreshState<
        C extends HeadEscalationsCubit<Object?>>
    extends State<HeadEscalationsAutoRefresh<C>> {
  Timer? _timer;
  StreamSubscription<dynamic>? _live;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<C>();
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => cubit.load());
    _live = RealtimeHub.instance.notifications
        .where((n) => n.type == widget.liveType)
        .listen((_) => cubit.load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _live?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// عنوان + بطاقات لوحة تصعيد (نفس شكل اللوحات السابقة).
class HeadEscalationsPanelFrame<T> extends StatelessWidget {
  const HeadEscalationsPanelFrame({
    super.key,
    required this.state,
    required this.title,
    required this.retryLabel,
    required this.onRetry,
    required this.itemBuilder,
  });

  final HeadEscalationsState<T> state;
  final String title;
  final String retryLabel;
  final VoidCallback onRetry;
  final Widget Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (state.loading) return const SizedBox.shrink();
    if (state.failed) {
      return TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(retryLabel),
      );
    }
    if (state.items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${state.items.length})',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in state.items) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: itemBuilder(item),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// يعرض نتيجة قرار على تصعيد: رسالة نجاح أو رسالة الخادم/العامة عند الفشل.
void showHeadEscalationOutcome(
  BuildContext context,
  BossActionResult<void> outcome, {
  required String done,
}) {
  if (!context.mounted) return;
  if (outcome.success) {
    AppSnackBar.showSuccess(context, done);
  } else {
    AppSnackBar.showError(
      context,
      outcome.message.isEmpty
          ? 'تعذر تنفيذ القرار، حاول مرة أخرى.'
          : outcome.message,
    );
  }
}
