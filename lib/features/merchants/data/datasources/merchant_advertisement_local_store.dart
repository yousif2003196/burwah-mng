import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';

class MerchantAdvertisementLocalStore {
  static const _storageKey = 'merchant_advertisement_statuses_v1';
  static final ValueNotifier<int> version = ValueNotifier<int>(0);
  static bool _loaded = false;
  static Future<void>? _loading;
  static final Map<String, MerchantAdvertisementStatus> _statuses = {};

  static Future<void> ensureLoaded() {
    if (_loaded) return Future<void>.value();
    return _loading ??= _load();
  }

  static Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_storageKey);
      if (encoded != null) {
        final decoded = jsonDecode(encoded);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
            'Stored merchant advertisement statuses are invalid.',
          );
        }
        final statuses = <String, MerchantAdvertisementStatus>{};
        for (final entry in decoded.entries) {
          if (entry.value is! String) {
            throw const FormatException(
              'Stored merchant advertisement status is invalid.',
            );
          }
          MerchantAdvertisementStatus? status;
          for (final candidate in MerchantAdvertisementStatus.values) {
            if (candidate.name == entry.value) status = candidate;
          }
          if (status == null) {
            throw FormatException(
              'Unknown advertisement status "${entry.value}".',
            );
          }
          statuses[entry.key] = status;
        }
        _statuses
          ..clear()
          ..addAll(statuses);
      }
      _loaded = true;
    } finally {
      _loading = null;
    }
  }

  static MerchantAdvertisementStatus statusFor(
    String reference,
    MerchantAdvertisementStatus defaultStatus,
  ) =>
      _statuses[reference] ?? defaultStatus;

  static Future<Map<String, MerchantAdvertisementStatus>> loadStatuses() async {
    await ensureLoaded();
    return Map.unmodifiable(_statuses);
  }

  static Future<void> saveStatus({
    required String reference,
    required MerchantAdvertisementStatus status,
  }) async {
    await ensureLoaded();
    final previous = _statuses[reference];
    _statuses[reference] = status;
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _storageKey,
        jsonEncode({
          for (final entry in _statuses.entries) entry.key: entry.value.name,
        }),
      );
      if (!saved) {
        throw StateError('Could not save merchant advertisement status.');
      }
      version.value++;
    } catch (_) {
      if (previous == null) {
        _statuses.remove(reference);
      } else {
        _statuses[reference] = previous;
      }
      rethrow;
    }
  }
}
