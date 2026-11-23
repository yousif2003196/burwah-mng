import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';

/// يبلّغ السيرفر إن المشرف فتح عنصر (من الشاشات اللي مش بتطلب تفاصيله من السيرفر)،
/// ومنه بيبدأ حساب وقت المراجعة لحد قراره. بيشتغل في الخلفية ومش بيوقف الشاشة.
class ReviewTimer {
  ReviewTimer._();

  static const _roles = {
    'SupervisorForAd',
    'SupervisorForMerchant',
    'SupervisorForServices',
    'SupervisorUsed',
    'Accountant',
  };

  /// [type]: ad / ticket / service / provider / merchant / order / wasalny / topup / withdrawal.
  /// [reference]: الرقم أو مرجع فيه الرقم (SRV-12، AD-5، srv-wd-7، #TCK-3).
  static void open(String type, Object? reference) {
    if (!AuthSession.isSignedIn || !_roles.contains(AuthSession.backendRole)) return;
    final match = RegExp(r'(\d+)').allMatches('${reference ?? ''}').lastOrNull;
    final id = match == null ? null : int.tryParse(match.group(1)!);
    if (id == null || id <= 0) return;
    sl<ApiConsumer>(instanceName: 'berwah')
        .post<Object>('api/ReviewTimer/open', data: {'type': type, 'id': id})
        .then((_) {}, onError: (_) {});
  }
}
