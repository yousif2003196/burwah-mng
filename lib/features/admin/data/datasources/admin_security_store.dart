import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/security/password_hasher.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_login_attempt.dart';

/// أمان حساب الأدمن محليًا: كلمة المرور، رمز التحقق الثاني (PIN)، القفل بعد
/// المحاولات الفاشلة، مهلة الخمول، وسجل محاولات الدخول.
///
/// تُحفظ كلمة المرور والرمز كبصمة SHA-256 مملّحة وليس كنص صريح. هذا حل مؤقت
/// حتى يتولى الخادم المصادقة.
class AdminSecurityStore {
  static const _storageKey = 'admin_security_v1';
  static const _logKey = 'admin_login_log_v1';
  static const maxFailedAttempts = 5;
  static const lockDuration = Duration(minutes: 15);
  static const _defaultPassword = 'Admin@2026';
  static const _defaultPin = '123456';
  static const _maxLogEntries = 100;

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<Map<String, dynamic>> _read() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded != null) {
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic> &&
          decoded['passwordSalt'] is String &&
          decoded['passwordHash'] is String &&
          decoded['pinSalt'] is String &&
          decoded['pinHash'] is String) {
        return decoded;
      }
      // بيانات قديمة أو تالفة: نعيد الإعدادات الافتراضية بدل أن يفشل الدخول.
    }
    final salt = PasswordHasher.newSalt();
    final pinSalt = PasswordHasher.newSalt();
    final fresh = <String, dynamic>{
      'passwordSalt': salt,
      'passwordHash': PasswordHasher.hash(_defaultPassword, salt),
      'defaultPassword': true,
      'pinSalt': pinSalt,
      'pinHash': PasswordHasher.hash(_defaultPin, pinSalt),
      'defaultPin': true,
      'twoFactor': true,
      'idleMinutes': 10,
      'failed': 0,
      'lockedUntil': null,
    };
    await _write(fresh, notify: false);
    return fresh;
  }

  Future<void> _write(Map<String, dynamic> data, {bool notify = true}) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_storageKey, jsonEncode(data));
    if (!saved) throw StateError('Could not save admin security settings.');
    if (notify) revision.value++;
  }

  Future<bool> verifyPassword(String password) async {
    final data = await _read();
    return PasswordHasher.hash(password, data['passwordSalt'] as String) ==
        data['passwordHash'];
  }

  Future<bool> verifyPin(String pin) async {
    final data = await _read();
    // ما دام الرمز لم يُغيَّر فالرمز الافتراضي مقبول دائمًا (يحمي من بيانات قديمة).
    if ((data['defaultPin'] as bool? ?? false) && pin == _defaultPin) return true;
    return PasswordHasher.hash(pin, data['pinSalt'] as String) == data['pinHash'];
  }

  Future<void> setPassword(String password) async {
    final data = await _read();
    final salt = PasswordHasher.newSalt();
    data['passwordSalt'] = salt;
    data['passwordHash'] = PasswordHasher.hash(password, salt);
    data['defaultPassword'] = false;
    await _write(data);
  }

  Future<void> setPin(String pin) async {
    final data = await _read();
    final salt = PasswordHasher.newSalt();
    data['pinSalt'] = salt;
    data['pinHash'] = PasswordHasher.hash(pin, salt);
    data['defaultPin'] = false;
    await _write(data);
  }

  Future<bool> usesDefaultCredentials() async {
    final data = await _read();
    return (data['defaultPassword'] as bool? ?? false) ||
        (data['defaultPin'] as bool? ?? false);
  }

  Future<bool> twoFactorEnabled() async =>
      (await _read())['twoFactor'] as bool? ?? true;

  Future<void> setTwoFactor(bool enabled) async {
    final data = await _read();
    data['twoFactor'] = enabled;
    await _write(data);
  }

  Future<int> idleMinutes() async =>
      ((await _read())['idleMinutes'] as num?)?.toInt() ?? 10;

  Future<void> setIdleMinutes(int minutes) async {
    final data = await _read();
    data['idleMinutes'] = minutes;
    await _write(data);
  }

  /// المدة المتبقية على القفل، أو null إن لم يكن الحساب مقفلًا.
  Future<Duration?> lockRemaining() async {
    final data = await _read();
    final raw = data['lockedUntil'] as String?;
    if (raw == null) return null;
    final until = DateTime.tryParse(raw);
    if (until == null) return null;
    final remaining = until.difference(DateTime.now());
    if (remaining.isNegative || remaining == Duration.zero) {
      data['lockedUntil'] = null;
      data['failed'] = 0;
      await _write(data, notify: false);
      return null;
    }
    return remaining;
  }

  /// يسجل محاولة. عند الفشل المتكرر يقفل الحساب. يرجع عدد المحاولات المتبقية
  /// قبل القفل (null عند النجاح أو القفل).
  Future<int?> recordAttempt(
    String email, {
    required bool success,
    required String note,
  }) async {
    final data = await _read();
    int? remaining;
    if (success) {
      data['failed'] = 0;
      data['lockedUntil'] = null;
    } else {
      final failed = ((data['failed'] as num?)?.toInt() ?? 0) + 1;
      data['failed'] = failed;
      if (failed >= maxFailedAttempts) {
        data['lockedUntil'] = DateTime.now().add(lockDuration).toIso8601String();
      } else {
        remaining = maxFailedAttempts - failed;
      }
    }
    await _write(data, notify: false);
    await _appendLog(AdminLoginAttempt(
      email: email,
      success: success,
      note: note,
      at: DateTime.now(),
    ));
    return remaining;
  }

  Future<List<AdminLoginAttempt>> getLog() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_logKey);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AdminLoginAttempt.fromJson)
        .toList()
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  Future<void> _appendLog(AdminLoginAttempt attempt) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = List<AdminLoginAttempt>.of(await getLog());
    entries.insert(0, attempt);
    final trimmed = entries.take(_maxLogEntries).toList();
    await preferences.setString(
      _logKey,
      jsonEncode(trimmed.map((item) => item.toJson()).toList()),
    );
    revision.value++;
  }

  /// قواعد كلمة المرور: 8 أحرف على الأقل، حرف ورقم.
  static String? validatePassword(String value) {
    if (value.length < 8) return 'short';
    if (!RegExp(r'[A-Za-z؀-ۿ]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value)) {
      return 'weak';
    }
    return null;
  }
}
