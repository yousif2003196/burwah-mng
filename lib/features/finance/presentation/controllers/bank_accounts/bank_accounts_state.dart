import 'package:equatable/equatable.dart';

import 'package:barwah_app/features/finance/domain/entities/bank_account_edit_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_entity.dart';

abstract class BankAccountsState extends Equatable {
  const BankAccountsState();

  @override
  List<Object?> get props => [];
}

class BankAccountsInitial extends BankAccountsState {}

class BankAccountsLoading extends BankAccountsState {}

class BankAccountsLoaded extends BankAccountsState {
  final List<BankAccountEntity> accounts;
  final List<BankAccountEditRequestEntity> editRequests;
  final String? submittingAccountId;

  const BankAccountsLoaded(
    this.accounts, {
    this.editRequests = const [],
    this.submittingAccountId,
  });

  BankAccountsLoaded copyWith({
    List<BankAccountEditRequestEntity>? editRequests,
    String? submittingAccountId,
    bool clearSubmittingAccountId = false,
  }) {
    return BankAccountsLoaded(
      accounts,
      editRequests: editRequests ?? this.editRequests,
      submittingAccountId: clearSubmittingAccountId
          ? null
          : submittingAccountId ?? this.submittingAccountId,
    );
  }

  @override
  List<Object?> get props => [accounts, editRequests, submittingAccountId];
}

class BankAccountsError extends BankAccountsState {
  final String message;

  const BankAccountsError(this.message);

  @override
  List<Object> get props => [message];
}
