import 'dart:async';

import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';

/// شكاوى المنتجات المستعملة اللي رفعها مشرف وصلني للرئيس
/// (`GET api/SupervisorUsed/complaint-escalations`). الرئيس يحسم الشكوى
/// (`POST complaints/{id}/resolve`) فتتقفل وتختفي من القائمة.
class HeadUsedComplaintEscalationsPanel extends StatefulWidget {
  const HeadUsedComplaintEscalationsPanel({super.key});

  @override
  State<HeadUsedComplaintEscalationsPanel> createState() =>
      _HeadUsedComplaintEscalationsPanelState();
}

class _UsedEscalation {
  _UsedEscalation(Map<String, dynamic> j)
    : complaintId = (j['complaintId'] as num).toInt(),
      title = '${j['title'] ?? ''}',
      description = '${j['description'] ?? ''}',
      buyerName = '${j['buyerName'] ?? ''}',
      reason = '${j['reason'] ?? ''}',
      supervisorName = '${j['supervisorName'] ?? ''}';

  final int complaintId;
  final String title;
  final String description;
  final String buyerName;
  final String reason;
  final String supervisorName;
}

class _HeadUsedComplaintEscalationsPanelState
    extends State<HeadUsedComplaintEscalationsPanel> {
  ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');
  List<_UsedEscalation> _items = const [];
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
        .where((n) => n.type == 'used_complaint_escalation')
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
      final response = await _api.get<Object>(ApiEndpoints.usedComplaintEscalations);
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! List) throw const FormatException('bad escalations');
      final items = [
        for (final item in data)
          if (item is Map<String, dynamic>) _UsedEscalation(item),
      ];
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _failed = false;
      });
    } on Object catch (error) {
      debugPrint('Head used complaint escalations load failed: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = _items.isEmpty;
      });
    }
  }

  Future<String?> _askNote() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('قرارك في الشكوى'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'اكتب القرار / الملاحظة'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.length < 5) return;
                Navigator.of(ctx).pop(text);
              },
              child: const Text('حسم الشكوى'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _resolve(_UsedEscalation e) async {
    final note = await _askNote();
    if (note == null || !mounted) return;
    setState(() => _busyId = e.complaintId);
    try {
      await _api.post<Object>(
        ApiEndpoints.usedComplaintResolve(e.complaintId),
        data: {'reason': note},
      );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'تم حسم الشكوى #CMP-${e.complaintId}');
      await _load();
    } on Object catch (error) {
      debugPrint('Head used complaint decision failed: $error');
      if (mounted) {
        AppSnackBar.showError(context, 'تعذر تنفيذ القرار، حاول مرة أخرى.');
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_failed) {
      return TextButton.icon(
        onPressed: _load,
        icon: const Icon(Icons.refresh),
        label: const Text('تعذر تحميل شكاوى وصلني — إعادة المحاولة'),
      );
    }
    if (_items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'شكاوى وصلني بانتظار قرارك (${_items.length})',
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
                  '#CMP-${e.complaintId} • ${e.title}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (e.buyerName.isNotEmpty) Text('صاحب الشكوى: ${e.buyerName}'),
                if (e.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    e.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'سبب الرفع: ${e.reason.isEmpty ? '—' : e.reason}',
                  style: TextStyle(color: AppColors.dangerDark, fontSize: 12),
                ),
                if (e.supervisorName.isNotEmpty)
                  Text(
                    'المشرف: ${e.supervisorName}',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                const SizedBox(height: 10),
                if (_busyId == e.complaintId)
                  const Center(child: CircularProgressIndicator())
                else
                  FilledButton(
                    onPressed: () => _resolve(e),
                    child: const Text('حسم الشكوى'),
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
