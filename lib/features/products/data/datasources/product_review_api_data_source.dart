import 'package:dio/dio.dart';

import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/features/products/data/datasources/product_category_api_data_source.dart';
import 'package:barwah_app/features/products/data/datasources/product_review_data_source.dart';
import 'package:barwah_app/features/products/data/models/product_review_model.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';

/// مصدر بيانات مراجعة الإعلانات من واجهة Berwah (قسم SupervisorForAd).
///
/// - GET  api/SupervisorForAd/ads?status=Pending|Approved|Rejected|Suspended
/// - POST api/SupervisorForAd/reject/{id} و hide/{id} (السبب يصل لصاحب الإعلان)
/// - POST api/SupervisorForAd/update-ad-status/{id} بجسم { "status": n }
///
/// الحالات: 0 معلّق، 1 معتمد، 2 مرفوض، 3 موقوف.
/// تعديل الإعلان يبقى محليًا حتى يرجّع الباك إند معرّف التصنيف.
class ProductReviewApiDataSource implements ProductReviewDataSource {
  ProductReviewApiDataSource({
    required this.apiConsumer,
    this.categories,
  });

  final ApiConsumer apiConsumer;
  final ProductCategoryApiDataSource? categories;

  static const _basePath = 'api/SupervisorForAd';
  static const _pageSize = 100;

  final Map<String, ProductReviewModel> _cache = {};
  final Map<String, ({int category, int sub})> _categoryIds = {};

