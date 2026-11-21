import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/head_supervisor/domain/entities/boss_profile.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_boss_profile_usecase.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';

typedef BossProfileState = BossLoadState<BossProfile>;

/// الملف الشخصي والسجل الرقابي لرئيس المشرفين.
class BossProfileCubit extends Cubit<BossProfileState> {
  BossProfileCubit({required this.getProfile}) : super(const BossLoading());

  final GetBossProfileUseCase getProfile;
  int _requestId = 0;

  Future<void> load() async {
    final id = ++_requestId;
    if (state is! BossLoaded<BossProfile>) emit(const BossLoading());
    final result = await getProfile();
    if (isClosed || id != _requestId) return;
    emit(result.fold<BossProfileState>(
      (failure) => BossLoadFailure(failure.message),
      (profile) => BossLoaded(profile),
    ));
  }
}
