import 'package:flutter/material.dart';

import 'package:barwah_app/features/messaging/presentation/screens/server_notifications_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

/// إشعارات مشرف وصلني: كلها من السيرفر.
class WasalnySupervisorNotificationsScreen extends StatelessWidget {
  const WasalnySupervisorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => ServerNotificationsScreen(
        title: AppLocalizations.of(context)!.wasalnyNotificationsTitle,
      );
}
