import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/admin/domain/entities/head_account.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

class HeadAccountStore {
  static const _storageKey = 'admin_head_accounts_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static final defaultAccounts = <HeadAccountRecord>[
    HeadAccountRecord(
      id: '#HSUP-101',
      name: 'م. عادل بن ناصر الشمري',
      email: 'head.adel@barwah.com',
      phone: '+966 50 123 4567',
      sector: 'خدمات وصيانة',
      permissions: const {
        HeadPermission.settleDisputes,
        HeadPermission.approveRefunds,
        HeadPermission.manageSupervisors,
      },
      createdAt: DateTime(2026, 1, 1),
    ),
    HeadAccountRecord(
      id: '#HSUP-104',
      name: 'أ. فهد سليمان المنصور',
      email: 'head.fahad@barwah.com',
      sector: 'تجار ومتاجر',
      permissions: const {
        HeadPermission.reviewAds,
        HeadPermission.settleDisputes,
      },
      createdAt: DateTime(2026, 1, 2),
    ),
    HeadAccountRecord(
      id: '#HSUP-109',
      name: 'أ. سلطان بن حمد الخالدي',
      email: 'head.sultan@barwah.com',
      sector: 'وصلني',
      permissions: const {HeadPermission.manageSupervisors},
      suspended: true,
      suspensionReason:
          'تم تعليق الصلاحية بقرار إداري #SUS-889 لوجود تباين في تدقيق حسابات الضمان.',
      createdAt: DateTime(2026, 1, 3),
    ),
  ];

  Future<List<HeadAccountRecord>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) {
      await saveAll(defaultAccounts);
      return List.of(defaultAccounts);
    }
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid head accounts.');
    }
    return decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid head account.');
      }
      return HeadAccountRecord.fromJson(value);
    }).toList();
  }

  Future<HeadAccountRecord?> findByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    for (final account in await getAll()) {
      if (account.email.trim().toLowerCase() == normalized) return account;
    }
    return null;
  }

  Future<void> saveAll(List<HeadAccountRecord> accounts) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(accounts.map((item) => item.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save head accounts.');
    revision.value++;
  }

  /// يرجع نص الخطأ إن وُجد (بريد مكرر)، وإلا null.
  Future<String?> add(HeadAccountRecord account) async {
    final accounts = await getAll();
    final email = account.email.trim().toLowerCase();
    if (accounts.any((item) => item.email.trim().toLowerCase() == email)) {
      return 'duplicate_email';
    }
    await saveAll([account, ...accounts]);
    await _notify(account, 'تم إنشاء حسابك كرئيس مشرفين',
        'Your head-of-supervisors account was created');
    return null;
  }

  Future<String?> update(HeadAccountRecord account) async {
    final accounts = await getAll();
    final index = accounts.indexWhere((item) => item.id == account.id);
    if (index < 0) return 'not_found';
    final email = account.email.trim().toLowerCase();
    if (accounts.any((item) =>
        item.id != account.id && item.email.trim().toLowerCase() == email)) {
      return 'duplicate_email';
    }
    final before = accounts[index];
    accounts[index] = account;
    await saveAll(accounts);
    if (before.suspended != account.suspended) {
      await _notify(
        account,
        account.suspended
            ? 'تم إيقاف حسابك: ${account.suspensionReason}'
            : 'تمت إعادة تفعيل حسابك',
        account.suspended
            ? 'Your account was suspended: ${account.suspensionReason}'
            : 'Your account was reactivated',
      );
    } else {
      final changes = describeHeadChanges(before, account);
      final detail = changes.isEmpty ? '' : ' ${changes.join(' | ')}';
      await _notify(account, 'تم تحديث بيانات حسابك من الإدارة.$detail',
          'Your account details were updated by management.$detail');
    }
    return null;
  }

  Future<void> remove(String id) async {
    final accounts = await getAll();
    accounts.removeWhere((item) => item.id == id);
    await saveAll(accounts);
  }

  String nextId(List<HeadAccountRecord> accounts) {
    var max = 100;
    for (final account in accounts) {
      final digits = RegExp(r'(\d+)$').firstMatch(account.id)?.group(1);
      final value = int.tryParse(digits ?? '');
      if (value != null && value > max) max = value;
    }
    return '#HSUP-${max + 1}';
  }

  Future<void> _notify(
      HeadAccountRecord account, String messageAr, String messageEn) async {
    final now = DateTime.now();
    await LocalEventStore().publish(LocalEvent(
      id: 'admin-head-${account.id}-${now.microsecondsSinceEpoch}',
      recipient: 'head',
      source: 'admin',
      titleAr: 'إشعار من الإدارة',
      titleEn: 'Message from management',
      messageAr: messageAr,
      messageEn: messageEn,
      createdAt: now,
    ));
  }
}
