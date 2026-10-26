import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class HeadSupervisorSuspensionDraft {
  final String duration;
  final String reason;

  const HeadSupervisorSuspensionDraft({required this.duration, required this.reason});
}

class HeadSupervisorSuspendSupervisorSheet extends StatefulWidget {
  final String supervisorId;
  final String name;
  final String department;
  final String avatar;
  final Color avatarColor;

  const HeadSupervisorSuspendSupervisorSheet({
    super.key,
    required this.supervisorId,
    required this.name,
    required this.department,
    required this.avatar,
    required this.avatarColor,
  });

  @override
  State<HeadSupervisorSuspendSupervisorSheet> createState() =>
      _HeadSupervisorSuspendSupervisorSheetState();
}

class _HeadSupervisorSuspendSupervisorSheetState
    extends State<HeadSupervisorSuspendSupervisorSheet> {
  final _reasonController = TextEditingController();
  String _duration = 'لحين انتهاء التحقيق';
  String? _reasonError;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _confirm() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _reasonError = headSupervisorText(context, arabic: 'سبب التعليق الرقابي مطلوب', english: 'A suspension reason is required'));
      return;
    }
    Navigator.of(context).pop(HeadSupervisorSuspensionDraft(duration: _duration, reason: reason));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .94),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
          child: Column(children: [
            const SizedBox(height: 11),
            Container(width: 42, height: 5, decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 9),
            _Header(onClose: () => Navigator.pop(context)),
            Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 5, 18, 12), children: [
              _SupervisorSummary(
                id: widget.supervisorId,
                name: widget.name,
                department: widget.department,
                avatar: widget.avatar,
                color: widget.avatarColor,
              ),
              const SizedBox(height: 12),
              const _WarningCard(),
              const SizedBox(height: 14),
              Row(children: [Text(headSupervisorText(context, arabic: 'قابلة للتمديد أو الإلغاء', english: 'Can be extended or cancelled'), style: TextStyle(fontSize: 8, color: AppColors.textSecondary)), const Spacer(), Text(headSupervisorText(context, arabic: 'مدة التعليق المبدئية', english: 'Initial suspension period'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink))]),
              const SizedBox(height: 7),
              _DurationGrid(selected: _duration, onChanged: (value) => setState(() => _duration = value)),
              const SizedBox(height: 14),
              Row(children: [Text(headSupervisorText(context, arabic: '${_reasonController.text.length}/300 حرف كحد أقصى', english: '${_reasonController.text.length}/300 characters maximum'), style: TextStyle(fontSize: 8, color: AppColors.textSecondary)), const Spacer(), Text(headSupervisorText(context, arabic: 'سبب التعليق الرقابي', english: 'Oversight suspension reason'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)), const SizedBox(width: 4), Text('*', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 6),
              TextField(
                controller: _reasonController,
                minLines: 3,
                maxLines: 4,
                maxLength: 300,
                textAlign: TextAlign.right,
                onChanged: (_) => setState(() => _reasonError = null),
                decoration: InputDecoration(
                  hintText: headSupervisorText(context, arabic: 'اكتب بالتفصيل سبب تعليق الصلاحيات الإشرافية والتجار، أو رقم البلاغ (مطلوب للتوثيق في سجل الرقابة والحوكمة)...', english: 'Explain the suspension reason or provide a case number for the oversight log...'),
                  hintStyle: TextStyle(fontSize: 9, height: 1.5, color: AppColors.textMuted),
                  errorText: _reasonError,
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.all(12),
                  counterText: '${_reasonController.text.length}/300',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [Flexible(child: Text(headSupervisorText(context, arabic: 'سيتم تدوين هذا السبب في سجل الحوكمة وإشعار المشرف رسمياً بموجب لائحة المنظومة.', english: 'This reason will be recorded in the governance log and formally sent to the supervisor.'), textAlign: TextAlign.right, style: TextStyle(fontSize: 8, color: AppColors.textSecondary))), const SizedBox(width: 5), MotionIcon(Icons.info_outline, size: 13, color: AppColors.infoDark)]),
            ])),
            Padding(padding: const EdgeInsets.fromLTRB(18, 4, 18, 13), child: Column(children: [
              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _confirm, icon: const MotionIcon(Icons.lock_person_outlined, size: 17), label: Text(headSupervisorText(context, arabic: 'تأكيد تعليق المشرف', english: 'Confirm supervisor suspension')), style: FilledButton.styleFrom(backgroundColor: AppColors.dangerDark, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
              const SizedBox(height: 7),
              SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(backgroundColor: AppColors.surfaceHighlight, foregroundColor: AppColors.textPrimary, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(headSupervisorText(context, arabic: 'إلغاء والتراجع', english: 'Cancel')))),
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
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [Text(headSupervisorText(context, arabic: 'تعليق مشرف مؤقتاً', english: 'Temporarily suspend supervisor'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink)), const SizedBox(width: 5), MotionIcon(Icons.gavel_outlined, size: 18, color: AppColors.ink)]),
          const SizedBox(height: 3),
          Text(headSupervisorText(context, arabic: 'تجميد الصلاحيات الميدانية والرقابية للمشرف مؤقتاً', english: 'Temporarily freeze the supervisor’s field and oversight access'), style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
        ]),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(12)), child: Row(children: [MotionIcon(Icons.circle, size: 6, color: AppColors.danger), const SizedBox(width: 4), Text(headSupervisorText(context, arabic: 'إجراء رقابي فوري', english: 'Immediate oversight action'), style: TextStyle(fontSize: 8, color: AppColors.danger, fontWeight: FontWeight.bold))])),
        const Spacer(),
        IconButton(onPressed: onClose, icon: const MotionIcon(Icons.close, size: 18), style: IconButton.styleFrom(backgroundColor: AppColors.surfaceHighlight)),
      ]));
}

