import 'package:flutter/material.dart';

import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';

class ProductSupervisorChatsScreen extends StatelessWidget {
  final String accountId;

  const ProductSupervisorChatsScreen({
    super.key,
    this.accountId = 'products',
  });

  @override
  Widget build(BuildContext context) =>
      AccountConversationsScreen(accountId: accountId);
}
