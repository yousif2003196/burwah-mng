import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/finance/domain/usecases/get_finance_summary_usecase.dart';
import 'package:barwah_app/features/finance/presentation/controllers/dashboard/finance_dashboard_state.dart';

class FinanceDashboardCubit extends Cubit<FinanceDashboardState> {
  final GetFinanceSummaryUseCase getFinanceSummaryUseCase;

  FinanceDashboardCubit({required this.getFinanceSummaryUseCase}) : super(FinanceDashboardInitial());

  Future<void> loadDashboardData() async {
    emit(FinanceDashboardLoading());
    final result = await getFinanceSummaryUseCase();
    result.fold(
          (failure) => emit(FinanceDashboardError(failure.message)),
          (summary) => emit(FinanceDashboardLoaded(summary)),
    );
  }
}