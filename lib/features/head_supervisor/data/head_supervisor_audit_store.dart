import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeadSupervisorAuditRecord {
  final String id;
  final String subjectId;
  final String kind;
  final String title;
  final String details;
  final String department;
  final DateTime occurredAt;

  const HeadSupervisorAuditRecord({
    required this.id,
    required this.subjectId,
    required this.kind,
    required this.title,
    required this.details,
    required this.department,
    required this.occurredAt,
  });

  Map<String, Object?> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'kind': kind,
        'title': title,
        'details': details,
        'department': department,
        'occurredAt': occurredAt.toIso8601String(),
      };

  factory HeadSupervisorAuditRecord.fromJson(Map<String, dynamic> json) =>
      HeadSupervisorAuditRecord(
        id: json['id'] as String,
        subjectId: json['subjectId'] as String,
        kind: json['kind'] as String,
        title: json['title'] as String,
        details: json['details'] as String,
        department: json['department'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
      );
}

class HeadSupervisorAuditStore {
  static const _storageKey = 'head_supervisor_audit_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<List<HeadSupervisorAuditRecord>> getRecent({int limit = 50}) async {
    final records = await getAll();
    return records.take(limit).toList();
  }

  Future<List<HeadSupervisorAuditRecord>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid head supervisor audit log.');
    }
    final records = decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid head supervisor audit record.');
      }
      return HeadSupervisorAuditRecord.fromJson(value);
    }).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return records;
  }

  Future<void> record(HeadSupervisorAuditRecord record) async {
    final preferences = await SharedPreferences.getInstance();
    final records = await _getAll(preferences);
    if (records.any((item) => item.id == record.id)) return;
    records.insert(0, record);
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(records.map((item) => item.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save the head supervisor audit record.');
    revision.value++;
  }

  Future<List<HeadSupervisorAuditRecord>> _getAll(
    SharedPreferences preferences,
  ) async {
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid head supervisor audit log.');
    }
    return decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid head supervisor audit record.');
      }
      return HeadSupervisorAuditRecord.fromJson(value);
    }).toList();
  }
}
