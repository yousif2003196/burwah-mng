import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class HeadSupervisorDraft {
  final String name;
  final String email;
  final String phone;
  final String department;
  final bool reviewAds;
  final bool hideAds;

  const HeadSupervisorDraft({
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.reviewAds,
    required this.hideAds,
  });
}

class HeadSupervisorAddSupervisorSheet extends StatefulWidget {
  const HeadSupervisorAddSupervisorSheet({super.key});

  @override
  State<HeadSupervisorAddSupervisorSheet> createState() =>
      _HeadSupervisorAddSupervisorSheetState();
}

class _HeadSupervisorAddSupervisorSheetState
    extends State<HeadSupervisorAddSupervisorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _department = 'تجار ومتاجر';
  bool _reviewAds = false;
  bool _hideAds = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(HeadSupervisorDraft(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      department: _department,
      reviewAds: _reviewAds,
      hideAds: _hideAds,
    ));
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
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .92),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 42, height: 5, decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 10),
            _SheetHeader(onClose: () => Navigator.pop(context)),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                  children: [
                    const SizedBox(height: 6),
                    _FieldTitle(title: headSupervisorText(context, arabic: 'اسم المشرف الرباعي', english: 'Supervisor full name'), hint: headSupervisorText(context, arabic: 'إلزامي', english: 'Required')),
                    _InputField(controller: _name, hint: headSupervisorText(context, arabic: 'أ. عبد الله عبد الرحمن الشمري', english: 'e.g. Alex Morgan'), icon: Icons.badge_outlined, validator: (value) => value == null || value.trim().isEmpty ? headSupervisorText(context, arabic: 'أدخل اسم المشرف', english: 'Enter the supervisor name') : null),
                    const SizedBox(height: 12),
                    _FieldTitle(title: headSupervisorText(context, arabic: 'البريد الإلكتروني المهني', english: 'Work email'), hint: headSupervisorText(context, arabic: 'نطاق المنظومة', english: 'Organization domain')),
                    _InputField(controller: _email, hint: 'a.alshammary@almazouri.sa', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty || !email.contains('@') || !email.contains('.')) return headSupervisorText(context, arabic: 'أدخل بريداً إلكترونياً صحيحاً', english: 'Enter a valid email address');
                      return null;
                    }),
                    const SizedBox(height: 12),
                    _FieldTitle(title: headSupervisorText(context, arabic: 'رقم الجوال والتحقق السريع', english: 'Phone and two-factor authentication'), hint: '2FA'),
                    _InputField(controller: _phone, hint: '+966 50 842 1904', icon: Icons.phone_iphone_outlined, keyboardType: TextInputType.phone, validator: (value) => value == null || value.trim().length < 8 ? headSupervisorText(context, arabic: 'أدخل رقم جوال صحيحاً', english: 'Enter a valid phone number') : null),
                    const SizedBox(height: 13),
                    _FieldTitle(title: headSupervisorText(context, arabic: 'القسم الإشرافي المكلف', english: 'Assigned department'), hint: headSupervisorText(context, arabic: 'النشط: تجار ومتاجر', english: 'Active: merchants and stores')),
                    _DepartmentSelector(selected: _department, onChanged: (value) => setState(() => _department = value)),
                    const SizedBox(height: 16),
                    _PermissionsPanel(
                      reviewAds: _reviewAds,
                      hideAds: _hideAds,
                      onReviewChanged: (value) => setState(() => _reviewAds = value),
                      onHideChanged: (value) => setState(() => _hideAds = value),
                    ),
                    const SizedBox(height: 12),
                    const _SecurityNote(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: Column(children: [
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _submit, icon: const MotionIcon(Icons.person_add_alt_1, size: 18), label: Text(headSupervisorText(context, arabic: 'إضافة المشرف وتفعيل الصلاحيات', english: 'Add supervisor and enable access')), style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                const SizedBox(height: 7),
                SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(backgroundColor: AppColors.surfaceHighlight, foregroundColor: AppColors.textPrimary, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(headSupervisorText(context, arabic: 'إلغاء والتراجع', english: 'Cancel'), style: const TextStyle(fontWeight: FontWeight.w600)))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _SheetHeader({required this.onClose});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [Text(headSupervisorText(context, arabic: 'إضافة مشرف جديد', english: 'Add supervisor'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink)), const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(12)), child: Text('#SUP-NEW', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.ink)))]),
            const SizedBox(height: 3),
            Text(headSupervisorText(context, arabic: 'منح ترخيص رقابي تشغيلي وتعيين مصفوفة الأدوات', english: 'Grant operational oversight access and assign permissions'), style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ]),
          const Spacer(),
          IconButton(onPressed: onClose, icon: const MotionIcon(Icons.close, size: 19), style: IconButton.styleFrom(backgroundColor: AppColors.surfaceHighlight)),
        ]),
      );
}