  @override
  Future<List<ProductReviewModel>> getProductReviews() async {
    final reviews = <ProductReviewModel>[];
    for (final status in const [
      'Pending',
      'Approved',
      'Rejected',
      'Suspended',
    ]) {
      final response = await apiConsumer.get<Object>(
        '$_basePath/ads',
        queryParameters: {'status': status, 'page': 1, 'pageSize': _pageSize},
      );
      final body = response.data;
      if (body is! Map<String, dynamic> || body['data'] is! List<dynamic>) {
        throw FormatException('ads?status=$status: data must be a list.');
      }
      for (final item in body['data'] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          reviews.add(_fromJson(item));
          _categoryIds['${item['id']}'] = (
            category: (item['categoryId'] as num?)?.toInt() ?? 0,
            sub: (item['subCategoryId'] as num?)?.toInt() ?? 0,
          );
        }
      }
    }
    _cache
      ..clear()
      ..addEntries(reviews.map((r) => MapEntry(r.id, r)));
    return List.unmodifiable(reviews);
  }

  @override
  Future<ProductReviewModel> updateProductReview(
    ProductReviewModel review,
  ) async {
    final adId = int.tryParse(review.id);
    final before = _cache[review.id];
    if (adId != null && before != null) {
      final price = _parsePrice(
        review.priceAr != before.priceAr ? review.priceAr : review.priceEn,
      );
      final description = review.descriptionAr != before.descriptionAr
          ? review.descriptionAr
          : review.descriptionEn;
      final changed = price != _parsePrice(before.priceAr) ||
          description != before.descriptionAr ||
          (review.categoryId != null &&
              review.categoryId != before.categoryId);
      var ids = _categoryIds[review.id];
      final newCategory = review.categoryId;
      if (ids != null && newCategory != null && newCategory != ids.category) {
        // تغيّر التصنيف: نختار أول تصنيف فرعي له حتى يبقى الإعلان متسقًا.
        final sub = await categories?.firstSubCategoryId(newCategory);
        ids = (category: newCategory, sub: sub ?? 0);
      }
      if (changed && price != null && ids != null) {
        try {
          await apiConsumer.put<Object>(
            '$_basePath/ad/$adId',
            data: {
              'title': review.titleAr,
              'description': description,
              'price': price,
              'categoryId': ids.category,
              'subCategoryId': ids.sub,
            },
          );
        } on DioException catch (error) {
          throw StateError(
            'Could not save the ad '
            '(${error.response?.statusCode ?? 'network'}).',
          );
        }
      }
    }
    if (adId != null && review.categoryId != null) {
      _categoryIds[review.id] = (
        category: review.categoryId!,
        sub: _categoryIds[review.id]?.category == review.categoryId
            ? _categoryIds[review.id]!.sub
            : 0,
      );
    }
    _cache[review.id] = review;
    return review;
  }

  /// "١٬٥٠٠ ج.م" أو "EGP 1,500.50" → 1500.5
  static double? _parsePrice(String text) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final index = arabic.indexOf(char);
      if (index >= 0) {
        buffer.write(index);
      } else if (char == '٫' || char == '.') {
        buffer.write('.');
      } else if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
        buffer.write(char);
      }
    }
    return double.tryParse(buffer.toString());
  }

  @override
  Future<ProductReviewModel> changeProductReviewStatus({
    required String id,
    required ProductReviewStatus status,
    String? decisionNote,
    bool merchantNotificationRequested = false,
  }) async {
    final adId = int.tryParse(id);
    if (adId == null) {
      throw ArgumentError.value(id, 'id', 'Must be a numeric ad id.');
    }
    final note = (decisionNote ?? '').trim();
    try {
      switch (status) {
        case ProductReviewStatus.rejected:
          await apiConsumer.post<Object>(
            '$_basePath/reject/$adId',
            data: {
              'rejectReason': note.isEmpty ? 'مخالف لشروط النشر' : note,
              'supervisorNotes': '',
              'allowResubmission': true,
            },
          );
        case ProductReviewStatus.suspended:
        case ProductReviewStatus.hidden:
          await apiConsumer.post<Object>(
            '$_basePath/hide/$adId',
            data: {
              'notificationMessage':
                  note.isEmpty ? 'تم تعليق إعلانك مؤقتًا من المراجعة.' : note,
              'sendSmsNotification': false,
            },
          );
        case ProductReviewStatus.approved:
        case ProductReviewStatus.pending:
          await apiConsumer.post<Object>(
            '$_basePath/update-ad-status/$adId',
            data: {'status': _statusCode(status)},
          );
      }
    } on DioException catch (error) {
      throw StateError(
        'Could not update the ad status '
        '(${error.response?.statusCode ?? 'network'}).',
      );
    }
    final current = _cache[id];
    if (current == null) {
      throw StateError('Ad $id is not loaded.');
    }
    final updated = current.copyWith(
      status: status,
      decisionNote: decisionNote,
      merchantNotificationRequested: merchantNotificationRequested,
    );
    _cache[id] = updated;
    return updated;
  }

  static int _statusCode(ProductReviewStatus status) => switch (status) {
        ProductReviewStatus.pending => 0,
        ProductReviewStatus.approved => 1,
        ProductReviewStatus.rejected => 2,
        ProductReviewStatus.suspended => 3,
        ProductReviewStatus.hidden => 3,
      };

  static ProductReviewStatus _statusFrom(Object? value) =>
      switch ('$value'.toLowerCase()) {
        'approved' || '1' => ProductReviewStatus.approved,
        'rejected' || '2' => ProductReviewStatus.rejected,
        'suspended' || '3' => ProductReviewStatus.suspended,
        _ => ProductReviewStatus.pending,
      };

  static ProductReviewModel _fromJson(Map<String, dynamic> json) {
    final id = '${json['id']}';
    final title = '${json['title'] ?? ''}'.trim();
    final seller = '${json['sellerName'] ?? ''}'.trim();
    final amount = _group((json['price'] as num?)?.toDouble() ?? 0);
    final images = <String>[
      for (final url in (json['imageUrls'] as List<dynamic>? ?? const []))
        if (url is String && url.isNotEmpty) url,
    ];
    final description = '${json['description'] ?? ''}'.trim();
    return ProductReviewModel(
      id: id,
      reference: 'AD-$id',
      titleAr: title,
      titleEn: title,
      merchantNameAr: seller,
      merchantNameEn: seller,
      category: ProductCategory.electronics,
      imageKind: ProductImageKind.phone,
      photoCount: images.length,
      receivedMinutesAgo: _minutesAgo(json['createdAt']),
      priceAr: '$amount ج.م',
      priceEn: 'EGP $amount',
      descriptionAr: description,
      descriptionEn: description,
      status: _statusFrom(json['status']),
      imageUrls: images,
      decisionNote: (json['reviewNote'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['reviewNote'] as String).trim(),
      categoryId: (json['categoryId'] as num?)?.toInt(),
      subCategoryId: (json['subCategoryId'] as num?)?.toInt(),
    );
  }

  static int _minutesAgo(Object? createdAt) {
    if (createdAt is! String) return 0;
    var parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return 0;
    if (!parsed.isUtc) {
      parsed = DateTime.utc(parsed.year, parsed.month, parsed.day, parsed.hour,
          parsed.minute, parsed.second);
    }
    final minutes = DateTime.now().toUtc().difference(parsed).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }

  static String _group(double value) {
    final whole = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return buffer.toString();
  }
}
