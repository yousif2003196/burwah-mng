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

  /// آخر رسالة من رسايلي اتقرت عند الطرف التاني (الصحّين).
  int _readUpTo = 0;
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
                at: _utc(m['createdAt'])?.toLocal() ?? DateTime.now(),
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
        _readUpTo = (body['readUpTo'] as num?)?.toInt() ?? _readUpTo;
      });
      if (fresh.isNotEmpty) _toEnd();
    } catch (_) {}
  }

  /// السيرفر بيبعت الوقت UTC من غير Z.
  static DateTime? _utc(Object? raw) {
    final t = '${raw ?? ''}'.trim();
    if (t.isEmpty || t == 'null') return null;
    final zoned = t.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(t);
    return DateTime.tryParse(zoned ? t : '${t}Z');
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
                    bg: AppColors.warningLight,
                    fg: AppColors.warningDark,
                    onTap: () => Navigator.pop(ctx, 'video'),
                  ),
                  const SizedBox(width: 12),
                  _AttachTile(
                    icon: Icons.quickreply_outlined,
                    label: 'رد جاهز',
                    bg: AppColors.surfaceLight,
                    fg: AppColors.ink,
                    onTap: () => Navigator.pop(ctx, 'reply'),
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
      case 'reply':
        await _openQuickReplies();
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
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          shape: Border(bottom: BorderSide(color: AppColors.cardBorder)),
          title: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.surfaceHighlight,
                child: Text(initial,
                    style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        if (_closed)
                          Icon(Icons.lock_outline_rounded,
                              size: 12, color: AppColors.textMuted)
                        else
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success),
                          ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            [
                              _closed ? 'مقفولة' : 'مفتوحة',
                              if ((widget.subtitle ?? '').isNotEmpty)
                                widget.subtitle!,
                            ].join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _closed
                                    ? AppColors.textMuted
                                    : AppColors.successDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forum_outlined,
                              size: 42, color: AppColors.textMuted),
                          const SizedBox(height: 10),
                          Text(_error!,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      if (widget.adTitle.isNotEmpty) _contextCard(),
                      Expanded(
                        child: _msgs.isEmpty
                            ? _emptyThread()
                            : ListView(
                                controller: _scroll,
                                padding:
                                    const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                children: _threadItems(),
                              ),
                      ),
                      if (_sending) const LinearProgressIndicator(minHeight: 2),
                      if (_closed)
                        _closedBar()
                      else if (_recording)
                        _recordingBar()
                      else ...[
                        _quickRepliesRow(),
                        _composer(),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _emptyThread() => Center(
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
                child: Icon(Icons.chat_bubble_outline_rounded,
                    size: 30, color: AppColors.ink),
              ),
              const SizedBox(height: 12),
              Text(
                widget.conversationId != null
                    ? 'ابدأ المحادثة'
                    : 'ابدأ المحادثة مع ${_name.trim().isEmpty ? 'الطرف التاني' : _name}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text('اكتب رسالة أو اختار رد جاهز من تحت',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      );

  // ───────────────────────── thread layout ─────────────────────────

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dayLabel(DateTime d) {
    final now = DateTime.now();
    if (_sameDay(d, now)) return 'النهارده';
    if (_sameDay(d, now.subtract(const Duration(days: 1)))) return 'امبارح';
    const days = ['الاتنين', 'التلات', 'الأربع', 'الخميس', 'الجمعة', 'السبت', 'الحد'];
    if (now.difference(d).inDays < 7) return days[d.weekday - 1];
    return '${d.day}/${d.month}/${d.year}';
  }

  /// فواصل الأيام + الرسايل؛ رسايل نفس الشخص ورا بعض (خلال 3 دقايق) بتتجمع.
  List<Widget> _threadItems() {
    final items = <Widget>[];
    for (var i = 0; i < _msgs.length; i++) {
      final m = _msgs[i];
      final prev = i > 0 ? _msgs[i - 1] : null;
      final next = i + 1 < _msgs.length ? _msgs[i + 1] : null;
      if (prev == null || !_sameDay(prev.at, m.at)) {
        items.add(_daySeparator(_dayLabel(m.at)));
      }
      final groupedWithNext = next != null &&
          next.mine == m.mine &&
          _sameDay(next.at, m.at) &&
          next.at.difference(m.at).inMinutes < 3;
      items.add(_bubble(m, tail: !groupedWithNext));
    }
    return items;
  }

  Widget _daySeparator(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
          ),
        ),
      );

  Widget _closedBar() => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.lock_outline_rounded,
                      size: 18, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'المحادثة اتقفلت بعد القرار. السجل متاح للقراءة بس.',
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ───────────────────────── quick replies ─────────────────────────

  static const _quickReplies = <String>[
    'أهلًا بيك، معاك المشرف من برواح',
    'بنراجع الموضوع حالًا وهرجعلك',
    'ممكن تبعت صورة أوضح؟',
    'محتاجين بيانات أكتر عشان نكمّل',
    'تم حل المشكلة، شكرًا لصبرك',
    'شكرًا لتواصلك معانا',
  ];

  /// الرد الجاهز بيتكتب في الخانة عشان المشرف يعدّله لو حب قبل الإرسال.
  void _useReply(String text) {
    _input.text = text;
    _input.selection = TextSelection.collapsed(offset: text.length);
  }

  Widget _quickRepliesRow() => SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          itemCount: _quickReplies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) => ActionChip(
            label: Text(_quickReplies[i]),
            onPressed: _sending ? null : () => _useReply(_quickReplies[i]),
            labelStyle: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.ink),
            backgroundColor: AppColors.surface,
            side: BorderSide(color: AppColors.borderMedium),
            shape: const StadiumBorder(),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      );

  Future<void> _openQuickReplies() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Text('ردود جاهزة',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
              ),
              for (final r in _quickReplies)
                ListTile(
                  leading: Icon(Icons.quickreply_outlined,
                      color: AppColors.textSecondary),
                  title: Text(r,
                      style: TextStyle(
                          fontSize: 13.5, color: AppColors.textPrimary)),
                  onTap: () => Navigator.pop(ctx, r),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) _useReply(picked);
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
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.sell_outlined, size: 20, color: AppColors.ink),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.adTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  if ((widget.subtitle ?? '').isNotEmpty)
                    Text(widget.subtitle!,
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _bubble(_Msg m, {bool tail = true}) {
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
    final read = m.mine && m.id <= _readUpTo;
    const r = Radius.circular(18);
    const small = Radius.circular(5);
    // RTL: رسايلي على اليمين، والطرف التاني على الشمال.
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: tail ? 8 : 3),
        padding: EdgeInsets.fromLTRB(
            hasMedia ? 5 : 12, hasMedia ? 5 : 8, hasMedia ? 5 : 12, 5),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: m.mine ? _navy : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: r,
            topRight: r,
            bottomRight: m.mine && tail ? small : r,
            bottomLeft: !m.mine && tail ? small : r,
          ),
          border: m.mine ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(alignment: AlignmentDirectional.centerStart, child: content),
            const SizedBox(height: 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hasMedia ? 4 : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t,
                      style: TextStyle(
                          fontSize: 10,
                          color: m.mine ? Colors.white70 : AppColors.textMuted)),
                  if (m.mine) ...[
                    const SizedBox(width: 3),
                    // صح واحد = اتبعتت، صحّين فاتحين = اتقرت.
                    Icon(read ? Icons.done_all_rounded : Icons.done_rounded,
                        size: 14,
                        color: read ? const Color(0xFF7DD3FC) : Colors.white70),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composer() => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: _sending ? null : _openAttach,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceLight,
                    ),
                    child: Icon(Icons.add_rounded,
                        color: AppColors.textSecondary, semanticLabel: 'إرفاق'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: AppColors.borderMedium),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sending ? null : (_hasText ? _send : _startRecording),
                  customBorder: const CircleBorder(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _navy),
                    child: Icon(
                      _hasText ? Icons.send_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 21,
                      semanticLabel: _hasText ? 'إرسال' : 'تسجيل رسالة صوتية',
                    ),
                  ),
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
