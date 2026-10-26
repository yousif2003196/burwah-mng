import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_frozen_withdrawals_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/reject_and_forfeit_withdrawal_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/restore_frozen_withdrawal_usecase.dart';
import 'package:barwah_app/features/finance/presentation/controllers/frozen_requests/frozen_requests_state.dart';

class FrozenRequestsCubit extends Cubit<FrozenRequestsState> {
  final GetFrozenWithdrawalsUseCase getFrozenWithdrawalsUseCase;
  final RestoreFrozenWithdrawalUseCase restoreFrozenWithdrawalUseCase;
  final RejectAndForfeitWithdrawalUseCase rejectAndForfeitWithdrawalUseCase;

  FrozenRequestsCubit({
    required this.getFrozenWithdrawalsUseCase,
    required this.restoreFrozenWithdrawalUseCase,
    required this.rejectAndForfeitWithdrawalUseCase,
  }) : super(const FrozenRequestsState());

  Future<void> loadRequests() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await getFrozenWithdrawalsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (requests) => emit(state.copyWith(
        requests: requests,
        isLoading: false,
        clearError: true,
      )),
    );
  }

  Future<Either<Failure, void>> restoreRequest(
      WithdrawalRequestEntity request) async {
    if (state.processingRequestId != null) {
      return const Left(ServerFailure());
    }
    emit(state.copyWith(
      processingRequestId: request.id,
      clearError: true,
    ));

    final result = await restoreFrozenWithdrawalUseCase(
      requestId: request.id,
      beneficiaryType: request.beneficiaryType,
    );
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
          requests: state.requests
              .where((item) => !_isSameRequest(item, request))
              .toList(growable: false),
          clearProcessingRequestId: true,
          clearError: true,
        ));
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, void>> rejectAndForfeitRequest({
    required WithdrawalRequestEntity request,
    required String reason,
  }) async {
    if (state.processingRequestId != null) {
      return const Left(ServerFailure());
    }
    emit(state.copyWith(
      processingRequestId: request.id,
      clearError: true,
    ));

    final result = await rejectAndForfeitWithdrawalUseCase(
      requestId: request.id,
      beneficiaryType: request.beneficiaryType,
      reason: reason,
    );
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
          requests: state.requests
              .where((item) => !_isSameRequest(item, request))
              .toList(growable: false),
          clearProcessingRequestId: true,
          clearError: true,
        ));
        return const Right(null);
      },
    );
  }

  bool _isSameRequest(
    WithdrawalRequestEntity first,
    WithdrawalRequestEntity second,
  ) =>
      first.id == second.id && first.beneficiaryType == second.beneficiaryType;
}
