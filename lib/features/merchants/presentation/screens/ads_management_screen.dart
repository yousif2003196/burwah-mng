import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

// منتجات التجار الحقيقية من السيرفر: المنتج الجديد أو المتعدّل بيفضل مخفي عن العملاء
// لحد ما مشرف التجار يقبله. القرارات: قبول، رفض بسبب، تعليق بسبب، وإعادة مراجعة القرار.

ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

String _serverMessage(Object error, String fallback) {
  if (error is DioException) {
    final body = error.response?.data;
    final message = body is Map ? '${body['message'] ?? ''}'.trim() : '';
    if (message.isNotEmpty) return message;
  }
  return fallback;
}

String? _s(Object? v) {
  final t = '${v ?? ''}'.trim();
  return t.isEmpty || t == 'null' ? null : t;
}

double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

int _i(Object? v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

DateTime? _date(Object? raw) {
  final t = _s(raw);
  if (t == null) return null;
  final zoned = t.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(t);
  return DateTime.tryParse(zoned ? t : '${t}Z')?.toLocal();
}

String _ago(DateTime? d) {
  if (d == null) return '—';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'دلوقتي';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
  if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
  return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}

String _money(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// رابط الصورة: لو السيرفر رجّع مسار نسبي بنكمّله بعنوان السيرفر.
String? _image(Object? raw) {
  final url = _s(raw);
  if (url == null) return null;
  if (url.startsWith('http')) return url;
  final base = '${RealtimeHub.instance.baseUrl}'.replaceAll(RegExp(r'/+$'), '');
  if (base.isEmpty || base == 'null') return url;
  return url.startsWith('/') ? '$base$url' : '$base/$url';
}

/// منتج تاجر في قايمة المراجعة.
class MerchantProductItem {
  final int id;
  final String name;
  final double price;
  final double? originalPrice;
  final int stock;
  final String? imageUrl;
  final String? section;
  final int merchantId;
  final String merchantName;

  /// pending | approved | rejected | suspended
  final String status;
  final String? reason;
  final bool visible;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  const MerchantProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.stock = 0,
    this.imageUrl,
    this.section,
    required this.merchantId,
    required this.merchantName,
    required this.status,
    this.reason,
    this.visible = false,
    this.submittedAt,
    this.reviewedAt,
  });

  factory MerchantProductItem.fromJson(Map json) => MerchantProductItem(
        id: _i(json['id']),
        name: _s(json['name']) ?? '—',
        price: _d(json['price']),
        originalPrice: json['originalPrice'] == null ? null : _d(json['originalPrice']),
        stock: _i(json['stock']),
        imageUrl: _image(json['imageUrl']),
        section: _s(json['section']),
        merchantId: _i(json['merchantId']),
        merchantName: _s(json['merchantName']) ?? '—',
        status: _s(json['reviewStatus']) ?? 'pending',
        reason: _s(json['reviewReason']),
        visible: json['visible'] == true,
        submittedAt: _date(json['submittedAt']),
        reviewedAt: _date(json['reviewedAt']),
      );
}

typedef ProductCounts = ({int pending, int approved, int rejected, int suspended});

abstract class MerchantProductsApi {
  static Future<int> pendingCount() async {
    final r = await _api.get<Object>(ApiEndpoints.merchantProductsPendingCount);
    final body = r.data;
    return body is Map ? _i(body['count']) : 0;
  }

