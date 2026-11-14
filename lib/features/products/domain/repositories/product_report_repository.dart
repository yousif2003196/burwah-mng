import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/products/domain/entities/product_report.dart';

abstract class ProductReportRepository {
  /// [period]: today | week | month
  Future<Either<Failure, ProductReport>> getReport(String period);
}
