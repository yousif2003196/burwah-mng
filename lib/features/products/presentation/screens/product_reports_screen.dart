import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/features/products/data/datasources/product_escalation_store.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _ReportPeriod { today, week, month, custom }

/// Live numbers from the complaints list and the head escalations.
class _LiveStats {
  final int openComplaints;
  final int overdueComplaints;
  final int resolvedComplaints;
  final int withHead;
  final int returnedByHead;
  final int atAdmin;
  final int overdueEscalations;

  const _LiveStats({
    required this.openComplaints,
    required this.overdueComplaints,
    required this.resolvedComplaints,
    required this.withHead,
    required this.returnedByHead,
    required this.atAdmin,
    required this.overdueEscalations,
  });
}

enum _ReportActionStatus { hidden, approved, rejected }

class _ReportMetrics {
  final int reviewed;
  final int approved;
  final int declined;
  final String approvalRate;
  final String averageMinutes;
  final String change;

  const _ReportMetrics({
    required this.reviewed,
    required this.approved,
    required this.declined,
    required this.approvalRate,
    required this.averageMinutes,
  }) : change = '—';

  String get declinedRate =>
      reviewed == 0 ? '0%' : '${(declined * 100 / reviewed).round()}%';
}

class _AuditAction {
  final String adNumber;
  final String titleAr;
  final String titleEn;
  final String ageAr;
  final String ageEn;
  final _ReportActionStatus status;
  final String reasonAr;
  final String reasonEn;

  const _AuditAction({
    required this.adNumber,
    required this.titleAr,
    required this.titleEn,
    required this.ageAr,
    required this.ageEn,
    required this.status,
    required this.reasonAr,
    required this.reasonEn,
  });

  _AuditAction copyWith({
    _ReportActionStatus? status,
    String? reasonAr,
    String? reasonEn,
  }) {
    return _AuditAction(
      adNumber: adNumber,
      titleAr: titleAr,
      titleEn: titleEn,
      ageAr: ageAr,
      ageEn: ageEn,
      status: status ?? this.status,
      reasonAr: reasonAr ?? this.reasonAr,
      reasonEn: reasonEn ?? this.reasonEn,
    );
  }
}

class ProductReportsScreen extends StatefulWidget {
  const ProductReportsScreen({super.key});

  @override
  State<ProductReportsScreen> createState() => _ProductReportsScreenState();
}

class _ProductReportsScreenState extends State<ProductReportsScreen> {
  static const _initialActions = [
    _AuditAction(
      adNumber: 'AD-98204',
      titleAr: 'ساعة آبل الجيل 2 الأصلية - الإصدار الثاني',
      titleEn: 'Apple Watch Series 2 Original - Second Edition',
      ageAr: 'منذ 10 دقائق',
      ageEn: '10 minutes ago',
      status: _ReportActionStatus.hidden,
      reasonAr: 'تحقيق التغليف الأمني',
      reasonEn: 'Security packaging verification',
    ),
    _AuditAction(
      adNumber: 'AD-98201',
      titleAr: 'سوني بلايستيشن 5 - مع الضمان الوكيل',
      titleEn: 'Sony PlayStation 5 - With Official Warranty',
      ageAr: 'منذ 35 دقيقة',
      ageEn: '35 minutes ago',
      status: _ReportActionStatus.approved,
      reasonAr: 'المطابقة: كافة شروط المنتج الجديد',
      reasonEn: 'Verified: all new-product requirements met',
    ),
    _AuditAction(
      adNumber: 'AD-98195',
      titleAr: 'سماعات آبل ايربودز ماكس (فضي)',
      titleEn: 'Apple AirPods Max Headphones (Silver)',
      ageAr: 'منذ ساعتين',
      ageEn: '2 hours ago',
      status: _ReportActionStatus.rejected,
      reasonAr: 'خزان مفتوح ومستعمل مسبقاً',
      reasonEn: 'Package opened and previously used',
    ),
  ];

  _ReportPeriod _period = _ReportPeriod.week;
  List<_AuditAction> _savedActions = List.of(_initialActions);
  List<_AuditAction> _draftActions = List.of(_initialActions);
  DateTimeRange? _customRange;
  bool _hasUnsavedChanges = false;
  List<ProductSupervisorAuditEntry> _auditEntries = [];
  late Future<_LiveStats> _liveFuture;

  @override
  void initState() {
    super.initState();
    _liveFuture = _loadLiveStats();
    _loadAuditEntries();
  }

