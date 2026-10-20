import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../head_supervisor_text.dart';

class HeadSupervisorDeletionDraft {
  final String reason;
  final String caseReference;
  final String notes;

  const HeadSupervisorDeletionDraft({required this.reason, required this.caseReference, required this.notes});
}

class HeadSupervisorDeleteSupervisorSheet extends StatefulWidget {
  final String supervisorId;
  final String name;
  final String department;
  final String avatar;
  final Color avatarColor;

  const HeadSupervisorDeleteSupervisorSheet({
    super.key,
    required this.supervisorId,
    required this.name,
    required this.department,
    required this.avatar,
    required this.avatarColor,
  });

  @override
  State<HeadSupervisorDeleteSupervisorSheet> createState() =>
      _HeadSupervisorDeleteSupervisorSheetState();
}

class _HeadSupervisorDeleteSupervisorSheetState
    extends State<HeadSupervisorDeleteSupervisorSheet> {
  static const _reasons = [
    'مخالفة معايير وضوابط الإشراف والنزاهة',
    'إنهاء عقد العمل الرسمي أو استقالة المشرف',
    'سوء استغلال الصلاحيات الائتمانية الممنوحة',
    'موجب إداري آخر مرفق بالمحضر',
  ];
  final _caseController = TextEditingController();
  final _notesController = TextEditingController();
  String _reason = _reasons.first;
  bool _acknowledged = false;
  String? _error;

  @override
  void dispose() {
    _caseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_acknowledged) {
      setState(() => _error = headSupervisorText(context, arabic: 'يرجى تأكيد الإقرار قبل رفع الطلب.', english: 'Confirm the acknowledgement before submitting.'));
      return;
    }
    Navigator.of(context).pop(HeadSupervisorDeletionDraft(
      reason: _reason,
      caseReference: _caseController.text.trim(),
      notes: _notesController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .96),
          decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
          child: Column(children: [
            const SizedBox(height: 10),
            Container(width: 42, height: 5, decoration: BoxDecoration(color: const Color(0xFFD8DCE1), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 8),
            _Header(onClose: () => Navigator.pop(context)),
            Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 12), children: [
              const _AlertIcon(),
              const SizedBox(height: 7),
              Text(headSupervisorText(context, arabic: 'حذف المشرف وسحب التراخيص نهائياً', english: 'Permanently delete supervisor and revoke access'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              const SizedBox(height: 4),
              Text(headSupervisorText(context, arabic: 'يترتب على هذا الإجراء إلغاء ترخيص الإشراف وسحب كافة الصلاحيات الميدانية والوصول المباشر للنظام فوراً.', english: 'This revokes the supervisor license, field access, and direct system access immediately.'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, height: 1.5, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              _SupervisorCard(id: widget.supervisorId, name: widget.name, department: widget.department, avatar: widget.avatar, color: widget.avatarColor),
              const SizedBox(height: 12),
              const _GovernanceWarning(),
              const SizedBox(height: 14),
              Row(children: [Text(headSupervisorText(context, arabic: '* إلزامي', english: '* Required'), style: const TextStyle(fontSize: 8, color: AppColors.danger)), const Spacer(), Text(headSupervisorText(context, arabic: 'سبب الحذف والمساءلة الرقابية', english: 'Deletion and oversight reason'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark))]),
              const SizedBox(height: 7),
              for (final reason in _reasons) ...[
                _ReasonOption(label: reason, selected: _reason == reason, onTap: () => setState(() => _reason = reason)),
                const SizedBox(height: 6),
              ],
              const SizedBox(height: 3),
              TextField(controller: _caseController, textAlign: TextAlign.right, decoration: InputDecoration(hintText: headSupervisorText(context, arabic: 'رقم المحضر الإداري المعتمد (مثال: GOV-2024-998)', english: 'Approved case reference (e.g. GOV-2024-998)'), hintStyle: const TextStyle(fontSize: 9, color: AppColors.textSecondary), prefixIcon: const Icon(Icons.assignment_outlined, size: 17), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE9EDF0))))),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(headSupervisorText(context, arabic: 'ملاحظات التحقيق والاعتماد النهائي', english: 'Investigation and final approval notes'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)), const Icon(Icons.notes_outlined, size: 14, color: AppColors.textSecondary)]),
              const SizedBox(height: 5),
              TextField(controller: _notesController, minLines: 3, maxLines: 4, maxLength: 500, textAlign: TextAlign.right, decoration: InputDecoration(hintText: headSupervisorText(context, arabic: 'اكتب بالتفصيل سبب حذف الصلاحيات الإشرافية والقرائن أو رقم البلاغ (مطلوب للتوثيق في سجل الرقابة والحوكمة)...', english: 'Describe the reason, evidence, or report number for the oversight log...'), hintStyle: const TextStyle(fontSize: 9, height: 1.5, color: AppColors.textMuted), counterStyle: const TextStyle(fontSize: 8), filled: true, fillColor: const Color(0xFFF1F3F5), contentPadding: const EdgeInsets.all(12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9DDE2))))),
              const SizedBox(height: 7),
              InkWell(onTap: () => setState(() { _acknowledged = !_acknowledged; _error = null; }), borderRadius: BorderRadius.circular(11), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11), decoration: BoxDecoration(color: const Color(0xFFEBEDEF), borderRadius: BorderRadius.circular(11)), child: Row(children: [Checkbox(value: _acknowledged, onChanged: (value) => setState(() { _acknowledged = value ?? false; _error = null; }), activeColor: AppColors.primaryDark, visualDensity: VisualDensity.compact), Expanded(child: Text(headSupervisorText(context, arabic: 'أقر بصحة تنفيذ سحب الصلاحيات وحفظ المحاضر المسجلة وبدء إجراءات سحب الصلاحيات التشغيلية للمشرف فوراً.', english: 'I confirm the access revocation, preservation of recorded reports, and immediate start of operational access removal.'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, height: 1.4, color: AppColors.textPrimary)))]))),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 5), child: Text(_error!, textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, color: AppColors.danger))),
            ])),
            Padding(padding: const EdgeInsets.fromLTRB(18, 4, 18, 12), child: Column(children: [
              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.lock_person_outlined, size: 17), label: Text(headSupervisorText(context, arabic: 'رفع الطلب للإدارة العليا', english: 'Submit to senior management')), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
              const SizedBox(height: 7),
              SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(backgroundColor: const Color(0xFFEBEDEF), foregroundColor: AppColors.primaryDark, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(headSupervisorText(context, arabic: 'إلغاء والتراجع', english: 'Cancel'), style: const TextStyle(fontWeight: FontWeight.bold)))),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFFFE0E0), borderRadius: BorderRadius.circular(14)), child: Row(children: [Text(headSupervisorText(context, arabic: 'إجراء رقابي نهائي - عالي الحساسية', english: 'Final high-sensitivity action'), style: const TextStyle(fontSize: 8, color: AppColors.dangerDark, fontWeight: FontWeight.bold)), const SizedBox(width: 4), const Icon(Icons.shield_outlined, size: 12, color: AppColors.dangerDark)])),
        const Spacer(),
        IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 18), style: IconButton.styleFrom(backgroundColor: const Color(0xFFEBEDEF))),
      ]));
}

