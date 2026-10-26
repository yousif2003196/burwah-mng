import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_edit_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_entity.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_bank_account_edit_requests_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_bank_accounts_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/submit_bank_account_edit_request_usecase.dart';
import 'package:barwah_app/features/finance/presentation/controllers/bank_accounts/bank_accounts_state.dart';

class BankAccountsCubit extends Cubit<BankAccountsState> {
  final GetBankAccountsUseCase getBankAccountsUseCase;
  final GetBankAccountEditRequestsUseCase getBankAccountEditRequestsUseCase;
  final SubmitBankAccountEditRequestUseCase submitBankAccountEditRequestUseCase;

  BankAccountsCubit({
    required this.getBankAccountsUseCase,
    required this.getBankAccountEditRequestsUseCase,
    required this.submitBankAccountEditRequestUseCase,
  }) : super(BankAccountsInitial());

  Future<void> loadBankAccounts() async {
    emit(BankAccountsLoading());
    final accountsResult = await getBankAccountsUseCase();
    List<BankAccountEntity>? accounts;
    Failure? failure;
    accountsResult.fold(
      (value) => failure = value,
      (value) => accounts = value,
    );
    if (failure != null) {
      emit(BankAccountsError(failure!.message));
      return;
    }

    final requestsResult = await getBankAccountEditRequestsUseCase();
    List<BankAccountEditRequestEntity>? requests;
    requestsResult.fold(
      (value) => failure = value,
      (value) => requests = value,
    );
    if (failure != null) {
      emit(BankAccountsError(failure!.message));
      return;
    }

    emit(BankAccountsLoaded(accounts!, editRequests: requests!));
  }

  Future<Either<Failure, BankAccountEditRequestEntity>> submitEditRequest({
    required String accountId,
    required String proposedBankName,
    required String proposedAccountType,
    required String proposedIban,
  }) async {
    final currentState = state;
    if (currentState is! BankAccountsLoaded) {
      return const Left(ServerFailure());
    }
    if (currentState.submittingAccountId != null) {
      return const Left(ServerFailure());
    }

    emit(currentState.copyWith(submittingAccountId: accountId));
    final result = await submitBankAccountEditRequestUseCase(
      accountId: accountId,
      proposedBankName: proposedBankName,
      proposedAccountType: proposedAccountType,
      proposedIban: proposedIban,
    );

    return result.fold(
      (failure) {
        emit(currentState.copyWith(clearSubmittingAccountId: true));
        return Left(failure);
      },
      (request) {
        emit(currentState.copyWith(
          editRequests: [...currentState.editRequests, request],
          clearSubmittingAccountId: true,
        ));
        return Right(request);
      },
    );
  }
}
