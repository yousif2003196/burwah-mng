import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_profile.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_wallet.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';

/// عقد وحدة رئيس المشرفين (`api/BossOfSupervisor`).
///
/// عمليات الكتابة ترجع رسالة الخادم عند النجاح لعرضها للمستخدم.
abstract class BossSupervisorRepository {
  Future<Either<Failure, BossOperationsPage>> getOperations({
    String? search,
    BossOperationFilter filter = BossOperationFilter.all,
  });

  Future<Either<Failure, String>> reevaluateRequest(
    int id, {
    required ReevaluateActionType actionType,
    required String directiveText,
  });

  Future<Either<Failure, String>> resolveDispute(
    int id, {
    required DisputeResolutionType resolutionType,
    required String officialRulingText,
  });

  Future<Either<Failure, List<MerchantComplaintSummary>>> getMerchantComplaints();

  Future<Either<Failure, MerchantComplaintDetails>> getComplaintDetails(int id);

  Future<Either<Failure, SummonChatResult>> summonSupervisorChat(
    int complaintId, {
    required SummonTopic topic,
    required String initialMessage,
    required bool attachCaseDocument,
  });

  Future<Either<Failure, String>> unbanAndInvestigate(
    int complaintId,
    UnbanInvestigationRequest request,
  );

  Future<Either<Failure, String>> decideComplaint(
    int complaintId, {
    required ComplaintDecisionType decisionType,
    required String notes,
  });

  Future<Either<Failure, BossProfile>> getProfile();

  Future<Either<Failure, BossWallet>> getWallet();

  Future<Either<Failure, BossPayoutResult>> requestPayout(
    BossPayoutRequest request,
  );
}
