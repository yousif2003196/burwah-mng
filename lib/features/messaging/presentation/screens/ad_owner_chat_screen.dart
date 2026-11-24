import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/presentation/widgets/chat_media.dart';

class _Msg {
  _Msg({
    required this.id,
    required this.text,
    required this.mine,
    required this.at,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.seconds = 0,
  });
  final int id;
  final String text;
  final bool mine;
  final DateTime at;
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final int seconds;
}

const _kMaxImageBytes = 8 * 1024 * 1024;
const _kMaxVideoBytes = 50 * 1024 * 1024;
const _kMaxVideoSeconds = 120;
const _kMaxVoiceSeconds = 300;

/// محادثة مشرف المنتجات مع صاحب الإعلان. بتتقفل تلقائيًا أول ما المشرف
/// ياخد قرار على الإعلان (قبول / رفض / إخفاء). بتدعم نص وصور وفيديو ورسائل صوتية.
class AdOwnerChatScreen extends StatefulWidget {
  const AdOwnerChatScreen({
    super.key,
    required this.adId,
    this.adTitle = '',
    this.requestId,
    this.complaintId,
    this.openPath,
    this.withRole = 'buyer',
    this.conversationId,
    this.title,
    this.subtitle,
  });

  final int adId;
  final String adTitle;

  /// When set, the chat is the used-goods supervisor's chat about this Wasalny
  /// request with its buyer or seller ([withRole]) instead of the ad owner's.
  final int? requestId;

  /// When set, the used-goods supervisor's chat about this complaint (ticket) with its buyer or seller ([withRole]).
  final int? complaintId;

  /// Any server endpoint that opens a supervisor chat (POST, body {'with': [withRole]}) and returns {id, closed}.
  final String? openPath;
  final String withRole;

  /// A conversation that already exists (from the chats list): it is opened as it is, nothing is created.
  final int? conversationId;

  /// The other side's name, when the chat is opened from the chats list.
  final String? title;

  /// What the chat is about (shown under the name), e.g. «طلب وصلني».
  final String? subtitle;

  @override
  State<AdOwnerChatScreen> createState() => _AdOwnerChatScreenState();
}

class _AdOwnerChatScreenState extends State<AdOwnerChatScreen> {
  final _api = sl<ApiConsumer>(instanceName: 'berwah');
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  final List<_Msg> _msgs = [];
  int? _conversationId;
  bool _loading = true;
  bool _closed = false;
  bool _sending = false;
  bool _hasText = false;
  String? _error;
  Timer? _poll;
  StreamSubscription<RealtimeChatMessage>? _sub;

  // Recording state.
  bool _recording = false;
  int _recSeconds = 0;
  Timer? _recTimer;
  StreamSubscription<Amplitude>? _ampSub;
  final List<double> _live = List<double>.filled(22, 6);

  Color get _navy => AppColors.primaryDark;

  String get _name =>
      widget.title ??
      (widget.adTitle.isEmpty ? 'صاحب الإعلان' : widget.adTitle);

