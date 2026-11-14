import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/auth/data/models/session_user_model.dart';

/// بيانات حساب الجلسة الحالية غير الحساسة (بدون توكنات) في SharedPreferences.
class SessionUserStore {
  static const _key = 'auth_session_user_v1';

  Future<void> save(SessionUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(_key, jsonEncode(user.toJson()));
    if (!ok) throw StateError('Could not save the session user.');
  }

  /// يرجع null لو لا توجد جلسة محفوظة.
  Future<SessionUserModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return null;
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid saved session user.');
    }
    return SessionUserModel.fromJson(decoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