class _AlertIcon extends StatelessWidget {
  const _AlertIcon();
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 54, height: 54, decoration: BoxDecoration(color: const Color(0xFFFFD9D6), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.person_remove_alt_1, color: AppColors.dangerDark, size: 26)));
}

class _SupervisorCard extends StatelessWidget {
  final String id;
  final String name;
  final String department;
  final String avatar;
  final Color color;
  const _SupervisorCard({required this.id, required this.name, required this.department, required this.avatar, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE8ECF0))), child: Column(children: [
        Row(children: [CircleAvatar(radius: 25, backgroundColor: color, child: Text(avatar, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(name, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), Text(headSupervisorText(context, arabic: 'مشرف • $department', english: 'Supervisor • $department'), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: Color(0xFF42699F))), Text(headSupervisorText(context, arabic: 'نطاق الرياض', english: 'Riyadh area'), style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))])), const SizedBox(width: 8), _IdBadge(id)]),
        const SizedBox(height: 9),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFF0F2F4), borderRadius: BorderRadius.circular(10)), child: Row(children: [Expanded(child: _MiniMetric(title: headSupervisorText(context, arabic: 'نسبة التجاوب', english: 'Response rate'), value: '98.4%', icon: Icons.speed_outlined)), Expanded(child: _MiniMetric(title: headSupervisorText(context, arabic: 'عمليات التحقيق', english: 'Investigations'), value: headSupervisorText(context, arabic: '142 عملية', english: '142'), icon: Icons.verified_outlined))])),
      ]));
}