  Future<_LiveStats> _loadLiveStats() async {
    final prefs = await SharedPreferences.getInstance();
    var open = 0;
    var overdue = 0;
    var resolved = 0;
    final saved = prefs.getString('product_supervisor_complaints_v1');
    final now = DateTime.now();
    if (saved != null) {
      final decoded = jsonDecode(saved);
      if (decoded is List) {
        for (final item in decoded.whereType<Map<String, dynamic>>()) {
          final status = item['status'] as String? ?? 'newCase';
          final updated = DateTime.tryParse(item['updatedAt'] as String? ?? '');
          if (status == 'resolved' || status == 'archived') {
            resolved++;
          } else if (status == 'newCase' || status == 'inProgress') {
            open++;
            if (updated != null &&
                now.difference(updated) > const Duration(hours: 24)) {
              overdue++;
            }
          }
        }
      }
    }
    final escalations = (await ProductEscalationStore().refresh()).values;
    return _LiveStats(
      openComplaints: open,
      overdueComplaints: overdue,
      resolvedComplaints: resolved,
      withHead: escalations
          .where((e) => e.status == ProductEscalationStatus.pendingHead)
          .length,
      returnedByHead: escalations
          .where((e) => e.status == ProductEscalationStatus.returned)
          .length,
      atAdmin: escalations
          .where((e) => e.status == ProductEscalationStatus.escalatedToAdmin)
          .length,
      overdueEscalations: escalations.where((e) => e.isOverdue(now)).length,
    );
  }

