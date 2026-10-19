import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinanceAuditEntry {
  final String id;
  final String actionKey;
  final String titleAr;
  final String titleEn;
  final String detailsAr;
  final String detailsEn;
  final String reference;
  final String actor;
  final DateTime occurredAt;

  const FinanceAuditEntry({
    required this.id,
    required this.actionKey,
    required this.titleAr,
    required this.titleEn,
    required this.detailsAr,
    required this.detailsEn,
    required this.reference,
    required this.actor,
    required this.occurredAt,
  });

  Map<String, Object?> toJson() => {
        'id': id,
        'actionKey': actionKey,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'detailsAr': detailsAr,
        'detailsEn': detailsEn,
        'reference': reference,
        'actor': actor,
        'occurredAt': occurredAt.toIso8601String(),
      };

  factory FinanceAuditEntry.fromJson(Map<String, dynamic> json) =>
      FinanceAuditEntry(
        id: json['id'] as String,
        actionKey: json['actionKey'] as String,
        titleAr: json['titleAr'] as String,
        titleEn: json['titleEn'] as String,
        detailsAr: json['detailsAr'] as String,
        detailsEn: json['detailsEn'] as String,
        reference: json['reference'] as String? ?? '',
        actor: json['actor'] as String? ?? 'finance',
        occurredAt: DateTime.parse(json['occurredAt'] as String),
      );
}

class FinanceAuditStore {
  static const _storageKey = 'finance_audit_entries_v1';
  static const _maxEntries = 500;
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<List<FinanceAuditEntry>> getRecent({int? limit}) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Finance audit entries must be a list.');
    }
    final entries = decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid finance audit entry.');
      }
      return FinanceAuditEntry.fromJson(value);
    }).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return limit == null ? entries : entries.take(limit).toList();
  }

  Future<void> record(FinanceAuditEntry entry) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await getRecent();
    if (entries.any((item) => item.id == entry.id)) return;
    entries.insert(0, entry);
    if (entries.length > _maxEntries) {
      entries.removeRange(_maxEntries, entries.length);
    }
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(entries.map((item) => item.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save the finance audit entry.');
    revision.value++;
  }
}
