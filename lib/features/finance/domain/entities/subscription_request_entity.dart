import 'package:equatable/equatable.dart';

enum SubscriptionType { merchant, serviceProvider, user, courier, ad }

enum SubscriptionReviewDecision { approved, frozen, rejected }

class SubscriptionRequestEntity extends Equatable {
  final String id;
  final String providerName; // متجر إلكترونيات النخبة
  final String registrationNumber; // س.ت أو رقم الرخصة
  final String categoryName; // اشتراك تاجر مميز / مقدم خدمات منزلية
  final String targetPackageName; // الباقة الذهبية السنوية / مزود خدمة احترافي
  final String durationText; // سنوي / نصف سنوي
  final double totalAmount; // المبلغ الإجمالي بالجنيه
  final String paymentMethod; // تحويل بنكي مباشر / خصم مباشر من المحفظة
  final String status; // قيد المطابقة / جاهز للاعتماد التلقائي
  final SubscriptionType type;
  final DateTime? createdAt;
  final SubscriptionReviewDecision? reviewDecision;
  final String? decisionReason;
  final String?
      availableBalance; // رصيد متاح في المحفظة إن وجد (مثال: رصيد متاح 6,400 ج.م)

  const SubscriptionRequestEntity({
    required this.id,
    required this.providerName,
    required this.registrationNumber,
    required this.categoryName,
    required this.targetPackageName,
    required this.durationText,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.type,
    this.createdAt,
    this.reviewDecision,
    this.decisionReason,
    this.availableBalance,
  });

  SubscriptionRequestEntity copyWith({
    String? id,
    String? providerName,
    String? registrationNumber,
    String? categoryName,
    String? targetPackageName,
    String? durationText,
    double? totalAmount,
    String? paymentMethod,
    String? status,
    SubscriptionType? type,
    DateTime? createdAt,
    SubscriptionReviewDecision? reviewDecision,
    String? decisionReason,
    bool clearReviewDecision = false,
    bool clearDecisionReason = false,
    String? availableBalance,
  }) {
    return SubscriptionRequestEntity(
      id: id ?? this.id,
      providerName: providerName ?? this.providerName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      categoryName: categoryName ?? this.categoryName,
      targetPackageName: targetPackageName ?? this.targetPackageName,
      durationText: durationText ?? this.durationText,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      reviewDecision:
          clearReviewDecision ? null : reviewDecision ?? this.reviewDecision,
      decisionReason:
          clearDecisionReason ? null : decisionReason ?? this.decisionReason,
      availableBalance: availableBalance ?? this.availableBalance,
    );
  }

  @override
  List<Object?> get props => [
        id,
        providerName,
        totalAmount,
        status,
        createdAt,
        reviewDecision,
        decisionReason,
      ];
}
