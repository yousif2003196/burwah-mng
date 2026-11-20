import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/head_escalations_cubits.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/escalations/head_escalation_note_dialog.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/escalations/head_escalations_panel_frame.dart';

/// Suspicious service requests the services supervisor sent to the head
/// (server status "Escalated"). The head approves, rejects or returns them.
class HeadServiceEscalationsPanel extends StatelessWidget {
  const HeadServiceEscalationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HeadServiceEscalationsCubit>()..load(),
      child: const HeadEscalationsAutoRefresh<HeadServiceEscalationsCubit>(
        liveType: 'service_escalation',
        child: _ServiceEscalationsView(),
      ),
    );
  }
}

class _ServiceEscalationsView extends StatelessWidget {
  const _ServiceEscalationsView();

  Future<void> _decide(
    BuildContext context,
    HeadServiceEscalation r,
    ServiceEscalationDecision decision, {
    String? askTitle,
    bool noteRequired = true,
    required String done,
  }) async {
    final cubit = context.read<HeadServiceEscalationsCubit>();
    var note = '';
    if (askTitle != null) {
      final answer = await askHeadEscalationNote(
        context,
        title: askTitle,
        required: noteRequired,
      );
      if (answer == null || !context.mounted) return;
      note = answer;
    }
    final outcome = await cubit.decideRequest(r.id, decision, note: note);
    if (!context.mounted) return;
    showHeadEscalationOutcome(context, outcome, done: done);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeadServiceEscalationsCubit,
        HeadEscalationsState<HeadServiceEscalation>>(
      builder: (context, state) => HeadEscalationsPanelFrame<HeadServiceEscalation>(
        state: state,
        title: 'طلبات خدمات مشبوهة بانتظار قرارك',
        retryLabel: 'تعذر تحميل الطلبات المشبوهة — إعادة المحاولة',
        onRetry: context.read<HeadServiceEscalationsCubit>().load,
        itemBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#SRV-${r.id} • ${r.subCategory}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text('العميل: ${r.client}  ${r.phone}'),
            if (r.address.isNotEmpty) Text('العنوان: ${r.address}'),
            const SizedBox(height: 4),
            Text(r.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(
              'سبب الإحالة: ${r.referralReason.isEmpty ? '—' : r.referralReason}',
              style: TextStyle(color: AppColors.dangerDark, fontSize: 12),
            ),
            const SizedBox(height: 10),
            if (state.busyId == r.id)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => _decide(
                      context,
                      r,
                      ServiceEscalationDecision.approve,
                      done: 'تم اعتماد الطلب #SRV-${r.id}',
                    ),
                    child: const Text('اعتماد'),
                  ),
                  OutlinedButton(
                    onPressed: () => _decide(
                      context,
                      r,
                      ServiceEscalationDecision.reject,
                      askTitle: 'سبب رفض الطلب #SRV-${r.id}',
                      done: 'تم رفض الطلب #SRV-${r.id}',
                    ),
                    child: const Text('رفض'),
                  ),
                  OutlinedButton(
                    onPressed: () => _decide(
                      context,
                      r,
                      ServiceEscalationDecision.returnToSupervisor,
                      askTitle: 'ملاحظة لمشرف الخدمات (اختياري)',
                      noteRequired: false,
                      done: 'أُعيد الطلب #SRV-${r.id} للمراجعة',
                    ),
                    child: const Text('إرجاع للمراجعة'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
