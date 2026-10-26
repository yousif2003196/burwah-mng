import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/data/datasources/conversation_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/chat_account.dart';
import 'package:barwah_app/features/messaging/domain/entities/conversation.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class AccountConversationsScreen extends StatefulWidget {
  static ValueNotifier<int> get unreadRevision => ConversationStore.unreadRevision;

  final String accountId;

  const AccountConversationsScreen({
    super.key,
    required this.accountId,
  });

  static Future<int> unreadCountFor(String accountId) =>
      ConversationStore.instance.unreadCountFor(accountId);

  static Future<void> openDirectConversation({
    required BuildContext context,
    required String firstAccountId,
    required String otherAccountId,
    required String requestId,
    required String initialMessage,
  }) async {
    final conversation = await ConversationStore.instance.openConversation(
      firstAccountId,
      otherAccountId,
      requestId,
    );
    if (initialMessage.trim().isNotEmpty) {
      await ConversationStore.instance.sendMessage(
        conversation.id,
        firstAccountId,
        initialMessage.trim(),
      );
    }
    if (!context.mounted) return;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _ConversationThreadScreen(
          conversationId: conversation.id,
          accountId: firstAccountId,
          title: chatAccountName(otherAccountId, isArabic),
        ),
      ),
    );
  }

  @override
  State<AccountConversationsScreen> createState() =>
      _AccountConversationsScreenState();
}

class AccountChatUnreadBadge extends StatelessWidget {
  final String accountId;
  final Widget child;

  const AccountChatUnreadBadge({
    super.key,
    required this.accountId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: AccountConversationsScreen.unreadRevision,
        builder: (context, revision, _) => FutureBuilder<int>(
          future: AccountConversationsScreen.unreadCountFor(accountId),
          builder: (context, snapshot) {
            final unread = snapshot.data ?? 0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                child,
                if (unread > 0)
                  PositionedDirectional(
                    top: -7,
                    end: -9,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
}

class _AccountConversationsScreenState
    extends State<AccountConversationsScreen> {
  late Future<List<Conversation>> _conversations;
  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _conversations = ConversationStore.instance.forAccount(widget.accountId);
  }

  void _reload() {
    setState(() {
      _conversations = ConversationStore.instance.forAccount(widget.accountId);
    });
  }

  Future<void> _startConversation() async {
    final otherAccount = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 12),
              child: Text(
                _isArabic ? 'اختر الحساب' : 'Choose an account',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final account in chatAccounts.entries)
              if (account.key != widget.accountId)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceLight,
                    child: MotionIcon(Icons.person_outline,
                        color: AppColors.ink),
                  ),
                  title: Text(_isArabic ? account.value.$1 : account.value.$2),
                  onTap: () => Navigator.pop(context, account.key),
                ),
          ],
        ),
      ),
    );
    if (otherAccount == null || !mounted) return;
    final requestController = TextEditingController();
    try {
      final requestId = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_isArabic ? 'محادثة جديدة' : 'New conversation'),
          content: TextField(
            controller: requestController,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: _isArabic
                  ? 'رقم الطلب (اختياري)'
                  : 'Request reference (optional)',
              hintText: 'REQ-1234',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_isArabic ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, requestController.text.trim()),
              child: Text(_isArabic ? 'إنشاء' : 'Create'),
            ),
          ],
        ),
      );
      if (requestId == null || !mounted) return;
      await ConversationStore.instance.openConversation(
        widget.accountId,
        otherAccount,
        requestId,
      );
      _reload();
    } finally {
      requestController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isArabic ? 'المحادثات' : 'Conversations';
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(title),
          actions: [
            IconButton(
              tooltip: _isArabic ? 'محادثة جديدة' : 'New conversation',
              onPressed: _startConversation,
              icon: const MotionIcon(Icons.add_comment_outlined),
            ),
          ],
        ),
        body: FutureBuilder<List<Conversation>>(
          future: _conversations,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(_isArabic
                    ? 'تعذر تحميل المحادثات.'
                    : 'Could not load conversations.'),
              );
            }
            final items = snapshot.data ?? const <Conversation>[];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MotionIcon(Icons.forum_outlined,
                          size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        _isArabic
                            ? 'لا توجد محادثات بعد. ابدأ محادثة مع حساب آخر.'
                            : 'No conversations yet. Start one with another account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final conversation = items[index];
                final other = conversation.participants.firstWhere(
                  (id) => id != widget.accountId,
                  orElse: () => widget.accountId,
                );
                final name = chatAccountName(other, _isArabic);
                final latest = conversation.messages.isEmpty
                    ? (_isArabic ? 'ابدأ المحادثة' : 'Start the conversation')
                    : conversation.messages.last.body;
                final unread = conversation.messages
                    .where((message) =>
                        message.senderId != widget.accountId &&
                        !message.readBy.contains(widget.accountId))
                    .length;
                return Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceLight,
                      child: MotionIcon(_accountIcon(other),
                          color: AppColors.ink),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        if (unread > 0)
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: AppColors.primaryDark,
                            child: CountText('$unread',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '${conversation.requestId.isEmpty ? '' : '${conversation.requestId} · '}$latest',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => _ConversationThreadScreen(
                            conversationId: conversation.id,
                            accountId: widget.accountId,
                            title: name,
                          ),
                        ),
                      );
                      _reload();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ConversationThreadScreen extends StatefulWidget {
  final String conversationId;
  final String accountId;
  final String title;

  const _ConversationThreadScreen({
    required this.conversationId,
    required this.accountId,
    required this.title,
  });

  @override
  State<_ConversationThreadScreen> createState() =>
      _ConversationThreadScreenState();
}

