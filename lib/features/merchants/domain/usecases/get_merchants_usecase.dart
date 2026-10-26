import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/domain/repositories/merchants_repository.dart';

class GetMerchantsUseCase {
  final MerchantsRepository repository;

  GetMerchantsUseCase({required this.repository});

  Future<List<MerchantEntity>> call() async {
    return await repository.getMerchants();
  }
}

