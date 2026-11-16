import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/products/domain/entities/product_report.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_report_cubit.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_report_state.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_audit_screen.dart';
import 'package:barwah_app/features/support/data/datasources/support_inbox_api_data_source.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

enum _ReportPeriod { today, week, month, all, custom }

/// شكاوى المنتجات الجديدة من التذاكر اللي المستخدمين بيرفعوها.
class _ComplaintStats {
  final int open;
  final int overdue;
  final int closed;

  const _ComplaintStats({
    required this.open,
    required this.overdue,
    required this.closed,
  });
}

class ProductReportsScreen extends StatefulWidget {
  const ProductReportsScreen({super.key});

  @override
  State<ProductReportsScreen> createState() => _ProductReportsScreenState();
}

class _ProductReportsScreenState extends State<ProductReportsScreen> {
  _ReportPeriod _period = _ReportPeriod.week;
  DateTimeRange? _customRange;

  ProductReport? _report;
  bool _loading = false;
  bool _failed = false;
  ProductReportCubit? _reportCubit;

  /// للوضع التجريبي فقط (بدون تسجيل دخول حقيقي).
  List<ProductSupervisorAuditEntry> _auditEntries = [];

  Future<_ComplaintStats>? _complaintsFuture;

  bool get _remote => AuthSession.isSignedIn;

  String get _apiPeriod => switch (_period) {
        _ReportPeriod.today => 'today',
        _ReportPeriod.week => 'week',
        _ReportPeriod.month => 'month',
        _ReportPeriod.all => 'all',
        _ReportPeriod.custom => 'custom',
      };

  @override
  void initState() {
    super.initState();
    if (_remote) {
      _reportCubit = sl<ProductReportCubit>();
      _complaintsFuture = _loadComplaints();
    } else {
      _loadLocalEntries();
    }
    _loadReport();
  }

  @override
  void dispose() {
    _reportCubit?.close();
    super.dispose();
  }

  // ---------------------------------------------------------------- data

  Future<void> _loadReport() async {
    final cubit = _reportCubit;
    if (cubit == null) return;
    if (_period == _ReportPeriod.custom && _customRange == null) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    await cubit.load(
      _apiPeriod,
      from: _customRange?.start,
      to: _customRange?.end,
    );
    if (!mounted) return;
    final state = cubit.state;
    // طلب أحدث لسه شغال → نسيب النتيجة له.
    if (state is ProductReportLoading) return;
    setState(() {
      _loading = false;
      if (state is ProductReportLoaded && state.period == _apiPeriod) {
        _report = state.report;
      } else if (state is ProductReportLoadFailure) {
        _failed = true;
      }
    });
  }

