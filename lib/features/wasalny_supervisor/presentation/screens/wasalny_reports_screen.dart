import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

/// تقرير مشرف وصلني من السيرفر (`GET api/SupervisorUsed/reports?period=`):
/// مراجعة الإعلانات المستعملة وطلبات وصلني وطلبات الشراء والشكاوى.
class WasalnyReportsScreen extends StatefulWidget {
  const WasalnyReportsScreen({super.key});

  @override
  State<WasalnyReportsScreen> createState() => _WasalnyReportsScreenState();
}

class _WasalnyReportsScreenState extends State<WasalnyReportsScreen> {
  static const _periods = ['today', 'week', 'month', 'all'];

  String _period = 'month';
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AuthSession.isSignedIn) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final response = await sl<ApiConsumer>(instanceName: 'berwah').get<Object>(
        ApiEndpoints.usedReports,
        queryParameters: {'period': _period},
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map<String, dynamic>) throw const FormatException('report');
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } on Object catch (error) {
      debugPrint('Wasalny report load failed: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  int _n(String key) => (_data?[key] as num?)?.toInt() ?? 0;
  double? _d(String key) => (_data?[key] as num?)?.toDouble();

  String _minutes(double? m, bool ar) {
    if (m == null) return '—';
    if (m < 90) return '${m.toStringAsFixed(0)} ${ar ? 'دقيقة' : 'min'}';
    return '${(m / 60).toStringAsFixed(1)} ${ar ? 'ساعة' : 'h'}';
  }

  String _periodLabel(String p, bool ar) => switch (p) {
    'today' => ar ? 'اليوم' : 'Today',
    'week' => ar ? 'الأسبوع' : 'Week',
    'month' => ar ? 'الشهر' : 'Month',
    _ => ar ? 'الكل' : 'All',
  };

  Future<void> _export(bool ar) async {
    final d = _data;
    if (d == null) return;
    try {
      final rows = <List<String>>[
        [ar ? 'إعلانات تمت مراجعتها' : 'Ads reviewed', '${_n('reviewed')}'],
        [ar ? 'معتمدة' : 'Approved', '${_n('approved')}'],
        [ar ? 'مرفوضة' : 'Rejected', '${_n('rejected')}'],
        [ar ? 'طُلب تعديلها' : 'Edit requested', '${_n('editRequested')}'],
        [ar ? 'معلّقة' : 'Suspended', '${_n('suspended')}'],
        [ar ? 'طلبات وصلني معتمدة' : 'Wasalny approved', '${_n('requestsApproved')}'],
        [ar ? 'طلبات وصلني مرفوضة' : 'Wasalny rejected', '${_n('requestsRejected')}'],
        [ar ? 'طلبات وصلني مجمّدة' : 'Wasalny frozen', '${_n('requestsFrozen')}'],
        [ar ? 'طلبات شراء معتمدة' : 'Orders approved', '${_n('ordersApproved')}'],
        [ar ? 'شكاوى مصعّدة' : 'Complaints escalated', '${_n('complaintsEscalated')}'],
        [ar ? 'شكاوى محلولة' : 'Complaints resolved', '${_n('complaintsResolved')}'],
        [ar ? 'شكاوى مفتوحة' : 'Open complaints', '${_n('openComplaints')}'],
      ];
      await CsvExporter.share(
        fileName: 'wasalny_report_${CsvExporter.stamp()}.csv',
        title: ar ? 'تقرير مشرف وصلني' : 'Wasalny supervisor report',
        headers: [ar ? 'المؤشر' : 'Metric', ar ? 'القيمة' : 'Value'],
        rows: rows,
      );
    } on Object catch (error) {
      debugPrint('Wasalny report export failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ar ? 'تعذر تصدير التقرير' : 'Could not export')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ar = l10n.localeName.startsWith('ar');
    final change = _d('changePercent');

    return Directionality(
      textDirection: ar ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(l10n.productReportsTab),
          actions: [
            IconButton(
              tooltip: ar ? 'تصدير CSV' : 'Export CSV',
              onPressed: _data == null ? null : () => _export(ar),
              icon: const MotionIcon(Icons.download_outlined),
            ),
          ],
        ),
        body: !AuthSession.isSignedIn
            ? Center(child: Text(ar ? 'سجّل الدخول لعرض التقرير' : 'Sign in to see the report'))
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : _failed || _data == null
            ? Center(
                child: FilledButton.icon(
                  onPressed: _load,
                  icon: const MotionIcon(Icons.refresh),
                  label: Text(l10n.retryLoadMerchants),
                ),
              )
            : BrandRefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final p in _periods)
                          ChoiceChip(
                            label: Text(_periodLabel(p, ar)),
                            selected: _period == p,
                            onSelected: (_) {
                              if (_period == p) return;
                              setState(() => _period = p);
                              _load();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _section(ar ? 'مراجعة الإعلانات' : 'Ad review'),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.fact_check_outlined,
                      label: ar ? 'إعلانات تمت مراجعتها' : 'Ads reviewed',
                      value: '${_n('reviewed')}',
                      detail: change == null
                          ? (ar ? 'لا مقارنة بالفترة السابقة' : 'No previous period to compare')
                          : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% ${ar ? 'عن الفترة السابقة' : 'vs previous period'}',
                    )),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.task_alt_outlined,
                      label: ar ? 'معتمدة / مرفوضة' : 'Approved / rejected',
                      value: '${_n('approved')} / ${_n('rejected')}',
                      detail: ar
                          ? 'نسبة القبول ${_d('approvalRate')?.toStringAsFixed(1) ?? '0'}% • الرفض ${_d('rejectionRate')?.toStringAsFixed(1) ?? '0'}%'
                          : 'Approval ${_d('approvalRate')?.toStringAsFixed(1) ?? '0'}% • rejection ${_d('rejectionRate')?.toStringAsFixed(1) ?? '0'}%',
                    )),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.edit_note_outlined,
                      label: ar ? 'طُلب تعديل / معلّقة' : 'Edit requested / suspended',
                      value: '${_n('editRequested')} / ${_n('suspended')}',
                      detail: ar ? 'في الفترة المحددة' : 'In the selected period',
                    )),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.timer_outlined,
                      label: ar ? 'متوسط وقت مراجعتي' : 'My average review time',
                      value: _minutes(_d('myAverageReviewMinutes'), ar),
                      detail: ar
                          ? 'من فتحي للعنصر لحد قراري • آخر 30 يوم (${_n('myMeasuredDecisions')} قرار)'
                          : 'From opening the item to my decision • last 30 days (${_n('myMeasuredDecisions')})',
                    )),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.speed_outlined,
                      label: ar ? 'متوسط القسم' : 'Department average',
                      value: _minutes(_d('averageMinutes'), ar),
                      detail: ar ? 'من وصول الإعلان حتى القرار' : 'From submission to decision',
                    )),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.hourglass_bottom_outlined,
                      label: ar ? 'بانتظار المراجعة / متأخرة' : 'Pending / overdue',
                      value: '${_n('pendingAds')} / ${_n('overdueAds')}',
                      detail: ar ? 'المتأخر تجاوز 24 ساعة' : 'Overdue = more than 24 hours',
                    )),
                    const SizedBox(height: 8),
                    _section(ar ? 'طلبات وصلني والشراء' : 'Wasalny & orders'),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.local_shipping_outlined,
                      label: ar ? 'طلبات وصلني: معتمد / مرفوض / مجمّد' : 'Wasalny: approved / rejected / frozen',
                      value: '${_n('requestsApproved')} / ${_n('requestsRejected')} / ${_n('requestsFrozen')}',
                      detail: ar
                          ? 'قيد المراجعة الآن: ${_n('pendingRequests')}'
                          : 'Under review now: ${_n('pendingRequests')}',
                    )),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.shopping_bag_outlined,
                      label: ar ? 'طلبات شراء معتمدة' : 'Orders approved',
                      value: '${_n('ordersApproved')}',
                      detail: ar
                          ? 'بانتظار الاعتماد: ${_n('pendingOrders')} • تنبيهات مشتركة: ${_n('jointAlerts')}'
                          : 'Waiting: ${_n('pendingOrders')} • joint alerts: ${_n('jointAlerts')}',
                    )),
                    const SizedBox(height: 8),
                    _section(ar ? 'الشكاوى' : 'Complaints'),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.inbox_outlined,
                      label: ar ? 'الشكاوى المفتوحة' : 'Open complaints',
                      value: '${_n('openComplaints')}',
                      detail: ar ? 'تحتاج متابعة' : 'Need follow-up',
                    )),
                    ScrollFx(child: _ReportMetric(
                      icon: Icons.account_tree_outlined,
                      label: ar ? 'متابعة / مرسلة للبائع / مصعّدة / محلولة' : 'Follow-up / to seller / escalated / resolved',
                      value:
                          '${_n('complaintsFollowUp')} / ${_n('complaintsSentToSeller')} / ${_n('complaintsEscalated')} / ${_n('complaintsResolved')}',
                      detail: ar ? 'في الفترة المحددة' : 'In the selected period',
                    )),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
    ),
  );
}

class _ReportMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  const _ReportMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceLight,
            child: MotionIcon(icon, color: AppColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                CountText(
                  value,
                  style: TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Text(detail, style: TextStyle(color: AppColors.successDark, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
