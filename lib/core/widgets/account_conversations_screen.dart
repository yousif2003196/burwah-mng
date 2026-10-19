import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../../features/wasalny_supervisor/data/wasalny_local_event_store.dart';

class AccountConversationsScreen extends StatefulWidget {
  final String accountId;

  const AccountConversationsScreen({
    super.key,
    required this.accountId,
  });

  @override
  State<AccountConversationsScreen> createState() =>
      _AccountConversationsScreenState();
}

class _AccountConversationsScreenState
    extends State<AccountConversationsScreen> {
  late Future<List<_Conversation>> _conversations;
  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _conversations = _ConversationStore.instance.forAccount(widget.accountId);
  }

  void _reload() {
    setState(() {
      _conversations = _ConversationStore.instance.forAccount(widget.accountId);
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
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final account in _accounts.entries)
              if (account.key != widget.accountId)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceLight,
                    child: Icon(Icons.person_outline,
                        color: AppColors.primaryDark),
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
      await _ConversationStore.instance.openConversation(
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          title: Text(title),
          actions: [
            IconButton(
              tooltip: _isArabic ? 'محادثة جديدة' : 'New conversation',
              onPressed: _startConversation,
              icon: const Icon(Icons.add_comment_outlined),
            ),
          ],
        ),
        body: FutureBuilder<List<_Conversation>>(
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
            final items = snapshot.data ?? const <_Conversation>[];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.forum_outlined,
                          size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        _isArabic
                            ? 'لا توجد محادثات بعد. ابدأ محادثة مع حساب آخر.'
                            : 'No conversations yet. Start one with another account.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
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
                final name = _accountName(other, _isArabic);
                final latest = conversation.messages.isEmpty
                    ? (_isArabic ? 'ابدأ المحادثة' : 'Start the conversation')
                    : conversation.messages.last.body;
                final unread = conversation.messages
                    .where((message) =>
                        message.senderId != widget.accountId &&
                        !message.readBy.contains(widget.accountId))
                    .length;
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceLight,
                      child: Icon(_accountIcon(other),
                          color: AppColors.primaryDark),
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
                            child: Text('$unread',
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
  _Conversation? _conversation;
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
      final conversation = await _ConversationStore.instance.markRead(
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
      final updated = await _ConversationStore.instance.sendMessage(
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          title: Text(widget.title),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_conversation?.requestId.isNotEmpty == true)
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '${_isArabic ? 'مرتبطة بالطلب' : 'Linked request'}: ${_conversation!.requestId}',
                        style: const TextStyle(
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
                                        : Colors.white,
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
                                        '${_accountName(message.senderId, _isArabic)} · ${message.createdAt.toLocal().toString().substring(0, 16)}',
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
                      color: Colors.white,
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
                            icon: const Icon(Icons.send_rounded),
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

class _ConversationStore {
  _ConversationStore._();
  static final instance = _ConversationStore._();
  static const _storageKey = 'account_conversations_v1';

  Future<List<_Conversation>> forAccount(String accountId) async {
    final all = await _readAll();
    return all.where((item) => item.participants.contains(accountId)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<_Conversation> openConversation(
    String first,
    String second,
    String requestId,
  ) async {
    final all = await _readAll();
    final participants = [first, second]..sort();
    final normalizedRequest = requestId.trim();
    final existing = all.where((item) =>
        item.participants.length == 2 &&
        item.participants[0] == participants[0] &&
        item.participants[1] == participants[1] &&
        item.requestId == normalizedRequest);
    if (existing.isNotEmpty) return existing.first;
    final now = DateTime.now();
    final conversation = _Conversation(
      id: '${participants.join('-')}-${now.microsecondsSinceEpoch}',
      participants: participants,
      requestId: normalizedRequest,
      messages: const [],
      updatedAt: now,
    );
    all.add(conversation);
    await _writeAll(all);
    return conversation;
  }

  Future<_Conversation> markRead(String id, String accountId) async {
    final all = await _readAll();
    final index = all.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Conversation not found.');
    final conversation = all[index].copyWith(
      messages: [
        for (final message in all[index].messages)
          message.senderId == accountId || message.readBy.contains(accountId)
              ? message
              : message.copyWith(readBy: {...message.readBy, accountId}),
      ],
    );
    all[index] = conversation;
    await _writeAll(all);
    return conversation;
  }

  Future<_Conversation> sendMessage(
    String id,
    String senderId,
    String body,
  ) async {
    final all = await _readAll();
    final index = all.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Conversation not found.');
    final conversation = all[index];
    if (!conversation.participants.contains(senderId)) {
      throw StateError('Account is not a conversation participant.');
    }
    final now = DateTime.now();
    final message = _ConversationMessage(
      id: now.microsecondsSinceEpoch.toString(),
      senderId: senderId,
      body: body,
      createdAt: now,
      readBy: {senderId},
    );
    final updated = conversation.copyWith(
      messages: [...conversation.messages, message],
      updatedAt: now,
    );
    all[index] = updated;
    await _writeAll(all);
    final recipient = conversation.participants.firstWhere(
      (participant) => participant != senderId,
    );
    try {
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
        id: 'conversation-${message.id}',
        recipient: recipient,
        source: senderId,
        titleAr: 'رسالة جديدة من ${_accountName(senderId, true)}',
        titleEn: 'New message from ${_accountName(senderId, false)}',
        messageAr: body,
        messageEn: body,
        createdAt: now,
        ),
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'account conversation notification',
      ));
    }
    return updated;
  }

  Future<List<_Conversation>> _readAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List) throw const FormatException('Invalid conversations.');
    return decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid conversation record.');
      }
      return _Conversation.fromJson(value);
    }).toList();
  }

  Future<void> _writeAll(List<_Conversation> all) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(all.map((item) => item.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save conversations.');
  }
}

class _Conversation {
  final String id;
  final List<String> participants;
  final String requestId;
  final List<_ConversationMessage> messages;
  final DateTime updatedAt;

  const _Conversation({
    required this.id,
    required this.participants,
    required this.requestId,
    required this.messages,
    required this.updatedAt,
  });

  _Conversation copyWith({
    List<_ConversationMessage>? messages,
    DateTime? updatedAt,
  }) =>
      _Conversation(
        id: id,
        participants: participants,
        requestId: requestId,
        messages: messages ?? this.messages,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'participants': participants,
        'requestId': requestId,
        'messages': messages.map((message) => message.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory _Conversation.fromJson(Map<String, dynamic> json) => _Conversation(
        id: json['id'] as String,
        participants: (json['participants'] as List).cast<String>(),
        requestId: json['requestId'] as String? ?? '',
        messages: (json['messages'] as List? ?? const [])
            .map((value) => _ConversationMessage.fromJson(
                Map<String, dynamic>.from(value as Map)))
            .toList(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class _ConversationMessage {
  final String id;
  final String senderId;
  final String body;
  final DateTime createdAt;
  final Set<String> readBy;

  const _ConversationMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
    required this.readBy,
  });

  _ConversationMessage copyWith({Set<String>? readBy}) =>
      _ConversationMessage(
        id: id,
        senderId: senderId,
        body: body,
        createdAt: createdAt,
        readBy: readBy ?? this.readBy,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'senderId': senderId,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'readBy': readBy.toList(),
      };

  factory _ConversationMessage.fromJson(Map<String, dynamic> json) =>
      _ConversationMessage(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        readBy: (json['readBy'] as List? ?? const []).cast<String>().toSet(),
      );
}

const _accounts = <String, (String, String)>{
  'finance': ('المشرف المالي', 'Finance supervisor'),
  'merchant': ('مشرف التجار', 'Merchant supervisor'),
  'products': ('مشرف المنتجات', 'Product supervisor'),
  'wasalny': ('مشرف وصلني', 'Wasalny supervisor'),
  'services': ('مشرف الخدمات', 'Services supervisor'),
  'head': ('رئيس المشرفين', 'Head supervisor'),
};

String _accountName(String id, bool isArabic) {
  final names = _accounts[id];
  if (names == null) return id;
  return isArabic ? names.$1 : names.$2;
}

IconData _accountIcon(String id) => switch (id) {
      'finance' => Icons.account_balance_outlined,
      'merchant' => Icons.storefront_outlined,
      'products' => Icons.inventory_2_outlined,
      'wasalny' => Icons.local_shipping_outlined,
      'services' => Icons.support_agent_outlined,
      _ => Icons.supervisor_account_outlined,
    };
