import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/app/app.dart';
import 'package:barwah_app/core/widgets/app_launch_splash.dart';
import 'package:barwah_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('app shows animated brand splash before login', (tester) async {
    await tester.pumpWidget(const BarwahApp());

    expect(find.byType(AppLaunchSplash), findsOneWidget);
    expect(find.byKey(const ValueKey('brand-wordmark')), findsOneWidget);
    expect(find.byIcon(Icons.shield_rounded), findsNWidgets(4));

    final shieldStart =
        tester.getTopLeft(find.byIcon(Icons.shield_rounded).first);
    await tester.pump(const Duration(milliseconds: 400));
    final shieldInMotion =
        tester.getTopLeft(find.byIcon(Icons.shield_rounded).first);
    expect(shieldInMotion, isNot(shieldStart));

    final firstLetter = find.byKey(const ValueKey('brand-letter-0'));
    final lastLetter = find.byKey(const ValueKey('brand-letter-9'));
    final letterStart = tester.getTopLeft(firstLetter);
    final lastLetterStart = tester.getTopLeft(lastLetter);

    await tester.pump(const Duration(milliseconds: 750));
    expect(tester.getTopLeft(firstLetter), isNot(letterStart));
    expect(tester.getTopLeft(lastLetter), lastLetterStart);

    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.getTopLeft(lastLetter), isNot(lastLetterStart));
    expect(find.byKey(const ValueKey('brand-wordmark')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AppLaunchSplash), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
