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

  /// ad / service / order / auction / none.
  final String linkType;

  /// مشرف صعّدها لرئيس المشرفين (مش موجهة له مباشرة).
  final bool escalated;

  const MerchantComplaintSummary({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.complainant,
    required this.status,
    required this.createdAt,
    this.linkType = 'none',
    this.escalated = false,
  });
}

/// طرف في محل الشكوى (تاجر أو كابتن).
class ComplaintParty {
  final int id;
  final String name;
  const ComplaintParty({required this.id, required this.name});
}

/// سطر في الأوردر محل الشكوى.
class ComplaintLinkItem {
  final String name;
  final int quantity;
  final double price;
  const ComplaintLinkItem({required this.name, required this.quantity, required this.price});
}

/// محل الشكوى: طلب خدمة أو أوردر.
class ComplaintLink {
  final String type;
  final int id;
  final String code;
  final String title;
  final List<(String, String)> fields;
  final List<ComplaintLinkItem> items;
  final String description;
  final int? providerId;
  final String providerName;
  final bool providerSuspended;
  final List<ComplaintParty> merchants;
  final ComplaintParty? captain;

  /// قيمة الطلب (أقصى تعويض).
  final double amount;

  const ComplaintLink({
    required this.type,
    required this.id,
    required this.code,
    required this.title,
    required this.fields,
    required this.items,
    required this.description,
    required this.providerId,
    required this.providerName,
    required this.providerSuspended,
    required this.merchants,
    required this.captain,
    required this.amount,
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

  /// آخر قرار للمشرف على محل الشكوى.
  final String lastDecision;
  final DateTime? lastDecisionAt;

  bool get known => code.isNotEmpty;

  const ComplaintAccusedSupervisor({
    required this.name,
    required this.code,
    required this.approvedDecisionsCount,
    this.lastDecision = '',
    this.lastDecisionAt,
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

/// الملف الكامل للتظلم من `complaints/{id}/details`.
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

  /// ad / service / order / auction / none.
  final String linkType;
  final ComplaintLink? link;

  /// Open / InProgress / Closed.
  final String status;

  bool get closed => status == 'Closed';

  const MerchantComplaintDetails({
    this.linkType = 'none',
    this.link,
    this.status = '',
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
