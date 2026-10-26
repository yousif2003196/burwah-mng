import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_preferences_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_payment_channels_panel.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_request_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_summary_entity.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_finance_summary_usecase.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// المالية: جلسة اعتماد سيادية، السيولة، الطلبات المحالة، وقنوات الدفع.
class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});

  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> {
  final _prefs = AdminPreferencesStore();
  Map<String, bool> _channels = {
    for (final key in AdminPreferencesStore.defaultChannels) key: true,
  };
  List<AdminChannelEntry> _entries = const [];
  bool _hasRemovedDefaults = false;

  double _financeCap = 0;

  Future<void> _loadCap() async {
    try {
      final cap = await _prefs.financeApprovalCap();
      if (!mounted) return;
      setState(() => _financeCap = cap);
    } catch (_) {
      // تبقى القيمة السابقة.
    }
  }

  Future<void> _editCap() async {
    final controller = TextEditingController(
        text: _financeCap > 0 ? _financeCap.toStringAsFixed(0) : '');
    String? error;
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: Text(adminText(dialogContext,
              ar: 'سقف اعتماد المشرف المالي', en: 'Finance supervisor approval cap')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                adminText(dialogContext,
                    ar: 'أي سحب يتجاوز هذا المبلغ يُرفع إليك للمصادقة النهائية. اتركه فارغًا أو 0 لإلغاء السقف.',
                    en: 'Any withdrawal above this amount is sent to you for final approval. Leave empty or 0 for no cap.'),
                style: const TextStyle(fontSize: 12),
              ),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: adminText(dialogContext, ar: 'السقف (ج.م)', en: 'Cap (EGP)'),
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim().replaceAll(',', '');
                final parsed = text.isEmpty ? 0.0 : double.tryParse(text);
                if (parsed == null || parsed < 0) {
                  setDialogState(() => error = adminText(dialogContext,
                      ar: 'أدخل مبلغًا صحيحًا', en: 'Enter a valid amount'));
                  return;
                }
                Navigator.pop(dialogContext, parsed);
              },
              child: Text(adminText(dialogContext, ar: 'حفظ', en: 'Save')),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    try {
      await _prefs.setFinanceApprovalCap(value);
      await _loadCap();
      if (!mounted) return;
      _toast('تم حفظ السقف', 'Cap saved');
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin finance cap',
      ));
      if (!mounted) return;
      _toast('تعذر حفظ السقف', 'Could not save the cap', success: false);
    }
  }

  Future<void> _loadChannels() async {
    try {
      final entries = await _prefs.channels();
      final hasRemoved = await _prefs.hasRemovedDefaultChannels();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _hasRemovedDefaults = hasRemoved;
        _channels = {for (final e in entries) e.key: e.enabled};
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin payment channels',
      ));
    }
  }

  Future<void> _setChannel(String key, bool value) async {
    final previous = _channels[key] ?? true;
    setState(() => _channels[key] = value);
    try {
      await _prefs.setChannel(key, value);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin payment channel toggle',
      ));
      if (!mounted) return;
      setState(() => _channels[key] = previous);
      _toast('تعذر حفظ حالة القناة', 'Could not save the channel state', success: false);
    }
  }

  /// نصوص القنوات الافتراضية (تُستبدل بما يكتبه الأدمن عند التعديل).
  static const _defaultTexts = <String, ({String ar, String en, String subAr, String subEn})>{
    'rajhi': (
      ar: 'مصرف الراجحي',
      en: 'Al Rajhi Bank',
      subAr: 'حساب الشركات المركزي (الرواتب والأرباح)',
      subEn: 'Central corporate account (payroll & profits)',
    ),
    'ahli': (
      ar: 'البنك الأهلي السعودي',
      en: 'Saudi National Bank',
      subAr: 'حساب التسويات السريعة وعمليات الضمان (Escrow)',
      subEn: 'Fast settlements & escrow account',
    ),
    'sarie': (
      ar: 'شبكة المدفوعات الفورية (سريع / SARIE)',
      en: 'Instant payments (SARIE)',
      subAr: 'تحويلات على مدار 24/7 دون توقف',
      subEn: '24/7 transfers without downtime',
    ),
    'gateways': (
      ar: 'بوابات الدفع الإلكتروني',
      en: 'Online payment gateways',
      subAr: 'Apple Pay, Visa, Mastercard, mada',
      subEn: 'Apple Pay, Visa, Mastercard, mada',
    ),
  };

  String _entryTitle(AdminChannelEntry e) {
    if (e.title.isNotEmpty) return e.title;
    final d = _defaultTexts[e.key];
    return d == null ? e.key : adminText(context, ar: d.ar, en: d.en);
  }

  String _entrySubtitle(AdminChannelEntry e) {
    if (e.title.isNotEmpty) return e.subtitle;
    final d = _defaultTexts[e.key];
    return d == null
        ? e.subtitle
        : adminText(context, ar: d.subAr, en: d.subEn);
  }

  /// إضافة قناة/بنك جديد، أو تعديل اسم ووصف موجود ([entry]).
  Future<void> _editChannel([AdminChannelEntry? entry]) async {
    final title = TextEditingController(text: entry == null ? '' : _entryTitle(entry));
    final details = TextEditingController(text: entry == null ? '' : _entrySubtitle(entry));
    String? error;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: Text(entry == null
              ? adminText(dialogContext, ar: 'إضافة قناة دفع', en: 'Add payment channel')
              : adminText(dialogContext, ar: 'تعديل القناة', en: 'Edit channel')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(
                  labelText: adminText(dialogContext,
                      ar: 'اسم القناة أو البنك', en: 'Channel or bank name'),
                  errorText: error,
                ),
              ),
              TextField(
                controller: details,
                decoration: InputDecoration(
                  labelText: adminText(dialogContext,
                      ar: 'وصف (اختياري)', en: 'Description (optional)'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty) {
                  setDialogState(() => error = adminText(dialogContext,
                      ar: 'الاسم مطلوب', en: 'Name is required'));
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: Text(entry == null
                  ? adminText(dialogContext, ar: 'إضافة', en: 'Add')
                  : adminText(dialogContext, ar: 'حفظ', en: 'Save')),
            ),
          ],
        ),
      ),
    );
    final name = title.text.trim();
    final description = details.text.trim();
    title.dispose();
    details.dispose();
    if (ok != true || !mounted) return;
    try {
      if (entry == null) {
        await _prefs.addChannel(name, description);
      } else {
        await _prefs.updateChannel(entry.key, name, description);
      }
      await _loadChannels();
      if (!mounted) return;
      _toast(entry == null ? 'تمت إضافة القناة' : 'تم حفظ التعديل',
          entry == null ? 'Channel added' : 'Changes saved');
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin edit payment channel',
      ));
      if (!mounted) return;
      _toast('تعذر حفظ القناة', 'Could not save the channel', success: false);
    }
  }

  Future<void> _restoreDefaultChannels() async {
    try {
      await _prefs.restoreDefaultChannels();
      await _loadChannels();
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin restore payment channels',
      ));
      if (!mounted) return;
      _toast('تعذر استعادة القنوات', 'Could not restore the channels', success: false);
    }
  }

  Future<void> _removeChannel(AdminChannelEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(adminText(dialogContext,
            ar: 'حذف القناة؟', en: 'Remove the channel?')),
        content: Text(adminText(dialogContext,
            ar: '«${_entryTitle(entry)}» ستختفي من القائمة${entry.isDefault ? ' ويمكن استعادتها لاحقًا' : ' نهائيًا'}.',
            en: '"${_entryTitle(entry)}" will be removed from the list${entry.isDefault ? ' and can be restored later' : ' permanently'}.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(adminText(dialogContext, ar: 'حذف', en: 'Remove')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final key = entry.key;
    try {
      await _prefs.removeChannel(key);
      await _loadChannels();
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin remove payment channel',
      ));
      if (!mounted) return;
      _toast('تعذر حذف القناة', 'Could not remove the channel', success: false);
    }
  }

  static final _money = NumberFormat('#,##0', 'en_US');
  FinanceSummaryEntity? _summary;
  bool _summaryFailed = false;

  static const _financialKinds = {
    AdminRequestKind.expense,
    AdminRequestKind.bankLink,
    AdminRequestKind.withdrawal,
    AdminRequestKind.subscription,
  };

  double _pendingAmount = 0;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    AdminRequestStore.revision.addListener(_loadPending);
    _loadSummary();
    _loadPending();
    _loadChannels();
    _loadCap();
  }

  @override
  void dispose() {
    AdminRequestStore.revision.removeListener(_loadPending);
    super.dispose();
  }

  Future<void> _loadPending() async {
    try {
      final pending = (await AdminRequestStore().getAll()).where(
          (item) => item.isPending && _financialKinds.contains(item.kind));
      if (!mounted) return;
      setState(() {
        _pendingCount = pending.length;
        _pendingAmount =
            pending.fold<double>(0, (sum, item) => sum + (item.amount ?? 0));
      });
    } catch (_) {
      // تبقى القيم السابقة إذا تعذرت القراءة.
    }
  }

  Future<void> _loadSummary() async {
    final result = await sl<GetFinanceSummaryUseCase>()();
    if (!mounted) return;
    setState(() {
      _summary = result.fold((_) => null, (value) => value);
      _summaryFailed = _summary == null;
    });
  }

  String _sar(BuildContext context, double? value) {
    if (value == null) return '—';
    final text = _money.format(value);
    return adminText(context, ar: '$text ج.م', en: 'EGP $text');
  }

  void _toast(String ar, String en, {bool success = true}) {
    final message = adminText(context, ar: ar, en: en);
    if (success) {
      AppSnackBar.showSuccess(context, message);
    } else {
      AppSnackBar.showInfo(context, message);
    }
  }

  Future<void> _exportFinanceLog() async {
    try {
      String fmt(DateTime? t) {
        if (t == null) return '';
        String two(int v) => v.toString().padLeft(2, '0');
        return '${t.year}/${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
      }

      String kindLabel(AdminRequestKind k) => switch (k) {
            AdminRequestKind.expense => 'مصروف',
            AdminRequestKind.bankLink => 'ربط حساب بنكي',
            AdminRequestKind.withdrawal => 'سحب',
            AdminRequestKind.subscription => 'اشتراك',
            AdminRequestKind.deletion => 'حذف مشرف',
            AdminRequestKind.escalation => 'تصعيد',
          };
      String statusLabel(AdminRequestStatus st) => switch (st) {
            AdminRequestStatus.pending => 'بانتظار القرار',
            AdminRequestStatus.approved => 'معتمد',
            AdminRequestStatus.frozen => 'مجمّد',
            AdminRequestStatus.rejected => 'مرفوض',
          };

      final requests = (await AdminRequestStore().getAll())
          .where((r) => _financialKinds.contains(r.kind))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (requests.isEmpty) {
        if (!mounted) return;
        _toast('لا توجد عمليات مالية لتصديرها بعد', 'No financial operations to export yet',
            success: false);
        return;
      }
      await CsvExporter.share(
        fileName: 'admin_finance_${CsvExporter.stamp()}.csv',
        title: 'سجل الاعتمادات المالية',
        headers: const [
          'المرجع',
          'النوع',
          'العنوان',
          'الجهة المرسلة',
          'المبلغ',
          'الحالة',
          'تاريخ الطلب',
          'تاريخ القرار',
          'ملاحظة القرار',
        ],
        rows: [
          for (final r in requests)
            [
              r.refId,
              kindLabel(r.kind),
              r.titleAr,
              r.fromAr,
              r.amount == null ? '' : r.amount!.toStringAsFixed(2),
              statusLabel(r.status),
              fmt(r.createdAt),
              fmt(r.decidedAt),
              r.decisionNote,
            ],
        ],
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin finance export',
      ));
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context, ar: 'تعذر تصدير التقرير', en: 'Could not export the report'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryExtraDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const MotionIcon(Icons.shield_outlined, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adminText(context,
                          ar: 'جلسة اعتماد سيادية مشفرة', en: 'Encrypted sovereign approval session'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      adminText(context,
                          ar: 'صلاحية إطلاق الدفعات البنكية المباشرة عبر الربط المالي (SARIE)',
                          en: 'Authority to release direct bank payments via SARIE'),
                      style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  adminText(context, ar: '2FA مفعل', en: '2FA on'),
                  style: const TextStyle(
                      color: AppPalette.teal5EEAD4,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_summaryFailed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              adminText(context,
                  ar: 'تعذر تحميل الأرصدة من المالية.',
                  en: 'Could not load balances from Finance.'),
              style: TextStyle(fontSize: 11, color: AppColors.dangerDark),
            ),
          ),
        AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MotionIcon(Icons.account_balance_outlined,
                        color: AppColors.info),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      adminText(context,
                          ar: 'السيولة الإجمالية المتاحة', en: 'Total available liquidity'),
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  AdminChip(
                      label: adminText(context, ar: 'جاهز للتسوية', en: 'Ready to settle'),
                      tone: AdminTone.success),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _sar(context, _summary?.totalLiquidity),
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    adminText(context,
                        ar: 'تغطية السيولة ${_summary?.instantLiquidityCoverageRatio.toStringAsFixed(1) ?? '—'}%',
                        en: 'Liquidity coverage ${_summary?.instantLiquidityCoverageRatio.toStringAsFixed(1) ?? '—'}%'),
                    style: TextStyle(
                        fontSize: 10.5, color: AppColors.successDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ((_summary?.instantLiquidityCoverageRatio ?? 0) / 100)
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        minHeight: 7,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation(AppColors.successDark),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AdminCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        MotionIcon(Icons.circle, size: 8, color: AppColors.success),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            adminText(context, ar: 'عمولات المنصة (الشو)', en: 'Platform commissions'),
                            style: TextStyle(
                                fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        _sar(context, _summary?.monthlyCommissionEarned),
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adminText(context, ar: 'عمولة الشهر الحالي', en: 'This month'),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successDark),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        MotionIcon(Icons.circle, size: 8, color: AppColors.danger),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            adminText(context, ar: 'بانتظار توقيع الأدمن', en: 'Awaiting admin signature'),
                            style: TextStyle(
                                fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        _sar(context, _pendingAmount),
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dangerDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adminText(context,
                            ar: '$_pendingCount طلب بانتظار قرارك',
                            en: '$_pendingCount request(s) awaiting you'),
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        AdminSectionTitle(
          icon: Icons.inbox_outlined,
          title: adminText(context,
              ar: 'طلبات محالة من المشرف المالي', en: 'Requests forwarded by Finance'),
          trailing: adminText(context, ar: 'ختم واعتماد سيادي', en: 'Sovereign seal'),
        ),
        AdminRequestsBuilder(
          builder: (context, all) => AdminRequestList(
            requests: all
                .where((item) => const {
                      AdminRequestKind.expense,
                      AdminRequestKind.bankLink,
                      AdminRequestKind.withdrawal,
                      AdminRequestKind.subscription,
                    }.contains(item.kind))
                .toList(),
          ),
        ),
        AdminListRow(
          icon: Icons.rule_folder_outlined,
          color: AppColors.primaryDark,
          title: adminText(context,
              ar: 'سقف اعتماد المشرف المالي', en: 'Finance supervisor approval cap'),
          subtitle: _financeCap > 0
              ? adminText(context,
                  ar: '${_money.format(_financeCap)} ج.م — ما فوقه يُرفع إليك',
                  en: 'EGP ${_money.format(_financeCap)} — above it comes to you')
              : adminText(context,
                  ar: 'بلا سقف — الطلبات الجاهزة للصرف الفوري تُنفَّذ مباشرة',
                  en: 'No cap — instant-ready requests are executed directly'),
          trailing: TextButton(
            onPressed: _editCap,
            child: Text(adminText(context, ar: 'تعديل', en: 'Edit')),
          ),
        ),
        const SizedBox(height: 12),
        AdminSectionTitle(
          icon: Icons.account_balance_wallet_outlined,
          title: adminText(context,
              ar: 'قنوات الدفع والبنوك المركزية', en: 'Payment channels & central banks'),
          trailing: adminText(context, ar: 'تفعيل القنوات', en: 'Channel activation'),
        ),
        AdminCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              if (_entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    adminText(context,
                        ar: 'لا توجد قنوات. أضف قناة أو استعد الافتراضية.',
                        en: 'No channels. Add one or restore the defaults.'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              for (final entry in _entries.indexed) ...[
                if (entry.$1 > 0) const Divider(height: 1),
                _channelRow(
                  key: entry.$2.key,
                  icon: switch (entry.$2.key) {
                    'rajhi' => Icons.account_balance_outlined,
                    'ahli' => Icons.apartment_outlined,
                    'sarie' => Icons.bolt_rounded,
                    'gateways' => Icons.credit_card_outlined,
                    _ => Icons.account_balance_wallet_outlined,
                  },
                  title: _entryTitle(entry.$2),
                  subtitle: _entrySubtitle(entry.$2),
                  badge: entry.$2.key == 'rajhi' && entry.$2.title.isEmpty
                      ? adminText(context, ar: 'رئيسي', en: 'Primary')
                      : null,
                  onEdit: () => _editChannel(entry.$2),
                  onDelete: () => _removeChannel(entry.$2),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            onPressed: () => _editChannel(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.infoLight,
              foregroundColor: AppColors.infoDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const MotionIcon(Icons.add_circle_outline),
            label: Text(
              adminText(context,
                  ar: 'إضافة قناة دفع أو حساب بنكي جديد', en: 'Add payment channel or bank account'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (_hasRemovedDefaults)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: _restoreDefaultChannels,
              icon: const MotionIcon(Icons.restore, size: 16),
              label: Text(adminText(context,
                  ar: 'استعادة القنوات الافتراضية',
                  en: 'Restore default channels')),
            ),
          ),
        const SizedBox(height: 12),
        AdminSectionTitle(
          icon: Icons.tune_outlined,
          title: adminText(context,
              ar: 'حدود ورسوم وسائل الدفع', en: 'Payment method limits & fees'),
          trailing: adminText(context,
              ar: 'إنستاباي · محافظ · فيزا · IBAN', en: 'InstaPay · wallets · Visa · IBAN'),
        ),
        const AdminPaymentChannelsPanel(),
        const SizedBox(height: 10),
        AdminListRow(
          icon: Icons.receipt_long_outlined,
          color: AppColors.primaryDark,
          title: adminText(context,
              ar: 'سجل الاعتمادات والتدقيق المالي السيادي الكامل',
              en: 'Full sovereign approvals & financial audit log'),
          trailing: TextButton.icon(
            onPressed: _exportFinanceLog,
            icon: const MotionIcon(Icons.download_rounded, size: 15),
            label: Text(adminText(context, ar: 'تصدير تقرير', en: 'Export')),
          ),
        ),
      ],
    );
  }

  Widget _channelRow({
    required String key,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final hasMenu = onEdit != null || onDelete != null;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 6, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MotionIcon(icon, color: AppColors.info, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    if (badge != null)
                      AdminChip(label: badge, tone: AdminTone.success),
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Switch(
            value: _channels[key] ?? false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeThumbColor: AppColors.successDark,
            onChanged: (v) => _setChannel(key, v),
          ),
          if (hasMenu)
            PopupMenuButton<String>(
              tooltip: adminText(context, ar: 'خيارات القناة', en: 'Channel options'),
              icon: const MotionIcon(Icons.more_vert, size: 20),
              padding: EdgeInsets.zero,
              onSelected: (v) {
                if (v == 'edit') onEdit?.call();
                if (v == 'delete') onDelete?.call();
              },
              itemBuilder: (menuContext) => [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const MotionIcon(Icons.edit_outlined, size: 18),
                      const SizedBox(width: 10),
                      Text(adminText(menuContext, ar: 'تعديل', en: 'Edit')),
                    ]),
                  ),
                if (onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      MotionIcon(Icons.delete_outline,
                          size: 18, color: AppColors.dangerDark),
                      const SizedBox(width: 10),
                      Text(adminText(menuContext, ar: 'حذف', en: 'Remove'),
                          style: TextStyle(color: AppColors.dangerDark)),
                    ]),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
