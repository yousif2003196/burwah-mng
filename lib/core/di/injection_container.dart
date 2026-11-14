import 'package:get_it/get_it.dart';

import 'package:barwah_app/core/network/api_configuration.dart';
import 'package:barwah_app/core/auth/auth_refresh_interceptor.dart';
import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/auth/auth_token_store.dart';
import 'package:barwah_app/core/auth/device_id_store.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/features/products/data/datasources/product_report_api_data_source.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/features/auth/data/datasources/auth_api_data_source.dart';
import 'package:barwah_app/features/auth/data/datasources/session_user_store.dart';
import 'package:barwah_app/features/products/data/datasources/product_category_api_data_source.dart';
import 'package:barwah_app/features/products/data/datasources/product_promotion_api_data_source.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/data/datasources/head_account_store.dart';
import 'package:barwah_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:barwah_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barwah_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:barwah_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:barwah_app/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_cubit.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_mock_data_source.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:barwah_app/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/finance/domain/usecases/approve_bank_link_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/edit_expense_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/freeze_bank_link_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_bank_account_edit_requests_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_bank_accounts_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_bank_link_requests_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_department_wallet_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_expense_requests_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_finance_summary_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_frozen_withdrawals_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_merchant_withdrawals_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_subscriptions_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_supervisor_withdrawals_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/reject_and_forfeit_withdrawal_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/reject_bank_link_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/reject_frozen_bank_link_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/request_iban_certificate_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/restore_frozen_bank_link_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/restore_frozen_withdrawal_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/submit_bank_account_edit_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/submit_expense_request_usecase.dart';
import 'package:barwah_app/features/finance/domain/usecases/update_expense_request_status_usecase.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_data_source.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_mock_data_source.dart';
import 'package:barwah_app/features/merchants/data/repositories/merchants_repository_impl.dart';
import 'package:barwah_app/features/merchants/domain/repositories/merchants_repository.dart';
import 'package:barwah_app/features/merchants/domain/usecases/get_merchants_usecase.dart';
import 'package:barwah_app/features/merchants/domain/usecases/get_supervised_merchants_usecase.dart';
import 'package:barwah_app/features/merchants/domain/usecases/get_supervisor_stats_usecase.dart';
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_cubit.dart';
import 'package:barwah_app/features/products/data/datasources/product_review_data_source.dart';
import 'package:barwah_app/features/products/data/datasources/product_review_api_data_source.dart';
import 'package:barwah_app/features/products/data/datasources/product_review_mock_data_source.dart';
import 'package:barwah_app/features/products/data/datasources/product_supervisor_audit_data_source.dart';
import 'package:barwah_app/features/products/data/datasources/product_supervisor_audit_shared_preferences_data_source.dart';
import 'package:barwah_app/features/products/data/repositories/product_report_repository_impl.dart';
import 'package:barwah_app/features/products/data/repositories/product_review_repository_impl.dart';
import 'package:barwah_app/features/products/data/repositories/product_supervisor_audit_repository_impl.dart';
import 'package:barwah_app/features/products/domain/repositories/product_report_repository.dart';
import 'package:barwah_app/features/products/domain/repositories/product_review_repository.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/domain/usecases/change_product_review_status_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_report_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_review_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_reviews_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/update_product_review_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/ad_quick_review_cubit.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_report_cubit.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_cubit.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_case_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_api_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_mock_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/repositories/wasalny_complaints_repository_impl.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/repositories/wasalny_complaints_repository.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/escalate_wasalny_complaint_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/get_wasalny_complaints_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/resolve_wasalny_complaint_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_complaints_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Auth (registered first so login keeps working if a later registration fails)
  sl.registerLazySingleton(() => AdminSecurityStore());
  sl.registerLazySingleton(() => HeadAccountStore());
  sl.registerLazySingleton(() => HeadSupervisorRosterStore());
  // عميل واحد لباك إند Berwah بتوكن الجلسة (AuthSession).
  const berwahApiUrl = String.fromEnvironment(
    'BERWAH_API_URL',
    defaultValue: 'https://berwah.runasp.net/',
  );
  RealtimeHub.instance.baseUrl = berwahApiUrl;
  // معرّف الجهاز يُرسل مع كل طلب في ترويسة X-Device-Id.
  sl.registerLazySingleton(() => DeviceIdStore());
  // التوكنات في التخزين الآمن لتبقى الجلسة بعد إغلاق التطبيق.
  sl.registerLazySingleton(() => AuthTokenStore());
  sl.registerLazySingleton<ApiConsumer>(
    () {
      final deviceIds = sl<DeviceIdStore>();
      final consumer = ApiConsumer(
        baseUrl: berwahApiUrl,
        accessTokenProvider: AuthSession.tokenProvider,
        deviceIdProvider: deviceIds.read,
      );
      consumer.dio.interceptors.add(
        AuthRefreshInterceptor(
          baseUrl: berwahApiUrl,
          client: consumer.dio,
          deviceIdProvider: deviceIds.read,
          tokenStore: sl<AuthTokenStore>(),
          onSessionExpired: AuthSession.notifyExpired,
        ),
      );
      return consumer;
    },
    instanceName: 'berwah',
  );
  sl.registerLazySingleton<ProductReportApiDataSource>(
    () => ProductReportApiDataSource(
      apiConsumer: sl<ApiConsumer>(instanceName: 'berwah'),
    ),
  );
  sl.registerLazySingleton<ProductCategoryApiDataSource>(
    () => ProductCategoryApiDataSource(
      apiConsumer: sl<ApiConsumer>(instanceName: 'berwah'),
    ),
  );
  sl.registerLazySingleton<ProductPromotionApiDataSource>(
    () => ProductPromotionApiDataSource(
      apiConsumer: sl<ApiConsumer>(instanceName: 'berwah'),
    ),
  );
  // بيانات حساب الجلسة غير الحساسة (الاسم والبريد والدور) في SharedPreferences.
  sl.registerLazySingleton(() => SessionUserStore());
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      adminSecurity: sl(),
      headAccounts: sl(),
      supervisorRoster: sl(),
      // الدخول عن طريق السيرفر فقط.
      api: AuthApiDataSource(apiConsumer: sl(instanceName: 'berwah')),
      tokenStore: sl<AuthTokenStore>(),
      userStore: sl<SessionUserStore>(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => RestoreSessionUseCase(sl()));
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      restoreSessionUseCase: sl(),
    ),
  );

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
  // مراجعة الإعلانات من واجهة Berwah (SupervisorForAd).
  // للعودة للبيانات التجريبية: --dart-define=USE_MOCK_PRODUCTS=true
  const useMockProducts = bool.fromEnvironment('USE_MOCK_PRODUCTS');
  sl.registerLazySingleton<ProductReviewDataSource>(
    () => useMockProducts
        ? ProductReviewMockDataSource()
        : ProductReviewApiDataSource(
            apiConsumer: sl<ApiConsumer>(instanceName: 'berwah'),
            categories: sl<ProductCategoryApiDataSource>(),
          ),
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
  sl.registerLazySingleton(() => GetProductReviewUseCase(repository: sl()));
  sl.registerFactory(
    () => ProductReviewCubit(
      getProductReviews: sl(),
      changeProductReviewStatus: sl(),
      updateProductReview: sl(),
      getProductReview: sl(),
      auditRepository: sl(),
      categoryLoader:
          useMockProducts ? null : sl<ProductCategoryApiDataSource>().load,
    ),
  );
  // مراجعة سريعة لإعلان مفتوح من إشعار "إعلان جديد".
  sl.registerFactory(
    () => AdQuickReviewCubit(
      getProductReview: sl(),
      changeProductReviewStatus: sl(),
    ),
  );
  // تقرير أداء مشرف الإعلانات (api/SupervisorForAd/reports).
  sl.registerLazySingleton<ProductReportRepository>(
    () => ProductReportRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => GetProductReportUseCase(repository: sl()));
  sl.registerFactory(() => ProductReportCubit(getProductReport: sl()));

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
      caseStore: WasalnyCaseStore(),
    ),
  );
}
