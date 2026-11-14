import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/products/domain/entities/product_report.dart';
import 'package:barwah_app/features/products/domain/repositories/product_report_repository.dart';

class GetProductReportUseCase {
  final ProductReportRepository repository;

  const GetProductReportUseCase({required this.repository});

  Future<Either<Failure, ProductReport>> call(String period) =>
      repository.getReport(period);
}
