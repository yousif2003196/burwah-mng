import 'package:flutter/material.dart';

import '../../../../core/widgets/account_conversations_screen.dart';

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
