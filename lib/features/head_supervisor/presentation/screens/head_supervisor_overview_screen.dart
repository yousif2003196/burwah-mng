import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_audit_store.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_complaint_store.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_audit_record.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_complaint_summary.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_record.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_complaints_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_requests_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_supervisors_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class HeadSupervisorOverviewScreen extends StatefulWidget {
  const HeadSupervisorOverviewScreen({super.key});

  @override
  State<HeadSupervisorOverviewScreen> createState() =>
      _HeadSupervisorOverviewScreenState();
}

class _HeadSupervisorOverviewScreenState
    extends State<HeadSupervisorOverviewScreen> {
  final _events = LocalEventStore();
  final _roster = HeadSupervisorRosterStore();
  final _audit = HeadSupervisorAuditStore();
  late Future<_OverviewData> _data;

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_refresh);
    HeadSupervisorRosterStore.revision.addListener(_refresh);
    HeadSupervisorAuditStore.revision.addListener(_refresh);
    HeadSupervisorComplaintStore.revision.addListener(_refresh);
    _data = _load();
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_refresh);
    HeadSupervisorRosterStore.revision.removeListener(_refresh);
    HeadSupervisorAuditStore.revision.removeListener(_refresh);
    HeadSupervisorComplaintStore.revision.removeListener(_refresh);
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _data = _load();
  }

  void _refresh() {
    if (mounted) setState(() => _data = _load());
  }

  Future<_OverviewData> _load() async {
    final results = await Future.wait<Object>([
      _events.getEvents('head'),
      _roster.getAll(),
      _audit.getAll(),
      HeadSupervisorComplaintSummary.getOpenCount(),
    ]);
    final events = (results[0] as List<LocalEvent>)
        .where((event) =>
            event.recipient == 'head' && !event.id.startsWith('demo-'))
        .toList();
    final supervisors = results[1] as List<HeadSupervisorRecord>;
    final auditRecords = results[2] as List<HeadSupervisorAuditRecord>;
    final today = DateTime.now();
    final todayActions = auditRecords.where((record) {
      final date = record.occurredAt.toLocal();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
    final days = List<DateTime>.generate(
      7,
      (index) => DateTime(today.year, today.month, today.day - 6 + index),
    );
    const departmentSources = <String, String>{
      'التجار': 'merchant',
      'وصلني': 'wasalny',
      'المنتجات': 'products',
      'الخدمات': 'services',
    };
    return _OverviewData(
      pendingRequests: events.where((event) => !event.isRead).length,
      activeSupervisors: supervisors
          .where((supervisor) =>
              !supervisor.suspended && !supervisor.deletionPending)
          .length,
      supervisors: supervisors,
      todayActions: todayActions,
      openComplaints: results[3] as int,
      pendingItems: events.where((event) => !event.isRead).take(5).toList(),
      trendDays: days,
      workflowTrends: {
        for (final entry in departmentSources.entries)
          entry.key: [
            for (final day in days)
              events.where((event) {
                final createdAt = event.createdAt.toLocal();
                return event.source == entry.value &&
                    createdAt.year == day.year &&
                    createdAt.month == day.month &&
                    createdAt.day == day.day;
              }).length,
          ],
      },
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (routeContext) => Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          title: Text(
            headSupervisorText(
              routeContext,
              arabic: page is HeadSupervisorSupervisorsScreen
                  ? 'المشرفون'
                  : page is HeadSupervisorRequestsScreen
                      ? 'كل الطلبات'
                      : 'الشكاوى',
              english: page is HeadSupervisorSupervisorsScreen
                  ? 'Supervisors'
                  : page is HeadSupervisorRequestsScreen
                      ? 'All requests'
                      : 'Complaints',
            ),
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: true,
        ),
        body: page,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: AppColors.scaffold,
        child: FutureBuilder<_OverviewData>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(headSupervisorText(context,
                      arabic: 'تعذر تحميل مؤشرات لوحة المتابعة.',
                      english: 'Could not load dashboard metrics.')),
                  TextButton(
                    onPressed: _refresh,
                    child: Text(headSupervisorText(context,
                        arabic: 'إعادة المحاولة', english: 'Retry')),
                  ),
                ]),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ScrollFx(child: _HeroCard(
                  pending: data.pendingRequests,
                  todayActions: data.todayActions,
                  activeSupervisors: data.activeSupervisors,
                  openComplaints: data.openComplaints,
                )),
                const SizedBox(height: 18),
                ScrollFx(child: _SectionTitle(
                  title: headSupervisorText(context,
                      arabic: 'يحتاج قرارك الآن',
                      english: 'Needs your decision'),
                  action: headSupervisorText(context,
                      arabic: 'عرض الكل', english: 'View all'),
                  onAction: () => _open(
                      context, const HeadSupervisorRequestsScreen()),
                )),
                const SizedBox(height: 10),
                ScrollFx(child: _PendingWorkPanel(
                  events: data.pendingItems,
                  onOpen: () => _open(
                      context, const HeadSupervisorRequestsScreen()),
                )),
                const SizedBox(height: 12),
                ScrollFx(child: Row(children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.badge_outlined,
                      title: headSupervisorText(context,
                          arabic: 'المشرفون النشطون',
                          english: 'Active supervisors'),
                      value: '${data.activeSupervisors}',
                      color: AppColors.info,
                      background: AppColors.infoLight,
                      onTap: () => _open(
                          context,
                          const HeadSupervisorSupervisorsScreen(
                              initialFilter: 'active')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.report_gmailerrorred_outlined,
                      title: headSupervisorText(context,
                          arabic: 'الشكاوى المفتوحة',
                          english: 'Open complaints'),
                      value: '${data.openComplaints}',
                      color: AppColors.danger,
                      background: AppColors.dangerLight,
                      onTap: () => _open(
                          context, const HeadSupervisorComplaintsScreen()),
                    ),
                  ),
                ])),
                const SizedBox(height: 12),
                ScrollFx(child: _WorkflowChart(
                  days: data.trendDays,
                  trends: data.workflowTrends,
                )),
                const SizedBox(height: 12),
                ScrollFx(child: _SupervisorStrip(
                  supervisors: data.supervisors,
                  onShowAll: () => _open(
                      context, const HeadSupervisorSupervisorsScreen()),
                )),
                const SizedBox(height: 12),
                ScrollFx(child: const _FinanceNoticeCard()),
              ],
            );
          },
        ),
      );
}