class _IdBadge extends StatelessWidget {
  final String id;
  const _IdBadge(this.id);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE7E9EC), borderRadius: BorderRadius.circular(6)), child: Text(id, style: const TextStyle(fontSize: 8, color: AppColors.textPrimary)));
}

class _MiniMetric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _MiniMetric({required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.end, children: [Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(title, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)), Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark))]), const SizedBox(width: 5), Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: const Color(0xFFE3E6E9), borderRadius: BorderRadius.circular(7)), child: Icon(icon, size: 13, color: AppColors.primaryDark))]);
}

class _GovernanceWarning extends StatelessWidget {
  const _GovernanceWarning();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFDAD7), borderRadius: BorderRadius.circular(14)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(headSupervisorText(context, arabic: 'تنبيه رقابي مشدد وفق لائحة الحوكمة (م-14)', english: 'Governance notice under policy M-14'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.dangerDark)), const SizedBox(height: 5), Text(headSupervisorText(context, arabic: 'حذف المشرف نهائياً يلزم النظام بإخطار الإدارة العامة للرقابة الميدانية ومكتب التفتيش المركزي فوراً، وتجمد كافة الاعتمادات المعلقة ولا يمكن استرجاع الحساب إلا بعد المصادقة.', english: 'Permanent deletion immediately notifies central oversight and freezes pending approvals. The account cannot be restored without authorization.'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, height: 1.55, color: AppColors.dangerDark))])),
        const SizedBox(width: 8),
        Icon(Icons.warning_amber_rounded, color: AppColors.dangerDark, size: 19),
      ]));
}

class _ReasonOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ReasonOption({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: const Color(0xFFF0F2F4), borderRadius: BorderRadius.circular(12), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), child: Row(children: [Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, size: 17, color: selected ? AppColors.primaryDark : AppColors.textMuted), const Spacer(), Expanded(child: Text(headSupervisorText(context, arabic: label, english: switch (label) { 'مخالفة معايير وضوابط الإشراف والنزاهة' => 'Violation of oversight or integrity standards', 'إنهاء عقد العمل الرسمي أو استقالة المشرف' => 'Contract ended or supervisor resigned', 'سوء استغلال الصلاحيات الائتمانية الممنوحة' => 'Misuse of granted trusted access', _ => 'Other administrative reason on record' }), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, color: AppColors.textPrimary))), const SizedBox(width: 7), Icon(_reasonIcon(label), size: 15, color: const Color(0xFF42699F))]))));

  IconData _reasonIcon(String value) {
    if (value.startsWith('مخالفة')) return Icons.rule_folder_outlined;
    if (value.startsWith('إنهاء')) return Icons.assignment_ind_outlined;
    if (value.startsWith('سوء')) return Icons.gavel_outlined;
    return Icons.folder_copy_outlined;
  }
}
