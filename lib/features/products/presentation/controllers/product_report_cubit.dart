import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/products/domain/usecases/get_product_report_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_report_state.dart';

/// تقرير أداء مشرف الإعلانات من `api/SupervisorForAd/reports`.
class ProductReportCubit extends Cubit<ProductReportState> {
  ProductReportCubit({required this.getProductReport})
      : super(const ProductReportInitial());

  final GetProductReportUseCase getProductReport;
  int _requestId = 0;

  /// يحمّل تقرير [period] (ولو `custom` يبعت [from]/[to]). نتيجة طلب أقدم تُهمل.
  Future<void> load(String period, {DateTime? from, DateTime? to}) async {
    final id = ++_requestId;
    emit(ProductReportLoading(period));
    final result = await getProductReport(period, from: from, to: to);
    if (isClosed || id != _requestId) return;
    emit(result.fold(
      (failure) => ProductReportLoadFailure(period, failure.message),
      (report) => ProductReportLoaded(period, report),
    ));
  }
}
