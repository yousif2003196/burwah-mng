import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../head_supervisor_text.dart';

enum HeadSupervisorDecisionAction {
  approve,
  reject,
  returnForReview,
  requestExplanation,
  administrativeWarning,
  returnFullRefund,
  partialCompensation,
  rejectRefund,
  referLegalAffairs,
}

extension HeadSupervisorDecisionActionLabels on HeadSupervisorDecisionAction {
  String get labelAr => switch (this) {
        HeadSupervisorDecisionAction.approve => 'اعتماد الطلب',
        HeadSupervisorDecisionAction.reject => 'رفض الطلب',
        HeadSupervisorDecisionAction.returnForReview => 'إعادة للمراجعة',
        HeadSupervisorDecisionAction.requestExplanation => 'طلب إفادة تفسيرية',
        HeadSupervisorDecisionAction.administrativeWarning => 'توجيه تنبيه إداري',
        HeadSupervisorDecisionAction.returnFullRefund => 'إرجاع كامل المبلغ للمشتري',
        HeadSupervisorDecisionAction.partialCompensation => 'تعويض جزئي وإتمام التسليم',
        HeadSupervisorDecisionAction.rejectRefund => 'رفض طلب الإرجاع',
        HeadSupervisorDecisionAction.referLegalAffairs => 'إحالة للشؤون القانونية',
      };
  String get labelEn => switch (this) {
        HeadSupervisorDecisionAction.approve => 'Approve the request',
        HeadSupervisorDecisionAction.reject => 'Reject the request',
        HeadSupervisorDecisionAction.returnForReview => 'Return for review',
        HeadSupervisorDecisionAction.requestExplanation => 'Request an explanation',
        HeadSupervisorDecisionAction.administrativeWarning => 'Issue an administrative warning',
        HeadSupervisorDecisionAction.returnFullRefund => 'Issue a full refund',
        HeadSupervisorDecisionAction.partialCompensation => 'Award partial compensation',
        HeadSupervisorDecisionAction.rejectRefund => 'Reject the refund request',
        HeadSupervisorDecisionAction.referLegalAffairs => 'Refer to legal affairs',
      };
  bool get closesRequest => true;
}

class HeadSupervisorDecisionDraft {
  final HeadSupervisorDecisionAction action;
  final String note;
  const HeadSupervisorDecisionDraft({required this.action, required this.note});
}

class HeadSupervisorRequestDecisionSheet extends StatefulWidget {
  final String requestId;
  final String title;
  final String department;
  final String supervisor;
  final String reason;

  const HeadSupervisorRequestDecisionSheet({
    super.key,
    required this.requestId,
    required this.title,
    required this.department,
    required this.supervisor,
    required this.reason,
  });

  @override
  State<HeadSupervisorRequestDecisionSheet> createState() =>
      _HeadSupervisorRequestDecisionSheetState();
}

class _HeadSupervisorRequestDecisionSheetState
    extends State<HeadSupervisorRequestDecisionSheet> {
  final _note = TextEditingController();
  HeadSupervisorDecisionAction _action = HeadSupervisorDecisionAction.approve;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _note.text.trim();
    if (note.isEmpty) {
      setState(() => _error = headSupervisorText(context, arabic: 'أضف ملاحظة القرار لإشعار المشرف بسبب الإجراء.', english: 'Add a decision note explaining the action to the supervisor.'));
      return;
    }
    Navigator.of(context).pop(HeadSupervisorDecisionDraft(action: _action, note: note));
  }

  @override
  Widget build(BuildContext context) => AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .88),
            decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              const SizedBox(height: 10),
              Container(width: 42, height: 5, decoration: BoxDecoration(color: const Color(0xFFD9DDE2), borderRadius: BorderRadius.circular(10))),
              Padding(padding: const EdgeInsets.fromLTRB(18, 11, 18, 7), child: Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), style: IconButton.styleFrom(backgroundColor: const Color(0xFFEBEDEF))),
                const Spacer(),
                Text(headSupervisorText(context, arabic: 'مراجعة الطلب واتخاذ القرار', english: 'Review request and decide'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(width: 6),
                const Icon(Icons.gavel_outlined, size: 18, color: AppColors.primaryDark),
              ])),
              Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 12), children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE7EBEF))), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [Text(widget.requestId, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)), const Spacer(), Text(widget.department, style: const TextStyle(fontSize: 9, color: Color(0xFF315E9A), fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 7),
                  Text(widget.title, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 5),
                  Text(headSupervisorText(context, arabic: 'المشرف المحيل: ${widget.supervisor}', english: 'Referred by: ${widget.supervisor}'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                  const SizedBox(height: 7),
                  Text(headSupervisorText(context, arabic: 'سبب الإحالة: ${widget.reason}', english: 'Referral reason: ${widget.reason}'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, height: 1.45, color: AppColors.textSecondary)),
                ])),
                const SizedBox(height: 15),
                Text(headSupervisorText(context, arabic: 'حدد القرار الرقابي', english: 'Select an oversight decision'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 7),
                for (final action in HeadSupervisorDecisionAction.values) ...[
                  _DecisionOption(action: action, selected: _action == action, onTap: () => setState(() => _action = action)),
                  const SizedBox(height: 7),
                ],
                const SizedBox(height: 7),
                Text(headSupervisorText(context, arabic: 'ملاحظة القرار للمشرف', english: 'Decision note for supervisor'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 6),
                TextField(controller: _note, minLines: 3, maxLines: 4, maxLength: 300, textAlign: TextAlign.right, onChanged: (_) => setState(() => _error = null), decoration: InputDecoration(hintText: headSupervisorText(context, arabic: 'اكتب مبررات القرار أو المطلوب استكماله...', english: 'Enter the decision rationale or required follow-up...'), hintStyle: const TextStyle(fontSize: 9, color: AppColors.textMuted), errorText: _error, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.all(12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E4E8))))),
                const SizedBox(height: 5),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [const Icon(Icons.notifications_active_outlined, size: 13, color: Color(0xFF315E9A)), const SizedBox(width: 5), Text(headSupervisorText(context, arabic: 'سيتم إرسال القرار وملاحظته للمشرف والقسم المحيل.', english: 'The decision and its note will be sent to the supervisor and referring department.'), style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))]),
              ])),
              Padding(padding: const EdgeInsets.fromLTRB(18, 4, 18, 12), child: Column(children: [
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.send_outlined, size: 16), label: Text(headSupervisorText(context, arabic: '${_action.labelAr} وإشعار المشرف', english: '${_action.labelEn} and notify supervisor')), style: FilledButton.styleFrom(backgroundColor: _action == HeadSupervisorDecisionAction.reject ? AppColors.dangerDark : AppColors.primaryDark, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                const SizedBox(height: 6),
                SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(context), child: Text(headSupervisorText(context, arabic: 'إلغاء', english: 'Cancel')))),
              ])),
            ]),
          ),
        ),
      );
}

