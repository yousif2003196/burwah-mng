import 'package:barwah_app/features/head_supervisor/domain/entities/boss_status.dart';

class BossComplianceMetrics {
  final int approvedInterventions;
  final String governanceScore;
  final int managedSupervisors;

  const BossComplianceMetrics({
    required this.approvedInterventions,
    required this.governanceScore,
    required this.managedSupervisors,
  });
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
  final bool twoFactorEnabled;
  final int activeSessionsCount;
  final bool urgentAlertsEnabled;

  const BossSecuritySettings({
    required this.twoFactorEnabled,
    required this.activeSessionsCount,
    required this.urgentAlertsEnabled,
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
