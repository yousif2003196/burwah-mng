import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/products/domain/usecases/get_product_report_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_report_state.dart';

/// تقرير أداء مشرف الإعلانات من `api/SupervisorForAd/reports`.
class ProductReportCubit extends Cubit<ProductReportState> {
  ProductReportCubit({required this.getProductReport})
      : super(const ProductReportInitial());

  final GetProductReportUseCase getProductReport;
  String? _requestedPeriod;

  /// يحمّل تقرير [period]. نتيجة طلب أقدم لفترة لم تعد مختارة تُهمل.
  Future<void> load(String period) async {
    _requestedPeriod = period;
    emit(ProductReportLoading(period));
    final result = await getProductReport(period);
    if (isClosed || _requestedPeriod != period) return;
    emit(result.fold(
      (failure) => ProductReportLoadFailure(period, failure.message),
      (report) => ProductReportLoaded(period, report),
    ));
  }
}
