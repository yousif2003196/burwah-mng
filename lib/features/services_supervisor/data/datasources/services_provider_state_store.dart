import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesProviderState {
  final String id;
  final bool? available;
  final bool? verified;
  final bool suspended;
  final String? reason;
  final DateTime? updatedAt;

  const ServicesProviderState({
    required this.id,
    this.available,
    this.verified,
    this.suspended = false,
    this.reason,
    this.updatedAt,
  });

  ServicesProviderState copyWith({
    bool? available,
    bool? verified,
    bool? suspended,
    String? reason,
  }) =>
      ServicesProviderState(
        id: id,
        available: available ?? this.available,
        verified: verified ?? this.verified,
        suspended: suspended ?? this.suspended,
        reason: reason ?? this.reason,
        updatedAt: DateTime.now(),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'available': available,
        'verified': verified,
        'suspended': suspended,
        'reason': reason,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ServicesProviderState.fromJson(Map<String, dynamic> j) =>
      ServicesProviderState(
        id: j['id'] as String,
        available: j['available'] as bool?,
        verified: j['verified'] as bool?,
        suspended: (j['suspended'] as bool?) ?? false,
        reason: j['reason'] as String?,
        updatedAt: j['updatedAt'] == null
            ? null
            : DateTime.parse(j['updatedAt'] as String),
      );
}

/// Local overrides on top of the static provider catalog: temporary
/// suspension, reactivation and verification.
class ServicesProviderStateStore {
  static const _key = 'services_provider_states_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<Map<String, ServicesProviderState>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid provider states.');
    }
    return {
      for (final v in decoded)
        (v as Map<String, dynamic>)['id'] as String:
            ServicesProviderState.fromJson(v),
    };
  }

  Future<void> _save(Map<String, ServicesProviderState> all) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _key,
      jsonEncode(all.values.map((s) => s.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save provider states.');
    revision.value++;
  }

  Future<void> suspend(String id, String reason) async {
    final clean = reason.trim();
    if (clean.length < 5) throw ArgumentError('A reason is required.');
    final all = await load();
    final s = all[id] ?? ServicesProviderState(id: id);
    all[id] = s.copyWith(suspended: true, available: false, reason: clean);
    await _save(all);
  }

  Future<void> reactivate(String id) async {
    final all = await load();
    final s = all[id] ?? ServicesProviderState(id: id);
    all[id] = s.copyWith(suspended: false, available: true);
    await _save(all);
  }

  Future<void> setVerified(String id, bool verified) async {
    final all = await load();
    final s = all[id] ?? ServicesProviderState(id: id);
    all[id] = s.copyWith(verified: verified);
    await _save(all);
  }
}
