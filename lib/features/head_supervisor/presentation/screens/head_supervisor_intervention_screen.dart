import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../head_supervisor_text.dart';
import '../../../wasalny_supervisor/data/wasalny_local_event_store.dart';
import 'head_supervisor_request_decision_sheet.dart';

class HeadSupervisorInterventionScreen extends StatefulWidget {
  final String eventId;
  final String requestId;
  final String title;
  final String department;
  final String supervisor;
  final String reason;
  final String supervisorDecision;
  final String recipient;
  final DateTime createdAt;

  const HeadSupervisorInterventionScreen({
    super.key,
    required this.eventId,
    required this.requestId,
    required this.title,
    required this.department,
    required this.supervisor,
    required this.reason,
    required this.supervisorDecision,
    required this.recipient,
    required this.createdAt,
  });

  @override
  State<HeadSupervisorInterventionScreen> createState() =>
      _HeadSupervisorInterventionScreenState();
}

class _HeadSupervisorInterventionScreenState
    extends State<HeadSupervisorInterventionScreen> {
  final _guidance = TextEditingController();
  final _basis = TextEditingController();
  HeadSupervisorDecisionAction _action =
      HeadSupervisorDecisionAction.returnFullRefund;
  bool _guidanceSent = false;
  bool _sendingGuidance = false;
  String? _error;

  static const _actions = [
    (
      HeadSupervisorDecisionAction.returnFullRefund,
      'إرجاع السلعة للبائع واسترداد كامل المبلغ للمشتري',
      'رد كامل المبلغ إلى حساب العميل البنكي فوراً، وإرجاع الكاميرا للبائع مع خصم رسوم الفحص وسوء الإفصاح من رصيد التاجر.',
      'حسم النزاع بسبب عدم مطابقة السلعة للمواصفات المعلنة وثبوت قصور الإفصاح.',
    ),
    (
      HeadSupervisorDecisionAction.partialCompensation,
      'إلزام البائع بتعويض جزئي (15%) واستلام السلعة',
      'استقطاع مبلغ 1,267.50 ر.س من قيمة الصفقة وإيداعه للمشتري مقابل قبول الخدش، وتحويل المبلغ المتبقي للبائع.',
      'تعويض جزئي عن العيب المثبت مع إتمام الصفقة بموافقة المشتري.',
    ),
    (
      HeadSupervisorDecisionAction.rejectRefund,
      'رفض طلب الإرجاع وإلزام المشتري بالاستلام',
      'اعتماد فحص الاستلام وإلزام المشتري بالاستلام وفق شروط الصفقة، مع توثيق نتيجة الفحص.',
      'رفض الإرجاع بعد مطابقة تقرير الفحص لشروط الاستلام المعلنة.',
    ),
    (
      HeadSupervisorDecisionAction.referLegalAffairs,
      'إحالة الملف للشؤون القانونية والمكتب التنفيذي',
      'تجميد الحساب لمدة 14 يوماً ورفع مذكرة اشتباه احتيال وتضليل تجاري للمدير العام.',
      'إحالة الملف للتحقيق النظامي وحفظ كافة الأدلة والمراسلات.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _basis.text = _actions.first.$4;
  }

  @override
  void dispose() {
    _guidance.dispose();
    _basis.dispose();
    super.dispose();
  }

  void _selectAction(HeadSupervisorDecisionAction action, String basis) {
    setState(() {
      _action = action;
      _basis.text = basis;
      _error = null;
    });
  }

  Future<void> _sendGuidance() async {
    final note = _guidance.text.trim();
    if (note.isEmpty) {
      setState(() => _error = 'اكتب التوجيه الإداري المطلوب للمشرف أولاً.');
      return;
    }
    setState(() => _sendingGuidance = true);
    try {
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
          id: 'head-intervention-guidance-${widget.eventId}-${DateTime.now().millisecondsSinceEpoch}',
          recipient: widget.recipient,
          source: 'head',
          titleAr: 'توجيه رقابي بشأن الطلب ${widget.requestId}',
          titleEn: 'Supervisory instruction for request ${widget.requestId}',
          messageAr: note,
          messageEn: note,
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _guidanceSent = true;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'تم إرسال التوجيه الرقابي للمشرف.', english: 'Oversight instruction sent to the supervisor.'))),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor intervention',
      ));
      if (!mounted) return;
      setState(() => _error = headSupervisorText(context, arabic: 'تعذر إرسال التوجيه. حاول مرة أخرى.', english: 'Could not send the instruction. Try again.'));
    } finally {
      if (mounted) setState(() => _sendingGuidance = false);
    }
  }

  void _submit() {
    final guidance = _guidance.text.trim();
    final basis = _basis.text.trim();
    if (guidance.isEmpty || basis.isEmpty) {
      setState(() => _error = headSupervisorText(context, arabic: 'أكمل التوجيه الإداري والسند النظامي قبل الاعتماد.', english: 'Complete the administrative instruction and legal basis before approving.'));
      return;
    }
    Navigator.of(context).pop(
      HeadSupervisorDecisionDraft(
        action: _action,
        note: 'التوجيه للمشرف: $guidance | السند النظامي: $basis',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frozen = widget.supervisorDecision == 'مجمّد';
    final urgent = DateTime.now().difference(widget.createdAt).inHours >= 48;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(headSupervisorText(context, arabic: 'التدخل الرقابي', english: 'Oversight intervention'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _UrgencyBanner(urgent: urgent),
          const SizedBox(height: 11),
          _DisputeSummaryCard(
            requestId: widget.requestId,
            title: widget.title,
            department: widget.department,
            frozen: frozen,
          ),
          const SizedBox(height: 12),
          _ComplaintDetailsCard(reason: widget.reason),
          const SizedBox(height: 12),
          _SupervisorGuidanceCard(
            supervisor: widget.supervisor,
            guidance: _guidance,
            sent: _guidanceSent,
            sending: _sendingGuidance,
            error: _error,
            onSend: _sendGuidance,
            onChanged: () => setState(() => _error = null),
          ),
          const SizedBox(height: 12),
          _DisputePartiesCard(requestId: widget.requestId),
          const SizedBox(height: 14),
          Text(headSupervisorText(context, arabic: 'قرارات الحسم الرقابي الفوري', english: 'Immediate oversight decisions'),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 8),
          for (final option in _actions) ...[
            _FinalDecisionOption(
              title: option.$2,
              detail: option.$3,
              selected: _action == option.$1,
              warning: option.$1 == HeadSupervisorDecisionAction.referLegalAffairs,
              onTap: () => _selectAction(option.$1, option.$4),
            ),
            const SizedBox(height: 8),
          ],
          _LegalBasisCard(
            controller: _basis,
            error: _error,
            onChanged: () => setState(() => _error = null),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.gavel_outlined, size: 18),
              label: Text(headSupervisorText(context, arabic: 'اعتماد قرار حسم النزاع وإنهاء البلاغ فوراً', english: 'Approve dispute resolution and close the report'),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            headSupervisorText(context, arabic: 'قرار الحسم يصدر بموجب صلاحيات رئيس هيئة المشرفين المختصين، ويُرسل للطرفين فوراً.', english: 'The decision is issued under the Head Supervisor’s authority and sent to both parties.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _UrgencyBanner extends StatelessWidget {
  final bool urgent;
  const _UrgencyBanner({required this.urgent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
            color: const Color(0xFFFFE2DE),
            borderRadius: BorderRadius.circular(11)),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(urgent
                  ? headSupervisorText(context, arabic: 'تدخل عاجل • تجاوزت مدة التعليق 48 ساعة', english: 'Urgent intervention • on hold for over 48 hours')
                  : headSupervisorText(context, arabic: 'مراجعة رقابية • طلب بانتظار قرار رئيس المشرفين', english: 'Oversight review • awaiting Head Supervisor decision'),
              style: TextStyle(
                  fontSize: 9,
                  color: urgent ? AppColors.dangerDark : AppColors.primaryDark,
                  fontWeight: FontWeight.bold)),
          SizedBox(width: 6),
          Icon(urgent ? Icons.warning_amber_rounded : Icons.shield_outlined,
              size: 16, color: urgent ? AppColors.dangerDark : AppColors.primaryDark),
        ]),
      );
}

class _DisputeSummaryCard extends StatelessWidget {
  final String requestId;
  final String title;
  final String department;
  final bool frozen;

  const _DisputeSummaryCard({
    required this.requestId,
    required this.title,
    required this.department,
    required this.frozen,
  });

  @override
  Widget build(BuildContext context) {
    final amount = requestId == 'WAS-5510' ? headSupervisorText(context, arabic: '8,450 ر.س', english: 'SAR 8,450') : headSupervisorText(context, arabic: 'غير محدد في الطلب', english: 'Not specified');
    return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF0A2443),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const Icon(Icons.gavel_outlined, color: Colors.white70),
            const Spacer(),
            _Tag(label: requestId, light: true),
          ]),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 5),
          Text(department,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 9, color: Color(0xFFB8C9DE))),
          const Divider(color: Color(0x335A789C), height: 20),
          Row(children: [
            _Tag(label: frozen ? headSupervisorText(context, arabic: 'مجمّد مؤقتاً', english: 'Temporarily frozen') : headSupervisorText(context, arabic: 'مرفوض من المشرف', english: 'Rejected by supervisor'), light: true),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(headSupervisorText(context, arabic: 'المبلغ المتنازع عليه', english: 'Disputed amount'),
                  style: TextStyle(fontSize: 8, color: Color(0xFFB8C9DE))),
              Text(amount,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ]),
          ]),
        ]),
      );
  }
}

