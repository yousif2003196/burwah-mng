import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_request_decision_sheet.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

enum WasalnyRequestFlagKind {
  suspicious('شبهة احتيال/مخالفة'),
  banSeller('طلب حظر البائع');

  final String labelAr;
  const WasalnyRequestFlagKind(this.labelAr);
}

enum WasalnyRequestFlagStatus {
  pendingHead('بانتظار قرار رئيس المشرفين'),
  returned('أعادها الرئيس للمراجعة'),
  escalatedToAdmin('رفعها الرئيس للأدمن'),
  decided('حسمها الرئيس');

  final String labelAr;
  const WasalnyRequestFlagStatus(this.labelAr);
}

class WasalnyRequestState {
  final String id;
  final DateTime? soldAt;
  final WasalnyRequestFlagKind? flagKind;
  final WasalnyRequestFlagStatus? flagStatus;
  final String? reason;
  final DateTime? escalatedAt;
  final int escalations;
  final String? lastDecisionEventId;

  const WasalnyRequestState({
    required this.id,
    this.soldAt,
    this.flagKind,
    this.flagStatus,
    this.reason,
    this.escalatedAt,
    this.escalations = 0,
    this.lastDecisionEventId,
  });

  bool get isSold => soldAt != null;
  bool get canFlag =>
      flagStatus == null || flagStatus == WasalnyRequestFlagStatus.returned;

  WasalnyRequestState copyWith({
    DateTime? soldAt,
    WasalnyRequestFlagKind? flagKind,
    WasalnyRequestFlagStatus? flagStatus,
    String? reason,
    DateTime? escalatedAt,
    int? escalations,
    String? lastDecisionEventId,
  }) =>
      WasalnyRequestState(
        id: id,
        soldAt: soldAt ?? this.soldAt,
        flagKind: flagKind ?? this.flagKind,
        flagStatus: flagStatus ?? this.flagStatus,
        reason: reason ?? this.reason,
        escalatedAt: escalatedAt ?? this.escalatedAt,
        escalations: escalations ?? this.escalations,
        lastDecisionEventId: lastDecisionEventId ?? this.lastDecisionEventId,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'soldAt': soldAt?.toIso8601String(),
        'flagKind': flagKind?.name,
        'flagStatus': flagStatus?.name,
        'reason': reason,
        'escalatedAt': escalatedAt?.toIso8601String(),
        'escalations': escalations,
        'lastDecisionEventId': lastDecisionEventId,
      };

  factory WasalnyRequestState.fromJson(Map<String, dynamic> j) =>
      WasalnyRequestState(
        id: j['id'] as String,
        soldAt:
            j['soldAt'] == null ? null : DateTime.parse(j['soldAt'] as String),
        flagKind: j['flagKind'] == null
            ? null
            : WasalnyRequestFlagKind.values.byName(j['flagKind'] as String),
        flagStatus: j['flagStatus'] == null
            ? null
            : WasalnyRequestFlagStatus.values.byName(j['flagStatus'] as String),
        reason: j['reason'] as String?,
        escalatedAt: j['escalatedAt'] == null
            ? null
            : DateTime.parse(j['escalatedAt'] as String),
        escalations: (j['escalations'] as int?) ?? 0,
        lastDecisionEventId: j['lastDecisionEventId'] as String?,
      );
}

/// Persists Wasalny request progress (sold) and flags raised to the head.
class WasalnyRequestStore {
  static const _key = 'wasalny_request_states_v1';
  static const eventPrefix = 'head-wasalny-request-';
  static const decisionPrefix = 'head-decision-$eventPrefix';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  final LocalEventStore _events;
  WasalnyRequestStore({LocalEventStore? events})
      : _events = events ?? LocalEventStore();

  Future<Map<String, WasalnyRequestState>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid Wasalny request states.');
    }
    return {
      for (final v in decoded)
        (v as Map<String, dynamic>)['id'] as String:
            WasalnyRequestState.fromJson(v),
    };
  }

  Future<void> _save(Map<String, WasalnyRequestState> states) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _key,
      jsonEncode(states.values.map((s) => s.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save Wasalny request states.');
    revision.value++;
  }

  Future<void> markSold(String id) async {
    final states = await load();
    final s = states[id] ?? WasalnyRequestState(id: id);
    if (s.isSold) return;
    states[id] = s.copyWith(soldAt: DateTime.now());
    await _save(states);
  }

  /// Raises a suspicious-request flag / seller-ban request to the head.
  /// Never goes straight to the admin.
  Future<void> flagToHead({
    required String id,
    required String title,
    required String sellerName,
    required WasalnyRequestFlagKind kind,
    required String reason,
  }) async {
    final clean = reason.replaceAll(' — ', ' - ').replaceAll('\n', ' ').trim();
    if (clean.length < 5) {
      throw ArgumentError('A written reason is required.');
    }
    final states = await load();
    final s = states[id] ?? WasalnyRequestState(id: id);
    if (!s.canFlag) {
      throw StateError('This request already has an open flag.');
    }
    final now = DateTime.now();
    final round = s.escalations;
    await _events.publish(LocalEvent(
      id: round == 0 ? '$eventPrefix$id' : '$eventPrefix$id-r${round + 1}',
      recipient: 'head',
      source: 'wasalny',
      titleAr: 'وصلني: ${kind.labelAr}',
      titleEn: 'Wasalny request flagged',
      messageAr:
          '$id: $title — البائع: $sellerName. النوع: ${kind.labelAr}. السبب: $clean',
      messageEn:
          '$id: $title — Seller: $sellerName. Type: ${kind.name}. Reason: $clean',
      createdAt: now,
    ));
    states[id] = s.copyWith(
      flagKind: kind,
      flagStatus: WasalnyRequestFlagStatus.pendingHead,
      reason: clean,
      escalatedAt: now,
      escalations: round + 1,
    );
    await _save(states);
  }

  /// Applies head decisions; returns the fresh states.
  Future<Map<String, WasalnyRequestState>> refresh() async {
    final states = await load();
    final waiting = states.values
        .where((s) => s.flagStatus == WasalnyRequestFlagStatus.pendingHead)
        .toList();
    if (waiting.isEmpty) return states;
    final events = await _events.getEvents('wasalny');
    var changed = false;
    for (final s in waiting) {
      final prefix = '$decisionPrefix${s.id}-';
      final match = events.where((e) => e.id.startsWith(prefix)).firstOrNull;
      if (match == null || match.id == s.lastDecisionEventId) continue;
      final action = HeadSupervisorDecisionAction.values
          .where((a) => match.titleAr.contains(a.labelAr))
          .firstOrNull;
      final status = switch (action) {
        HeadSupervisorDecisionAction.escalateToAdmin =>
          WasalnyRequestFlagStatus.escalatedToAdmin,
        HeadSupervisorDecisionAction.returnForReview ||
        HeadSupervisorDecisionAction.requestExplanation =>
          WasalnyRequestFlagStatus.returned,
        _ => WasalnyRequestFlagStatus.decided,
      };
      states[s.id] =
          s.copyWith(flagStatus: status, lastDecisionEventId: match.id);
      changed = true;
    }
    if (changed) await _save(states);
    return states;
  }
}
