import 'package:barwah_app/features/products/data/datasources/product_review_data_source.dart';
import 'package:barwah_app/features/products/data/models/product_review_model.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';

class ProductReviewMockDataSource implements ProductReviewDataSource {
  final List<ProductReviewModel> _reviews = [
    _review(
      '1',
      'AD-98204',
      'ساعة آبل الجيل 2 الأصلية - إصدار جديد',
      'Apple Watch Series 2 Original - New Edition',
      'سعد المنصور',
      'Saad Al-Mansour',
      ProductCategory.electronics,
      ProductImageKind.watch,
      8,
      15,
      '3,200 ج.م',
      'EGP 3,200',
      descriptionAr:
          'جهاز ذكي جديد كلياً لم يُفتح من كرتونه نهائياً مع استيكر المصنع الحراري، وارد الوكيل المحلي مع فاتورة شراء معتمدة وضمان سنتين ساري.',
      descriptionEn:
          'Brand-new smart device, unopened in its original factory-sealed box. Includes a verified local purchase invoice and two-year warranty.',
      isFeatured: true,
    ),
    _review(
      '2',
      'AD-98205',
      'بلانشيت 5 مع تحكم إضافية',
      'Blancet 5 with Additional Controls',
      'فهد بن خالد',
      'Fahad Bin Khalid',
      ProductCategory.homeAppliances,
      ProductImageKind.appliance,
      5,
      28,
      '2,150 ج.م',
      'EGP 2,150',
      condition: ProductCondition.used,
    ),
    _review(
      '3',
      'AD-98209',
      'كاميرا سوني Alpha A7 IV',
      'Sony Alpha A7 IV Camera',
      'منى العتيبي',
      'Mona Al-Otaibi',
      ProductCategory.electronics,
      ProductImageKind.camera,
      6,
      42,
      '8,400 ج.م',
      'EGP 8,400',
      isFeatured: true,
    ),
    _review(
      '4',
      'AD-98212',
      'عطر فاخر إصدار محدود',
      'Luxury Limited Edition Perfume',
      'متجر لمسة عطر',
      'Perfume Touch Store',
      ProductCategory.perfumesAndWatches,
      ProductImageKind.fragrance,
      4,
      55,
      '680 ج.م',
      'EGP 680',
    ),
    _review(
      '5',
      'AD-98214',
      'غسالة أوتوماتيك 10 كجم',
      '10kg Automatic Washing Machine',
      'معرض البيت الحديث',
      'Modern Home Showroom',
      ProductCategory.homeAppliances,
      ProductImageKind.appliance,
      7,
      68,
      '2,750 ج.م',
      'EGP 2,750',
    ),
    _review(
      '6',
      'AD-98216',
      'ساعة يد كلاسيكية مقاومة للماء',
      'Water-resistant Classic Wristwatch',
      'ساعات النخبة',
      'Elite Watches',
      ProductCategory.perfumesAndWatches,
      ProductImageKind.watch,
      5,
      77,
      '1,450 ج.م',
      'EGP 1,450',
    ),
    _review(
      '7',
      'AD-98218',
      'هاتف ذكي بسعة 256 جيجابايت',
      '256GB Smartphone',
      'متجر الصفوة للإلكترونيات',
      'Al-Safwa Electronics Store',
      ProductCategory.electronics,
      ProductImageKind.phone,
      6,
      91,
      '4,100 ج.م',
      'EGP 4,100',
    ),
    _review(
      '8',
      'AD-98220',
      'مكنسة كهربائية لاسلكية',
      'Cordless Vacuum Cleaner',
      'مؤسسة الأجهزة المنزلية',
      'Home Appliances Est.',
      ProductCategory.homeAppliances,
      ProductImageKind.appliance,
      4,
      104,
      '920 ج.م',
      'EGP 920',
    ),
    _review(
      '9',
      'AD-98223',
      'طقم عطور شرقية',
      'Oriental Perfume Set',
      'دار المسك للعطور',
      'Dar Al-Misk Perfumes',
      ProductCategory.perfumesAndWatches,
      ProductImageKind.fragrance,
      3,
      116,
      '540 ج.م',
      'EGP 540',
    ),
    _review(
      '10',
      'AD-98225',
      'كاميرا رقمية احترافية',
      'Professional Digital Camera',
      'متجر الصورة الرقمية',
      'Digital Image Store',
      ProductCategory.electronics,
      ProductImageKind.camera,
      8,
      129,
      '6,200 ج.م',
      'EGP 6,200',
    ),
    _review(
      '11',
      'AD-98227',
      'فرن كهربائي متعدد الاستخدام',
      'Multi-purpose Electric Oven',
      'معرض البيت الحديث',
      'Modern Home Showroom',
      ProductCategory.homeAppliances,
      ProductImageKind.appliance,
      4,
      143,
      '1,300 ج.م',
      'EGP 1,300',
    ),
    _review(
      '12',
      'AD-98230',
      'ساعة ذكية رياضية',
      'Smart Fitness Watch',
      'ساعات النخبة',
      'Elite Watches',
      ProductCategory.perfumesAndWatches,
      ProductImageKind.watch,
      5,
      157,
      '1,050 ج.م',
      'EGP 1,050',
    ),
    _review(
      '13',
      'AD-98232',
      'سماعات لاسلكية عازلة للضوضاء',
      'Noise-cancelling Wireless Headphones',
      'متجر الصفوة للإلكترونيات',
      'Al-Safwa Electronics Store',
      ProductCategory.electronics,
      ProductImageKind.phone,
      5,
      168,
      '890 ج.م',
      'EGP 890',
    ),
    _review(
      '14',
      'AD-98235',
      'طقم عطور نسائي فاخر',
      'Luxury Women’s Perfume Set',
      'دار المسك للعطور',
      'Dar Al-Misk Perfumes',
      ProductCategory.perfumesAndWatches,
      ProductImageKind.fragrance,
      4,
      182,
      '750 ج.م',
      'EGP 750',
    ),
  ];

