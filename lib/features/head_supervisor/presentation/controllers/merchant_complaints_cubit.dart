import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_merchant_complaints_usecase.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';

typedef MerchantComplaintsState = BossLoadState<List<MerchantComplaintSummary>>;

/// قائمة تظلمات التجار ضد المشرفين.
class MerchantComplaintsCubit extends Cubit<MerchantComplaintsState> {
  MerchantComplaintsCubit({required this.getComplaints})
      : super(const BossLoading());

  final GetMerchantComplaintsUseCase getComplaints;
  int _requestId = 0;

  Future<void> load() => _fetch(showLoading: true);

  Future<void> refresh() => _fetch(showLoading: false);

  Future<void> _fetch({required bool showLoading}) async {
    final id = ++_requestId;
    if (showLoading || state is! BossLoaded<List<MerchantComplaintSummary>>) {
      emit(const BossLoading());
    }
    final result = await getComplaints();
    if (isClosed || id != _requestId) return;
    emit(result.fold<MerchantComplaintsState>(
      (failure) => BossLoadFailure(failure.message),
      (complaints) => BossLoaded(complaints),
    ));
  }
}
