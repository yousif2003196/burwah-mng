import 'dart:async';

import 'package:flutter/material.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/features/messaging/presentation/screens/ad_owner_chat_screen.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/data/datasources/conversation_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/chat_account.dart';
import 'package:barwah_app/features/messaging/domain/entities/conversation.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class AccountConversationsScreen extends StatefulWidget {
  static ValueNotifier<int> get unreadRevision =>
      ConversationStore.unreadRevision;

  final String accountId;

  const AccountConversationsScreen({
    super.key,
    required this.accountId,
  });

  /// الحسابات الحقيقية (داخلة بالسيرفر) بتعد محادثات السيرفر بس؛ المحادثات المحلية للوضع التجريبي فقط.
  static Future<int> unreadCountFor(String accountId) async =>
      (AuthSession.isSignedIn
          ? 0
          : await ConversationStore.instance.unreadCountFor(accountId)) +
      (await _serverChats()).fold<int>(0, (sum, chat) => sum + chat.unread);

  static Future<List<Conversation>> _local(String accountId) =>
      AuthSession.isSignedIn
          ? Future.value(const <Conversation>[])
          : ConversationStore.instance.forAccount(accountId);

  /// The customers' chats of the signed-in account, from the server (empty when signed out or on any failure).
  static Future<List<_ServerChat>> _serverChats() async {
    if (!AuthSession.isSignedIn) return const [];
    try {
      final response = await sl<ApiConsumer>(instanceName: 'berwah')
          .get<Object>('api/Chat/conversations');
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! List) return const [];
      return [
        for (final item in data)
          if (item is Map && item['id'] is num)
            _ServerChat.fromJson(Map<String, dynamic>.from(item)),
      ];
    } catch (_) {
      return const [];
    }
  }

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

/// A chat with a customer, as the server lists it.
class _ServerChat {
  _ServerChat({
    required this.id,
    required this.kind,
    required this.refId,
    required this.name,
    required this.lastMessage,
    required this.at,
    required this.unread,
    required this.closed,
  });

  final int id;
  final int kind;
  final int refId;
  final String name;
  final String lastMessage;
  final DateTime? at;
  final int unread;
  final bool closed;

  factory _ServerChat.fromJson(Map<String, dynamic> j) => _ServerChat(
        id: (j['id'] as num).toInt(),
        kind: (j['kind'] as num?)?.toInt() ?? 0,
        refId: (j['refId'] as num?)?.toInt() ?? 0,
        name: '${j['otherName'] ?? ''}'.trim(),
        lastMessage: '${j['lastMessage'] ?? ''}',
        at: DateTime.tryParse('${j['lastMessageAt']}')?.toLocal(),
        unread: (j['unread'] as num?)?.toInt() ?? 0,
        closed: j['closed'] == true,
      );

