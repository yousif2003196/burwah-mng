import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _Period { today, week, month, all, custom }

/// أرقام تقارير مشرف الخدمات كما يحسبها السيرفر من سجله الرقابي وطلبات الخدمات.
class ServicesReportMetrics {
  final int reviewed;
  final int approved;
  final int rejected;
  final double approvalRate;
  final double rejectionRate;
  final int suspended;
  final int escalated;
  final int returned;
  final int infoRequests;
  final int categoryChanges;
  final int reassigned;
  final int providerActions;
  final int complaintsEscalated;
  final int compensations;
  final double? averageMinutes;
  final int previousReviewed;
  final double? changePercent;
  final int pending;
  final int overdue;
  final int escalatedOpen;
  final List<ServicesReportLog> logs;

  const ServicesReportMetrics({
    required this.reviewed,
    required this.approved,
    required this.rejected,
    required this.approvalRate,
    required this.rejectionRate,
    required this.suspended,
    required this.escalated,
    required this.returned,
    required this.infoRequests,
    required this.categoryChanges,
    required this.reassigned,
    required this.providerActions,
    required this.complaintsEscalated,
    required this.compensations,
    required this.averageMinutes,
    required this.previousReviewed,
    required this.changePercent,
    required this.pending,
    required this.overdue,
    required this.escalatedOpen,
    required this.logs,
  });

  factory ServicesReportMetrics.fromJson(Map<String, dynamic> j) {
    int i(String k) => (j[k] as num?)?.toInt() ?? 0;
    double d(String k) => (j[k] as num?)?.toDouble() ?? 0;
    return ServicesReportMetrics(
      reviewed: i('reviewed'),
      approved: i('approved'),
      rejected: i('rejected'),
      approvalRate: d('approvalRate'),
      rejectionRate: d('rejectionRate'),
      suspended: i('suspended'),
      escalated: i('escalated'),
      returned: i('returned'),
      infoRequests: i('infoRequests'),
      categoryChanges: i('categoryChanges'),
      reassigned: i('reassigned'),
      providerActions: i('providerActions'),
      complaintsEscalated: i('complaintsEscalated'),
      compensations: i('compensations'),
      averageMinutes: (j['averageMinutes'] as num?)?.toDouble(),
      previousReviewed: i('previousReviewed'),
      changePercent: (j['changePercent'] as num?)?.toDouble(),
      pending: i('pending'),
      overdue: i('overdue'),
      escalatedOpen: i('escalatedOpen'),
      logs: [
        for (final l in (j['logs'] as List? ?? const []))
          if (l is Map<String, dynamic>) ServicesReportLog.fromJson(l),
      ],
    );
  }
}

class ServicesReportLog {
  final String actionType;
  final String title;
  final String reason;
  final String supervisor;
  final DateTime at;

  const ServicesReportLog({
    required this.actionType,
    required this.title,
    required this.reason,
    required this.supervisor,
    required this.at,
  });

  factory ServicesReportLog.fromJson(Map<String, dynamic> j) => ServicesReportLog(
        actionType: '${j['actionType'] ?? ''}',
        title: '${j['title'] ?? ''}',
        reason: '${j['reason'] ?? ''}',
        supervisor: '${j['supervisorName'] ?? ''}',
        at: DateTime.tryParse('${j['at'] ?? ''}')?.toLocal() ?? DateTime.now(),
      );
}

class ServicesReportsScreen extends StatefulWidget {
  const ServicesReportsScreen({super.key});

  @override
  State<ServicesReportsScreen> createState() => _ServicesReportsScreenState();
}

class _ServicesReportsScreenState extends State<ServicesReportsScreen> {
  static const _labels = {
    _Period.today: 'اليوم',
    _Period.week: 'آخر 7 أيام',
    _Period.month: 'آخر 30 يومًا',
    _Period.all: 'الكل',
    _Period.custom: 'فترة محددة',
  };

