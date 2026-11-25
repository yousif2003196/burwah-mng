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
    this.lastFromMe = false,
    this.image,
  });

  final int id;
  final int kind;
  final int refId;
  final String name;
  final String lastMessage;
  final DateTime? at;
  final int unread;
  final bool closed;

  /// آخر رسالة أنا اللي باعتها (بيظهر قبلها «أنت:»).
  final bool lastFromMe;
  final String? image;

  factory _ServerChat.fromJson(Map<String, dynamic> j) => _ServerChat(
        id: (j['id'] as num).toInt(),
        kind: (j['kind'] as num?)?.toInt() ?? 0,
        refId: (j['refId'] as num?)?.toInt() ?? 0,
        name: '${j['otherName'] ?? ''}'.trim(),
        lastMessage: '${j['lastMessage'] ?? ''}',
        at: _utc(j['lastMessageAt'])?.toLocal(),
        unread: (j['unread'] as num?)?.toInt() ?? 0,
        closed: j['closed'] == true,
        lastFromMe: j['lastFromMe'] == true,
        image: '${j['otherImage'] ?? ''}'.trim().isEmpty ? null : '${j['otherImage']}'.trim(),
      );

  /// السيرفر بيبعت الوقت UTC من غير Z.
  static DateTime? _utc(Object? raw) {
    final t = '${raw ?? ''}'.trim();
    if (t.isEmpty || t == 'null') return null;
    final zoned = t.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(t);
    return DateTime.tryParse(zoned ? t : '${t}Z');
  }

  /// لون وأيقونة نوع المحادثة (بيتبعوا ألوان الثيم الفاتح والداكن).
  ({Color fg, Color bg, IconData icon}) get style => switch (kind) {
        8 => (fg: AppColors.dangerDark, bg: AppColors.dangerLight, icon: Icons.report_problem_rounded),
        1 => (fg: AppColors.infoDark, bg: AppColors.infoLight, icon: Icons.handyman_rounded),
        2 => (fg: AppColors.warningDark, bg: AppColors.warningLight, icon: Icons.receipt_long_rounded),
        3 => (fg: AppColors.warningDark, bg: AppColors.warningLight, icon: Icons.delivery_dining_rounded),
        7 => (fg: AppColors.warningDark, bg: AppColors.warningLight, icon: Icons.directions_car_rounded),
        4 => (fg: AppColors.successDark, bg: AppColors.successLight, icon: Icons.sell_rounded),
        5 => (fg: AppColors.successDark, bg: AppColors.successLight, icon: Icons.gavel_rounded),
        6 => (fg: AppColors.successDark, bg: AppColors.successLight, icon: Icons.handshake_rounded),
        9 => (fg: AppColors.purple, bg: AppColors.surfaceHighlight, icon: Icons.support_agent_rounded),
        _ => (fg: AppColors.ink, bg: AppColors.surfaceHighlight, icon: Icons.chat_rounded),
      };

  String kindLabel(bool arabic) => switch (kind) {
        1 => arabic ? 'طلب خدمة' : 'Service',
        2 => arabic ? 'طلب' : 'Order',
        3 => arabic ? 'توصيل' : 'Delivery',
        4 => arabic ? 'مراجعة إعلان' : 'Ad review',
        5 => arabic ? 'مزاد' : 'Auction',
        6 => arabic ? 'صفقة' : 'Deal',
        7 => arabic ? 'طلب وصلني' : 'Wasalny request',
        8 => arabic ? 'شكوى' : 'Complaint',
        9 => arabic ? 'محادثة مباشرة' : 'Direct',
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
  /// all · unread · complaints · requests · ads · direct · supervisors (تجريبي)
  String _filter = 'all';
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
    final initials = name.trim().isEmpty
        ? '؟'
        : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w.characters.first).join();
    final kind = chat.kindLabel(_isArabic);
    final style = chat.style;
    final preview = _previewIcon(chat.lastMessage);
    final cleanLast = preview == null
        ? chat.lastMessage
        : chat.lastMessage.characters.skip(1).toString().trim();
    final last = chat.lastMessage.isEmpty
        ? (_isArabic ? 'ابدأ المحادثة' : 'Start the conversation')
        : '${chat.lastFromMe ? (_isArabic ? 'أنت: ' : 'You: ') : ''}$cleanLast';
    final hot = chat.unread > 0 && !chat.closed;
    final muted = chat.closed;
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor:
                        muted ? AppColors.surfaceLight : style.bg,
                    backgroundImage: chat.image == null
                        ? null
                        : NetworkImage(chat.image!),
                    child: chat.image != null
                        ? null
                        : Text(initials,
                            style: TextStyle(
                                color: muted ? AppColors.textMuted : style.fg,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                  ),
                  PositionedDirectional(
                    bottom: -2,
                    end: -2,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: muted ? AppColors.textMuted : style.fg,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: Icon(muted ? Icons.lock_rounded : style.icon,
                          size: 10, color: AppColors.surface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: hot ? FontWeight.w800 : FontWeight.w700,
                            fontSize: 14,
                            color: muted
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(_timeLabel(chat.at),
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: hot ? FontWeight.w800 : FontWeight.w500,
                              color: hot ? AppColors.infoDark : AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    muted ? '${_isArabic ? 'مقفولة' : 'Closed'} • $kind' : kind,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: muted ? AppColors.textMuted : style.fg),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (preview != null) ...[
                        Icon(preview,
                            size: 14,
                            color: hot ? AppColors.textPrimary : AppColors.textSecondary),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: hot
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: hot ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (chat.unread > 0) ...[
                        const SizedBox(width: 6),
                        _unreadPill(chat.unread),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
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
    if (now.difference(at).inDays < 2) return _isArabic ? 'امبارح' : 'Yesterday';
    return '${at.day}/${at.month}';
  }

  Widget _filterBar() {
    // المحادثات بين المشرفين كانت محلية (تجريبية)، فبتختفي للحسابات الحقيقية.
    final real = AuthSession.isSignedIn;
    int count(String f) => _server.where((c) => _matchesKey(c, f)).length;
    final filters = <(String, String)>[
      ('all', _isArabic ? 'الكل' : 'All'),
      ('unread', _isArabic ? 'غير مقروء' : 'Unread'),
      ('complaints', _isArabic ? 'شكاوى' : 'Complaints'),
      ('requests', _isArabic ? 'طلبات' : 'Requests'),
      ('ads', _isArabic ? 'إعلانات' : 'Ads'),
      ('direct', _isArabic ? 'مباشرة' : 'Direct'),
      if (!real) ('supervisors', _isArabic ? 'المشرفون' : 'Supervisors'),
    ].where((f) =>
        f.$1 == 'all' || f.$1 == 'unread' || f.$1 == 'supervisors' || count(f.$1) > 0);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: _isArabic
                          ? 'ابحث بالاسم أو الرسالة'
                          : 'Search by name or message',
                      hintStyle: TextStyle(color: AppColors.textMuted),
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
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final f in filters)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _filter == f.$1
                              ? _navy
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          f.$1 == 'supervisors' || (f.$1 == 'all' && _server.isEmpty)
                              ? f.$2
                              : '${f.$2} ${f.$1 == 'all' ? _server.length : count(f.$1)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _filter == f.$1
                                ? Colors.white
                                : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
    final needReply = _server.where((c) => c.unread > 0 && !c.closed).length;
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 4,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.ink)),
              Text(
                needReply > 0
                    ? (_isArabic
                        ? '$needReply محتاجين رد'
                        : '$needReply need a reply')
                    : (_isArabic ? 'كله متردّ عليه' : 'All caught up'),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: needReply > 0
                        ? AppColors.warningDark
                        : AppColors.textMuted),
              ),
            ],
          ),
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
                  return _emptyState(
                    Icons.cloud_off_outlined,
                    _isArabic
                        ? 'تعذر تحميل المحادثات.'
                        : 'Could not load conversations.',
                  );
                }
                final items = snapshot.data ?? const <Conversation>[];
                if (items.isEmpty && _server.isEmpty) {
                  return _emptyState(
                    Icons.forum_outlined,
                    AuthSession.isSignedIn
                        ? (_isArabic
                            ? 'لسه مفيش محادثات. أول ما حد يكلمك أو تفتح محادثة من طلب أو شكوى هتظهر هنا.'
                            : 'No conversations yet. They show up here once someone messages you.')
                        : (_isArabic
                            ? 'لا توجد محادثات بعد. ابدأ محادثة مع حساب آخر.'
                            : 'No conversations yet. Start one with another account.'),
                  );
                }
                final q = _query.trim();
                final srv = _server
                    .where((c) =>
                        _matchesFilter(c) &&
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
                  if (_filter != 'all' &&
                      _filter != 'supervisors' &&
                      _filter != 'unread') {
                    return false;
                  }
                  if (_filter == 'unread' && localUnread(c) == 0) return false;
                  if (q.isEmpty) return true;
                  final other = c.participants.firstWhere(
                      (id) => id != widget.accountId,
                      orElse: () => widget.accountId);
                  return chatAccountName(other, _isArabic).contains(q) ||
                      (c.messages.isNotEmpty &&
                          c.messages.last.body.contains(q));
                }).toList();
                if (srv.isEmpty && loc.isEmpty) {
                  return _emptyState(Icons.search_off_rounded,
                      _isArabic ? 'لا توجد نتائج' : 'No results');
                }
                final pending =
                    srv.where((c) => c.unread > 0 && !c.closed).toList();
                final rest =
                    srv.where((c) => !(c.unread > 0 && !c.closed)).toList();
                return RefreshIndicator(
                  onRefresh: _loadServer,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    children: [
                      if (pending.isNotEmpty) ...[
                        _sectionLabel(
                          _isArabic ? 'محتاجة ردك' : 'Needs your reply',
                          Icons.schedule_rounded,
                          AppColors.warningDark,
                        ),
                        _group([for (final c in pending) _serverTile(c)]),
                        const SizedBox(height: 14),
                      ],
                      if (rest.isNotEmpty) ...[
                        if (pending.isNotEmpty)
                          _sectionLabel(_isArabic ? 'الأحدث' : 'Recent', null,
                              AppColors.textMuted),
                        _group([for (final c in rest) _serverTile(c)]),
                      ],
                      if (loc.isNotEmpty) ...[
                        if (srv.isNotEmpty) const SizedBox(height: 14),
                        _group([for (final c in loc) _localTile(c)]),
                      ],
                    ],
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(_ServerChat c) => _matchesKey(c, _filter);

  static bool _matchesKey(_ServerChat c, String key) => switch (key) {
        'unread' => c.unread > 0,
        'complaints' => c.kind == 8,
        'requests' => const {1, 2, 3, 7}.contains(c.kind),
        'ads' => const {4, 5, 6}.contains(c.kind),
        'direct' => c.kind == 9,
        'supervisors' => false,
        _ => true,
      };

  Widget _emptyState(IconData icon, String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: MotionIcon(icon, size: 30, color: AppColors.ink),
              ),
              const SizedBox(height: 12),
              Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textSecondary, height: 1.6)),
            ],
          ),
        ),
      );

  Widget _sectionLabel(String text, IconData? icon, Color color) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 7),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
            ],
            Text(text,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      );

  /// مجموعة محادثات في كارت واحد بفواصل رفيعة.
  Widget _group(List<Widget> tiles) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0)
                Divider(
                    height: 1,
                    thickness: 1,
                    indent: 66,
                    color: AppColors.borderLight),
              tiles[i],
            ],
          ],
        ),
      );

  Widget _localTile(Conversation conversation) {
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
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceLight,
              child: MotionIcon(_accountIcon(other), color: AppColors.ink),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(
                    '${conversation.requestId.isEmpty ? '' : '${conversation.requestId} · '}$latest',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (unread > 0) _unreadPill(unread),
          ],
        ),
      ),
    );
  }

  Widget _unreadPill(int n) => Container(
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: _navy,
            borderRadius: const BorderRadius.all(Radius.circular(99))),
        child: CountText(n > 99 ? '99+' : '$n',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800)),
      );
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
