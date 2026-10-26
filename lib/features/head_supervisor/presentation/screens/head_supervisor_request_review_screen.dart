import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_request_decision_sheet.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class HeadSupervisorRequestReviewScreen extends StatefulWidget {
  final String requestId;
  final String title;
  final String department;
  final String supervisor;
  final String reason;
  final String supervisorDecision;
  final DateTime createdAt;

  const HeadSupervisorRequestReviewScreen({
    super.key,
    required this.requestId,
    required this.title,
    required this.department,
    required this.supervisor,
    required this.reason,
    required this.supervisorDecision,
    required this.createdAt,
  });

  @override
  State<HeadSupervisorRequestReviewScreen> createState() =>
      _HeadSupervisorRequestReviewScreenState();
}

class _HeadSupervisorRequestReviewScreenState
    extends State<HeadSupervisorRequestReviewScreen> {
  final _guidance = TextEditingController();
  HeadSupervisorDecisionAction _action =
      HeadSupervisorDecisionAction.returnForReview;
  String? _error;

  @override
  void dispose() {
    _guidance.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _guidance.text.trim();
    if (note.isEmpty) {
      setState(() => _error = headSupervisorText(context, arabic: 'اكتب التوجيه المطلوب إرساله للمشرف.', english: 'Enter the instruction to send to the supervisor.'));
      return;
    }
    Navigator.of(context).pop(
      HeadSupervisorDecisionDraft(action: _action, note: note),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rejected = widget.supervisorDecision == 'مرفوض';
    final statusColor = rejected ? AppColors.dangerDark : AppColors.infoDark;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(headSupervisorText(context, arabic: 'إعادة مراجعة القرار', english: 'Review decision'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          tooltip: headSupervisorText(context, arabic: 'رجوع', english: 'Back'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const MotionIcon(Icons.arrow_back),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 14),
            child: MotionIcon(Icons.shield_outlined, color: AppColors.ink),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ScrollFx(child: _ReviewSessionCard(
            requestId: widget.requestId,
            status: widget.supervisorDecision,
            statusColor: statusColor,
            createdAt: widget.createdAt,
          )),
          const SizedBox(height: 12),
          ScrollFx(child: _SupervisorDecisionCard(
            supervisor: widget.supervisor,
            department: widget.department,
            decision: widget.supervisorDecision,
            reason: widget.reason,
            statusColor: statusColor,
          )),
          const SizedBox(height: 12),
          ScrollFx(child: _RequestDetailsCard(
            requestId: widget.requestId,
            title: widget.title,
            department: widget.department,
          )),
          const SizedBox(height: 18),
          ScrollFx(child: _SectionHeading(
            title: headSupervisorText(context, arabic: 'نوع الإجراء والتوجيه الرقابي', english: 'Oversight action and instruction'),
            subtitle: headSupervisorText(context, arabic: 'اختر الإجراء المطلوب من المشرف', english: 'Choose the action required from the supervisor'),
          )),
          const SizedBox(height: 8),
          ScrollFx(child: _ActionChoice(
            selected: _action == HeadSupervisorDecisionAction.returnForReview,
            onTap: () => setState(() => _action =
                HeadSupervisorDecisionAction.returnForReview),
            title: headSupervisorText(context, arabic: 'إعادة الطلب للمشرف مع توجيه ملزم', english: 'Return request with a required instruction'),
            detail: headSupervisorText(context, arabic: 'إلزام المشرف بإعادة فحص الطلب وإسناد النطاق الجغرافي خلال مهلة محددة.', english: 'Require the supervisor to review the request and assign its geographic scope within a set period.'),
            badge: headSupervisorText(context, arabic: 'الإجراء الأنسب', english: 'Recommended action'),
          )),
          const SizedBox(height: 8),
          ScrollFx(child: _ActionChoice(
            selected: _action == HeadSupervisorDecisionAction.requestExplanation,
            onTap: () => setState(() =>
                _action = HeadSupervisorDecisionAction.requestExplanation),
            title: headSupervisorText(context, arabic: 'طلب إفادة تفسيرية إضافية من المشرف', english: 'Request additional explanation'),
            detail: headSupervisorText(context, arabic: 'تجميد اعتماد القرار مؤقتاً ومطالبة المشرف بتوضيح كتابي يشرح سبب اتخاذه.', english: 'Temporarily hold approval and ask the supervisor for a written explanation.'),
          )),
          const SizedBox(height: 8),
          ScrollFx(child: _ActionChoice(
            selected:
                _action == HeadSupervisorDecisionAction.administrativeWarning,
            onTap: () => setState(() =>
                _action = HeadSupervisorDecisionAction.administrativeWarning),
            title: headSupervisorText(context, arabic: 'توجيه تنبيه إداري ولفت نظر رقابي', english: 'Issue an administrative warning'),
            detail: headSupervisorText(context, arabic: 'تسجيل ملاحظة تدقيق مهني في سجل أداء المشرف لاتخاذ الإجراء المناسب.', english: 'Record an audit note in the supervisor performance log.'),
            warning: true,
          )),
          const SizedBox(height: 14),
          ScrollFx(child: _SectionHeading(
            title: headSupervisorText(context, arabic: 'التوجيه الإداري والمهني للمشرف *', english: 'Administrative instruction for supervisor *'),
            subtitle: headSupervisorText(context, arabic: 'إشعار المشرف فوراً', english: 'Notify supervisor immediately'),
          )),
          const SizedBox(height: 8),
          TextField(
            controller: _guidance,
            minLines: 4,
            maxLines: 5,
            maxLength: 300,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              hintText: headSupervisorText(context, arabic: 'اكتب التوجيه وسبب إعادة مراجعة القرار...', english: 'Enter the instruction and reason for reviewing the decision...'),
              hintStyle: TextStyle(fontSize: 10, color: AppColors.textMuted),
              errorText: _error,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: AppColors.surfaceHighlight),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ScrollFx(child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                MotionIcon(Icons.folder_open_outlined,
                    color: AppColors.textSecondary),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(headSupervisorText(context, arabic: 'سجل توجيهات المشرف السابقة', english: 'Previous supervisor instructions'),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink)),
                      Text(headSupervisorText(context, arabic: 'تاريخ قرار المشرف: ${_dateLabel(widget.createdAt, context)}', english: 'Supervisor decision date: ${_dateLabel(widget.createdAt, context)}'),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 8, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                MotionIcon(Icons.chevron_left, color: AppColors.textSecondary),
              ],
            ),
          )),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const MotionIcon(Icons.send_outlined, size: 17),
              label: Text(
                headSupervisorText(context, arabic: switch (_action) {
                  HeadSupervisorDecisionAction.returnForReview =>
                    'إرسال أمر إعادة المراجعة للمشرف فوراً',
                  HeadSupervisorDecisionAction.requestExplanation =>
                    'إرسال طلب الإفادة للمشرف فوراً',
                  HeadSupervisorDecisionAction.administrativeWarning =>
                    'تسجيل التنبيه وإشعار المشرف فوراً',
                  _ => 'إرسال التوجيه للمشرف فوراً',
                }, english: switch (_action) {
                  HeadSupervisorDecisionAction.returnForReview => 'Send review order to supervisor',
                  HeadSupervisorDecisionAction.requestExplanation => 'Request an explanation from supervisor',
                  HeadSupervisorDecisionAction.administrativeWarning => 'Record warning and notify supervisor',
                  _ => 'Send instruction to supervisor',
                }),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceHighlight,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(headSupervisorText(context, arabic: 'إلغاء والتراجع', english: 'Cancel'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSessionCard extends StatelessWidget {
  final String requestId;
  final String status;
  final Color statusColor;
  final DateTime createdAt;

  const _ReviewSessionCard({
    required this.requestId,
    required this.status,
    required this.statusColor,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) => _WhiteCard(
        child: Column(children: [
          Row(children: [
            MotionIcon(Icons.shield_outlined,
                size: 20, color: AppColors.ink),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(headSupervisorText(context, arabic: 'رقم الجلسة الرقابية', english: 'Oversight session ID'),
                  style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              Text('REV-${requestId.hashCode.abs() % 90000 + 10000}#',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink)),
            ]),
          ]),
          const Divider(height: 18),
          Row(children: [
            _StatusBadge(label: headSupervisorText(
              context,
              arabic: 'قرار المشرف $status',
              english: 'Supervisor decision: ${switch (status) {
                'مرفوض' => 'Rejected',
                'مجمّد' => 'Frozen',
                _ => status,
              }}',
            ), color: statusColor),
            const Spacer(),
            Text('مرتبط بالطلب: $requestId',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(width: 4),
            MotionIcon(Icons.assignment_outlined,
                size: 14, color: AppColors.textSecondary),
          ]),
        ]),
      );
}

class _SupervisorDecisionCard extends StatelessWidget {
  final String supervisor;
  final String department;
  final String decision;
  final String reason;
  final Color statusColor;

  const _SupervisorDecisionCard({
    required this.supervisor,
    required this.department,
    required this.decision,
    required this.reason,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final decisionLabel = switch (decision) {
      'مرفوض' => headSupervisorText(context, arabic: 'رفض الطلب', english: 'Request rejected'),
      'مجمّد' => headSupervisorText(context, arabic: 'تجميد الطلب', english: 'Request frozen'),
      _ => headSupervisorText(context, arabic: 'مصعّد للمراجعة', english: 'Escalated for review'),
    };
    return _WhiteCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            _StatusBadge(label: decisionLabel, color: statusColor),
            const Spacer(),
            Text(supervisor,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceHighlight,
              child: MotionIcon(Icons.person_outline, color: statusColor),
            ),
          ]),
          const SizedBox(height: 3),
          Text(department,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(headSupervisorText(context, arabic: 'مسوغ المشرف للقرار', english: 'Supervisor rationale'),
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 5),
                MotionIcon(Icons.format_quote, size: 15, color: statusColor),
              ]),
              const SizedBox(height: 5),
              Text(reason.isEmpty ? headSupervisorText(context, arabic: 'لم يسجل المشرف سبباً للقرار.', english: 'The supervisor did not provide a reason.') : reason,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 10,
                      height: 1.55,
                      color: AppColors.textSecondary)),
            ]),
          ),
        ]),
      );
  }
}

