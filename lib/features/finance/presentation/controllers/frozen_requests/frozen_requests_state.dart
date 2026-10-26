import 'package:equatable/equatable.dart';

import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';

class FrozenRequestsState extends Equatable {
  final List<WithdrawalRequestEntity> requests;
  final bool isLoading;
  final String? processingRequestId;
  final String? errorMessage;

  const FrozenRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.processingRequestId,
    this.errorMessage,
  });

  FrozenRequestsState copyWith({
    List<WithdrawalRequestEntity>? requests,
    bool? isLoading,
    String? processingRequestId,
    String? errorMessage,
    bool clearProcessingRequestId = false,
    bool clearError = false,
  }) {
    return FrozenRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      processingRequestId: clearProcessingRequestId
          ? null
          : processingRequestId ?? this.processingRequestId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [requests, isLoading, processingRequestId, errorMessage];
}
