import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/head_escalations_cubits.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/escalations/head_escalation_note_dialog.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/escalations/head_escalations_panel_frame.dart';

/// شكاوى المنتجات المستعملة اللي رفعها مشرف وصلني للرئيس
/// (`GET api/SupervisorUsed/complaint-escalations`). الرئيس يحسم الشكوى
/// (`POST complaints/{id}/resolve`) فتتقفل وتختفي من القائمة.
class HeadUsedComplaintEscalationsPanel extends StatelessWidget {
  const HeadUsedComplaintEscalationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HeadUsedComplaintEscalationsCubit>()..load(),
      child: const HeadEscalationsAutoRefresh<HeadUsedComplaintEscalationsCubit>(
        liveType: 'used_complaint_escalation',
        child: _UsedComplaintEscalationsView(),
      ),
    );
  }
}

class _UsedComplaintEscalationsView extends StatelessWidget {
  const _UsedComplaintEscalationsView();

  Future<void> _resolve(
    BuildContext context,
    HeadUsedComplaintEscalation e,
  ) async {
    final cubit = context.read<HeadUsedComplaintEscalationsCubit>();
    final note = await askHeadEscalationNote(
      context,
      title: 'قرارك في الشكوى',
      hint: 'اكتب القرار / الملاحظة',
      confirmLabel: 'حسم الشكوى',
      minLength: 5,
    );
    if (note == null || !context.mounted) return;
    final outcome = await cubit.resolve(e.complaintId, note);
    if (!context.mounted) return;
    showHeadEscalationOutcome(
      context,
      outcome,
      done: 'تم حسم الشكوى #CMP-${e.complaintId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeadUsedComplaintEscalationsCubit,
        HeadEscalationsState<HeadUsedComplaintEscalation>>(
      builder: (context, state) =>
          HeadEscalationsPanelFrame<HeadUsedComplaintEscalation>(
        state: state,
        title: 'شكاوى وصلني بانتظار قرارك',
        retryLabel: 'تعذر تحميل شكاوى وصلني — إعادة المحاولة',
        onRetry: context.read<HeadUsedComplaintEscalationsCubit>().load,
        itemBuilder: (e) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#CMP-${e.complaintId} • ${e.title}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (e.buyerName.isNotEmpty) Text('صاحب الشكوى: ${e.buyerName}'),
            if (e.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                e.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
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
            if (state.busyId == e.complaintId)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton(
                onPressed: () => _resolve(context, e),
                child: const Text('حسم الشكوى'),
              ),
          ],
        ),
      ),
    );
  }
}
