import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../head_supervisor_text.dart';

const _headSupervisorLocationsEn = <String, String>{
  'تجار ومتاجر': 'Merchants and stores', 'إعلانات جديدة': 'New ads',
  'مستعملة ووصلي': 'Used items and Wasalny', 'خدمات وصيانة': 'Services and maintenance',
  'متاجر الإلكترونيات والأجهزة المعتمدة': 'Approved electronics stores',
  'متاجر السيارات والمركبات': 'Cars and vehicles stores',
  'إعلانات الخدمات والعروض': 'Service and offer ads',
  'جميع المتاجر المعتمدة': 'All approved stores',
  'القاهرة': 'Cairo', 'الجيزة': 'Giza', 'الإسكندرية': 'Alexandria',
  'القليوبية': 'Qalyubia', 'البحيرة': 'Beheira', 'مطروح': 'Matrouh',
  'دمياط': 'Damietta', 'الدقهلية': 'Dakahlia', 'كفر الشيخ': 'Kafr El Sheikh',
  'الغربية': 'Gharbia', 'المنوفية': 'Monufia', 'الشرقية': 'Sharqia',
  'الإسماعيلية': 'Ismailia', 'بورسعيد': 'Port Said', 'السويس': 'Suez',
  'شمال سيناء': 'North Sinai', 'جنوب سيناء': 'South Sinai', 'الفيوم': 'Faiyum',
  'بني سويف': 'Beni Suef', 'المنيا': 'Minya', 'أسيوط': 'Assiut',
  'سوهاج': 'Sohag', 'قنا': 'Qena', 'الأقصر': 'Luxor', 'أسوان': 'Aswan',
  'البحر الأحمر': 'Red Sea', 'الوادي الجديد': 'New Valley',
  'مدينة نصر': 'Nasr City', 'مصر الجديدة': 'Heliopolis', 'المعادي': 'Maadi',
  'حلوان': 'Helwan', 'الشروق': 'El Shorouk', 'بدر': 'Badr',
  '6 أكتوبر': '6th of October', 'الشيخ زايد': 'Sheikh Zayed', 'الهرم': 'Haram',
  'فيصل': 'Faisal', 'البدرشين': 'Badrashin', 'برج العرب': 'Borg El Arab',
  'العجمي': 'Agami', 'العامرية': 'Amreya', 'بنها': 'Banha',
  'شبرا الخيمة': 'Shubra El Kheima', 'العبور': 'Obour', 'قليوب': 'Qalyub',
  'القناطر الخيرية': 'Qanater Khairia', 'دمنهور': 'Damanhur', 'كفر الدوار': 'Kafr El Dawar',
  'رشيد': 'Rosetta', 'إدكو': 'Edku', 'وادي النطرون': 'Wadi El Natrun',
  'مرسى مطروح': 'Marsa Matrouh', 'العلمين': 'El Alamein', 'الحمام': 'El Hammam',
  'سيوة': 'Siwa', 'الضبعة': 'El Dabaa', 'دمياط الجديدة': 'New Damietta',
  'رأس البر': 'Ras El Bar', 'فارسكور': 'Faraskur', 'المنصورة': 'Mansoura',
  'ميت غمر': 'Mit Ghamr', 'طلخا': 'Talkha', 'دكرنس': 'Dekernes',
  'دسوق': 'Desouk', 'بلطيم': 'Baltim', 'الحامول': 'El Hamoul',
  'طنطا': 'Tanta', 'المحلة الكبرى': 'El Mahalla El Kubra', 'زفتى': 'Zifta',
  'كفر الزيات': 'Kafr El Zayat', 'شبين الكوم': 'Shibin El Kom', 'منوف': 'Menouf',
  'السادات': 'Sadat City', 'أشمون': 'Ashmoun', 'الزقازيق': 'Zagazig',
  'العاشر من رمضان': '10th of Ramadan', 'بلبيس': 'Belbeis', 'منيا القمح': 'Minya El Qamh',
  'فايد': 'Fayed', 'القنطرة شرق': 'Qantara Sharq', 'القنطرة غرب': 'Qantara Gharb',
  'بورفؤاد': 'Port Fouad', 'عتاقة': 'Ataqa', 'الأربعين': 'Arbaeen',
  'العريش': 'Arish', 'بئر العبد': 'Bir El Abd', 'رفح': 'Rafah', 'الشيخ زويد': 'Sheikh Zuweid',
  'الطور': 'El Tor', 'شرم الشيخ': 'Sharm El Sheikh', 'دهب': 'Dahab', 'نويبع': 'Nuweiba',
  'طابا': 'Taba', 'سنورس': 'Sannuris', 'إطسا': 'Itsa', 'طامية': 'Tamia',
  'الفشن': 'El Fashn', 'ناصر': 'Nasser', 'إهناسيا': 'Ihnasiya', 'ملوي': 'Mallawi',
  'سمالوط': 'Samalut', 'مغاغة': 'Maghagha', 'ديروط': 'Dayrout', 'منفلوط': 'Manfalut',
  'القوصية': 'El Qusiya', 'أخميم': 'Akhmim', 'جرجا': 'Girga', 'طهطا': 'Tahta',
  'نجع حمادي': 'Nag Hammadi', 'قوص': 'Qus', 'دشنا': 'Deshna', 'إسنا': 'Esna',
  'أرمنت': 'Armant', 'كوم أمبو': 'Kom Ombo', 'إدفو': 'Edfu', 'أبو سمبل': 'Abu Simbel',
  'الغردقة': 'Hurghada', 'رأس غارب': 'Ras Gharib', 'سفاجا': 'Safaga', 'القصير': 'El Quseir',
  'مرسى علم': 'Marsa Alam', 'الخارجة': 'Kharga', 'الداخلة': 'Dakhla', 'الفرافرة': 'Farafra',
  'باريس': 'Paris',
};