class _DecisionOption extends StatelessWidget {
  final HeadSupervisorDecisionAction action;
  final bool selected;
  final VoidCallback onTap;
  const _DecisionOption({required this.action, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = switch (action) {
      HeadSupervisorDecisionAction.approve => Icons.check_circle_outline,
      HeadSupervisorDecisionAction.reject => Icons.cancel_outlined,
      HeadSupervisorDecisionAction.returnForReview => Icons.replay_outlined,
      HeadSupervisorDecisionAction.requestExplanation => Icons.description_outlined,
      HeadSupervisorDecisionAction.administrativeWarning => Icons.warning_amber_outlined,
      HeadSupervisorDecisionAction.returnFullRefund => Icons.keyboard_return_outlined,
      HeadSupervisorDecisionAction.partialCompensation => Icons.payments_outlined,
      HeadSupervisorDecisionAction.rejectRefund => Icons.block_outlined,
      HeadSupervisorDecisionAction.referLegalAffairs => Icons.gavel_outlined,
    };
    final subtitleAr = switch (action) {
      HeadSupervisorDecisionAction.approve => 'اعتماد الإجراء وإغلاق الطلب',
      HeadSupervisorDecisionAction.reject => 'رفض التصعيد مع توضيح المبررات',
      HeadSupervisorDecisionAction.returnForReview => 'إعادة الطلب للمشرف لاستكمال المراجعة',
      HeadSupervisorDecisionAction.requestExplanation => 'طلب توضيح مكتوب قبل اعتماد القرار',
      HeadSupervisorDecisionAction.administrativeWarning => 'تسجيل تنبيه رقابي في سجل أداء المشرف',
      HeadSupervisorDecisionAction.returnFullRefund => 'إعادة المبلغ كاملاً إلى المشتري',
      HeadSupervisorDecisionAction.partialCompensation => 'تعويض جزئي مقابل إتمام التسليم',
      HeadSupervisorDecisionAction.rejectRefund => 'إنهاء النزاع بعد مراجعة المستندات',
      HeadSupervisorDecisionAction.referLegalAffairs => 'تجميد الإجراء وإحالة الملف للتحقيق',
    };
    final subtitleEn = switch (action) {
      HeadSupervisorDecisionAction.approve => 'Approve the action and close the request',
      HeadSupervisorDecisionAction.reject => 'Reject the escalation and explain why',
      HeadSupervisorDecisionAction.returnForReview => 'Return the request for further review',
      HeadSupervisorDecisionAction.requestExplanation => 'Request written clarification before deciding',
      HeadSupervisorDecisionAction.administrativeWarning => 'Add an oversight warning to the supervisor record',
      HeadSupervisorDecisionAction.returnFullRefund => 'Return the full amount to the buyer',
      HeadSupervisorDecisionAction.partialCompensation => 'Award partial compensation and complete delivery',
      HeadSupervisorDecisionAction.rejectRefund => 'Close the dispute after reviewing documents',
      HeadSupervisorDecisionAction.referLegalAffairs => 'Pause action and refer the case for investigation',
    };
    return Material(color: selected ? const Color(0xFFEAF0F8) : Colors.white, borderRadius: BorderRadius.circular(12), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10), child: Row(children: [Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, size: 17, color: selected ? const Color(0xFF315E9A) : AppColors.textMuted), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(headSupervisorText(context, arabic: action.labelAr, english: action.labelEn), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), Text(headSupervisorText(context, arabic: subtitleAr, english: subtitleEn), style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))])), const SizedBox(width: 8), Icon(icon, size: 18, color: const Color(0xFF315E9A))]))));
  }
}
