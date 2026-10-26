import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_ads_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_ad.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/repositories/wasalny_ads_repository.dart';

class WasalnyAdsRepositoryImpl implements WasalnyAdsRepository {
  final WasalnyAdsDataSource dataSource;

  const WasalnyAdsRepositoryImpl({required this.dataSource});

  @override
  Future<List<WasalnyAd>> getAds() => dataSource.getAds();

  @override
  Future<WasalnyAd> updateAdStatus({
    required String id,
    required WasalnyAdStatus status,
    String? decisionNote,
  }) {
    return dataSource.updateAdStatus(
      id: id,
      status: status,
      decisionNote: decisionNote,
    );
  }
}
