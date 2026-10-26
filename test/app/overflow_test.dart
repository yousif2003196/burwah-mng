import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/app/navigation/finance_tabs_shell.dart';
import 'package:barwah_app/app/navigation/merchants_tabs_shell.dart';
import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/features/auth/presentation/screens/login_screen.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:barwah_app/features/finance/domain/entities/department_wallet_entity.dart';
import 'package:barwah_app/features/finance/presentation/screens/bank_accounts_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/bank_reconciliation_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/department_wallet_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/edit_matrix_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/expenses_management_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/frozen_requests_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/merchant_withdrawals_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/profile_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/subscriptions_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/supervisor_withdrawals_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/transaction_history_screen.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_advertisement_local_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/presentation/screens/ads_management_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/advertisement_review_details_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_financial_requests_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_wallet_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

import '../support/auth_test_support.dart';
import '../support/icon_finders.dart';

Widget buildTestScreen(
  Widget child, {
  Locale locale = const Locale('en'),
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => buildAuthCubit()),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await di.initDependencies();
  });

  setUp(() async {
    await AppLocaleController.instance.setLocale('en');
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('merchant_supervisor_ad_actions_v1');
    await preferences.remove('merchant_supervisor_financial_actions_v1');
    await preferences.remove('merchant_supervisor_financial_requests_v1');
    await MerchantAdvertisementLocalStore.saveStatus(
      reference: 'AD-94820',
      status: MerchantAdvertisementStatus.underReview,
    );
  });

  Future<void> testScreen(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestScreen(widget));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('Test LoginScreen in English', (tester) async {
    await testScreen(tester, LoginScreen(onFinancialLogin: () {}));
  });

  testWidgets('Test FinanceTabsShell in English', (tester) async {
    await testScreen(tester, FinanceTabsShell(onLogout: () {}));
  });

  testWidgets('Merchants shell reuses finance app bar and bottom bar',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester
        .pumpWidget(buildTestScreen(MerchantsTabsShell(onLogout: () {})));
    await tester.pumpAndSettle();

    expect(find.byType(FinancePageAppBar), findsOneWidget);
    expect(find.byType(FinanceBottomNavigationBar), findsOneWidget);
    expect(find.text('Merchant Supervisor'), findsOneWidget);
    expect(find.text('Merchants'), findsNWidgets(2));
    expect(find.text('Ads'), findsOneWidget);
    expect(find.text('Financial Requests'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(
      find.descendant(
        of: find.byType(FinanceBottomNavigationBar),
        matching: find.text('Ads'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FinancePageAppBar), findsOneWidget);
    expect(find.text('Ads'), findsNWidgets(2));
    expect(find.text('Ads awaiting review'), findsOneWidget);
    expect(find.text('2023 Mercedes E300 AMG fully loaded'), findsOneWidget);
    expect(find.text('New iPhone 16 Pro Max 256GB Natural Titanium'),
        findsOneWidget);
    await tester.ensureVisible(find.text('Al-Ufuq Car Trading Est.'));
    final adIconRect = tester.getRect(
      find.ancestor(
        of: findMotionIcon(Icons.directions_car_outlined),
        matching: find.byType(CircleAvatar),
      ),
    );
    final adMerchantRect = tester.getRect(
      find.text('Al-Ufuq Car Trading Est.'),
    );
    expect(adMerchantRect.left - adIconRect.right, inInclusiveRange(0, 10));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Cars & vehicles (5)'));
    await tester.pumpAndSettle();
    expect(find.text('2023 Mercedes E300 AMG fully loaded'), findsOneWidget);
    expect(find.text('New iPhone 16 Pro Max 256GB Natural Titanium'),
        findsNothing);

    await tester.tap(find.text('Approve and publish').first);
    await tester.pumpAndSettle();
    expect(find.text('Waiting for finance review'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Advertisement management renders without Arabic overflow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      buildTestScreen(
        MerchantsTabsShell(onLogout: () {}),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.tap(
      find.descendant(
        of: find.byType(FinanceBottomNavigationBar),
        matching: find.text(l10n.navAds),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.adsPendingHeading), findsOneWidget);
    expect(find.text(l10n.adsCarTitle), findsOneWidget);
    await tester.ensureVisible(find.text(l10n.adsCarMerchant));
    final adIconRect = tester.getRect(
      find.ancestor(
        of: findMotionIcon(Icons.directions_car_outlined),
        matching: find.byType(CircleAvatar),
      ),
    );
    final adMerchantRect = tester.getRect(find.text(l10n.adsCarMerchant));
    expect(adIconRect.left - adMerchantRect.right, inInclusiveRange(0, 10));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic ad cards open detailed vehicle review and approve',
      (tester) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      buildTestScreen(
        MerchantsTabsShell(onLogout: () {}),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.tap(
      find.descendant(
        of: find.byType(FinanceBottomNavigationBar),
        matching: find.text(l10n.navAds),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.adsCarTitle));
    await tester.pumpAndSettle();

    expect(find.byType(AdvertisementReviewDetailsScreen), findsOneWidget);
    expect(find.text(l10n.adsDetailsTitle), findsOneWidget);
    expect(find.text(l10n.adsVehicleDescription), findsOneWidget);
    expect(find.text(l10n.adsMileageValue), findsOneWidget);
    expect(find.text(l10n.adsVillaArea), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text(l10n.adsRequestEdit),
      350,
      scrollable: find
          .descendant(
            of: find.byType(AdvertisementReviewDetailsScreen),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            ),
          )
          .first,
    );
    await tester.ensureVisible(find.text(l10n.adsRequestEdit));
    await tester.tap(find.text(l10n.adsRequestEdit));
    await tester.pumpAndSettle();
    expect(find.text(l10n.adsEditRequestTitle), findsOneWidget);
    expect(find.text(l10n.adsEditRequestGuidanceTitle), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('ad-edit-request-note')),
      'يرجى توضيح بيانات الإعلان',
    );
    await tester.ensureVisible(find.text(l10n.adsEditRequestSend));
    await tester.tap(find.text(l10n.adsEditRequestSend));
    await tester.pumpAndSettle();
    expect(find.text(l10n.adsRequestEditUnavailable), findsOneWidget);
    expect(find.byType(AdvertisementReviewDetailsScreen), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(l10n.adsApproveAction),
      350,
      scrollable: find
          .descendant(
            of: find.byType(AdvertisementReviewDetailsScreen),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            ),
          )
          .first,
    );
    await tester.ensureVisible(find.text(l10n.adsApproveAction));
    await tester.tap(find.text(l10n.adsApproveAction));
    await tester.pumpAndSettle();
    expect(find.byType(AdvertisementReviewDetailsScreen), findsNothing);
    expect(find.text(l10n.adsPremiumWaitingFinance), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English ad details show category-specific data', (tester) async {
    tester.view.physicalSize = const Size(390, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      buildTestScreen(
        MerchantsTabsShell(onLogout: () {}),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();
    final enL10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(
      find.descendant(
        of: find.byType(FinanceBottomNavigationBar),
        matching: find.text('Ads'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New iPhone 16 Pro Max 256GB Natural Titanium'));
    await tester.pumpAndSettle();

    expect(find.text('Ad details'), findsOneWidget);
    expect(find.text('5 years'), findsOneWidget);
    expect(find.text('256 GB'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Luxury modern villa with living-room stairs - Al Narjis'),
      350,
      scrollable: find
          .descendant(
            of: find.byType(AdsManagementScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(
      find.text('Luxury modern villa with living-room stairs - Al Narjis'),
    );
    await tester.tap(
      find.text('Luxury modern villa with living-room stairs - Al Narjis'),
    );
    await tester.pumpAndSettle();
    expect(find.text('375 m²'), findsOneWidget);
    expect(find.text('Valid and verified'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(enL10n.adsRejectAction),
      350,
      scrollable: find
          .descendant(
            of: find.byType(AdvertisementReviewDetailsScreen),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            ),
          )
          .first,
    );
    await tester.ensureVisible(find.text(enL10n.adsRejectAction));
    await tester.tap(find.text(enL10n.adsRejectAction));
    await tester.pumpAndSettle();
    expect(find.text(enL10n.adsRejectReasonTitle), findsOneWidget);
    await tester.tap(find.byTooltip(enL10n.adsCancelAction));
    await tester.pumpAndSettle();
    expect(find.byType(AdsManagementScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Luxury modern villa with living-room stairs - Al Narjis'),
      350,
      scrollable: find
          .descendant(
            of: find.byType(AdsManagementScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(
      find.text('Luxury modern villa with living-room stairs - Al Narjis'),
    );
    await tester.tap(
      find.text('Luxury modern villa with living-room stairs - Al Narjis'),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(enL10n.adsRequestEdit),
      350,
      scrollable: find
          .descendant(
            of: find.byType(AdvertisementReviewDetailsScreen),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            ),
          )
          .first,
    );
    await tester.ensureVisible(find.text(enL10n.adsRequestEdit));
    await tester.tap(find.text(enL10n.adsRequestEdit));
    await tester.pumpAndSettle();
    expect(find.text(enL10n.adsEditRequestTitle), findsOneWidget);
    expect(
        find.text(enL10n.adsEditRequestAdTitle(
            'Luxury modern villa with living-room stairs - Al Narjis')),
        findsOneWidget);
    final sendEditRequest = find.text(enL10n.adsEditRequestSend);
    await tester.ensureVisible(sendEditRequest);
    await tester.tap(sendEditRequest);
    await tester.pumpAndSettle();
    expect(find.text(enL10n.adsEditRequestRequired), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('ad-edit-request-note')),
      'Update the property license details',
    );
    await tester.tap(sendEditRequest);
    await tester.pumpAndSettle();
    expect(find.text(enL10n.adsRequestEditUnavailable), findsOneWidget);
    expect(find.text(enL10n.adsEditRequestTitle), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ad rejection requires a reason and notifies in Arabic',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      buildTestScreen(
        MerchantsTabsShell(onLogout: () {}),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.tap(
      find.descendant(
        of: find.byType(FinanceBottomNavigationBar),
        matching: find.text(l10n.navAds),
      ),
    );
    await tester.pumpAndSettle();
    final rejectButton = find.text(l10n.adsRejectAction).first;
    await tester.ensureVisible(rejectButton);
    await tester.tap(rejectButton);
    await tester.pumpAndSettle();

    expect(find.text(l10n.adsRejectReasonTitle), findsOneWidget);
    expect(find.text(l10n.adsRejectReasonPrice), findsOneWidget);
    expect(find.text(l10n.adsRejectReasonPolicy), findsOneWidget);
    final confirm = find.text(l10n.adsConfirmRejectAndNotify);
    expect(
        tester
            .widget<ElevatedButton>(
              find
                  .ancestor(of: confirm, matching: find.byType(ElevatedButton))
                  .first,
            )
            .onPressed,
        isNull);

    await tester.tap(find.text(l10n.adsRejectReasonPhotos));
    await tester.enterText(
      find.byKey(const ValueKey('ad-rejection-guidance')),
      'يرجى إضافة صور واضحة للمنتج',
    );
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(find.text(l10n.adsRejectedStatus), findsWidgets);
    expect(find.text(l10n.adsRejectReasonTitle), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Merchant financial requests are reviewable and filterable',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      buildTestScreen(
        MerchantsTabsShell(onLogout: () {}),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(
      find.descendant(
        of: find.byType(FinanceBottomNavigationBar),
        matching: find.text('Financial Requests'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MerchantFinancialRequestsScreen), findsOneWidget);
    expect(find.text(l10n.finRequestLocalWorkflowNotice), findsOneWidget);
    expect(find.text('Sales profit transfer request'), findsOneWidget);
    await tester.ensureVisible(find.text('Sales profit transfer request'));
    final requestIconRect =
        tester.getRect(findMotionIcon(Icons.directions_car_outlined));
    final requestTextRect =
        tester.getRect(find.text('Sales profit transfer request'));
    expect(
      requestTextRect.left - requestIconRect.right,
      inInclusiveRange(0, 10),
    );
    expect(find.text('Annual Gold package subscription fee'), findsOneWidget);
    expect(find.text('Wallet balance withdrawal request'), findsOneWidget);
    expect(find.text(l10n.finRequestSendToFinance), findsWidgets);
    expect(
      tester
          .widget<OutlinedButton>(
            find
                .widgetWithText(
                  OutlinedButton,
                  l10n.finRequestSendToFinance,
                )
                .first,
          )
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Package fees'));
    await tester.tap(find.text('Package fees'));
    await tester.pumpAndSettle();
    expect(find.text('Annual Gold package subscription fee'), findsOneWidget);
    expect(find.text('Sales profit transfer request'), findsNothing);

    await tester.tap(find.text('View request details'));
    await tester.pumpAndSettle();
    expect(find.text('Request number: FIN-3016'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic financial requests fit a phone screen', (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      buildTestScreen(
        MerchantsTabsShell(onLogout: () {}),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.tap(
      find.descendant(
        of: find.byType(FinanceBottomNavigationBar),
        matching: find.text(l10n.navFinancialRequests),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.finRequestLocalWorkflowNotice), findsOneWidget);
    expect(find.text(l10n.finRequestHistoryTitle), findsOneWidget);
    await tester.ensureVisible(find.text(l10n.finRequestCarTitle));
    final requestIconRect =
        tester.getRect(findMotionIcon(Icons.directions_car_outlined));
    final requestTextRect = tester.getRect(find.text(l10n.finRequestCarTitle));
    expect(
      requestIconRect.left - requestTextRect.right,
      inInclusiveRange(0, 10),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Merchant account tab is localized and interactive in English',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    var didLogout = false;
    await tester.pumpWidget(
      buildTestScreen(MerchantsTabsShell(onLogout: () => didLogout = true)),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(FinanceBottomNavigationBar),
        matching: find.text('Account'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ahmed bin Abdulaziz Al-Shehri'), findsOneWidget);
    expect(find.text('Approved oversight files and documents'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
    await tester.ensureVisible(find.text('Field Availability and Readiness'));
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);

    await tester.ensureVisible(find.text('Available balance and dues'));
    await tester.tap(find.text('Available balance and dues'));
    await tester.pumpAndSettle();
    expect(find.byType(ServicesSupervisorWalletScreen), findsOneWidget);
    expect(find.text('My wallet and transactions'), findsOneWidget);
    expect(find.text('Demo data'), findsOneWidget);
    expect(find.text('Choose a transfer method'), findsOneWidget);
    await tester.tap(find.text('Bank transfer').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('services_wallet_bank')), findsOneWidget);
    await tester.ensureVisible(find.text('Submit withdrawal request'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit withdrawal request'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm withdrawal request'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.financeWalletWithdrawalRequestSent), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Sign out'),
      400,
      scrollable: find
          .ancestor(
            of: find.text('Sign out'),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Sign out'));
    expect(didLogout, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Merchant account tab renders in Arabic without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      buildTestScreen(
        MerchantsTabsShell(onLogout: () {}),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.tap(
      find.descendant(
        of: find.byType(FinanceBottomNavigationBar),
        matching: find.text(l10n.navAccount),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.merchantProfileName), findsOneWidget);
    expect(find.text(l10n.merchantProfileDocumentsTitle), findsOneWidget);
    expect(find.text(l10n.merchantProfileAvailability), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(l10n.merchantProfileBalanceTitle));
    await tester.pumpAndSettle();
    expect(find.byType(ServicesSupervisorWalletScreen), findsOneWidget);
    expect(find.text('محفظتي والعمليات المالية'), findsOneWidget);
    expect(find.text('طلب سحب رصيد'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test ProfileScreen in English', (tester) async {
    await testScreen(tester, const ProfileScreen(onLogout: _noop));
  });

  testWidgets('Test BankAccountsScreen in English', (tester) async {
    await testScreen(tester, const BankAccountsScreen());
  });

  testWidgets('Test DepartmentWalletScreen in English', (tester) async {
    await testScreen(
        tester, const DepartmentWalletScreen(type: DepartmentType.couriers));
  });

  testWidgets('Test ExpensesManagementScreen in English', (tester) async {
    await testScreen(tester, const ExpensesManagementScreen());
  });

  testWidgets('Test FrozenRequestsScreen in English', (tester) async {
    await testScreen(tester, const FrozenRequestsScreen());
  });

  testWidgets('Test MerchantWithdrawalsScreen in English', (tester) async {
    await testScreen(tester, const MerchantWithdrawalsScreen());
  });

  testWidgets('Test SubscriptionsScreen in English', (tester) async {
    await testScreen(tester, const SubscriptionsScreen());
  });

  testWidgets('Test SupervisorWithdrawalsScreen in English', (tester) async {
    await testScreen(tester, const SupervisorWithdrawalsScreen());
  });

  testWidgets(
      'Supervisor withdrawal archive shows final statuses without decision actions',
      (tester) async {
    final financeDataSource = di.sl<FinanceRemoteDataSource>();
    await financeDataSource.submitSupervisorWithdrawal(
      beneficiaryName: 'Pending workflow test',
      beneficiaryRole: 'Merchant account supervisor',
      sourceAccount: 'merchant',
      amount: 100,
      bankName: 'Test bank',
      iban: 'TEST-PENDING',
      transferMethod: 'Bank transfer',
    );
    final decidedRequest = await financeDataSource.submitSupervisorWithdrawal(
      beneficiaryName: 'Archived workflow test',
      beneficiaryRole: 'Merchant account supervisor',
      sourceAccount: 'merchant',
      amount: 100,
      bankName: 'Test bank',
      iban: 'TEST-ARCHIVED',
      transferMethod: 'Bank transfer',
    );
    await financeDataSource.approveWithdrawal(decidedRequest.id);

    await testScreen(tester, const SupervisorWithdrawalsScreen());

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SupervisorWithdrawalsScreen)),
    )!;
    await tester.ensureVisible(find.text(l10n.financeRequestsArchiveTab));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.financeRequestsArchiveTab));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(l10n.financeRequestApprovedBadge));
    await tester.pumpAndSettle();

    expect(find.text(l10n.financeRequestApprovalTitle), findsNothing);
    expect(find.text(l10n.approveAndSendToAdmin), findsNothing);
    expect(find.text(l10n.approveAndIssueBankOrder), findsNothing);
    expect(find.text(l10n.financeRequestApprovedBadge), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test EditMatrixScreen in English', (tester) async {
    await testScreen(tester, const EditMatrixScreen());
  });

  testWidgets('Test TransactionHistoryScreen in English', (tester) async {
    await testScreen(
        tester,
        const TransactionHistoryScreen(
          title: 'Test Wallet',
          id: 'WAL-123',
          availableBalance: 50000.0,
        ));
  });

  testWidgets('Test BankReconciliationScreen in English', (tester) async {
    await testScreen(tester, const BankReconciliationScreen());
  });
}

void _noop() {}
