import 'package:equatable/equatable.dart';

import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';

class ExpenseRequestsState extends Equatable {
  final List<ExpenseRequestEntity> requests;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  const ExpenseRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  ExpenseRequestsState copyWith({
    List<ExpenseRequestEntity>? requests,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExpenseRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [requests, isLoading, isSubmitting, errorMessage];
}
