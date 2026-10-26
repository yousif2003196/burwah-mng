import 'package:equatable/equatable.dart';

import 'package:barwah_app/features/finance/domain/entities/finance_summary_entity.dart';

abstract class FinanceDashboardState extends Equatable {
  const FinanceDashboardState();
  @override
  List<Object?> get props => [];
}

class FinanceDashboardInitial extends FinanceDashboardState {}
class FinanceDashboardLoading extends FinanceDashboardState {}
class FinanceDashboardLoaded extends FinanceDashboardState {
  final FinanceSummaryEntity summary;
  const FinanceDashboardLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}
class FinanceDashboardError extends FinanceDashboardState {
  final String message;
  const FinanceDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}