class _SupervisorSummary extends StatelessWidget {
  final String id;
  final String name;
  final String department;
  final String avatar;
  final Color color;
  const _SupervisorSummary({required this.id, required this.name, required this.department, required this.avatar, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.cardBorder)), child: Row(children: [
        Stack(clipBehavior: Clip.none, children: [CircleAvatar(radius: 24, backgroundColor: color, child: Text(avatar, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))), Positioned(bottom: 0, left: 0, child: CircleAvatar(radius: 7, backgroundColor: AppColors.surface, child: CircleAvatar(radius: 5, backgroundColor: AppColors.success)))]),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)), const SizedBox(width: 5), MotionIcon(Icons.circle, size: 6, color: AppColors.success)]), const SizedBox(height: 4), Text(headSupervisorText(context, arabic: 'مشرف معتمد • $department', english: 'Approved supervisor • $department'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: AppColors.textSecondary)), const SizedBox(height: 4), Row(mainAxisAlignment: MainAxisAlignment.end, children: [MotionIcon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary), Text(headSupervisorText(context, arabic: 'نطاق الرياض', english: 'Riyadh area'), style: TextStyle(fontSize: 8, color: AppColors.textSecondary)), const SizedBox(width: 8), Text(headSupervisorText(context, arabic: 'نشط ميدانياً', english: 'Active in field'), style: TextStyle(fontSize: 8, color: AppColors.success))])])),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(8)), child: Text(id, style: TextStyle(fontSize: 8, color: AppColors.textPrimary))), const SizedBox(height: 5), Text(headSupervisorText(context, arabic: 'مشرف ميداني', english: 'Field supervisor'), style: TextStyle(fontSize: 8, color: AppColors.textSecondary))]),
      ]));
}

class _WarningCard extends StatelessWidget {
  const _WarningCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: AppColors.dangerLight, border: Border.all(color: AppColors.dangerBorder), borderRadius: BorderRadius.circular(14)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(headSupervisorText(context, arabic: 'تنبيه رقابي مشدد', english: 'Important oversight notice'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.dangerDark)), const SizedBox(height: 4), Text(headSupervisorText(context, arabic: 'سيؤدي هذا الإجراء إلى سحب صلاحيات اعتماد الإعلانات والتحصيل المالي فوراً، وتخضع حساباتك لمراجعة القرار من رئيس المشرفين.', english: 'This action immediately revokes ad approval and financial collection access. The Head Supervisor will review the decision.'), textAlign: TextAlign.right, style: TextStyle(fontSize: 9, height: 1.5, color: AppColors.textSecondary))])),
        const SizedBox(width: 8),
        Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.dangerBorder, shape: BoxShape.circle), child: MotionIcon(Icons.warning_amber_rounded, size: 17, color: AppColors.dangerDark)),
      ]));
}

class _DurationGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _DurationGrid({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    const durations = ['24 ساعة', '3 أيام', 'أسبوع كامل', 'لحين انتهاء التحقيق'];
    return Column(children: [for (var row = 0; row < 2; row++) ...[
      if (row > 0) const SizedBox(height: 7),
      Row(children: [for (var column = 0; column < 2; column++) ...[
        if (column > 0) const SizedBox(width: 6),
        Expanded(child: _DurationChip(label: durations[row * 2 + column], selected: selected == durations[row * 2 + column], onTap: () => onChanged(durations[row * 2 + column]))),
      ]]),
    ]]);
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DurationChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: selected ? AppColors.primaryDark : AppColors.surfaceLight, borderRadius: BorderRadius.circular(12), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [if (selected) const MotionIcon(Icons.hourglass_bottom, size: 13, color: Colors.white), if (selected) const SizedBox(width: 4), Text(headSupervisorText(context, arabic: label, english: switch (label) { '24 ساعة' => '24 hours', '3 أيام' => '3 days', 'أسبوع كامل' => 'One week', _ => 'Until investigation ends' }), style: TextStyle(fontSize: 9, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? Colors.white : AppColors.textPrimary))]))));
}
