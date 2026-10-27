import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/data/services/head_access_policy.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/admin/domain/entities/head_account.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_audit_store.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_audit_record.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_intervention_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_request_review_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_request_decision_sheet.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class HeadSupervisorRequestsScreen extends StatefulWidget {
  const HeadSupervisorRequestsScreen({super.key});

  @override
  State<HeadSupervisorRequestsScreen> createState() =>
      _HeadSupervisorRequestsScreenState();
}

class _HeadSupervisorRequestsScreenState
    extends State<HeadSupervisorRequestsScreen> {
  final _store = LocalEventStore();
  final _search = TextEditingController();
  List<LocalEvent> _events = const [];
  bool _loading = true;
  Object? _error;
  String _query = '';
  String _filter = 'الكل';

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_load);
    _search.addListener(() => setState(() => _query = _search.text.trim()));
    _load();
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_load);
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      var events = await _store.getEvents('head');
      final legacyDemoEvents = events.where(
        (event) => event.id.startsWith('demo-') && !event.isRead,
      );
      for (final event in legacyDemoEvents) {
        await _store.markRead('head', event.id);
      }
      if (legacyDemoEvents.isNotEmpty) {
        events = await _store.getEvents('head');
      }
      if (!mounted) return;
      setState(() {
        _events = events.where(_isReviewRequest).toList();
        _loading = false;
        _error = null;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor requests',
      ));
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  bool _isReviewRequest(LocalEvent event) =>
      !event.id.startsWith('demo-') &&
      const {'merchant', 'products', 'wasalny', 'services'}
          .contains(event.source);

  List<LocalEvent> get _pending {
    return _events.where((event) {
      if (event.isRead) return false;
      final text = '${event.id} ${event.titleAr} ${event.titleEn} ${event.messageAr} ${event.messageEn}'.toLowerCase();
      final matchesQuery = _query.isEmpty || text.contains(_query.toLowerCase());
      final matchesFilter = switch (_filter) {
        'مرفوض' => event.titleAr.contains('رفض'),
        'مجمّد' => event.titleAr.contains('تجميد'),
        'التجار' => event.source == 'merchant',
        'وصلني' => event.source == 'wasalny',
        'الخدمات' => event.source == 'services',
        'المنتجات' => event.source == 'products',
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  Map<String, int> get _counts {
    final pending = _events.where((event) => !event.isRead).toList();
    return {
      'الكل': pending.length,
      'مرفوض': pending.where((event) => event.titleAr.contains('رفض')).length,
      'مجمّد': pending.where((event) => event.titleAr.contains('تجميد')).length,
      'التجار': pending.where((event) => event.source == 'merchant').length,
      'وصلني': pending.where((event) => event.source == 'wasalny').length,
      'الخدمات': pending.where((event) => event.source == 'services').length,
      'المنتجات': pending.where((event) => event.source == 'products').length,
    };
  }

  Future<void> _decide(
    LocalEvent event, {
    bool intervention = false,
  }) async {
    final policy = await HeadAccessPolicy.load();
    if (!mounted) return;
    if (intervention &&
        !await ensureHeadPermission(context, HeadPermission.settleDisputes)) {
      return;
    }
    if (!mounted) return;
    final request = _Request.fromEvent(event, context);
    final decision = await Navigator.of(context).push<HeadSupervisorDecisionDraft>(
      MaterialPageRoute(
        builder: (_) => intervention
            ? HeadSupervisorInterventionScreen(
                eventId: event.id,
                requestId: request.id,
                title: request.title,
                department: request.department,
                supervisor: request.supervisor,
                reason: request.reason,
                supervisorDecision: request.supervisorDecision,
                recipient: event.source,
                createdAt: event.createdAt,
                allowRefunds: policy.allows(HeadPermission.approveRefunds),
              )
            : HeadSupervisorRequestReviewScreen(
                requestId: request.id,
                title: request.title,
                department: request.department,
                supervisor: request.supervisor,
                reason: request.reason,
                supervisorDecision: request.supervisorDecision,
                createdAt: event.createdAt,
              ),
      ),
    );
    if (!mounted || decision == null) return;

    try {
      final source = _sourceLabel(event.source, context);
      final id = 'head-decision-${event.id}-${DateTime.now().millisecondsSinceEpoch}';
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      final actionLabel = isArabic
          ? decision.action.labelAr
          : decision.action.labelEn;
      final actionTitle = headSupervisorText(context,
          arabic: 'توجيه رئيس المشرفين: $actionLabel',
          english: 'Head supervisor decision: $actionLabel');
      final actionDetailsAr =
          'تم اتخاذ قرار ${decision.action.labelAr} بشأن الطلب ${request.id} المحال من ${_sourceLabel(event.source, context)}. ${decision.note}';
      final actionDetailsEn =
          'Decision: ${decision.action.labelEn} for request ${request.id}, referred by ${_sourceLabelEnglish(event.source)}. ${decision.note}';
      final actionDetails = isArabic ? actionDetailsAr : actionDetailsEn;
      await HeadSupervisorAuditStore().record(
        HeadSupervisorAuditRecord(
          id: id,
          subjectId: request.id,
          kind: 'request',
          title: actionTitle,
          details: actionDetails,
          department: request.department,
          occurredAt: DateTime.now(),
        ),
      );
      await _store.publish(LocalEvent(
        id: id,
        recipient: event.source,
        source: 'head',
        titleAr: actionTitle,
        titleEn: 'Head supervisor decision: ${decision.action.labelEn}',
        messageAr: actionDetailsAr,
        messageEn: actionDetailsEn,
        createdAt: DateTime.now(),
      ));
      if (decision.action == HeadSupervisorDecisionAction.escalateToAdmin) {
        await AdminRequestStore().submit(AdminRequest(
          id: 'escalation-${event.id}',
          kind: AdminRequestKind.escalation,
          titleAr: request.title,
          titleEn: request.title,
          detailsAr: 'طلب ${request.id} من ${request.department} (المشرف: ${request.supervisor}). السبب: ${request.reason}. مبررات الرئيس: ${decision.note}',
          detailsEn: 'Request ${request.id} from ${request.department} (supervisor: ${request.supervisor}). Reason: ${request.reason}. Head note: ${decision.note}',
          fromAr: 'رئيس المشرفين',
          fromEn: 'Head of supervisors',
          origin: 'head',
          refId: request.id,
          createdAt: DateTime.now(),
          priority: AdminRequestPriority.critical,
          deadline: DateTime.now().add(const Duration(hours: 24)),
          sourceAccount: event.source,
        ));
      }
      if (decision.action.closesRequest) await _store.markRead('head', event.id);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(headSupervisorText(context, arabic: 'تم إرسال القرار وإشعار $source.', english: 'Decision sent and $source notified.'))));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace, library: 'Head supervisor decision'));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(headSupervisorText(context, arabic: 'تعذر إرسال القرار. حاول مرة أخرى.', english: 'Could not send the decision. Please try again.'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = _pending;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(headSupervisorText(context, arabic: 'تعذر تحميل الطلبات: $_error', english: 'Could not load requests: $_error')));
    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ScrollFx(child: _SearchBar(controller: _search)),
          const SizedBox(height: 10),
          ScrollFx(child: _FilterBar(selected: _filter, counts: _counts, onChanged: (value) => setState(() => _filter = value))),
          const SizedBox(height: 12),
          ScrollFx(child: _Summary(count: _events.where((event) => !event.isRead).length)),
          const SizedBox(height: 12),
          if (requests.isEmpty)
            const _EmptyQueue()
          else
            for (final event in requests) ...[
              _RequestCard(
                event: event,
                request: _Request.fromEvent(event, context),
                onDecide: () => _decide(event),
                onIntervene: () => _decide(event, intervention: true),
              ),
              const SizedBox(height: 12),
            ],
          ScrollFx(child: const _GovernanceFooter()),
        ],
      ),
    );
  }
}

