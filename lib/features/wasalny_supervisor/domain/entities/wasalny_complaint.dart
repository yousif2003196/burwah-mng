enum WasalnyComplaintStatus {
  underReview,
  escalatedToChief,
  actionTakenBlocked,
  resolved,
  returnedByHead,
  escalatedToAdmin,
}

enum WasalnyComplaintFilter {
  all,
  awaitingFollowUp,
  escalatedToChief,
}

class WasalnyComplaint {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String timeAgoAr;
  final String timeAgoEn;
  final WasalnyComplaintStatus status;
  final String? dealCode;
  final String itemTitleAr;
  final String itemTitleEn;
  final String? heldAmount;
  final String? buyerNameAr;
  final String? buyerNameEn;
  final String? sellerNameAr;
  final String? sellerNameEn;
  final String? warrantyTextAr;
  final String? warrantyTextEn;
  final String? actionNoteAr;
  final String? actionNoteEn;
  final bool isAdViolation;
  final bool isBlocked;
  final String sellerPhone;
  final String buyerPhone;

  const WasalnyComplaint({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.timeAgoAr,
    required this.timeAgoEn,
    required this.status,
    this.dealCode,
    required this.itemTitleAr,
    required this.itemTitleEn,
    this.heldAmount,
    this.buyerNameAr,
    this.buyerNameEn,
    this.sellerNameAr,
    this.sellerNameEn,
    this.warrantyTextAr,
    this.warrantyTextEn,
    this.actionNoteAr,
    this.actionNoteEn,
    this.isAdViolation = false,
    this.isBlocked = false,
    this.sellerPhone = '050 000 1042',
    this.buyerPhone = '050 000 2042',
  });

  WasalnyComplaint copyWith({
    WasalnyComplaintStatus? status,
    String? actionNoteAr,
    String? actionNoteEn,
    bool? isBlocked,
  }) {
    return WasalnyComplaint(
      id: id,
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      timeAgoAr: timeAgoAr,
      timeAgoEn: timeAgoEn,
      status: status ?? this.status,
      dealCode: dealCode,
      itemTitleAr: itemTitleAr,
      itemTitleEn: itemTitleEn,
      heldAmount: heldAmount,
      buyerNameAr: buyerNameAr,
      buyerNameEn: buyerNameEn,
      sellerNameAr: sellerNameAr,
      sellerNameEn: sellerNameEn,
      warrantyTextAr: warrantyTextAr,
      warrantyTextEn: warrantyTextEn,
      actionNoteAr: actionNoteAr ?? this.actionNoteAr,
      actionNoteEn: actionNoteEn ?? this.actionNoteEn,
      isAdViolation: isAdViolation,
      isBlocked: isBlocked ?? this.isBlocked,
      sellerPhone: sellerPhone,
      buyerPhone: buyerPhone,
    );
  }
}

