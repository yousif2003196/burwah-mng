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
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_link_widgets.dart';
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
    // الاستدعاء بيوصل للمشرف إشعار ويتسجل في سجله وسجل الشكوى.
    Navigator.of(context).pop(result.message);
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
                arabic: 'تفاصيل الشكوى',
                english: 'Complaint details'),
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

  Future<void> _closing(BuildContext context, Future<String?> sheet) async {
    final message = await sheet;
    if (message == null || !context.mounted) return;
    Navigator.of(context).pop(message);
  }

  /// إنذار التاجر/الكابتن مش بيقفل الشكوى: نعرض الرسالة ونحدّث التفاصيل.
  Future<void> _warn(BuildContext context, MerchantComplaintDetails details, String party) async {
    final captain = party == 'captain';
    final cubit = context.read<ComplaintDetailsCubit>();
    final message = await showComplaintNoteSheet(
      context,
      title: captain
          ? headSupervisorText(context, arabic: 'إنذار للكابتن', english: 'Warn the captain')
          : headSupervisorText(context, arabic: 'إنذار للتاجر', english: 'Warn the merchant'),
      subtitle: headSupervisorText(context,
          arabic: 'بيوصله إشعار رسمي ويتسجل في الشكوى، والشكوى بتفضل مفتوحة.',
          english: 'Sent as an official notice; the complaint stays open.'),
      hint: headSupervisorText(context, arabic: 'نص الإنذار', english: 'Warning text'),
      confirmLabel: headSupervisorText(context, arabic: 'إرسال الإنذار', english: 'Send warning'),
      icon: captain ? Icons.delivery_dining_outlined : Icons.storefront_outlined,
      iconBackground: AppColors.warningLight,
      action: (note) => ComplaintLinkActionsApi().warn(details.complaintId, party, note),
    );
    if (message == null || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    await cubit.retry();
  }

  Widget _buildDetails(BuildContext context, MerchantComplaintDetails details) {
    final archived = summary.status.isFinal || details.closed;
    final link = details.link;
    final type = details.linkType;
    final isAd = type == 'ad';
    final supervisor = details.accusedSupervisor;
    Widget gap([double h = 12]) => SizedBox(height: h);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ScrollFx(child: ComplaintHeaderPanel(details: details, archived: archived)),
        if (link != null) ...[
          gap(),
          ScrollFx(child: ComplaintLinkPanel(link: link)),
        ],
        if (!isAd) ...[
          gap(),
          ScrollFx(child: ComplaintResponsiblePanel(supervisor: supervisor)),
          if (details.automatedAudit.protocolAlert.isNotEmpty) ...[
            gap(),
            ScrollFx(child: ComplaintHistoryPanel(history: details.automatedAudit.protocolAlert)),
          ],
        ] else ...[
          gap(),
          ScrollFx(child: ComplaintAutomatedAuditPanel(audit: details.automatedAudit)),
          gap(),
          ScrollFx(child: ComplaintSupervisorStatementPanel(statement: details.supervisorStatement)),
        ],
        if (details.evidences.isNotEmpty) ...[
          gap(),
          ScrollFx(child: ComplaintEvidencesPanel(evidences: details.evidences)),
        ],
        gap(14),
        if (!archived) ...[
          Text(
              headSupervisorText(context,
                  arabic: 'الإجراءات الرقابية المتاحة',
                  english: 'Available oversight actions'),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
          gap(8),
          if (isAd) ...[
            ComplaintActionButton(
              title: headSupervisorText(context,
                  arabic: 'إلغاء حظر الإعلان والتحقيق مع المشرف',
                  english: 'Unblock the ad and investigate the supervisor'),
              icon: Icons.fact_check_outlined,
              busy: false,
              primary: true,
              onPressed: () => _unban(context, details),
            ),
            gap(8),
          ],
          if (type == 'service' || type == 'order') ...[
            ComplaintActionButton(
              title: type == 'order'
                  ? headSupervisorText(context, arabic: 'استرداد المبلغ لمحفظة العميل', english: 'Refund to the customer wallet')
                  : headSupervisorText(context, arabic: 'تعويض العميل في المحفظة', english: 'Compensate in the wallet'),
              icon: Icons.account_balance_wallet_outlined,
              busy: false,
              primary: true,
              onPressed: () => _closing(
                  context,
                  showComplaintCompensationSheet(context,
                      complaintId: details.complaintId,
                      maxAmount: link?.amount ?? 0,
                      isOrder: type == 'order')),
            ),
            gap(8),
          ],
          if (type == 'service' && link?.providerId != null && !(link?.providerSuspended ?? false)) ...[
            ComplaintToneButton(
              title: headSupervisorText(context, arabic: 'إيقاف مقدم الخدمة', english: 'Suspend the provider'),
              icon: Icons.person_off_outlined,
              color: AppColors.dangerDark,
              onPressed: () => _closing(
                context,
                showComplaintNoteSheet(
                  context,
                  title: headSupervisorText(context, arabic: 'إيقاف ${link?.providerName ?? ''}', english: 'Suspend ${link?.providerName ?? ''}'),
                  subtitle: headSupervisorText(context,
                      arabic: 'مش هيستقبل طلبات جديدة، والشكوى هتتقفل.',
                      english: 'No new requests; the complaint will be closed.'),
                  hint: headSupervisorText(context, arabic: 'سبب الإيقاف', english: 'Reason'),
                  confirmLabel: headSupervisorText(context, arabic: 'إيقاف وقفل الشكوى', english: 'Suspend and close'),
                  icon: Icons.person_off_outlined,
                  iconBackground: AppColors.dangerLight,
                  action: (note) => ComplaintLinkActionsApi().suspendProvider(details.complaintId, note),
                ),
              ),
            ),
            gap(8),
          ],
          if (type == 'order' && (link?.merchants.isNotEmpty ?? false)) ...[
            ComplaintToneButton(
              title: headSupervisorText(context, arabic: 'إنذار للتاجر', english: 'Warn the merchant'),
              icon: Icons.storefront_outlined,
              color: AppColors.warningDark,
              onPressed: () => _warn(context, details, 'merchant'),
            ),
            gap(8),
          ],
          if (type == 'order' && link?.captain != null) ...[
            ComplaintToneButton(
              title: headSupervisorText(context, arabic: 'إنذار للكابتن', english: 'Warn the captain'),
              icon: Icons.delivery_dining_outlined,
              color: AppColors.warningDark,
              onPressed: () => _warn(context, details, 'captain'),
            ),
            gap(8),
          ],
          if (supervisor.known) ...[
            ComplaintActionButton(
              title: headSupervisorText(context,
                  arabic: 'استدعاء المشرف للتوضيح',
                  english: 'Summon the supervisor'),
              icon: Icons.person_search_outlined,
              busy: false,
              primary: false,
              onPressed: () => _summon(context, details),
            ),
            gap(8),
          ],
          ComplaintActionButton(
            title: type == 'order'
                ? headSupervisorText(context, arabic: 'رفض الشكوى وقفلها', english: 'Reject and close')
                : headSupervisorText(context, arabic: 'تأييد إجراء المشرف ورفض التظلم', english: 'Uphold the supervisor'),
            icon: Icons.verified_outlined,
            busy: false,
            primary: false,
            onPressed: () =>
                _decide(context, ComplaintDecisionType.upholdSupervisor),
          ),
          gap(8),
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
          gap(8),
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