  @override
  Future<List<ProductReviewModel>> getProductReviews() async {
    return List.unmodifiable(_reviews);
  }

  @override
  Future<ProductReviewModel> updateProductReview(
    ProductReviewModel review,
  ) async {
    final index = _reviews.indexWhere((item) => item.id == review.id);
    if (index < 0) {
      throw StateError('Product review ${review.id} was not found.');
    }
    if (_reviews[index].status != ProductReviewStatus.pending) {
      throw StateError('Product review ${review.id} is no longer editable.');
    }
    _reviews[index] = review;
    return review;
  }

  @override
  Future<ProductReviewModel> changeProductReviewStatus({
    required String id,
    required ProductReviewStatus status,
    String? decisionNote,
    bool merchantNotificationRequested = false,
  }) async {
    final index = _reviews.indexWhere((review) => review.id == id);
    if (index < 0) {
      throw StateError('Product review $id was not found.');
    }
    if (_reviews[index].status != ProductReviewStatus.pending) {
      throw StateError('Product review $id has already been processed.');
    }

    final updated = _reviews[index].copyWith(
      status: status,
      decisionNote: decisionNote,
      merchantNotificationRequested: merchantNotificationRequested,
    );
    _reviews[index] = updated;
    return updated;
  }

  static ProductReviewModel _review(
    String id,
    String reference,
    String titleAr,
    String titleEn,
    String merchantNameAr,
    String merchantNameEn,
    ProductCategory category,
    ProductImageKind imageKind,
    int photoCount,
    int receivedMinutesAgo,
    String priceAr,
    String priceEn, {
    ProductCondition condition = ProductCondition.newInBox,
    String descriptionAr = '',
    String descriptionEn = '',
    bool isFeatured = false,
  }) {
    return ProductReviewModel(
      id: id,
      reference: reference,
      titleAr: titleAr,
      titleEn: titleEn,
      merchantNameAr: merchantNameAr,
      merchantNameEn: merchantNameEn,
      category: category,
      condition: condition,
      imageKind: imageKind,
      photoCount: photoCount,
      receivedMinutesAgo: receivedMinutesAgo,
      priceAr: priceAr,
      priceEn: priceEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      isFeatured: isFeatured,
    );
  }
}
