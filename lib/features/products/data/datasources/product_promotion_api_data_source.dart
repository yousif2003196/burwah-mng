import 'package:dio/dio.dart';

import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/features/products/domain/entities/product_promotion_request.dart';

/// طلبات ترويج الإعلانات (Featured / VIP) من الباك إند.
///
/// - GET  api/AdPromotion/All
/// - POST api/AdPromotion/{id}/Approve
/// - POST api/AdPromotion/{id}/Reject بجسم { "reason": "..." }
///
/// الباك إند لا يدعم تعليق الترويج أو إعادته بعد التفعيل، ولا الانتهاء اليدوي.
class ProductPromotionApiDataSource {
  ProductPromotionApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static const _basePath = 'api/AdPromotion';

  Future<List<ProductPromotionRequest>> load() async {
    final response = await apiConsumer.get<Object>('$_basePath/All');
    final body = response.data;
    if (body is! Map<String, dynamic> || body['data'] is! List<dynamic>) {
      throw const FormatException('AdPromotion/All: data must be a list.');
    }
    final requests = <ProductPromotionRequest>[
      for (final item in body['data'] as List<dynamic>)
        if (item is Map<String, dynamic>) _fromJson(item),
    ];
    return List.unmodifiable(requests);
  }

  /// حد إعلانات VIP في البنر وعدد الجاري والمنتظر (GET api/AdPromotion/Settings).
  Future<({int limit, int running, int waiting})> loadVipSettings() async {
    final response = await apiConsumer.get<Object>('$_basePath/Settings');
    final body = response.data;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('AdPromotion/Settings: data must be an object.');
    }
    return (
      limit: (data['maxVipAds'] as num?)?.toInt() ?? 0,
      running: (data['running'] as num?)?.toInt() ?? 0,
      waiting: (data['waiting'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> saveVipLimit(int limit) async {
    try {
      await apiConsumer.put<Object>('$_basePath/Settings', data: {'maxVipAds': limit});
    } on DioException catch (error) {
      throw StateError('Could not save the VIP limit (${error.response?.statusCode ?? 'network'}).');
    }
  }

  Future<void> approve(String id) => _post('$_basePath/$id/Approve');

  Future<void> reject(String id, {String? reason}) => _post(
        '$_basePath/$id/Reject',
        data: {'reason': (reason ?? '').trim()},
      );

  /// POST api/AdPromotion/{id}/Suspend — يوقف باقة سارية ويرجع المبلغ المردود للمحفظة.
  Future<double> suspend(String id, {required String reason, required bool refund}) async {
    try {
      final response = await apiConsumer.post<Object>(
        '$_basePath/$id/Suspend',
        data: {'reason': reason.trim(), 'refund': refund},
      );
      final body = response.data;
      return body is Map<String, dynamic>
          ? (body['refunded'] as num?)?.toDouble() ?? 0
          : 0;
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map<String, dynamic> ? '${data['message'] ?? ''}' : '';
      throw StateError(message.isEmpty
          ? 'Promotion suspend failed (${error.response?.statusCode ?? 'network'}).'
          : message);
    }
  }

  /// POST api/AdPromotionOffer/Purchase/{id} — المشرف يقترح مدة وسعرًا إجماليًا جديدًا.
  Future<void> sendOffer(String purchaseId,
      {required int days, required double price, String? note}) async {
    await _postWithMessage('api/AdPromotionOffer/Purchase/$purchaseId',
        {'days': days, 'price': price, 'note': (note ?? '').trim()});
  }

  /// POST api/AdPromotionOffer/{offerId}/Supervisor — قبول/رفض العرض المضاد من العميل.
  Future<void> answerCounter(String offerId, {required bool accept}) async {
    await _postWithMessage('api/AdPromotionOffer/$offerId/Supervisor',
        {'action': accept ? 'accept' : 'reject'});
  }

  Future<void> _postWithMessage(String path, Object data) async {
    try {
      await apiConsumer.post<Object>(path, data: data);
    } on DioException catch (error) {
      final body = error.response?.data;
      final message = body is Map<String, dynamic> ? '${body['message'] ?? ''}' : '';
      throw StateError(message.isEmpty
          ? 'Request failed (${error.response?.statusCode ?? 'network'}).'
          : message);
    }
  }

  static ProductPromotionOffer? _offerFrom(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    return ProductPromotionOffer(
      id: '${raw['id']}',
      fromUser: '${raw['side']}' == 'User',
      status: '${raw['status']}',
      days: (raw['days'] as num?)?.toInt() ?? 0,
      price: (raw['price'] as num?)?.toDouble() ?? 0,
      note: (raw['note'] as String?)?.trim().isEmpty ?? true ? null : raw['note'] as String,
      round: (raw['round'] as num?)?.toInt() ?? 0,
      expiresAt: DateTime.tryParse('${raw['expiresAt']}')?.toLocal(),
    );
  }

  Future<void> _post(String path, {Object? data}) async {
    try {
      await apiConsumer.post<Object>(path, data: data ?? const {});
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw StateError(
        status == 404
            ? 'Promotion request was already reviewed or not found.'
            : 'Promotion request failed (${status ?? 'network'}).',
      );
    }
  }

  static ProductPromotionRequest _fromJson(Map<String, dynamic> json) {
    final plan = '${json['plan'] ?? ''}'.toLowerCase();
    final isVip = plan == 'vip';
    final title = '${json['adTitle'] ?? ''}'.trim();
    final seller = '${json['userName'] ?? ''}'.trim();
    final method = '${json['paymentMethod'] ?? ''}';
    final reference = '${json['paymentReference'] ?? ''}'.trim();
    return ProductPromotionRequest(
      id: '${json['id']}',
      adReference: 'AD-${json['advertismentId']}',
      productNameAr: title,
      productNameEn: title,
      merchantNameAr: seller.isEmpty ? 'مستخدم' : seller,
      merchantNameEn: seller.isEmpty ? 'User' : seller,
      packageKey: isVip ? 'premium' : 'featured',
      durationDays: (json['days'] as num?)?.toInt() ?? (isVip ? 5 : 2),
      offer: _offerFrom(json['offer']),
      price: (json['amount'] as num?)?.round() ?? 0,
      requestedAt: DateTime.tryParse('${json['createdAt']}')?.toLocal() ??
          DateTime.now(),
      // الدفع يراجعه المشرف من المرجع المعروض؛ ربط المالية لاحقًا.
      paymentConfirmedByFinance: true,
      status: switch ('${json['status']}'.toLowerCase()) {
        'approved' => ProductPromotionStatus.active,
        'rejected' => ProductPromotionStatus.rejected,
        _ => ProductPromotionStatus.pending,
      },
      adWaiting: json['adWaiting'] == true,
      paymentNote: [
        _methodLabel(method),
        if (reference.isNotEmpty) reference,
      ].join(' • '),
    );
  }

  static String _methodLabel(String method) => switch (method) {
        'Card' => 'بطاقة',
        'EWallet' => 'محفظة إلكترونية',
        'InstaPay' => 'إنستا باي',
        'Wallet' => 'من رصيد المحفظة',
        _ => method,
      };
}
