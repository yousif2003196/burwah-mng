enum WasalnyAdStatus {
  pending,
  approved,
  hidden,
  rejected,
  awaitingApproval,
  suspended,
  editRequested,
}

class WasalnyAd {
  final String id;
  final String reference;
  final String titleAr;
  final String titleEn;
  final String sellerNameAr;
  final String sellerNameEn;
  final String cityAr;
  final String cityEn;
  final int price;
  final String categoryKey;
  final WasalnyAdStatus status;
  final DateTime submittedAt;
  final String? decisionNote;
  final String descriptionAr;
  final String descriptionEn;
  final int photoCount;
  final String sellerPhone;
  final bool isSellerPremium;
  final String categoryName;
  final List<String> imageUrls;

  const WasalnyAd({
    required this.id,
    required this.reference,
    required this.titleAr,
    required this.titleEn,
    required this.sellerNameAr,
    required this.sellerNameEn,
    required this.cityAr,
    required this.cityEn,
    required this.price,
    required this.categoryKey,
    required this.status,
    required this.submittedAt,
    this.decisionNote,
    this.descriptionAr = '',
    this.descriptionEn = '',
    this.photoCount = 4,
    this.sellerPhone = '',
    this.isSellerPremium = false,
    this.categoryName = '',
    this.imageUrls = const [],
  });

  WasalnyAd copyWith({
    WasalnyAdStatus? status,
    String? decisionNote,
    String? sellerPhone,
    bool? isSellerPremium,
  }) {
    return WasalnyAd(
      id: id,
      reference: reference,
      titleAr: titleAr,
      titleEn: titleEn,
      sellerNameAr: sellerNameAr,
      sellerNameEn: sellerNameEn,
      cityAr: cityAr,
      cityEn: cityEn,
      price: price,
      categoryKey: categoryKey,
      status: status ?? this.status,
      submittedAt: submittedAt,
      decisionNote: decisionNote ?? this.decisionNote,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      photoCount: photoCount,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      isSellerPremium: isSellerPremium ?? this.isSellerPremium,
      categoryName: categoryName,
      imageUrls: imageUrls,
    );
  }
}