class _FieldTitle extends StatelessWidget {
  final String title;
  final String hint;
  const _FieldTitle({required this.title, required this.hint});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Text(hint, style: TextStyle(fontSize: 8, color: AppColors.textSecondary)), const Spacer(), Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink))]));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const _InputField({required this.controller, required this.hint, required this.icon, this.keyboardType = TextInputType.text, this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 11, color: AppColors.textPrimary),
          prefixIcon: MotionIcon(icon, size: 18, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.surfaceHighlight)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.infoDark)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.danger)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.danger)),
        ),
      );
}

class _DepartmentSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _DepartmentSelector({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    const departments = [
      ('تجار ومتاجر', Icons.storefront_outlined),
      ('وصلني', Icons.local_shipping_outlined),
      ('منتجات', Icons.inventory_2_outlined),
      ('خدمات وصيانة', Icons.design_services_outlined),
      ('المالية', Icons.account_balance_wallet_outlined),
    ];
    final rows = (departments.length / 2).ceil();
    return Column(children: [
      for (var row = 0; row < rows; row++) ...[
        if (row > 0) const SizedBox(height: 8),
        Row(children: [
          for (var column = 0; column < 2; column++) ...[
            if (column > 0) const SizedBox(width: 8),
            if (row * 2 + column < departments.length)
              Expanded(child: _DepartmentChip(label: departments[row * 2 + column].$1, icon: departments[row * 2 + column].$2, selected: selected == departments[row * 2 + column].$1, onTap: () => onChanged(departments[row * 2 + column].$1)))
            else
              const Expanded(child: SizedBox()),
          ],
        ]),
      ],
    ]);
  }
}

class _DepartmentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _DepartmentChip({required this.label, required this.icon, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: selected ? AppColors.primaryDark : AppColors.surfaceLight, borderRadius: BorderRadius.circular(13), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(13), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [MotionIcon(selected ? Icons.check_circle_outline : Icons.circle_outlined, size: 14, color: selected ? AppColors.infoBorder : AppColors.cardBorder), Row(children: [MotionIcon(icon, size: 15, color: selected ? Colors.white : AppColors.textSecondary), const SizedBox(width: 5), Text(headSupervisorText(context, arabic: label, english: switch (label) { 'تجار ومتاجر' => 'Merchants and stores', 'وصلني' => 'Wasalny', 'منتجات' => 'Products', 'المالية' => 'Finance', _ => 'Services and maintenance' }), style: TextStyle(fontSize: 9, color: selected ? Colors.white : AppColors.textPrimary, fontWeight: selected ? FontWeight.bold : FontWeight.normal))])]))));
}

class _PermissionsPanel extends StatelessWidget {
  final bool reviewAds;
  final bool hideAds;
  final ValueChanged<bool> onReviewChanged;
  final ValueChanged<bool> onHideChanged;
  const _PermissionsPanel({required this.reviewAds, required this.hideAds, required this.onReviewChanged, required this.onHideChanged});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(14)), child: Column(children: [
        Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(10)), child: Text(headSupervisorText(context, arabic: '3 مفعلة', english: '3 enabled'), style: TextStyle(fontSize: 8, color: AppColors.infoDark))), const Spacer(), Text(headSupervisorText(context, arabic: 'الصلاحيات الرقابية الأساسية', english: 'Core oversight permissions'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink))]),
        const SizedBox(height: 9),
        _PermissionSwitch(title: headSupervisorText(context, arabic: 'مراجعة وتحقيق الإعلانات قبل النشر', english: 'Review ads before publishing'), subtitle: headSupervisorText(context, arabic: 'فحص الالتزام بالضوابط والمعايير القياسية', english: 'Check compliance with standards and policies'), value: reviewAds, onChanged: onReviewChanged),
        const SizedBox(height: 6),
        _PermissionSwitch(title: headSupervisorText(context, arabic: 'إخفاء وتعليق الإعلانات المخالفة', english: 'Hide or suspend violating ads'), subtitle: headSupervisorText(context, arabic: 'حجب فوري مع إشعار البائع بسبب الإجراء', english: 'Hide immediately and notify the seller of the reason'), value: hideAds, onChanged: onHideChanged),
      ]));
}

class _PermissionSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PermissionSwitch({required this.title, required this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)), child: Row(children: [Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.primaryDark, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap), const SizedBox(width: 5), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(title, textAlign: TextAlign.right, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.ink)), Text(subtitle, textAlign: TextAlign.right, style: TextStyle(fontSize: 8, color: AppColors.textSecondary))]))]));
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(13)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [MotionIcon(Icons.verified_user_outlined, size: 16, color: AppColors.infoDark), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(headSupervisorText(context, arabic: 'ملاحظة أمنية:', english: 'Security note:'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.ink)), const SizedBox(height: 3), Text(headSupervisorText(context, arabic: 'لا تشمل هذه الصلاحيات العمليات المالية أو الحسابات وفق لائحة الحوكمة المعتمدة للمنظومة.', english: 'These permissions do not include financial operations or accounts under the platform governance policy.'), textAlign: TextAlign.right, style: TextStyle(fontSize: 8, height: 1.5, color: AppColors.textSecondary))]))]));
}
