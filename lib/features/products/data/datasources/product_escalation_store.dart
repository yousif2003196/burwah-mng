import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_request_decision_sheet.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

enum ProductEscalationKind {
  complaint('شكوى عميل'),
  product('مراجعة منتج'),
  unblock('طلب رفع إيقاف');

  final String labelAr;
  const ProductEscalationKind(this.labelAr);
}

enum ProductEscalationStatus {
  pendingHead('بانتظار قرار رئيس المشرفين'),
  returned('أعادها الرئيس للمراجعة'),
  escalatedToAdmin('رفعها الرئيس للأدمن'),
  decided('حسمها الرئيس');

  final String labelAr;
  const ProductEscalationStatus(this.labelAr);
}

class ProductEscalationNote {
  final DateTime at;
  final String text;
  const ProductEscalationNote(this.at, this.text);

  Map<String, Object?> toJson() => {'at': at.toIso8601String(), 'text': text};
  factory ProductEscalationNote.fromJson(Map<String, dynamic> j) =>
      ProductEscalationNote(
          DateTime.parse(j['at'] as String), j['text'] as String);
}

/// A complaint / product review sent to the head of supervisors.
/// It never goes straight to the admin.
class ProductEscalation {
  static const headSla = Duration(hours: 48);

  final ProductEscalationKind kind;
  final String refId;
  final String title;
  final ProductEscalationStatus status;
  final String reason;
  final DateTime escalatedAt;
  final int rounds;
  final String? lastDecisionEventId;
  final List<ProductEscalationNote> timeline;

  const ProductEscalation({
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
  static String keyOf(ProductEscalationKind kind, String refId) =>
      '${kind.name}:$refId';

  bool get canEscalateAgain => status == ProductEscalationStatus.returned;

  bool isOverdue(DateTime now) =>
      status == ProductEscalationStatus.pendingHead &&
      now.difference(escalatedAt) > headSla;

  ProductEscalation copyWith({
    ProductEscalationStatus? status,
    String? reason,
    DateTime? escalatedAt,
    int? rounds,
    String? lastDecisionEventId,
    List<ProductEscalationNote>? timeline,
  }) =>
      ProductEscalation(
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

  factory ProductEscalation.fromJson(Map<String, dynamic> j) =>
      ProductEscalation(
        kind: ProductEscalationKind.values.byName(j['kind'] as String),
        refId: j['refId'] as String,
        title: j['title'] as String,
        status: ProductEscalationStatus.values.byName(j['status'] as String),
        reason: j['reason'] as String,
        escalatedAt: DateTime.parse(j['escalatedAt'] as String),
        rounds: (j['rounds'] as int?) ?? 1,
        lastDecisionEventId: j['lastDecisionEventId'] as String?,
        timeline: [
          for (final n in (j['timeline'] as List<dynamic>? ?? const []))
            ProductEscalationNote.fromJson(n as Map<String, dynamic>),
        ],
      );
}

class ProductEscalationStore {
  static const _key = 'product_escalations_v1';
  static const eventPrefix = 'head-products-esc-';
  static const decisionPrefix = 'head-decision-$eventPrefix';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  final LocalEventStore _events;
  ProductEscalationStore({LocalEventStore? events})
      : _events = events ?? LocalEventStore();

  Future<Map<String, ProductEscalation>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid product escalations.');
    }
    final list = [
      for (final v in decoded)
        ProductEscalation.fromJson(v as Map<String, dynamic>),
    ];
    return {for (final e in list) e.key: e};
  }

  Future<void> _save(Map<String, ProductEscalation> all) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _key,
      jsonEncode(all.values.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save product escalations.');
    revision.value++;
  }

  /// Sends [refId] to the head. A written reason is mandatory.
  Future<void> escalate({
    required ProductEscalationKind kind,
    required String refId,
    required String title,
    required String subject,
    required String reason,
  }) async {
    final clean = reason.replaceAll(' — ', ' - ').replaceAll('\n', ' ').trim();
    if (clean.length < 5) throw ArgumentError('A written reason is required.');
    final all = await load();
    final key = ProductEscalation.keyOf(kind, refId);
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
      source: 'products',
      titleAr: 'تصعيد من مشرف المنتجات: ${kind.labelAr}',
      titleEn: 'Products supervisor escalation',
      messageAr:
          '$refId: ${title.replaceAll(' — ', ' - ')} — $subject. السبب: $clean',
      messageEn:
          '$refId: ${title.replaceAll(' — ', ' - ')} — $subject. Reason: $clean',
      createdAt: now,
    ));
    all[key] = ProductEscalation(
      kind: kind,
      refId: refId,
      title: title,
      status: ProductEscalationStatus.pendingHead,
      reason: clean,
      escalatedAt: now,
      rounds: rounds,
      lastDecisionEventId: existing?.lastDecisionEventId,
      timeline: [
        ...?existing?.timeline,
        ProductEscalationNote(now, 'تم الرفع لرئيس المشرفين — $clean'),
      ],
    );
    await _save(all);
  }

  /// Applies head decisions (events addressed to `products`).
  Future<Map<String, ProductEscalation>> refresh() async {
    final all = await load();
    final waiting = all.values
        .where((e) => e.status == ProductEscalationStatus.pendingHead)
        .toList();
    if (waiting.isEmpty) return all;
    final events = await _events.getEvents('products');
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
          ProductEscalationStatus.escalatedToAdmin,
        HeadSupervisorDecisionAction.returnForReview ||
        HeadSupervisorDecisionAction.requestExplanation =>
          ProductEscalationStatus.returned,
        _ => ProductEscalationStatus.decided,
      };
      all[e.key] = e.copyWith(
        status: status,
        lastDecisionEventId: match.id,
        timeline: [
          ...e.timeline,
          ProductEscalationNote(
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