  _Period _period = _Period.week;
  DateTimeRange? _range;
  ServicesReportMetrics? _metrics;
  bool _loading = true;
  bool _failed = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final response = await sl<ApiConsumer>(instanceName: 'berwah').get<Object>(
        ApiEndpoints.serviceReports,
        queryParameters: {
          'period': _period.name,
          if (_period == _Period.custom && _range != null) ...{
            'from': fmt.format(_range!.start),
            'to': fmt.format(_range!.end),
          },
        },
      );
      final body = response.data;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      if (data is! Map<String, dynamic>) throw const FormatException('reports');
      if (!mounted || id != _requestId) return;
      setState(() {
        _metrics = ServicesReportMetrics.fromJson(data);
        _loading = false;
      });
    } on Object catch (error) {
      debugPrint('Services report unavailable: $error');
      if (!mounted || id != _requestId) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _pick(_Period p) async {
    if (p == _Period.custom) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 2),
        lastDate: now,
        initialDateRange: _range,
      );
      if (picked == null) return;
      _range = picked;
    }
    setState(() => _period = p);
    _load();
  }

  String _minutes(double? m) {
    if (m == null) return '—';
    if (m < 60) return '${m.round()} دقيقة';
    if (m < 60 * 24) return '${(m / 60).toStringAsFixed(1)} ساعة';
    return '${(m / (60 * 24)).toStringAsFixed(1)} يوم';
  }

  String _pct(double v) => '${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1)}%';

  List<(String, String)> _rows(ServicesReportMetrics m) => [
        ('طلبات تمت مراجعتها', '${m.reviewed}'),
        ('نسبة الاعتماد', m.reviewed == 0 ? '—' : _pct(m.approvalRate)),
        ('نسبة الرفض', m.reviewed == 0 ? '—' : _pct(m.rejectionRate)),
        ('طلبات معتمدة', '${m.approved}'),
        ('طلبات مرفوضة', '${m.rejected}'),
        ('متوسط زمن المراجعة', _minutes(m.averageMinutes)),
        ('طلبات معلقة', '${m.suspended}'),
        ('طلبات أُحيلت للرئيس', '${m.escalated}'),
        ('طلبات أعادها الرئيس', '${m.returned}'),
        ('طلبات توضيح أُرسلت', '${m.infoRequests}'),
        ('تعديلات التصنيف', '${m.categoryChanges}'),
        ('إعادات إسناد', '${m.reassigned}'),
        ('إجراءات على المزودين', '${m.providerActions}'),
        ('شكاوى رُفعت للرئيس', '${m.complaintsEscalated}'),
        ('تعويضات مُلزمة', '${m.compensations}'),
        ('بانتظار المراجعة الآن', '${m.pending}'),
        ('متأخرة أكثر من 24 ساعة', '${m.overdue}'),
        ('عند الرئيس الآن', '${m.escalatedOpen}'),
      ];

  Widget _row(String label, String value) => Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final m = _metrics;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: const Text(
            'تقارير الخدمات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: BrandRefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in _Period.values)
                    ChoiceChip(
                      label: Text(
                        p == _Period.custom && _range != null && _period == p
                            ? '${DateFormat('MM/dd').format(_range!.start)} - ${DateFormat('MM/dd').format(_range!.end)}'
                            : _labels[p]!,
                      ),
                      selected: _period == p,
                      onSelected: (_) => _pick(p),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (_loading && m == null)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_failed && m == null)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      const Text('تعذر تحميل التقرير'),
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
                    ],
                  ),
                )
              else if (m != null) ...[
                if (m.changePercent != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      m.changePercent! >= 0
                          ? 'المراجعات أعلى بنسبة ${_pct(m.changePercent!)} من الفترة السابقة (${m.previousReviewed})'
                          : 'المراجعات أقل بنسبة ${_pct(-m.changePercent!)} من الفترة السابقة (${m.previousReviewed})',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                    ),
                  ),
                for (final r in _rows(m)) _row(r.$1, r.$2),
                if (m.logs.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'آخر الإجراءات',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final l in m.logs)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.actionType} · ${l.title}',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (l.reason.isNotEmpty || l.supervisor.isNotEmpty)
                            Text(
                              [
                                if (l.supervisor.isNotEmpty) l.supervisor,
                                if (l.reason.isNotEmpty) l.reason,
                              ].join(' • '),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          Text(
                            DateFormat('yyyy/MM/dd  HH:mm').format(l.at),
                            style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => CsvExporter.share(
                    fileName: 'services_report_${CsvExporter.stamp()}.csv',
                    title: 'تقارير الخدمات',
                    headers: const ['المؤشر', 'القيمة'],
                    rows: [for (final r in _rows(m)) [r.$1, r.$2]],
                  ),
                  icon: const MotionIcon(Icons.share_outlined, size: 18),
                  label: const Text('مشاركة CSV'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