String _headSupervisorOptionText(BuildContext context, String value) =>
    headSupervisorText(context, arabic: value, english: _headSupervisorLocationsEn[value] ?? value);

class HeadSupervisorPermissionsDraft {
  final String department;
  final String area;
  final String city;
  final String marketScope;

  const HeadSupervisorPermissionsDraft({required this.department, required this.area, required this.city, required this.marketScope});
}

class HeadSupervisorEditPermissionsSheet extends StatefulWidget {
  final String supervisorId;
  final String name;
  final String department;
  final String area;
  final String city;
  final String marketScope;
  final String avatar;
  final Color avatarColor;

  const HeadSupervisorEditPermissionsSheet({
    super.key,
    required this.supervisorId,
    required this.name,
    required this.department,
    required this.area,
    required this.city,
    required this.marketScope,
    required this.avatar,
    required this.avatarColor,
  });

  @override
  State<HeadSupervisorEditPermissionsSheet> createState() =>
      _HeadSupervisorEditPermissionsSheetState();
}

class _HeadSupervisorEditPermissionsSheetState
    extends State<HeadSupervisorEditPermissionsSheet> {
  static const _governorates = [
    'القاهرة', 'الجيزة', 'الإسكندرية', 'القليوبية', 'البحيرة', 'مطروح',
    'دمياط', 'الدقهلية', 'كفر الشيخ', 'الغربية', 'المنوفية', 'الشرقية',
    'الإسماعيلية', 'بورسعيد', 'السويس', 'شمال سيناء', 'جنوب سيناء',
    'الفيوم', 'بني سويف', 'المنيا', 'أسيوط', 'سوهاج', 'قنا', 'الأقصر',
    'أسوان', 'البحر الأحمر', 'الوادي الجديد',
  ];
  static const Map<String, List<String>> _citiesByGovernorate = {
    'القاهرة': ['القاهرة', 'مدينة نصر', 'مصر الجديدة', 'المعادي', 'حلوان', 'الشروق', 'بدر'],
    'الجيزة': ['الجيزة', '6 أكتوبر', 'الشيخ زايد', 'الهرم', 'فيصل', 'البدرشين'],
    'الإسكندرية': ['الإسكندرية', 'برج العرب', 'العجمي', 'العامرية'],
    'القليوبية': ['بنها', 'شبرا الخيمة', 'العبور', 'قليوب', 'القناطر الخيرية'],
    'البحيرة': ['دمنهور', 'كفر الدوار', 'رشيد', 'إدكو', 'وادي النطرون'],
    'مطروح': ['مرسى مطروح', 'العلمين', 'الحمام', 'سيوة', 'الضبعة'],
    'دمياط': ['دمياط', 'دمياط الجديدة', 'رأس البر', 'فارسكور'],
    'الدقهلية': ['المنصورة', 'ميت غمر', 'طلخا', 'دكرنس'],
    'كفر الشيخ': ['كفر الشيخ', 'دسوق', 'بلطيم', 'الحامول'],
    'الغربية': ['طنطا', 'المحلة الكبرى', 'زفتى', 'كفر الزيات'],
    'المنوفية': ['شبين الكوم', 'منوف', 'السادات', 'أشمون'],
    'الشرقية': ['الزقازيق', 'العاشر من رمضان', 'بلبيس', 'منيا القمح'],
    'الإسماعيلية': ['الإسماعيلية', 'فايد', 'القنطرة شرق', 'القنطرة غرب'],
    'بورسعيد': ['بورسعيد', 'بورفؤاد'],
    'السويس': ['السويس', 'عتاقة', 'الأربعين'],
    'شمال سيناء': ['العريش', 'بئر العبد', 'رفح', 'الشيخ زويد'],
    'جنوب سيناء': ['الطور', 'شرم الشيخ', 'دهب', 'نويبع', 'طابا'],
    'الفيوم': ['الفيوم', 'سنورس', 'إطسا', 'طامية'],
    'بني سويف': ['بني سويف', 'الفشن', 'ناصر', 'إهناسيا'],
    'المنيا': ['المنيا', 'ملوي', 'سمالوط', 'مغاغة'],
    'أسيوط': ['أسيوط', 'ديروط', 'منفلوط', 'القوصية'],
    'سوهاج': ['سوهاج', 'أخميم', 'جرجا', 'طهطا'],
    'قنا': ['قنا', 'نجع حمادي', 'قوص', 'دشنا'],
    'الأقصر': ['الأقصر', 'إسنا', 'أرمنت'],
    'أسوان': ['أسوان', 'كوم أمبو', 'إدفو', 'أبو سمبل'],
    'البحر الأحمر': ['الغردقة', 'رأس غارب', 'سفاجا', 'القصير', 'مرسى علم'],
    'الوادي الجديد': ['الخارجة', 'الداخلة', 'الفرافرة', 'باريس'],
  };
  static const _markets = ['متاجر الإلكترونيات والأجهزة المعتمدة', 'متاجر السيارات والمركبات', 'إعلانات الخدمات والعروض', 'جميع المتاجر المعتمدة'];

  late String _department = _departmentFromName(widget.department);
  late String _governorate = _governorates.contains(widget.area) ? widget.area : _governorates.first;
  late String _city = (_citiesByGovernorate[widget.area] ?? _citiesByGovernorate[_governorates.first]!).contains(widget.city)
      ? widget.city
      : (_citiesByGovernorate[widget.area] ?? _citiesByGovernorate[_governorates.first]!).first;
  late String _marketScope = _markets.contains(widget.marketScope) ? widget.marketScope : _markets.first;

  String _departmentFromName(String value) {
    if (value.contains('منتج') || value.contains('إعلان')) return 'إعلانات جديدة';
    if (value.contains('مستعمل')) return 'مستعملة ووصلي';
    if (value.contains('خدمات') || value.contains('صيانة')) return 'خدمات وصيانة';
    return 'تجار ومتاجر';
  }

  void _save() => Navigator.of(context).pop(HeadSupervisorPermissionsDraft(
        department: _department,
        area: _governorate,
        city: _city,
        marketScope: _marketScope,
      ));

  @override
  Widget build(BuildContext context) => AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .94),
            decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
            child: Column(children: [
              const SizedBox(height: 10),
              Container(width: 42, height: 5, decoration: BoxDecoration(color: const Color(0xFFD9DDE2), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 8),
              _Header(onClose: () => Navigator.pop(context)),
              Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 5, 18, 14), children: [
                _SupervisorSummary(id: widget.supervisorId, name: widget.name, department: widget.department, avatar: widget.avatar, color: widget.avatarColor),
                const SizedBox(height: 15),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(headSupervisorText(context, arabic: 'نطاق البيانات والصلاحية المكانية', english: 'Data and geographic access scope'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), const SizedBox(width: 5), const Icon(Icons.public_outlined, size: 16, color: Color(0xFF42699F))]),
                const SizedBox(height: 8),
                _DropdownField(label: headSupervisorText(context, arabic: 'المحافظة', english: 'Governorate'), value: _governorate, options: _governorates, icon: Icons.location_on_outlined, helper: headSupervisorText(context, arabic: 'اختر المحافظة المصرية لنطاق الإشراف', english: 'Select the governorate for this assignment'), onChanged: (value) => setState(() {
                  _governorate = value;
                  _city = _citiesByGovernorate[value]!.first;
                })),
                const SizedBox(height: 8),
                _DropdownField(label: headSupervisorText(context, arabic: 'المدينة', english: 'City'), value: _city, options: _citiesByGovernorate[_governorate]!, icon: Icons.location_city_outlined, helper: headSupervisorText(context, arabic: 'المدن المتاحة داخل محافظة $_governorate', english: 'Available cities in $_governorate'), onChanged: (value) => setState(() => _city = value)),
                const SizedBox(height: 8),
                _DropdownField(label: headSupervisorText(context, arabic: 'فئة المتاجر المحددة للاختصاص', english: 'Store category scope'), value: _marketScope, options: _markets, icon: Icons.store_mall_directory_outlined, helper: headSupervisorText(context, arabic: 'اختر الفئة التي سيشرف عليها الحساب', english: 'Select the category assigned to this account'), onChanged: (value) => setState(() => _marketScope = value)),
                const SizedBox(height: 17),
                Row(children: [Text(headSupervisorText(context, arabic: 'مطلوب للاعتماد', english: 'Required'), style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)), const Spacer(), Text(headSupervisorText(context, arabic: 'القسم الإشرافي المكلف به *', english: 'Assigned department *'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), const Icon(Icons.account_tree_outlined, size: 15, color: Color(0xFF42699F))]),
                const SizedBox(height: 8),
                _DepartmentGrid(selected: _department, onChanged: (value) => setState(() => _department = value)),
                const SizedBox(height: 14),
                const _SecurityWarning(),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [const Icon(Icons.lock_clock_outlined, size: 13, color: AppColors.textSecondary), const SizedBox(width: 4), Text(headSupervisorText(context, arabic: 'يتم توثيق كافة التعديلات في سجل التدقيق الرقابي برقم رقمي مستقل', english: 'All changes are recorded in the oversight audit log with a unique reference.'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))]),
              ])),
              Padding(padding: const EdgeInsets.fromLTRB(18, 4, 18, 12), child: Column(children: [
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check_circle_outline, size: 17), label: Text(headSupervisorText(context, arabic: 'حفظ وتحديث الصلاحيات فوراً', english: 'Save and update access'), style: const TextStyle(fontWeight: FontWeight.w600)), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF071A31), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                const SizedBox(height: 7),
                SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(backgroundColor: const Color(0xFFEBEDEF), foregroundColor: AppColors.textSecondary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(headSupervisorText(context, arabic: 'إلغاء والتراجع', english: 'Cancel')))),
              ])),
            ]),
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Row(children: [
        const Icon(Icons.admin_panel_settings_outlined, size: 19, color: AppColors.primaryDark),
        const SizedBox(width: 6),
        Text(headSupervisorText(context, arabic: 'تعديل صلاحيات ونطاق المشرف', english: 'Edit supervisor access and scope'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        const Spacer(),
        IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 18), style: IconButton.styleFrom(backgroundColor: const Color(0xFFEBEDEF))),
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
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFFF0F2F4), borderRadius: BorderRadius.circular(14)), child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: color, child: Text(avatar, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), const SizedBox(width: 5), _IdBadge(id)]), Text(headSupervisorText(context, arabic: 'مشرف $department', english: 'Supervisor • $department'), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)), Row(mainAxisAlignment: MainAxisAlignment.end, children: [const Icon(Icons.verified_user_outlined, size: 12, color: Color(0xFF42699F)), Text(headSupervisorText(context, arabic: 'نشط ومراقب', english: 'Active and monitored'), style: const TextStyle(fontSize: 8, color: Color(0xFF42699F)))])])),
      ]));
}