class _OverviewData {
  final int pendingRequests;
  final int activeSupervisors;
  final List<HeadSupervisorRecord> supervisors;
  final int todayActions;
  final int openComplaints;
  final List<LocalEvent> pendingItems;
  final List<DateTime> trendDays;
  final Map<String, List<int>> workflowTrends;

  const _OverviewData({
    required this.pendingRequests,
    required this.activeSupervisors,
    required this.supervisors,
    required this.todayActions,
    required this.openComplaints,
    required this.pendingItems,
    required this.trendDays,
    required this.workflowTrends,
  });
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionTitle({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
        ),
        if (action != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(action!,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.info)),
            ),
          ),
      ]);
}

/// بطاقة الترحيب: الرقم الأهم (الطلبات المعلقة) بحجم كبير وتحته ثلاثة مؤشرات.
class _HeroCard extends StatelessWidget {
  final int pending;
  final int todayActions;
  final int activeSupervisors;
  final int openComplaints;

  const _HeroCard({
    required this.pending,
    required this.todayActions,
    required this.activeSupervisors,
    required this.openComplaints,
  });

  @override
  Widget build(BuildContext context) {
    final soft = Colors.white.withValues(alpha: 0.78);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      headSupervisorText(context,
                          arabic: 'مرحباً رئيس المشرفين',
                          english: 'Welcome, Head Supervisor'),
                      style: TextStyle(fontSize: 12, color: soft)),
                  const SizedBox(height: 4),
                  pending == 0
                      ? Text(
                          headSupervisorText(context,
                              arabic: 'لا طلبات بانتظار قرارك',
                              english: 'No requests awaiting you'),
                          style: const TextStyle(
                              fontSize: 20,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              color: Colors.white))
                      : Wrap(
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 6,
                          children: [
                            CountText('$pending',
                                style: const TextStyle(
                                    fontSize: 30,
                                    height: 1.15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                  headSupervisorText(context,
                                      arabic: 'طلبات بانتظار قرارك',
                                      english: 'requests awaiting you'),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: soft)),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const MotionIcon(Icons.shield_outlined,
                  color: Colors.white, size: 26),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _HeroStat(
                value: '$todayActions',
                label: headSupervisorText(context,
                    arabic: 'إجراءات اليوم', english: 'Actions today')),
            const SizedBox(width: 8),
            _HeroStat(
                value: '$activeSupervisors',
                label: headSupervisorText(context,
                    arabic: 'مشرف نشط', english: 'Active')),
            const SizedBox(width: 8),
            _HeroStat(
                value: '$openComplaints',
                label: headSupervisorText(context,
                    arabic: 'شكاوى مفتوحة', english: 'Open complaints')),
          ]),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CountText(value,
                  style: const TextStyle(
                      fontSize: 20,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.78))),
            ],
          ),
        ),
      );
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color background;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.background,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MotionIcon(icon, color: color, size: 19),
                ),
                const SizedBox(height: 10),
                CountText(value,
                    style: TextStyle(
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      );
}