class _ComplaintDetailsCard extends StatelessWidget {
  final String reason;
  const _ComplaintDetailsCard({required this.reason});

  @override
  Widget build(BuildContext context) => _WhiteCard(
        title: headSupervisorText(context, arabic: 'فحوى الشكوى وتقرير الواقعة', english: 'Complaint and incident report'),
        icon: Icons.assignment_late_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(11)),
            child: Text(
              reason.isEmpty
                  ? headSupervisorText(context, arabic: 'لم تُرفق تفاصيل إضافية للشكوى.', english: 'No additional complaint details were provided.')
                  : reason,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 10,
                  height: 1.55,
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          Text(headSupervisorText(context, arabic: 'المرفقات والأدلة (نماذج توضيحية)', english: 'Attachments and evidence (samples)'),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          const Row(children: [
            Expanded(child: _AttachmentTile(icon: Icons.article_outlined, label: 'سجل المراسلات')),
            SizedBox(width: 6),
            Expanded(child: _AttachmentTile(icon: Icons.image_outlined, label: 'صور المنتج')),
            SizedBox(width: 6),
            Expanded(child: _AttachmentTile(icon: Icons.picture_as_pdf_outlined, label: 'تقرير الفحص PDF')),
          ]),
        ]),
      );
  }


class _SupervisorGuidanceCard extends StatelessWidget {
  final String supervisor;
  final TextEditingController guidance;
  final bool sent;
  final bool sending;
  final String? error;
  final VoidCallback onSend;
  final VoidCallback onChanged;

