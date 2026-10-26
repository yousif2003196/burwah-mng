import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_ad.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/repositories/wasalny_ads_repository.dart';

class GetWasalnyAdsUseCase {
  final WasalnyAdsRepository repository;

  const GetWasalnyAdsUseCase({required this.repository});

  Future<List<WasalnyAd>> call() => repository.getAds();
}
