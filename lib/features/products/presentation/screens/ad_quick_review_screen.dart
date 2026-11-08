import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/presentation/screens/ad_owner_chat_screen.dart';

/// بتفتح من إشعار "إعلان جديد": تفاصيل الإعلان + شات صاحب الإعلان + القرار.
class AdQuickReviewScreen extends StatefulWidget {
  const AdQuickReviewScreen({super.key, required this.adId});

  final int adId;

  @override
  State<AdQuickReviewScreen> createState() => _AdQuickReviewScreenState();
}

class _AdQuickReviewScreenState extends State<AdQuickReviewScreen> {
  final _api = sl<ApiConsumer>(instanceName: 'berwah');
  Map<String, dynamic>? _ad;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  static const _base = 'api/SupervisorForAd';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await _api.get<Object>('$_base/ad/${widget.adId}');
      final body = r.data;
      final data = body is Map ? (body['data'] ?? body) : null;
      if (data is! Map) throw const FormatException('bad ad');
      if (!mounted) return;
      setState(() {
        _ad = Map<String, dynamic>.from(data);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل الإعلان';
      });
    }
  }

  String _s(String key) => '${_ad?[key] ?? ''}';

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تعذر تنفيذ القرار')));
    }
  }

  Future<void> _reject() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('سبب الرفض'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'اكتب السبب'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('رفض'),
            ),
          ],
        ),
      ),
    );
    if (reason == null || reason.isEmpty) return;
    await _run(
      () => _api.post<Object>('$_base/reject/${widget.adId}', data: {
        'rejectReason': reason,
        'supervisorNotes': '',
        'allowResubmission': true,
      }),
      'تم رفض الإعلان',
    );
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
          title: const Text('مراجعة الإعلان'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(_s('title'),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text('السعر: ${_s('price')}'),
                      const SizedBox(height: 8),
                      Text(_s('description')),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AdOwnerChatScreen(
                                adId: widget.adId, adTitle: _s('title')),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('محادثة صاحب الإعلان'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: _busy
                                  ? null
                                  : () => _run(
                                        () => _api.post<Object>(
                                            '$_base/update-ad-status/${widget.adId}',
                                            data: {'status': 1}),
                                        'تم قبول الإعلان ونشره',
                                      ),
                              child: const Text('قبول'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _busy
                                  ? null
                                  : () => _run(
                                        () => _api.post<Object>(
                                            '$_base/hide/${widget.adId}',
                                            data: {
                                              'notificationMessage': '',
                                              'sendSmsNotification': false,
                                            }),
                                        'تم إخفاء الإعلان',
                                      ),
                              child: const Text('إخفاء'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _busy ? null : _reject,
                              child: const Text('رفض'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
