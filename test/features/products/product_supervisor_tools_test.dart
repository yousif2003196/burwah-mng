import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/app/navigation/product_supervisor_tabs_shell.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_conversation_screen.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_audit_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_chats_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_notifications_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_support_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  Widget localizedApp(Widget home) => MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      );

  testWidgets('review app bar opens notification center and chats',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await LocalEventStore().publish(
      LocalEvent(
        id: 'product-notification-test',
        recipient: 'products',
        source: 'finance',
        titleAr: 'طلبات جديدة قيد المراجعة',
        titleEn: 'New requests awaiting review',
        messageAr: 'تم استلام طلب مالي جديد.',
        messageEn: 'A new financial request was received.',
        createdAt: DateTime.now(),
      ),
    );
    await tester.pumpWidget(
      localizedApp(const ProductSupervisorTabsShell(onLogout: _ignoreLogout)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('الإشعارات'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductSupervisorNotificationsScreen), findsOneWidget);
    expect(find.text('طلبات جديدة قيد المراجعة'), findsOneWidget);
    Navigator.of(
      tester.element(find.byType(ProductSupervisorNotificationsScreen)),
    ).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('الدردشات'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductSupervisorChatsScreen), findsOneWidget);
    expect(find.text('رئيس المشرفين'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('support chat opens the shared conversation screen',
      (tester) async {
    await tester.pumpWidget(
      localizedApp(const ProductSupervisorSupportScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('بدء محادثة').first);
    await tester.pumpAndSettle();

    expect(find.byType(MerchantConversationScreen), findsOneWidget);
    expect(find.text('رئيس المشرفين'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'أحتاج إلى مساعدة');
    await tester.tap(find.byTooltip('إرسال'));
    await tester.pumpAndSettle();
    expect(find.text('أحتاج إلى مساعدة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('audit history displays persisted supervisory decisions',
      (tester) async {
    await sl<ProductSupervisorAuditRepository>().recordEntry(
      ProductSupervisorAuditEntry(
        id: 'audit-test',
        actionKey: 'product_approved',
        subject: 'ساعة اختبار',
        details: 'PRD-TEST',
        occurredAt: DateTime.utc(2026, 10, 7, 10),
      ),
    );
    await tester.pumpWidget(
      localizedApp(const ProductSupervisorAuditScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('اعتماد منتج'), findsWidgets);
    expect(find.text('ساعة اختبار'), findsOneWidget);
    expect(find.text('PRD-TEST'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _ignoreLogout() {}
