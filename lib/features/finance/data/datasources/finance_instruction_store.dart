import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/finance/data/datasources/finance_audit_store.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_audit_entry.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_instruction.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

/// تعليمات الأدمن للمالية (استرداد/تعويض) وحالة تنفيذها.
class FinanceInstructionStore {
  static const _storageKey = 'finance_instructions_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<List<FinanceInstruction>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid finance instructions.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(FinanceInstruction.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveAll(List<FinanceInstruction> items) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
        _storageKey, jsonEncode(items.map((e) => e.toJson()).toList()));
    if (!saved) throw StateError('Could not save finance instructions.');
    revision.value++;
  }

  /// يضيف تعليمة جديدة (تجاهل إن وُجد نفس المعرّف).
  Future<void> add(FinanceInstruction instruction) async {
    final items = await getAll();
    if (items.any((e) => e.id == instruction.id)) return;
    await _saveAll([instruction, ...items]);
  }

  /// يسجّل تنفيذ التعليمة أو تعذّرها، ويُبلغ الأدمن ويضيف سجلًا للتدقيق المالي.
  Future<void> resolve(
    String id,
    FinanceInstructionStatus status,
    String note,
  ) async {
    final items = await getAll();
    final index = items.indexWhere((e) => e.id == id);
    if (index < 0 || !items[index].isPending) return;
    final now = DateTime.now();
    final resolved = items[index].resolve(status, note, now);
    items[index] = resolved;
    await _saveAll(items);

    final done = status == FinanceInstructionStatus.executed;
    final kindAr =
        resolved.kind == FinanceInstructionKind.refund ? 'استرداد' : 'تعويض';
    final kindEn =
        resolved.kind == FinanceInstructionKind.refund ? 'refund' : 'compensation';
    final value = resolved.amount.toStringAsFixed(0);
    await FinanceAuditStore().record(FinanceAuditEntry(
      id: 'finance-instruction-$id-${now.microsecondsSinceEpoch}',
      actionKey: done ? 'instruction_executed' : 'instruction_failed',
      titleAr: done ? 'تنفيذ تعليمة $kindAr' : 'تعذّر تنفيذ تعليمة $kindAr',
      titleEn: done ? 'Executed $kindEn instruction' : 'Failed to execute $kindEn instruction',
      detailsAr: '${resolved.title} — $value ج.م. $note',
      detailsEn: '${resolved.title} — EGP $value. $note',
      reference: resolved.reference,
      actor: 'المشرف المالي',
      occurredAt: now,
    ));
    await LocalEventStore().publish(LocalEvent(
      id: 'finance-instruction-result-$id-${now.microsecondsSinceEpoch}',
      recipient: 'admin',
      source: 'finance',
      titleAr: done ? 'نُفّذت تعليمتك المالية' : 'تعذّر تنفيذ تعليمتك المالية',
      titleEn: done ? 'Your finance instruction was executed' : 'Your finance instruction failed',
      messageAr: '$kindAr بقيمة $value ج.م (${resolved.reference}). $note',
      messageEn: '${kindEn[0].toUpperCase()}${kindEn.substring(1)} of EGP $value (${resolved.reference}). $note',
      createdAt: now,
    ));
  }
}
