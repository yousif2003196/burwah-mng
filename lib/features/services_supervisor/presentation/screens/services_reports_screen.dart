import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_activity_log.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_escalation_store.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// Snapshot of the services supervisor's work, computed from the local
/// activity log and escalation store.
class ServicesReportMetrics {
  final int approved;
  final int rejected;
  final int providerActions;
  final int withHead;
  final int returnedByHead;
  final int atAdmin;
  final int decidedByHead;
  final int overdueEscalations;

  const ServicesReportMetrics({
    required this.approved,
    required this.rejected,
    required this.providerActions,
    required this.withHead,
    required this.returnedByHead,
    required this.atAdmin,
    required this.decidedByHead,
    required this.overdueEscalations,
  });

  int get reviewed => approved + rejected;
  String get approvalRate =>
      reviewed == 0 ? '—' : '${(approved * 100 / reviewed).round()}%';

  factory ServicesReportMetrics.compute(
    List<ServicesActivityEntry> log,
    Iterable<ServicesEscalation> escalations,
    DateTime now,
  ) {
    int count(bool Function(ServicesActivityEntry) t) => log.where(t).length;
    int status(ServicesEscalationStatus s) =>
        escalations.where((e) => e.status == s).length;
    return ServicesReportMetrics(
      approved: count((e) => e.action == 'request_approved'),
      rejected: count((e) => e.action == 'request_rejected'),
      providerActions: count((e) => e.action.startsWith('provider_')),
      withHead: status(ServicesEscalationStatus.pendingHead),
      returnedByHead: status(ServicesEscalationStatus.returned),
      atAdmin: status(ServicesEscalationStatus.escalatedToAdmin),
      decidedByHead: status(ServicesEscalationStatus.decided),
      overdueEscalations: escalations.where((e) => e.isOverdue(now)).length,
    );
  }
}

class ServicesReportsScreen extends StatefulWidget {
  const ServicesReportsScreen({super.key});

  @override
  State<ServicesReportsScreen> createState() => _ServicesReportsScreenState();
}

class _ServicesReportsScreenState extends State<ServicesReportsScreen> {
  ServicesReportMetrics? _metrics;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_load);
    ServicesActivityLog.revision.addListener(_load);
    ServicesEscalationStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_load);
    ServicesActivityLog.revision.removeListener(_load);
    ServicesEscalationStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final log = await ServicesActivityLog().getAll();
      final escalations = (await ServicesEscalationStore().refresh()).values;
      if (!mounted) return;
      setState(() {
        _metrics =
            ServicesReportMetrics.compute(log, escalations, DateTime.now());
        _failed = false;
      });
    } on Object catch (error) {
      debugPrint('Services report unavailable: $error');
      if (mounted) setState(() => _failed = true);
    }
  }

  List<(String, String)> _rows(ServicesReportMetrics m) => [
        ('طلبات تمت مراجعتها', '${m.reviewed}'),
        ('نسبة الاعتماد', m.approvalRate),
        ('طلبات معتمدة', '${m.approved}'),
        ('طلبات مرفوضة', '${m.rejected}'),
        ('إجراءات على المزودين', '${m.providerActions}'),
        ('عند رئيس المشرفين', '${m.withHead}'),
        ('أعادها الرئيس', '${m.returnedByHead}'),
        ('عند الأدمن عبر الرئيس', '${m.atAdmin}'),
        ('حسمها الرئيس', '${m.decidedByHead}'),
        ('تصعيدات متأخرة', '${m.overdueEscalations}'),
      ];

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
        body: _failed
            ? const Center(child: Text('تعذر تحميل التقرير'))
            : m == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final row in _rows(m)) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  row.$1,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                row.$2,
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
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
                  ),
      ),
    );
  }
}
