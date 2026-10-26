import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/merchants/presentation/screens/merchant_conversation_screen.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_mock_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/repositories/wasalny_complaints_repository_impl.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/escalate_wasalny_complaint_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/get_wasalny_complaints_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/resolve_wasalny_complaint_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_complaints_cubit.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_complaints_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('escalation opens the review sheet and confirms the complaint',
      (tester) async {
    tester.view.physicalSize = const Size(440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = WasalnyComplaintsRepositoryImpl(
      dataSource: WasalnyComplaintsMockDataSource(),
    );
    final cubit = WasalnyComplaintsCubit(
      getComplaints: GetWasalnyComplaintsUseCase(repository),
      escalateComplaint: EscalateWasalnyComplaintUseCase(repository),
      resolveComplaint: ResolveWasalnyComplaintUseCase(repository),
    )..loadComplaints();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          locale: Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WasalnyComplaintsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('WS-CMP-4088'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تصعيد الشكوى لرئيس المشرفين'));
    await tester.pumpAndSettle();

    expect(find.text('إجراء تصعيد الشكوى'), findsOneWidget);
    expect(find.text('صفقة وصلني #WS-4088'), findsNWidgets(2));
    expect(find.text('1,850 ج.م'), findsNWidgets(2));
    expect(find.text('صلاحيات وضوابط اللجنة الرقابية'), findsOneWidget);

    await tester.tap(find.text('تأكيد رفع تصعيد الشكوى رسمياً'));
    await tester.pumpAndSettle();

    // A written reason is mandatory.
    await tester.tap(find.text('تصعيد'));
    await tester.pumpAndSettle();
    expect(find.text('سبب التصعيد'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'تأخر البائع وخلاف على المبلغ');
    await tester.tap(find.text('تصعيد'));
    await tester.pumpAndSettle();

    expect(find.text('مصعّدة لرئيس المشرفين'), findsOneWidget);
    expect(find.text('تم تصعيد الشكوى لرئيس المشرفين'), findsOneWidget);
  });

  testWidgets('party chat opens a shared conversation with seller and buyer',
      (tester) async {
    tester.view.physicalSize = const Size(440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = WasalnyComplaintsRepositoryImpl(
      dataSource: WasalnyComplaintsMockDataSource(),
    );
    final cubit = WasalnyComplaintsCubit(
      getComplaints: GetWasalnyComplaintsUseCase(repository),
      escalateComplaint: EscalateWasalnyComplaintUseCase(repository),
      resolveComplaint: ResolveWasalnyComplaintUseCase(repository),
    )..loadComplaints();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          locale: Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WasalnyComplaintsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('WS-CMP-4088'));
    await tester.pumpAndSettle();
    final partyChat = find.byTooltip('دردشة مع الطرفين').first;
    await tester.ensureVisible(partyChat);
    await tester.pumpAndSettle();
    await tester.tap(partyChat);
    await tester.pumpAndSettle();

    expect(find.byType(MerchantConversationScreen), findsOneWidget);
    expect(find.textContaining('محمد الدوسري'), findsOneWidget);
    expect(find.textContaining('سلطان الحربي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling escalation leaves the complaint under review',
      (tester) async {
    tester.view.physicalSize = const Size(440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = WasalnyComplaintsRepositoryImpl(
      dataSource: WasalnyComplaintsMockDataSource(),
    );
    final cubit = WasalnyComplaintsCubit(
      getComplaints: GetWasalnyComplaintsUseCase(repository),
      escalateComplaint: EscalateWasalnyComplaintUseCase(repository),
      resolveComplaint: ResolveWasalnyComplaintUseCase(repository),
    )..loadComplaints();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          locale: Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WasalnyComplaintsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('WS-CMP-4088'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تصعيد الشكوى لرئيس المشرفين'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العودة لقائمة الشكاوى').last);
    await tester.pumpAndSettle();

    expect(
      (cubit.state as WasalnyComplaintsLoaded).complaints.first.status,
      WasalnyComplaintStatus.underReview,
    );
    expect(find.text('تم تصعيد الشكوى لرئيس المشرفين'), findsNothing);
  });
}
