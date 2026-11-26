import 'package:dio/dio.dart';

import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';

/// ملف التاجر كما يشوفه رئيس المشرفين.
class HeadMerchantCase {
  const HeadMerchantCase({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.phone,
    required this.place,
    required this.status,
    required this.statusLabel,
    required this.supervisorName,
    required this.violation,
    required this.reviewNote,
    required this.fullDetails,
  });

  final int id;
  final String storeName;
  final String ownerName;
  final String phone;
  final String place;

  /// pending / info / active (أو working) / suspended / rejected.
  final String status;
  final String statusLabel;
  final String supervisorName;
  final String violation;
  final String reviewNote;

  /// true لو اتحمّل من تفاصيل مشرف التجار، false لو من قائمة التوزيع (بيانات أقل).
  final bool fullDetails;

  bool get isSuspended => status == 'suspended';
  bool get isRejected => status == 'rejected';
  bool get isPendingReview => status == 'pending' || status == 'info';

  /// شغال (السيرفر بيقول active أو working حسب المسار).
  bool get isActive => !isSuspended && !isRejected && !isPendingReview;

  String get displayName => storeName.isNotEmpty ? storeName : ownerName;

  factory HeadMerchantCase.fromJson(
    Map<String, dynamic> j, {
    required bool fullDetails,
  }) {
    String s(Object? v) {
      final t = '${v ?? ''}'.trim();
      return t == 'null' ? '' : t;
    }

    final place = s(j['place']).isNotEmpty
        ? s(j['place'])
        : [s(j['city']), s(j['governorate'])].where((e) => e.isNotEmpty).join(' - ');
    final violation = [s(j['violationType']), s(j['violationDescription'])]
        .where((e) => e.isNotEmpty)
        .join(' - ');
    return HeadMerchantCase(
      id: (j['id'] as num?)?.toInt() ?? 0,
      storeName: s(j['storeName']),
      ownerName: s(j['ownerName']),
      phone: s(j['phone']).isNotEmpty ? s(j['phone']) : s(j['phoneNumber']),
      place: place,
      status: s(j['status']),
      statusLabel: s(j['statusLabel']),
      supervisorName: s(j['supervisorName']),
      violation: violation,
      reviewNote: s(j['reviewNote']),
      fullDetails: fullDetails,
    );
  }
}

/// رفض من السيرفر برسالة جاهزة للعرض.
class HeadMerchantActionRejection implements Exception {
  const HeadMerchantActionRejection(this.message, {this.forbidden = false});
  final String message;

  /// السيرفر رفض الدور نفسه (403) مش البيانات.
  final bool forbidden;

  @override
  String toString() => message;
}

/// إجراءات رئيس المشرفين على تاجر وصل له في تصعيد أو من شاشة التوزيع.
///
/// Swagger مفيهوش endpoint لرئيس المشرفين يوقف/يفعّل تاجر، فبنستخدم نفس
/// مسارات `api/supervisor/merchant`. لو السيرفر رفض الدور (403) بنقول ده صراحة.
class HeadMerchantActionsApi {
  HeadMerchantActionsApi({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static const forbiddenMessage =
      'السيرفر لسه مش سامح لرئيس المشرفين بالإجراء ده على التاجر. '
      'لازم الباك إند يضيف دور BossOfSupervisor على مسارات api/supervisor/merchant.';

  /// تفاصيل التاجر: من مسار مشرف التجار، ولو الدور مرفوض نرجع لقائمة التوزيع.
  Future<HeadMerchantCase> load(int merchantId) async {
    try {
      final response =
          await apiConsumer.get<Object>(ApiEndpoints.merchantDetails(merchantId));
      final data = _map(_map(response.data)['data']);
      if (data.isNotEmpty) {
        return HeadMerchantCase.fromJson(
          {'id': merchantId, ...data},
          fullDetails: true,
        );
      }
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code != 401 && code != 403 && code != 404) rethrow;
    }
    return _fromAssignment(merchantId);
  }

  Future<HeadMerchantCase> _fromAssignment(int merchantId) async {
    final response = await _send(() => apiConsumer.get<Object>(
          ApiEndpoints.bossMerchantAssignment,
          queryParameters: {'filter': 'all'},
        ));
    final rows = _map(_map(response.data)['data'])['merchants'];
    if (rows is List) {
      for (final row in rows) {
        if (row is Map && (row['id'] as num?)?.toInt() == merchantId) {
          return HeadMerchantCase.fromJson(
            Map<String, dynamic>.from(row),
            fullDetails: false,
          );
        }
      }
    }
    throw const HeadMerchantActionRejection('التاجر مش موجود في قائمة التجار.');
  }

  Future<String> suspend(
    int merchantId, {
    required String violationType,
    String? description,
    int? days,
  }) =>
      _message(() => apiConsumer.post<Object>(
            ApiEndpoints.merchantSuspend(merchantId),
            data: {
              'violationType': violationType,
              'violationDescription': description,
              'days': days,
            },
          ));

  Future<String> reactivate(int merchantId, {String? note}) =>
      _message(() => apiConsumer.post<Object>(
            ApiEndpoints.merchantReactivate(merchantId),
            data: {'note': note},
          ));

  Future<String> _message(Future<Response<Object>> Function() call) async {
    final response = await _send(call);
    return '${_map(response.data)['message'] ?? ''}'.trim();
  }

  Future<Response<Object>> _send(Future<Response<Object>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        throw const HeadMerchantActionRejection(forbiddenMessage, forbidden: true);
      }
      final body = error.response?.data;
      final message = body is Map ? '${body['message'] ?? ''}'.trim() : '';
      if (message.isNotEmpty) throw HeadMerchantActionRejection(message);
      rethrow;
    }
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}
