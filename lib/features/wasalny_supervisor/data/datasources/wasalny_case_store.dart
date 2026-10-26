import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_request_decision_sheet.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';

class WasalnyCaseNote {
  final DateTime at;
  final String text;
  const WasalnyCaseNote(this.at, this.text);

  Map<String, Object?> toJson() => {'at': at.toIso8601String(), 'text': text};
  factory WasalnyCaseNote.fromJson(Map<String, dynamic> j) =>
      WasalnyCaseNote(DateTime.parse(j['at'] as String), j['text'] as String);
}

/// Persistent follow-up data for a Wasalny complaint (the complaint list
/// itself is still served by the data source).
class WasalnyCaseRecord {
  static const supervisorSla = Duration(hours: 24);
  static const headSla = Duration(hours: 48);

  final String id;
  final DateTime firstSeen;
  final WasalnyComplaintStatus? status;
  final DateTime? escalatedAt;
  final int escalations;
  final String? reason;
  final String? lastDecisionEventId;
  final List<WasalnyCaseNote> timeline;

  const WasalnyCaseRecord({
    required this.id,
    required this.firstSeen,
    this.status,
    this.escalatedAt,
    this.escalations = 0,
    this.reason,
    this.lastDecisionEventId,
    this.timeline = const [],
  });

  WasalnyCaseRecord copyWith({
    WasalnyComplaintStatus? status,
    DateTime? escalatedAt,
    int? escalations,
    String? reason,
    String? lastDecisionEventId,
    List<WasalnyCaseNote>? timeline,
  }) =>
      WasalnyCaseRecord(
        id: id,
        firstSeen: firstSeen,
        status: status ?? this.status,
        escalatedAt: escalatedAt ?? this.escalatedAt,
        escalations: escalations ?? this.escalations,
        reason: reason ?? this.reason,
        lastDecisionEventId: lastDecisionEventId ?? this.lastDecisionEventId,
        timeline: timeline ?? this.timeline,
      );

  /// Overdue rule: waiting on the supervisor > 24h, or on the head > 48h.
  static bool isOverdue(
    WasalnyComplaintStatus status,
    WasalnyCaseRecord? record,
    DateTime now,
  ) {
    if (record == null) return false;
    return switch (status) {
      WasalnyComplaintStatus.underReview ||
      WasalnyComplaintStatus.returnedByHead =>
        now.difference(record.firstSeen) > supervisorSla,
      WasalnyComplaintStatus.escalatedToChief =>
        now.difference(record.escalatedAt ?? record.firstSeen) > headSla,
      _ => false,
    };
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'firstSeen': firstSeen.toIso8601String(),
        'status': status?.name,
        'escalatedAt': escalatedAt?.toIso8601String(),
        'escalations': escalations,
        'reason': reason,
        'lastDecisionEventId': lastDecisionEventId,
        'timeline': timeline.map((n) => n.toJson()).toList(),
      };

  factory WasalnyCaseRecord.fromJson(Map<String, dynamic> j) =>
      WasalnyCaseRecord(
        id: j['id'] as String,
        firstSeen: DateTime.parse(j['firstSeen'] as String),
        status: j['status'] == null
            ? null
            : WasalnyComplaintStatus.values.byName(j['status'] as String),
        escalatedAt: j['escalatedAt'] == null
            ? null
            : DateTime.parse(j['escalatedAt'] as String),
        escalations: (j['escalations'] as int?) ?? 0,
        reason: j['reason'] as String?,
        lastDecisionEventId: j['lastDecisionEventId'] as String?,
        timeline: [
          for (final n in (j['timeline'] as List<dynamic>? ?? const []))
            WasalnyCaseNote.fromJson(n as Map<String, dynamic>),
        ],
      );
}

class WasalnyCaseStore {
  static const _key = 'wasalny_cases_v1';
  static const eventPrefix = 'head-';
  static const decisionPrefix = 'head-decision-head-';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  final LocalEventStore _events;
  WasalnyCaseStore({LocalEventStore? events})
      : _events = events ?? LocalEventStore();