  Future<void> _loadLocalEntries() async {
    try {
      final entries = await sl<ProductSupervisorAuditRepository>().getEntries();
      if (!mounted) return;
      setState(() => _auditEntries = entries);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'product reports audit loading',
      ));
    }
  }

  /// الشكاوى = التذاكر الواصلة لمشرف المنتجات الجديدة من `api/Supporter/Inbox`.
  Future<_ComplaintStats> _loadComplaints() async {
    final inbox = SupportInboxApiDataSource(
      apiConsumer: sl<ApiConsumer>(instanceName: 'berwah'),
    );
    final open = await inbox.load(status: 'open');
    final closed = await inbox.load(status: 'closed');
    final now = DateTime.now();
    return _ComplaintStats(
      open: open.length,
      overdue: open
          .where((t) => now.difference(t.createdAt) > const Duration(hours: 24))
          .length,
      closed: closed.length,
    );
  }

  /// بديل محلي للوضع التجريبي: تقرير من سجل القرارات المحفوظ على الجهاز.
  ProductReport _localReport() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? start;
    DateTime end = now;
    switch (_period) {
      case _ReportPeriod.today:
        start = today;
      case _ReportPeriod.week:
        start = today.subtract(Duration(days: today.weekday - 1));
      case _ReportPeriod.month:
        start = DateTime(now.year, now.month);
      case _ReportPeriod.all:
        start = null;
      case _ReportPeriod.custom:
        final r = _customRange;
        if (r != null) {
          start = DateTime(r.start.year, r.start.month, r.start.day);
          end = DateTime(r.end.year, r.end.month, r.end.day, 23, 59, 59);
        } else {
          start = today;
        }
    }
    const keys = {
      'product_approved',
      'product_hidden',
      'product_rejected',
      'product_suspended',
    };
    final rows = _auditEntries.where((e) =>
        keys.contains(e.actionKey) &&
        (start == null || !e.occurredAt.isBefore(start)) &&
        !e.occurredAt.isAfter(end));
    final approved = rows.where((e) => e.actionKey == 'product_approved').length;
    final suspended =
        rows.where((e) => e.actionKey == 'product_suspended').length;
    final rejected = rows.length - approved - suspended;
    final total = rows.length;
    double rate(int n) => total == 0 ? 0 : n * 100 / total;
    return ProductReport(
      reviewed: total,
      approved: approved,
      declined: rejected,
      suspended: suspended,
      pending: 0,
      approvalRate: rate(approved),
      rejectionRate: rate(rejected),
      logs: const [],
    );
  }

  ProductReport get _current => _report ?? (_remote ? _empty : _localReport());

  static const _empty = ProductReport(
    reviewed: 0,
    approved: 0,
    declined: 0,
    suspended: 0,
    pending: 0,
    approvalRate: 0,
    rejectionRate: 0,
    logs: [],
  );

  // --------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final report = _current;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: BrandRefreshIndicator(
        onRefresh: () async {
          if (_remote) {
            setState(() => _complaintsFuture = _loadComplaints());
          }
          await _loadReport();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            ScrollFx(child: _buildReportHeading(l10n, report, isArabic)),
            const SizedBox(height: 14),
            ScrollFx(child: _buildPeriodSelector(l10n, isArabic)),
            if (_loading) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(minHeight: 2),
            ],
            if (_failed) ...[
              const SizedBox(height: 10),
              _buildErrorBanner(isArabic),
            ],
            const SizedBox(height: 18),
            ScrollFx(child: _buildMetrics(report, l10n, isArabic)),
            const SizedBox(height: 18),
            ScrollFx(child: _buildDecisionsSection(report, isArabic)),
            if (_remote) ...[
              const SizedBox(height: 18),
              ScrollFx(child: _buildComplaintsSection(isArabic)),
            ],
            const SizedBox(height: 18),
            ScrollFx(child: _buildCategoriesSection(report, isArabic)),
            if (_remote) ...[
              const SizedBox(height: 18),
              ScrollFx(child: _buildPromotionsSection(report, isArabic)),
            ],
            const SizedBox(height: 18),
            ScrollFx(child: _buildAuditSection(report, l10n, isArabic)),
            const SizedBox(height: 16),
            ScrollFx(child: _buildDataNote(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          MotionIcon(Icons.error_outline, size: 17, color: AppColors.danger),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              isArabic
                  ? 'تعذر تحميل التقرير. الأرقام المعروضة قد تكون قديمة.'
                  : 'Could not load the report. Figures shown may be stale.',
              style: TextStyle(color: AppColors.dangerDark, fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: _loadReport,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Retry',
                style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportHeading(
    AppLocalizations l10n,
    ProductReport report,
    bool isArabic,
  ) {
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
          onPressed: () => _showExportDialog(l10n, report, isArabic),
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

  Widget _buildPeriodSelector(AppLocalizations l10n, bool isArabic) {
    final periods = [
      (_ReportPeriod.today, l10n.productReportToday),
      (_ReportPeriod.week, l10n.productReportThisWeek),
      (_ReportPeriod.month, l10n.productReportThisMonth),
      (_ReportPeriod.all, isArabic ? 'الكل' : 'All time'),
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
                      ? const MotionIcon(Icons.calendar_month_outlined,
                          size: 15)
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
        _report = null;
      });
      _loadReport();
      return;
    }
    setState(() {
      _period = period;
      _report = null;
    });
    _loadReport();
  }

  String _formatDateRange(DateTimeRange range) {
    String format(DateTime date) =>
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    return '${format(range.start)} - ${format(range.end)}';
  }

  // ------------------------------------------------------------- metrics

  /// متوسط وقت المراجعة بوحدة مناسبة (دقيقة / ساعة / يوم).
  (String, String?) _averageText(double? minutes, AppLocalizations l10n) {
    if (minutes == null) return ('—', null);
    final isArabic = l10n.localeName.startsWith('ar');
    if (minutes >= 1440) {
      return ((minutes / 1440).toStringAsFixed(1), isArabic ? 'يوم' : 'd');
    }
    if (minutes >= 60) {
      return ((minutes / 60).toStringAsFixed(1), isArabic ? 'ساعة' : 'h');
    }
    return (minutes.round().toString(), l10n.productReportMinuteUnit);
  }

  Widget _buildMetrics(
    ProductReport report,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final change = report.changePercent;
    final changeText = change == null
        ? '—'
        : '${change > 0 ? '+' : ''}${change.round()}%';
    final avg = _averageText(report.averageMinutes, l10n);
    final cards = [
      _MetricCardData(
        title: l10n.productReportReviewedAds,
        value: report.reviewed.toString(),
        detail: '$changeText ${l10n.productReportComparedToPrevious}',
        icon: Icons.shield_outlined,
        iconColor: AppColors.info,
      ),
      _MetricCardData(
        title: l10n.productReportApprovalRate,
        value: '${report.approvalRate.round()}%',
        detail: l10n.productReportApprovedCount(report.approved),
        icon: Icons.check_circle,
        iconColor: AppColors.infoDark,
      ),
      _MetricCardData(
        title: l10n.productReportDeclinedRate,
        value: '${report.rejectionRate.round()}%',
        detail: l10n.productReportDeclinedCount(report.declined),
        icon: Icons.block_outlined,
        iconColor: AppColors.danger,
        isDanger: true,
      ),
      _MetricCardData(
        title: l10n.productReportAverageReview,
        value: avg.$1,
        detail: report.averageMinutes == null
            ? (isArabic ? 'لا توجد قرارات بعد' : 'No decisions yet')
            : (isArabic
                ? 'من الإرسال حتى القرار'
                : 'From submission to decision'),
        icon: Icons.timer_outlined,
        iconColor: AppColors.ink,
        unit: avg.$2,
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
                  color: data.isDanger ? AppColors.danger : AppColors.ink,
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

  // ----------------------------------------------------------- sections

  Widget _countRow(String label, int value, {bool alert = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
            CountText(
              '$value',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color:
                    alert && value > 0 ? AppColors.dangerDark : AppColors.ink,
              ),
            ),
          ],
        ),
      );

  Widget _buildDecisionsSection(ProductReport report, bool isArabic) {
    return _sectionCard(
      title: isArabic ? 'القرارات في الفترة' : 'Decisions in period',
      icon: Icons.fact_check_outlined,
      child: Column(
        children: [
          _countRow(isArabic ? 'معتمدة' : 'Approved', report.approved),
          _countRow(isArabic ? 'مرفوضة' : 'Rejected', report.declined),
          _countRow(isArabic ? 'موقوفة / معلّقة' : 'Suspended', report.suspended),
          const Divider(),
          _countRow(
            isArabic ? 'في انتظار المراجعة الآن' : 'Waiting for review now',
            report.pending,
            alert: report.pending > 10,
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsSection(bool isArabic) {
    return FutureBuilder<_ComplaintStats>(
      future: _complaintsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        return _sectionCard(
          title: isArabic
              ? 'شكاوى المنتجات الجديدة'
              : 'New-product complaints',
          icon: Icons.support_agent_outlined,
          child: snapshot.hasError
              ? Text(
                  isArabic
                      ? 'تعذر تحميل الشكاوى.'
                      : 'Could not load complaints.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                )
              : stats == null
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        _countRow(
                            isArabic ? 'شكاوى مفتوحة' : 'Open complaints',
                            stats.open),
                        _countRow(
                            isArabic
                                ? 'شكاوى متأخرة (+24 ساعة)'
                                : 'Overdue complaints (24h+)',
                            stats.overdue,
                            alert: true),
                        _countRow(
                            isArabic ? 'شكاوى منتهية' : 'Closed complaints',
                            stats.closed),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildCategoriesSection(ProductReport report, bool isArabic) {
    const colors = [
      Color(0xFF2E7D6B),
      Color(0xFF3F6FB5),
      Color(0xFFB5833F),
      Color(0xFF8A4FB0),
      Color(0xFFB5463F),
      Color(0xFF4F8AB0),
    ];
    return _sectionCard(
      title: isArabic ? 'توزيع الإعلانات حسب القسم' : 'Ads by category',
      icon: Icons.category_outlined,
      child: report.categories.isEmpty
          ? Text(
              isArabic
                  ? 'لا توجد إعلانات في هذه الفترة.'
                  : 'No ads in this period.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            )
          : Column(
              children: [
                for (var i = 0; i < report.categories.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCategoryRow(
                      report.categories[i],
                      colors[i % colors.length],
                      isArabic,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildCategoryRow(
    ProductReportCategory data,
    Color color,
    bool isArabic,
  ) {
    final parts = [
      if (data.approved > 0) '${isArabic ? 'معتمد' : 'Approved'} ${data.approved}',
      if (data.rejected > 0) '${isArabic ? 'مرفوض' : 'Rejected'} ${data.rejected}',
      if (data.suspended > 0)
        '${isArabic ? 'موقوف' : 'Suspended'} ${data.suspended}',
      if (data.pending > 0)
        '${isArabic ? 'قيد المراجعة' : 'Pending'} ${data.pending}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MotionIcon(Icons.folder_outlined, size: 15, color: color),
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
              '${data.percent.round()}%',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${data.count})',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (data.percent / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceHighlight,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        if (parts.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            parts.join(' • '),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
          ),
        ],
      ],
    );
  }

  Widget _buildPromotionsSection(ProductReport report, bool isArabic) {
    final p = report.promotions;
    return _sectionCard(
      title: isArabic ? 'الترويج' : 'Promotions',
      icon: Icons.campaign_outlined,
      child: Column(
        children: [
          _countRow(isArabic ? 'طلبات إعلان مميز' : 'Featured requests',
              p.featuredRequests),
          _countRow(isArabic ? 'طلبات VIP' : 'VIP requests', p.vipRequests),
          _countRow(
            isArabic ? 'الإيراد (طلبات مقبولة)' : 'Revenue (approved)',
            p.revenue.round(),
          ),
          const Divider(),
          _countRow(isArabic ? 'طلبات ترويج منتظرة قرارك' : 'Requests awaiting you',
              p.pendingRequests,
              alert: true),
          _countRow(isArabic ? 'مميز شغّال الآن' : 'Featured running',
              p.runningFeatured),
          _countRow(
              isArabic
                  ? 'VIP شغّال الآن (الحد ${p.vipLimit})'
                  : 'VIP running (limit ${p.vipLimit})',
              p.runningVip),
          _countRow(isArabic ? 'VIP في الانتظار' : 'VIP waiting', p.waitingVip),
        ],
      ),
    );
  }

  Widget _buildAuditSection(
    ProductReport report,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return _sectionCard(
      title: l10n.productReportAuditTitle,
      icon: Icons.history,
      trailing: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ProductSupervisorAuditScreen(),
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          isArabic ? 'عرض السجل كامل' : 'View full log',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
      child: report.logs.isEmpty
          ? Text(
              isArabic
                  ? 'لا توجد إجراءات مسجلة بعد.'
                  : 'No recorded actions yet.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            )
          : Column(
              children: [
                for (final log in report.logs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _buildLogItem(log, l10n),
                  ),
              ],
            ),
    );
  }

  Widget _buildLogItem(ProductReportLog log, AppLocalizations l10n) {
    final type = log.actionType;
    final isApproved = type.contains('اعتماد');
    final isRejected = type.contains('رفض');
    final color = isApproved
        ? AppColors.infoDark
        : isRejected
            ? AppColors.danger
            : AppColors.textSecondary;
    final icon = isApproved
        ? Icons.check
        : isRejected
            ? Icons.close
            : Icons.pause_circle_outline;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MotionIcon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productReportActionHeadline(log.adNumber),
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  log.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
                ),
                if (log.reason.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontSize: 9),
                  ),
                ],
                if (log.supervisorName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.supervisorName,
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _smallTag(type),
              const SizedBox(height: 5),
              Text(
                log.timeAgo,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 8),
              ),
            ],
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
              style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
            ),
          ),
          MotionIcon(Icons.circle, size: 6, color: AppColors.info),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- export

  Future<void> _showExportDialog(
    AppLocalizations l10n,
    ProductReport report,
    bool isArabic,
  ) async {
    final avg = _averageText(report.averageMinutes, l10n);
    final avgText = avg.$2 == null ? avg.$1 : '${avg.$1} ${avg.$2}';
    final p = report.promotions;

    _ComplaintStats? complaints;
    if (_complaintsFuture != null) {
      try {
        complaints = await _complaintsFuture!;
      } on Object {
        complaints = null;
      }
    }
    if (!mounted) return;

    final rows = <List<String>>[
      [l10n.productReportReviewedAds, '${report.reviewed}'],
      [l10n.productReportApprovalRate, '${report.approvalRate.round()}%'],
      [isArabic ? 'معتمدة' : 'Approved', '${report.approved}'],
      [isArabic ? 'مرفوضة' : 'Rejected', '${report.declined}'],
      [isArabic ? 'موقوفة' : 'Suspended', '${report.suspended}'],
      [isArabic ? 'في الانتظار' : 'Pending', '${report.pending}'],
      [l10n.productReportAverageReview, avgText],
      if (complaints != null) ...[
        [isArabic ? 'شكاوى مفتوحة' : 'Open complaints', '${complaints.open}'],
        [
          isArabic ? 'شكاوى متأخرة' : 'Overdue complaints',
          '${complaints.overdue}'
        ],
        [isArabic ? 'شكاوى منتهية' : 'Closed complaints', '${complaints.closed}'],
      ],
      for (final c in report.categories)
        [
          '${isArabic ? 'قسم' : 'Category'}: ${c.name}',
          '${c.count} (${c.percent.round()}%)'
        ],
      if (_remote) ...[
        [isArabic ? 'طلبات مميز' : 'Featured requests', '${p.featuredRequests}'],
        [isArabic ? 'طلبات VIP' : 'VIP requests', '${p.vipRequests}'],
        [isArabic ? 'إيراد الترويج' : 'Promotion revenue', '${p.revenue.round()}'],
      ],
    ];
    final text = [
      l10n.productReportTitle,
      for (final r in rows) '${r[0]},${r[1]}',
    ].map(_escapeCsv).join('\n');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.productReportExportTitle),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.productCancelAction),
          ),
          OutlinedButton.icon(
            onPressed: () => CsvExporter.share(
              fileName: 'products_report_${CsvExporter.stamp()}.csv',
              title: l10n.productReportTitle,
              headers: [isArabic ? 'المؤشر' : 'Metric', isArabic ? 'القيمة' : 'Value'],
              rows: rows,
            ),
            icon: const MotionIcon(Icons.share_outlined, size: 16),
            label: Text(isArabic ? 'مشاركة CSV' : 'Share CSV'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
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

  String _escapeCsv(String value) => '"${value.replaceAll('"', '""')}"';

  // --------------------------------------------------------------- shell

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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
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
