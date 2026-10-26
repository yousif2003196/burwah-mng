import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_record.dart';

/// حسابات تنفيذية يديرها الأدمن وحده (لا تظهر لرئيس المشرفين)،
/// مثل حساب المشرف المالي. تُحفظ حالة الإيقاف محليًا.
class AdminManagedAccountStore {
  static const _storageKey = 'admin_managed_accounts_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static const _defaults = <HeadSupervisorRecord>[
    HeadSupervisorRecord(
      id: '#FIN-01',
      name: 'المشرف المالي',
      department: 'قسم المالية والمحافظ',
      status: 'نشط',
      metric: '',
      score: '',
      avatar: 'مل',
      color: AppPalette.green537A61,
      accountId: 'finance',
      area: 'الإدارة المركزية',
      city: 'الإدارة المركزية',
      marketScope: 'الطلبات والمحافظ المالية',
    ),
  ];

  bool manages(String id) => _defaults.any((item) => item.id == id);

  Future<Map<String, dynamic>> _readState() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  Future<List<HeadSupervisorRecord>> getAll() async {
    final state = await _readState();
    return [
      for (final item in _defaults)
        () {
          final entry = state[item.id];
          if (entry is! Map<String, dynamic>) return item;
          return item.copyWith(
            suspended: entry['suspended'] as bool? ?? false,
            suspensionReason: entry['reason'] as String? ?? '',
          );
        }(),
    ];
  }

  Future<bool> isAccountSuspended(String accountId) async {
    final all = await getAll();
    return all.any((item) => item.accountId == accountId && item.suspended);
  }

  Future<void> setSuspended(String id, bool suspended, String reason) async {
    if (!manages(id)) return;
    final state = await _readState();
    state[id] = {'suspended': suspended, 'reason': reason};
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_storageKey, jsonEncode(state));
    if (!saved) throw StateError('Could not save managed accounts.');
    revision.value++;
  }
}
