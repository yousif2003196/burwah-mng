import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_api.dart';

/// آخر طلبات التاجر من السيرفر (رقم الطلب، العميل، الحالة، الدفع، قيمة اللي باعه التاجر فيه).
class MerchantOrdersScreen extends StatefulWidget {
  const MerchantOrdersScreen({super.key, required this.merchantId, required this.merchantName});

  final int merchantId;
  final String merchantName;

  @override
  State<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends State<MerchantOrdersScreen> {
  List<Map<String, dynamic>> _orders = const [];
  bool _loading = true;
  String? _error;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await MerchantsApi.orders(widget.merchantId);
      if (!mounted) return;
      setState(() {
        _orders = rows;
        _loading = false;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = MerchantsApi.messageOf(error);
      });
    }
  }

  static (String, Color, Color) _status(String raw) => switch (raw) {
        'Delivered' => ('اتسلّم', AppColors.successDark, AppColors.successLight),
        'Cancelled' => ('ملغي', AppColors.dangerDark, AppColors.dangerLight),
        'OutForDelivery' || 'Shipped' => ('في الطريق', AppColors.infoDark, AppColors.infoLight),
        'Processing' => ('بيتجهّز', AppColors.warningDark, AppColors.warningLight),
        'PendingAdminApproval' => ('بانتظار الموافقة', AppColors.warningDark, AppColors.warningLight),
        _ => ('جديد', AppColors.infoDark, AppColors.infoLight),
      };

  static String _payment(String raw) => switch (raw) {
        'CreditCard' => 'فيزا',
        'InstaPay' => 'إنستاباي',
        _ => 'كاش',
      };

  static String _group(String raw) => switch (raw) {
        'Delivered' => 'done',
        'Cancelled' => 'cancelled',
        _ => 'open',
      };

  static String _date(Object? raw) {
    final t = '${raw ?? ''}'.trim();
    if (t.isEmpty) return '';
    final zoned = t.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(t);
    final d = DateTime.tryParse(zoned ? t : '${t}Z')?.toLocal();
    if (d == null) return '';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}/${two(d.month)}/${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  static String _money(Object? v) {
    final n = v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    return n.truncateToDouble() == n ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filter == 'all'
        ? _orders
        : _orders.where((o) => _group('${o['status']}') == _filter).toList();
    final delivered = _orders.where((o) => o['status'] == 'Delivered');
    final sales = delivered.fold<double>(0, (sum, o) => sum + ((o['total'] as num?)?.toDouble() ?? 0));
    int count(String f) => f == 'all' ? _orders.length : _orders.where((o) => _group('${o['status']}') == f).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          centerTitle: true,
          title: Column(
            children: [
              const Text('طلبات التاجر', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(widget.merchantName, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        body: BrandRefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              if (_loading)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center))
              else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _Stat(label: 'آخر الطلبات', value: '${_orders.length}')),
                      Expanded(child: _Stat(label: 'اتسلّمت', value: '${delivered.length}')),
                      Expanded(child: _Stat(label: 'مبيعات المسلّم', value: '${_money(sales)} ج.م')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final f in const [('all', 'الكل'), ('open', 'جارية'), ('done', 'اتسلّمت'), ('cancelled', 'ملغية')])
                      ChoiceChip(
                        label: Text('${f.$2} (${count(f.$1)})'),
                        selected: _filter == f.$1,
                        onSelected: (_) => setState(() => _filter = f.$1),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(children: [
                      Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 8),
                      Text('مفيش طلبات هنا', style: TextStyle(color: AppColors.textSecondary)),
                    ]),
                  )
                else
                  for (final o in visible) ...[
                    ScrollFx(child: _orderCard(o)),
                    const SizedBox(height: 8),
                  ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> o) {
    final (label, fg, bg) = _status('${o['status']}');
    final customer = '${o['customerName'] ?? ''}'.trim();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.receipt_outlined, color: fg, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('طلب #${o['id']}${customer.isEmpty ? '' : ' • $customer'}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text('${_date(o['createdAt'])} • ${_payment('${o['paymentMethod']}')}',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_money(o['total'])} ج.م',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.ink)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
                child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: fg)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.ink)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
      ],
    );
  }
}
