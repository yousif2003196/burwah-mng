import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_api.dart';

/// مراجعة تسجيل التجار الجدد: قبول / طلب استكمال بيانات / رفض بسبب.
class MerchantRegistrationReviewScreen extends StatefulWidget {
  const MerchantRegistrationReviewScreen({super.key});

  @override
  State<MerchantRegistrationReviewScreen> createState() =>
      _MerchantRegistrationReviewScreenState();
}

class _MerchantRegistrationReviewScreenState
    extends State<MerchantRegistrationReviewScreen> {
  List<Map<String, dynamic>> _rows = const [];
  bool _loading = true;
  String? _error;
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pending = await MerchantsApi.merchants(status: 'pending');
      final info = await MerchantsApi.merchants(status: 'info');
      if (!mounted) return;
      setState(() {
        _rows = [...pending, ...info];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = MerchantsApi.messageOf(e);
        _loading = false;
      });
    }
  }

  void _toast(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  Future<String?> _askReason(String title, {bool required = true}) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'اكتب السبب / الملاحظة'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (required && text.isEmpty) return;
              Navigator.pop(ctx, text);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _run(int id, Future<void> Function() action, String done) async {
    setState(() => _busy.add(id));
    try {
      await action();
      _toast(done);
      await _load();
    } catch (e) {
      _toast(MerchantsApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!),
          const SizedBox(height: 8),
          FilledButton(onPressed: _load, child: const Text('إعادة المحاولة')),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: _rows.isEmpty
          ? ListView(children: const [
              SizedBox(height: 120),
              Center(child: Text('لا توجد تسجيلات بانتظار المراجعة')),
            ])
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _card(_rows[i]),
            ),
    );
  }

  Widget _card(Map<String, dynamic> m) {
    final id = (m['id'] as num).toInt();
    final busy = _busy.contains(id);
    final info = m['status'] == 'info';
    final lines = <String>[
      if ('${m['ownerName'] ?? ''}'.isNotEmpty) 'المالك: ${m['ownerName']}',
      if ('${m['phone'] ?? ''}'.isNotEmpty) 'الهاتف: ${m['phone']}',
      if ('${m['email'] ?? ''}'.isNotEmpty) 'البريد: ${m['email']}',
      if ('${m['address'] ?? ''}'.isNotEmpty) 'العنوان: ${m['address']}',
      if ('${m['commercialRegister'] ?? ''}'.isNotEmpty)
        'السجل التجاري: ${m['commercialRegister']}',
      if (info && '${m['reviewNote'] ?? ''}'.isNotEmpty)
        'المطلوب: ${m['reviewNote']}',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  '${m['storeName'] ?? ''}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Chip(
                label: Text(info ? 'بانتظار استكمال' : 'جديد'),
                backgroundColor:
                    AppColors.warningDark.withValues(alpha: 0.15),
              ),
            ]),
            Text('${m['businessType'] ?? ''}'),
            const SizedBox(height: 6),
            for (final l in lines) Text(l),
            const SizedBox(height: 10),
            if (busy)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(
                  onPressed: () => _run(id, () => MerchantsApi.approve(id),
                      'تم قبول التاجر'),
                  icon: const Icon(Icons.check),
                  label: const Text('قبول'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final r = await _askReason('المطلوب من التاجر');
                    if (r == null) return;
                    await _run(id, () => MerchantsApi.requestInfo(id, r),
                        'تم طلب استكمال البيانات');
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text('طلب بيانات'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dangerDark),
                  onPressed: () async {
                    final r = await _askReason('سبب الرفض');
                    if (r == null) return;
                    await _run(
                        id, () => MerchantsApi.reject(id, r), 'تم رفض التسجيل');
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('رفض'),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}
