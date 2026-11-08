import 'dart:async';

import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';

class _Msg {
  _Msg(this.id, this.text, this.mine, this.at);
  final int id;
  final String text;
  final bool mine;
  final DateTime at;
}

/// محادثة مشرف المنتجات مع صاحب الإعلان. بتتقفل تلقائيًا أول ما المشرف
/// ياخد قرار على الإعلان (قبول / رفض / إخفاء).
class AdOwnerChatScreen extends StatefulWidget {
  const AdOwnerChatScreen({super.key, required this.adId, this.adTitle = ''});

  final int adId;
  final String adTitle;

  @override
  State<AdOwnerChatScreen> createState() => _AdOwnerChatScreenState();
}

class _AdOwnerChatScreenState extends State<AdOwnerChatScreen> {
  final _api = sl<ApiConsumer>(instanceName: 'berwah');
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  int? _conversationId;
  bool _loading = true;
  bool _closed = false;
  bool _sending = false;
  String? _error;
  Timer? _poll;
  StreamSubscription<RealtimeChatMessage>? _sub;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _sub?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    try {
      final r = await _api.post<Object>('api/Chat/open', data: {
        'kind': 4,
        'refId': widget.adId,
        'otherUserId': 0,
      });
      final body = r.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map) throw const FormatException('bad open');
      _conversationId = (data['id'] as num).toInt();
      _closed = data['closed'] == true;
      await _fetch();
      _sub = RealtimeHub.instance.chats
          .where((m) => m.conversationId == _conversationId)
          .listen((_) => _fetch());
      _poll = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'تعذر فتح المحادثة';
        });
      }
    }
  }

  Future<void> _fetch() async {
    final id = _conversationId;
    if (id == null) return;
    try {
      final after = _msgs.isEmpty ? 0 : _msgs.last.id;
      final r = await _api.get<Object>('api/Chat/$id/messages',
          queryParameters: {'afterId': after});
      final body = r.data;
      if (body is! Map) return;
      final list = body['data'];
      final fresh = <_Msg>[
        if (list is List)
          for (final m in list)
            if (m is Map)
              _Msg(
                (m['id'] as num).toInt(),
                '${m['text'] ?? (m['imageUrl'] != null ? '📷 صورة' : '')}',
                m['mine'] == true,
                DateTime.tryParse('${m['createdAt']}')?.toLocal() ??
                    DateTime.now(),
              ),
      ];
      if (!mounted) return;
      setState(() {
        _msgs.addAll(fresh.where((m) => !_msgs.any((x) => x.id == m.id)));
        _closed = body['closed'] == true;
      });
      if (fresh.isNotEmpty) _toEnd();
    } catch (_) {}
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    final id = _conversationId;
    if (text.isEmpty || id == null || _sending || _closed) return;
    setState(() => _sending = true);
    try {
      await _api.post<Object>('api/Chat/$id/messages', data: {'text': text});
      _input.clear();
      await _fetch();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إرسال الرسالة')),
        );
        await _fetch();
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(widget.adTitle.isEmpty
              ? 'محادثة صاحب الإعلان'
              : 'صاحب إعلان: ${widget.adTitle}'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    children: [
                      Expanded(
                        child: _msgs.isEmpty
                            ? const Center(child: Text('ابدأ المحادثة مع صاحب الإعلان'))
                            : ListView.builder(
                                controller: _scroll,
                                padding: const EdgeInsets.all(14),
                                itemCount: _msgs.length,
                                itemBuilder: (_, i) {
                                  final m = _msgs[i];
                                  return Align(
                                    alignment: m.mine
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 9),
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(context).size.width *
                                                  0.75),
                                      decoration: BoxDecoration(
                                        color: m.mine
                                            ? AppColors.ink
                                            : AppColors.surface,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: AppColors.cardBorder),
                                      ),
                                      child: Text(
                                        m.text,
                                        style: TextStyle(
                                          color: m.mine
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (_closed)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          color: AppColors.surface,
                          child: const Text(
                            'تم اتخاذ قرار على الإعلان، المحادثة مقفولة',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        SafeArea(
                          child: Container(
                            color: AppColors.surface,
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _input,
                                    minLines: 1,
                                    maxLines: 4,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _send(),
                                    decoration: const InputDecoration(
                                      hintText: 'اكتب رسالة لصاحب الإعلان',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: _sending ? null : _send,
                                  icon: const Icon(Icons.send),
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
