import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/features/products/domain/entities/vip_banner.dart';

/// بنرات قسم VIP (api/VipBanner). الإضافة والتعديل والحذف لمشرف المنتجات والأدمن فقط.
class VipBannerApiDataSource {
  VipBannerApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static const _basePath = 'api/VipBanner';

  Future<List<VipBanner>> load() async {
    final response = await apiConsumer.get<Object>('$_basePath/All');
    final body = response.data;
    if (body is! Map<String, dynamic> || body['data'] is! List<dynamic>) {
      throw const FormatException('VipBanner/All: data must be a list.');
    }
    return List.unmodifiable([
      for (final item in body['data'] as List<dynamic>)
        if (item is Map<String, dynamic>) VipBanner.fromJson(item),
    ]);
  }

  /// إنشاء (id = null) أو تعديل بنر. الصورة مطلوبة عند الإنشاء واختيارية عند التعديل.
  Future<void> save({
    int? id,
    required String title,
    String? details,
    String? offerText,
    int? discountPercent,
    DateTime? endsAt,
    int? advertisementId,
    bool clearAdvertisement = false,
    bool isActive = true,
    Uint8List? imageBytes,
    String imageName = 'banner.jpg',
  }) async {
    final form = FormData.fromMap({
      'Title': title.trim(),
      'Details': (details ?? '').trim(),
      'OfferText': (offerText ?? '').trim(),
      if (discountPercent != null) 'DiscountPercent': discountPercent,
      if (endsAt != null) 'EndsAt': endsAt.toUtc().toIso8601String(),
      if (advertisementId != null) 'AdvertisementId': advertisementId,
      'ClearAdvertisement': clearAdvertisement,
      'IsActive': isActive,
      if (imageBytes != null)
        'Image': MultipartFile.fromBytes(imageBytes, filename: imageName),
    });
    try {
      final options = Options(contentType: 'multipart/form-data');
      if (id == null) {
        await apiConsumer.dio.post<Object>(_basePath, data: form, options: options);
      } else {
        await apiConsumer.dio.put<Object>('$_basePath/$id', data: form, options: options);
      }
    } on DioException catch (error) {
      throw StateError(_message(error));
    }
  }

  Future<void> setActive(int id, bool active) async {
    try {
      await apiConsumer.post<Object>('$_basePath/$id/Toggle', data: {'isActive': active});
    } on DioException catch (error) {
      throw StateError(_message(error));
    }
  }

  Future<void> delete(int id) async {
    try {
      await apiConsumer.dio.delete<Object>('$_basePath/$id');
    } on DioException catch (error) {
      throw StateError(_message(error));
    }
  }

  /// الإعلانات المقبولة لاختيار إعلان يرتبط به البنر: (id, عنوان).
  Future<List<({int id, String title})>> loadApprovedAds() async {
    final response = await apiConsumer.get<Object>(
      'api/SupervisorForAd/ads',
      queryParameters: {'status': 'Approved', 'page': 1, 'pageSize': 100},
    );
    final body = response.data;
    if (body is! Map<String, dynamic> || body['data'] is! List<dynamic>) {
      return const [];
    }
    return [
      for (final item in body['data'] as List<dynamic>)
        if (item is Map<String, dynamic> && item['id'] is num)
          (
            id: (item['id'] as num).toInt(),
            title: (item['title'] ?? item['name'] ?? '#${item['id']}').toString(),
          ),
    ];
  }

  String _message(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    return 'تعذر تنفيذ العملية (${error.response?.statusCode ?? 'لا يوجد اتصال'}).';
  }
}