  String kindLabel(bool arabic) => switch (kind) {
        1 => arabic ? 'طلب خدمة' : 'Service',
        2 => arabic ? 'طلب' : 'Order',
        3 => arabic ? 'توصيل' : 'Delivery',
        4 => arabic ? 'مراجعة إعلان' : 'Ad review',
        5 => arabic ? 'مزاد' : 'Auction',
        6 => arabic ? 'صفقة' : 'Deal',
        7 => arabic ? 'طلب وصلني' : 'Wasalny request',
        8 => arabic ? 'شكوى' : 'Complaint',
        9 => arabic ? 'مشرف' : 'Supervisor',
        _ => arabic ? 'محادثة' : 'Chat',
      };
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
                      constraints:
                          const BoxConstraints(minWidth: 17, minHeight: 17),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.danger, shape: BoxShape.circle),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
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
  List<_ServerChat> _server = const [];
  StreamSubscription<RealtimeChatMessage>? _chatSub;
  String _query = '';
  int _filter = 0; // 0 all · 1 customers · 2 supervisors · 3 unread
  static Color get _navy => AppColors.primaryDark;
  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _conversations = AccountConversationsScreen._local(widget.accountId);
    _loadServer();
    // A new message from a customer puts its chat on top at once.
    _chatSub = RealtimeHub.instance.chats.listen((_) => _loadServer());
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    super.dispose();
  }

  Future<void> _loadServer() async {
    final chats = await AccountConversationsScreen._serverChats();
    if (!mounted) return;
    setState(() => _server = chats);
  }

  void _reload() {
    setState(() {
      _conversations = AccountConversationsScreen._local(widget.accountId);
    });
    _loadServer();
  }

  Widget _serverTile(_ServerChat chat) {
    final name =
        chat.name.isEmpty ? (_isArabic ? 'عميل' : 'Customer') : chat.name;
    final last = chat.lastMessage.isEmpty
        ? (_isArabic ? 'ابدأ المحادثة' : 'Start the conversation')
        : chat.lastMessage;
    final kind = chat.kindLabel(_isArabic);
    final preview = _previewIcon(chat.lastMessage);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => AdOwnerChatScreen(
                adId: chat.refId,
                conversationId: chat.id,
                title: name,
                subtitle: kind,
              ),
            ),
          );
          _reload();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.infoLight,
                child: Text(
                  name.characters.first,
                  style: TextStyle(
                      color: AppColors.infoDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 17),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: chat.unread > 0
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              fontSize: 14.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(
                            color: _navy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(kind,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _navy)),
                        ),
                        if (chat.closed) ...[
                          const SizedBox(width: 6),
                          Text(_isArabic ? 'مقفولة' : 'Closed',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (preview != null) ...[
                          Icon(preview,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: chat.unread > 0
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: chat.unread > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_timeLabel(chat.at),
                      style: TextStyle(
                          fontSize: 10.5, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  if (chat.unread > 0)
                    Container(
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: _navy,
                          borderRadius: const BorderRadius.all(Radius.circular(99))),
                      child: CountText('${chat.unread}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800)),
                    )
                  else
                    const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData? _previewIcon(String last) {
    if (last.startsWith('🎤')) return Icons.mic_rounded;
    if (last.startsWith('📷')) return Icons.photo_camera_outlined;
    if (last.startsWith('🎥')) return Icons.videocam_outlined;
    return null;
  }

  String _timeLabel(DateTime? at) {
    if (at == null) return '';
    final now = DateTime.now();
    final sameDay =
        at.year == now.year && at.month == now.month && at.day == now.day;
    if (sameDay) {
      return '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    }
    if (now.difference(at).inDays < 2) return _isArabic ? 'أمس' : 'Yesterday';
    return '${at.day}/${at.month}';
  }

  Widget _filterBar() {
    // المحادثات بين المشرفين كانت محلية (تجريبية)، فبتختفي للحسابات الحقيقية.
    final real = AuthSession.isSignedIn;
    final labels = _isArabic
        ? ['الكل', 'العملاء', if (!real) 'المشرفون', 'غير المقروء']
        : ['All', 'Customers', if (!real) 'Supervisors', 'Unread'];
    // رقم الفلتر الحقيقي لكل شريحة (0 الكل · 1 العملاء · 2 المشرفون · 3 غير المقروء).
    final codes = real ? const [0, 1, 3] : const [0, 1, 2, 3];
    return Container(
      color: _navy,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: _isArabic
                          ? 'ابحث في المحادثات'
                          : 'Search conversations',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: labels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final on = _filter == codes[i];
                return GestureDetector(
                  onTap: () => setState(() => _filter = codes[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(labels[i],
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: on ? _navy : Colors.white)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
                    child:
                        MotionIcon(Icons.person_outline, color: AppColors.ink),
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
              onPressed: () =>
                  Navigator.pop(context, requestController.text.trim()),
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
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            if (!AuthSession.isSignedIn)
            IconButton(
              tooltip: _isArabic ? 'محادثة جديدة' : 'New conversation',
              onPressed: _startConversation,
              icon: const MotionIcon(Icons.add_comment_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            _filterBar(),
            Expanded(
                child: FutureBuilder<List<Conversation>>(
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
                if (items.isEmpty && _server.isEmpty) {
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
                final q = _query.trim();
                final srv = _server
                    .where((c) =>
                        (_filter == 0 ||
                            _filter == 1 ||
                            (_filter == 3 && c.unread > 0)) &&
                        (_filter != 3 || c.unread > 0) &&
                        (q.isEmpty ||
                            c.name.contains(q) ||
                            c.lastMessage.contains(q)))
                    .toList();
                int localUnread(Conversation c) => c.messages
                    .where((m) =>
                        m.senderId != widget.accountId &&
                        !m.readBy.contains(widget.accountId))
                    .length;
                final loc = items.where((c) {
                  if (_filter == 1) return false;
                  if (_filter == 3 && localUnread(c) == 0) return false;
                  if (q.isEmpty) return true;
                  final other = c.participants.firstWhere(
                      (id) => id != widget.accountId,
                      orElse: () => widget.accountId);
                  return chatAccountName(other, _isArabic).contains(q) ||
                      (c.messages.isNotEmpty &&
                          c.messages.last.body.contains(q));
                }).toList();
                if (srv.isEmpty && loc.isEmpty) {
                  return Center(
                    child: Text(_isArabic ? 'لا توجد نتائج' : 'No results',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: srv.length + loc.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    if (index < srv.length) return _serverTile(srv[index]);
                    final conversation = loc[index - srv.length];
                    final other = conversation.participants.firstWhere(
                      (id) => id != widget.accountId,
                      orElse: () => widget.accountId,
                    );
                    final name = chatAccountName(other, _isArabic);
                    final latest = conversation.messages.isEmpty
                        ? (_isArabic
                            ? 'ابدأ المحادثة'
                            : 'Start the conversation')
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
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
            )),
          ],
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
