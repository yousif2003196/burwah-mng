import 'package:barwah_app/features/merchants/domain/entities/supervisor_stats_entity.dart';
import 'package:barwah_app/features/merchants/domain/repositories/merchants_repository.dart';

class GetSupervisorStatsUseCase {
  final MerchantsRepository repository;

  GetSupervisorStatsUseCase({required this.repository});

  Future<SupervisorStatsEntity> call() async {
    return await repository.getSupervisorStats();
  }
}