class _IdBadge extends StatelessWidget {
  final String id;
  const _IdBadge(this.id);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFE0E9FA), borderRadius: BorderRadius.circular(9)), child: Text(id, style: const TextStyle(fontSize: 8, color: Color(0xFF315E9A))));
}

class _DepartmentGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _DepartmentGrid({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    const options = [
      ('تجار ومتاجر', Icons.storefront_outlined),
      ('إعلانات جديدة', Icons.campaign_outlined),
      ('مستعملة ووصلي', Icons.sync_outlined),
      ('خدمات وصيانة', Icons.design_services_outlined),
    ];
    return Column(children: [for (var row = 0; row < 2; row++) ...[
      if (row > 0) const SizedBox(height: 7),
      Row(children: [for (var column = 0; column < 2; column++) ...[
        if (column > 0) const SizedBox(width: 7),
        Expanded(child: _DepartmentChip(label: options[row * 2 + column].$1, icon: options[row * 2 + column].$2, selected: selected == options[row * 2 + column].$1, onTap: () => onChanged(options[row * 2 + column].$1))),
      ]]),
    ]]);
  }
}

class _DepartmentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _DepartmentChip({required this.label, required this.icon, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: selected ? const Color(0xFF0B294A) : const Color(0xFFF0F2F4), borderRadius: BorderRadius.circular(12), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(selected ? Icons.check_circle_outline : Icons.circle_outlined, size: 14, color: selected ? const Color(0xFFCADAF2) : const Color(0xFFD6DADD)), Row(children: [Icon(icon, size: 15, color: selected ? Colors.white : const Color(0xFF536173)), const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 9, color: selected ? Colors.white : AppColors.textPrimary, fontWeight: selected ? FontWeight.bold : FontWeight.normal))])]))));
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final IconData icon;
  final String helper;
  final ValueChanged<String> onChanged;
  const _DropdownField({required this.label, required this.value, required this.options, required this.icon, required this.helper, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF0F2F4), borderRadius: BorderRadius.circular(13)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: const EdgeInsets.only(right: 6, bottom: 5), child: Text(_headSupervisorOptionText(context, label), textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Row(children: [
          const SizedBox(width: 7),
          Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFE8EFFC), borderRadius: BorderRadius.circular(9)), child: Icon(icon, size: 18, color: const Color(0xFF315E9A))),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_headSupervisorOptionText(context, value), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark)), Text(_headSupervisorOptionText(context, helper), textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))])),
          PopupMenuButton<String>(tooltip: _headSupervisorOptionText(context, label), icon: const Icon(Icons.unfold_more, size: 17, color: AppColors.textSecondary), onSelected: onChanged, itemBuilder: (_) => [for (final option in options) PopupMenuItem(value: option, child: Text(_headSupervisorOptionText(context, option), style: const TextStyle(fontSize: 11)))]),
        ])),
      ]));
}

class _SecurityWarning extends StatelessWidget {
  const _SecurityWarning();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF0EF), borderRadius: BorderRadius.circular(14)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(headSupervisorText(context, arabic: 'تنبيه رقابي مشدد', english: 'Important oversight notice'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.dangerDark)), const SizedBox(height: 5), Text(headSupervisorText(context, arabic: 'لا يملك رئيس المشرفين صلاحية منح صلاحيات مالية مباشرة أو الحسابات الحساسة للمستخدمين، والتجار يخضعون للائحة الحوكمة والسياسات المالية للمنصة.', english: 'The Head Supervisor cannot grant direct financial or sensitive account access. Merchants remain subject to platform governance and financial policies.'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, height: 1.5, color: AppColors.dangerDark))])),
        const SizedBox(width: 8),
        const CircleAvatar(radius: 15, backgroundColor: const Color(0xFFFFD9D6), child: const Icon(Icons.shield_outlined, size: 16, color: AppColors.dangerDark)),
      ]));
}
