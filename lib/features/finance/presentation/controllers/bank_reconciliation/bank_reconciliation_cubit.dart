import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../../domain/entities/bank_link_request_entity.dart';
import '../../../domain/usecases/approve_bank_link_request_usecase.dart';
import '../../../domain/usecases/freeze_bank_link_request_usecase.dart';
import '../../../domain/usecases/get_bank_link_requests_usecase.dart';
import '../../../domain/usecases/reject_bank_link_request_usecase.dart';
import '../../../domain/usecases/request_iban_certificate_usecase.dart';
import '../../../domain/usecases/reject_frozen_bank_link_request_usecase.dart';
import '../../../domain/usecases/restore_frozen_bank_link_request_usecase.dart';
import 'bank_reconciliation_state.dart';

class BankReconciliationCubit extends Cubit<BankReconciliationState> {
  final GetBankLinkRequestsUseCase getRequestsUseCase;
  final ApproveBankLinkRequestUseCase approveRequestUseCase;
  final RequestIbanCertificateUseCase requestIbanCertificateUseCase;
  final FreezeBankLinkRequestUseCase freezeRequestUseCase;
  final RejectBankLinkRequestUseCase rejectRequestUseCase;
  final RestoreFrozenBankLinkRequestUseCase restoreFrozenRequestUseCase;
  final RejectFrozenBankLinkRequestUseCase rejectFrozenRequestUseCase;

  BankReconciliationCubit({
    required this.getRequestsUseCase,
    required this.approveRequestUseCase,
    required this.requestIbanCertificateUseCase,
    required this.freezeRequestUseCase,
    required this.rejectRequestUseCase,
    required this.restoreFrozenRequestUseCase,
    required this.rejectFrozenRequestUseCase,
  }) : super(const BankReconciliationState());

  Future<void> loadRequests() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await getRequestsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (requests) => emit(state.copyWith(
        requests: requests
            .where((request) => request.status == BankLinkRequestStatus.pending)
            .toList(growable: false),
        archiveRequests: requests
            .where((request) => request.status != BankLinkRequestStatus.pending)
            .toList(growable: false),
        isLoading: false,
        clearError: true,
      )),
    );
  }

  Future<Either<Failure, void>> approveRequest(String requestId) {
    final request = state.requests.firstWhere((item) => item.id == requestId);
    return _perform(
      requestId,
      () => approveRequestUseCase(requestId),
      archivedRequest: request.copyWith(
        status: BankLinkRequestStatus.pendingManagementApproval,
      ),
    );
  }

  Future<Either<Failure, void>> requestIbanCertificate(String requestId) {
    final request = state.requests.firstWhere((item) => item.id == requestId);
    return _perform(
      requestId,
      () => requestIbanCertificateUseCase(requestId),
      archivedRequest: request.copyWith(
        status: BankLinkRequestStatus.ibanCertificateRequested,
      ),
    );
  }

  Future<Either<Failure, void>> freezeRequest(
    String requestId,
    String reason,
  ) {
    final request = state.requests.firstWhere(
      (item) => item.id == requestId,
    );
    return _perform(
      requestId,
      () => freezeRequestUseCase(requestId, reason),
      archivedRequest: request.copyWith(
        status: BankLinkRequestStatus.frozen,
        decisionReason: reason,
      ),
    );
  }

  Future<Either<Failure, void>> rejectRequest(
    String requestId,
    String reason,
  ) {
    final request = state.requests.firstWhere((item) => item.id == requestId);
    return _perform(
      requestId,
      () => rejectRequestUseCase(requestId, reason),
      archivedRequest: request.copyWith(
        status: BankLinkRequestStatus.rejected,
        decisionReason: reason,
      ),
    );
  }

  Future<Either<Failure, void>> restoreFrozenRequest(String requestId) {
    final request = state.archiveRequests.firstWhere(
      (item) => item.id == requestId,
    );
    return _perform(
      requestId,
      () => restoreFrozenRequestUseCase(requestId),
      restoredRequest: request.copyWith(
        status: BankLinkRequestStatus.pending,
        clearDecisionReason: true,
      ),
      fromFrozen: true,
    );
  }

  Future<Either<Failure, void>> rejectFrozenRequest(
    String requestId,
    String reason,
  ) {
    final request = state.archiveRequests.firstWhere(
      (item) =>
          item.id == requestId && item.status == BankLinkRequestStatus.frozen,
    );
    return _perform(
      requestId,
      () => rejectFrozenRequestUseCase(requestId, reason),
      archivedRequest: request.copyWith(
        status: BankLinkRequestStatus.rejected,
        decisionReason: reason,
      ),
      fromFrozen: true,
    );
  }

  Future<Either<Failure, void>> _perform(
    String requestId,
    Future<Either<Failure, void>> Function() action, {
    BankLinkRequestEntity? archivedRequest,
    BankLinkRequestEntity? restoredRequest,
    bool fromFrozen = false,
  }) async {
    if (state.processingRequestId != null) {
      return const Left(ServerFailure());
    }
    emit(state.copyWith(
      processingRequestId: requestId,
      clearError: true,
    ));

    final result = await action();
    return result.fold(
      (failure) {
        emit(state.copyWith(
          clearProcessingRequestId: true,
          errorMessage: failure.message,
        ));
        return Left(failure);
      },
      (_) {
        emit(state.copyWith(
          requests: [
            ...state.requests.where((request) => request.id != requestId),
            if (restoredRequest != null) restoredRequest,
          ],
          archiveRequests: [
            ...state.archiveRequests
                .where((request) => !fromFrozen || request.id != requestId),
            if (archivedRequest != null) archivedRequest,
          ],
          clearProcessingRequestId: true,
          clearError: true,
        ));
        return const Right(null);
      },
    );
  }
}
