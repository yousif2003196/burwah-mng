import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_ad.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/repositories/wasalny_ads_repository.dart';

class UpdateWasalnyAdStatusUseCase {
  final WasalnyAdsRepository repository;

  const UpdateWasalnyAdStatusUseCase({required this.repository});

  Future<WasalnyAd> call({
    required String id,
    required WasalnyAdStatus status,
    String? decisionNote,
  }) {
    return repository.updateAdStatus(
      id: id,
      status: status,
      decisionNote: decisionNote,
    );
  }
}