  const _SupervisorGuidanceCard({
    required this.supervisor,
    required this.guidance,
    required this.sent,
    required this.sending,
    required this.error,
    required this.onSend,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => _WhiteCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const Icon(Icons.chat_bubble_outline,
                color: Color(0xFF315E9A), size: 18),
            const Spacer(),
            Text(headSupervisorText(context, arabic: 'توجيه إداري مباشر وموثق للمشرف', english: 'Direct documented instruction to supervisor'),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark)),
          ]),
          const SizedBox(height: 6),
          Text(supervisor,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 7),
          TextField(
            controller: guidance,
            minLines: 2,
            maxLines: 3,
            maxLength: 300,
            textAlign: TextAlign.right,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              hintText: headSupervisorText(context, arabic: 'اكتب أمراً تنفيذياً أو تنبيهاً يوثق في السجل الوظيفي للمشرف...', english: 'Enter an instruction or warning for the supervisor’s employment record...'),
              hintStyle: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              errorText: error,
              filled: true,
              fillColor: const Color(0xFFF1F3F5),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide.none),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: sending || sent ? null : onSend,
              icon: Icon(sent ? Icons.check_circle_outline : Icons.send_outlined,
                  size: 14),
              label: Text(sent ? headSupervisorText(context, arabic: 'تم إرسال التوجيه', english: 'Instruction sent') : headSupervisorText(context, arabic: 'إرسال التوجيه فوراً', english: 'Send instruction now'),
                  style: const TextStyle(fontSize: 9)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  visualDensity: VisualDensity.compact),
            ),
          ),
        ]),
      );
}

