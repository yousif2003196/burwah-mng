import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/close_provider_escalation_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/decide_service_escalation_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_provider_escalations_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_service_escalations_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_used_complaint_escalations_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/resolve_used_complaint_escalation_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/suspend_escalated_provider_usecase.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';

/// حالة لوحة تصعيدات: العناصر + التحميل الأول + فشل بدون بيانات + العنصر المشغول.
class HeadEscalationsState<T> {
  final List<T> items;
  final bool loading;
  final bool failed;
  final int? busyId;

  const HeadEscalationsState({
    this.items = const [],
    this.loading = true,
    this.failed = false,
    this.busyId,
  });

  HeadEscalationsState<T> copyWith({
    List<T>? items,
    bool? loading,
    bool? failed,
    int? busyId,
    bool clearBusy = false,
  }) {
    return HeadEscalationsState<T>(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      failed: failed ?? this.failed,
      busyId: clearBusy ? null : busyId ?? this.busyId,
    );
  }
}

/// أساس مشترك: تحميل القائمة وتنفيذ قرار على عنصر ثم إعادة التحميل.
abstract class HeadEscalationsCubit<T> extends Cubit<HeadEscalationsState<T>> {
  HeadEscalationsCubit() : super(HeadEscalationsState<T>());

  Future<Either<Failure, List<T>>> fetch();

  Future<void> load() async {
    final result = await fetch();
    if (isClosed) return;
    emit(result.fold(
      (_) => state.copyWith(loading: false, failed: state.items.isEmpty),
      (items) => state.copyWith(items: items, loading: false, failed: false),
    ));
  }

  Future<BossActionResult<void>> runAction(
    int id,
    Future<Either<Failure, Unit>> Function() action,
  ) async {
    emit(state.copyWith(busyId: id));
    final result = await action();
    if (isClosed) return const BossActionResult.failure('');
    final outcome = result.fold(
      (failure) => BossActionResult<void>.failure(failure.message),
      (_) => const BossActionResult<void>.success(''),
    );
    if (outcome.success) await load();
    if (!isClosed) emit(state.copyWith(clearBusy: true));
    return outcome;
  }
}

class HeadServiceEscalationsCubit
    extends HeadEscalationsCubit<HeadServiceEscalation> {
  HeadServiceEscalationsCubit({required this.getItems, required this.decide});

  final GetServiceEscalationsUseCase getItems;
  final DecideServiceEscalationUseCase decide;

  @override
  Future<Either<Failure, List<HeadServiceEscalation>>> fetch() => getItems();

  Future<BossActionResult<void>> decideRequest(
    int id,
    ServiceEscalationDecision decision, {
    String note = '',
  }) {
    return runAction(id, () => decide(id, decision, note: note));
  }
}

class HeadProviderEscalationsCubit
    extends HeadEscalationsCubit<HeadProviderEscalation> {
  HeadProviderEscalationsCubit({
    required this.getItems,
    required this.suspendProvider,
    required this.closeEscalation,
  });

  final GetProviderEscalationsUseCase getItems;
  final SuspendEscalatedProviderUseCase suspendProvider;
  final CloseProviderEscalationUseCase closeEscalation;

  @override
  Future<Either<Failure, List<HeadProviderEscalation>>> fetch() => getItems();

  Future<BossActionResult<void>> suspend(int providerId, String reason) =>
      runAction(providerId, () => suspendProvider(providerId, reason));

  Future<BossActionResult<void>> closeWithoutAction(
    int providerId,
    String note,
  ) =>
      runAction(providerId, () => closeEscalation(providerId, note));
}

class HeadUsedComplaintEscalationsCubit
    extends HeadEscalationsCubit<HeadUsedComplaintEscalation> {
  HeadUsedComplaintEscalationsCubit({
    required this.getItems,
    required this.resolveComplaint,
  });

  final GetUsedComplaintEscalationsUseCase getItems;
  final ResolveUsedComplaintEscalationUseCase resolveComplaint;

  @override
  Future<Either<Failure, List<HeadUsedComplaintEscalation>>> fetch() =>
      getItems();

  Future<BossActionResult<void>> resolve(int complaintId, String note) =>
      runAction(complaintId, () => resolveComplaint(complaintId, note));
}
