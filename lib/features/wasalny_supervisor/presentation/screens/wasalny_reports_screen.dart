import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_case_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_request_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/get_wasalny_complaints_usecase.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// Live numbers computed from complaints and request follow-up data.
class _ReportExtra {
  final int totalComplaints;
  final int openComplaints;
  final int atHead;
  final int atAdmin;
  final int resolvedComplaints;
  final int overdueComplaints;
  final Duration? avgResolution;
  final int soldRequests;
  final int flaggedRequests;
  final int pendingFlags;
  final List<List<String>> complaintRows;

  const _ReportExtra({
    required this.totalComplaints,
    required this.openComplaints,
    required this.atHead,
    required this.atAdmin,
    required this.resolvedComplaints,
    required this.overdueComplaints,
    required this.avgResolution,
    required this.soldRequests,
    required this.flaggedRequests,
    required this.pendingFlags,
    required this.complaintRows,
  });
}

String _complaintStatusAr(WasalnyComplaintStatus s) => switch (s) {
      WasalnyComplaintStatus.underReview => 'جديدة',
      WasalnyComplaintStatus.escalatedToChief => 'عند رئيس المشرفين',
      WasalnyComplaintStatus.actionTakenBlocked => 'تم الإجراء/الحجب',
      WasalnyComplaintStatus.resolved => 'محلولة',
      WasalnyComplaintStatus.returnedByHead => 'أُعيدت من الرئيس',
      WasalnyComplaintStatus.escalatedToAdmin => 'عند الأدمن عبر الرئيس',
    };

class WasalnyReportsScreen extends StatefulWidget {
  const WasalnyReportsScreen({super.key});

  @override
  State<WasalnyReportsScreen> createState() => _WasalnyReportsScreenState();
}

