import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/app/navigation/services_supervisor_tabs_shell.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_mock_data_source.dart';
import 'package:barwah_app/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_account_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_profile_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_wallet_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    sl.registerLazySingleton<FinanceRepository>(
      () => FinanceRepositoryImpl(
        remoteDataSource: FinanceMockDataSource(),
      ),
    );
  });

  void setPhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('services profile shows supervisor, metrics and administration',
      (tester) async {
    setPhoneSize(tester);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: ServicesSupervisorProfileScreen(onLogout: _ignoreLogout),
        ),
      ),
    );

    expect(find.text('م. عبد العزيز بن خالد السالم'), findsOneWidget);
    expect(find.text('342'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);
    expect(find.text('محفظة المستحقات والعمولات'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('البيانات الإدارية والاعتمادات'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('سجل نشاطات المشرف والتدقيق'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wallet shortcut opens the wallet and accepts a demo withdrawal',
      (tester) async {
    setPhoneSize(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: ServicesSupervisorProfileScreen(onLogout: _ignoreLogout),
        ),
      ),
    );

    await tester.tap(find.text('فتح المحفظة وسحب الرصيد'));
    await tester.pumpAndSettle();

    expect(find.byType(ServicesSupervisorWalletScreen), findsOneWidget);
    expect(find.text('محفظتي والعمليات المالية'), findsOneWidget);
    expect(find.text('بيانات تجريبية'), findsOneWidget);

    await tester.tap(find.text('50%'));
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('services_wallet_amount')),
          )
          .controller!
          .text,
      '2425',
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('services_wallet_submit')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('services_wallet_submit')));
    await tester.pumpAndSettle();
    expect(find.text('تأكيد طلب السحب'), findsOneWidget);
    expect(find.textContaining('2425'), findsNWidgets(2));
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('تم إرسال طلب السحب إلى المشرف المالي، والطلب قيد المراجعة.'),
      findsOneWidget,
    );
    final requests = await sl<FinanceRepository>().getSupervisorWithdrawals();
    final request = requests.fold(
      (failure) => throw StateError(failure.message),
      (items) => items.singleWhere(
        (item) => item.sourceAccount == 'services',
      ),
    );
    expect(request.status, RequestStatus.pending);
    final decision =
        await sl<FinanceRepository>().approveWithdrawal(request.id);
    expect(decision.isRight(), isTrue);
    await tester.ensureVisible(find.text('تحديث الأرصدة'));
    await tester.tap(find.text('تحديث الأرصدة'));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(ServicesSupervisorWalletScreen)),
    )!;
    expect(
      find.text(l10n.withdrawalDetailsStatusApproved),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile opens local account settings and activity history',
      (tester) async {
    setPhoneSize(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: ServicesSupervisorProfileScreen(onLogout: _ignoreLogout),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('إعدادات الحساب والتنبيهات'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('إعدادات الحساب والتنبيهات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إعدادات الحساب والتنبيهات'));
    await tester.pumpAndSettle();

    expect(find.text('تفضيلات التنبيهات'), findsOneWidget);
    expect(find.text('المحفظة غير متصلة'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('سجل نشاط الحساب'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('سجل نشاط الحساب'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(OutlinedButton).first,
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byType(OutlinedButton).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'مشرف الخدمات الجديد');
    await tester.enterText(find.byType(TextField).at(1), '0559876543');
    await tester.enterText(find.byType(TextField).at(2), 'جدة');
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pumpAndSettle();
    expect(find.text('مشرف الخدمات الجديد'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('مشرف الخدمات الجديد'),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('مشرف الخدمات الجديد'), findsOneWidget);
    expect(find.text('0559876543'), findsOneWidget);
    expect(find.text('جدة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account settings persist profile and notification changes',
      (tester) async {
    setPhoneSize(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: ServicesSupervisorAccountScreen(onLogout: _ignoreLogout),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('إعدادات الحساب والتنبيهات'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'مشرف تجريبي');
    await tester.enterText(find.byType(TextField).at(1), '0551234567');
    await tester.enterText(find.byType(TextField).at(2), 'الرياض');
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('مشرف تجريبي'), findsOneWidget);
    await tester.ensureVisible(find.text('تفضيلات التنبيهات'));
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('سجل نشاط الحساب'));
    expect(find.text('تم تعديل بيانات الملف'), findsOneWidget);
    expect(find.text('تم تعديل تفضيلات التنبيهات'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    final stored = jsonDecode(
      preferences.getString('services_supervisor_account_state_v1')!,
    ) as Map<String, dynamic>;
    expect(stored['name'], 'مشرف تجريبي');
    expect(stored['phone'], '0551234567');
    expect(stored['coverage'], 'الرياض');
    expect(stored['assignmentAlerts'], isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account tab and profile shortcut open services profile',
      (tester) async {
    setPhoneSize(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ServicesSupervisorTabsShell(onLogout: _ignoreLogout),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('ملفك الشخصي'));
    await tester.pumpAndSettle();
    expect(find.text('الملف الشخصي'), findsOneWidget);
    expect(find.text('م. عبد العزيز بن خالد السالم'), findsOneWidget);
    await tester.tap(find.byTooltip('العودة'));
    await tester.pumpAndSettle();
    expect(find.text('طلبات الخدمات قيد المراجعة'), findsOneWidget);

    await tester.tap(find.text('الشكاوى').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('الحساب').last);
    await tester.pumpAndSettle();
    expect(find.text('م. عبد العزيز بن خالد السالم'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _ignoreLogout() {}
