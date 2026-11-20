import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/head_supervisor/domain/entities/boss_wallet.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_boss_wallet_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/request_boss_payout_usecase.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';

typedef BossWalletState = BossLoadState<BossWallet>;

/// محفظة رئيس المشرفين: الرصيد والسجل + طلب الصرف الفوري.
class BossWalletCubit extends Cubit<BossWalletState> {
  BossWalletCubit({required this.getWallet, required this.requestPayout})
      : super(const BossLoading());

  final GetBossWalletUseCase getWallet;
  final RequestBossPayoutUseCase requestPayout;
  int _requestId = 0;

  Future<void> load() async {
    final id = ++_requestId;
    if (state is! BossLoaded<BossWallet>) emit(const BossLoading());
    final result = await getWallet();
    if (isClosed || id != _requestId) return;
    emit(result.fold<BossWalletState>(
      (failure) => BossLoadFailure(failure.message),
      (wallet) => BossLoaded(wallet),
    ));
  }

  /// يرسل طلب الصرف ثم يعيد تحميل المحفظة عند النجاح.
  ///
  /// الخادم يتحقق من الحد الأدنى والرصيد، ورسالته العربية تعود كما هي.
  Future<BossActionResult<BossPayoutResult>> payout(
    BossPayoutRequest request,
  ) async {
    final result = await requestPayout(request);
    final outcome = result.fold(
      (failure) => BossActionResult<BossPayoutResult>.failure(failure.message),
      (payout) => BossActionResult<BossPayoutResult>.success(
          payout.message, payout),
    );
    if (outcome.success && !isClosed) await load();
    return outcome;
  }
}
