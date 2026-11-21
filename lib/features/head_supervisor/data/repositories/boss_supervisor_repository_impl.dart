import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:barwah_app/core/errors/failure_mapper.dart';
import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/boss_supervisor_remote_data_source.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_profile.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_wallet.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class BossSupervisorRepositoryImpl implements BossSupervisorRepository {
  final BossSupervisorRemoteDataSource dataSource;

  const BossSupervisorRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, BossOperationsPage>> getOperations({
    String? search,
    BossOperationFilter filter = BossOperationFilter.all,
  }) {
    return _guard(
      'orders-and-disputes',
      () => dataSource.getOperations(search: search, filter: filter),
    );
  }

  @override
  Future<Either<Failure, String>> reevaluateRequest(
    int id, {
    required ReevaluateActionType actionType,
    required String directiveText,
  }) {
    return _guard(
      'reevaluate $id',
      () => dataSource.reevaluateRequest(
        id,
        actionType: actionType,
        directiveText: directiveText,
      ),
    );
  }

  @override
  Future<Either<Failure, String>> resolveDispute(
    int id, {
    required DisputeResolutionType resolutionType,
    required String officialRulingText,
  }) {
    return _guard(
      'resolve dispute $id',
      () => dataSource.resolveDispute(
        id,
        resolutionType: resolutionType,
        officialRulingText: officialRulingText,
      ),
    );
  }

  @override
  Future<Either<Failure, List<MerchantComplaintSummary>>>
      getMerchantComplaints() {
    return _guard('merchant-complaints', dataSource.getMerchantComplaints);
  }

  @override
  Future<Either<Failure, MerchantComplaintDetails>> getComplaintDetails(
    int id,
  ) {
    return _guard(
      'complaint details $id',
      () => dataSource.getComplaintDetails(id),
    );
  }

  @override
  Future<Either<Failure, SummonChatResult>> summonSupervisorChat(
    int complaintId, {
    required SummonTopic topic,
    required String initialMessage,
    required bool attachCaseDocument,
  }) {
    return _guard(
      'summon chat $complaintId',
      () => dataSource.summonSupervisorChat(
        complaintId,
        topic: topic,
        initialMessage: initialMessage,
        attachCaseDocument: attachCaseDocument,
      ),
    );
  }

  @override
  Future<Either<Failure, String>> unbanAndInvestigate(
    int complaintId,
    UnbanInvestigationRequest request,
  ) {
    return _guard(
      'unban and investigate $complaintId',
      () => dataSource.unbanAndInvestigate(complaintId, request),
    );
  }

  @override
  Future<Either<Failure, String>> decideComplaint(
    int complaintId, {
    required ComplaintDecisionType decisionType,
    required String notes,
  }) {
    return _guard(
      'complaint decision $complaintId',
      () => dataSource.decideComplaint(
        complaintId,
        decisionType: decisionType,
        notes: notes,
      ),
    );
  }

  @override
  Future<Either<Failure, BossProfile>> getProfile() {
    return _guard('profile', dataSource.getProfile);
  }

  @override
  Future<Either<Failure, BossWallet>> getWallet() {
    return _guard('wallet', dataSource.getWallet);
  }

  @override
  Future<Either<Failure, BossPayoutResult>> requestPayout(
    BossPayoutRequest request,
  ) {
    return _guard('payout', () => dataSource.requestPayout(request));
  }

  Future<Either<Failure, T>> _guard<T>(
    String label,
    Future<T> Function() call,
  ) async {
    try {
      return Right(await call());
    } on BossApiException catch (error) {
      debugPrint('BossOfSupervisor $label rejected: ${error.message}');
      return Left(error.message.isEmpty
          ? const ServerFailure()
          : ServerFailure(error.message));
    } on Object catch (error) {
      debugPrint('BossOfSupervisor $label failed: $error');
      return Left(failureFrom(error));
    }
  }
}
