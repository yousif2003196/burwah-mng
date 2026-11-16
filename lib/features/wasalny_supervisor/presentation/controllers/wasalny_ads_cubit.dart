import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_ad.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/get_wasalny_ads_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/update_wasalny_ad_status_usecase.dart';

sealed class WasalnyAdsState {
  const WasalnyAdsState();
}

class WasalnyAdsLoading extends WasalnyAdsState {
  const WasalnyAdsLoading();
}

class WasalnyAdsLoadFailure extends WasalnyAdsState {
  final Object error;

  const WasalnyAdsLoadFailure(this.error);
}

class WasalnyAdsLoaded extends WasalnyAdsState {
  final List<WasalnyAd> ads;

  const WasalnyAdsLoaded(this.ads);
}

class WasalnyAdsCubit extends Cubit<WasalnyAdsState> {
  final GetWasalnyAdsUseCase getAds;
  final UpdateWasalnyAdStatusUseCase updateAdStatus;

  WasalnyAdsCubit({
    required this.getAds,
    required this.updateAdStatus,
  }) : super(const WasalnyAdsLoading());

  Future<void> loadAds() async {
    emit(const WasalnyAdsLoading());
    try {
      emit(WasalnyAdsLoaded(await getAds()));
    } catch (error) {
      emit(WasalnyAdsLoadFailure(error));
    }
  }

  /// يحدّث القائمة من غير شاشة تحميل (للسحب للتحديث).
  Future<void> refresh() async {
    try {
      emit(WasalnyAdsLoaded(await getAds()));
    } catch (_) {
      // نسيب القائمة الحالية زي ما هي لو التحديث فشل.
    }
  }

  Future<bool> decide({
    required String id,
    required WasalnyAdStatus status,
    String? decisionNote,
  }) async {
    final current = state;
    if (current is! WasalnyAdsLoaded) return false;
    try {
      final updated = await updateAdStatus(
        id: id,
        status: status,
        decisionNote: decisionNote,
      );
      emit(
        WasalnyAdsLoaded([
          for (final ad in current.ads) ad.id == id ? updated : ad,
        ]),
      );
      return true;
    } catch (error) {
      emit(WasalnyAdsLoadFailure(error));
      return false;
    }
  }
}