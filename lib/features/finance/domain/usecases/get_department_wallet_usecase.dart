import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/department_wallet_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetDepartmentWalletUseCase {
  final FinanceRepository repository;

  const GetDepartmentWalletUseCase(this.repository);

  Future<Either<Failure, DepartmentWalletEntity>> call(DepartmentType type) {
    return repository.getDepartmentWallet(type);
  }
}