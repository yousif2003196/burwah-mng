import 'dart:convert';

/// قراءة بيانات حمولة JWT (بدون التحقق من التوقيع، فالتحقق مسؤولية السيرفر).
///
/// تُستخدم لمعرفة دور الحساب عندما يرجع `LoginForSupervisor` دورًا عامًا مثل
/// `Supervisor`، ولمعرفة انتهاء صلاحية التوكن عند استعادة جلسة محفوظة.
class JwtClaims {
  const JwtClaims._(this._payload);

  final Map<String, dynamic> _payload;

  /// مفتاح الدور الذي يضعه ASP.NET Identity في التوكن.
  static const _aspNetRoleClaim =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

  /// يرجع `null` لو التوكن ليس JWT صالح الشكل.
  static JwtClaims? tryParse(String token) {
    final parts = token.trim().split('.');
    if (parts.length != 3 || parts[1].isEmpty) return null;
    try {
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payload = jsonDecode(decoded);
      if (payload is! Map<String, dynamic>) return null;
      return JwtClaims._(payload);
    } on FormatException {
      return null;
    }
  }

  /// كل الأدوار المذكورة في التوكن، بالترتيب.
  List<String> get roles {
    final roles = <String>[];
    for (final key in const [_aspNetRoleClaim, 'role', 'roles']) {
      final value = _payload[key];
      if (value is String && value.trim().isNotEmpty) {
        roles.add(value.trim());
      } else if (value is List) {
        roles.addAll(
          value.map((role) => '$role'.trim()).where((role) => role.isNotEmpty),
        );
      }
    }
    return roles;
  }

  /// وقت انتهاء الصلاحية من `exp` (ثوانٍ منذ 1970 بتوقيت UTC).
  DateTime? get expiresAt {
    final exp = _payload['exp'];
    final seconds = exp is num ? exp.toInt() : int.tryParse('$exp');
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  bool isExpiredAt(DateTime now) {
    final expiry = expiresAt;
    return expiry != null && !now.toUtc().isBefore(expiry);
  }
}
