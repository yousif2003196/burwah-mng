/// بيانات حساب رئيس المشرفين كما يرجعها الباك إند
/// (`api/BossOfSupervisor/profile` و`api/BossOfSupervisor/wallet`).

class HeadSupervisorAuditLogItem {
  const HeadSupervisorAuditLogItem({
    required this.code,
    required this.title,
    required this.status,
    required this.note,
    this.reviewedAt,
  });

  final String code;
  final String title;
  final String status;
  final String note;
  final DateTime? reviewedAt;
}

class HeadSupervisorProfile {
  const HeadSupervisorProfile({
    required this.userId,
    required this.fullName,
    required this.roleTitle,
    required this.badgeCode,
    required this.email,
    required this.phoneNumber,
    required this.supervisionScope,
    required this.totalBalance,
    required this.availableForWithdrawal,
    required this.lockedBalance,
    required this.approvedInterventions,
    required this.governanceScore,
    required this.managedSupervisors,
    required this.recentAuditLogs,
  });

  final int userId;
  final String fullName;
  final String roleTitle;
  final String badgeCode;
  final String email;
  final String phoneNumber;
  final String supervisionScope;
  final double totalBalance;
  final double availableForWithdrawal;
  final double lockedBalance;
  final int approvedInterventions;
  final String governanceScore;
  final int managedSupervisors;
  final List<HeadSupervisorAuditLogItem> recentAuditLogs;
}

class HeadSupervisorWalletTransaction {
  const HeadSupervisorWalletTransaction({
    required this.referenceCode,
    required this.kind,
    required this.amount,
    required this.description,
    required this.status,
    this.createdAt,
  });

  final String referenceCode;
  final String kind;
  final double amount;
  final String description;
  final String status;
  final DateTime? createdAt;
}

class HeadSupervisorWallet {
  const HeadSupervisorWallet({
    required this.totalBalance,
    required this.availableForWithdrawal,
    required this.lockedBalance,
    required this.minimumWithdrawal,
    required this.payoutMethods,
    required this.transactions,
  });

  final double totalBalance;
  final double availableForWithdrawal;
  final double lockedBalance;
  final double minimumWithdrawal;
  final List<String> payoutMethods;
  final List<HeadSupervisorWalletTransaction> transactions;
}

/// نتيجة طلب سحب ناجح.
class HeadSupervisorPayoutResult {
  const HeadSupervisorPayoutResult({
    required this.message,
    required this.transactionId,
    required this.remainingBalance,
  });

  final String message;
  final String transactionId;
  final double remainingBalance;
}

/// حالة حساب مشرف ومؤشراته الفعلية (`supervisors/{id}/profile`).
class HeadSupervisorAccountInfo {
  const HeadSupervisorAccountInfo({
    required this.activeSessions,
    required this.adDecisions,
    required this.approved,
    required this.rejected,
    required this.otherActions,
    required this.frozen,
    required this.deletionPending,
    this.lastActivity,
    this.lastPasswordChange,
    this.createdAt,
    this.suspendedUntil,
    this.suspensionNote = '',
    this.canReviewAds = true,
    this.canHideAds = true,
    this.role = '',
    this.decisionsLast7Days = 0,
    this.decisionsLast30Days = 0,
    this.approvalRate,
    this.avgReviewMinutes,
  });

  final int activeSessions;
  final int adDecisions;
  final int approved;
  final int rejected;
  final int otherActions;
  final bool frozen;
  final bool deletionPending;
  final DateTime? lastActivity;
  final DateTime? lastPasswordChange;
  final DateTime? createdAt;

  /// نهاية التعليق؛ null مع [frozen] = تعليق لحين انتهاء التحقيق.
  final DateTime? suspendedUntil;
  final String suspensionNote;
  final bool canReviewAds;
  final bool canHideAds;

  /// دور الحساب في السيرفر (SupervisorForAd ...).
  final String role;
  final int decisionsLast7Days;
  final int decisionsLast30Days;

  /// نسبة القبول من قرارات الإعلانات (null لو مفيش قرارات).
  final int? approvalRate;

  /// متوسط دقائق مراجعة الإعلان في آخر 30 يوم.
  final double? avgReviewMinutes;

  bool get handlesAds =>
      role == 'SupervisorForAd' || role == 'SupervisorUsed';
}

/// معاينة إعلان (قراءة بس) من سجل المشرف.
class HeadSupervisorAdPreview {
  const HeadSupervisorAdPreview({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.status,
    required this.sellerName,
    required this.reviewNote,
    required this.imageUrls,
    this.createdAt,
    this.reviewedAt,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final String status;
  final String sellerName;
  final String reviewNote;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
}

/// طلب حذف مشرف معلق عند الأدمن (`deletion-requests`).
class HeadSupervisorDeletionRequest {
  const HeadSupervisorDeletionRequest({
    required this.supervisorId,
    required this.supervisorName,
    required this.role,
    required this.reason,
    required this.notes,
    required this.requestedBy,
    required this.requestedAt,
  });

  final int supervisorId;
  final String supervisorName;
  final String role;
  final String reason;
  final String notes;
  final String requestedBy;
  final DateTime requestedAt;
}

/// رفض من السيرفر برسالة مفهومة للمستخدم (مثل رصيد غير كافٍ).
class HeadSupervisorApiRejection implements Exception {
  const HeadSupervisorApiRejection(this.message);
  final String message;

  @override
  String toString() => message;
}

/// يوم في اتجاه قرارات الأقسام (لوحة "نظرة عامة").
class HeadSupervisorTrendDay {
  const HeadSupervisorTrendDay({
    required this.date,
    required this.merchant,
    required this.wasalny,
    required this.products,
    required this.services,
  });

  final DateTime date;
  final int merchant;
  final int wasalny;
  final int products;
  final int services;
}

/// مؤشرات لوحة رئيس المشرفين من `dashboard-overview`.
class HeadSupervisorDashboard {
  const HeadSupervisorDashboard({
    required this.todayActions,
    required this.activeSupervisors,
    required this.trend,
  });

  final int todayActions;
  final int activeSupervisors;
  final List<HeadSupervisorTrendDay> trend;
}
