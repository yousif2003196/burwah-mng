import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../data/head_supervisor_audit_store.dart';
import '../../data/head_supervisor_complaint_store.dart';
import '../../data/head_supervisor_complaint_summary.dart';
import '../../data/head_supervisor_roster_store.dart';
import 'head_supervisor_complaints_screen.dart';
import 'head_supervisor_requests_screen.dart';
import 'head_supervisor_supervisors_screen.dart';
import '../head_supervisor_text.dart';

class HeadSupervisorOverviewScreen extends StatefulWidget {
  const HeadSupervisorOverviewScreen({super.key});

  @override
  State<HeadSupervisorOverviewScreen> createState() =>
      _HeadSupervisorOverviewScreenState();
}

class _HeadSupervisorOverviewScreenState
    extends State<HeadSupervisorOverviewScreen> {
  final _events = WasalnyLocalEventStore();
  final _roster = HeadSupervisorRosterStore();
  final _audit = HeadSupervisorAuditStore();
  late Future<_OverviewData> _data;

  @override
  void initState() {
    super.initState();
    WasalnyLocalEventStore.revision.addListener(_refresh);
    HeadSupervisorRosterStore.revision.addListener(_refresh);
    HeadSupervisorAuditStore.revision.addListener(_refresh);
    HeadSupervisorComplaintStore.revision.addListener(_refresh);
    _data = _load();
  }

  @override
  void dispose() {
    WasalnyLocalEventStore.revision.removeListener(_refresh);
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
    final events = (results[0] as List<WasalnyLocalEvent>)
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
        backgroundColor: AppColors.background,
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
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          centerTitle: true,
        ),
        body: page,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: AppColors.background,
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                _WelcomeCard(
                  title: headSupervisorText(context,
                      arabic: 'مرحباً رئيس المشرفين',
                      english: 'Welcome, Head Supervisor'),
                  badge: headSupervisorText(context,
                      arabic: 'لوحة متابعة', english: 'Live overview'),
                  subtitle:
                      'العمليات الميدانية نشطة الآن • تغطية شاملة لـ 4 أقسام تشغيلية بدقة وكفاءة',
                ),
                const SizedBox(height: 10),
                _SnapshotStrip(
                  todayActions: data.todayActions,
                  pendingRequests: data.pendingRequests,
                ),
                const SizedBox(height: 18),
                Row(children: [
                  const Icon(Icons.analytics_outlined,
                      color: Color(0xFF315F9A), size: 15),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Text('نظرة تشغيلية فورية',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark)),
                  ),
                  Text(headSupervisorText(context,
                      arabic: '3 مؤشرات مباشرة',
                      english: '3 live indicators'),
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.badge_outlined,
                  title: headSupervisorText(context,
                      arabic: 'عدد المشرفين النشطين',
                      english: 'Active supervisors'),
                      value: '${data.activeSupervisors}',
                  subtitle: headSupervisorText(context,
                      arabic: 'مشرفاً ميدانياً', english: 'Field supervisors'),
                      onTap: () => _open(
                          context,
                          const HeadSupervisorSupervisorsScreen(
                              initialFilter: 'active')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.verified_user_outlined,
                      title: headSupervisorText(context,
                          arabic: 'طلبات قيد المراجعة',
                          english: 'Requests under review'),
                      value: '${data.pendingRequests}',
                      iconBackground: const Color(0xFFE3EDFF),
                      onTap: () => _open(
                          context, const HeadSupervisorRequestsScreen()),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                _MetricCard(
                  icon: Icons.report_gmailerrorred_outlined,
                  title: headSupervisorText(context,
                      arabic: 'الشكاوى المفتوحة', english: 'Open complaints'),
                  value: '${data.openComplaints}',
                  subtitle: headSupervisorText(context,
                      arabic: 'تحتاج إلى مراجعة', english: 'Need review'),
                  iconBackground: const Color(0xFFFFE9E6),
                  onTap: () => _open(
                      context, const HeadSupervisorComplaintsScreen()),
                ),
                const SizedBox(height: 14),
                _WorkflowChart(
                  days: data.trendDays,
                  trends: data.workflowTrends,
                ),
                const SizedBox(height: 12),
                _PendingWorkPanel(
                  events: data.pendingItems,
                  onOpen: () => _open(
                      context, const HeadSupervisorRequestsScreen()),
                ),
                const SizedBox(height: 12),
                _QuickLinks(
                  onRequests: () => _open(
                      context, const HeadSupervisorRequestsScreen()),
                  onSupervisors: () => _open(
                      context, const HeadSupervisorSupervisorsScreen()),
                  onComplaints: () => _open(
                      context, const HeadSupervisorComplaintsScreen()),
                ),
                const SizedBox(height: 12),
                _SupervisorStrip(
                  supervisors: data.supervisors,
                  onShowAll: () => _open(
                      context, const HeadSupervisorSupervisorsScreen()),
                ),
                const SizedBox(height: 12),
                const _FinanceNoticeCard(),
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
  final List<WasalnyLocalEvent> pendingItems;
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

class _WelcomeCard extends StatelessWidget {
  final String title;
  final String badge;
  final String subtitle;

  const _WelcomeCard({
    required this.title,
    required this.badge,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.waving_hand_rounded,
                  color: const Color(0xFFFFC94A), size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.circle, color: const Color(0xFF8DBBFF), size: 8),
              const SizedBox(width: 5),
              Text(badge,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ]),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(
                    color: const Color(0xFFB9C8DB), fontSize: 11, height: 1.5)),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                  color: const Color(0xFF172B43),
                  borderRadius: BorderRadius.circular(9)),
              child: const Row(children: [
                Icon(Icons.verified_user_outlined,
                    size: 13, color: Color(0xFFBFD2EF)),
                SizedBox(width: 5),
                Expanded(
                  child: Text('حالة الاعتماد الأمني: مفعّلة',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 9, color: Colors.white)),
                ),
                Text('تحديث: منذ دقيقة',
                    style: TextStyle(fontSize: 8, color: Color(0xFFB9C8DB))),
              ]),
            ),
          ],
        ),
      );
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color? iconBackground;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.subtitle,
    this.iconBackground,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 145,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9EDF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackground ?? const Color(0xFFEFF1F3),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: AppColors.primaryDark, size: 18),
                ),
                const Spacer(),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              fontSize: 8, color: AppColors.textSecondary)),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 23,
                            height: 1.1,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 3),
          Text(subtitle,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textSecondary)),
        ],
      );
}

