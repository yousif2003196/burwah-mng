import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/complaint_details_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/common/boss_state_views.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_common.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_decision_dialog.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_details_sections.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/summon_supervisor_sheet.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/unban_investigation_sheet.dart';

/// تفاصيل التظلم والفحص الآلي: `GET complaints/{id}/details`
/// + الإجراءات (استدعاء / فك حظر وتحقيق / قرار إداري).
///
/// عند نجاح أي إجراء ترجع الشاشة رسالة الخادم للقائمة لتحدّث نفسها.
class HeadSupervisorComplaintDetailsScreen extends StatelessWidget {
  final MerchantComplaintSummary summary;

  const HeadSupervisorComplaintDetailsScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ComplaintDetailsCubit>()..load(summary.id),
      child: _ComplaintDetailsView(summary: summary),
    );
  }
}

class _ComplaintDetailsView extends StatelessWidget {
  final MerchantComplaintSummary summary;

  const _ComplaintDetailsView({required this.summary});

  Future<void> _summon(
    BuildContext context,
    MerchantComplaintDetails details,
  ) async {
    final result = await showSummonSupervisorSheet(context, details);
    if (result == null || !context.mounted) return;
    // TODO(backend): الرد يرجع chatSessionId، لكن لا يوجد endpoint/شاشة
    // لفتح محادثة BossOfSupervisor بهذا المعرّف. نعرض المعرّف فقط حاليًا.
    final session = result.chatSessionId.isEmpty
        ? ''
        : ' (${result.chatSessionId})';
    Navigator.of(context).pop('${result.message}$session');
  }

  Future<void> _unban(
    BuildContext context,
    MerchantComplaintDetails details,
  ) async {
    final message = await showUnbanInvestigationSheet(context, details);
    if (message == null || !context.mounted) return;
    Navigator.of(context).pop(message);
  }

  Future<void> _decide(
    BuildContext context,
    ComplaintDecisionType decisionType,
  ) async {
    final message = await showComplaintDecisionDialog(context, decisionType);
    if (message == null || !context.mounted) return;
    Navigator.of(context).pop(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(
            headSupervisorText(context,
                arabic: 'تفاصيل شكوى التاجر',
                english: 'Merchant complaint details'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const MotionIcon(Icons.arrow_back)),
      ),
      body: BlocBuilder<ComplaintDetailsCubit, ComplaintDetailsState>(
        builder: (context, state) => switch (state) {
          BossLoading() => const BossLoadingView(),
          BossLoadFailure(:final message) => BossErrorView(
              message: message,
              onRetry: context.read<ComplaintDetailsCubit>().retry,
            ),
          BossLoaded(:final data) => _buildDetails(context, data),
        },
      ),
    );
  }

  Widget _buildDetails(BuildContext context, MerchantComplaintDetails details) {
    final archived = summary.status.isFinal;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ScrollFx(child: ComplaintHeaderPanel(details: details, archived: archived)),
        const SizedBox(height: 12),
        ScrollFx(
            child: ComplaintAutomatedAuditPanel(audit: details.automatedAudit)),
        const SizedBox(height: 12),
        ScrollFx(
          child: ComplaintSupervisorStatementPanel(
              statement: details.supervisorStatement),
        ),
        const SizedBox(height: 12),
        ScrollFx(child: ComplaintEvidencesPanel(evidences: details.evidences)),
        const SizedBox(height: 14),
        if (!archived) ...[
          Text(
              headSupervisorText(context,
                  arabic: 'الإجراءات الرقابية المتاحة',
                  english: 'Available oversight actions'),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 8),
          ComplaintActionButton(
            title: headSupervisorText(context,
                arabic: 'إلغاء حظر الإعلان والتحقيق مع المشرف',
                english: 'Unblock the ad and investigate the supervisor'),
            icon: Icons.fact_check_outlined,
            busy: false,
            primary: true,
            onPressed: () => _unban(context, details),
          ),
          const SizedBox(height: 8),
          ComplaintActionButton(
            title: headSupervisorText(context,
                arabic: 'استدعاء المشرف للتوضيح',
                english: 'Summon the supervisor'),
            icon: Icons.person_search_outlined,
            busy: false,
            primary: false,
            onPressed: () => _summon(context, details),
          ),
          const SizedBox(height: 8),
          ComplaintActionButton(
            title: headSupervisorText(context,
                arabic: 'تأييد إجراء المشرف ورفض التظلم',
                english: 'Uphold the supervisor'),
            icon: Icons.verified_outlined,
            busy: false,
            primary: false,
            onPressed: () =>
                _decide(context, ComplaintDecisionType.upholdSupervisor),
          ),
          const SizedBox(height: 8),
          ComplaintActionButton(
            title: headSupervisorText(context,
                arabic: 'تصعيد للشؤون القانونية والمدير العام',
                english: 'Escalate to legal affairs and the GM'),
            icon: Icons.shield_outlined,
            busy: false,
            primary: false,
            onPressed: () =>
                _decide(context, ComplaintDecisionType.escalateLegalGm),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: 44,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style:
                TextButton.styleFrom(backgroundColor: AppColors.surfaceHighlight),
            child: Text(headSupervisorText(context,
                arabic: 'العودة إلى قائمة الشكاوى',
                english: 'Back to complaints')),
          ),
        ),
      ],
    );
  }
}