  @override
  void initState() {
    super.initState();
    _input.addListener(() {
      final has = _input.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _open();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _sub?.cancel();
    _recTimer?.cancel();
    _ampSub?.cancel();
    _recorder.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    try {
      final requestId = widget.requestId;
      if (widget.conversationId != null) {
        _conversationId = widget.conversationId;
      } else {
        final complaintId = widget.complaintId;
        final openPath = widget.openPath;
        final r = openPath != null
            ? await _api.post<Object>(openPath, data: {'with': widget.withRole})
            : complaintId != null
            ? await _api.post<Object>(
                'api/SupervisorUsed/complaints/$complaintId/chat',
                data: {'with': widget.withRole},
              )
            : requestId != null
            ? await _api.post<Object>(
                'api/WasalnyRequest/supervisor/$requestId/chat',
                data: {'with': widget.withRole},
              )
            : await _api.post<Object>('api/Chat/open', data: {
                'kind': 4,
                'refId': widget.adId,
                'otherUserId': 0,
              });
        final body = r.data;
        final data = body is Map ? body['data'] : null;
        if (data is! Map) throw const FormatException('bad open');
        _conversationId = (data['id'] as num).toInt();
        _closed = data['closed'] == true;
      }
      await _fetch();
      _sub = RealtimeHub.instance.chats
          .where((m) => m.conversationId == _conversationId)
          .listen((_) => _fetch());
      _poll = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      // رسالة السيرفر لو موجودة (مثلًا: صاحب الشكوى مش مسجل في التطبيق).
      final body = e is DioException ? e.response?.data : null;
      final message = body is Map ? '${body['message'] ?? ''}'.trim() : '';
      if (mounted) {
        setState(() {
          _loading = false;
          _error = message.isEmpty ? 'تعذر فتح المحادثة' : message;
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
                id: (m['id'] as num).toInt(),
                text: '${m['text'] ?? ''}',
                mine: m['mine'] == true,
                at: DateTime.tryParse('${m['createdAt']}')?.toLocal() ??
                    DateTime.now(),
                imageUrl: _str(m['imageUrl']),
                videoUrl: _str(m['videoUrl']),
                audioUrl: _str(m['audioUrl']),
                seconds: ((m['videoSeconds'] ?? m['audioSeconds'] ?? 0) as num)
                    .toInt(),
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

  String? _str(Object? v) {
    final s = v?.toString() ?? '';
    return s.isEmpty ? null : s;
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  String _errMsg(Object e, String fallback) {
    if (e is DioException) {
      final d = e.response?.data;
      if (d is Map && d['message'] is String) return d['message'] as String;
    }
    return fallback;
  }

  // ───────────────────────── sending ─────────────────────────

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
      _toast('تعذر إرسال الرسالة');
      await _fetch();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _upload(String path, FormData form, String fallback) async {
    final id = _conversationId;
    if (id == null) return;
    setState(() => _sending = true);
    try {
      await _api.dio.post<Object>(
        'api/Chat/$id/$path',
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ),
      );
      await _fetch();
    } catch (e) {
      _toast(_errMsg(e, fallback));
      await _fetch();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openAttach() async {
    if (_closed || _sending) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text('إرفاق في المحادثة',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _AttachTile(
                    icon: Icons.photo_camera_outlined,
                    label: 'الكاميرا',
                    bg: AppColors.infoLight,
                    fg: AppColors.infoDark,
                    onTap: () => Navigator.pop(ctx, 'camera'),
                  ),
                  const SizedBox(width: 12),
                  _AttachTile(
                    icon: Icons.image_outlined,
                    label: 'صورة',
                    bg: AppColors.successLight,
                    fg: AppColors.successDark,
                    onTap: () => Navigator.pop(ctx, 'image'),
                  ),
                  const SizedBox(width: 12),
                  _AttachTile(
                    icon: Icons.videocam_outlined,
                    label: 'فيديو',
                    bg: AppColors.purple.withValues(alpha: 0.16),
                    fg: AppColors.purple,
                    onTap: () => Navigator.pop(ctx, 'video'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'الحد الأقصى: صورة ٨ ميجا، وفيديو ٥٠ ميجا بمدة لا تتجاوز دقيقتين.',
                  style: TextStyle(
                      fontSize: 11,
                      height: 1.6,
                      color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    switch (choice) {
      case 'camera':
        await _pickImage(ImageSource.camera);
      case 'image':
        await _pickImage(ImageSource.gallery);
      case 'video':
        await _pickVideo();
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final x = await _picker.pickImage(
          source: src, imageQuality: 82, maxWidth: 1920, maxHeight: 1920);
      if (x == null) return;
      final file = File(x.path);
      if (await file.length() > _kMaxImageBytes) {
        _toast('الصورة كبيرة جدًا (الحد ٨ ميجا)');
        return;
      }
      if (!mounted) return;
      final caption =
          await Navigator.of(context).push<String>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            ChatMediaPreviewScreen(file: file, isVideo: false, toName: _name),
      ));
      if (caption == null) return;
      final form = FormData.fromMap({
        'Image': await MultipartFile.fromFile(
          file.path,
          filename: x.name.isEmpty ? 'photo.jpg' : x.name,
          contentType: DioMediaType('image', _imageSubtype(x.name)),
        ),
        if (caption.isNotEmpty) 'Text': caption,
      });
      await _upload('image', form, 'تعذر إرسال الصورة');
    } catch (_) {
      _toast('تعذر فتح الصورة');
    }
  }

  String _imageSubtype(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'png';
    if (n.endsWith('.webp')) return 'webp';
    return 'jpeg';
  }

  Future<void> _pickVideo() async {
    try {
      final x = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: _kMaxVideoSeconds),
      );
      if (x == null) return;
      final file = File(x.path);
      if (await file.length() > _kMaxVideoBytes) {
        _toast('الفيديو كبير جدًا (الحد ٥٠ ميجا)');
        return;
      }
      var seconds = 0;
      final probe = VideoPlayerController.file(file);
      try {
        await probe.initialize();
        seconds = probe.value.duration.inSeconds;
      } catch (_) {
      } finally {
        await probe.dispose();
      }
      if (seconds > _kMaxVideoSeconds) {
        _toast('الفيديو لا يتجاوز دقيقتين');
        return;
      }
      if (!mounted) return;
      final caption =
          await Navigator.of(context).push<String>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ChatMediaPreviewScreen(
            file: file, isVideo: true, toName: _name, seconds: seconds),
      ));
      if (caption == null) return;
      final name = x.name.isEmpty ? 'video.mp4' : x.name;
      final form = FormData.fromMap({
        'Video': await MultipartFile.fromFile(
          file.path,
          filename: name,
          contentType: DioMediaType('video',
              name.toLowerCase().endsWith('.mov') ? 'quicktime' : 'mp4'),
        ),
        'Seconds': seconds,
        if (caption.isNotEmpty) 'Text': caption,
      });
      await _upload('video', form, 'تعذر إرسال الفيديو');
    } catch (_) {
      _toast('تعذر فتح الفيديو');
    }
  }

  // ───────────────────────── voice ─────────────────────────

  Future<void> _startRecording() async {
    if (_closed || _sending || _recording) return;
    try {
      if (!await _recorder.hasPermission()) {
        _toast('اسمح للتطبيق باستخدام الميكروفون من الإعدادات');
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
        path: path,
      );
      for (var i = 0; i < _live.length; i++) {
        _live[i] = 6;
      }
      setState(() {
        _recording = true;
        _recSeconds = 0;
      });
      _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recSeconds++);
        if (_recSeconds >= _kMaxVoiceSeconds) _finishRecording(send: true);
      });
      _ampSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 120))
          .listen((a) {
        // current is in dB (-45 … 0): map to a 6…26 px bar.
        final level = ((a.current + 45) / 45).clamp(0.0, 1.0);
        if (!mounted) return;
        setState(() {
          _live.removeAt(0);
          _live.add(6 + level * 20);
        });
      });
    } catch (_) {
      _toast('تعذر بدء التسجيل');
    }
  }

  Future<void> _finishRecording({required bool send}) async {
    if (!_recording) return;
    final secs = _recSeconds;
    _recTimer?.cancel();
    await _ampSub?.cancel();
    _ampSub = null;
    String? path;
    try {
      if (send && secs >= 1) {
        path = await _recorder.stop();
      } else {
        await _recorder.cancel();
      }
    } catch (_) {}
    if (mounted) setState(() => _recording = false);
    if (!send) return;
    if (secs < 1 || path == null) {
      _toast('التسجيل قصير جدًا');
      return;
    }
    final form = FormData.fromMap({
      'Audio': await MultipartFile.fromFile(
        path,
        filename: 'voice.m4a',
        contentType: DioMediaType('audio', 'mp4'),
      ),
      'Seconds': secs,
    });
    await _upload('voice', form, 'تعذر إرسال الرسالة الصوتية');
    try {
      await File(path).delete();
    } catch (_) {}
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final initial = _name.trim().isEmpty ? '؟' : _name.trim().characters.first;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surfaceMuted,
        appBar: AppBar(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.infoLight,
                child: Text(initial,
                    style: TextStyle(
                        color: AppColors.infoDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    if ((widget.subtitle ?? '').isNotEmpty)
                      Text(widget.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    children: [
                      if (widget.adTitle.isNotEmpty) _contextCard(),
                      Expanded(
                        child: _msgs.isEmpty
                            ? Center(
                                child: Text(widget.conversationId != null
                                    ? 'ابدأ المحادثة'
                                    : 'ابدأ المحادثة مع صاحب الإعلان'))
                            : ListView.builder(
                                controller: _scroll,
                                padding: const EdgeInsets.all(14),
                                itemCount: _msgs.length,
                                itemBuilder: (_, i) => _bubble(_msgs[i]),
                              ),
                      ),
                      if (_sending) const LinearProgressIndicator(minHeight: 2),
                      if (_closed)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          color: AppColors.surface,
                          child: const SafeArea(
                            top: false,
                            child: Text(
                              'تم اتخاذ قرار على الإعلان، المحادثة مقفولة',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        _recording ? _recordingBar() : _composer(),
                    ],
                  ),
      ),
    );
  }

  Widget _contextCard() => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.sell_outlined, size: 20, color: _navy),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.adTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
          ],
        ),
      );

  Widget _bubble(_Msg m) {
    final fg = m.mine ? Colors.white : AppColors.textPrimary;
    final hasMedia = m.imageUrl != null || m.videoUrl != null;
    final Widget content;
    if (m.audioUrl != null) {
      content =
          VoiceMessageView(url: m.audioUrl!, seconds: m.seconds, mine: m.mine);
    } else if (m.imageUrl != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatImageViewer(url: m.imageUrl!))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                m.imageUrl!,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, p) => p == null
                    ? child
                    : const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(child: CircularProgressIndicator())),
                errorBuilder: (_, __, ___) => const SizedBox(
                    width: 220,
                    height: 120,
                    child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ),
          if (m.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(m.text, style: TextStyle(color: fg, height: 1.5)),
          ],
        ],
      );
    } else if (m.videoUrl != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatVideoPlayerScreen(url: m.videoUrl!))),
            child: Container(
              width: 220,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.primaryDark.withValues(alpha: 0.78), AppColors.primaryDark],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.92)),
                    child: Icon(Icons.play_arrow_rounded,
                        size: 34, color: _navy),
                  ),
                  if (m.seconds > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(formatChatDuration(m.seconds),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (m.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(m.text, style: TextStyle(color: fg, height: 1.5)),
          ],
        ],
      );
    } else {
      content = Text(m.text, style: TextStyle(color: fg, height: 1.55));
    }

    final t =
        '${m.at.hour.toString().padLeft(2, '0')}:${m.at.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.fromLTRB(
            hasMedia ? 6 : 12, hasMedia ? 6 : 9, hasMedia ? 6 : 12, 6),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: m.mine ? _navy : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomRight: Radius.circular(m.mine ? 4 : 16),
            bottomLeft: Radius.circular(m.mine ? 16 : 4),
          ),
          border: m.mine ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(alignment: AlignmentDirectional.centerStart, child: content),
            const SizedBox(height: 3),
            Text(t,
                style: TextStyle(
                    fontSize: 10,
                    color: m.mine ? Colors.white60 : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _composer() => Container(
        color: AppColors.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'إرفاق',
                  onPressed: _sending ? null : _openAttach,
                  icon: Icon(Icons.attach_file_rounded,
                      color: AppColors.textSecondary),
                ),
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _hasText
                    ? IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: _navy),
                        onPressed: _sending ? null : _send,
                        icon: const Icon(Icons.send_rounded),
                      )
                    : IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: _navy),
                        tooltip: 'تسجيل رسالة صوتية',
                        onPressed: _sending ? null : _startRecording,
                        icon: const Icon(Icons.mic_rounded),
                      ),
              ],
            ),
          ),
        ),
      );

  Widget _recordingBar() => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _finishRecording(send: false),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.danger,
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.danger
                                      .withValues(alpha: 0.2),
                                  spreadRadius: 5)
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(formatChatDuration(_recSeconds),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dangerDark)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (var i = 0; i < _live.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Container(
                                    width: 3,
                                    height: _live[i],
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: AppColors.danger.withValues(
                                          alpha: 0.35 +
                                              0.65 * (i + 1) / _live.length),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _finishRecording(send: true),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: _navy),
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _AttachTile extends StatelessWidget {
  const _AttachTile({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 16, 6, 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: bg, borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, size: 26, color: fg),
                ),
                const SizedBox(height: 8),
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      );
}
