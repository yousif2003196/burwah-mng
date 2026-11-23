import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/head_supervisor/data/models/boss_json.dart';
import 'package:barwah_app/features/head_supervisor/data/models/boss_operation_model.dart';
import 'package:barwah_app/features/head_supervisor/data/models/boss_profile_model.dart';
import 'package:barwah_app/features/head_supervisor/data/models/boss_wallet_model.dart';
import 'package:barwah_app/features/head_supervisor/data/models/merchant_complaint_model.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_wallet.dart';

/// نداءات `api/BossOfSupervisor` عبر [ApiConsumer] المشترك.
///
/// كل الردود على شكل `{status, message?, data}`. قائمة `orders-and-disputes`
/// وحدها متداخلة في `data.data`، والباقي في `data` مباشرة.
class BossSupervisorRemoteDataSource {
  BossSupervisorRemoteDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  Future<BossOperationsPageModel> getOperations({
    String? search,
    BossOperationFilter filter = BossOperationFilter.all,
  }) async {
    final query = search?.trim() ?? '';
    final response = await apiConsumer.get<Object>(
      ApiEndpoints.bossOrdersAndDisputes,
      queryParameters: {
        if (query.isNotEmpty) 'search': query,
        'filterTab': filter.apiValue,
      },
    );
    final data = _envelope(response.data)['data'];
    if (data is! Map) {
      throw const FormatException(
          'orders-and-disputes must return data.data.');
    }
    return BossOperationsPageModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<String> reevaluateRequest(
    int id, {
    required ReevaluateActionType actionType,
    required String directiveText,
  }) {
    return _postForMessage(ApiEndpoints.bossReevaluateRequest(id), {
      'actionType': actionType.apiValue,
      'directiveText': directiveText,
    });
  }

  Future<String> resolveDispute(
    int id, {
    required DisputeResolutionType resolutionType,
    required String officialRulingText,
  }) {
    return _postForMessage(ApiEndpoints.bossResolveDispute(id), {
      'resolutionType': resolutionType.apiValue,
      'officialRulingText': officialRulingText,
    });
  }

  Future<List<MerchantComplaintSummaryModel>> getMerchantComplaints() async {
    final response =
        await apiConsumer.get<Object>(ApiEndpoints.bossMerchantComplaints);
    final data = _envelope(response.data)['data'];
    if (data is! List) {
      throw const FormatException('merchant-complaints must return a list.');
    }
    return [
      for (final row in BossJson.mapList(data))
        MerchantComplaintSummaryModel.fromJson(row),
    ];
  }

  Future<MerchantComplaintDetailsModel> getComplaintDetails(int id) async {
    final response =
        await apiConsumer.get<Object>(ApiEndpoints.bossComplaintDetails(id));
    return MerchantComplaintDetailsModel.fromJson(_dataMap(response.data));
  }

  Future<SummonChatResult> summonSupervisorChat(
    int complaintId, {
    required SummonTopic topic,
    required String initialMessage,
    required bool attachCaseDocument,
  }) async {
    final response = await apiConsumer.post<Object>(
      ApiEndpoints.bossComplaintSummonChat(complaintId),
      data: {
        'summonTopic': topic.apiValue,
        'initialMessage': initialMessage,
        'attachCaseDocument': attachCaseDocument,
      },
    );
    final body = _envelope(response.data);
    final data = BossJson.map(body['data']);
    return SummonChatResult(
      message: BossJson.text(body['message']),
      chatSessionId: BossJson.text(data['chatSessionId']),
      startedAt: BossJson.date(data['startedAt']),
    );
  }

  Future<String> unbanAndInvestigate(
    int complaintId,
    UnbanInvestigationRequest request,
  ) {
    return _postForMessage(
      ApiEndpoints.bossComplaintUnbanAndInvestigate(complaintId),
      {
        'unbanAdImmediately': request.unbanAdImmediately,
        'openFormalInvestigation': request.openFormalInvestigation,
        'compensateMerchantPromotion': request.compensateMerchantPromotion,
        'promotionCompensationDays': request.promotionCompensationDays,
        'justificationAndDirective': request.justificationAndDirective,
      },
    );
  }

  Future<String> decideComplaint(
    int complaintId, {
    required ComplaintDecisionType decisionType,
    required String notes,
  }) {
    return _postForMessage(ApiEndpoints.bossComplaintDecision(complaintId), {
      'decisionType': decisionType.apiValue,
      'notes': notes,
    });
  }

  Future<BossProfileModel> getProfile() async {
    final response = await apiConsumer.get<Object>(ApiEndpoints.bossProfile);
    return BossProfileModel.fromJson(_dataMap(response.data));
  }

  Future<BossWalletModel> getWallet() async {
    final response = await apiConsumer.get<Object>(ApiEndpoints.bossWallet);
    return BossWalletModel.fromJson(_dataMap(response.data));
  }

  Future<BossPayoutResultModel> requestPayout(BossPayoutRequest request) async {
    final response = await apiConsumer.post<Object>(
      ApiEndpoints.bossWalletPayout,
      data: {
        'amount': request.amount,
        'payoutMethod': request.payoutMethod,
        'destinationAccount': request.destinationAccount,
      },
    );
    final body = _envelope(response.data);
    return BossPayoutResultModel.fromJson(
      BossJson.map(body['data']),
      message: BossJson.text(body['message']),
    );
  }

  Future<String> _postForMessage(String path, Map<String, Object?> body) async {
    final response = await apiConsumer.post<Object>(path, data: body);
    return BossJson.text(_envelope(response.data)['message']);
  }

  static Map<String, dynamic> _envelope(Object? body) {
    if (body is! Map) {
      throw const FormatException('BossOfSupervisor response must be a JSON object.');
    }
    final envelope = Map<String, dynamic>.from(body);
    final status = BossJson.text(envelope['status']).toLowerCase();
    if (status.isNotEmpty && status != 'success') {
      throw BossApiException(BossJson.text(envelope['message']));
    }
    return envelope;
  }

  static Map<String, dynamic> _dataMap(Object? body) {
    final data = _envelope(body)['data'];
    if (data is! Map) {
      throw const FormatException('BossOfSupervisor response must hold a data object.');
    }
    return Map<String, dynamic>.from(data);
  }
}

/// رد 200 لكن `status` ليس `success`: الرسالة من الخادم تُعرض كما هي.
class BossApiException implements Exception {
  final String message;

  const BossApiException(this.message);

  @override
  String toString() => 'BossApiException: $message';
}
