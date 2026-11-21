/// طلب خدمة مشبوه أحاله مشرف الخدمات لرئيس المشرفين.
class HeadServiceEscalation {
  final int id;
  final String subCategory;
  final String client;
  final String phone;
  final String address;
  final String description;
  final String referralReason;

  const HeadServiceEscalation({
    required this.id,
    required this.subCategory,
    required this.client,
    required this.phone,
    required this.address,
    required this.description,
    required this.referralReason,
  });
}

/// مزود خدمة رفعه مشرف الخدمات لرئيس المشرفين.
class HeadProviderEscalation {
  final int providerId;
  final String name;
  final String businessType;
  final String reason;
  final String supervisorName;
  final DateTime? at;

  const HeadProviderEscalation({
    required this.providerId,
    required this.name,
    required this.businessType,
    required this.reason,
    required this.supervisorName,
    required this.at,
  });
}

/// شكوى منتج مستعمل رفعها مشرف وصلني لرئيس المشرفين.
class HeadUsedComplaintEscalation {
  final int complaintId;
  final String title;
  final String description;
  final String buyerName;
  final String reason;
  final String supervisorName;

  const HeadUsedComplaintEscalation({
    required this.complaintId,
    required this.title,
    required this.description,
    required this.buyerName,
    required this.reason,
    required this.supervisorName,
  });
}

/// قرار رئيس المشرفين على طلب خدمة مشبوه.
enum ServiceEscalationDecision { approve, reject, returnToSupervisor }
