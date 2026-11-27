import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_api.dart';

/// طلبات سحب التجار (بالجنيه المصري): المشرف يراجع ويرشّح للمالية.
class MerchantWithdrawalsReviewScreen extends StatefulWidget {
  const MerchantWithdrawalsReviewScreen({super.key});

  @override
  State<MerchantWithdrawalsReviewScreen> createState() =>
      _MerchantWithdrawalsReviewScreenState();
}

class _MerchantWithdrawalsReviewScreenState
    extends State<MerchantWithdrawalsReviewScreen> {
  List<Map<String, dynamic>> _rows = const [];
  bool _loading = true;
  String? _error;
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// أول تحميل بس اللي بيعرض شاشة التحميل؛ السحب للتحديث والتحديث بعد أي
  /// إجراء بيسيبوا القائمة ظاهرة (وإلا الـ RefreshIndicator بيتشال وهو شغال).
  bool _loadedOnce = false;

  Future<void> _load() async {
    final quiet = _loadedOnce;
    setState(() {
      if (!quiet) _loading = true;
      _error = null;
    });
    try {
      final rows = await MerchantsApi.withdrawals(status: 0);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
        _loadedOnce = true;
      });
    } catch (e) {
      if (!mounted) return;
      if (quiet) {
        // البيانات القديمة تفضل، والخطأ يظهر كرسالة.
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(MerchantsApi.messageOf(e))));
        return;
      }
      setState(() {
        _error = MerchantsApi.messageOf(e);
        _loading = false;
      });
    }
  }

  static String _egp(Object? v) {
    final d = (v as num?)?.toDouble() ?? 0;
    final s = d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
    return '$s ج.م';
  }

  Future<void> _recommend(int id) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ترشيح الطلب للمالية'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'ملاحظة (اختياري)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('ترشيح')),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;
    setState(() => _busy.add(id));
    try {
      await MerchantsApi.recommendWithdrawal(id, note: note);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم إرسال الترشيح للمالية')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(MerchantsApi.messageOf(e))));
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
              Center(child: Text('لا توجد طلبات سحب معلقة')),
            ])
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final w = _rows[i];
                final id = (w['id'] as num).toInt();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text('${w['merchantName'] ?? ''}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Text(_egp(w['amount']),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark)),
                        ]),
                        const SizedBox(height: 6),
                        if ('${w['method'] ?? ''}'.isNotEmpty)
                          Text('الطريقة: ${w['method']}'),
                        if ('${w['destination'] ?? ''}'.isNotEmpty)
                          Text('الوجهة: ${w['destination']}'),
                        if ('${w['holderName'] ?? ''}'.isNotEmpty)
                          Text('باسم: ${w['holderName']}'),
                        if (((w['fee'] as num?) ?? 0) > 0)
                          Text('الرسوم: ${_egp(w['fee'])}'),
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: _busy.contains(id)
                              ? const CircularProgressIndicator()
                              : FilledButton.icon(
                                  onPressed: () => _recommend(id),
                                  icon: const Icon(Icons.send_outlined),
                                  label: const Text('ترشيح للمالية'),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