  Widget _buildLiveSection(bool isArabic) {
    return FutureBuilder<_LiveStats>(
      future: _liveFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        if (stats == null) return const SizedBox.shrink();
        Widget row(String label, int value, {bool alert = false}) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(label, style: const TextStyle(fontSize: 12)),
                  ),
                  CountText(
                    '$value',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: alert && value > 0
                          ? AppColors.dangerDark
                          : AppColors.ink,
                    ),
                  ),
                ],
              ),
            );
        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: _sectionCard(
            title: isArabic ? 'الشكاوى والتصعيدات (حية)' : 'Complaints & escalations (live)',
            icon: Icons.account_tree_outlined,
            child: Column(
              children: [
                row(isArabic ? 'شكاوى مفتوحة' : 'Open complaints', stats.openComplaints),
                row(isArabic ? 'شكاوى متأخرة (+24 ساعة)' : 'Overdue complaints (24h+)', stats.overdueComplaints, alert: true),
                row(isArabic ? 'شكاوى منتهية' : 'Closed complaints', stats.resolvedComplaints),
                const Divider(),
                row(isArabic ? 'عند رئيس المشرفين' : 'With the head', stats.withHead),
                row(isArabic ? 'أعادها الرئيس للمراجعة' : 'Returned by the head', stats.returnedByHead),
                row(isArabic ? 'عند الأدمن عبر الرئيس' : 'With admin via head', stats.atAdmin),
                row(isArabic ? 'تصعيدات متأخرة (+48 ساعة)' : 'Overdue escalations (48h+)', stats.overdueEscalations, alert: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadAuditEntries() async {
    try {
      final entries = await sl<ProductSupervisorAuditRepository>().getEntries();
      if (!mounted) return;
      setState(() {
        _auditEntries = entries;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'product reports audit loading',
      ));
    }
  }

  _ReportMetrics _metricsForSelectedPeriod() {
    final now = DateTime.now();
    late final DateTime start;
    late final DateTime end;
    switch (_period) {
      case _ReportPeriod.today:
        start = DateTime(now.year, now.month, now.day);
        end = now;
        break;
      case _ReportPeriod.week:
        final today = DateTime(now.year, now.month, now.day);
        start = today.subtract(Duration(days: today.weekday - 1));
        end = now;
        break;
      case _ReportPeriod.month:
        start = DateTime(now.year, now.month);
        end = now;
        break;
      case _ReportPeriod.custom:
        final range = _customRange;
        start = range == null
            ? DateTime(now.year, now.month, now.day)
            : DateTime(range.start.year, range.start.month, range.start.day);
        end = range == null
            ? now
            : DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
        break;
    }
    const reviewActions = {
      'product_approved',
      'product_hidden',
      'product_rejected',
      'product_suspended',
    };
    final actions = _auditEntries.where((entry) =>
        reviewActions.contains(entry.actionKey) &&
        !entry.occurredAt.isBefore(start) &&
        !entry.occurredAt.isAfter(end));
    final approved =
        actions.where((entry) => entry.actionKey == 'product_approved').length;
    final declined = actions
        .where((entry) =>
            entry.actionKey == 'product_rejected' ||
            entry.actionKey == 'product_suspended')
        .length;
    final reviewed = actions.length;
    final rate = reviewed == 0 ? 0 : (approved * 100 / reviewed).round();
    return _ReportMetrics(
      reviewed: reviewed,
      approved: approved,
      declined: declined,
      approvalRate: '$rate%',
      averageMinutes: '—',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final metrics = _metricsForSelectedPeriod();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              children: [
                ScrollFx(child: _buildReportHeading(l10n)),
                const SizedBox(height: 14),
                ScrollFx(child: _buildPeriodSelector(l10n)),
                const SizedBox(height: 22),
                ScrollFx(child: _buildMetrics(metrics, l10n)),
                const SizedBox(height: 22),
                ScrollFx(child: _buildLiveSection(isArabic)),
                ScrollFx(child: _buildStandardsSection(l10n)),
                const SizedBox(height: 22),
                ScrollFx(child: _buildAuditSection(l10n, isArabic)),
                const SizedBox(height: 16),
                ScrollFx(child: _buildDataNote(l10n)),
              ],
            ),
          ),
          _buildSaveActions(l10n),
        ],
      ),
    );
  }

  Widget _buildReportHeading(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MotionIcon(Icons.analytics_outlined,
                      size: 15, color: AppColors.info),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      l10n.productReportEyebrow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                l10n.productReportTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _showExportDialog(l10n),
          icon: const MotionIcon(Icons.file_download_outlined, size: 17),
          label: Text(l10n.productReportExport),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            backgroundColor: AppColors.surface,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            textStyle:
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n) {
    final periods = [
      (_ReportPeriod.today, l10n.productReportToday),
      (_ReportPeriod.week, l10n.productReportThisWeek),
      (_ReportPeriod.month, l10n.productReportThisMonth),
      (_ReportPeriod.custom, l10n.productReportCustom),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((entry) {
          final selected = _period == entry.$1;
          final label = entry.$1 == _ReportPeriod.custom && _customRange != null
              ? _formatDateRange(_customRange!)
              : entry.$2;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 7),
            child: ChoiceChip(
              selected: selected,
              showCheckmark: false,
              avatar: selected
                  ? MotionIcon(Icons.circle, size: 7, color: AppColors.info)
                  : entry.$1 == _ReportPeriod.custom
                      ? const MotionIcon(Icons.calendar_month_outlined, size: 15)
                      : null,
              label: Text(label),
              onSelected: (_) => _selectPeriod(entry.$1),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryDark,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _selectPeriod(_ReportPeriod period) async {
    if (period == _ReportPeriod.custom) {
      final now = DateTime.now();
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 3),
        lastDate: now,
        initialDateRange: _customRange ??
            DateTimeRange(
              start: now.subtract(const Duration(days: 6)),
              end: now,
            ),
      );
      if (range == null || !mounted) return;
      setState(() {
        _customRange = range;
        _period = period;
      });
      return;
    }
    setState(() => _period = period);
  }

  String _formatDateRange(DateTimeRange range) {
    String format(DateTime date) =>
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    return '${format(range.start)} - ${format(range.end)}';
  }

  Widget _buildMetrics(_ReportMetrics metrics, AppLocalizations l10n) {
    final cards = [
      _MetricCardData(
        title: l10n.productReportReviewedAds,
        value: metrics.reviewed.toString(),
        detail: '${metrics.change} ${l10n.productReportComparedToPrevious}',
        icon: Icons.shield_outlined,
        iconColor: AppColors.info,
      ),
      _MetricCardData(
        title: l10n.productReportApprovalRate,
        value: metrics.approvalRate,
        detail: l10n.productReportApprovedCount(metrics.approved),
        icon: Icons.check_circle,
        iconColor: AppColors.infoDark,
      ),
      _MetricCardData(
        title: l10n.productReportDeclinedRate,
        value: metrics.declinedRate,
        detail: l10n.productReportDeclinedCount(metrics.declined),
        icon: Icons.block_outlined,
        iconColor: AppColors.danger,
        isDanger: true,
      ),
      _MetricCardData(
        title: l10n.productReportAverageReview,
        value: metrics.averageMinutes,
        detail: l10n.productReportMinutesAndFaster,
        icon: Icons.timer_outlined,
        iconColor: AppColors.ink,
        unit: metrics.averageMinutes == '—'
            ? null
            : l10n.productReportMinuteUnit,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((card) => SizedBox(
                    width: width,
                    height: 128,
                    child: _buildMetricCard(card),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildMetricCard(_MetricCardData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: data.isDanger
                      ? AppColors.dangerLight
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MotionIcon(data.icon, size: 18, color: data.iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color:
                      data.isDanger ? AppColors.danger : AppColors.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(text: data.value),
                  if (data.unit != null)
                    TextSpan(
                      text: ' ${data.unit}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.info,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardsSection(AppLocalizations l10n) {
    return _sectionCard(
      title: l10n.productReportStandardsTitle,
      icon: Icons.fact_check_outlined,
      trailing: _smallTag(l10n.productReportStandardsVersion),
      child: Row(
        children: [
          Expanded(
            child: _buildStandardCard(
              title: l10n.productReportPackagingTitle,
              subtitle: l10n.productReportPackagingHint,
              icon: Icons.inventory_2_outlined,
              color: AppColors.textMuted,
              isLocked: true,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _buildStandardCard(
              title: l10n.productReportSerialTitle,
              subtitle: l10n.productReportSerialHint,
              icon: Icons.qr_code_2,
              color: AppColors.textSecondary,
              isLocked: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isLocked,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 92,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.24), color],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MotionIcon(icon,
                      size: 52, color: Colors.white.withValues(alpha: .9)),
                  PositionedDirectional(
                    end: 6,
                    top: 6,
                    child: MotionIcon(
                      isLocked ? Icons.lock_outline : Icons.verified_outlined,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(_ReportCategoryData data) {
    return Column(
      children: [
        Row(
          children: [
            MotionIcon(data.icon, size: 15, color: AppColors.info),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 5),
            CountText(
              '${(data.percent * 100).round()}%',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${data.count})',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: data.percent,
            minHeight: 8,
            backgroundColor: AppColors.surfaceHighlight,
            valueColor: AlwaysStoppedAnimation(data.color),
          ),
        ),
      ],
    );
  }

  Widget _buildAuditSection(AppLocalizations l10n, bool isArabic) {
    return _sectionCard(
      title: l10n.productReportAuditTitle,
      icon: Icons.history,
      trailing: TextButton(
        onPressed: () => _showAllActions(l10n),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          l10n.productReportLive,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
      child: Column(
        children: _draftActions
            .map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _buildAuditAction(action, l10n, isArabic),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildAuditAction(
    _AuditAction action,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final statusColor = switch (action.status) {
      _ReportActionStatus.hidden => AppColors.textSecondary,
      _ReportActionStatus.approved => AppColors.infoDark,
      _ReportActionStatus.rejected => AppColors.danger,
    };
    final statusIcon = switch (action.status) {
      _ReportActionStatus.hidden => Icons.visibility_off_outlined,
      _ReportActionStatus.approved => Icons.check,
      _ReportActionStatus.rejected => Icons.close,
    };
    final statusLabel = switch (action.status) {
      _ReportActionStatus.hidden => l10n.productReportHidden,
      _ReportActionStatus.approved => l10n.productReportApproved,
      _ReportActionStatus.rejected => l10n.productReportRejected,
    };
    final reason = isArabic ? action.reasonAr : action.reasonEn;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MotionIcon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.productReportActionHeadline(action.adNumber),
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isArabic ? action.titleAr : action.titleEn,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: statusColor, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _smallTag(statusLabel),
                  const SizedBox(height: 5),
                  Text(
                    isArabic ? action.ageAr : action.ageEn,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _editAction(action, l10n, isArabic),
              icon: const MotionIcon(Icons.edit_note, size: 16),
              label: Text(l10n.productReportEditAction),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editAction(
    _AuditAction action,
    AppLocalizations l10n,
    bool isArabic,
  ) async {
    var status = action.status;
    final reasonController = TextEditingController(
      text: isArabic ? action.reasonAr : action.reasonEn,
    );
    try {
      final edited = await showDialog<_AuditAction>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(l10n.productReportEditDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<_ReportActionStatus>(
                  initialValue: status,
                  decoration: InputDecoration(
                    labelText: l10n.productReportActionStatus,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: _ReportActionStatus.hidden,
                      child: Text(l10n.productReportHidden),
                    ),
                    DropdownMenuItem(
                      value: _ReportActionStatus.approved,
                      child: Text(l10n.productReportApproved),
                    ),
                    DropdownMenuItem(
                      value: _ReportActionStatus.rejected,
                      child: Text(l10n.productReportRejected),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => status = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.productReportActionReason,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.productCancelAction),
              ),
              FilledButton(
                onPressed: () {
                  final reason = reasonController.text.trim();
                  Navigator.pop(
                    dialogContext,
                    action.copyWith(
                      status: status,
                      reasonAr: isArabic ? reason : action.reasonAr,
                      reasonEn: isArabic ? action.reasonEn : reason,
                    ),
                  );
                },
                child: Text(l10n.productReportApplyEdit),
              ),
            ],
          ),
        ),
      );
      if (edited == null || !mounted) return;
      setState(() {
        _draftActions = _draftActions
            .map((item) => item.adNumber == edited.adNumber ? edited : item)
            .toList();
        _hasUnsavedChanges = true;
      });
    } finally {
      reasonController.dispose();
    }
  }

  void _showAllActions(AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.productReportAuditTitle),
        content: Text(l10n.productReportRecentActionsNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.productCancelAction),
          ),
        ],
      ),
    );
  }

  Widget _buildDataNote(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          MotionIcon(Icons.shield_outlined, size: 17, color: AppColors.info),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              l10n.productReportDataNote,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ),
          MotionIcon(Icons.circle, size: 6, color: AppColors.info),
        ],
      ),
    );
  }

  Widget _buildSaveActions(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _saveChanges,
              icon: const MotionIcon(Icons.check_circle_outline, size: 18),
              label: Text(l10n.productReportSaveAndUpdate),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: TextButton(
              onPressed: _hasUnsavedChanges ? _discardChanges : null,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                l10n.productReportDiscardChanges,
                style: TextStyle(
                  color: _hasUnsavedChanges
                      ? AppColors.textSecondary
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _savedActions = List.of(_draftActions);
      _hasUnsavedChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.productReportSaved)),
    );
  }

  void _discardChanges() {
    setState(() {
      _draftActions = List.of(_savedActions);
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _showExportDialog(AppLocalizations l10n) async {
    final metrics = _metricsForSelectedPeriod();
    final report = [
      l10n.productReportTitle,
      '${l10n.productReportReviewedAds},${metrics.reviewed}',
      '${l10n.productReportApprovalRate},${metrics.approvalRate}',
      l10n.productReportApprovedCount(metrics.approved),
      l10n.productReportDeclinedCount(metrics.declined),
      '${l10n.productReportAverageReview},${metrics.averageMinutes}',
    ].map(_escapeCsv).join('\n');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.productReportExportTitle),
        content: SelectableText(report),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.productCancelAction),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final live = await _liveFuture.catchError(
                (_) => const _LiveStats(
                  openComplaints: 0,
                  overdueComplaints: 0,
                  resolvedComplaints: 0,
                  withHead: 0,
                  returnedByHead: 0,
                  atAdmin: 0,
                  overdueEscalations: 0,
                ),
              );
              await CsvExporter.share(
                fileName: 'products_report_${CsvExporter.stamp()}.csv',
                title: l10n.productReportTitle,
                headers: const ['المؤشر', 'القيمة'],
                rows: [
                  [l10n.productReportReviewedAds, '${metrics.reviewed}'],
                  [l10n.productReportApprovalRate, metrics.approvalRate],
                  ['معتمدة', '${metrics.approved}'],
                  ['مرفوضة/موقوفة', '${metrics.declined}'],
                  ['شكاوى مفتوحة', '${live.openComplaints}'],
                  ['شكاوى متأخرة', '${live.overdueComplaints}'],
                  ['شكاوى منتهية', '${live.resolvedComplaints}'],
                  ['عند رئيس المشرفين', '${live.withHead}'],
                  ['أعادها الرئيس', '${live.returnedByHead}'],
                  ['عند الأدمن عبر الرئيس', '${live.atAdmin}'],
                  ['تصعيدات متأخرة', '${live.overdueEscalations}'],
                ],
              );
            },
            icon: const MotionIcon(Icons.share_outlined, size: 16),
            label: Text(isArabicDialog(l10n) ? 'مشاركة CSV' : 'Share CSV'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: report));
              if (!dialogContext.mounted || !mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.productReportExportCopied)),
              );
            },
            icon: const MotionIcon(Icons.copy, size: 16),
            label: Text(l10n.productReportCopyCsv),
          ),
        ],
      ),
    );
  }

  bool isArabicDialog(AppLocalizations l10n) => l10n.localeName.startsWith('ar');

  String _escapeCsv(String value) => '"${value.replaceAll('"', '""')}"';

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MotionIcon(icon, color: AppColors.info, size: 19),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 5),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _smallTag(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
        value,
        maxLines: 1,
 softWrap: false,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      )),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );
}

class _MetricCardData {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color iconColor;
  final bool isDanger;
  final String? unit;

  const _MetricCardData({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.iconColor,
    this.isDanger = false,
    this.unit,
  });
}

class _ReportCategoryData {
  final String name;
  final int count;
  final double percent;
  final IconData icon;
  final Color color;

  const _ReportCategoryData({
    required this.name,
    required this.count,
    required this.percent,
    required this.icon,
    required this.color,
  });
}
