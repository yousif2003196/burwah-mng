enum ProductCategory { homeAppliances, electronics, perfumesAndWatches }

enum ProductImageKind { watch, appliance, camera, phone, fragrance, tool }

enum ProductCondition { newInBox, used }

enum ProductReviewStatus { pending, approved, hidden, rejected, suspended }

class ProductReview {
  final String id;
  final String reference;
  final String titleAr;
  final String titleEn;
  final String merchantNameAr;
  final String merchantNameEn;
  final ProductCategory category;
  final ProductCondition condition;
  final ProductImageKind imageKind;
  final int photoCount;
  final int receivedMinutesAgo;
  final String priceAr;
  final String priceEn;
  final String descriptionAr;
  final String descriptionEn;
  final ProductReviewStatus status;
  final String? decisionNote;
  final bool isFeatured;
  final bool merchantNotificationRequested;
  final List<String> imageUrls;

  /// معرّفات وتسمية التصنيف الحقيقي من الباك إند (null في الوضع التجريبي).
  final int? categoryId;
  final int? subCategoryId;
  final String? categoryName;

  const ProductReview({
    required this.id,
    required this.reference,
    required this.titleAr,
    required this.titleEn,
    required this.merchantNameAr,
    required this.merchantNameEn,
    required this.category,
    this.condition = ProductCondition.newInBox,
    required this.imageKind,
    required this.photoCount,
    required this.receivedMinutesAgo,
    required this.priceAr,
    required this.priceEn,
    this.descriptionAr = '',
    this.descriptionEn = '',
    this.status = ProductReviewStatus.pending,
    this.decisionNote,
    this.isFeatured = false,
    this.merchantNotificationRequested = false,
    this.imageUrls = const [],
    this.categoryId,
    this.subCategoryId,
    this.categoryName,
  });

  ProductReview copyWith({
    ProductCategory? category,
    ProductCondition? condition,
    String? priceAr,
    String? priceEn,
    String? descriptionAr,
    String? descriptionEn,
    ProductReviewStatus? status,
    String? decisionNote,
    bool? isFeatured,
    bool? merchantNotificationRequested,
    int? categoryId,
    int? subCategoryId,
    String? categoryName,
  }) {
    return ProductReview(
      id: id,
      reference: reference,
      titleAr: titleAr,
      titleEn: titleEn,
      merchantNameAr: merchantNameAr,
      merchantNameEn: merchantNameEn,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      imageKind: imageKind,
      photoCount: photoCount,
      receivedMinutesAgo: receivedMinutesAgo,
      priceAr: priceAr ?? this.priceAr,
      priceEn: priceEn ?? this.priceEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      status: status ?? this.status,
      decisionNote: decisionNote ?? this.decisionNote,
      isFeatured: isFeatured ?? this.isFeatured,
      merchantNotificationRequested:
          merchantNotificationRequested ?? this.merchantNotificationRequested,
      imageUrls: imageUrls,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
