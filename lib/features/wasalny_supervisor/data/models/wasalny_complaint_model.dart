import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';

class WasalnyComplaintModel extends WasalnyComplaint {
  const WasalnyComplaintModel({
    required super.id,
    required super.titleAr,
    required super.titleEn,
    required super.descriptionAr,
    required super.descriptionEn,
    required super.timeAgoAr,
    required super.timeAgoEn,
    required super.status,
    super.dealCode,
    required super.itemTitleAr,
    required super.itemTitleEn,
    super.heldAmount,
    super.buyerNameAr,
    super.buyerNameEn,
    super.sellerNameAr,
    super.sellerNameEn,
    super.warrantyTextAr,
    super.warrantyTextEn,
    super.actionNoteAr,
    super.actionNoteEn,
    super.isAdViolation,
    super.isBlocked,
    super.sellerPhone,
    super.buyerPhone,
  });

  factory WasalnyComplaintModel.fromJson(Map<String, dynamic> json) {
    return WasalnyComplaintModel(
      id: _requiredString(json, 'id'),
      titleAr: _requiredString(json, 'titleAr'),
      titleEn: _requiredString(json, 'titleEn'),
      descriptionAr: _requiredString(json, 'descriptionAr'),
      descriptionEn: _requiredString(json, 'descriptionEn'),
      timeAgoAr: _requiredString(json, 'timeAgoAr'),
      timeAgoEn: _requiredString(json, 'timeAgoEn'),
      status: _readStatus(json, 'status'),
      dealCode: _optionalString(json, 'dealCode'),
      itemTitleAr: _requiredString(json, 'itemTitleAr'),
      itemTitleEn: _requiredString(json, 'itemTitleEn'),
      heldAmount: _optionalString(json, 'heldAmount'),
      buyerNameAr: _optionalString(json, 'buyerNameAr'),
      buyerNameEn: _optionalString(json, 'buyerNameEn'),
      sellerNameAr: _optionalString(json, 'sellerNameAr'),
      sellerNameEn: _optionalString(json, 'sellerNameEn'),
      warrantyTextAr: _optionalString(json, 'warrantyTextAr'),
      warrantyTextEn: _optionalString(json, 'warrantyTextEn'),
      actionNoteAr: _optionalString(json, 'actionNoteAr'),
      actionNoteEn: _optionalString(json, 'actionNoteEn'),
      isAdViolation: _optionalBool(json, 'isAdViolation'),
      isBlocked: _optionalBool(json, 'isBlocked'),
      sellerPhone: _optionalString(json, 'sellerPhone') ?? '',
      buyerPhone: _optionalString(json, 'buyerPhone') ?? '',
    );
  }

  factory WasalnyComplaintModel.fromEntity(WasalnyComplaint entity) {
    return WasalnyComplaintModel(
      id: entity.id,
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      timeAgoAr: entity.timeAgoAr,
      timeAgoEn: entity.timeAgoEn,
      status: entity.status,
      dealCode: entity.dealCode,
      itemTitleAr: entity.itemTitleAr,
      itemTitleEn: entity.itemTitleEn,
      heldAmount: entity.heldAmount,
      buyerNameAr: entity.buyerNameAr,
      buyerNameEn: entity.buyerNameEn,
      sellerNameAr: entity.sellerNameAr,
      sellerNameEn: entity.sellerNameEn,
      warrantyTextAr: entity.warrantyTextAr,
      warrantyTextEn: entity.warrantyTextEn,
      actionNoteAr: entity.actionNoteAr,
      actionNoteEn: entity.actionNoteEn,
      isAdViolation: entity.isAdViolation,
      isBlocked: entity.isBlocked,
      sellerPhone: entity.sellerPhone,
      buyerPhone: entity.buyerPhone,
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
          'Complaint field "$key" must be a non-empty string.');
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Complaint field "$key" must be a string.');
    }
    return value;
  }

  static bool _optionalBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return false;
    if (value is! bool) {
      throw FormatException('Complaint field "$key" must be a boolean.');
    }
    return value;
  }

  static WasalnyComplaintStatus _readStatus(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Complaint field "$key" must be a string.');
    }
    return switch (value) {
      'under_review' => WasalnyComplaintStatus.underReview,
      'escalated_to_chief' => WasalnyComplaintStatus.escalatedToChief,
      'action_taken_blocked' => WasalnyComplaintStatus.actionTakenBlocked,
      'resolved' => WasalnyComplaintStatus.resolved,
      'returned_by_head' => WasalnyComplaintStatus.returnedByHead,
      'escalated_to_admin' => WasalnyComplaintStatus.escalatedToAdmin,
      _ => throw FormatException('Unsupported complaint status "$value".'),
    };
  }
}
