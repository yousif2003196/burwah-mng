import 'package:dio/dio.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';

/// نداءات مشرف التجار على `api/supervisor/merchant`. كل الأرقام بالجنيه المصري.
class MerchantsApi {
  MerchantsApi._();

  static ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

  static Map<String, dynamic> _map(Object? body) =>
      body is Map<String, dynamic> ? body : const {};

  /// رسالة الخطأ اللي رجّعها السيرفر (أو نص عام).
  static String messageOf(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && '${data['message'] ?? ''}'.trim().isNotEmpty) {
        return '${data['message']}';
      }
    }
    return 'تعذر تنفيذ العملية، حاول مرة أخرى';
  }

  static Future<Map<String, dynamic>> stats() async {
    final r = await _api.get<Object>(ApiEndpoints.merchantStats);
    return Map<String, dynamic>.from(_map(r.data)['data'] as Map? ?? const {});
  }

  /// صفحة من التجار. [status]: all / pending / info / rejected / suspended / active.
  static Future<List<Map<String, dynamic>>> merchants({
    String status = 'all',
    String? search,
    int page = 1,
    int pageSize = 100,
  }) async {
    final r = await _api.get<Object>(
      ApiEndpoints.merchantList,
      queryParameters: {
        'status': status,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = _map(r.data)['data'];
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map) Map<String, dynamic>.from(row),
    ];
  }

  static Future<Map<String, dynamic>> details(int id) async {
    final r = await _api.get<Object>(ApiEndpoints.merchantDetails(id));
    return Map<String, dynamic>.from(_map(r.data)['data'] as Map? ?? const {});
  }

  static Future<void> approve(int id, {String? note}) =>
      _api.post<Object>(ApiEndpoints.merchantApprove(id), data: {'note': note});

  static Future<void> reject(int id, String reason) =>
      _api.post<Object>(ApiEndpoints.merchantReject(id), data: {'reason': reason});

  static Future<void> requestInfo(int id, String note) =>
      _api.post<Object>(ApiEndpoints.merchantRequestInfo(id), data: {'reason': note});

  static Future<void> suspend(
    int id, {
    required String violationType,
    String? description,
    int? days,
  }) =>
      _api.post<Object>(
        ApiEndpoints.merchantSuspend(id),
        data: {
          'violationType': violationType,
          'violationDescription': description,
          'days': days,
        },
      );

  static Future<void> reactivate(int id, {String? note}) =>
      _api.post<Object>(ApiEndpoints.merchantReactivate(id), data: {'note': note});

  /// [percent] = null يرجّع التاجر للنسبة العامة.
  static Future<void> commission(int id, double? percent) =>
      _api.post<Object>(ApiEndpoints.merchantCommission(id), data: {'percent': percent});

  static Future<void> hideProduct(int productId, String reason) =>
      _api.post<Object>(ApiEndpoints.merchantProductHide(productId), data: {'reason': reason});

  static Future<void> showProduct(int productId) =>
      _api.post<Object>(ApiEndpoints.merchantProductShow(productId), data: {});

  static Future<List<Map<String, dynamic>>> orders(int id) async {
    final r = await _api.get<Object>(ApiEndpoints.merchantOrders(id));
    final data = _map(r.data)['data'];
    return data is List ? [for (final e in data) if (e is Map) Map<String, dynamic>.from(e)] : const [];
  }

  /// [status]: 0 = قيد المراجعة، 1 = تم، 2 = مرفوض، null = الكل.
  static Future<List<Map<String, dynamic>>> withdrawals({int? status = 0}) async {
    final r = await _api.get<Object>(
      ApiEndpoints.merchantWithdrawals,
      queryParameters: {if (status != null) 'status': status},
    );
    final data = _map(r.data)['data'];
    return data is List ? [for (final e in data) if (e is Map) Map<String, dynamic>.from(e)] : const [];
  }

  static Future<void> recommendWithdrawal(int id, {String? note}) =>
      _api.post<Object>(ApiEndpoints.merchantWithdrawalRecommend(id), data: {'note': note});

  static Future<List<Map<String, dynamic>>> events({int take = 100}) async {
    final r = await _api.get<Object>(ApiEndpoints.merchantEvents, queryParameters: {'take': take});
    final data = _map(r.data)['data'];
    return data is List ? [for (final e in data) if (e is Map) Map<String, dynamic>.from(e)] : const [];
  }
}