class _RequestDetailsCard extends StatelessWidget {
  final String requestId;
  final String title;
  final String department;

  const _RequestDetailsCard({
    required this.requestId,
    required this.title,
    required this.department,
  });

  @override
  Widget build(BuildContext context) => _WhiteCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(headSupervisorText(context, arabic: 'تفاصيل الطلب / الإعلان', english: 'Request / ad details'),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.infoDark)),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(headSupervisorText(context, arabic: 'القسم', english: 'Department'),
                  style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              Text(department,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold)),
            ]),
            const Spacer(),
            Expanded(
              flex: 2,
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text(headSupervisorText(context, arabic: 'رقم الطلب: $requestId', english: 'Request ID: $requestId'),
                    style: TextStyle(
                        fontSize: 8, color: AppColors.textSecondary)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.infoBorder,
                borderRadius: BorderRadius.circular(11)),
            child: Row(children: [
              MotionIcon(Icons.radar, color: AppColors.ink, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headSupervisorText(context, arabic: 'يعرض هذا القسم بيانات الطلب وسبب قرار المشرف المسجل للمراجعة الرقابية.', english: 'This section shows the request and the supervisor decision rationale for oversight review.'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 8,
                      height: 1.4,
                      color: AppColors.textSecondary),
                ),
              ),
            ]),
          ),
        ]),
      );
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeading({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Row(children: [
        if (subtitle != null)
          Text(subtitle!,
              style: TextStyle(
                  fontSize: 8, color: AppColors.textSecondary)),
        const Spacer(),
        Text(title,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ]);
}

class _ActionChoice extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String title;
  final String detail;
  final String? badge;
  final bool warning;

  const _ActionChoice({
    required this.selected,
    required this.onTap,
    required this.title,
    required this.detail,
    this.badge,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.danger : AppColors.infoDark;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MotionIcon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 17, color: selected ? AppColors.ink : AppColors.textMuted),
            const SizedBox(width: 9),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (badge != null) ...[
                    _StatusBadge(label: badge!, color: color),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: warning ? AppColors.dangerDark : AppColors.textPrimary)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(detail,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 8,
                        height: 1.45,
                        color: AppColors.textSecondary)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: TextStyle(
                fontSize: 8, color: color, fontWeight: FontWeight.w600)),
      );
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: child,
      );
}

String _dateLabel(DateTime date, BuildContext context) {
  final days = DateTime.now().difference(date).inDays;
  return days == 0
      ? headSupervisorText(context, arabic: 'اليوم', english: 'Today')
      : headSupervisorText(context, arabic: 'منذ $days يوم', english: '$days days ago');
}
