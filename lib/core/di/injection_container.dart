import 'package:get_it/get_it.dart';

import '../network/api_configuration.dart';
import '../network/api_consumer.dart';
import '../../features/merchants/data/datasources/merchants_data_source.dart';
import '../../features/merchants/data/datasources/merchants_mock_data_source.dart';
import '../../features/merchants/data/repositories/merchants_repository_impl.dart';
import '../../features/merchants/domain/repositories/merchants_repository.dart';
import '../../features/merchants/domain/usecases/get_merchants_usecase.dart';
import '../../features/merchants/domain/usecases/get_supervised_merchants_usecase.dart';
import '../../features/merchants/domain/usecases/get_supervisor_stats_usecase.dart';
import '../../features/merchants/presentation/controllers/merchants_cubit.dart';
import '../../features/products/data/datasources/product_review_data_source.dart';
import '../../features/products/data/datasources/product_review_mock_data_source.dart';
import '../../features/products/data/datasources/product_supervisor_audit_data_source.dart';
import '../../features/products/data/datasources/product_supervisor_audit_shared_preferences_data_source.dart';
import '../../features/products/data/repositories/product_review_repository_impl.dart';
import '../../features/products/data/repositories/product_supervisor_audit_repository_impl.dart';
import '../../features/products/domain/repositories/product_review_repository.dart';
import '../../features/products/domain/repositories/product_supervisor_audit_repository.dart';
import '../../features/products/domain/usecases/change_product_review_status_usecase.dart';
import '../../features/products/domain/usecases/get_product_reviews_usecase.dart';
import '../../features/products/domain/usecases/update_product_review_usecase.dart';
import '../../features/products/presentation/controllers/product_review_cubit.dart';
import '../../features/finance/data/datasources/finance_mock_data_source.dart';
import '../../features/finance/data/datasources/finance_remote_data_source.dart';
import '../../features/finance/data/repositories/finance_repository_impl.dart';
import '../../features/finance/domain/repositories/finance_repository.dart';
import '../../features/finance/domain/usecases/get_bank_account_edit_requests_usecase.dart';
import '../../features/finance/domain/usecases/get_bank_link_requests_usecase.dart';
import '../../features/finance/domain/usecases/get_bank_accounts_usecase.dart';
import '../../features/finance/domain/usecases/get_department_wallet_usecase.dart';
import '../../features/finance/domain/usecases/get_expense_requests_usecase.dart';
import '../../features/finance/domain/usecases/get_finance_summary_usecase.dart';
import '../../features/finance/domain/usecases/get_frozen_withdrawals_usecase.dart';
import '../../features/finance/domain/usecases/get_merchant_withdrawals_usecase.dart';
import '../../features/finance/domain/usecases/get_subscriptions_usecase.dart';
import '../../features/finance/domain/usecases/get_supervisor_withdrawals_usecase.dart';
import '../../features/finance/domain/usecases/submit_bank_account_edit_request_usecase.dart';
import '../../features/finance/domain/usecases/submit_expense_request_usecase.dart';
import '../../features/finance/domain/usecases/update_expense_request_status_usecase.dart';
import '../../features/finance/domain/usecases/edit_expense_request_usecase.dart';
import '../../features/finance/domain/usecases/restore_frozen_withdrawal_usecase.dart';
import '../../features/finance/domain/usecases/reject_and_forfeit_withdrawal_usecase.dart';
import '../../features/finance/domain/usecases/approve_bank_link_request_usecase.dart';
import '../../features/finance/domain/usecases/request_iban_certificate_usecase.dart';
import '../../features/finance/domain/usecases/freeze_bank_link_request_usecase.dart';
import '../../features/finance/domain/usecases/reject_bank_link_request_usecase.dart';
import '../../features/finance/domain/usecases/restore_frozen_bank_link_request_usecase.dart';
import '../../features/finance/domain/usecases/reject_frozen_bank_link_request_usecase.dart';
import '../../features/wasalny_supervisor/data/datasources/wasalny_complaints_data_source.dart';
import '../../features/wasalny_supervisor/data/datasources/wasalny_complaints_api_data_source.dart';
import '../../features/wasalny_supervisor/data/datasources/wasalny_complaints_mock_data_source.dart';
import '../../features/wasalny_supervisor/data/repositories/wasalny_complaints_repository_impl.dart';
import '../../features/wasalny_supervisor/domain/repositories/wasalny_complaints_repository.dart';
import '../../features/wasalny_supervisor/domain/usecases/escalate_wasalny_complaint_usecase.dart';
import '../../features/wasalny_supervisor/domain/usecases/get_wasalny_complaints_usecase.dart';
import '../../features/wasalny_supervisor/domain/usecases/resolve_wasalny_complaint_usecase.dart';
import '../../features/wasalny_supervisor/presentation/controllers/wasalny_complaints_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final apiConfiguration = ApiConfiguration.fromEnvironment();
  apiConfiguration.validate();

  // Finance API wiring will follow the backend financial-request contract.
  sl.registerLazySingleton<FinanceRemoteDataSource>(
    () => FinanceMockDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetFinanceSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetBankAccountsUseCase(sl()));
  sl.registerLazySingleton(() => GetBankAccountEditRequestsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitBankAccountEditRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetExpenseRequestsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitExpenseRequestUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExpenseRequestStatusUseCase(sl()));
  sl.registerLazySingleton(() => EditExpenseRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetDepartmentWalletUseCase(sl()));
  sl.registerLazySingleton(() => GetMerchantWithdrawalsUseCase(sl()));
  sl.registerLazySingleton(() => GetSupervisorWithdrawalsUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionsUseCase(sl()));
  sl.registerLazySingleton(() => GetFrozenWithdrawalsUseCase(sl()));
  sl.registerLazySingleton(() => RestoreFrozenWithdrawalUseCase(sl()));
  sl.registerLazySingleton(() => RejectAndForfeitWithdrawalUseCase(sl()));
  sl.registerLazySingleton(() => GetBankLinkRequestsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveBankLinkRequestUseCase(sl()));
  sl.registerLazySingleton(() => RequestIbanCertificateUseCase(sl()));
  sl.registerLazySingleton(() => FreezeBankLinkRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectBankLinkRequestUseCase(sl()));
  sl.registerLazySingleton(() => RestoreFrozenBankLinkRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectFrozenBankLinkRequestUseCase(sl()));

  // Merchants
  sl.registerLazySingleton<MerchantsDataSource>(
    () => MerchantsMockDataSource(),
  );
  sl.registerLazySingleton<MerchantsRepository>(
    () => MerchantsRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => GetMerchantsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetSupervisorStatsUseCase(repository: sl()));
  sl.registerLazySingleton(
    () => GetSupervisedMerchantsUseCase(repository: sl()),
  );
  sl.registerFactory(
    () => MerchantsCubit(
      getMerchantsUseCase: sl(),
      getSupervisorStatsUseCase: sl(),
      getSupervisedMerchantsUseCase: sl(),
    ),
  );

  // Product supervisor
  sl.registerLazySingleton<ProductSupervisorAuditDataSource>(
    () => ProductSupervisorAuditSharedPreferencesDataSource(),
  );
  sl.registerLazySingleton<ProductSupervisorAuditRepository>(
    () => ProductSupervisorAuditRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<ProductReviewDataSource>(
    () => ProductReviewMockDataSource(),
  );
  sl.registerLazySingleton<ProductReviewRepository>(
    () => ProductReviewRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => GetProductReviewsUseCase(repository: sl()));
  sl.registerLazySingleton(
    () => ChangeProductReviewStatusUseCase(repository: sl()),
  );
  sl.registerLazySingleton(
    () => UpdateProductReviewUseCase(repository: sl()),
  );
  sl.registerFactory(
    () => ProductReviewCubit(
      getProductReviews: sl(),
      changeProductReviewStatus: sl(),
      updateProductReview: sl(),
      auditRepository: sl(),
    ),
  );

  // Wasalny complaints
  if (apiConfiguration.useMockData) {
    sl.registerLazySingleton<WasalnyComplaintsDataSource>(
      () => WasalnyComplaintsMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<ApiConsumer>(
      () => ApiConsumer(baseUrl: apiConfiguration.baseUrl),
    );
    sl.registerLazySingleton<WasalnyComplaintsDataSource>(
      () => WasalnyComplaintsApiDataSource(apiConsumer: sl()),
    );
  }
  sl.registerLazySingleton<WasalnyComplaintsRepository>(
    () => WasalnyComplaintsRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => GetWasalnyComplaintsUseCase(sl()));
  sl.registerLazySingleton(() => EscalateWasalnyComplaintUseCase(sl()));
  sl.registerLazySingleton(() => ResolveWasalnyComplaintUseCase(sl()));
  sl.registerFactory(
    () => WasalnyComplaintsCubit(
      getComplaints: sl(),
      escalateComplaint: sl(),
      resolveComplaint: sl(),
      auditRepository: sl(),
    ),
  );
}
