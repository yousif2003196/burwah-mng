import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/finance_audit_store.dart';

class FinanceCommissionMatrix {
  static const _storageKey = 'finance_commission_matrix_v1';
  static const _historyKey = 'finance_commission_matrix_history_v1';

  final double salesPercentage;
  final double settlementPercentage;
  final double deliveryPercentage;
  final double deliveryFixedAmount;
  final bool addFixedFee;
  final bool notifyAll;
  final String deliveryCommissionType;
  final String reason;
  final DateTime? updatedAt;

  const FinanceCommissionMatrix({
    required this.salesPercentage,
    required this.settlementPercentage,
    required this.deliveryPercentage,
    required this.deliveryFixedAmount,
    required this.addFixedFee,
    required this.notifyAll,
    required this.deliveryCommissionType,
    required this.reason,
    required this.updatedAt,
  });

  const FinanceCommissionMatrix.defaults()
      : salesPercentage = 4.5,
        settlementPercentage = 1.25,
        deliveryPercentage = 7,
        deliveryFixedAmount = 3,
        addFixedFee = true,
        notifyAll = true,
        deliveryCommissionType = 'percentage',
        reason = '',
        updatedAt = null;

  static Future<FinanceCommissionMatrix> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const FinanceCommissionMatrix.defaults();

    try {
      return _decode(raw);
    } on FormatException {
      return const FinanceCommissionMatrix.defaults();
    } on TypeError {
      return const FinanceCommissionMatrix.defaults();
    }
  }

  static Future<List<FinanceCommissionMatrix>> loadHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final history = preferences.getStringList(_historyKey) ?? <String>[];
    final entries = <FinanceCommissionMatrix>[];
    for (final raw in history) {
      try {
        entries.add(_decode(raw));
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }
    return entries;
  }

  Future<void> save() async {
    final preferences = await SharedPreferences.getInstance();
    final savedAt = DateTime.now();
    final data = <String, Object>{
      'salesPercentage': salesPercentage,
      'settlementPercentage': settlementPercentage,
      'deliveryPercentage': deliveryPercentage,
      'deliveryFixedAmount': deliveryFixedAmount,
      'addFixedFee': addFixedFee,
      'notifyAll': notifyAll,
      'deliveryCommissionType': deliveryCommissionType,
      'reason': reason,
      'updatedAt': savedAt.toIso8601String(),
    };
    final history = preferences.getStringList(_historyKey) ?? <String>[];
    history.insert(0, jsonEncode(data));
    if (history.length > 50) history.removeRange(50, history.length);

    final matrixSaved = await preferences.setString(_storageKey, jsonEncode(data));
    final historySaved = await preferences.setStringList(_historyKey, history);
    if (!matrixSaved || !historySaved) {
      throw StateError('Could not persist finance commission matrix.');
    }
    try {
      await FinanceAuditStore().record(FinanceAuditEntry(
        id: 'commission-matrix-${savedAt.microsecondsSinceEpoch}',
        actionKey: 'commission_matrix_updated',
        titleAr: 'تعديل مصفوفة العمولات',
        titleEn: 'Commission matrix updated',
        detailsAr:
            'المبيعات $salesPercentage% · التسوية $settlementPercentage% · التوصيل $deliveryPercentage%${reason.trim().isEmpty ? '' : ' · السبب: ${reason.trim()}'}',
        detailsEn:
            'Sales $salesPercentage% · settlement $settlementPercentage% · delivery $deliveryPercentage%${reason.trim().isEmpty ? '' : ' · Reason: ${reason.trim()}'}',
        reference: 'commission-matrix',
        actor: 'finance',
        occurredAt: savedAt,
      ));
    } catch (error, stackTrace) {
      // Audit recording must not undo a successfully saved commission matrix.
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'finance commission matrix audit',
      ));
    }
  }

  static double _readDouble(
      Map<String, dynamic> data, String key, double fallback) {
    final value = data[key];
    if (value is num && value.isFinite) return value.toDouble();
    return fallback;
  }

  static FinanceCommissionMatrix _decode(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return FinanceCommissionMatrix(
      salesPercentage: _readDouble(data, 'salesPercentage', 4.5),
      settlementPercentage: _readDouble(data, 'settlementPercentage', 1.25),
      deliveryPercentage: _readDouble(data, 'deliveryPercentage', 7),
      deliveryFixedAmount: _readDouble(data, 'deliveryFixedAmount', 3),
      addFixedFee: data['addFixedFee'] as bool? ?? true,
      notifyAll: data['notifyAll'] as bool? ?? true,
      deliveryCommissionType:
          data['deliveryCommissionType'] as String? ?? 'percentage',
      reason: data['reason'] as String? ?? '',
      updatedAt: DateTime.tryParse(data['updatedAt'] as String? ?? ''),
    );
  }
}
