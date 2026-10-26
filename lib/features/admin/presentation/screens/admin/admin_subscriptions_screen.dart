import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_subscription_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_subscription.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// متابعة اشتراكات المنظومة وتذكيرات التجديد. الحالة تُحسب من تاريخ التجديد.
class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() =>
      _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState extends State<AdminSubscriptionsScreen> {
  final _store = AdminSubscriptionStore();
  List<AdminSubscription> _items = const [];
  bool _loading = true;
  int _filter = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    AdminSubscriptionStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AdminSubscriptionStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await _store.getAll();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin subscriptions',
      ));
      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackBar.showError(
        context,
        adminText(context,
            ar: 'تعذر تحميل الاشتراكات.', en: 'Could not load subscriptions.'),
      );
    }
  }

  static String _date(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}/${two(t.month)}/${two(t.day)}';
  }

  String _remaining(AdminSubscription item) {
    final days = item.daysLeft();
    if (days < 0) {
      return adminText(context,
          ar: 'انتهى منذ ${-days} يومًا', en: 'Expired ${-days} day(s) ago');
    }
    if (days == 0) {
      return adminText(context, ar: 'ينتهي اليوم', en: 'Expires today');
    }
    return adminText(context,
        ar: 'ينتهي خلال $days يومًا', en: 'Expires in $days day(s)');
  }

  AdminTone _tone(AdminSubscription item) => switch (item.group()) {
        1 => AdminTone.danger,
        2 => AdminTone.warning,
        _ => AdminTone.success,
      };

  String _statusLabel(AdminSubscription item) => switch (item.group()) {
        1 => adminText(context, ar: 'عاجل', en: 'Urgent'),
        2 => adminText(context, ar: 'قريب', en: 'Soon'),
        _ => adminText(context, ar: 'سليم', en: 'Healthy'),
      };

  List<AdminSubscription> get _visible {
    final q = _query.trim().toLowerCase();
    return _items.where((item) {
      if (_filter != 0 && item.group() != _filter) return false;
      if (q.isEmpty) return true;
      return item.title.toLowerCase().contains(q) ||
          item.type.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _run(Future<void> Function() action, String okAr, String okEn) async {
    try {
      await action();
      if (!mounted) return;
      AppSnackBar.showSuccess(context, adminText(context, ar: okAr, en: okEn));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin subscriptions action',
      ));
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context, ar: 'تعذر تنفيذ الإجراء.', en: 'Could not complete the action.'),
      );
    }
  }

  void _open(AdminSubscription item) {
    showAdminDetailSheet(
      context,
      title: item.title,
      rows: [
        (adminText(context, ar: 'الحالة', en: 'Status'), _statusLabel(item)),
        (adminText(context, ar: 'النوع', en: 'Type'), item.type),
        (adminText(context, ar: 'تاريخ التجديد', en: 'Renewal date'), _date(item.renewalDate)),
        (adminText(context, ar: 'المتبقي', en: 'Remaining'), _remaining(item)),
        (adminText(context, ar: 'مدة التجديد', en: 'Renewal period'),
            adminText(context, ar: '${item.periodMonths} شهر', en: '${item.periodMonths} month(s)')),
        if (item.cost.isNotEmpty)
          (adminText(context, ar: 'التكلفة', en: 'Cost'), item.cost),
      ],
      actions: [
        Builder(
          builder: (sheetContext) => AdminPrimaryButton(
            label: adminText(sheetContext,
                ar: 'تسجيل التجديد (+${item.periodMonths} شهر)',
                en: 'Mark renewed (+${item.periodMonths} mo)'),
            color: AppColors.success,
            onPressed: () {
              Navigator.pop(sheetContext);
              _run(() => _store.markRenewed(item.id), 'تم تسجيل التجديد.',
                  'Renewal recorded.');
            },
          ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (sheetContext) => AdminPrimaryButton(
            label: adminText(sheetContext, ar: 'حذف الاشتراك', en: 'Delete subscription'),
            color: AppColors.danger,
            outlined: true,
            onPressed: () {
              Navigator.pop(sheetContext);
              _run(() => _store.remove(item.id), 'تم حذف الاشتراك.',
                  'Subscription deleted.');
            },
          ),
        ),
      ],
    );
  }

  Future<void> _add() async {
    final title = TextEditingController();
    final type = TextEditingController();
    final cost = TextEditingController();
    var date = DateTime.now().add(const Duration(days: 30));
    var period = 12;
    String? error;
    final created = await showDialog<AdminSubscription>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: Text(adminText(dialogContext, ar: 'إضافة اشتراك', en: 'Add subscription')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: InputDecoration(
                    labelText: adminText(dialogContext, ar: 'الاسم', en: 'Name'),
                    errorText: error,
                  ),
                ),
                TextField(
                  controller: type,
                  decoration: InputDecoration(
                    labelText: adminText(dialogContext,
                        ar: 'النوع (استضافة، مفتاح API...)', en: 'Type (hosting, API key...)'),
                  ),
                ),
                TextField(
                  controller: cost,
                  decoration: InputDecoration(
                    labelText: adminText(dialogContext, ar: 'التكلفة (اختياري)', en: 'Cost (optional)'),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const MotionIcon(Icons.event_outlined, size: 16),
                  label: Text(adminText(dialogContext,
                      ar: 'تاريخ التجديد: ${_date(date)}',
                      en: 'Renewal date: ${_date(date)}')),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: date,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 6)),
                    );
                    if (picked != null) setDialogState(() => date = picked);
                  },
                ),
                DropdownButtonFormField<int>(
                  initialValue: period,
                  decoration: InputDecoration(
                    labelText: adminText(dialogContext, ar: 'مدة التجديد', en: 'Renewal period'),
                  ),
                  items: const [1, 3, 6, 12, 24]
                      .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(adminText(dialogContext,
                              ar: '$m شهر', en: '$m month(s)'))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => period = v ?? 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty) {
                  setDialogState(() => error = adminText(dialogContext,
                      ar: 'الاسم مطلوب', en: 'Name is required'));
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  AdminSubscription(
                    id: 'sub-${DateTime.now().microsecondsSinceEpoch}',
                    title: title.text.trim(),
                    type: type.text.trim().isEmpty ? '—' : type.text.trim(),
                    cost: cost.text.trim(),
                    renewalDate: date,
                    periodMonths: period,
                  ),
                );
              },
              child: Text(adminText(dialogContext, ar: 'إضافة', en: 'Add')),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    type.dispose();
    cost.dispose();
    if (created == null || !mounted) return;
    await _run(() => _store.add(created), 'تمت إضافة الاشتراك.', 'Subscription added.');
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _items.where((e) => e.group() == 1).length;
    final soon = _items.where((e) => e.group() == 2).length;
    final visible = _visible;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0.5,
        title: Text(
          adminText(context, ar: 'اشتراكات المنظومة', en: 'System subscriptions'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: adminText(context, ar: 'إضافة اشتراك', en: 'Add subscription'),
            icon: const MotionIcon(Icons.add_circle_outline),
            onPressed: _add,
          ),
        ],
      ),
      body: AdminPage(
        children: [
          AdminHeroCard(
            badge: adminText(context, ar: 'تذكيرات التجديد', en: 'Renewal reminders'),
            title: urgent + soon == 0
                ? adminText(context, ar: 'كل الاشتراكات سليمة', en: 'All subscriptions are healthy')
                : adminText(context,
                    ar: '${urgent + soon} اشتراكات تحتاج تجديدًا قريبًا',
                    en: '${urgent + soon} subscription(s) need renewal soon'),
            subtitle: adminText(context,
                ar: 'عاجل: $urgent • قريب: $soon',
                en: 'Urgent: $urgent • Soon: $soon'),
            icon: Icons.event_repeat_outlined,
          ),
          const SizedBox(height: 14),
          AdminSearchField(
            hint: adminText(context, ar: 'ابحث في الاشتراكات', en: 'Search subscriptions'),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 10),
          AdminFilterBar(
            labels: [
              adminText(context, ar: 'الكل', en: 'All'),
              adminText(context, ar: 'عاجل', en: 'Urgent'),
              adminText(context, ar: 'قريب', en: 'Soon'),
              adminText(context, ar: 'سليم', en: 'Healthy'),
            ],
            selected: _filter,
            onSelected: (i) => setState(() => _filter = i),
          ),
          AdminSectionTitle(
            icon: Icons.subscriptions_outlined,
            title: adminText(context, ar: 'الاشتراكات', en: 'Subscriptions'),
            trailing: '${visible.length}',
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(adminText(context, ar: 'لا توجد اشتراكات', en: 'No subscriptions'),
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          for (final item in visible) ...[
            AdminListRow(
              icon: Icons.event_repeat_outlined,
              color: adminToneColor(_tone(item)),
              title: item.title,
              subtitle: '${_remaining(item)} • ${_date(item.renewalDate)}',
              trailing: AdminChip(label: _statusLabel(item), tone: _tone(item)),
              onTap: () => _open(item),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
