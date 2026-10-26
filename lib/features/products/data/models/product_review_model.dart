import 'package:barwah_app/features/products/domain/entities/product_review.dart';

class ProductReviewModel extends ProductReview {
  const ProductReviewModel({
    required super.id,
    required super.reference,
    required super.titleAr,
    required super.titleEn,
    required super.merchantNameAr,
    required super.merchantNameEn,
    required super.category,
    super.condition,
    required super.imageKind,
    required super.photoCount,
    required super.receivedMinutesAgo,
    required super.priceAr,
    required super.priceEn,
    super.descriptionAr,
    super.descriptionEn,
    super.status,
    super.decisionNote,
    super.isFeatured,
    super.merchantNotificationRequested,
  });

  factory ProductReviewModel.fromEntity(ProductReview entity) {
    return ProductReviewModel(
      id: entity.id,
      reference: entity.reference,
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      merchantNameAr: entity.merchantNameAr,
      merchantNameEn: entity.merchantNameEn,
      category: entity.category,
      condition: entity.condition,
      imageKind: entity.imageKind,
      photoCount: entity.photoCount,
      receivedMinutesAgo: entity.receivedMinutesAgo,
      priceAr: entity.priceAr,
      priceEn: entity.priceEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      status: entity.status,
      decisionNote: entity.decisionNote,
      isFeatured: entity.isFeatured,
      merchantNotificationRequested: entity.merchantNotificationRequested,
    );
  }

  @override
  ProductReviewModel copyWith({
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
  }) {
    return ProductReviewModel(
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
    );
  }
}