class _DisputePartiesCard extends StatelessWidget {
  final String requestId;
  const _DisputePartiesCard({required this.requestId});

  @override
  Widget build(BuildContext context) {
    final isSample = requestId == 'WAS-5510';
    return _WhiteCard(
        title: headSupervisorText(context, arabic: 'أطراف النزاع التعاقدي', english: 'Dispute parties'),
        icon: Icons.groups_outlined,
        child: Column(children: [
          _PartyRow(name: isSample ? 'طارق العمري' : 'بيانات مقدم الطلب', role: isSample ? 'مقدم الاعتراض • الرياض' : 'تُعرض عند توفر بيانات صاحب الطلب', code: isSample ? 'USR-9022' : 'غير متاح', icon: Icons.person_outline),
          const SizedBox(height: 7),
          _PartyRow(name: isSample ? 'فهد العايد' : 'بيانات الطرف الآخر', role: isSample ? 'التاجر • مقدم السلعة' : 'تُعرض عند توفر بيانات الطرف الآخر', code: isSample ? 'TRD-4410' : 'غير متاح', icon: Icons.storefront_outlined),
        ]),
      );
  }
}

class _PartyRow extends StatelessWidget {
  final String name;
  final String role;
  final String code;
  final IconData icon;
  const _PartyRow({required this.name, required this.role, required this.code, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.chat_bubble_outline, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          const Icon(Icons.phone_outlined, size: 17, color: AppColors.textSecondary),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$name • #$code', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            Text(role, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          ]),
          const SizedBox(width: 8),
          CircleAvatar(radius: 17, backgroundColor: const Color(0xFFDDE8F5), child: Icon(icon, size: 17, color: AppColors.primaryDark)),
        ]),
      );
}

class _FinalDecisionOption extends StatelessWidget {
  final String title;
  final String detail;
  final bool selected;
  final bool warning;
  final VoidCallback onTap;

  const _FinalDecisionOption({required this.title, required this.detail, required this.selected, required this.onTap, this.warning = false});

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? const Color(0xFFF0F2F4) : Colors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 17, color: warning ? AppColors.danger : AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(title, textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: warning ? AppColors.dangerDark : AppColors.primaryDark)),
                const SizedBox(height: 5),
                Text(detail, textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, height: 1.45, color: AppColors.textSecondary)),
              ])),
            ]),
          ),
        ),
      );
}

class _LegalBasisCard extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final VoidCallback onChanged;
  const _LegalBasisCard({required this.controller, required this.error, required this.onChanged});

  @override
  Widget build(BuildContext context) => _WhiteCard(
        title: headSupervisorText(context, arabic: 'السند الإداري وتسبيب الحكم الإلزامي', english: 'Administrative and legal basis'),
        icon: Icons.gavel_outlined,
        child: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 4,
          textAlign: TextAlign.right,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: headSupervisorText(context, arabic: 'يُملأ السند بحسب القرار المختار، ويمكن إضافة حيثيات الحكم...', english: 'Enter the basis for the selected decision and any supporting rationale...'),
            hintStyle: const TextStyle(fontSize: 9, color: AppColors.textMuted),
            errorText: error,
            filled: true,
            fillColor: const Color(0xFFF1F3F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide.none),
          ),
        ),
      );
}

class _AttachmentTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AttachmentTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        height: 58,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(9)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 19, color: const Color(0xFF315E9A)),
          const SizedBox(height: 3),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 7, color: AppColors.textSecondary)),
        ]),
      );
}

class _Tag extends StatelessWidget {
  final String label;
  final bool light;
  const _Tag({required this.label, this.light = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: light ? const Color(0x334B6687) : const Color(0xFFE6EDF6), borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: TextStyle(fontSize: 8, color: light ? const Color(0xFFD6E1EF) : AppColors.primaryDark, fontWeight: FontWeight.w600)),
      );
}

class _WhiteCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  const _WhiteCard({this.title, this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE9EDF1))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (title != null) ...[
            Row(children: [
              if (icon != null) Icon(icon!, size: 17, color: AppColors.primaryDark),
              const Spacer(),
              Text(title!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ]),
            const SizedBox(height: 9),
          ],
          child,
        ]),
      );
}