class _WorkflowChart extends StatelessWidget {
  final List<DateTime> days;
  final Map<String, List<int>> trends;

  const _WorkflowChart({required this.days, required this.trends});

  static Map<String, Color> get _colors => <String, Color>{
    'التجار': AppColors.primaryDark,
    'وصلني': AppColors.info,
    'المنتجات': AppColors.success,
    'الخدمات': AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final hasActivity = trends.values.expand((values) => values).any((v) => v > 0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(headSupervisorText(context,
              arabic: 'مجرى سير العمل حسب القسم',
              english: 'Workflow by department'),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
          const SizedBox(height: 3),
          Text(headSupervisorText(context,
              arabic: 'عدد الطلبات المسجلة يومياً • آخر 7 أيام',
              english: 'Daily recorded requests • Last 7 days'),
              style: TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 12,
            runSpacing: 7,
            children: [
              for (final entry in _colors.entries)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(headSupervisorText(context,
                      arabic: entry.key,
                      english: switch (entry.key) {
                        'التجار' => 'Merchants',
                        'وصلني' => 'Wasalny',
                        'المنتجات' => 'Products',
                        _ => 'Services',
                      }),
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: entry.value, shape: BoxShape.circle),
                  ),
                ]),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: _WorkflowChartPainter(trends: trends),
              child: const SizedBox.expand(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35, right: 5),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final day in days)
                    CountText('${day.day}',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          if (!hasActivity) ...[
            const SizedBox(height: 6),
            Text(headSupervisorText(context,
                arabic: 'لا توجد طلبات مسجلة خلال هذه الفترة بعد.',
                english: 'No requests have been recorded during this period yet.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}

class _WorkflowChartPainter extends CustomPainter {
  final Map<String, List<int>> trends;

  const _WorkflowChartPainter({required this.trends});

  static Map<String, Color> get _colors => _WorkflowChart._colors;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0;
    const right = 7.0;
    const top = 8.0;
    const bottom = 7.0;
    final width = size.width - left - right;
    final height = size.height - top - bottom;
    final maxValue = trends.values
        .expand((values) => values)
        .fold<int>(0, (maximum, value) => value > maximum ? value : maximum)
        .toDouble();
    final maxY = maxValue == 0 ? 1.0 : maxValue;
    final gridPaint = Paint()
      ..color = AppColors.surfaceHighlight
      ..strokeWidth = 1;

    for (var line = 0; line <= 3; line++) {
      final y = top + height * line / 3;
      canvas.drawLine(Offset(left, y), Offset(left + width, y), gridPaint);
      final value = (maxY * (3 - line) / 3).round();
      final text = TextPainter(
        text: TextSpan(
          text: '$value',
          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(left - text.width - 5, y - text.height / 2));
    }

    for (final entry in _colors.entries) {
      final values = trends[entry.key] ?? const <int>[];
      if (values.isEmpty) continue;
      final path = Path();
      for (var index = 0; index < values.length; index++) {
        final x = left + (values.length <= 1
            ? width / 2
            : width * index / (values.length - 1));
        final y = top + height - height * values[index] / maxY;
        if (index == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = entry.value
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
      for (var index = 0; index < values.length; index++) {
        final x = left + (values.length <= 1
            ? width / 2
            : width * index / (values.length - 1));
        final y = top + height - height * values[index] / maxY;
        canvas.drawCircle(Offset(x, y), 2.6,
            Paint()..color = entry.value);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WorkflowChartPainter oldDelegate) =>
      oldDelegate.trends != trends;
}

class _PendingWorkPanel extends StatelessWidget {
  final List<LocalEvent> events;
  final VoidCallback onOpen;

  const _PendingWorkPanel({required this.events, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: events.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Column(children: [
                MotionIcon(Icons.task_alt_rounded,
                    size: 28, color: AppColors.success),
                const SizedBox(height: 8),
                Text(
                    headSupervisorText(context,
                        arabic: 'لا توجد طلبات معلقة تحتاج إلى مراجعتك.',
                        english:
                            'There are no pending requests that need your review.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ]),
            )
          : Column(children: [
              for (var i = 0; i < events.length; i++) ...[
                if (i > 0) Divider(height: 1, color: AppColors.cardBorder),
                InkWell(
                  onTap: onOpen,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _tint(events[i].source).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MotionIcon(Icons.assignment_outlined,
                            size: 18, color: _tint(events[i].source)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                isArabic
                                    ? events[i].titleAr
                                    : events[i].titleEn,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink)),
                            const SizedBox(height: 2),
                            Text(
                                '${_departmentName(context, events[i].source)} • ${_ago(context, events[i].createdAt)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      MotionIcon(Icons.chevron_right_rounded,
                          size: 20, color: AppColors.textMuted),
                    ]),
                  ),
                ),
              ],
            ]),
    );
  }

  Color _tint(String source) => switch (source) {
        'merchant' => AppColors.info,
        'wasalny' => AppColors.success,
        'products' => AppColors.purple,
        'services' => AppColors.warning,
        _ => AppColors.textSecondary,
      };

  String _ago(BuildContext context, DateTime date) {
    final minutes = DateTime.now().difference(date).inMinutes;
    if (minutes < 1) {
      return headSupervisorText(context, arabic: 'الآن', english: 'Just now');
    }
    if (minutes < 60) {
      return headSupervisorText(context,
          arabic: 'منذ $minutes د', english: '$minutes min ago');
    }
    final hours = minutes ~/ 60;
    if (hours < 24) {
      return headSupervisorText(context,
          arabic: 'منذ $hours ساعة', english: '$hours h ago');
    }
    final days = hours ~/ 24;
    return headSupervisorText(context,
        arabic: 'منذ $days يوم', english: '$days d ago');
  }

  String _departmentName(BuildContext context, String source) {
    final (arabic, english) = switch (source) {
      'merchant' => ('التجار', 'Merchants'),
      'wasalny' => ('وصلني', 'Wasalny'),
      'products' => ('المنتجات', 'Products'),
      'services' => ('الخدمات', 'Services'),
      _ => ('الإدارة', 'Management'),
    };
    return headSupervisorText(context, arabic: arabic, english: english);
  }
}

class _SupervisorStrip extends StatelessWidget {
  final List<HeadSupervisorRecord> supervisors;
  final VoidCallback onShowAll;
  const _SupervisorStrip({required this.supervisors, required this.onShowAll});

  @override
  Widget build(BuildContext context) {
    final visibleSupervisors = supervisors.take(4).toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _SectionTitle(
          title: headSupervisorText(context,
              arabic: 'فريق الإشراف', english: 'Supervision team'),
          action: headSupervisorText(context,
              arabic: 'عرض الكل', english: 'View all'),
          onAction: onShowAll,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final supervisor in visibleSupervisors)
              Container(
                width: 190,
                margin: const EdgeInsetsDirectional.only(end: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: supervisor.color,
                    child: Text(supervisor.avatar,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(supervisor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink)),
                        Text(
                            supervisor.department
                                .replaceFirst('قسم ', 'مشرف '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _FinanceNoticeCard extends StatelessWidget {
  const _FinanceNoticeCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              MotionIcon(Icons.lock_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('غير متاح لرئيس المشرفين',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ),
              const Spacer(),
              Text('القسم المالي والتحصيل',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ]),
            const SizedBox(height: 5),
            Text('صلاحيات حصرية للإدارة المالية',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'الاطلاع على الأرصدة البنكية، طلبات سحب الأرباح، وحسابات التسوية المالية يقع خارج نطاق الإشراف التشغيلي، ويقتصر حصرياً على مجلس الإدارة المالية العليا ومكتب المدير العام لضمان بروتوكولات الحوكمة المعتمدة.',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 12, height: 1.6, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Text('البروتوكول رقم 402',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Spacer(),
              Text('نظام التشفير وحجب الصلاحيات: نشط ومقيد',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              SizedBox(width: 4),
              MotionIcon(Icons.shield_outlined, size: 12, color: AppColors.textSecondary),
            ]),
          ],
        ),
      );
}
