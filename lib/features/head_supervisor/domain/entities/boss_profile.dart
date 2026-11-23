import 'package:barwah_app/features/head_supervisor/domain/entities/boss_status.dart';

/// مؤشرات حقيقية من السيرفر.
class BossComplianceMetrics {
  final int managedSupervisors;
  final int activeSupervisors;

  /// إجراءات رئيس المشرفين نفسه في آخر 30 يوم.
  final int decisionsLast30Days;
  final int openComplaints;
  final int openDisputes;

  const BossComplianceMetrics({
    required this.managedSupervisors,
    required this.activeSupervisors,
    required this.decisionsLast30Days,
    required this.openComplaints,
    required this.openDisputes,
  });

  int get waitingForDecision => openComplaints + openDisputes;
}

class BossAuditLog {
  final int id;
  final String code;
  final String title;
  final BossStatus status;
  final String note;
  final DateTime? reviewedAt;

  const BossAuditLog({
    required this.id,
    required this.code,
    required this.title,
    required this.status,
    required this.note,
    required this.reviewedAt,
  });
}

class BossSecuritySettings {
  /// عدد الأجهزة الداخلة على الحساب فعلًا.
  final int activeSessionsCount;
  final DateTime? lastPasswordChange;

  const BossSecuritySettings({
    required this.activeSessionsCount,
    required this.lastPasswordChange,
  });
}

/// الملف الشخصي والسجل الرقابي من `profile`.
class BossProfile {
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
  final BossComplianceMetrics complianceMetrics;
  final List<BossAuditLog> recentAuditLogs;
  final BossSecuritySettings securitySettings;

  const BossProfile({
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
    required this.complianceMetrics,
    required this.recentAuditLogs,
    required this.securitySettings,
  });
}
