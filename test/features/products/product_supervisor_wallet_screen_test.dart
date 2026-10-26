import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_mock_data_source.dart';
import 'package:barwah_app/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/products/data/datasources/product_supervisor_audit_data_source.dart';
import 'package:barwah_app/features/products/data/repositories/product_supervisor_audit_repository_impl.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_profile_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_wallet_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_wallet_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    final dataSource = _MemoryAuditDataSource();
    sl.registerLazySingleton<ProductSupervisorAuditDataSource>(
      () => dataSource,
    );
    sl.registerLazySingleton<ProductSupervisorAuditRepository>(
      () => ProductSupervisorAuditRepositoryImpl(dataSource: sl()),
    );
    sl.registerLazySingleton<FinanceRepository>(
      () => FinanceRepositoryImpl(
        remoteDataSource: FinanceMockDataSource(),
      ),
    );
  });

  Widget buildTestApp() {
    return const MaterialApp(
      locale: Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: ProductSupervisorProfileScreen(onLogout: _ignoreLogout),
      ),
    );
  }

  testWidgets('available balance opens the shared supervisor wallet',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('الرصيد المتاح والمستحقات'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('الرصيد المتاح والمستحقات'));
    await tester.pumpAndSettle();

    expect(find.byType(ServicesSupervisorWalletScreen), findsOneWidget);
    expect(find.text('محفظتي والعمليات المالية'), findsOneWidget);
    expect(find.text('طلب سحب رصيد'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('سجل العمليات المالية'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('سجل العمليات المالية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wallet withdrawal request asks for confirmation',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProductSupervisorWalletScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final requestButton = find.text('إرسال الطلب للمراجعة المالية');
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(requestButton);
    await tester.tap(requestButton);
    await tester.pumpAndSettle();

    expect(find.text('تأكيد طلب السحب'), findsOneWidget);
    expect(find.text('تأكيد السحب'), findsOneWidget);
    await tester.tap(find.text('تأكيد السحب'));
    await tester.pumpAndSettle();
    expect(
      find.text('أُرسل الطلب إلى المشرف المالي للمراجعة. لم يتم أي تحويل.'),
      findsOneWidget,
    );
    final requests = await sl<FinanceRepository>().getSupervisorWithdrawals();
    final request = requests.fold(
      (failure) => throw StateError(failure.message),
      (items) => items.singleWhere(
        (item) => item.sourceAccount == 'products',
      ),
    );
    expect(request.status, RequestStatus.pending);
    final financeNotices = await LocalEventStore().getEvents('finance');
    expect(financeNotices, hasLength(1));
    expect(financeNotices.single.messageAr, contains(request.requestNumber));

    final approved =
        await sl<FinanceRepository>().approveWithdrawal(request.id);
    expect(approved.isRight(), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProductSupervisorWalletScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -1600));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining(request.requestNumber));
    await tester.pumpAndSettle();
    expect(find.textContaining(request.requestNumber), findsOneWidget);
    final l10n = AppLocalizations.of(
        tester.element(find.byType(ProductSupervisorWalletScreen)))!;
    expect(
      find.textContaining(l10n.withdrawalDetailsStatusApproved),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

void _ignoreLogout() {}

class _MemoryAuditDataSource implements ProductSupervisorAuditDataSource {
  final List<ProductSupervisorAuditEntry> entries = [];

  @override
  Future<List<ProductSupervisorAuditEntry>> getEntries() async =>
      List.of(entries);

  @override
  Future<void> saveEntry(ProductSupervisorAuditEntry entry) async {
    entries.add(entry);
  }
}
