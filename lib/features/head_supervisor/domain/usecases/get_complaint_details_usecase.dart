import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class GetComplaintDetailsUseCase {
  final BossSupervisorRepository repository;

  const GetComplaintDetailsUseCase(this.repository);

  Future<Either<Failure, MerchantComplaintDetails>> call(int complaintId) {
    return repository.getComplaintDetails(complaintId);
  }
}
