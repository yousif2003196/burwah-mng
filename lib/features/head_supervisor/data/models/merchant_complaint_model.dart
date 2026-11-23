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
    super.linkType,
    super.escalated,
  });

  factory MerchantComplaintSummaryModel.fromJson(Map<String, dynamic> json) {
    final id = BossJson.integer(json['id']);
    final code = BossJson.text(json['code']);
    return MerchantComplaintSummaryModel(
      id: id,
      code: code.isEmpty ? '#$id' : code,
      title: BossJson.text(json['title']).isNotEmpty
          ? BossJson.text(json['title'])
          : BossJson.text(json['subject']),
      description: BossJson.text(json['description']),
      complainant: BossJson.text(json['complainant']),
      status: BossJson.status(json['status']),
      createdAt: BossJson.date(json['createdAt']),
      linkType: BossJson.text(json['linkType']).isEmpty
          ? (json['adId'] != null ? 'ad' : 'none')
          : BossJson.text(json['linkType']),
      escalated: json['escalated'] == true,
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
    super.linkType,
    super.link,
    super.status,
  });

  factory MerchantComplaintDetailsModel.fromJson(Map<String, dynamic> json) {
    final complainant = BossJson.map(json['complainant']);
    final supervisor = BossJson.map(json['accusedSupervisor']);
    final audit = BossJson.map(json['automatedAudit']);
    final statement = BossJson.map(json['supervisorStatement']);
    final id = BossJson.integer(json['complaintId']);
    final code = BossJson.text(json['code']);
    final linkJson = BossJson.map(json['link']);
    return MerchantComplaintDetailsModel(
      linkType: BossJson.text(json['linkType']).isEmpty ? 'none' : BossJson.text(json['linkType']),
      link: linkJson.isEmpty ? null : _link(linkJson),
      status: BossJson.text(json['status']),
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
        lastDecision: BossJson.text(supervisor['lastDecision']),
        lastDecisionAt: BossJson.date(supervisor['lastDecisionAt']),
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

  static double _number(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  static ComplaintLink _link(Map<String, dynamic> j) {
    ComplaintParty? party(Object? v) {
      final m = BossJson.map(v);
      if (m.isEmpty) return null;
      return ComplaintParty(id: BossJson.integer(m['id']), name: BossJson.text(m['name']));
    }

    return ComplaintLink(
      type: BossJson.text(j['type']),
      id: BossJson.integer(j['id']),
      code: BossJson.text(j['code']),
      title: BossJson.text(j['title']),
      fields: [
        for (final f in BossJson.mapList(j['fields']))
          (BossJson.text(f['label']), BossJson.text(f['value'])),
      ],
      items: [
        for (final i in BossJson.mapList(j['items']))
          ComplaintLinkItem(
            name: BossJson.text(i['name']),
            quantity: BossJson.integer(i['quantity']),
            price: _number(i['price']),
          ),
      ],
      description: BossJson.text(j['description']),
      providerId: BossJson.optionalInteger(j['providerId']),
      providerName: BossJson.text(j['providerName']),
      providerSuspended: j['providerSuspended'] == true,
      merchants: [
        for (final m in BossJson.mapList(j['merchants']))
          ComplaintParty(id: BossJson.integer(m['id']), name: BossJson.text(m['name'])),
      ],
      captain: party(j['captain']),
      amount: _number(j['amount']),
    );
  }
}
