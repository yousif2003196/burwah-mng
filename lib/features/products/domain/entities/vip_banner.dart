/// بنر في قسم VIP يصنعه مشرف المنتجات: صورة بعنوان وتفاصيل وعرض،
/// وقد يرتبط بإعلان (الضغط يفتح الإعلان) أو يبقى صورة فقط (يفتح تفاصيله).
class VipBanner {
  const VipBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.details,
    this.offerText,
    this.discountPercent,
    this.advertisementId,
    this.endsAt,
    this.isActive = true,
    this.expired = false,
  });

  final int id;
  final String title;
  final String imageUrl;
  final String? details;
  final String? offerText;
  final int? discountPercent;
  final int? advertisementId;
  final DateTime? endsAt;
  final bool isActive;
  final bool expired;

  factory VipBanner.fromJson(Map<String, dynamic> json) {
    String? text(Object? v) {
      final s = v?.toString().trim();
      return s == null || s.isEmpty ? null : s;
    }

    return VipBanner(
      id: (json['id'] as num).toInt(),
      title: text(json['title']) ?? '',
      imageUrl: text(json['imageUrl']) ?? '',
      details: text(json['details']),
      offerText: text(json['offerText']),
      discountPercent: (json['discountPercent'] as num?)?.toInt(),
      advertisementId: (json['advertisementId'] as num?)?.toInt(),
      endsAt: DateTime.tryParse(json['endsAt']?.toString() ?? '')?.toLocal(),
      isActive: json['isActive'] != false,
      expired: json['expired'] == true,
    );
  }
}
