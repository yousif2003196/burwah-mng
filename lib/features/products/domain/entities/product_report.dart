/// تقرير أداء مشرف الإعلانات لفترة (اليوم / الأسبوع / الشهر).
class ProductReport {
  const ProductReport({
    required this.reviewed,
    required this.approved,
    required this.declined,
    required this.approvalRate,
    required this.logs,
  });

  final int reviewed;
  final int approved;
  final int declined;
  final double approvalRate;
  final List<ProductReportLog> logs;
}

/// قرار حديث في سجل التقرير.
class ProductReportLog {
  const ProductReportLog({
    required this.adNumber,
    required this.title,
    required this.actionType,
    required this.reason,
    required this.timeAgo,
  });

  final String adNumber;
  final String title;
  final String actionType;
  final String reason;
  final String timeAgo;
}
