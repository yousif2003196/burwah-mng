import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

String formatChatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Voice message bubble body: play / pause, a waveform that fills while playing and the duration.
class VoiceMessageView extends StatefulWidget {
  const VoiceMessageView({
    super.key,
    required this.url,
    required this.seconds,
    required this.mine,
  });

  final String url;
  final int seconds;
  final bool mine;

  @override
  State<VoiceMessageView> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageView> {
  AudioPlayer? _player;
  bool _playing = false;
  Duration _pos = Duration.zero;
  Duration? _total;

  static const _bars = [
    6.0,
    12.0,
    18.0,
    10.0,
    22.0,
    14.0,
    8.0,
    20.0,
    12.0,
    6.0,
    16.0,
    22.0,
    10.0,
    14.0,
    18.0,
    8.0,
    12.0,
    17.0,
    9.0,
    13.0
  ];

  Future<void> _toggle() async {
    var p = _player;
    if (p == null) {
      p = AudioPlayer();
      _player = p;
      p.onPlayerStateChanged.listen((s) {
        if (mounted) setState(() => _playing = s == PlayerState.playing);
      });
      p.onPositionChanged.listen((d) {
        if (mounted) setState(() => _pos = d);
      });
      p.onDurationChanged.listen((d) {
        if (mounted) setState(() => _total = d);
      });
      p.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _pos = Duration.zero);
      });
      await p.play(UrlSource(widget.url));
      return;
    }
    if (_playing) {
      await p.pause();
    } else {
      await p.resume();
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.mine ? Colors.white : AppColors.primaryDark;
    final dim = widget.mine ? Colors.white38 : AppColors.borderMedium;
    final totalMs =
        (_total?.inMilliseconds ?? widget.seconds * 1000).clamp(1, 1 << 31);
    final progress = (_pos.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final shown = _playing || _pos > Duration.zero
        ? _pos.inSeconds
        : (widget.seconds > 0 ? widget.seconds : (_total?.inSeconds ?? 0));
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          InkWell(
            onTap: _toggle,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.mine
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.primaryDark.withValues(alpha: 0.1),
              ),
              child: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: fg),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 26,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < _bars.length; i++)
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 3,
                          height: _bars[i],
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: i / _bars.length <= progress ? fg : dim,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatChatDuration(shown),
            style:
                TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}

/// Full-screen viewer for a chat photo (network url).
class ChatImageViewer extends StatelessWidget {
  const ChatImageViewer({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 48),
          ),
        ),
      ),
    );
  }
}

/// Full-screen video player (network url or a local file).
class ChatVideoPlayerScreen extends StatefulWidget {
  const ChatVideoPlayerScreen({super.key, this.url, this.file});
  final String? url;
  final File? file;

  @override
  State<ChatVideoPlayerScreen> createState() => _ChatVideoPlayerScreenState();
}

class _ChatVideoPlayerScreenState extends State<ChatVideoPlayerScreen> {
  late final VideoPlayerController _c;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _c = widget.file != null
        ? VideoPlayerController.file(widget.file!)
        : VideoPlayerController.networkUrl(Uri.parse(widget.url ?? ''));
    _c.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _c.play();
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
    _c.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pos = _ready ? _c.value.position : Duration.zero;
    final dur = _ready ? _c.value.duration : Duration.zero;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: _failed
          ? const Center(
              child: Text('تعذر تشغيل الفيديو',
                  style: TextStyle(color: Colors.white)))
          : !_ready
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            _c.value.isPlaying ? _c.pause() : _c.play(),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: _c.value.aspectRatio == 0
                                ? 16 / 9
                                : _c.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_c),
                                if (!_c.value.isPlaying)
                                  const Icon(Icons.play_circle_fill_rounded,
                                      color: Colors.white70, size: 64),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      child: Row(
                        children: [
                          Text(formatChatDuration(pos.inSeconds),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          Expanded(
                            child: VideoProgressIndicator(
                              _c,
                              allowScrubbing: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              colors: const VideoProgressColors(
                                playedColor: Colors.white,
                                bufferedColor: Colors.white30,
                                backgroundColor: Colors.white12,
                              ),
                            ),
                          ),
                          Text(formatChatDuration(dur.inSeconds),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

/// Dark pre-send preview of one picked photo or video with a caption field.
/// Pops with the caption when the user sends, or with null when cancelled.
class ChatMediaPreviewScreen extends StatefulWidget {
  const ChatMediaPreviewScreen({
    super.key,
    required this.file,
    required this.isVideo,
    required this.toName,
    this.seconds = 0,
  });

  final File file;
  final bool isVideo;
  final String toName;
  final int seconds;

  @override
  State<ChatMediaPreviewScreen> createState() => _ChatMediaPreviewScreenState();
}

class _ChatMediaPreviewScreenState extends State<ChatMediaPreviewScreen> {
  final _caption = TextEditingController();
  VideoPlayerController? _c;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _c = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          if (mounted) setState(() {});
        }).catchError((_) {})
        ..addListener(() {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _caption.dispose();
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final ready = c != null && c.value.isInitialized;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    _RoundBtn(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.pop(context)),
                    Expanded(
                      child: Column(
                        children: [
                          Text('إلى ${widget.toName}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          Text(widget.isVideo ? 'فيديو' : 'صورة',
                              style: const TextStyle(
                                  color: Color(0xFF98A2B3), fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      color: const Color(0xFF16284D),
                      child: widget.isVideo
                          ? (ready
                              ? GestureDetector(
                                  onTap: () =>
                                      c.value.isPlaying ? c.pause() : c.play(),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: AspectRatio(
                                          aspectRatio: c.value.aspectRatio == 0
                                              ? 16 / 9
                                              : c.value.aspectRatio,
                                          child: VideoPlayer(c),
                                        ),
                                      ),
                                      if (!c.value.isPlaying)
                                        Container(
                                          width: 68,
                                          height: 68,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          child: const Icon(
                                              Icons.play_arrow_rounded,
                                              size: 40,
                                              color: Color(0xFF14284B)),
                                        ),
                                      Positioned(
                                        left: 14,
                                        right: 14,
                                        bottom: 10,
                                        child: VideoProgressIndicator(
                                          c,
                                          allowScrubbing: true,
                                          colors: const VideoProgressColors(
                                            playedColor: Colors.white,
                                            bufferedColor: Colors.white30,
                                            backgroundColor: Colors.white24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator()))
                          : InteractiveViewer(
                              child:
                                  Image.file(widget.file, fit: BoxFit.contain),
                            ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _caption,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          maxLines: 3,
                          minLines: 1,
                          decoration: const InputDecoration(
                            hintText: 'أضف تعليقًا...',
                            hintStyle: TextStyle(color: Color(0xFF98A2B3)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => Navigator.pop(context, _caption.text.trim()),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFF12B76A)),
                        child:
                            const Icon(Icons.send_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}
