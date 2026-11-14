import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// معرّف ثابت لهذا الجهاز يُرسل في ترويسة `X-Device-Id` لتتبّع الجلسات.
///
/// يُولَّد مرة واحدة (UUID v4 من مولّد عشوائي آمن) ويُحفظ في
/// SharedPreferences، فيبقى كما هو بين مرات التشغيل حتى حذف بيانات التطبيق.
class DeviceIdStore {
  static const _key = 'device_id_v1';
  static final _uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  Future<String>? _deviceId;

  /// يرجع المعرّف المحفوظ، ويولّده ويحفظه في أول استدعاء.
  Future<String> read() {
    final cached = _deviceId;
    if (cached != null) return cached;
    final loading = _loadOrCreate();
    _deviceId = loading;
    // لو تعذّرت القراءة أو الحفظ نسمح بإعادة المحاولة مع الطلب التالي.
    loading.then<void>((_) {}, onError: (Object error) {
      _deviceId = null;
    });
    return loading;
  }

  Future<String> _loadOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null && _uuidV4.hasMatch(stored)) return stored;

    final created = _generateUuidV4();
    if (!await prefs.setString(_key, created)) {
      throw StateError('Could not save the device id.');
    }
    return created;
  }

  /// UUID v4 حسب RFC 4122.
  static String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // الإصدار 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // متغيّر RFC 4122
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
