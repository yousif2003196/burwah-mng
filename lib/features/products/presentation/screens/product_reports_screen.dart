import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/product_supervisor_audit_entry.dart';
import '../../domain/repositories/product_supervisor_audit_repository.dart';

enum _ReportPeriod { today, week, month, custom }

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
    this.change = '—',
  });

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

  @override
  void initState() {
    super.initState();
    _loadAuditEntries();
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
      backgroundColor: const Color(0xFFF5F7F9),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              children: [
                _buildReportHeading(l10n),
                const SizedBox(height: 14),
                _buildPeriodSelector(l10n),
                const SizedBox(height: 22),
                _buildMetrics(metrics, l10n),
                const SizedBox(height: 22),
                _buildStandardsSection(l10n),
                const SizedBox(height: 22),
                _buildAuditSection(l10n, isArabic),
                const SizedBox(height: 16),
                _buildDataNote(l10n),
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
                  const Icon(Icons.analytics_outlined,
                      size: 15, color: AppColors.info),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      l10n.productReportEyebrow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
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
                style: const TextStyle(
                  color: AppColors.primaryDark,
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
          icon: const Icon(Icons.file_download_outlined, size: 17),
          label: Text(l10n.productReportExport),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            backgroundColor: Colors.white,
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
                  ? const Icon(Icons.circle, size: 7, color: Color(0xFF8DBBFF))
                  : entry.$1 == _ReportPeriod.custom
                      ? const Icon(Icons.calendar_month_outlined, size: 15)
                      : null,
              label: Text(label),
              onSelected: (_) => _selectPeriod(entry.$1),
              backgroundColor: Colors.white,
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
        iconColor: const Color(0xFF3D669C),
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
        iconColor: AppColors.primaryDark,
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
                      ? const Color(0xFFFFF0EF)
                      : const Color(0xFFF0F2F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 18, color: data.iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
                      data.isDanger ? AppColors.danger : AppColors.primaryDark,
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
            style: const TextStyle(
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
              color: const Color(0xFF9CA7AC),
              isLocked: true,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _buildStandardCard(
              title: l10n.productReportSerialTitle,
              subtitle: l10n.productReportSerialHint,
              icon: Icons.qr_code_2,
              color: const Color(0xFF7A8B92),
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
        color: const Color(0xFFF3F5F6),
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
                  Icon(icon,
                      size: 52, color: Colors.white.withValues(alpha: .9)),
                  PositionedDirectional(
                    end: 6,
                    top: 6,
                    child: Icon(
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
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(_ReportMetrics metrics, AppLocalizations l10n) {
    final categories = [
      _ReportCategoryData(
        name: l10n.productReportElectronics,
        count: (metrics.reviewed * .48).floor(),
        percent: .48,
        icon: Icons.phone_iphone_outlined,
        color: const Color(0xFF061A36),
      ),
      _ReportCategoryData(
        name: l10n.productReportGames,
        count: (metrics.reviewed * .26).round(),
        percent: .26,
        icon: Icons.sports_esports_outlined,
        color: const Color(0xFF3D669C),
      ),
      _ReportCategoryData(
        name: l10n.productReportPerfumes,
        count: metrics.reviewed -
            (metrics.reviewed * .48).floor() -
            (metrics.reviewed * .26).round() -
            (metrics.reviewed * .10).round(),
        percent: .16,
        icon: Icons.watch_outlined,
        color: const Color(0xFF445D85),
      ),
      _ReportCategoryData(
        name: l10n.productReportHomeAppliances,
        count: (metrics.reviewed * .10).round(),
        percent: .10,
        icon: Icons.kitchen_outlined,
        color: const Color(0xFF80868B),
      ),
    ];

    return _sectionCard(
      title: l10n.productReportCategoryTitle,
      icon: Icons.category_outlined,
      trailing: Text(
        l10n.productReportAdsCount(metrics.reviewed),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
      child: Column(
        children: categories
            .map((category) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCategoryRow(category),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCategoryRow(_ReportCategoryData data) {
    return Column(
      children: [
        Row(
          children: [
            Icon(data.icon, size: 15, color: AppColors.info),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '${(data.percent * 100).round()}%',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${data.count})',
              style: const TextStyle(
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
            backgroundColor: const Color(0xFFE9ECEF),
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
      _ReportActionStatus.approved => const Color(0xFF3D669C),
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
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.productReportActionHeadline(action.adNumber),
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isArabic ? action.titleAr : action.titleEn,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
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
                    style: const TextStyle(
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
              icon: const Icon(Icons.edit_note, size: 16),
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
        color: const Color(0xFFF0F2F4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 17, color: AppColors.info),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              l10n.productReportDataNote,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ),
          const Icon(Icons.circle, size: 6, color: Color(0xFF8DBBFF)),
        ],
      ),
    );
  }

  Widget _buildSaveActions(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.check_circle_outline, size: 18),
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
                backgroundColor: const Color(0xFFF1F3F5),
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
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: report));
              if (!dialogContext.mounted || !mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.productReportExportCopied)),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: Text(l10n.productReportCopyCsv),
          ),
        ],
      ),
    );
  }

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
              Icon(icon, color: AppColors.info, size: 19),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
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
        color: const Color(0xFFEDEFF1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF1F3)),
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