String _sourceLabel(String source, BuildContext context) {
  final (arabic, english) = switch (source) {
    'merchant' => ('مشرف التجار', 'Merchants supervisor'),
    'wasalny' => ('مشرف وصلني', 'Wasalny supervisor'),
    'services' => ('مشرف الخدمات', 'Services supervisor'),
    'products' => ('مشرف المنتجات', 'Products supervisor'),
    _ => ('المشرف المحيل', 'Referring supervisor'),
  };
  return headSupervisorText(context, arabic: arabic, english: english);
}

String _sourceLabelEnglish(String source) => switch (source) {
      'merchant' => 'the merchants supervisor',
      'wasalny' => 'the Wasalny supervisor',
      'services' => 'the services supervisor',
      'products' => 'the products supervisor',
      _ => 'the referring supervisor',
    };

class _Request {
  final String source;
  final String id;
  final String title;
  final String reason;
  final String supervisor;
  final String supervisorCode;
  final String department;
  final IconData icon;
  final Color color;
  final String supervisorDecision;
  final bool urgent;

  const _Request({required this.source, required this.id, required this.title, required this.reason, required this.supervisor, required this.supervisorCode, required this.department, required this.icon, required this.color, required this.supervisorDecision, required this.urgent});

  factory _Request.fromEvent(LocalEvent event, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final raw = isArabic ? event.messageAr : event.messageEn;
    final idAndTitle = raw.split(' — ').first.trim();
    final fullReason = raw.contains(' — ')
        ? raw.split(' — ').skip(1).join(' — ').trim()
        : '';
    final reasonMarker = isArabic ? 'السبب:' : 'Reason:';
    final reason = fullReason.contains(reasonMarker)
        ? fullReason.split(reasonMarker).skip(1).join(reasonMarker).trim()
        : fullReason;
    String id;
    String title;
    if (idAndTitle.contains(': ')) {
      final parts = idAndTitle.split(': ');
      id = parts.first.trim();
      title = parts.skip(1).join(': ').trim();
    } else if (idAndTitle.contains(' · ')) {
      final parts = idAndTitle.split(' · ');
      id = parts.first.trim();
      title = parts.skip(1).join(' · ').trim();
    } else {
      id = event.id;
      title = idAndTitle.isEmpty
          ? (isArabic ? event.titleAr : event.titleEn)
          : idAndTitle;
    }
    final (departmentAr, departmentEn, icon, color) = switch (event.source) {
      'services' => ('قسم الخدمات الميدانية', 'Field Services', Icons.build_outlined, AppColors.infoDark),
      'products' => ('قسم المنتجات والمستعمل', 'Products and Used Goods', Icons.local_shipping_outlined, AppColors.dangerDark),
      'wasalny' => ('قسم وصلني', 'Wasalny', Icons.directions_car_outlined, AppColors.infoDark),
      'merchant' => ('قسم التجار', 'Merchants', Icons.storefront_outlined, AppColors.infoDark),
      _ => ('القسم المحيل', 'Referring department', Icons.assignment_outlined, AppColors.infoDark),
    };
    final isFrozen = event.titleAr.contains('تجميد') ||
        event.titleEn.toLowerCase().contains('frozen');
    final isRejected = event.titleAr.contains('رفض') ||
        event.titleEn.toLowerCase().contains('rejected');
    final supervisorDecision = isFrozen
        ? headSupervisorText(context, arabic: 'مجمّد', english: 'Frozen')
        : isRejected
            ? headSupervisorText(context, arabic: 'مرفوض', english: 'Rejected')
            : headSupervisorText(context, arabic: 'مصعّد للمراجعة', english: 'Escalated for review');
    return _Request(source: event.source, id: id, title: title, reason: reason, supervisor: _sourceLabel(event.source, context), supervisorCode: headSupervisorText(context, arabic: 'حساب القسم', english: 'Department account'), department: headSupervisorText(context, arabic: departmentAr, english: departmentEn), icon: icon, color: color, supervisorDecision: supervisorDecision, urgent: isFrozen || isRejected);
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: headSupervisorText(context,
              arabic: 'بحث برقم الطلب، اسم المشرف، أو القسم',
              english: 'Search by request ID, supervisor, or department'),
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const MotionIcon(Icons.search, size: 20),
          filled: true,
          fillColor: AppColors.surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.cardBorder)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.cardBorder)),
        ),
      );
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final Map<String, int> counts;
  final ValueChanged<String> onChanged;
  const _FilterBar({required this.selected, required this.counts, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    const labels = <(String, String)>[
      ('الكل', 'All'),
      ('مرفوض', 'Rejected'),
      ('مجمّد', 'Frozen'),
      ('التجار', 'Merchants'),
      ('وصلني', 'Wasalny'),
      ('الخدمات', 'Services'),
      ('المنتجات', 'Products'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final (arabic, english) in labels)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: CountText(
                  '${headSupervisorText(context, arabic: arabic, english: english)}  ${counts[arabic] ?? 0}',
                  style: const TextStyle(fontSize: 12)),
              selected: selected == arabic,
              onSelected: (_) => onChanged(arabic),
              showCheckmark: false,
              selectedColor: AppColors.primaryDark,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected == arabic
                      ? Colors.white
                      : AppColors.textSecondary),
              side: BorderSide(
                  color: selected == arabic
                      ? Colors.transparent
                      : AppColors.cardBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
          ),
      ]),
    );
  }
}

