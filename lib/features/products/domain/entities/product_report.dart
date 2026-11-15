/// تقرير أداء مشرف الإعلانات لفترة (اليوم / الأسبوع / الشهر / الكل / مخصص).
class ProductReport {
  const ProductReport({
    required this.reviewed,
    required this.approved,
    required this.declined,
    required this.suspended,
    required this.pending,
    required this.approvalRate,
    required this.rejectionRate,
    required this.logs,
    this.averageMinutes,
    this.previousReviewed = 0,
    this.changePercent,
    this.categories = const [],
    this.promotions = const ProductReportPromotions(),
  });

  final int reviewed;
  final int approved;
  final int declined;
  final int suspended;
  final int pending;
  final double approvalRate;
  final double rejectionRate;

  /// متوسط وقت المراجعة بالدقائق (null لو مفيش قرارات في الفترة).
  final double? averageMinutes;
  final int previousReviewed;

  /// نسبة التغير عن الفترة السابقة (null لو مفيش فترة سابقة للمقارنة).
  final double? changePercent;
  final List<ProductReportCategory> categories;
  final ProductReportPromotions promotions;
  final List<ProductReportLog> logs;
}

/// توزيع الإعلانات على قسم واحد.
class ProductReportCategory {
  const ProductReportCategory({
    required this.id,
    required this.name,
    required this.count,
    required this.approved,
    required this.rejected,
    required this.suspended,
    required this.pending,
    required this.percent,
  });

  final int id;
  final String name;
  final int count;
  final int approved;
  final int rejected;
  final int suspended;
  final int pending;
  final double percent;
}

/// أرقام الترويج (مميز / VIP) في الفترة.
class ProductReportPromotions {
  const ProductReportPromotions({
    this.featuredRequests = 0,
    this.vipRequests = 0,
    this.revenue = 0,
    this.pendingRequests = 0,
    this.runningFeatured = 0,
    this.runningVip = 0,
    this.waitingVip = 0,
    this.vipLimit = 0,
  });

  final int featuredRequests;
  final int vipRequests;
  final double revenue;
  final int pendingRequests;
  final int runningFeatured;
  final int runningVip;
  final int waitingVip;
  final int vipLimit;
}

/// قرار حديث في سجل التقرير.
class ProductReportLog {
  const ProductReportLog({
    required this.adNumber,
    required this.title,
    required this.actionType,
    required this.reason,
    required this.timeAgo,
    this.supervisorName = '',
    this.at,
  });

  final String adNumber;
  final String title;
  final String actionType;
  final String reason;
  final String timeAgo;
  final String supervisorName;
  final DateTime? at;
}
