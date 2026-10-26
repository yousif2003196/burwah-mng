import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/merchants/data/datasources/merchant_supervisor_local_store.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_profile_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  Widget buildApp() {
    return const MaterialApp(
      locale: Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: MerchantProfileScreen(onLogout: _ignoreLogout)),
    );
  }

  testWidgets('profile preferences persist and record local activity',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final availabilityToggle = find.byKey(
      const ValueKey('merchant_profile_availability_toggle'),
    );
    expect(tester.widget<Switch>(availabilityToggle).value, isFalse);
    await tester.ensureVisible(availabilityToggle);
    await tester.tap(availabilityToggle);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(availabilityToggle).value, isTrue);
    expect(find.text('Profile preference changed'), findsOneWidget);
    expect(find.textContaining('Field Availability and Readiness · Enabled'),
        findsOneWidget);
    expect(
      find.textContaining('not a server audit log'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(availabilityToggle).value, isTrue);
    expect(find.text('Profile preference changed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile audit shows supervisory operations and settings action',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await MerchantSupervisorLocalStore.recordAction(
      action: 'Merchant suspended',
      subject: 'Test merchant',
      details: 'Compliance review',
    );
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Merchant suspended'), findsOneWidget);
    expect(find.textContaining('Test merchant · Compliance review'),
        findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('merchant_profile_change_settings')),
    );
    await tester.tap(
      find.byKey(const ValueKey('merchant_profile_change_settings')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Change settings'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}

void _ignoreLogout() {}
