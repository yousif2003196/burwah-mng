import 'package:barwah_app/features/head_supervisor/data/models/boss_json.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_profile.dart';

class BossProfileModel extends BossProfile {
  const BossProfileModel({
    required super.userId,
    required super.fullName,
    required super.roleTitle,
    required super.badgeCode,
    required super.email,
    required super.phoneNumber,
    required super.supervisionScope,
    required super.totalBalance,
    required super.availableForWithdrawal,
    required super.lockedBalance,
    required super.complianceMetrics,
    required super.recentAuditLogs,
    required super.securitySettings,
  });

  factory BossProfileModel.fromJson(Map<String, dynamic> json) {
    final metrics = BossJson.map(json['complianceMetrics']);
    final security = BossJson.map(json['securitySettings']);
    return BossProfileModel(
      userId: BossJson.integer(json['userId']),
      fullName: BossJson.text(json['fullName']),
      roleTitle: BossJson.text(json['roleTitle']),
      badgeCode: BossJson.text(json['badgeCode']),
      email: BossJson.text(json['email']),
      phoneNumber: BossJson.text(json['phoneNumber']),
      supervisionScope: BossJson.text(json['supervisionScope']),
      totalBalance: BossJson.number(json['totalBalance']),
      availableForWithdrawal: BossJson.number(json['availableForWithdrawal']),
      lockedBalance: BossJson.number(json['lockedBalance']),
      complianceMetrics: BossComplianceMetrics(
        approvedInterventions:
            BossJson.integer(metrics['approvedInterventions']),
        governanceScore: BossJson.text(metrics['governanceScore']),
        managedSupervisors: BossJson.integer(metrics['managedSupervisors']),
      ),
      recentAuditLogs: [
        for (final row in BossJson.mapList(json['recentAuditLogs']))
          BossAuditLog(
            id: BossJson.integer(row['id']),
            code: BossJson.text(row['code']),
            title: BossJson.text(row['title']),
            status: BossJson.status(row['status']),
            note: BossJson.text(row['note']),
            reviewedAt: BossJson.date(row['reviewedAt']),
          ),
      ],
      securitySettings: BossSecuritySettings(
        twoFactorEnabled: BossJson.boolean(security['twoFactorEnabled']),
        activeSessionsCount: BossJson.integer(security['activeSessionsCount']),
        urgentAlertsEnabled: BossJson.boolean(security['urgentAlertsEnabled']),
      ),
    );
  }
}