  static Future<({List<MerchantProductItem> items, int total, ProductCounts counts})> list({
    required String status,
    String? search,
    int? merchantId,
    int page = 1,
    int pageSize = 30,
  }) async {
    final r = await _api.get<Object>(
      ApiEndpoints.merchantProducts,
      queryParameters: {
        'status': status,
        if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
        if (merchantId != null) 'merchantId': merchantId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final body = r.data;
    if (body is! Map) throw const FormatException('bad products');
    final data = body['data'];
    final c = body['counts'] is Map ? body['counts'] as Map : const {};
    return (
      items: data is List ? data.whereType<Map>().map(MerchantProductItem.fromJson).toList() : <MerchantProductItem>[],
      total: _i(body['total']),
      counts: (
        pending: _i(c['pending']),
        approved: _i(c['approved']),
        rejected: _i(c['rejected']),
        suspended: _i(c['suspended']),
      ),
    );
  }

  static Future<Map<String, dynamic>> details(int id) async {
    final r = await _api.get<Object>(ApiEndpoints.merchantProduct(id));
    final body = r.data;
    final data = body is Map ? body['data'] : null;
    if (data is! Map) throw const FormatException('bad product');
    return Map<String, dynamic>.from(data);
  }

  /// [decision]: approve | reject | suspend | reopen.
  static Future<String> decide(int id, String decision, {String? reason}) async {
    final r = await _api.post<Object>(
      ApiEndpoints.merchantProductDecision(id, decision),
      data: {if (reason != null) 'reason': reason},
    );
    final body = r.data;
    return body is Map ? '${body['message'] ?? ''}' : '';
  }
}

({String label, Color fg, Color bg, IconData icon}) _statusLook(String status) => switch (status) {
      'approved' => (label: 'ظاهر للعملاء', fg: AppColors.successDark, bg: AppColors.successLight, icon: Icons.check_circle_outline),
      'rejected' => (label: 'مرفوض', fg: AppColors.dangerDark, bg: AppColors.dangerLight, icon: Icons.cancel_outlined),
      'suspended' => (label: 'معلّق', fg: AppColors.warningDark, bg: AppColors.warningLight, icon: Icons.pause_circle_outline),
      _ => (label: 'قيد المراجعة', fg: AppColors.infoDark, bg: AppColors.infoLight, icon: Icons.hourglass_top_rounded),
    };

/// بيسأل عن القرار، وبيرجّع السبب ('' للقبول وإعادة المراجعة) أو null لو اتلغى.
Future<String?> askProductDecision(BuildContext context, String productName, String decision, {String? status}) async {
  if (decision == 'approve' || decision == 'reopen') {
    final approve = decision == 'approve';
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(approve ? 'قبول المنتج' : 'إعادة مراجعة القرار',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(approve
            ? '«$productName» هيظهر للعملاء في متجر التاجر ويوصله إشعار. متأكد؟'
            : status == 'approved'
                ? '«$productName» هيتشال من المتجر ويرجع لقيد المراجعة لحد قرارك الجديد.'
                : '«$productName» هيرجع لقيد المراجعة علشان تاخد فيه قرار جديد.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: const Text('إلغاء')),
          FilledButton(
            style: approve ? FilledButton.styleFrom(backgroundColor: AppColors.successDark) : null,
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(approve ? 'قبول' : 'إعادة للمراجعة'),
          ),
        ],
      ),
    );
    return ok == true ? '' : null;
  }

  final suspend = decision == 'suspend';
  final controller = TextEditingController();
  final presets = suspend
      ? const ['السعر محتاج مراجعة', 'المنتج مش متوفر', 'شكوى من العملاء على المنتج', 'الصورة محتاجة تتغير']
      : const ['الصورة مش واضحة أو مش للمنتج', 'الوصف ناقص أو مضلل', 'السعر غير منطقي', 'منتج مخالف لسياسة المنصة'];
  final reason = await showDialog<String>(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (dialog, setLocal) => AlertDialog(
        title: Text(suspend ? 'تعليق المنتج' : 'رفض المنتج',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                suspend
                    ? '«$productName» هيتشال من المتجر مؤقتًا. السبب هيوصل للتاجر، ولو عدّل المنتج هيرجع للمراجعة.'
                    : 'السبب هيوصل للتاجر، ولو عدّل «$productName» هيرجع للمراجعة.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in presets)
                    ActionChip(
                      label: Text(p, style: const TextStyle(fontSize: 11)),
                      onPressed: () => setLocal(() => controller.text = p),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) => setLocal(() {}),
                decoration: InputDecoration(
                  hintText: suspend ? 'سبب التعليق' : 'سبب الرفض',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: suspend ? AppColors.warningDark : AppColors.dangerDark),
            onPressed: controller.text.trim().isEmpty ? null : () => Navigator.of(dialog).pop(controller.text.trim()),
            child: Text(suspend ? 'تعليق' : 'رفض'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  return reason;
}

/// بينفّذ القرار وبيرجّع true لو اتنفذ.
Future<bool> runProductDecision(BuildContext context, int id, String name, String decision, {String? status}) async {
  final reason = await askProductDecision(context, name, decision, status: status);
  if (reason == null || !context.mounted) return false;
  final messenger = ScaffoldMessenger.of(context);
  void toast(String m) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  try {
    final message = await MerchantProductsApi.decide(id, decision, reason: reason.isEmpty ? null : reason);
    toast(message.isEmpty ? 'تم تسجيل القرار' : message);
    return true;
  } on Object catch (error) {
    toast(_serverMessage(error, 'تعذر تسجيل القرار'));
    return false;
  }
}

// ─────────────────────────── الصفحة ───────────────────────────

/// تبويب "المنتجات" عند مشرف التجار (أو منتجات تاجر واحد لو [merchantId] متحدد).
class AdsManagementScreen extends StatefulWidget {
  const AdsManagementScreen({super.key, this.merchantId, this.merchantName});

  final int? merchantId;
  final String? merchantName;

  @override
  State<AdsManagementScreen> createState() => _AdsManagementScreenState();
}

class _AdsManagementScreenState extends State<AdsManagementScreen> {
  static const _pageSize = 30;
  static const _tabs = [
    ('pending', 'قيد المراجعة'),
    ('approved', 'ظاهرة'),
    ('suspended', 'معلّقة'),
    ('rejected', 'مرفوضة'),
  ];

  late String _status = widget.merchantId != null ? 'all' : 'pending';
  final _search = TextEditingController();
  List<MerchantProductItem> _items = [];
  int _total = 0;
  int _page = 0;
  ProductCounts _counts = (pending: 0, approved: 0, rejected: 0, suspended: 0);
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  final Set<int> _busy = {};

  bool get _single => widget.merchantId != null;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// [silent] = سحب للتحديث: لوجو السحب كفاية، من غير سبينر تاني جوه القائمة.
  Future<void> _reload({bool silent = false}) async {
    setState(() {
      _loading = !silent;
      _error = null;
    });
    try {
      final r = await MerchantProductsApi.list(
        status: _status,
        search: _search.text,
        merchantId: widget.merchantId,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items = r.items;
        _total = r.total;
        _counts = r.counts;
        _page = 1;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _serverMessage(error, 'تعذر تحميل المنتجات. اسحب للتحديث.');
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || _items.length >= _total) return;
    setState(() => _loadingMore = true);
    try {
      final r = await MerchantProductsApi.list(
        status: _status,
        search: _search.text,
        merchantId: widget.merchantId,
        page: _page + 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...r.items];
        _page++;
        _total = r.total;
        _loadingMore = false;
      });
    } on Object {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _select(String status) {
    if (status == _status) return;
    setState(() {
      _status = status;
      _items = [];
    });
    _reload();
  }

  Future<void> _decide(MerchantProductItem item, String decision) async {
    setState(() => _busy.add(item.id));
    final done = await runProductDecision(context, item.id, item.name, decision, status: item.status);
    if (!mounted) return;
    setState(() => _busy.remove(item.id));
    if (done) await _reload();
  }

  Future<void> _open(MerchantProductItem item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MerchantProductDetailsScreen(id: item.id, initial: item)),
    );
    if (changed == true && mounted) await _reload();
  }

  int _countOf(String status) => switch (status) {
        'pending' => _counts.pending,
        'approved' => _counts.approved,
        'suspended' => _counts.suspended,
        'rejected' => _counts.rejected,
        _ => _counts.pending + _counts.approved + _counts.suspended + _counts.rejected,
      };

  @override
  Widget build(BuildContext context) {
    final tabs = [if (_single) ('all', 'الكل'), ..._tabs];
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _reload(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              hintText: _single ? 'ابحث باسم المنتج' : 'ابحث باسم المنتج أو المتجر',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _search.clear();
                        _reload();
                      },
                    ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.cardBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.cardBorder)),
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            children: [
              for (final t in tabs) ...[
                _FilterChip(
                  label: t.$2,
                  count: _countOf(t.$1),
                  selected: _status == t.$1,
                  alert: t.$1 == 'pending',
                  onTap: () => _select(t.$1),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        Expanded(
          child: BrandRefreshIndicator(
            onRefresh: () => _reload(silent: true),
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels > n.metrics.maxScrollExtent - 300) _loadMore();
                return false;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 8, 16, _single ? 24 : 120),
                children: [
                  if (_status == 'pending' && _items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'المنتجات دي مش ظاهرة للعملاء لحد ما تقبلها. الأقدم الأول.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  if (_loading && _items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null && _items.isEmpty)
                    _Empty(icon: Icons.cloud_off_outlined, text: _error!)
                  else if (_items.isEmpty)
                    _Empty(
                      icon: _status == 'pending' ? Icons.task_alt_rounded : Icons.inventory_2_outlined,
                      text: _status == 'pending' ? 'مفيش منتجات مستنية مراجعة دلوقتي' : 'مفيش منتجات هنا',
                    )
                  else ...[
                    for (final item in _items) ...[
                      ScrollFx(
                        child: _ProductCard(
                          item: item,
                          showMerchant: !_single,
                          busy: _busy.contains(item.id),
                          onOpen: () => _open(item),
                          onDecide: (d) => _decide(item, d),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_items.length < _total)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: _single
          ? AppBar(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.ink,
              title: Text('منتجات ${widget.merchantName ?? 'التاجر'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          : null,
      body: body,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.count, required this.selected, required this.onTap, this.alert = false});

  final String label;
  final int count;
  final bool selected;
  final bool alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? AppColors.primaryDark : AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                )),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: alert ? AppColors.danger : (selected ? Colors.white24 : AppColors.surfaceHighlight),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('$count',
                    style: TextStyle(
                      color: alert || selected ? Colors.white : AppColors.ink,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    final look = _statusLook(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: look.bg, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(look.icon, size: 12, color: look.fg),
          const SizedBox(width: 4),
          Text(look.label, style: TextStyle(color: look.fg, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Center(child: Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 28));
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? placeholder
          : Image.network(url!, fit: BoxFit.cover, errorBuilder: (context, error, stack) => placeholder),
    );
  }
}

/// أزرار القرار حسب حالة المنتج.
class _Actions extends StatelessWidget {
  const _Actions({required this.status, required this.busy, required this.onDecide});

  final String status;
  final bool busy;
  final ValueChanged<String> onDecide;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    Widget filled(String label, Color color, String decision) => Expanded(
          child: FilledButton(
            onPressed: () => onDecide(decision),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        );
    Widget outlined(String label, Color color, String decision) => Expanded(
          child: OutlinedButton(
            onPressed: () => onDecide(decision),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        );
    final buttons = switch (status) {
      'pending' => [
          filled('قبول', AppColors.successDark, 'approve'),
          outlined('تعليق', AppColors.warningDark, 'suspend'),
          outlined('رفض', AppColors.dangerDark, 'reject'),
        ],
      'approved' => [
          outlined('تعليق', AppColors.warningDark, 'suspend'),
          outlined('رفض', AppColors.dangerDark, 'reject'),
          outlined('إعادة مراجعة', AppColors.infoDark, 'reopen'),
        ],
      _ => [
          filled('قبول', AppColors.successDark, 'approve'),
          outlined('إعادة مراجعة', AppColors.infoDark, 'reopen'),
        ],
    };
    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          buttons[i],
        ],
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.showMerchant,
    required this.busy,
    required this.onOpen,
    required this.onDecide,
  });

  final MerchantProductItem item;
  final bool showMerchant;
  final bool busy;
  final VoidCallback onOpen;
  final ValueChanged<String> onDecide;

  @override
  Widget build(BuildContext context) {
    final discounted = item.originalPrice != null && item.originalPrice! > item.price;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumb(url: item.imageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 6),
                            _StatusPill(item.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (showMerchant)
                          Row(
                            children: [
                              Icon(Icons.storefront_outlined, size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(item.merchantName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ),
                            ],
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('${_money(item.price)} ج.م',
                                style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w800)),
                            if (discounted) ...[
                              const SizedBox(width: 6),
                              Text('${_money(item.originalPrice!)} ج.م',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                  )),
                            ],
                            const Spacer(),
                            Text(
                              item.status == 'pending' ? _ago(item.submittedAt) : _ago(item.reviewedAt ?? item.submittedAt),
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [if (item.section != null) item.section!, 'المخزون: ${item.stock}'].join(' • '),
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.reason != null) ...[
                const SizedBox(height: 10),
                _ReasonBox(status: item.status, reason: item.reason!),
              ],
              const SizedBox(height: 10),
              _Actions(status: item.status, busy: busy, onDecide: onDecide),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonBox extends StatelessWidget {
  const _ReasonBox({required this.status, required this.reason});

  final String status;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final look = _statusLook(status);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: look.bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: look.fg),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${status == 'suspended' ? 'سبب التعليق' : 'سبب الرفض'}: $reason',
              style: TextStyle(color: look.fg, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── تفاصيل منتج ───────────────────────────

class MerchantProductDetailsScreen extends StatefulWidget {
  const MerchantProductDetailsScreen({super.key, required this.id, this.initial});

  final int id;
  final MerchantProductItem? initial;

  @override
  State<MerchantProductDetailsScreen> createState() => _MerchantProductDetailsScreenState();
}

class _MerchantProductDetailsScreenState extends State<MerchantProductDetailsScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _busy = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await MerchantProductsApi.details(widget.id);
      if (!mounted) return;
      setState(() {
        _data = data;
        _error = null;
      });
    } on Object catch (error) {
      if (mounted) setState(() => _error = _serverMessage(error, 'تعذر تحميل المنتج'));
    }
  }

  Future<void> _decide(String decision) async {
    final d = _data;
    final name = _s(d?['name']) ?? widget.initial?.name ?? 'المنتج';
    setState(() => _busy = true);
    final done = await runProductDecision(context, widget.id, name, decision, status: _s(d?['reviewStatus']));
    if (!mounted) return;
    if (done) {
      _changed = true;
      await _load();
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: const Text('تفاصيل المنتج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        body: d == null
            ? Center(
                child: _error == null
                    ? const CircularProgressIndicator()
                    : _Empty(icon: Icons.cloud_off_outlined, text: _error!),
              )
            : BrandRefreshIndicator(onRefresh: _load, child: _content(d)),
        bottomNavigationBar: d == null
            ? null
            : SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.cardBorder)),
                  ),
                  child: _Actions(status: _s(d['reviewStatus']) ?? 'pending', busy: _busy, onDecide: _decide),
                ),
              ),
      ),
    );
  }

  static String _actionLabel(String action) => switch (action) {
        'approve_product' => 'قبول',
        'reject_product' => 'رفض',
        'hide_product' => 'تعليق',
        'reopen_product' => 'إعادة مراجعة',
        _ => action,
      };

  Widget _content(Map<String, dynamic> d) {
    final status = _s(d['reviewStatus']) ?? 'pending';
    final image = _image(d['imageUrl']);
    final price = _d(d['price']);
    final original = d['originalPrice'] == null ? null : _d(d['originalPrice']);
    final merchant = d['merchant'] is Map ? Map<String, dynamic>.from(d['merchant'] as Map) : const <String, dynamic>{};
    final history = d['history'] is List ? (d['history'] as List).whereType<Map>().toList() : const <Map>[];
    final reason = _s(d['reviewReason']);
    final reviewedAt = _date(d['reviewedAt']);

    Widget card(String title, IconData icon, List<Widget> children) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.infoDark),
                  const SizedBox(width: 6),
                  Text(title, style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        );
    Widget row(String label, String? value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
              Expanded(
                child: Text(value == null || value.isEmpty ? '—' : value,
                    style: TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
    String yes(Object? v) => v == true ? 'أيوه' : 'لأ';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        GestureDetector(
          onTap: image == null
              ? null
              : () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      body: Center(child: InteractiveViewer(maxScale: 5, child: Image.network(image, fit: BoxFit.contain))),
                    ),
                  )),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(18)),
              clipBehavior: Clip.antiAlias,
              child: image == null
                  ? Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.textMuted)
                  : Image.network(image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          Icon(Icons.broken_image_outlined, size: 56, color: AppColors.textMuted)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(_s(d['name']) ?? '—',
                  style: TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            _StatusPill(status),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('${_money(price)} ج.م', style: TextStyle(color: AppColors.ink, fontSize: 17, fontWeight: FontWeight.w800)),
            if (original != null && original > price) ...[
              const SizedBox(width: 8),
              Text('${_money(original)} ج.م',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13, decoration: TextDecoration.lineThrough)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (reason != null) ...[
          _ReasonBox(status: status, reason: reason),
          const SizedBox(height: 12),
        ],
        card('بيانات المنتج', Icons.inventory_2_outlined, [
          row('الوصف', _s(d['description'])),
          row('القسم', _s(d['section'])),
          row('المخزون', '${_i(d['stock'])}'),
          if (_d(d['discount']) > 0) row('الخصم', '${_money(_d(d['discount']))}%'),
          row('عرض خاص', yes(d['isSpecialOffer'])),
          row('متاح للطلب الفوري', yes(d['isAvailableForInstantOrder'])),
          row('ظاهر للعملاء', yes(d['visible'])),
          row('رقم المنتج', 'P-${_i(d['id'])}'),
        ]),
        card('المراجعة', Icons.fact_check_outlined, [
          row('اتبعت للمراجعة', _ago(_date(d['submittedAt']))),
          row('آخر قرار', reviewedAt == null ? null : _ago(reviewedAt)),
          row('أخد القرار', _s(d['reviewedBy'])),
          row('اتطلب', '${_i(d['ordersCount'])} طلب • ${_i(d['soldQuantity'])} قطعة'),
        ]),
        card('التاجر', Icons.storefront_outlined, [
          row('المتجر', _s(merchant['storeName'])),
          row('صاحب المتجر', _s(merchant['ownerName'])),
          row('الموبايل', _s(merchant['phone'])),
          row('المكان', [_s(merchant['city']), _s(merchant['governorate'])].whereType<String>().join('، ')),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => AdsManagementScreen(merchantId: _i(merchant['id']), merchantName: _s(merchant['storeName'])),
            )),
            icon: const Icon(Icons.grid_view_rounded, size: 18),
            label: const Text('كل منتجات التاجر'),
          ),
        ]),
        if (history.isNotEmpty)
          card('سجل القرارات', Icons.history_rounded, [
            for (final h in history)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Icon(Icons.circle, size: 7, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_actionLabel('${h['action']}')} — ${'${h['note'] ?? ''}'.replaceFirst(RegExp(r'^#\d+\s*'), '')}',
                        style: TextStyle(color: AppColors.ink, fontSize: 12),
                      ),
                    ),
                    Text(_ago(_date(h['at'])), style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
          ]),
      ],
    );
  }
}
