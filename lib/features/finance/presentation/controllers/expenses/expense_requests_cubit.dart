import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';
import 'package:barwah_app/features/finance/domain/usecases/edit_expense_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_expense_requests_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/submit_expense_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/update_expense_request_status_usecase.dart';
import 'package:barwah_app/features/finance/presentation/controllers/expenses/expense_requests_state.dart';

class ExpenseRequestsCubit extends Cubit<ExpenseRequestsState> {
  final GetExpenseRequestsUseCase getExpenseRequestsUseCase;
  final SubmitExpenseRequestUseCase submitExpenseRequestUseCase;
  final UpdateExpenseRequestStatusUseCase updateExpenseRequestStatusUseCase;
  final EditExpenseRequestUseCase editExpenseRequestUseCase;

  ExpenseRequestsCubit({
    required this.getExpenseRequestsUseCase,
    required this.submitExpenseRequestUseCase,
    required this.updateExpenseRequestStatusUseCase,
    required this.editExpenseRequestUseCase,
  }) : super(const ExpenseRequestsState());

  Future<void> loadRequests() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await getExpenseRequestsUseCase();
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

  Future<Either<Failure, ExpenseRequestEntity>> submitRequest({
    required double amount,
    required String bankAccountId,
    required String reason,
    String category = 'other',
    String beneficiaryName = '',
    String? attachmentName,
    String? attachmentPath,
  }) async {
    if (state.isSubmitting) {
      return const Left(ServerFailure());
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await submitExpenseRequestUseCase(
      amount: amount,
      bankAccountId: bankAccountId,
      reason: reason,
      category: category,
      beneficiaryName: beneficiaryName,
      attachmentName: attachmentName,
      attachmentPath: attachmentPath,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        ));
        return Left(failure);
      },
      (request) {
        emit(state.copyWith(
          requests: [...state.requests, request],
          isSubmitting: false,
          clearError: true,
        ));
        return Right(request);
      },
    );
  }

  Future<Either<Failure, void>> updateRequestStatus({
    required String requestId,
    required ExpenseRequestStatus status,
    String? reason,
  }) async {
    final result = await updateExpenseRequestStatusUseCase(
      requestId: requestId,
      status: status,
      reason: reason,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return Left(failure);
      },
      (_) {
        final requests = state.requests.map((request) {
          if (request.id != requestId) return request;
          return request.copyWith(
            status: status,
            decisionReason: reason,
            clearDecisionReason: reason == null,
          );
        }).toList(growable: false);
        emit(state.copyWith(requests: requests, clearError: true));
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, ExpenseRequestEntity>> editRequest({
    required String requestId,
    required double amount,
    required String bankAccountId,
    required String reason,
    required String category,
    required String beneficiaryName,
    String? attachmentName,
    String? attachmentPath,
  }) async {
    if (state.isSubmitting) return const Left(ServerFailure());
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await editExpenseRequestUseCase(
      requestId: requestId,
      amount: amount,
      bankAccountId: bankAccountId,
      reason: reason,
      category: category,
      beneficiaryName: beneficiaryName,
      attachmentName: attachmentName,
      attachmentPath: attachmentPath,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSubmitting: false, errorMessage: failure.message));
        return Left(failure);
      },
      (request) {
        final requests = state.requests
            .map((item) => item.id == request.id ? request : item)
            .toList(growable: false);
        emit(state.copyWith(
          requests: requests,
          isSubmitting: false,
          clearError: true,
        ));
        return Right(request);
      },
    );
  }
}
