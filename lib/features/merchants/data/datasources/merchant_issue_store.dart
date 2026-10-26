import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_request_decision_sheet.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_supervisor_local_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_issue.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

/// Merchant problems received by the merchants supervisor.
///
/// Escalation always goes to the head of supervisors (a [LocalEvent] to
/// `head`); only the head can escalate onwards to the admin.
class MerchantIssueStore {
  static const _storageKey = 'merchant_issues_v1';
  static const eventPrefix = 'merchant-issue-';
  static const decisionPrefix = 'head-decision-$eventPrefix';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  final LocalEventStore _events;
  MerchantIssueStore({LocalEventStore? events})
      : _events = events ?? LocalEventStore();

  Future<List<MerchantIssue>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid merchant issues list.');
    }
    return [
      for (final v in decoded)
        MerchantIssue.fromJson(v as Map<String, dynamic>),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _save(List<MerchantIssue> issues) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _storageKey,
      jsonEncode(issues.map((i) => i.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save merchant issues.');
    revision.value++;
  }

  Future<MerchantIssue> open({
    required MerchantIssueType type,
    required MerchantIssuePriority priority,
    required String merchantRef,
    required String merchantName,
    required String title,
    required String details,
  }) async {
    final now = DateTime.now();
    final issue = MerchantIssue(
      id: 'MI-${now.millisecondsSinceEpoch % 1000000}',
      type: type,
      priority: priority,
      status: MerchantIssueStatus.open,
      merchantRef: merchantRef.trim(),
      merchantName: merchantName.trim(),
      title: title.trim(),
      details: details.trim(),
      createdAt: now,
      timeline: [MerchantIssueNote(at: now, text: 'تم تسجيل المشكلة')],
    );
    final all = await getAll();
    await _save([issue, ...all]);
    await _audit('فتح مشكلة تاجر', issue, 'النوع: ${type.labelAr}');
    return issue;
  }

  Future<void> _mutate(
    String id,
    MerchantIssue Function(MerchantIssue issue) change,
  ) async {
    final all = await getAll();
    final index = all.indexWhere((i) => i.id == id);
    if (index < 0) return;
    all[index] = change(all[index]);
    await _save(all);
  }

  List<MerchantIssueNote> _plus(MerchantIssue i, String text) =>
      [...i.timeline, MerchantIssueNote(at: DateTime.now(), text: text)];

  Future<void> startProgress(MerchantIssue issue) async {
    if (issue.status != MerchantIssueStatus.open &&
        issue.status != MerchantIssueStatus.returned) {
      return;
    }
    await _mutate(
      issue.id,
      (i) => i.copyWith(
        status: MerchantIssueStatus.inProgress,
        timeline: _plus(i, 'بدء المعالجة'),
      ),
    );
    await _audit('بدء معالجة مشكلة', issue, issue.title);
  }

  /// Sends the issue to the head of supervisors. A reason is mandatory.
  Future<void> escalateToHead(MerchantIssue issue, String reason) async {
    final cleanReason = _clean(reason);
    if (cleanReason.isEmpty) {
      throw ArgumentError('A reason is required to escalate.');
    }
    if (!issue.canEscalateToHead) {
      throw StateError('This issue cannot be escalated in its current state.');
    }
    final now = DateTime.now();
    final ref = issue.merchantRef.isEmpty ? '' : ' (${issue.merchantRef})';
    await _events.publish(LocalEvent(
      id: '$eventPrefix${issue.id}',
      recipient: 'head',
      source: 'merchant',
      titleAr: 'تصعيد من مشرف التجار: ${issue.type.labelAr}',
      titleEn: 'Merchants supervisor escalation',
      messageAr:
          '${issue.id}: ${_clean(issue.title)}$ref — التاجر: ${_clean(issue.merchantName)}. الأولوية: ${issue.priority.labelAr}. السبب: $cleanReason',
      messageEn:
          '${issue.id}: ${_clean(issue.title)}$ref — Merchant: ${_clean(issue.merchantName)}. Reason: $cleanReason',
      createdAt: now,
    ));
    await _mutate(
      issue.id,
      (i) => i.copyWith(
        status: MerchantIssueStatus.escalatedToHead,
        escalatedAt: now,
        escalationReason: cleanReason,
        timeline: _plus(i, 'تم التصعيد لرئيس المشرفين — $cleanReason'),
      ),
    );
    await _audit('تصعيد مشكلة لرئيس المشرفين', issue, cleanReason);
  }

  Future<void> close(MerchantIssue issue, String note) async {
    if (issue.status == MerchantIssueStatus.escalatedToHead) {
      throw StateError('Wait for the head decision before closing.');
    }
    final clean = _clean(note);
    await _mutate(
      issue.id,
      (i) => i.copyWith(
        status: MerchantIssueStatus.closed,
        timeline: _plus(i, clean.isEmpty ? 'تم الإغلاق' : 'تم الإغلاق — $clean'),
      ),
    );
    await _audit('إغلاق مشكلة', issue, clean);
  }

  /// Applies head decisions (events addressed to `merchant`) to the issues.
  /// Returns true if any issue changed.
  Future<bool> syncHeadDecisions() async {
    final issues = await getAll();
    if (issues.every((i) => i.status != MerchantIssueStatus.escalatedToHead)) {
      return false;
    }
    final events = await _events.getEvents('merchant');
    var changed = false;
    final updated = <MerchantIssue>[];
    for (final issue in issues) {
      final prefix = '$decisionPrefix${issue.id}-';
      // events are newest-first
      final match = events.where((e) => e.id.startsWith(prefix)).firstOrNull;
      if (match == null ||
          match.id == issue.lastDecisionEventId ||
          issue.status != MerchantIssueStatus.escalatedToHead) {
        updated.add(issue);
        continue;
      }
      final action = HeadSupervisorDecisionAction.values
          .where((a) => match.titleAr.contains(a.labelAr))
          .firstOrNull;
      final status = switch (action) {
        HeadSupervisorDecisionAction.escalateToAdmin =>
          MerchantIssueStatus.escalatedToAdmin,
        HeadSupervisorDecisionAction.returnForReview ||
        HeadSupervisorDecisionAction.requestExplanation =>
          MerchantIssueStatus.returned,
        _ => MerchantIssueStatus.resolved,
      };
      updated.add(issue.copyWith(
        status: status,
        lastDecisionEventId: match.id,
        timeline: [
          ...issue.timeline,
          MerchantIssueNote(
            at: match.createdAt,
            text: match.messageAr.isEmpty ? match.titleAr : match.messageAr,
          ),
        ],
      ));
      changed = true;
    }
    if (changed) await _save(updated);
    return changed;
  }

  static String _clean(String s) =>
      s.replaceAll(' — ', ' - ').replaceAll('\n', ' ').trim();

  Future<void> _audit(String action, MerchantIssue issue, String details) =>
      MerchantSupervisorLocalStore.recordAction(
        action: action,
        subject: '${issue.id} · ${issue.title}',
        details: details.isEmpty ? issue.type.labelAr : details,
        merchantId: issue.merchantRef.isEmpty ? null : issue.merchantRef,
        notifyMerchant: false,
      );
}
