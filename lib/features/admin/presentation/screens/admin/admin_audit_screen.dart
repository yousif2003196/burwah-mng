import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_preferences_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_collection_view.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_audit_store.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_audit_store.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// سجل التدقيق + الإعدادات. المجموعات: 1 = قرارات، 2 = حسابات، 3 = مالية، 4 = أمان.
class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  bool _urgentAlerts = true;

  List<AdminItem> _items = const [];
  bool _loading = true;
  int _failedLast24h = 0;
  bool _exporting = false;

  /// عدد المحاولات الفاشلة خلال 24 ساعة الذي يُظهر تنبيه الأمان.
  static const _alertThreshold = 3;

  @override
  void initState() {
    super.initState();
    HeadSupervisorAuditStore.revision.addListener(_load);
    FinanceAuditStore.revision.addListener(_load);
    AdminRequestStore.revision.addListener(_load);
    _loadPrefs();
    _load();
  }

  @override
  void dispose() {
    HeadSupervisorAuditStore.revision.removeListener(_load);
    FinanceAuditStore.revision.removeListener(_load);
    AdminRequestStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    try {
      final value = await AdminPreferencesStore().urgentAlerts();
      if (!mounted) return;
      setState(() => _urgentAlerts = value);
    } catch (_) {
      // تبقى القيمة الافتراضية (مفعّل).
    }
  }

  Future<void> _setUrgentAlerts(bool value) async {
    final previous = _urgentAlerts;
    setState(() => _urgentAlerts = value);
    try {
      await AdminPreferencesStore().setUrgentAlerts(value);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin alert preference',
      ));
      if (!mounted) return;
      setState(() => _urgentAlerts = previous);
      AppSnackBar.showError(
        context,
        adminText(context, ar: 'تعذر حفظ الإعداد.', en: 'Could not save the setting.'),
      );
    }
  }

  static String _fmt(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}/${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }

  Future<void> _load() async {
    try {
      final entries = <(DateTime, AdminItem)>[];

      for (final r in await HeadSupervisorAuditStore().getAll()) {
        final (group, tone, icon, status) = switch (r.kind) {
          'supervisor_management' => (
              2,
              AdminTone.info,
              Icons.manage_accounts_outlined,
              (ar: 'حساب', en: 'Account'),
            ),
          'wallet' => (
              3,
              AdminTone.warning,
              Icons.account_balance_wallet_outlined,
              (ar: 'مالية', en: 'Finance'),
            ),
          _ => (
              1,
              AdminTone.success,
              Icons.fact_check_outlined,
              (ar: 'قرار', en: 'Decision'),
            ),
        };
        entries.add((
          r.occurredAt,
          AdminItem(
            title: (ar: r.title, en: r.title),
            subtitle: (
              ar: '${_fmt(r.occurredAt)} • ${r.subjectId}',
              en: '${_fmt(r.occurredAt)} • ${r.subjectId}',
            ),
            icon: icon,
            tone: tone,
            status: status,
            group: group,
            details: [
              ((ar: 'المصدر', en: 'Source'), (ar: 'رئيس المشرفين', en: 'Head supervisor')),
              ((ar: 'القسم', en: 'Department'), (ar: r.department, en: r.department)),
              ((ar: 'التفاصيل', en: 'Details'), (ar: r.details, en: r.details)),
            ],
          ),
        ));
      }

      for (final e in await FinanceAuditStore().getRecent()) {
        entries.add((
          e.occurredAt,
          AdminItem(
            title: (ar: e.titleAr, en: e.titleEn),
            subtitle: (
              ar: '${_fmt(e.occurredAt)} • ${e.reference}',
              en: '${_fmt(e.occurredAt)} • ${e.reference}',
            ),
            icon: Icons.receipt_long_outlined,
            tone: AdminTone.warning,
            status: (ar: 'مالية', en: 'Finance'),
            group: 3,
            details: [
              ((ar: 'المصدر', en: 'Source'), (ar: 'المشرف المالي', en: 'Finance supervisor')),
              ((ar: 'التفاصيل', en: 'Details'), (ar: e.detailsAr, en: e.detailsEn)),
            ],
          ),
        ));
      }

      for (final r in await AdminRequestStore().getAll()) {
        if (r.isPending || r.decidedAt == null) continue;
        final (labelAr, labelEn, tone) = switch (r.status) {
          AdminRequestStatus.approved => ('اعتماد', 'Approved', AdminTone.success),
          AdminRequestStatus.frozen => ('تجميد', 'Frozen', AdminTone.info),
          _ => ('رفض', 'Rejected', AdminTone.danger),
        };
        final financial = r.kind != AdminRequestKind.deletion &&
            r.kind != AdminRequestKind.escalation;
        entries.add((
          r.decidedAt!,
          AdminItem(
            title: (
              ar: 'قرار الأدمن ($labelAr): ${r.titleAr}',
              en: 'Admin decision ($labelEn): ${r.titleEn}',
            ),
            subtitle: (
              ar: '${_fmt(r.decidedAt!)} • ${r.refId}',
              en: '${_fmt(r.decidedAt!)} • ${r.refId}',
            ),
            icon: Icons.gavel_rounded,
            tone: tone,
            status: financial
                ? (ar: 'مالية', en: 'Finance')
                : (ar: 'قرار', en: 'Decision'),
            group: financial ? 3 : 1,
            details: [
              ((ar: 'المنفّذ', en: 'Actor'), (ar: 'الأدمن', en: 'Admin')),
              ((ar: 'الجهة المرسلة', en: 'Sent by'), (ar: r.fromAr, en: r.fromEn)),
              ((ar: 'الطلب', en: 'Request'), (ar: r.detailsAr, en: r.detailsEn)),
              if (r.decisionNote.isNotEmpty)
                ((ar: 'ملاحظة القرار', en: 'Decision note'), (ar: r.decisionNote, en: r.decisionNote)),
            ],
          ),
        ));
      }

      final securityLog = await AdminSecurityStore().getLog();
      final since = DateTime.now().subtract(const Duration(hours: 24));
      final failed24h =
          securityLog.where((a) => !a.success && a.at.isAfter(since)).length;
      for (final a in securityLog) {
        final label = switch (a.note) {
          'login_ok' => ('دخول ناجح', 'Successful sign-in'),
          'wrong_password' => ('كلمة مرور خاطئة', 'Wrong password'),
          'pin_failed' => ('فشل التحقق بخطوتين', '2FA failed'),
          _ => (a.note, a.note),
        };
        entries.add((
          a.at,
          AdminItem(
            title: (ar: label.$1, en: label.$2),
            subtitle: (
              ar: '${_fmt(a.at)} • ${a.email}',
              en: '${_fmt(a.at)} • ${a.email}',
            ),
            icon: a.success ? Icons.verified_user_outlined : Icons.gpp_bad_outlined,
            tone: a.success ? AdminTone.success : AdminTone.danger,
            status: (ar: 'أمان', en: 'Security'),
            group: 4,
            details: [
              ((ar: 'البريد', en: 'Email'), (ar: a.email, en: a.email)),
              ((ar: 'النتيجة', en: 'Result'),
                  a.success
                      ? (ar: 'نجاح', en: 'Success')
                      : (ar: 'فشل', en: 'Failure')),
            ],
          ),
        ));
      }

      entries.sort((a, b) => b.$1.compareTo(a.$1));
      if (!mounted) return;
      setState(() {
        _items = entries.take(300).map((entry) => entry.$2).toList();
        _failedLast24h = failed24h;
        _loading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin audit log',
      ));
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _export() async {
    if (_items.isEmpty || _exporting) return;
    setState(() => _exporting = true);
    try {
      final rows = [
        for (final item in _items)
          [
            item.subtitle.ar.split(' • ').first,
            item.status.ar,
            item.title.ar,
            item.subtitle.ar.contains(' • ')
                ? item.subtitle.ar.split(' • ').skip(1).join(' • ')
                : '',
            item.details.map((d) => '${d.$1.ar}: ${d.$2.ar}').join(' | '),
          ],
      ];
      await CsvExporter.share(
        fileName: 'admin_audit_${CsvExporter.stamp()}.csv',
        title: 'سجل التدقيق',
        headers: const ['التاريخ', 'النوع', 'الحدث', 'المرجع', 'التفاصيل'],
        rows: rows,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin audit export',
      ));
      if (mounted) {
        AppSnackBar.showError(
          context,
          adminText(context,
              ar: 'تعذر تصدير السجل', en: 'Could not export the log'),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminCollectionView(
      header: [
        if (_failedLast24h >= _alertThreshold)
          AdminCard(
            color: AppColors.dangerLight,
            borderColor: AppColors.dangerBorder,
            child: Row(
              children: [
                MotionIcon(Icons.gpp_maybe_outlined, color: AppColors.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    adminText(context,
                        ar: 'تنبيه أمني: $_failedLast24h محاولات دخول فاشلة إلى حساب الأدمن خلال آخر 24 ساعة. راجع تبويب الأمان وغيّر كلمة المرور إن لم تكن أنت.',
                        en: 'Security alert: $_failedLast24h failed sign-in attempts to the admin account in the last 24 hours. Review the Security tab and change the password if it was not you.'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        AdminSectionTitle(
          icon: Icons.tune_rounded,
          title: adminText(context, ar: 'إعدادات الأدمن', en: 'Admin settings'),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: _items.isEmpty || _exporting ? null : _export,
            icon: const MotionIcon(Icons.download_rounded, size: 15),
            label: Text(adminText(context,
                ar: 'تصدير السجل CSV', en: 'Export log CSV')),
          ),
        ),
        AdminCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              _SettingSwitch(
                icon: Icons.notifications_active_outlined,
                title: adminText(context, ar: 'تنبيهات التصعيدات العاجلة', en: 'Urgent escalation alerts'),
                value: _urgentAlerts,
                onChanged: _setUrgentAlerts,
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                leading: MotionIcon(Icons.mark_email_unread_outlined,
                    color: AppColors.textSecondary, size: 20),
                title: Text(
                  adminText(context, ar: 'ملخص يومي بالبريد', en: 'Daily email digest'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  adminText(context,
                      ar: 'يتوفر بعد ربط الخادم (إرسال البريد يحتاج backend)',
                      en: 'Available once the server is connected (email needs a backend)'),
                  style: const TextStyle(fontSize: 10.5),
                ),
              ),
            ],
          ),
        ),
      ],
      searchHint: (ar: 'ابحث في السجل', en: 'Search the log'),
      filters: const [
        (ar: 'الكل', en: 'All'),
        (ar: 'قرارات', en: 'Decisions'),
        (ar: 'حسابات', en: 'Accounts'),
        (ar: 'مالية', en: 'Finance'),
        (ar: 'الأمان', en: 'Security'),
      ],
      listTitle: (ar: 'سجل التدقيق', en: 'Audit log'),
      listIcon: Icons.history_rounded,
      items: _items,
      emptyHint: _loading
          ? null
          : (ar: 'لا توجد سجلات بعد. ستظهر هنا قرارات الأدمن والرؤساء والمالية.', en: 'No records yet. Admin, head and finance actions will appear here.'),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.success,
      secondary: MotionIcon(icon, color: AppColors.ink, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}
