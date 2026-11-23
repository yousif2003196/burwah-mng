/// قيم `actionType` في `requests/{id}/reevaluate`.
enum ReevaluateActionType {
  reassign('reassign'),
  explanation('explanation'),
  warning('warning');

  final String apiValue;
  const ReevaluateActionType(this.apiValue);
}

/// قيم `resolutionType` في `disputes/{orderId}/resolve` (نزاعات التوصيل).
enum DisputeResolutionType {
  /// الطلب اتسلّم: يتصرف للكابتن نصيبه ويتقفل بلاغ العميل.
  payCaptain('pay_captain'),

  /// الطلب ما اتسلّمش: الكابتن ما ياخدش، والعميل يسترد اللي دفعه إلكترونيًا.
  notDelivered('not_delivered');

  final String apiValue;
  const DisputeResolutionType(this.apiValue);
}

/// قيم `summonTopic` في `summon-chat`.
enum SummonTopic {
  immediateClarification('immediate_clarification'),
  confrontDocuments('confront_documents'),
  quickInterrogation('quick_interrogation');

  final String apiValue;
  const SummonTopic(this.apiValue);
}

/// قيم `decisionType` في `complaints/{id}/decision`.
enum ComplaintDecisionType {
  upholdSupervisor('uphold_supervisor'),
  escalateLegalGm('escalate_legal_gm');

  final String apiValue;
  const ComplaintDecisionType(this.apiValue);
}

/// أقصى طول لنص التوجيه في إعادة المراجعة (حسب التوثيق).
const int reevaluateDirectiveMaxLength = 300;

/// بيانات قرار فك الحظر والتحقيق.
class UnbanInvestigationRequest {
  final bool unbanAdImmediately;
  final bool openFormalInvestigation;
  final bool compensateMerchantPromotion;
  final int promotionCompensationDays;
  final String justificationAndDirective;

  const UnbanInvestigationRequest({
    required this.unbanAdImmediately,
    required this.openFormalInvestigation,
    required this.compensateMerchantPromotion,
    required this.promotionCompensationDays,
    required this.justificationAndDirective,
  });
}

/// نتيجة بدء محادثة الاستدعاء.
class SummonChatResult {
  final String message;
  final String chatSessionId;
  final DateTime? startedAt;

  const SummonChatResult({
    required this.message,
    required this.chatSessionId,
    required this.startedAt,
  });
}
