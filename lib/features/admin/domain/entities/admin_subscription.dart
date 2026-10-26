/// اشتراك أو مفتاح خدمة تعتمد عليه المنظومة ويحتاج تجديدًا دوريًا.
class AdminSubscription {
  final String id;
  final String title;
  final String type;
  final String cost;
  final DateTime renewalDate;

  /// مدة التجديد بالأشهر (تُضاف إلى تاريخ التجديد عند تسجيله).
  final int periodMonths;

  const AdminSubscription({
    required this.id,
    required this.title,
    required this.type,
    required this.renewalDate,
    this.cost = '',
    this.periodMonths = 12,
  });

  int daysLeft([DateTime? now]) {
    final today = now ?? DateTime.now();
    final a = DateTime(today.year, today.month, today.day);
    final b = DateTime(renewalDate.year, renewalDate.month, renewalDate.day);
    return b.difference(a).inDays;
  }

  /// 1 = عاجل (≤ 14 يومًا أو منتهٍ)، 2 = قريب (≤ 45 يومًا)، 3 = سليم.
  int group([DateTime? now]) {
    final days = daysLeft(now);
    if (days <= 14) return 1;
    if (days <= 45) return 2;
    return 3;
  }

  AdminSubscription renewed() => AdminSubscription(
        id: id,
        title: title,
        type: type,
        cost: cost,
        periodMonths: periodMonths,
        renewalDate: DateTime(renewalDate.year,
            renewalDate.month + periodMonths, renewalDate.day),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'cost': cost,
        'renewalDate': renewalDate.toIso8601String(),
        'periodMonths': periodMonths,
      };

  factory AdminSubscription.fromJson(Map<String, dynamic> json) =>
      AdminSubscription(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        type: json['type'] as String? ?? '',
        cost: json['cost'] as String? ?? '',
        periodMonths: (json['periodMonths'] as num?)?.toInt() ?? 12,
        renewalDate: DateTime.tryParse(json['renewalDate'] as String? ?? '') ??
            DateTime.now(),
      );
}
