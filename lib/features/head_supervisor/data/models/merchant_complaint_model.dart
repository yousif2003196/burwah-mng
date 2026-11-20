import 'package:barwah_app/features/head_supervisor/data/models/boss_json.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';

class MerchantComplaintSummaryModel extends MerchantComplaintSummary {
  const MerchantComplaintSummaryModel({
    required super.id,
    required super.code,
    required super.title,
    required super.description,
    required super.complainant,
    required super.status,
    required super.createdAt,
  });

  factory MerchantComplaintSummaryModel.fromJson(Map<String, dynamic> json) {
    final id = BossJson.integer(json['id']);
    final code = BossJson.text(json['code']);
    return MerchantComplaintSummaryModel(
      id: id,
      code: code.isEmpty ? '#$id' : code,
      title: BossJson.text(json['title']),
      description: BossJson.text(json['description']),
      complainant: BossJson.text(json['complainant']),
      status: BossJson.status(json['status']),
      createdAt: BossJson.date(json['createdAt']),
    );
  }
}

class MerchantComplaintDetailsModel extends MerchantComplaintDetails {
  const MerchantComplaintDetailsModel({
    required super.complaintId,
    required super.code,
    required super.title,
    required super.priorityBadge,
    required super.classification,
    required super.complainant,
    required super.accusedSupervisor,
    required super.automatedAudit,
    required super.supervisorStatement,
    required super.evidences,
  });

  factory MerchantComplaintDetailsModel.fromJson(Map<String, dynamic> json) {
    final complainant = BossJson.map(json['complainant']);
    final supervisor = BossJson.map(json['accusedSupervisor']);
    final audit = BossJson.map(json['automatedAudit']);
    final statement = BossJson.map(json['supervisorStatement']);
    final id = BossJson.integer(json['complaintId']);
    final code = BossJson.text(json['code']);
    return MerchantComplaintDetailsModel(
      complaintId: id,
      code: code.isEmpty ? '#$id' : code,
      title: BossJson.text(json['title']),
      priorityBadge: BossJson.text(json['priorityBadge']),
      classification: BossJson.text(json['classification']),
      complainant: ComplaintComplainant(
        id: BossJson.optionalInteger(complainant['id']),
        name: BossJson.text(complainant['name']),
        badge: BossJson.text(complainant['badge']),
      ),
      accusedSupervisor: ComplaintAccusedSupervisor(
        name: BossJson.text(supervisor['name']),
        code: BossJson.text(supervisor['code']),
        approvedDecisionsCount:
            BossJson.integer(supervisor['approvedDecisionsCount']),
      ),
      automatedAudit: ComplaintAutomatedAudit(
        engineVersion: BossJson.text(audit['engineVersion']),
        commercialLicenseStatus: BossJson.text(audit['commercialLicenseStatus']),
        protocolAlert: BossJson.text(audit['protocolAlert']),
      ),
      supervisorStatement: ComplaintSupervisorStatement(
        statementText: BossJson.text(statement['statementText']),
        recordedAt: BossJson.date(statement['recordedAt']),
        legalAssessment: BossJson.text(statement['legalAssessment']),
      ),
      evidences: [
        for (final row in BossJson.mapList(json['evidences']))
          ComplaintEvidence(
            title: BossJson.text(row['title']),
            subtitle: BossJson.text(row['subtitle']),
            previewUrl: BossJson.text(row['previewUrl']),
          ),
      ],
    );
  }
}
