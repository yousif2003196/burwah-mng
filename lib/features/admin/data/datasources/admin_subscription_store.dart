import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/admin/domain/entities/admin_subscription.dart';

/// اشتراكات المنظومة محليًا حتى يتوفر الـ backend.
class AdminSubscriptionStore {
  static const _storageKey = 'admin_subscriptions_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static final defaults = <AdminSubscription>[
    AdminSubscription(
      id: 'sub-apple',
      title: 'Apple App Store (Developer)',
      type: 'حساب متجر',
      cost: '99 دولار / سنة',
      renewalDate: DateTime(2026, 11, 3),
    ),
    AdminSubscription(
      id: 'sub-maps',
      title: 'خرائط وتتبع الموقع المباشر',
      type: 'مفتاح API',
      renewalDate: DateTime(2026, 11, 15),
    ),
    AdminSubscription(
      id: 'sub-hosting',
      title: 'السيرفرات والاستضافة السحابية',
      type: 'استضافة',
      renewalDate: DateTime(2026, 11, 21),
      periodMonths: 1,
    ),
    AdminSubscription(
      id: 'sub-play',
      title: 'Google Play Console',
      type: 'حساب متجر',
      renewalDate: DateTime(2027, 3, 1),
    ),
    AdminSubscription(
      id: 'sub-gateways',
      title: 'مفاتيح بوابات الدفع',
      type: 'مفتاح API',
      renewalDate: DateTime(2027, 3, 15),
    ),
  ];

  Future<List<AdminSubscription>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) {
      await saveAll(defaults);
      return List.of(defaults);
    }
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid subscriptions.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AdminSubscription.fromJson)
        .toList()
      ..sort((a, b) => a.renewalDate.compareTo(b.renewalDate));
  }

  Future<void> saveAll(List<AdminSubscription> items) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
        _storageKey, jsonEncode(items.map((e) => e.toJson()).toList()));
    if (!saved) throw StateError('Could not save subscriptions.');
    revision.value++;
  }

  Future<void> add(AdminSubscription item) async =>
      saveAll([...await getAll(), item]);

  Future<void> markRenewed(String id) async {
    final items = await getAll();
    final index = items.indexWhere((e) => e.id == id);
    if (index < 0) return;
    items[index] = items[index].renewed();
    await saveAll(items);
  }

  Future<void> remove(String id) async {
    final items = await getAll()
      ..removeWhere((e) => e.id == id);
    await saveAll(items);
  }
}
