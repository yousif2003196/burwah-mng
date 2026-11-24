import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/supervisor_escalations_api.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_request_decision_sheet.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_activity_log.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

enum ServicesEscalationKind {
  complaint('شكوى خدمة'),
  request('طلب خدمة مشبوه'),
  provider('مقدم خدمة مخالف / طلب إيقاف');

  final String labelAr;
  const ServicesEscalationKind(this.labelAr);
}

enum ServicesEscalationStatus {
  pendingHead('بانتظار قرار رئيس المشرفين'),
  returned('أعادها الرئيس للمراجعة'),
  escalatedToAdmin('رفعها الرئيس للأدمن'),
  decided('حسمها الرئيس');

  final String labelAr;
  const ServicesEscalationStatus(this.labelAr);
}

class ServicesEscalationNote {
  final DateTime at;
  final String text;
  const ServicesEscalationNote(this.at, this.text);

  Map<String, Object?> toJson() => {'at': at.toIso8601String(), 'text': text};
  factory ServicesEscalationNote.fromJson(Map<String, dynamic> j) =>
      ServicesEscalationNote(
          DateTime.parse(j['at'] as String), j['text'] as String);
}

/// A complaint / product review sent to the head of supervisors.
/// It never goes straight to the admin.
class ServicesEscalation {
  static const headSla = Duration(hours: 48);

  final ServicesEscalationKind kind;
  final String refId;
  final String title;
  final ServicesEscalationStatus status;
  final String reason;
  final DateTime escalatedAt;
  final int rounds;
  final String? lastDecisionEventId;
  final List<ServicesEscalationNote> timeline;

  const ServicesEscalation({
    required this.kind,
    required this.refId,
    required this.title,
    required this.status,
    required this.reason,
    required this.escalatedAt,
    this.rounds = 1,
    this.lastDecisionEventId,
    this.timeline = const [],
  });

  String get key => keyOf(kind, refId);
  static String keyOf(ServicesEscalationKind kind, String refId) =>
      '${kind.name}:$refId';

  bool get canEscalateAgain => status == ServicesEscalationStatus.returned;

  bool isOverdue(DateTime now) =>
      status == ServicesEscalationStatus.pendingHead &&
      now.difference(escalatedAt) > headSla;

  ServicesEscalation copyWith({
    ServicesEscalationStatus? status,
    String? reason,
    DateTime? escalatedAt,
    int? rounds,
    String? lastDecisionEventId,
    List<ServicesEscalationNote>? timeline,
  }) =>
      ServicesEscalation(
        kind: kind,
        refId: refId,
        title: title,
        status: status ?? this.status,
        reason: reason ?? this.reason,
        escalatedAt: escalatedAt ?? this.escalatedAt,
        rounds: rounds ?? this.rounds,
        lastDecisionEventId: lastDecisionEventId ?? this.lastDecisionEventId,
        timeline: timeline ?? this.timeline,
      );

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'refId': refId,
        'title': title,
        'status': status.name,
        'reason': reason,
        'escalatedAt': escalatedAt.toIso8601String(),
        'rounds': rounds,
        'lastDecisionEventId': lastDecisionEventId,
        'timeline': timeline.map((n) => n.toJson()).toList(),
      };

  factory ServicesEscalation.fromJson(Map<String, dynamic> j) =>
      ServicesEscalation(
        kind: ServicesEscalationKind.values.byName(j['kind'] as String),
        refId: j['refId'] as String,
        title: j['title'] as String,
        status: ServicesEscalationStatus.values.byName(j['status'] as String),
        reason: j['reason'] as String,
        escalatedAt: DateTime.parse(j['escalatedAt'] as String),
        rounds: (j['rounds'] as int?) ?? 1,
        lastDecisionEventId: j['lastDecisionEventId'] as String?,
        timeline: [
          for (final n in (j['timeline'] as List<dynamic>? ?? const []))
            ServicesEscalationNote.fromJson(n as Map<String, dynamic>),
        ],
      );
}

class ServicesEscalationStore {
  static const _key = 'services_escalations_v1';
  static const eventPrefix = 'head-services-esc-';
  static const decisionPrefix = 'head-decision-$eventPrefix';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  final LocalEventStore _events;
  ServicesEscalationStore({LocalEventStore? events})
      : _events = events ?? LocalEventStore();

