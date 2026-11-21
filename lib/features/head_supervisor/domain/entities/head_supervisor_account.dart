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
