import 'package:barwah_app/core/realtime/realtime_hub.dart';

/// جلسة الدخول الحالية (توكن الباك إند) محفوظة في الذاكرة فقط.
///
/// تُملأ عند تسجيل دخول ناجح من الباك إند وتُمسح عند الخروج، وتقرأها
/// طبقة الشبكة لإضافة `Authorization: Bearer` لكل طلب.
class AuthSession {
  AuthSession._();

  static String? accessToken;
  static String? refreshToken;

  /// بيانات الحساب الحالي (من رد تسجيل الدخول).
  static String name = '';
  static String email = '';
  static String backendRole = '';

  /// يُستدعى عند انتهاء الجلسة نهائيًا (فشل تجديد التوكن) للعودة لشاشة الدخول.
  static void Function()? onExpired;

  static void notifyExpired() => onExpired?.call();

  static bool get isSignedIn => (accessToken ?? '').trim().isNotEmpty;

  static void start({
    required String token,
    String? refresh,
    String name = '',
    String email = '',
    String backendRole = '',
  }) {
    AuthSession.name = name;
    AuthSession.email = email;
    AuthSession.backendRole = backendRole;
    accessToken = token;
    refreshToken = refresh;
    // إشعارات ومحادثات لحظية.
    RealtimeHub.instance.start();
  }

  static void clear() {
    accessToken = null;
    refreshToken = null;
    name = '';
    email = '';
    backendRole = '';
    RealtimeHub.instance.stop();
  }

  static Future<String?> tokenProvider() async => accessToken;
}
