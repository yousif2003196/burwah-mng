import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';

/// عنصر قائمة عام (مشرف، تصعيد، طلب، مستخدم...) ببيانات ثنائية اللغة.
class AdminItem {
  final Bi title;
  final Bi subtitle;
  final IconData icon;
  final AdminTone tone;
  final Bi status;

  /// رقم الفئة المرتبطة بشريط الفلاتر (0 = الكل لا يُستخدم هنا).
  final int group;
  final List<(Bi, Bi)> details;

  const AdminItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.status,
    required this.group,
    this.details = const [],
  });
}

/// إجراء يظهر أسفل ورقة التفاصيل.
class AdminAction {
  final Bi label;
  final Bi toast;
  final Color? _color;
  Color get color => _color ?? AppColors.primaryDark;
  final bool outlined;

  const AdminAction({
    required this.label,
    required this.toast,
    Color? color,
    this.outlined = false,
  }) : _color = color;
}

/// شاشة قائمة عامة: عناصر علوية + بحث + فلاتر + عناصر + ورقة تفاصيل بإجراءات.
class AdminCollectionView extends StatefulWidget {
  final List<Widget> header;
  final List<Bi> filters;
  final List<AdminItem> items;
  final Bi searchHint;
  final List<AdminAction> actions;
  final Bi listTitle;
  final IconData listIcon;

  /// نص الحالة الفارغة عندما لا توجد عناصر إطلاقًا (اختياري).
  final Bi? emptyHint;

  const AdminCollectionView({
    super.key,
    required this.items,
    required this.filters,
    required this.searchHint,
    required this.listTitle,
    required this.listIcon,
    this.header = const [],
    this.actions = const [],
    this.emptyHint,
  });

  @override
  State<AdminCollectionView> createState() => _AdminCollectionViewState();
}

class _AdminCollectionViewState extends State<AdminCollectionView> {
  int _filter = 0;
  String _query = '';

  List<AdminItem> _visible(BuildContext context) {
    return widget.items.where((item) {
      if (_filter != 0 && item.group != _filter) return false;
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      return item.title.ar.toLowerCase().contains(q) ||
          item.title.en.toLowerCase().contains(q) ||
          item.subtitle.ar.toLowerCase().contains(q) ||
          item.subtitle.en.toLowerCase().contains(q);
    }).toList();
  }

  void _openDetails(BuildContext context, AdminItem item) {
    showAdminDetailSheet(
      context,
      title: item.title.of(context),
      rows: [
        (adminText(context, ar: 'الحالة', en: 'Status'), item.status.of(context)),
        for (final row in item.details) (row.$1.of(context), row.$2.of(context)),
      ],
      actions: [
        for (final action in widget.actions)
          AdminPrimaryButton(
            label: action.label.of(context),
            color: action.color,
            outlined: action.outlined,
            onPressed: () {
              Navigator.of(context).pop();
              AppSnackBar.showSuccess(context, action.toast.of(context));
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible(context);
    return AdminPage(
      children: [
        ...widget.header,
        if (widget.header.isNotEmpty) const SizedBox(height: 14),
        AdminSearchField(
          hint: widget.searchHint.of(context),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 10),
        AdminFilterBar(
          labels: [for (final f in widget.filters) f.of(context)],
          selected: _filter,
          onSelected: (index) => setState(() => _filter = index),
        ),
        AdminSectionTitle(
          icon: widget.listIcon,
          title: widget.listTitle.of(context),
          trailing: '${visible.length}',
        ),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Text(
                (widget.items.isEmpty ? widget.emptyHint : null)?.of(context) ??
                    adminText(context, ar: 'لا توجد نتائج', en: 'No results'),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          for (final item in visible) ...[
            AdminListRow(
              icon: item.icon,
              color: adminToneColor(item.tone),
              title: item.title.of(context),
              subtitle: item.subtitle.of(context),
              trailing: AdminChip(
                label: item.status.of(context),
                tone: item.tone,
              ),
              onTap: () => _openDetails(context, item),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}
