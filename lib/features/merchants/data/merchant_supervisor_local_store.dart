import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../wasalny_supervisor/data/wasalny_local_event_store.dart';

class MerchantSupervisorAuditEvent {
  final String action;
  final String subject;
  final String details;
  final DateTime occurredAt;
  final String? merchantId;

  const MerchantSupervisorAuditEvent({
    required this.action,
    required this.subject,
    required this.details,
    required this.occurredAt,
    this.merchantId,
  });
}

class MerchantSupervisorLocalStore {
  MerchantSupervisorLocalStore._();

  static const _storageKey = 'merchant_supervisor_local_operations_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static final WasalnyLocalEventStore _eventStore = WasalnyLocalEventStore();

  static Future<Set<String>> getSuspendedMerchantIds() async {
    final state = await _readState();
    final merchants = state['merchants'];
    if (merchants is! Map<String, dynamic>) {
      throw const FormatException('Suspended merchant data is invalid.');
    }
    return merchants.entries
        .where((entry) =>
            entry.value is Map<String, dynamic> &&
            (entry.value as Map<String, dynamic>)['suspended'] == true)
        .map((entry) => entry.key)
        .toSet();
  }

  static Future<Map<String, bool>> getSuspensionOverrides() async {
    final state = await _readState();
    final merchants = state['merchants'] as Map<String, dynamic>;
    return {
      for (final entry in merchants.entries)
        if (entry.value is Map<String, dynamic> &&
            (entry.value as Map<String, dynamic>)['suspended'] is bool)
          entry.key: (entry.value as Map<String, dynamic>)['suspended'] as bool,
    };
  }

  static Future<Map<String, double>> getCommissionOverrides() async {
    final state = await _readState();
    final merchants = state['merchants'] as Map<String, dynamic>;
    return {
      for (final entry in merchants.entries)
        if (entry.value is Map<String, dynamic> &&
            (entry.value as Map<String, dynamic>)['commissionPercent'] is num)
          entry.key: ((entry.value as Map<String, dynamic>)['commissionPercent']
                  as num)
              .toDouble(),
    };
  }

  static Future<void> setMerchantCommission({
    required String merchantId,
    required String merchantName,
    required double commissionPercent,
    required String action,
  }) async {
    if (!commissionPercent.isFinite ||
        commissionPercent < 0 ||
        commissionPercent > 100) {
      throw ArgumentError.value(commissionPercent, 'commissionPercent');
    }
    final state = await _readState();
    final merchants = state['merchants'] as Map<String, dynamic>;
    final existing = merchants[merchantId];
    final merchant = existing is Map<String, dynamic>
        ? Map<String, dynamic>.from(existing)
        : <String, dynamic>{};
    merchant['name'] = merchantName;
    merchant['commissionPercent'] = commissionPercent;
    merchant['commissionUpdatedAt'] = DateTime.now().toIso8601String();
    merchants[merchantId] = merchant;
    _appendAuditEvent(
      state,
      action: action,
      subject: merchantName,
      details: '${commissionPercent.toStringAsFixed(1)}%',
      merchantId: merchantId,
    );
    await _writeState(state);
    await _publishMerchantNotice(
      action: action,
      subject: merchantName,
      details: '${commissionPercent.toStringAsFixed(1)}%',
      merchantId: merchantId,
    );
  }

  static Future<List<MerchantSupervisorAuditEvent>> getAuditEvents() async {
    final state = await _readState();
    final events = state['events'];
    if (events is! List<dynamic>) {
      throw const FormatException('Merchant audit events are invalid.');
    }
    return events.map((value) {
      if (value is! Map<String, dynamic> ||
          value['action'] is! String ||
          value['subject'] is! String ||
          value['details'] is! String ||
          value['occurredAt'] is! String) {
        throw const FormatException('Merchant audit event is invalid.');
      }
      return MerchantSupervisorAuditEvent(
        action: value['action'] as String,
        subject: value['subject'] as String,
        details: value['details'] as String,
        occurredAt: DateTime.parse(value['occurredAt'] as String),
        merchantId: value['merchantId'] as String?,
      );
    }).toList(growable: false);
  }

  static Future<void> setMerchantSuspended({
    required String merchantId,
    required String merchantName,
    required bool isSuspended,
    required String action,
    required String details,
  }) async {
    final state = await _readState();
    final merchants = state['merchants'] as Map<String, dynamic>;
    final existing = merchants[merchantId];
    final merchant = existing is Map<String, dynamic>
        ? Map<String, dynamic>.from(existing)
        : <String, dynamic>{};
    merchant.addAll({
      'name': merchantName,
      'details': details,
      'suspended': isSuspended,
      'occurredAt': DateTime.now().toIso8601String(),
    });
    merchants[merchantId] = merchant;
    _appendAuditEvent(
      state,
      action: action,
      subject: merchantName,
      details: details,
      merchantId: merchantId,
    );
    await _writeState(state);
    await _publishMerchantNotice(
      action: action,
      subject: merchantName,
      details: details,
      merchantId: merchantId,
    );
  }

  static Future<void> recordAction({
    required String action,
    required String subject,
    required String details,
    String? merchantId,
  }) async {
    final state = await _readState();
    _appendAuditEvent(
      state,
      action: action,
      subject: subject,
      details: details,
      merchantId: merchantId,
    );
    await _writeState(state);
    await _publishMerchantNotice(
      action: action,
      subject: subject,
      details: details,
      merchantId: merchantId,
    );
  }

  static Future<void> _publishMerchantNotice({
    required String action,
    required String subject,
    required String details,
    String? merchantId,
  }) async {
    final occurredAt = DateTime.now();
    final suffix = merchantId == null ? '' : ' · $merchantId';
    final message = '$action: $details$suffix';
    try {
      await _eventStore.publish(
        WasalnyLocalEvent(
          id: 'merchant-action-${occurredAt.microsecondsSinceEpoch}',
          recipient: 'merchant',
          source: 'merchants',
          titleAr: 'تحديث على حساب التاجر',
          titleEn: 'Merchant account update',
          messageAr: '$subject — $message',
          messageEn: '$subject — $message',
          createdAt: occurredAt,
        ),
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant action notifications',
        ),
      );
    }
  }

  static void _appendAuditEvent(
    Map<String, dynamic> state, {
    required String action,
    required String subject,
    required String details,
    String? merchantId,
  }) {
    final events = state['events'] as List<dynamic>;
    events.insert(0, {
      'action': action,
      'subject': subject,
      'details': details,
      if (merchantId != null) 'merchantId': merchantId,
      'occurredAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>> _readState() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) {
      return {'merchants': <String, dynamic>{}, 'events': <dynamic>[]};
    }
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic> ||
        decoded['merchants'] is! Map<String, dynamic> ||
        decoded['events'] is! List<dynamic>) {
      throw const FormatException('Merchant supervisor local data is invalid.');
    }
    return {
      'merchants': Map<String, dynamic>.from(
        decoded['merchants'] as Map<String, dynamic>,
      ),
      'events': List<dynamic>.from(decoded['events'] as List<dynamic>),
    };
  }

  static Future<void> _writeState(Map<String, dynamic> state) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_storageKey, jsonEncode(state));
    if (!saved) {
      throw StateError('Could not save merchant supervisor local data.');
    }
    revision.value++;
  }
}
