import 'dart:async';

import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';

/// Service providers the services supervisor sent to the head
/// (`GET provider-escalations`). The head suspends the provider or closes
/// the escalation without changing the provider.
class HeadProviderEscalationsPanel extends StatefulWidget {
  const HeadProviderEscalationsPanel({super.key});

  @override
  State<HeadProviderEscalationsPanel> createState() =>
      _HeadProviderEscalationsPanelState();
}

class _ProviderEscalation {
  const _ProviderEscalation({
    required this.providerId,
    required this.name,
    required this.businessType,
    required this.reason,
    required this.supervisorName,
    required this.at,
  });

  final int providerId;
  final String name;
  final String businessType;
  final String reason;
  final String supervisorName;
  final DateTime at;

  factory _ProviderEscalation.fromJson(Map<String, dynamic> j) =>
      _ProviderEscalation(
        providerId: (j['providerId'] as num).toInt(),
        name: '${j['name'] ?? ''}',
        businessType: '${j['businessType'] ?? ''}',
        reason: '${j['reason'] ?? ''}',
        supervisorName: '${j['supervisorName'] ?? ''}',
        at: DateTime.tryParse('${j['at'] ?? ''}')?.toLocal() ?? DateTime.now(),
      );
}

class _HeadProviderEscalationsPanelState
    extends State<HeadProviderEscalationsPanel> {
  ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');
  List<_ProviderEscalation> _items = const [];
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
        .where((n) => n.type == 'provider_escalation')
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
      final response =
          await _api.get<Object>(ApiEndpoints.serviceProviderEscalations);
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! List) throw const FormatException('bad escalations');
      final items = [
        for (final item in data)
          if (item is Map<String, dynamic>) _ProviderEscalation.fromJson(item),
      ];
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _failed = false;
      });
    } on Object catch (error) {
      debugPrint('Head provider escalations load failed: $error');
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
                if (required && text.length < 5) return;
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
    _ProviderEscalation e,
    Future<void> Function() call,
    String done,
  ) async {
    setState(() => _busyId = e.providerId);
    try {
      await call();
      if (!mounted) return;
      AppSnackBar.showSuccess(context, done);
      await _load();
    } on Object catch (error) {
      debugPrint('Head provider decision failed: $error');
      if (mounted) {
        AppSnackBar.showError(context, 'تعذر تنفيذ القرار، حاول مرة أخرى.');
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _suspend(_ProviderEscalation e) async {
    final reason = await _ask('سبب إيقاف المزود ${e.name}');
    if (reason == null || !mounted) return;
    await _act(
      e,
      () => _api.post<Object>(
        ApiEndpoints.serviceProviderState(e.providerId),
        data: {'suspended': true, 'reason': reason},
      ),
      'تم إيقاف المزود ${e.name}',
    );
  }

  Future<void> _close(_ProviderEscalation e) async {
    final note = await _ask('ملاحظة (اختياري)', required: false);
    if (note == null || !mounted) return;
    await _act(
      e,
      () => _api.post<Object>(
        ApiEndpoints.serviceCloseProviderEscalation(e.providerId),
        data: {'reason': note},
      ),
      'تم إغلاق التصعيد',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_failed) {
      return TextButton.icon(
        onPressed: _load,
        icon: const Icon(Icons.refresh),
        label: const Text('تعذر تحميل تصعيدات المزودين — إعادة المحاولة'),
      );
    }
    if (_items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مزودون بانتظار قرارك (${_items.length})',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final e in _items) ...[
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
                  '#PRV-${e.providerId} • ${e.name}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (e.businessType.isNotEmpty) Text(e.businessType),
                const SizedBox(height: 6),
                Text(
                  'سبب الرفع: ${e.reason.isEmpty ? '—' : e.reason}',
                  style: TextStyle(color: AppColors.dangerDark, fontSize: 12),
                ),
                if (e.supervisorName.isNotEmpty)
                  Text(
                    'المشرف: ${e.supervisorName}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                const SizedBox(height: 10),
                if (_busyId == e.providerId)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => _suspend(e),
                        child: const Text('إيقاف المزود'),
                      ),
                      OutlinedButton(
                        onPressed: () => _close(e),
                        child: const Text('إغلاق بدون إجراء'),
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
