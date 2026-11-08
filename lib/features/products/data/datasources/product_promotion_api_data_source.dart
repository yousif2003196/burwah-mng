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

  Future<void> approve(String id) => _post('$_basePath/$id/Approve');

  Future<void> reject(String id, {String? reason}) => _post(
        '$_basePath/$id/Reject',
        data: {'reason': (reason ?? '').trim()},
      );

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
      durationDays: isVip ? 5 : 2,
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
