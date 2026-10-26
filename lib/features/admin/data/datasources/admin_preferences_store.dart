import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// قناة دفع أو بنك مركزي كما تظهر للأدمن. للقنوات الافتراضية يكون
/// [title]/[subtitle] فارغين ما لم يعدّلهما الأدمن (النص الافتراضي في الشاشة).
typedef AdminChannelEntry = ({
  String key,
  String title,
  String subtitle,
  bool isDefault,
  bool enabled,
});

/// تفضيلات الأدمن المحلية: التنبيهات وقنوات الدفع.
class AdminPreferencesStore {
  static const _alertsKey = 'admin_urgent_alerts_v1';
  static const _channelsKey = 'admin_payment_channels_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static const defaultChannels = <String>['rajhi', 'ahli', 'sarie', 'gateways'];

  Future<bool> urgentAlerts() async =>
      (await SharedPreferences.getInstance()).getBool(_alertsKey) ?? true;

  Future<void> setUrgentAlerts(bool value) async {
    final saved =
        await (await SharedPreferences.getInstance()).setBool(_alertsKey, value);
    if (!saved) throw StateError('Could not save admin preferences.');
    revision.value++;
  }

  /// حالة تفعيل قنوات الدفع (المفتاح → مفعّل) + القنوات المضافة يدويًا.
  Future<Map<String, dynamic>> _readChannels() async {
    final encoded =
        (await SharedPreferences.getInstance()).getString(_channelsKey);
    Map<String, dynamic> empty() => {
          'enabled': <String, dynamic>{},
          'custom': <dynamic>[],
          'overrides': <String, dynamic>{},
          'removed': <dynamic>[],
        };
    if (encoded == null) return empty();
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) return empty();
    return {
      'enabled': decoded['enabled'] is Map<String, dynamic> ? decoded['enabled'] : <String, dynamic>{},
      'custom': decoded['custom'] is List ? decoded['custom'] : <dynamic>[],
      'overrides': decoded['overrides'] is Map<String, dynamic> ? decoded['overrides'] : <String, dynamic>{},
      'removed': decoded['removed'] is List ? decoded['removed'] : <dynamic>[],
    };
  }

  Future<void> _writeChannels(Map<String, dynamic> data) async {
    final saved = await (await SharedPreferences.getInstance())
        .setString(_channelsKey, jsonEncode(data));
    if (!saved) throw StateError('Could not save payment channels.');
    revision.value++;
  }

  Future<Map<String, bool>> channelStates() async {
    final data = await _readChannels();
    final enabled = data['enabled'] as Map<String, dynamic>;
    final custom = (data['custom'] as List).whereType<Map<String, dynamic>>();
    return {
      for (final key in defaultChannels) key: enabled[key] as bool? ?? true,
      for (final item in custom)
        item['key'] as String: enabled[item['key']] as bool? ?? true,
    };
  }

  Future<void> setChannel(String key, bool value) async {
    final data = await _readChannels();
    (data['enabled'] as Map<String, dynamic>)[key] = value;
    await _writeChannels(data);
  }

  /// قنوات أضافها الأدمن: [{key,title,subtitle}].
  Future<List<({String key, String title, String subtitle})>> customChannels() async {
    final data = await _readChannels();
    return [
      for (final item in (data['custom'] as List).whereType<Map<String, dynamic>>())
        (
          key: item['key'] as String? ?? '',
          title: item['title'] as String? ?? '',
          subtitle: item['subtitle'] as String? ?? '',
        ),
    ];
  }

  static const _capKey = 'admin_finance_approval_cap_v1';

  /// سقف اعتماد المشرف المالي المباشر بالجنيه (0 = بلا سقف). ما فوقه يُرفع للأدمن.
  Future<double> financeApprovalCap() async =>
      (await SharedPreferences.getInstance()).getDouble(_capKey) ?? 0;

  Future<void> setFinanceApprovalCap(double value) async {
    final saved = await (await SharedPreferences.getInstance())
        .setDouble(_capKey, value < 0 ? 0 : value);
    if (!saved) throw StateError('Could not save the finance approval cap.');
    revision.value++;
  }

  Future<void> addChannel(String title, String subtitle) async {
    final data = await _readChannels();
    (data['custom'] as List).add({
      'key': 'custom-${DateTime.now().microsecondsSinceEpoch}',
      'title': title,
      'subtitle': subtitle,
    });
    await _writeChannels(data);
  }

  /// كل القنوات والبنوك الظاهرة (الافتراضية غير المحذوفة ثم المضافة).
  Future<List<AdminChannelEntry>> channels() async {
    final data = await _readChannels();
    final enabled = data['enabled'] as Map<String, dynamic>;
    final overrides = data['overrides'] as Map<String, dynamic>;
    final removed = (data['removed'] as List).whereType<String>().toSet();
    final custom = (data['custom'] as List).whereType<Map<String, dynamic>>();
    return [
      for (final key in defaultChannels)
        if (!removed.contains(key))
          (
            key: key,
            title: (overrides[key] as Map?)?['title'] as String? ?? '',
            subtitle: (overrides[key] as Map?)?['subtitle'] as String? ?? '',
            isDefault: true,
            enabled: enabled[key] as bool? ?? true,
          ),
      for (final item in custom)
        (
          key: item['key'] as String? ?? '',
          title: item['title'] as String? ?? '',
          subtitle: item['subtitle'] as String? ?? '',
          isDefault: false,
          enabled: enabled[item['key']] as bool? ?? true,
        ),
    ];
  }

  /// تعديل اسم ووصف قناة (افتراضية أو مضافة). الاسم مطلوب.
  Future<void> updateChannel(String key, String title, String subtitle) async {
    final name = title.trim();
    if (name.isEmpty) throw ArgumentError('A channel name is required.');
    final data = await _readChannels();
    final custom = data['custom'] as List;
    final index =
        custom.indexWhere((e) => e is Map && e['key'] == key);
    if (index >= 0) {
      custom[index] = {
        ...(custom[index] as Map<String, dynamic>),
        'title': name,
        'subtitle': subtitle.trim(),
      };
    } else if (defaultChannels.contains(key)) {
      (data['overrides'] as Map<String, dynamic>)[key] = {
        'title': name,
        'subtitle': subtitle.trim(),
      };
    } else {
      throw StateError('Unknown channel.');
    }
    await _writeChannels(data);
  }

  /// حذف قناة. الافتراضية تُخفى ويمكن استعادتها، والمضافة تُحذف نهائيًا.
  Future<void> removeChannel(String key) async {
    final data = await _readChannels();
    final custom = data['custom'] as List;
    final before = custom.length;
    custom.removeWhere((e) => e is Map && e['key'] == key);
    if (custom.length == before && defaultChannels.contains(key)) {
      final removed = data['removed'] as List;
      if (!removed.contains(key)) removed.add(key);
    }
    (data['enabled'] as Map<String, dynamic>).remove(key);
    await _writeChannels(data);
  }

  Future<bool> hasRemovedDefaultChannels() async =>
      ((await _readChannels())['removed'] as List).isNotEmpty;

  /// يعيد القنوات الافتراضية المحذوفة (بأسمائها الحالية).
  Future<void> restoreDefaultChannels() async {
    final data = await _readChannels();
    (data['removed'] as List).clear();
    await _writeChannels(data);
  }
}