  Future<Map<String, WasalnyCaseRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid Wasalny case list.');
    }
    return {
      for (final v in decoded)
        (v as Map<String, dynamic>)['id'] as String:
            WasalnyCaseRecord.fromJson(v),
    };
  }

  Future<void> _save(Map<String, WasalnyCaseRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _key,
      jsonEncode(records.values.map((r) => r.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save Wasalny cases.');
    revision.value++;
  }

  /// Registers complaints seen for the first time, applies head decisions and
  /// returns the up-to-date records.
  Future<Map<String, WasalnyCaseRecord>> refresh(
    Iterable<WasalnyComplaint> complaints,
  ) async {
    final records = await load();
    var changed = false;
    final now = DateTime.now();
    for (final c in complaints) {
      if (!records.containsKey(c.id)) {
        records[c.id] = WasalnyCaseRecord(
          id: c.id,
          firstSeen: now,
          timeline: [WasalnyCaseNote(now, 'وصلت الشكوى للمشرف')],
        );
        changed = true;
      }
    }
    if (await _applyDecisions(records)) changed = true;
    if (changed) await _save(records);
    return records;
  }

  Future<bool> _applyDecisions(Map<String, WasalnyCaseRecord> records) async {
    final waiting = records.values.where((r) =>
        r.status == WasalnyComplaintStatus.escalatedToChief);
    if (waiting.isEmpty) return false;
    final events = await _events.getEvents('wasalny');
    var changed = false;
    for (final record in waiting.toList()) {
      final prefix = '$decisionPrefix${record.id}-';
      final match = events.where((e) => e.id.startsWith(prefix)).firstOrNull;
      if (match == null || match.id == record.lastDecisionEventId) continue;
      final action = HeadSupervisorDecisionAction.values
          .where((a) => match.titleAr.contains(a.labelAr))
          .firstOrNull;
      final status = switch (action) {
        HeadSupervisorDecisionAction.escalateToAdmin =>
          WasalnyComplaintStatus.escalatedToAdmin,
        HeadSupervisorDecisionAction.returnForReview ||
        HeadSupervisorDecisionAction.requestExplanation =>
          WasalnyComplaintStatus.returnedByHead,
        _ => WasalnyComplaintStatus.resolved,
      };
      records[record.id] = record.copyWith(
        status: status,
        lastDecisionEventId: match.id,
        timeline: [
          ...record.timeline,
          WasalnyCaseNote(
            match.createdAt,
            match.messageAr.isEmpty ? match.titleAr : match.messageAr,
          ),
        ],
      );
      changed = true;
    }
    return changed;
  }

  Future<void> recordEscalation(String id, String reason) async {
    final records = await load();
    final now = DateTime.now();
    final r = records[id] ?? WasalnyCaseRecord(id: id, firstSeen: now);
    records[id] = r.copyWith(
      status: WasalnyComplaintStatus.escalatedToChief,
      escalatedAt: now,
      escalations: r.escalations + 1,
      reason: reason,
      timeline: [
        ...r.timeline,
        WasalnyCaseNote(now, 'تم التصعيد لرئيس المشرفين — $reason'),
      ],
    );
    await _save(records);
  }

  Future<void> recordResolved(String id, String note) async {
    final records = await load();
    final now = DateTime.now();
    final r = records[id] ?? WasalnyCaseRecord(id: id, firstSeen: now);
    records[id] = r.copyWith(
      status: WasalnyComplaintStatus.resolved,
      timeline: [...r.timeline, WasalnyCaseNote(now, 'تم الحل وديًا — $note')],
    );
    await _save(records);
  }

  Future<int> escalationCount(String id) async =>
      (await load())[id]?.escalations ?? 0;

  static List<WasalnyComplaint> apply(
    List<WasalnyComplaint> complaints,
    Map<String, WasalnyCaseRecord> records,
  ) =>
      [
        for (final c in complaints)
          records[c.id]?.status == null
              ? c
              : c.copyWith(status: records[c.id]!.status),
      ];
}
