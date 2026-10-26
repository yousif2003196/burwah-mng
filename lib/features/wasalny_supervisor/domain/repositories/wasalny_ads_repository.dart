import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_ad.dart';

abstract interface class WasalnyAdsRepository {
  Future<List<WasalnyAd>> getAds();

  Future<WasalnyAd> updateAdStatus({
    required String id,
    required WasalnyAdStatus status,
    String? decisionNote,
  });
}