  Future<Map<String, ServicesEscalation>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid services escalations.');
    }
    final list = [
      for (final v in decoded)
        ServicesEscalation.fromJson(v as Map<String, dynamic>),
    ];
    return {for (final e in list) e.key: e};
  }

  Future<void> _save(Map<String, ServicesEscalation> all) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _key,
      jsonEncode(all.values.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save services escalations.');
    revision.value++;
  }

  static const _firstSeenKey = 'services_complaints_first_seen_v1';

  /// Remembers when each id was first shown, to compute response deadlines.
  Future<Map<String, DateTime>> firstSeen(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_firstSeenKey);
    final map = <String, DateTime>{
      if (encoded != null)
        for (final e in (jsonDecode(encoded) as Map<String, dynamic>).entries)
          e.key: DateTime.parse(e.value as String),
    };
    var changed = false;
    final now = DateTime.now();
    for (final id in ids) {
      if (map.putIfAbsent(id, () => now) == now) changed = true;
    }
    if (changed) {
      await prefs.setString(
        _firstSeenKey,
        jsonEncode({for (final e in map.entries) e.key: e.value.toIso8601String()}),
      );
    }
    return map;
  }

  /// Sends [refId] to the head. A written reason is mandatory.
  Future<void> escalate({
    required ServicesEscalationKind kind,
    required String refId,
    required String title,
    required String subject,
    required String reason,
  }) async {
    final clean = reason.replaceAll(' — ', ' - ').replaceAll('\n', ' ').trim();
    if (clean.length < 5) throw ArgumentError('A written reason is required.');
    if (AuthSession.isSignedIn) {
      await _escalateRemote(kind, refId, clean);
      revision.value++;
      return;
    }
    final all = await load();
    final key = ServicesEscalation.keyOf(kind, refId);
    final existing = all[key];
    if (existing != null && !existing.canEscalateAgain) {
      throw StateError('This item already has an open escalation.');
    }
    final rounds = (existing?.rounds ?? 0) + 1;
    final now = DateTime.now();
    final base = '$eventPrefix${kind.name}-$refId';
    await _events.publish(LocalEvent(
      id: rounds == 1 ? base : '$base-r$rounds',
      recipient: 'head',
      source: 'services',
      titleAr: 'تصعيد من مشرف الخدمات: ${kind.labelAr}',
      titleEn: 'Services supervisor escalation',
      messageAr:
          '$refId: ${title.replaceAll(' — ', ' - ')} — $subject. السبب: $clean',
      messageEn:
          '$refId: ${title.replaceAll(' — ', ' - ')} — $subject. Reason: $clean',
      createdAt: now,
    ));
    all[key] = ServicesEscalation(
      kind: kind,
      refId: refId,
      title: title,
      status: ServicesEscalationStatus.pendingHead,
      reason: clean,
      escalatedAt: now,
      rounds: rounds,
      lastDecisionEventId: existing?.lastDecisionEventId,
      timeline: [
        ...?existing?.timeline,
        ServicesEscalationNote(now, 'تم الرفع لرئيس المشرفين — $clean'),
      ],
    );
    await _save(all);
  }

  static int _numberOf(String text) =>
      int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  /// Complaints and providers go to the head through the server. Requests are
  /// already escalated by the review screen (status "Escalated").
  Future<void> _escalateRemote(
    ServicesEscalationKind kind,
    String refId,
    String reason,
  ) async {
    final id = _numberOf(refId);
    if (id == 0) throw ArgumentError('Bad id: $refId');
    final api = sl<ApiConsumer>(instanceName: 'berwah');
    switch (kind) {
      case ServicesEscalationKind.complaint:
        await api.post<Object>(
          ApiEndpoints.serviceComplaintEscalate(id),
          data: {'supervisorNote': reason, 'sendNotification': true},
        );
      case ServicesEscalationKind.provider:
        await api.post<Object>(
          ApiEndpoints.serviceEscalateProvider(id),
          data: {'reason': reason, 'adminNotes': ''},
        );
      case ServicesEscalationKind.request:
        break;
    }
  }

  static const _requestDecisions = {
    'srv_approved': 'اعتمد الرئيس الطلب',
    'srv_updated_approved': 'عدّل الرئيس الطلب واعتمده',
    'srv_rejected': 'رفض الرئيس الطلب',
    'srv_suspended': 'علّق الرئيس الطلب',
  };
  static const _providerDecisions = {
    'srv_provider_suspended': 'تم إيقاف المزود',
    'srv_provider_reactivated': 'أُعيد تفعيل المزود',
    'srv_provider_escalation_closed': 'أغلق الرئيس التصعيد',
  };

  /// Built from the server audit trail: an escalation starts with the
  /// supervisor's line and ends with a later decision on the same subject.
  Future<Map<String, ServicesEscalation>> _remote() async {
    final entries = await ServicesActivityLog.fetchRemote(pageSize: 300);
    entries.sort((a, b) => a.at.compareTo(b.at));
    final all = <String, ServicesEscalation>{};
    ServicesEscalationKind? kindOf(String subject) {
      if (subject.startsWith('SRV-')) return ServicesEscalationKind.request;
      if (subject.startsWith('TCK-')) return ServicesEscalationKind.complaint;
      if (subject.startsWith('PRV-')) return ServicesEscalationKind.provider;
      return null;
    }

    for (final e in entries) {
      final kind = kindOf(e.subject);
      if (kind == null) continue;
      final refId = _numberOf(e.subject).toString();
      final key = ServicesEscalation.keyOf(kind, refId);
      final existing = all[key];
      final isStart = e.action == 'srv_escalated' ||
          e.action == 'srv_complaint_escalated' ||
          e.action == 'srv_provider_escalated';
      if (isStart) {
        all[key] = ServicesEscalation(
          kind: kind,
          refId: refId,
          title: e.subject,
          status: ServicesEscalationStatus.pendingHead,
          reason: e.details,
          escalatedAt: e.at,
          rounds: (existing?.rounds ?? 0) + 1,
          timeline: [
            ...?existing?.timeline,
            ServicesEscalationNote(
                e.at, 'تم الرفع لرئيس المشرفين — ${e.details}'),
          ],
        );
        continue;
      }
      if (existing == null ||
          existing.status != ServicesEscalationStatus.pendingHead) {
        continue;
      }
      String? text;
      var status = ServicesEscalationStatus.decided;
      if (kind == ServicesEscalationKind.request) {
        if (e.action == 'srv_returned') {
          status = ServicesEscalationStatus.returned;
          text = 'أعاد الرئيس الطلب للمراجعة';
        } else {
          text = _requestDecisions[e.action];
        }
      } else if (kind == ServicesEscalationKind.provider) {
        text = _providerDecisions[e.action];
      }
      if (text == null) continue;
      all[key] = existing.copyWith(
        status: status,
        timeline: [
          ...existing.timeline,
          ServicesEscalationNote(
            e.at,
            e.details.isEmpty ? text : '$text — ${e.details}',
          ),
        ],
      );
    }
    await _applyUnified(all);
    return all;
  }

  /// تصعيدات الشكاوى بتتحسم من لوحة التصعيدات الموحّدة عند رئيس المشرفين:
  /// حالتها وقراره وملاحظته بتيجي من هناك.
  Future<void> _applyUnified(Map<String, ServicesEscalation> all) async {
    if (!SupervisorEscalationsApi.supervisorCanUse) return;
    final List<SupervisorEscalationRecord> mine;
    try {
      mine = await sl<SupervisorEscalationsApi>().mine();
    } on Object catch (error) {
      debugPrint('Unified escalations unavailable: $error');
      return;
    }
    // الأقدم الأول علشان آخر تصعيد لكل شكوى يكسب.
    final sorted = [...mine]..sort((a, b) =>
        (a.createdAt ?? DateTime(2000)).compareTo(b.createdAt ?? DateTime(2000)));
    for (final r in sorted) {
      if (!r.refKey.startsWith('TCK-')) continue;
      final refId = _numberOf(r.refKey).toString();
      final key = ServicesEscalation.keyOf(ServicesEscalationKind.complaint, refId);
      final status = switch (r.status) {
        1 => ServicesEscalationStatus.decided,
        2 => ServicesEscalationStatus.returned,
        3 => ServicesEscalationStatus.escalatedToAdmin,
        _ => ServicesEscalationStatus.pendingHead,
      };
      final at = r.createdAt ?? DateTime.now();
      final existing = all[key];
      final timeline = <ServicesEscalationNote>[
        ...?existing?.timeline,
        if (existing == null) ServicesEscalationNote(at, 'تم الرفع لرئيس المشرفين — ${r.reason}'),
        if (status != ServicesEscalationStatus.pendingHead)
          ServicesEscalationNote(
            r.decidedAt ?? at,
            r.decisionNote.isEmpty ? status.labelAr : '${status.labelAr} — ${r.decisionNote}',
          ),
      ];
      all[key] = ServicesEscalation(
        kind: ServicesEscalationKind.complaint,
        refId: refId,
        title: r.title.isEmpty ? (existing?.title ?? r.refKey) : r.title,
        status: status,
        reason: r.reason,
        escalatedAt: at,
        rounds: existing?.rounds ?? 1,
        timeline: timeline,
      );
    }
  }

  /// Applies head decisions (server audit trail, or local events when offline).
  Future<Map<String, ServicesEscalation>> refresh() async {
    if (AuthSession.isSignedIn) {
      try {
        return await _remote();
      } on Object catch (error) {
        debugPrint('Services escalations unavailable: $error');
        return {};
      }
    }
    final all = await load();
    final waiting = all.values
        .where((e) => e.status == ServicesEscalationStatus.pendingHead)
        .toList();
    if (waiting.isEmpty) return all;
    final events = await _events.getEvents('services');
    var changed = false;
    for (final e in waiting) {
      final prefix = '$decisionPrefix${e.kind.name}-${e.refId}-';
      final match = events.where((v) => v.id.startsWith(prefix)).firstOrNull;
      if (match == null || match.id == e.lastDecisionEventId) continue;
      final action = HeadSupervisorDecisionAction.values
          .where((a) => match.titleAr.contains(a.labelAr))
          .firstOrNull;
      final status = switch (action) {
        HeadSupervisorDecisionAction.escalateToAdmin =>
          ServicesEscalationStatus.escalatedToAdmin,
        HeadSupervisorDecisionAction.returnForReview ||
        HeadSupervisorDecisionAction.requestExplanation =>
          ServicesEscalationStatus.returned,
        _ => ServicesEscalationStatus.decided,
      };
      all[e.key] = e.copyWith(
        status: status,
        lastDecisionEventId: match.id,
        timeline: [
          ...e.timeline,
          ServicesEscalationNote(
            match.createdAt,
            match.messageAr.isEmpty ? match.titleAr : match.messageAr,
          ),
        ],
      );
      changed = true;
    }
    if (changed) await _save(all);
    return all;
  }
}