class _WasalnyReportsScreenState extends State<WasalnyReportsScreen> {
  late Future<List<ProductSupervisorAuditEntry>> _entriesFuture;
  late Future<_ReportExtra> _extraFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
    _extraFuture = _loadExtra();
  }

  Future<List<ProductSupervisorAuditEntry>> _loadEntries() async {
    final entries = await sl<ProductSupervisorAuditRepository>().getEntries();
    return entries
        .where((entry) => entry.actionKey.startsWith('wasalny_'))
        .toList();
  }

  Future<_ReportExtra> _loadExtra() async {
    final raw = await sl<GetWasalnyComplaintsUseCase>()();
    final cases = await WasalnyCaseStore().refresh(raw);
    final complaints = WasalnyCaseStore.apply(raw, cases);
    final requests = await WasalnyRequestStore().load();
    final now = DateTime.now();
    bool isOpen(WasalnyComplaintStatus s) =>
        s == WasalnyComplaintStatus.underReview ||
        s == WasalnyComplaintStatus.returnedByHead;
    final durations = <Duration>[];
    for (final c in complaints) {
      final record = cases[c.id];
      if (c.status == WasalnyComplaintStatus.resolved &&
          record != null &&
          record.timeline.isNotEmpty) {
        final d = record.timeline.last.at.difference(record.firstSeen);
        if (!d.isNegative) durations.add(d);
      }
    }
    return _ReportExtra(
      totalComplaints: complaints.length,
      openComplaints: complaints.where((c) => isOpen(c.status)).length,
      atHead: complaints
          .where((c) => c.status == WasalnyComplaintStatus.escalatedToChief)
          .length,
      atAdmin: complaints
          .where((c) => c.status == WasalnyComplaintStatus.escalatedToAdmin)
          .length,
      resolvedComplaints: complaints
          .where((c) => c.status == WasalnyComplaintStatus.resolved)
          .length,
      overdueComplaints: complaints
          .where((c) =>
              WasalnyCaseRecord.isOverdue(c.status, cases[c.id], now))
          .length,
      avgResolution: durations.isEmpty
          ? null
          : Duration(
              minutes: durations.fold<int>(0, (a, d) => a + d.inMinutes) ~/
                  durations.length,
            ),
      soldRequests: requests.values.where((s) => s.isSold).length,
      flaggedRequests: requests.values.where((s) => s.flagStatus != null).length,
      pendingFlags: requests.values
          .where((s) => s.flagStatus == WasalnyRequestFlagStatus.pendingHead)
          .length,
      complaintRows: [
        for (final c in complaints)
          [
            'شكوى',
            c.id,
            c.titleAr,
            _complaintStatusAr(c.status),
            WasalnyCaseRecord.isOverdue(c.status, cases[c.id], now)
                ? 'متأخرة'
                : '',
          ],
      ],
    );
  }

  Future<void> _export() async {
    try {
      final entries = await _entriesFuture;
      final extra = await _extraFuture;
      final rows = <List<String>>[
        ['مؤشر', 'إجمالي الشكاوى', '', '${extra.totalComplaints}', ''],
        ['مؤشر', 'شكاوى مفتوحة', '', '${extra.openComplaints}', ''],
        ['مؤشر', 'عند رئيس المشرفين', '', '${extra.atHead}', ''],
        ['مؤشر', 'عند الأدمن عبر الرئيس', '', '${extra.atAdmin}', ''],
        ['مؤشر', 'شكاوى محلولة', '', '${extra.resolvedComplaints}', ''],
        ['مؤشر', 'شكاوى متأخرة', '', '${extra.overdueComplaints}', ''],
        ['مؤشر', 'طلبات تم بيعها', '', '${extra.soldRequests}', ''],
        ['مؤشر', 'طلبات مرفوعة للرئيس', '', '${extra.flaggedRequests}', ''],
        ...extra.complaintRows,
        for (final e in entries)
          ['إجراء', e.actionKey, e.subject, e.details, e.occurredAt.toIso8601String()],
      ];
      await CsvExporter.share(
        fileName: 'wasalny_report_${CsvExporter.stamp()}.csv',
        title: 'تقرير مشرف وصلني',
        headers: const ['النوع', 'المعرف', 'الوصف', 'الحالة/القيمة', 'ملاحظة/الوقت'],
        rows: rows,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Wasalny reports',
          context: ErrorDescription('while exporting the report'),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تصدير التقرير')),
      );
    }
  }

  void _retry() => setState(() {
        _entriesFuture = _loadEntries();
        _extraFuture = _loadExtra();
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(l10n.productReportsTab),
          actions: [
            IconButton(
              tooltip: isArabic ? 'تصدير CSV' : 'Export CSV',
              onPressed: _export,
              icon: const MotionIcon(Icons.download_outlined),
            ),
          ],
        ),
        body: FutureBuilder<List<ProductSupervisorAuditEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: FilledButton.icon(
                  onPressed: _retry,
                  icon: const MotionIcon(Icons.refresh),
                  label: Text(l10n.retryLoadMerchants),
                ),
              );
            }
            final entries = snapshot.data ?? const [];
            int count(String key) =>
                entries.where((entry) => entry.actionKey == key).length;
            final adReviews = entries
                .where((entry) => entry.actionKey.startsWith('wasalny_ad_'))
                .length;
            final adApprovals = count('wasalny_ad_approved');
            final resolved = count('wasalny_complaint_resolved');
            final escalated = count('wasalny_complaint_escalated');
            final contacts = count('wasalny_request_contact_revealed');

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.wasalnyReportOverview,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ScrollFx(child: _ReportMetric(
                  icon: Icons.fact_check_outlined,
                  label: isArabic
                      ? 'مراجعات الإعلانات المسجلة'
                      : 'Recorded ad reviews',
                  value: '$adReviews',
                  detail: isArabic
                      ? 'من سجل الإجراءات الرقابية'
                      : 'From the audit log',
                )),
                ScrollFx(child: _ReportMetric(
                  icon: Icons.task_alt_outlined,
                  label: isArabic ? 'الإعلانات المعتمدة' : 'Approved ads',
                  value: '$adApprovals',
                  detail: isArabic
                      ? 'قرارات اعتماد مسجلة'
                      : 'Approval decisions recorded',
                )),
                ScrollFx(child: _ReportMetric(
                  icon: Icons.check_circle_outline,
                  label: isArabic ? 'الشكاوى المحلولة' : 'Resolved complaints',
                  value: '$resolved',
                  detail: isArabic
                      ? 'من سجل الإجراءات الرقابية'
                      : 'From the audit log',
                )),
                ScrollFx(child: _ReportMetric(
                  icon: Icons.escalator_warning_outlined,
                  label: isArabic ? 'الشكاوى المصعّدة' : 'Escalated complaints',
                  value: '$escalated',
                  detail: isArabic
                      ? 'تم إرسالها لرئيس المشرفين'
                      : 'Sent to the head supervisor',
                )),
                ScrollFx(child: _ReportMetric(
                  icon: Icons.contact_phone_outlined,
                  label:
                      isArabic ? 'طلبات إظهار التواصل' : 'Contact disclosures',
                  value: '$contacts',
                  detail: isArabic
                      ? 'طلبات مسجلة في سجل الرقابة'
                      : 'Requests recorded in the audit log',
                )),
                FutureBuilder<_ReportExtra>(
                  future: _extraFuture,
                  builder: (context, extraSnapshot) {
                    final extra = extraSnapshot.data;
                    if (extra == null) return const SizedBox.shrink();
                    String hours(Duration? d) => d == null
                        ? '—'
                        : (d.inMinutes < 90
                            ? '${d.inMinutes} ${isArabic ? 'دقيقة' : 'min'}'
                            : '${(d.inMinutes / 60).toStringAsFixed(1)} ${isArabic ? 'ساعة' : 'h'}');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        _ReportMetric(
                          icon: Icons.inbox_outlined,
                          label: isArabic ? 'الشكاوى المفتوحة' : 'Open complaints',
                          value: '${extra.openComplaints} / ${extra.totalComplaints}',
                          detail: isArabic
                              ? 'تحتاج متابعة من المشرف'
                              : 'Need supervisor follow-up',
                        ),
                        _ReportMetric(
                          icon: Icons.account_tree_outlined,
                          label: isArabic ? 'عند الرئيس / الأدمن' : 'With head / admin',
                          value: '${extra.atHead} / ${extra.atAdmin}',
                          detail: isArabic
                              ? 'بانتظار القرار'
                              : 'Awaiting a decision',
                        ),
                        _ReportMetric(
                          icon: Icons.timer_off_outlined,
                          label: isArabic ? 'الشكاوى المتأخرة' : 'Overdue complaints',
                          value: '${extra.overdueComplaints}',
                          detail: isArabic
                              ? 'تجاوزت 24 ساعة (المشرف) أو 48 ساعة (الرئيس)'
                              : 'Past 24h (supervisor) or 48h (head)',
                        ),
                        _ReportMetric(
                          icon: Icons.speed_outlined,
                          label: isArabic ? 'متوسط زمن الحل' : 'Average resolution time',
                          value: hours(extra.avgResolution),
                          detail: isArabic
                              ? 'للشكاوى المحلولة على هذا الجهاز'
                              : 'For complaints resolved on this device',
                        ),
                        _ReportMetric(
                          icon: Icons.sell_outlined,
                          label: isArabic ? 'طلبات تم بيعها' : 'Sold requests',
                          value: '${extra.soldRequests}',
                          detail: isArabic
                              ? 'مرفوع للرئيس: ${extra.flaggedRequests} (بانتظار القرار ${extra.pendingFlags})'
                              : 'Flagged to head: ${extra.flaggedRequests} (${extra.pendingFlags} pending)',
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
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
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                CountText(
                  value,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    color: AppColors.successDark,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
