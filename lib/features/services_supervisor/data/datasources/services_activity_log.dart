import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesActivityEntry {
  final String action;
  final String subject;
  final String details;
  final DateTime at;

  const ServicesActivityEntry({
    required this.action,
    required this.subject,
    required this.details,
    required this.at,
  });

  Map<String, Object?> toJson() => {
        'action': action,
        'subject': subject,
        'details': details,
        'at': at.toIso8601String(),
      };

  factory ServicesActivityEntry.fromJson(Map<String, dynamic> j) =>
      ServicesActivityEntry(
        action: j['action'] as String,
        subject: j['subject'] as String,
        details: j['details'] as String,
        at: DateTime.parse(j['at'] as String),
      );
}

/// Local audit trail for the services supervisor's decisions.
class ServicesActivityLog {
  static const _key = 'services_activity_log_v1';
  static const _maxEntries = 500;
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<List<ServicesActivityEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid services activity log.');
    }
    return [
      for (final v in decoded)
        ServicesActivityEntry.fromJson(v as Map<String, dynamic>),
    ];
  }

  Future<void> record({
    required String action,
    required String subject,
    String details = '',
  }) async {
    final all = await getAll();
    final entries = [
      ServicesActivityEntry(
        action: action,
        subject: subject,
        details: details,
        at: DateTime.now(),
      ),
      ...all,
    ].take(_maxEntries).toList();
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _key,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save the services activity log.');
    revision.value++;
  }

  /// Best-effort logging for UI flows: never blocks the main action.
  Future<void> tryRecord({
    required String action,
    required String subject,
    String details = '',
  }) async {
    try {
      await record(action: action, subject: subject, details: details);
    } on Object catch (error) {
      debugPrint('Services activity log unavailable: $error');
    }
  }
}
