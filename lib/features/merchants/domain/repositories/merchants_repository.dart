import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/domain/entities/supervisor_stats_entity.dart';

abstract class MerchantsRepository {
  Future<List<MerchantEntity>> getMerchants();
  Future<List<MerchantEntity>> getSupervisedMerchants();
  Future<SupervisorStatsEntity> getSupervisorStats();
  Future<List<MerchantEntity>> searchAndFilterMerchants({
    String? query,
    MerchantStatus? statusFilter,
  });
}
