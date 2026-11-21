import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/head_escalations_cubits.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/escalations/head_escalation_note_dialog.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/escalations/head_escalations_panel_frame.dart';

/// Service providers the services supervisor sent to the head
/// (`GET provider-escalations`). The head suspends the provider or closes
/// the escalation without changing the provider.
class HeadProviderEscalationsPanel extends StatelessWidget {
  const HeadProviderEscalationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HeadProviderEscalationsCubit>()..load(),
      child: const HeadEscalationsAutoRefresh<HeadProviderEscalationsCubit>(
        liveType: 'provider_escalation',
        child: _ProviderEscalationsView(),
      ),
    );
  }
}

class _ProviderEscalationsView extends StatelessWidget {
  const _ProviderEscalationsView();

  Future<void> _suspend(BuildContext context, HeadProviderEscalation e) async {
    final cubit = context.read<HeadProviderEscalationsCubit>();
    final reason = await askHeadEscalationNote(
      context,
      title: 'سبب إيقاف المزود ${e.name}',
      minLength: 5,
    );
    if (reason == null || !context.mounted) return;
    final outcome = await cubit.suspend(e.providerId, reason);
    if (!context.mounted) return;
    showHeadEscalationOutcome(context, outcome, done: 'تم إيقاف المزود ${e.name}');
  }

  Future<void> _close(BuildContext context, HeadProviderEscalation e) async {
    final cubit = context.read<HeadProviderEscalationsCubit>();
    final note = await askHeadEscalationNote(
      context,
      title: 'ملاحظة (اختياري)',
      required: false,
    );
    if (note == null || !context.mounted) return;
    final outcome = await cubit.closeWithoutAction(e.providerId, note);
    if (!context.mounted) return;
    showHeadEscalationOutcome(context, outcome, done: 'تم إغلاق التصعيد');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeadProviderEscalationsCubit,
        HeadEscalationsState<HeadProviderEscalation>>(
      builder: (context, state) => HeadEscalationsPanelFrame<HeadProviderEscalation>(
        state: state,
        title: 'مزودون بانتظار قرارك',
        retryLabel: 'تعذر تحميل تصعيدات المزودين — إعادة المحاولة',
        onRetry: context.read<HeadProviderEscalationsCubit>().load,
        itemBuilder: (e) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#PRV-${e.providerId} • ${e.name}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (e.businessType.isNotEmpty) Text(e.businessType),
            const SizedBox(height: 6),
            Text(
              'سبب الرفع: ${e.reason.isEmpty ? '—' : e.reason}',
              style: TextStyle(color: AppColors.dangerDark, fontSize: 12),
            ),
            if (e.supervisorName.isNotEmpty)
              Text(
                'المشرف: ${e.supervisorName}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            const SizedBox(height: 10),
            if (state.busyId == e.providerId)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => _suspend(context, e),
                    child: const Text('إيقاف المزود'),
                  ),
                  OutlinedButton(
                    onPressed: () => _close(context, e),
                    child: const Text('إغلاق بدون إجراء'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