class _SnapshotStrip extends StatelessWidget {
  final int todayActions;
  final int pendingRequests;

  const _SnapshotStrip({
    required this.todayActions,
    required this.pendingRequests,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const _SnapshotTile(value: '4', label: 'الأقسام الأساسية', icon: Icons.dashboard_outlined),
          _SnapshotTile(value: '$todayActions', label: 'إجراءات اليوم', icon: Icons.check_circle_outline),
          _SnapshotTile(value: '$pendingRequests', label: 'طلبات معلقة', icon: Icons.hourglass_bottom),
        ]),
      );
}

class _SnapshotTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _SnapshotTile({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 12, color: const Color(0xFF315F9A)),
              const SizedBox(width: 3),
              Flexible(child: Text(
                  headSupervisorText(context,
                      arabic: label,
                      english: switch (label) {
                        'الأقسام الأساسية' => 'Core departments',
                        'إجراءات اليوم' => 'Actions today',
                        _ => 'Pending requests',
                      }),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 8, color: Color(0xFF315F9A)))),
            ]),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          ]),
        ),
      );
}

class _WorkflowChart extends StatelessWidget {
  final List<DateTime> days;
  final Map<String, List<int>> trends;

  const _WorkflowChart({required this.days, required this.trends});

  static const _colors = <String, Color>{
    'التجار': AppColors.primaryDark,
    'وصلني': Color(0xFF4B6FA5),
    'المنتجات': Color(0xFF3C765F),
    'الخدمات': Color(0xFFB27A35),
  };

