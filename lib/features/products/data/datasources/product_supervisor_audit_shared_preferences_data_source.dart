import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/products/data/datasources/product_supervisor_audit_data_source.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';

class ProductSupervisorAuditSharedPreferencesDataSource
    implements ProductSupervisorAuditDataSource {
  static const _storageKey = 'product_supervisor_audit_entries';

  @override
  Future<List<ProductSupervisorAuditEntry>> getEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedEntries = preferences.getString(_storageKey);
    if (encodedEntries == null) return [];

    final decoded = jsonDecode(encodedEntries);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid supervisor audit log format.');
    }
    return decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid supervisor audit entry.');
      }
      return ProductSupervisorAuditEntry(
        id: value['id'] as String,
        actionKey: value['actionKey'] as String,
        subject: value['subject'] as String,
        details: value['details'] as String,
        occurredAt: DateTime.parse(value['occurredAt'] as String),
      );
    }).toList(growable: false);
  }

  @override
  Future<void> saveEntry(ProductSupervisorAuditEntry entry) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await getEntries();
    final updatedEntries = [
      {
        'id': entry.id,
        'actionKey': entry.actionKey,
        'subject': entry.subject,
        'details': entry.details,
        'occurredAt': entry.occurredAt.toIso8601String(),
      },
      ...entries.map(
        (existing) => {
          'id': existing.id,
          'actionKey': existing.actionKey,
          'subject': existing.subject,
          'details': existing.details,
          'occurredAt': existing.occurredAt.toIso8601String(),
        },
      ),
    ];
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(updatedEntries),
    );
    if (!saved) {
      throw StateError('Could not persist the supervisor audit entry.');
    }
  }
}
