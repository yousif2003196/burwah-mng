import 'package:barwah_app/features/merchants/data/datasources/merchants_data_source.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/domain/entities/supervisor_stats_entity.dart';
import 'package:barwah_app/features/merchants/domain/repositories/merchants_repository.dart';

class MerchantsRepositoryImpl implements MerchantsRepository {
  final MerchantsDataSource dataSource;

  MerchantsRepositoryImpl({required this.dataSource});

  @override
  Future<List<MerchantEntity>> getMerchants() async {
    return await dataSource.getMerchants();
  }

  @override
  Future<List<MerchantEntity>> getSupervisedMerchants() async {
    return await dataSource.getSupervisedMerchants();
  }

  @override
  Future<SupervisorStatsEntity> getSupervisorStats() async {
    return await dataSource.getSupervisorStats();
  }

  @override
  Future<List<MerchantEntity>> searchAndFilterMerchants({
    String? query,
    MerchantStatus? statusFilter,
  }) async {
    return await dataSource.searchAndFilterMerchants(
      query: query,
      statusFilter: statusFilter,
    );
  }
}
