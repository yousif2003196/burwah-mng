import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_boss_operations_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/reevaluate_request_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/resolve_dispute_usecase.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';

class BossOperationsState {
  final BossLoadState<BossOperationsPage> page;
  final BossOperationFilter filter;
  final String search;

  const BossOperationsState({
    this.page = const BossLoading(),
    this.filter = BossOperationFilter.all,
    this.search = '',
  });

  BossOperationsState copyWith({
    BossLoadState<BossOperationsPage>? page,
    BossOperationFilter? filter,
    String? search,
  }) {
    return BossOperationsState(
      page: page ?? this.page,
      filter: filter ?? this.filter,
      search: search ?? this.search,
    );
  }
}

/// قائمة العمليات الحرجة والنزاعات + قرارات إعادة المراجعة وحسم النزاع.
class BossOperationsCubit extends Cubit<BossOperationsState> {
  BossOperationsCubit({
    required this.getOperations,
    required this.reevaluateRequest,
    required this.resolveDispute,
  }) : super(const BossOperationsState());

  final GetBossOperationsUseCase getOperations;
  final ReevaluateRequestUseCase reevaluateRequest;
  final ResolveDisputeUseCase resolveDispute;
  int _requestId = 0;

  Future<void> load() => _fetch(showLoading: true);

  /// تحديث بدون شاشة تحميل (سحب للتحديث / بعد قرار).
  Future<void> refresh() => _fetch(showLoading: false);

  Future<void> changeFilter(BossOperationFilter filter) {
    if (filter == state.filter) return Future.value();
    emit(state.copyWith(filter: filter));
    return _fetch(showLoading: true);
  }

  Future<void> search(String query) {
    final trimmed = query.trim();
    if (trimmed == state.search) return Future.value();
    emit(state.copyWith(search: trimmed));
    return _fetch(showLoading: true);
  }

  Future<BossActionResult<void>> reevaluate(
    int id, {
    required ReevaluateActionType actionType,
    required String directiveText,
  }) async {
    final result = await reevaluateRequest(
      id,
      actionType: actionType,
      directiveText: directiveText.trim(),
    );
    return _afterAction(result.fold(
      (failure) => BossActionResult<void>.failure(failure.message),
      (message) => BossActionResult<void>.success(message),
    ));
  }

  Future<BossActionResult<void>> resolve(
    int id, {
    required DisputeResolutionType resolutionType,
    required String officialRulingText,
  }) async {
    final result = await resolveDispute(
      id,
      resolutionType: resolutionType,
      officialRulingText: officialRulingText.trim(),
    );
    return _afterAction(result.fold(
      (failure) => BossActionResult<void>.failure(failure.message),
      (message) => BossActionResult<void>.success(message),
    ));
  }

  Future<BossActionResult<void>> _afterAction(
    BossActionResult<void> outcome,
  ) async {
    if (outcome.success && !isClosed) await refresh();
    return outcome;
  }

  Future<void> _fetch({required bool showLoading}) async {
    final id = ++_requestId;
    if (showLoading || state.page is! BossLoaded<BossOperationsPage>) {
      emit(state.copyWith(page: const BossLoading<BossOperationsPage>()));
    }
    final result = await getOperations(
      search: state.search,
      filter: state.filter,
    );
    if (isClosed || id != _requestId) return;
    emit(state.copyWith(
      page: result.fold<BossLoadState<BossOperationsPage>>(
        (failure) => BossLoadFailure(failure.message),
        (page) => BossLoaded(page),
      ),
    ));
  }
}
