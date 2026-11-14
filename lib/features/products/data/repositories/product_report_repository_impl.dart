import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:barwah_app/core/errors/failure_mapper.dart';
import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/products/data/datasources/product_report_api_data_source.dart';
import 'package:barwah_app/features/products/domain/entities/product_report.dart';
import 'package:barwah_app/features/products/domain/repositories/product_report_repository.dart';

class ProductReportRepositoryImpl implements ProductReportRepository {
  final ProductReportApiDataSource dataSource;

  const ProductReportRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, ProductReport>> getReport(String period) async {
    try {
      return Right(await dataSource.load(period));
    } on Object catch (error) {
      debugPrint('Product report ($period) failed: $error');
      return Left(failureFrom(error));
    }
  }
}