class _ConversationThreadScreenState extends State<_ConversationThreadScreen> {
  final _controller = TextEditingController();
  Conversation? _conversation;
  bool _isLoading = true;
  bool _isSending = false;

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final conversation = await ConversationStore.instance.markRead(
        widget.conversationId,
        widget.accountId,
      );
      if (!mounted) return;
      setState(() {
        _conversation = conversation;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'account conversations',
      ));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _send() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      final updated = await ConversationStore.instance.sendMessage(
        widget.conversationId,
        widget.accountId,
        body,
      );
      if (!mounted) return;
      _controller.clear();
      setState(() => _conversation = updated);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'account conversations',
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isArabic
                ? 'تعذر حفظ الرسالة.'
                : 'Could not save the message.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(widget.title),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_conversation?.requestId.isNotEmpty == true)
                    Container(
                      width: double.infinity,
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '${_isArabic ? 'مرتبطة بالطلب' : 'Linked request'}: ${_conversation!.requestId}',
                        style: TextStyle(
                          color: AppColors.infoDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Expanded(
                    child: _conversation == null
                        ? Center(
                            child: Text(_isArabic
                                ? 'المحادثة غير متاحة.'
                                : 'Conversation unavailable.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _conversation!.messages.length,
                            itemBuilder: (context, index) {
                              final message = _conversation!.messages[index];
                              final isMine =
                                  message.senderId == widget.accountId;
                              return Align(
                                alignment: isMine
                                    ? AlignmentDirectional.centerEnd
                                    : AlignmentDirectional.centerStart,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width * .78,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isMine
                                        ? AppColors.primaryDark
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(message.body,
                                          style: TextStyle(
                                              color: isMine
                                                  ? Colors.white
                                                  : AppColors.textPrimary)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${chatAccountName(message.senderId, _isArabic)} · ${message.createdAt.toLocal().toString().substring(0, 16)}',
                                        style: TextStyle(
                                          color: isMine
                                              ? Colors.white70
                                              : AppColors.textMuted,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: AppColors.surface,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                              decoration: InputDecoration(
                                hintText: _isArabic
                                    ? 'اكتب رسالة'
                                    : 'Write a message',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _isSending ? null : _send,
                            icon: const MotionIcon(Icons.send_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

IconData _accountIcon(String id) => switch (id) {
      'finance' => Icons.account_balance_outlined,
      'merchant' => Icons.storefront_outlined,
      'products' => Icons.inventory_2_outlined,
      'wasalny' => Icons.local_shipping_outlined,
      'services' => Icons.support_agent_outlined,
      'admin' => Icons.shield_outlined,
      _ => Icons.supervisor_account_outlined,
    };
