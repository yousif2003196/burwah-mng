import 'dart:async';

import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_request_api_data_source.dart';

/// Suspicious service requests the services supervisor sent to the head
/// (server status "Escalated"). The head approves, rejects or returns them.
class HeadServiceEscalationsPanel extends StatefulWidget {
  const HeadServiceEscalationsPanel({super.key});

  @override
  State<HeadServiceEscalationsPanel> createState() =>
      _HeadServiceEscalationsPanelState();
}

class _HeadServiceEscalationsPanelState
    extends State<HeadServiceEscalationsPanel> {
  late final ServicesRequestApiDataSource _api = ServicesRequestApiDataSource(
    apiConsumer: sl<ApiConsumer>(instanceName: 'berwah'),
  );
  List<ServicesRemoteRequest> _items = const [];
  bool _loading = true;
  bool _failed = false;
  int? _busyId;
  Timer? _timer;
  StreamSubscription<dynamic>? _live;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => _load());
    _live = RealtimeHub.instance.notifications
        .where((n) => n.type == 'service_escalation')
        .listen((_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _live?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await _api.load('escalated');
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _failed = false;
      });
    } on Object catch (error) {
      debugPrint('Head escalations load failed: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = _items.isEmpty;
      });
    }
  }

  Future<String?> _ask(String title, {bool required = true}) async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'اكتب السبب / الملاحظة'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (required && text.isEmpty) return;
                Navigator.of(ctx).pop(text);
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _act(
    ServicesRemoteRequest r,
    Future<void> Function() call,
    String done,
  ) async {
    setState(() => _busyId = r.id);
    try {
      await call();
      if (!mounted) return;
      AppSnackBar.showSuccess(context, done);
      await _load();
    } on Object catch (error) {
      debugPrint('Head decision failed: $error');
      if (mounted) AppSnackBar.showError(context, 'تعذر تنفيذ القرار، حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _approve(ServicesRemoteRequest r) async {
    await _act(r, () => _api.approve(r.id), 'تم اعتماد الطلب #SRV-${r.id}');
  }

  Future<void> _reject(ServicesRemoteRequest r) async {
    final reason = await _ask('سبب رفض الطلب #SRV-${r.id}');
    if (reason == null || !mounted) return;
    await _act(r, () => _api.reject(r.id, reason), 'تم رفض الطلب #SRV-${r.id}');
  }

  Future<void> _return(ServicesRemoteRequest r) async {
    final note = await _ask('ملاحظة لمشرف الخدمات (اختياري)', required: false);
    if (note == null || !mounted) return;
    await _act(r, () => _api.returnRequest(r.id, note),
        'أُعيد الطلب #SRV-${r.id} للمراجعة');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_failed) {
      return TextButton.icon(
        onPressed: _load,
        icon: const Icon(Icons.refresh),
        label: const Text('تعذر تحميل الطلبات المشبوهة — إعادة المحاولة'),
      );
    }
    if (_items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طلبات خدمات مشبوهة بانتظار قرارك (${_items.length})',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final r in _items) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#SRV-${r.id} • ${r.subCategory}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('العميل: ${r.client}  ${r.phone}'),
                if (r.address.isNotEmpty) Text('العنوان: ${r.address}'),
                const SizedBox(height: 4),
                Text(r.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(
                  'سبب الإحالة: ${r.rejectionReason.isEmpty ? '—' : r.rejectionReason}',
                  style: TextStyle(color: AppColors.dangerDark, fontSize: 12),
                ),
                const SizedBox(height: 10),
                if (_busyId == r.id)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => _approve(r),
                        child: const Text('اعتماد'),
                      ),
                      OutlinedButton(
                        onPressed: () => _reject(r),
                        child: const Text('رفض'),
                      ),
                      OutlinedButton(
                        onPressed: () => _return(r),
                        child: const Text('إرجاع للمراجعة'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
