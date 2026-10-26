import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
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
  final ProductSupervisorAuditRepository? auditRepository;

  WasalnyAdsCubit({
    required this.getAds,
    required this.updateAdStatus,
    this.auditRepository,
  }) : super(const WasalnyAdsLoading());

  Future<void> loadAds() async {
    emit(const WasalnyAdsLoading());
    try {
      final ads = await getAds();
      for (final ad in ads.where((item) =>
          item.status == WasalnyAdStatus.pending ||
          item.status == WasalnyAdStatus.awaitingApproval)) {
        try {
          await LocalEventStore().publish(
            LocalEvent(
              id: 'wasalny-new-ad-${ad.id}',
              recipient: 'wasalny',
              source: 'wasalny',
              titleAr: 'إعلان وصلني جديد بانتظار المراجعة',
              titleEn: 'New Wasalny ad awaiting review',
              messageAr: '${ad.titleAr} من ${ad.sellerNameAr}',
              messageEn: '${ad.titleEn} by ${ad.sellerNameEn}',
              createdAt: ad.submittedAt,
            ),
          );
        } catch (error, stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'Wasalny ads',
              context: ErrorDescription('while publishing a new-ad notification'),
            ),
          );
        }
      }
      emit(WasalnyAdsLoaded(ads));
    } catch (error) {
      emit(WasalnyAdsLoadFailure(error));
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
      final now = DateTime.now();
      await auditRepository?.recordEntry(
        ProductSupervisorAuditEntry(
          id: now.microsecondsSinceEpoch.toString(),
          actionKey: 'wasalny_ad_${status.name}',
          subject: updated.titleAr,
          details: [
            updated.reference,
            if (decisionNote?.isNotEmpty == true) decisionNote!,
          ].join(' • '),
          occurredAt: now,
        ),
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
