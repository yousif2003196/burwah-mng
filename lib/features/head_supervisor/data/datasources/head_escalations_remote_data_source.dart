import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/head_supervisor/data/models/boss_json.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_request_api_data_source.dart';

/// التصعيدات التي ترفعها أقسام أخرى لرئيس المشرفين:
/// - طلبات خدمات مشبوهة (`SupervisorForSR` بحالة escalated)
/// - مزودون (`SupervisorForSR/provider-escalations`)
/// - شكاوى مستعمل (`SupervisorUsed/complaint-escalations`)
class HeadEscalationsRemoteDataSource {
  HeadEscalationsRemoteDataSource({
    required this.apiConsumer,
    required this.servicesRequests,
  });

  final ApiConsumer apiConsumer;
  final ServicesRequestApiDataSource servicesRequests;

  Future<List<HeadServiceEscalation>> getServiceEscalations() async {
    final requests = await servicesRequests.load('escalated');
    return [
      for (final request in requests)
        HeadServiceEscalation(
          id: request.id,
          subCategory: request.subCategory,
          client: request.client,
          phone: request.phone,
          address: request.address,
          description: request.description,
          referralReason: request.rejectionReason,
        ),
    ];
  }

  Future<void> decideServiceEscalation(
    int id,
    ServiceEscalationDecision decision,
    String note,
  ) {
    return switch (decision) {
      ServiceEscalationDecision.approve => servicesRequests.approve(id),
      ServiceEscalationDecision.reject => servicesRequests.reject(id, note),
      ServiceEscalationDecision.returnToSupervisor =>
        servicesRequests.returnRequest(id, note),
    };
  }

  Future<List<HeadProviderEscalation>> getProviderEscalations() async {
    final response =
        await apiConsumer.get<Object>(ApiEndpoints.serviceProviderEscalations);
    return [
      for (final row in _dataList(response.data))
        HeadProviderEscalation(
          providerId: BossJson.integer(row['providerId']),
          name: BossJson.text(row['name']),
          businessType: BossJson.text(row['businessType']),
          reason: BossJson.text(row['reason']),
          supervisorName: BossJson.text(row['supervisorName']),
          at: BossJson.date(row['at']),
        ),
    ];
  }

  Future<void> suspendProvider(int providerId, String reason) async {
    await apiConsumer.post<Object>(
      ApiEndpoints.serviceProviderState(providerId),
      data: {'suspended': true, 'reason': reason},
    );
  }

  Future<void> closeProviderEscalation(int providerId, String note) async {
    await apiConsumer.post<Object>(
      ApiEndpoints.serviceCloseProviderEscalation(providerId),
      data: {'reason': note},
    );
  }

  Future<List<HeadUsedComplaintEscalation>> getUsedComplaintEscalations() async {
    final response =
        await apiConsumer.get<Object>(ApiEndpoints.usedComplaintEscalations);
    return [
      for (final row in _dataList(response.data))
        HeadUsedComplaintEscalation(
          complaintId: BossJson.integer(row['complaintId']),
          title: BossJson.text(row['title']),
          description: BossJson.text(row['description']),
          buyerName: BossJson.text(row['buyerName']),
          reason: BossJson.text(row['reason']),
          supervisorName: BossJson.text(row['supervisorName']),
        ),
    ];
  }

  Future<void> resolveUsedComplaint(int complaintId, String note) async {
    await apiConsumer.post<Object>(
      ApiEndpoints.usedComplaintResolve(complaintId),
      data: {'reason': note},
    );
  }

  static List<Map<String, dynamic>> _dataList(Object? body) {
    final data = body is Map ? body['data'] : null;
    if (data is! List) {
      throw const FormatException('Escalations response must hold a list.');
    }
    return BossJson.mapList(data);
  }
}