class _Summary extends StatelessWidget {
  final int count;
  const _Summary({required this.count});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: count == 0 ? AppColors.successLight : AppColors.infoLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          MotionIcon(count == 0 ? Icons.task_alt_rounded : Icons.schedule,
              size: 20,
              color: count == 0 ? AppColors.successDark : AppColors.infoDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                count == 0
                    ? headSupervisorText(context,
                        arabic: 'لا إحالات بانتظار مراجعتك',
                        english: 'No referrals awaiting your review')
                    : headSupervisorText(context,
                        arabic: '$count إحالات تنتظر مراجعتك',
                        english: '$count referrals awaiting your review'),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: count == 0
                        ? AppColors.successDark
                        : AppColors.infoDark)),
          ),
        ]),
      );
}

class _RequestCard extends StatelessWidget {
  final LocalEvent event;
  final _Request request;
  final VoidCallback onDecide;
  final VoidCallback onIntervene;
  const _RequestCard({required this.event, required this.request, required this.onDecide, required this.onIntervene});

  Color get _tint => switch (request.source) {
        'merchant' => AppColors.info,
        'wasalny' => AppColors.success,
        'products' => AppColors.purple,
        'services' => AppColors.warning,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final tint = _tint;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(11)),
            child: MotionIcon(request.icon, size: 18, color: tint),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.department,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: tint)),
                Text(request.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          _RequestBadge(
              label: request.supervisorDecision, urgent: request.urgent),
        ]),
        const SizedBox(height: 12),
        Text(request.title,
            style: TextStyle(
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: AppColors.ink)),
        if (request.reason.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(request.reason,
              style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.infoDark,
                child: Text(request.supervisor.substring(0, 1),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white))),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                  request.supervisor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
            ),
            MotionIcon(Icons.access_time,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(_elapsed(event.createdAt, context),
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDecide,
              icon: const MotionIcon(Icons.rule_outlined, size: 17),
              label: Text(
                  headSupervisorText(context,
                      arabic: 'إعادة مراجعة القرار',
                      english: 'Review decision'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: BorderSide(color: AppColors.cardBorder),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: onIntervene,
              icon: const MotionIcon(Icons.tune, size: 17),
              label: Text(
                  headSupervisorText(context,
                      arabic: 'التدخل الرقابي',
                      english: 'Oversight intervention'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800)),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ]),
      ]),
    );
  }
}

