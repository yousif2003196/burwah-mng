import 'package:barwah_app/features/merchants/data/models/merchant_model.dart';
import 'package:barwah_app/features/merchants/data/models/supervisor_stats_model.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';

abstract class MerchantsDataSource {
  Future<List<MerchantModel>> getMerchants();
  Future<List<MerchantModel>> getSupervisedMerchants();
  Future<SupervisorStatsModel> getSupervisorStats();
  Future<List<MerchantModel>> searchAndFilterMerchants({
    String? query,
    MerchantStatus? statusFilter,
  });
}