  @override
  Widget build(BuildContext context) {
    final hasActivity = trends.values.expand((values) => values).any((v) => v > 0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(headSupervisorText(context,
              arabic: 'مجرى سير العمل حسب القسم',
              english: 'Workflow by department'),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 3),
          Text(headSupervisorText(context,
              arabic: 'عدد الطلبات المسجلة يومياً • آخر 7 أيام',
              english: 'Daily recorded requests • Last 7 days'),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 8, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
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
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.textSecondary)),
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
                    Text('${day.day}',
                        style: const TextStyle(
                            fontSize: 8, color: AppColors.textMuted)),
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
                style: const TextStyle(
                    fontSize: 8, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}

class _WorkflowChartPainter extends CustomPainter {
  final Map<String, List<int>> trends;

  const _WorkflowChartPainter({required this.trends});

  static const _colors = _WorkflowChart._colors;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 31.0;
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
      ..color = const Color(0xFFE9EDF2)
      ..strokeWidth = 1;

    for (var line = 0; line <= 3; line++) {
      final y = top + height * line / 3;
      canvas.drawLine(Offset(left, y), Offset(left + width, y), gridPaint);
      final value = (maxY * (3 - line) / 3).round();
      final text = TextPainter(
        text: TextSpan(
          text: '$value',
          style: const TextStyle(fontSize: 8, color: AppColors.textMuted),
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
  final List<WasalnyLocalEvent> events;
  final VoidCallback onOpen;

  const _PendingWorkPanel({required this.events, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.arrow_back_ios_new, size: 11),
              label: Text(headSupervisorText(context,
                  arabic: 'عرض الطلبات', english: 'View requests')),
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF5278B5),
                  textStyle: const TextStyle(fontSize: 8)),
            ),
            const Spacer(),
            Text(headSupervisorText(context,
                arabic: 'مهام تحتاج تدخلك', english: 'Needs your attention'),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark)),
            const SizedBox(width: 5),
            const Icon(Icons.notification_important_outlined,
                size: 15, color: Color(0xFFB27A35)),
          ]),
          const SizedBox(height: 4),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(headSupervisorText(context,
                  arabic: 'لا توجد طلبات معلقة تحتاج إلى مراجعتك.',
                  english: 'There are no pending requests that need your review.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textSecondary)),
            )
          else
            for (final event in events)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Material(
                  color: const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    onTap: onOpen,
                    borderRadius: BorderRadius.circular(11),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                      child: Row(children: [
                        const Icon(Icons.chevron_left,
                            size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(isArabic ? event.titleAr : event.titleEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 3),
                              Text(
                                '${_departmentName(context, event.source)} • ${event.createdAt.toLocal().toString().substring(0, 16)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 7,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                              color: Color(0xFFB27A35),
                              shape: BoxShape.circle),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
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
    final visibleSupervisors = supervisors.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(children: [
        Row(children: [
          TextButton(onPressed: onShowAll, child: const Text('عرض الكل', style: TextStyle(fontSize: 9, color: Color(0xFF5278B5)))),
          const Spacer(),
          const Text('المشرفون المسؤولون في الوردية الحالية', textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        ]),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(children: [
            for (final supervisor in visibleSupervisors)
              Container(
                width: 155,
                margin: const EdgeInsets.only(left: 7),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(11)),
                child: Row(children: [
                  CircleAvatar(radius: 15, backgroundColor: supervisor.color, child: Text(supervisor.avatar, style: const TextStyle(fontSize: 9, color: Colors.white))),
                  const SizedBox(width: 6),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(supervisor.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    Text(supervisor.department.replaceFirst('قسم ', 'مشرف '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7, color: AppColors.textSecondary)),
                  ])),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  final VoidCallback onRequests;
  final VoidCallback onSupervisors;
  final VoidCallback onComplaints;

  const _QuickLinks({
    required this.onRequests,
    required this.onSupervisors,
    required this.onComplaints,
  });

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _QuickLink(
              label: headSupervisorText(context, arabic: 'الطلبات', english: 'Requests'),
              icon: Icons.assignment_outlined,
              onTap: onRequests),
          _QuickLink(
              label: headSupervisorText(context, arabic: 'المشرفون', english: 'Supervisors'),
              icon: Icons.people_outline,
              onTap: onSupervisors),
          _QuickLink(
              label: headSupervisorText(context, arabic: 'الشكاوى', english: 'Complaints'),
              icon: Icons.shield_outlined,
              onTap: onComplaints),
        ],
      );
}

class _QuickLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickLink(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: Color(0xFFDCE3EC)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

class _FinanceNoticeCard extends StatelessWidget {
  const _FinanceNoticeCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFEFF1F3),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.lock_outline,
                  size: 14, color: Color(0xFF656A72)),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E4E6),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('غير متاح لرئيس المشرفين',
                    style: TextStyle(fontSize: 8, color: Color(0xFF555B63))),
              ),
              const Spacer(),
              const Text('القسم المالي والتحصيل',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF454A52))),
            ]),
            const SizedBox(height: 5),
            const Text('صلاحيات حصرية للإدارة المالية',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF656A72))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8EAEC),
                  borderRadius: BorderRadius.circular(10)),
              child: const Text(
                'الاطلاع على الأرصدة البنكية، طلبات سحب الأرباح، وحسابات التسوية المالية يقع خارج نطاق الإشراف التشغيلي، ويقتصر حصرياً على مجلس الإدارة المالية العليا ومكتب المدير العام لضمان بروتوكولات الحوكمة المعتمدة.',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 9, height: 1.6, color: Color(0xFF656A72)),
              ),
            ),
            const SizedBox(height: 10),
            const Row(children: [
              Text('البروتوكول رقم 402',
                  style: TextStyle(fontSize: 8, color: Color(0xFF555B63))),
              Spacer(),
              Text('نظام التشفير وحجب الصلاحيات: نشط ومقيد',
                  style: TextStyle(fontSize: 8, color: Color(0xFF555B63))),
              SizedBox(width: 4),
              Icon(Icons.shield_outlined, size: 12, color: Color(0xFF555B63)),
            ]),
          ],
        ),
      );
}
