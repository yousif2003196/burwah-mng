import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_boss_operations_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_merchant_complaints_usecase.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';

/// مؤشرات لوحة المتابعة المتاحة من الـ API.
class BossOverviewSnapshot {
  final int totalOperations;
  final List<BossOperation> latestOperations;
  final int openComplaints;

  const BossOverviewSnapshot({
    required this.totalOperations,
    required this.latestOperations,
    required this.openComplaints,
  });
}

typedef BossOverviewState = BossLoadState<BossOverviewSnapshot>;

/// يجمع العمليات الحرجة وعدد التظلمات المفتوحة للوحة "نظرة عامة".
class BossOverviewCubit extends Cubit<BossOverviewState> {
  BossOverviewCubit({
    required this.getOperations,
    required this.getComplaints,
  }) : super(const BossLoading());

  final GetBossOperationsUseCase getOperations;
  final GetMerchantComplaintsUseCase getComplaints;
  int _requestId = 0;

  Future<void> load() async {
    final id = ++_requestId;
    if (state is! BossLoaded<BossOverviewSnapshot>) emit(const BossLoading());
    final operationsResult = await getOperations();
    final complaintsResult = await getComplaints();
    if (isClosed || id != _requestId) return;

    final operationsFailure = operationsResult.fold((f) => f, (_) => null);
    final complaintsFailure = complaintsResult.fold((f) => f, (_) => null);
    final failure = operationsFailure ?? complaintsFailure;
    if (failure != null) {
      emit(BossLoadFailure(failure.message));
      return;
    }
    final page = operationsResult.getOrElse(
      () => const BossOperationsPage(totalOperations: 0, operations: []),
    );
    final complaints = complaintsResult.getOrElse(() => const []);
    emit(BossLoaded(BossOverviewSnapshot(
      totalOperations: page.totalOperations,
      latestOperations: page.operations.take(5).toList(),
      openComplaints:
          complaints.where((complaint) => !complaint.status.isFinal).length,
    )));
  }
}
