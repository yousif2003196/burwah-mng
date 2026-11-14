import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// توكنات الجلسة محفوظة في التخزين الآمن للنظام (Keychain على iOS، وKeystore
/// على أندرويد) لتبقى الجلسة بعد إغلاق التطبيق.
class AuthTokenStore {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// يرجع null لو لا يوجد توكن وصول محفوظ.
  Future<({String accessToken, String refreshToken})?> read() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null || accessToken.isEmpty) return null;
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    return (accessToken: accessToken, refreshToken: refreshToken ?? '');
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
