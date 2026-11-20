import 'package:barwah_app/features/head_supervisor/domain/entities/boss_status.dart';

/// عنصر من قائمة تظلمات التجار ضد المشرفين.
class MerchantComplaintSummary {
  final int id;
  final String code;
  final String title;
  final String description;
  final String complainant;
  final BossStatus status;
  final DateTime? createdAt;

  const MerchantComplaintSummary({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.complainant,
    required this.status,
    required this.createdAt,
  });
}

class ComplaintComplainant {
  final int? id;
  final String name;
  final String badge;

  const ComplaintComplainant({
    required this.id,
    required this.name,
    required this.badge,
  });
}

class ComplaintAccusedSupervisor {
  final String name;
  final String code;
  final int approvedDecisionsCount;

  const ComplaintAccusedSupervisor({
    required this.name,
    required this.code,
    required this.approvedDecisionsCount,
  });
}

class ComplaintAutomatedAudit {
  final String engineVersion;
  final String commercialLicenseStatus;
  final String protocolAlert;

  const ComplaintAutomatedAudit({
    required this.engineVersion,
    required this.commercialLicenseStatus,
    required this.protocolAlert,
  });
}

class ComplaintSupervisorStatement {
  final String statementText;
  final DateTime? recordedAt;
  final String legalAssessment;

  const ComplaintSupervisorStatement({
    required this.statementText,
    required this.recordedAt,
    required this.legalAssessment,
  });
}

class ComplaintEvidence {
  final String title;
  final String subtitle;
  final String previewUrl;

  const ComplaintEvidence({
    required this.title,
    required this.subtitle,
    required this.previewUrl,
  });
}

/// الملف الكامل للتظلم من `final/complaints/{id}/details`.
class MerchantComplaintDetails {
  final int complaintId;
  final String code;
  final String title;
  final String priorityBadge;
  final String classification;
  final ComplaintComplainant complainant;
  final ComplaintAccusedSupervisor accusedSupervisor;
  final ComplaintAutomatedAudit automatedAudit;
  final ComplaintSupervisorStatement supervisorStatement;
  final List<ComplaintEvidence> evidences;

  const MerchantComplaintDetails({
    required this.complaintId,
    required this.code,
    required this.title,
    required this.priorityBadge,
    required this.classification,
    required this.complainant,
    required this.accusedSupervisor,
    required this.automatedAudit,
    required this.supervisorStatement,
    required this.evidences,
  });
}
