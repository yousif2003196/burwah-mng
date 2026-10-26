import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_request_decision_sheet.dart';
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

  /// Applies head decisions (events addressed to `products`).
  Future<Map<String, ServicesEscalation>> refresh() async {
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
