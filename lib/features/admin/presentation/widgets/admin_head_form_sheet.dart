import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/domain/entities/head_account.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// نموذج إضافة/تعديل رئيس مشرفين. يرجع السجل بعد التحقق من الحقول.
class AdminHeadFormSheet extends StatefulWidget {
  final HeadAccountRecord? initial;
  final String newId;

  /// رؤساء المشرفين الآخرون (للتحقق من تكرار البريد وتنبيه تشابه القطاعات).
  final List<HeadAccountRecord> otherHeads;

  /// بريدات مستخدمة في حسابات أخرى (مشرفون تنفيذيون...).
  final Set<String> otherEmails;

  const AdminHeadFormSheet({
    super.key,
    this.initial,
    required this.newId,
    this.otherHeads = const [],
    this.otherEmails = const {},
  });

  @override
  State<AdminHeadFormSheet> createState() => _AdminHeadFormSheetState();
}

class _AdminHeadFormSheetState extends State<AdminHeadFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late Set<String> _sectors;
  late Set<HeadPermission> _permissions;
  String? _error;

  static const _presets = <(String, String, Set<HeadPermission>)>[
    ('كامل', 'Full', {
      HeadPermission.reviewAds,
      HeadPermission.settleDisputes,
      HeadPermission.approveRefunds,
      HeadPermission.manageSupervisors,
    }),
    ('مالي فقط', 'Finance only', {
      HeadPermission.settleDisputes,
      HeadPermission.approveRefunds,
    }),
    ('مراجعة فقط', 'Review only', {HeadPermission.reviewAds}),
  ];

  static const _sensitive = {
    HeadPermission.settleDisputes,
    HeadPermission.approveRefunds,
    HeadPermission.manageSupervisors,
  };

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _email = TextEditingController(text: initial?.email ?? '');
    _phone = TextEditingController(text: initial?.phone ?? '');
    _sectors = initial == null ? <String>{} : HeadSectors.parse(initial.sector);
    _permissions = {...?initial?.permissions};
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  /// أرقام الهاتف المقبولة: 8 إلى 15 رقمًا مع السماح بـ + والمسافات والشرطة.
  static bool _validPhone(String value) {
    if (value.isEmpty) return true;
    if (!RegExp(r'^[+0-9\s\-()]+$').hasMatch(value)) return false;
    final digits = value.replaceAll(RegExp(r'\D'), '').length;
    return digits >= 8 && digits <= 15;
  }

  /// أرقام الهاتف العربية (٠١٢) تتحول إلى إنجليزية.
  static String _westernDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      final index = arabic.indexOf(ch);
      buffer.write(index >= 0 ? '$index' : ch);
    }
    return buffer.toString();
  }

  void _fail(String ar, String en) =>
      setState(() => _error = adminText(context, ar: ar, en: en));

  void _submit() {
    final name = _name.text.trim();
    final email = _email.text.trim().toLowerCase();
    final phone = _westernDigits(_phone.text.trim());
    if (name.isEmpty) {
      _fail('الاسم مطلوب.', 'Name is required.');
      return;
    }
    if (_sectors.isEmpty) {
      _fail('اختر قسمًا واحدًا على الأقل كقطاع.',
          'Select at least one department as the sector.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _fail('أدخل بريدًا إلكترونيًا صحيحًا.', 'Enter a valid email.');
      return;
    }
    final emailTaken = widget.otherEmails.contains(email) ||
        widget.otherHeads
            .any((h) => h.email.trim().toLowerCase() == email);
    if (emailTaken) {
      _fail('هذا البريد مسجل لحساب آخر.',
          'This email is registered to another account.');
      return;
    }
    if (!_validPhone(phone)) {
      _fail('رقم الهاتف غير صحيح (8 إلى 15 رقمًا).',
          'Invalid phone number (8 to 15 digits).');
      return;
    }
    final sector = HeadSectors.join(_sectors);
    final initial = widget.initial;
    Navigator.of(context).pop(
      initial == null
          ? HeadAccountRecord(
              id: widget.newId,
              name: name,
              email: email,
              phone: phone,
              sector: sector,
              permissions: _permissions,
              createdAt: DateTime.now(),
            )
          : initial.copyWith(
              name: name,
              email: email,
              phone: phone,
              sector: sector,
              permissions: _permissions,
            ),
    );
  }

  /// رؤساء نشطون آخرون يشاركون أحد الأقسام المختارة (تنبيه فقط).
  List<String> get _overlaps {
    final result = <String>[];
    for (final head in widget.otherHeads) {
      if (head.suspended) continue;
      final shared = HeadSectors.parse(head.sector).intersection(_sectors);
      if (shared.isNotEmpty) {
        result.add('${head.name} (${shared.join('، ')})');
      }
    }
    return result;
  }

  Widget _field(TextEditingController controller, String label,
      {TextInputType? type, bool ltr = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: type,
        textDirection: ltr ? TextDirection.ltr : null,
        onChanged: (_) => setState(() => _error = null),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 6),
        child: Text(text,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      );

  String _sensitiveNote(HeadPermission permission) => switch (permission) {
        HeadPermission.settleDisputes =>
          adminText(context,
              ar: 'يقرر في نزاعات التجار والعملاء ويرفعها للأدمن.',
              en: 'Decides merchant/customer disputes and escalates to admin.'),
        HeadPermission.approveRefunds =>
          adminText(context,
              ar: 'يعتمد استردادات مالية فعلية.',
              en: 'Approves real financial refunds.'),
        HeadPermission.manageSupervisors =>
          adminText(context,
              ar: 'يضيف المشرفين ويوقفهم ويعدّل نطاقاتهم.',
              en: 'Adds, suspends and re-scopes supervisors.'),
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    final overlaps = _overlaps;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .9),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      editing
                          ? adminText(context, ar: 'تعديل رئيس مشرفين', en: 'Edit head supervisor')
                          : adminText(context, ar: 'إضافة رئيس مشرفين', en: 'Add head supervisor'),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink),
                    ),
                  ),
                  AdminChip(
                    label: editing ? widget.initial!.id : widget.newId,
                    tone: AdminTone.info,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _field(_name, adminText(context, ar: 'الاسم الكامل', en: 'Full name')),
              _field(_email, adminText(context, ar: 'البريد الإلكتروني للدخول', en: 'Login email'),
                  type: TextInputType.emailAddress, ltr: true),
              _field(_phone, adminText(context, ar: 'رقم الهاتف', en: 'Phone'),
                  type: TextInputType.phone, ltr: true),
              _sectionLabel(adminText(context, ar: 'القطاع (اختر قسمًا أو أكثر)', en: 'Sector (pick one or more)')),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final sector in HeadSectors.all)
                    FilterChip(
                      label: Text(sector, style: const TextStyle(fontSize: 12)),
                      selected: _sectors.contains(sector),
                      onSelected: (on) => setState(() {
                        _error = null;
                        if (on) {
                          _sectors.add(sector);
                        } else {
                          _sectors.remove(sector);
                        }
                      }),
                    ),
                ],
              ),
              if (overlaps.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  adminText(context,
                      ar: 'تنبيه: يشاركه في نفس القسم ${overlaps.join(' • ')}.',
                      en: 'Note: shares a department with ${overlaps.join(' • ')}.'),
                  style: TextStyle(
                      fontSize: 11.5, color: AppColors.warningDark),
                ),
              ],
              const SizedBox(height: 12),
              _sectionLabel(adminText(context, ar: 'الصلاحيات', en: 'Permissions')),
              Wrap(
                spacing: 8,
                children: [
                  for (final preset in _presets)
                    ActionChip(
                      avatar: const MotionIcon(Icons.auto_fix_high_rounded, size: 15),
                      label: Text(
                          adminText(context, ar: preset.$1, en: preset.$2),
                          style: const TextStyle(fontSize: 12)),
                      onPressed: () => setState(() => _permissions = {...preset.$3}),
                    ),
                ],
              ),
              for (final permission in HeadPermission.values)
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.successDark,
                  title: Text(
                      adminText(context, ar: permission.labelAr, en: permission.labelEn),
                      style: const TextStyle(fontSize: 12.5)),
                  subtitle: _sensitive.contains(permission) &&
                          _permissions.contains(permission)
                      ? Text(_sensitiveNote(permission),
                          style: TextStyle(
                              fontSize: 11, color: AppColors.warningDark))
                      : null,
                  value: _permissions.contains(permission),
                  onChanged: (value) => setState(() {
                    if (value) {
                      _permissions.add(permission);
                    } else {
                      _permissions.remove(permission);
                    }
                  }),
                ),
              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(_error!,
                    style: TextStyle(color: AppColors.dangerDark, fontSize: 12)),
              ],
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: AdminPrimaryButton(
                  label: editing
                      ? adminText(context, ar: 'حفظ التعديلات', en: 'Save changes')
                      : adminText(context, ar: 'إنشاء الحساب', en: 'Create account'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
