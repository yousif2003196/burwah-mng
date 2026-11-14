import 'package:barwah_app/features/products/domain/entities/product_report.dart';

abstract class ProductReportState {
  const ProductReportState();
}

class ProductReportInitial extends ProductReportState {
  const ProductReportInitial();
}

class ProductReportLoading extends ProductReportState {
  final String period;

  const ProductReportLoading(this.period);
}

class ProductReportLoaded extends ProductReportState {
  final String period;
  final ProductReport report;

  const ProductReportLoaded(this.period, this.report);
}

class ProductReportLoadFailure extends ProductReportState {
  final String period;
  final String message;

  const ProductReportLoadFailure(this.period, this.message);
}
