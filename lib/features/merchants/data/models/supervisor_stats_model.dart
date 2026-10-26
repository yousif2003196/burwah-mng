import 'package:barwah_app/features/merchants/domain/entities/supervisor_stats_entity.dart';

class SupervisorStatsModel extends SupervisorStatsEntity {
  const SupervisorStatsModel({
    required super.supervisorName,
    required super.supervisorNameEn,
    required super.supervisorTag,
    required super.supervisorTagEn,
    required super.region,
    required super.regionEn,
    required super.approvedMerchantsCount,
    required super.pendingReviewCount,
    required super.totalCount,
    required super.activeVerifiedCount,
    required super.underAuditCount,
    required super.updateRequiredCount,
    required super.suspendedCount,
    super.compliancePercentage,
    super.pendingAlertsCount,
    super.supervisorCode,
    super.supervisorFullName,
    super.supervisorFullNameEn,
    super.supervisionScope,
    super.supervisionScopeEn,
  });

  factory SupervisorStatsModel.fromJson(Map<String, dynamic> json) {
    return SupervisorStatsModel(
      supervisorName: json['supervisorName'] as String,
      supervisorNameEn: json['supervisorNameEn'] as String,
      supervisorTag: json['supervisorTag'] as String,
      supervisorTagEn: json['supervisorTagEn'] as String,
      region: json['region'] as String,
      regionEn: json['regionEn'] as String,
      approvedMerchantsCount: json['approvedMerchantsCount'] as int,
      pendingReviewCount: json['pendingReviewCount'] as int,
      totalCount: json['totalCount'] as int,
      activeVerifiedCount: json['activeVerifiedCount'] as int,
      underAuditCount: json['underAuditCount'] as int,
      updateRequiredCount: json['updateRequiredCount'] as int,
      suspendedCount: json['suspendedCount'] as int,
      compliancePercentage:
          (json['compliancePercentage'] as num?)?.toInt() ?? 94,
      pendingAlertsCount: (json['pendingAlertsCount'] as num?)?.toInt() ?? 2,
      supervisorCode: json['supervisorCode'] as String? ?? 'SUP-4092',
      supervisorFullName:
          json['supervisorFullName'] as String? ?? 'أحمد بن عبد العزيز الخضيري',
      supervisorFullNameEn: json['supervisorFullNameEn'] as String? ??
          'Ahmed bin Abdulaziz Al-Khudairi',
      supervisionScope: json['supervisionScope'] as String? ??
          'منطقة الرياض (وسط وشمال العاصمة)',
      supervisionScopeEn: json['supervisionScopeEn'] as String? ??
          'Riyadh Region (Central & North)',
    );
  }
}
