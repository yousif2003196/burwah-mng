import 'package:flutter/material.dart';

import 'package:barwah_app/features/messaging/presentation/screens/local_event_inbox_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

class ProductSupervisorNotificationsScreen extends StatelessWidget {
  const ProductSupervisorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => LocalEventInboxScreen(
        recipient: 'products',
        title: AppLocalizations.of(context)!.productNotificationsTitle,
      );
}