String _elapsed(DateTime date, BuildContext context) {
  final minutes = DateTime.now().difference(date).inMinutes;
  if (minutes < 1) {
    return headSupervisorText(context, arabic: 'الآن', english: 'Just now');
  }
  if (minutes < 60) {
    return headSupervisorText(
        context, arabic: 'منذ $minutes دقيقة', english: '$minutes min ago');
  }
  final hours = minutes ~/ 60;
  if (hours < 24) {
    return headSupervisorText(
        context, arabic: 'منذ $hours ساعة', english: '$hours hr ago');
  }
  final days = hours ~/ 24;
  return headSupervisorText(
      context, arabic: 'منذ $days يوم', english: '$days day(s) ago');
}

class _RequestBadge extends StatelessWidget {
  final String label;
  final bool urgent;
  const _RequestBadge({required this.label, required this.urgent});
  @override
  Widget build(BuildContext context) {
    final color = urgent ? AppColors.dangerDark : AppColors.infoDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: urgent ? AppColors.dangerLight : AppColors.infoLight,
          borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        MotionIcon(urgent ? Icons.warning_amber_rounded : Icons.circle,
            size: urgent ? 13 : 7, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _GovernanceFooter extends StatelessWidget {
  const _GovernanceFooter();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: AppColors.blueFill,
            border: AppColors.blueEdge,
            boxShadow: AppColors.blueGlow,
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(20)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MotionIcon(Icons.admin_panel_settings_outlined,
              size: 24, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    headSupervisorText(context,
                        arabic: 'صلاحيات الإشراف الإداري والرقابي',
                        english: 'Administrative and oversight authority'),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 5),
                Text(
                    headSupervisorText(context,
                        arabic:
                            'تمنح منصة رئيس المشرفين حق مراجعة القرارات التشغيلية. وتظل القرارات المالية والحسابات مقيدة بموافقة الإدارة المالية وفق المعايير.',
                        english:
                            'The Head Supervisor can review operational decisions. Financial decisions and accounts remain subject to finance approval.'),
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.55,
                        color: Colors.white.withValues(alpha: 0.82))),
              ],
            ),
          ),
        ]),
      );
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 54),
        child: Column(children: [
          MotionIcon(Icons.inbox_outlined, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
              headSupervisorText(context,
                  arabic: 'لا توجد طلبات جديدة بانتظار القرار',
                  english: 'No new requests are awaiting a decision'),
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ]),
      );
}
