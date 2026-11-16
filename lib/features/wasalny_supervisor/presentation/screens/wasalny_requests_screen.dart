import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/messaging/presentation/screens/ad_owner_chat_screen.dart';

bool _isArabic(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

String _serverMessage(Object error, String fallback) {
  try {
    final data = (error as dynamic).response?.data;
    if (data is Map && data['message'] is String && '${data['message']}'.isNotEmpty) {
      return '${data['message']}';
    }
  } catch (_) {}
  return fallback;
}

String _timeAgo(DateTime at, bool ar) {
  final span = DateTime.now().difference(at);
  if (span.inMinutes < 1) return ar ? 'الآن' : 'Just now';
  if (span.inMinutes < 60) {
    return ar ? 'منذ ${span.inMinutes} دقيقة' : '${span.inMinutes} min ago';
  }
  if (span.inHours < 24) {
    return ar ? 'منذ ${span.inHours} ساعة' : '${span.inHours} h ago';
  }
  return ar ? 'منذ ${span.inDays} يوم' : '${span.inDays} d ago';
}

class _Req {
  _Req(Map<String, dynamic> j)
    : id = (j['id'] as num).toInt(),
      adId = (j['adId'] as num?)?.toInt() ?? 0,
      adTitle = '${j['adTitle'] ?? ''}',
      adPrice = (j['adPrice'] as num?)?.toDouble() ?? 0,
      imageUrl = '${j['imageUrl'] ?? ''}',
      buyerName = '${j['buyerName'] ?? ''}',
      buyerPhone = '${j['buyerPhone'] ?? ''}',
      sellerName = '${j['sellerName'] ?? ''}',
      sellerPhone = '${j['sellerPhone'] ?? ''}',
      status = '${j['status'] ?? 'underReview'}',
      reason = '${j['reason'] ?? ''}',
      createdAt =
          DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal() ??
          DateTime.now();

  final int id;
  final int adId;
  final String adTitle;
  final double adPrice;
  final String imageUrl;
  final String buyerName;
  final String buyerPhone;
  final String sellerName;
  final String sellerPhone;
  final String status;
  final String reason;
  final DateTime createdAt;
}

({String ar, String en, Color Function() color}) _statusStyle(String status) {
  switch (status) {
    case 'approved':
      return (ar: 'معتمد', en: 'Approved', color: () => AppColors.success);
    case 'rejected':
      return (ar: 'مرفوض', en: 'Rejected', color: () => AppColors.danger);
    case 'frozen':
      return (ar: 'مجمّد', en: 'Frozen', color: () => AppColors.info);
    default:
      return (ar: 'قيد المراجعة', en: 'Under review', color: () => AppColors.warning);
  }
}

/// طلبات وصلني: كل طلب جديد من مشتري على منتج مستعمل يوصل هنا الأول.
/// المشرف يراجع بيانات الطرفين ثم يعتمد (تفتح محادثة بين البائع والمشتري)
/// أو يرفض (السبب للمشتري) أو يجمّد (السبب للبائع). أي طلب اتخذ عليه قرار
/// يروح للأرشيف ويقدر المشرف يرجّعه لقيد المراجعة.
class WasalnyRequestsScreen extends StatefulWidget {
  const WasalnyRequestsScreen({super.key});

  @override
  State<WasalnyRequestsScreen> createState() => _WasalnyRequestsScreenState();
}

class _WasalnyRequestsScreenState extends State<WasalnyRequestsScreen> {
  ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

  bool _archive = false;
  List<_Req> _items = const [];
  int _reviewCount = 0;
  int _archiveCount = 0;
  bool _loading = true;
  bool _failed = false;
  Timer? _timer;
  StreamSubscription<dynamic>? _live;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => _load(quiet: true));
    _live = RealtimeHub.instance.notifications
        .where((n) => n.type == 'wasalny_request_new')
        .listen((_) => _load(quiet: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _live?.cancel();
    super.dispose();
  }

  Future<void> _load({bool quiet = false}) async {
    if (!AuthSession.isSignedIn) {
      setState(() => _loading = false);
      return;
    }
    if (!quiet) setState(() => _loading = true);
    try {
      final response = await _api.get<Object>(
        ApiEndpoints.wasalnyRequests,
        queryParameters: {'tab': _archive ? 'archive' : 'review', 'pageSize': 100},
      );
      final body = response.data;
      if (body is! Map || body['data'] is! List) throw const FormatException('bad requests');
      final counts = body['counts'];
      final items = [
        for (final item in body['data'] as List)
          if (item is Map<String, dynamic>) _Req(item),
      ];
      if (!mounted) return;
      setState(() {
        _items = items;
        if (counts is Map) {
          _reviewCount = (counts['review'] as num?)?.toInt() ?? _reviewCount;
          _archiveCount = (counts['archive'] as num?)?.toInt() ?? _archiveCount;
        }
        _loading = false;
        _failed = false;
      });
    } on Object catch (error) {
      debugPrint('Wasalny requests load failed: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = _items.isEmpty;
      });
    }
  }

  void _setTab(bool archive) {
    if (_archive == archive) return;
    setState(() {
      _archive = archive;
      _items = const [];
    });
    _load();
  }

  Future<void> _open(_Req request) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => WasalnyRequestDetailsScreen(requestId: request.id),
      ),
    );
    if (changed == true) _load(quiet: true);
  }

  @override
  Widget build(BuildContext context) {
    final ar = _isArabic(context);
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _TabChip(
                    label: '${ar ? 'قيد المراجعة' : 'Under review'} ($_reviewCount)',
                    selected: !_archive,
                    onTap: () => _setTab(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TabChip(
                    label: '${ar ? 'الأرشيف' : 'Archive'} ($_archiveCount)',
                    selected: _archive,
                    onTap: () => _setTab(true),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body(ar)),
        ],
      ),
    );
  }

  Widget _body(bool ar) {
    if (!AuthSession.isSignedIn) {
      return _Message(text: ar ? 'سجّل الدخول لعرض الطلبات' : 'Sign in to see the requests');
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed) {
      return Center(
        child: TextButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: Text(ar ? 'تعذر تحميل الطلبات — إعادة المحاولة' : 'Could not load — retry'),
        ),
      );
    }
    return BrandRefreshIndicator(
      onRefresh: () => _load(quiet: true),
      child: _items.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: 280,
                  child: _Message(
                    text: _archive
                        ? (ar ? 'الأرشيف فاضي' : 'The archive is empty')
                        : (ar ? 'مفيش طلبات قيد المراجعة' : 'No requests under review'),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _RequestCard(request: _items[i], onTap: () => _open(_items[i])),
            ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
    ),
  );
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryDark : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.primaryDark : AppColors.cardBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: selected ? Colors.white : AppColors.textPrimary,
        ),
      ),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);
    final color = style.color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _isArabic(context) ? style.ar : style.en,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onTap});

  final _Req request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ar = _isArabic(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('#REQ-${request.id}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  _StatusChip(status: request.status),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: request.imageUrl.isEmpty
                          ? ColoredBox(color: AppColors.surfaceMuted, child: Icon(Icons.image_outlined, color: AppColors.textMuted))
                          : Image.network(
                              request.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => ColoredBox(color: AppColors.surfaceMuted, child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.adTitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('${request.adPrice.toStringAsFixed(request.adPrice % 1 == 0 ? 0 : 2)} ${ar ? 'ج.م' : 'EGP'}', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _PersonLine(icon: Icons.shopping_bag_outlined, label: ar ? 'المشتري' : 'Buyer', name: request.buyerName, phone: request.buyerPhone),
              const SizedBox(height: 4),
              _PersonLine(icon: Icons.storefront_outlined, label: ar ? 'البائع' : 'Seller', name: request.sellerName, phone: request.sellerPhone),
              if (request.reason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${ar ? 'السبب' : 'Reason'}: ${request.reason}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.dangerDark, fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              Text(_timeAgo(request.createdAt, ar), style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonLine extends StatelessWidget {
  const _PersonLine({required this.icon, required this.label, required this.name, required this.phone});

  final IconData icon;
  final String label;
  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Text('$label: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      Expanded(
        child: Text(
          phone.isEmpty ? name : '$name • $phone',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

// ───────────────────────── details ─────────────────────────

class _Person {
  _Person(Map<String, dynamic> j)
    : id = (j['id'] as num?)?.toInt() ?? 0,
      name = '${j['name'] ?? ''}',
      phone = '${j['phone'] ?? ''}',
      email = '${j['email'] ?? ''}',
      governorate = '${j['governorate'] ?? ''}',
      city = '${j['city'] ?? ''}',
      address = '${j['address'] ?? ''}',
      imageUrl = '${j['imageUrl'] ?? ''}',
      rating = (j['rating'] as num?)?.toDouble() ?? 0,
      isVerified = j['isVerified'] == true;

  final int id;
  final String name;
  final String phone;
  final String email;
  final String governorate;
  final String city;
  final String address;
  final String imageUrl;
  final double rating;
  final bool isVerified;
}

/// تفاصيل طلب وصلني: الإعلان وبيانات البائع والمشتري كاملة، مع القرار.
class WasalnyRequestDetailsScreen extends StatefulWidget {
  const WasalnyRequestDetailsScreen({super.key, required this.requestId});

  final int requestId;

  @override
  State<WasalnyRequestDetailsScreen> createState() => _WasalnyRequestDetailsScreenState();
}

class _WasalnyRequestDetailsScreenState extends State<WasalnyRequestDetailsScreen> {
  ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _failed = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final response = await _api.get<Object>(ApiEndpoints.wasalnyRequest(widget.requestId));
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map<String, dynamic>) throw const FormatException('bad request');
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } on Object catch (error) {
      debugPrint('Wasalny request load failed: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<String?> _askReason(String title) async {
    final ar = _isArabic(context);
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(hintText: ar ? 'اكتب السبب' : 'Write the reason'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(ar ? 'إلغاء' : 'Cancel')),
              FilledButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.length < 3) return;
                  Navigator.of(ctx).pop(text);
                },
                child: Text(ar ? 'تأكيد' : 'Confirm'),
              ),
            ],
          ),
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _decide(String path, {Map<String, dynamic>? data, required String done}) async {
    final ar = _isArabic(context);
    setState(() => _busy = true);
    try {
      await _api.post<Object>(path, data: data ?? const {});
      if (!mounted) return;
      AppSnackBar.showSuccess(context, done);
      Navigator.of(context).pop(true);
    } on Object catch (error) {
      debugPrint('Wasalny decision failed: $error');
      if (mounted) {
        AppSnackBar.showError(context, _serverMessage(error, ar ? 'تعذر تنفيذ القرار، حاول مرة أخرى.' : 'Could not complete the action.'));
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _approve() => _decide(
    ApiEndpoints.wasalnyRequestApprove(widget.requestId),
    done: _isArabic(context) ? 'تم اعتماد الطلب وفتح المحادثة' : 'Approved — the chat is open',
  );

  Future<void> _reject() async {
    final ar = _isArabic(context);
    final reason = await _askReason(ar ? 'سبب الرفض (يوصل للمشتري)' : 'Rejection reason (sent to the buyer)');
    if (reason == null || !mounted) return;
    await _decide(
      ApiEndpoints.wasalnyRequestReject(widget.requestId),
      data: {'reason': reason},
      done: ar ? 'تم الرفض وإرسال السبب للمشتري' : 'Rejected — the buyer was told why',
    );
  }

  Future<void> _freeze() async {
    final ar = _isArabic(context);
    final reason = await _askReason(ar ? 'سبب التجميد (يوصل للبائع)' : 'Freeze reason (sent to the seller)');
    if (reason == null || !mounted) return;
    await _decide(
      ApiEndpoints.wasalnyRequestFreeze(widget.requestId),
      data: {'reason': reason},
      done: ar ? 'تم التجميد وإرسال السبب للبائع' : 'Frozen — the seller was told why',
    );
  }

  Future<void> _reopen() => _decide(
    ApiEndpoints.wasalnyRequestReopen(widget.requestId),
    done: _isArabic(context) ? 'رجع الطلب لقيد المراجعة' : 'Back under review',
  );

  void _message(String withRole, String adTitle, int adId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdOwnerChatScreen(
          adId: adId,
          adTitle: adTitle,
          requestId: widget.requestId,
          withRole: withRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ar = _isArabic(context);
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('${ar ? 'طلب وصلني' : 'Wasalny request'} #${widget.requestId}'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _failed || _data == null
            ? Center(
                child: TextButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: Text(ar ? 'تعذر التحميل — إعادة المحاولة' : 'Could not load — retry'),
                ),
              )
            : _content(ar, _data!),
      ),
    );
  }

  Widget _content(bool ar, Map<String, dynamic> d) {
    final status = '${d['status'] ?? 'underReview'}';
    final reason = '${d['reason'] ?? ''}';
    final note = '${d['buyerNote'] ?? ''}';
    final ad = d['ad'] is Map<String, dynamic> ? d['ad'] as Map<String, dynamic> : const <String, dynamic>{};
    final adId = (ad['id'] as num?)?.toInt() ?? 0;
    final adTitle = '${ad['title'] ?? ''}';
    final images = [for (final u in (ad['imageUrls'] as List? ?? const [])) '$u'];
    final buyer = _Person(d['buyer'] is Map<String, dynamic> ? d['buyer'] as Map<String, dynamic> : const {});
    final seller = _Person(d['seller'] is Map<String, dynamic> ? d['seller'] as Map<String, dynamic> : const {});
    final history = [for (final h in (d['history'] as List? ?? const [])) if (h is Map<String, dynamic>) h];
    final price = (ad['price'] as num?)?.toDouble() ?? 0;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Row(children: [_StatusChip(status: status)]),
              if (reason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${ar ? 'السبب' : 'Reason'}: $reason', style: TextStyle(color: AppColors.dangerDark, fontWeight: FontWeight.w700)),
              ],
              const SizedBox(height: 12),
              _Section(
                title: ar ? 'الإعلان' : 'The ad',
                children: [
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            images[i],
                            width: 150,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => SizedBox(width: 150, child: ColoredBox(color: AppColors.surfaceMuted)),
                          ),
                        ),
                      ),
                    ),
                  if (images.isNotEmpty) const SizedBox(height: 10),
                  Text(adTitle, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    '${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)} ${ar ? 'ج.م' : 'EGP'}${ad['isNegotiable'] == true ? (ar ? ' • قابل للتفاوض' : ' • negotiable') : ''}',
                    style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800),
                  ),
                  if ('${ad['description'] ?? ''}'.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('${ad['description']}', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    [ad['governorate'], ad['city']].where((e) => '${e ?? ''}'.isNotEmpty).join(' - '),
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Section(
                  title: ar ? 'ملاحظة المشتري' : 'Buyer note',
                  children: [Text(note, style: TextStyle(color: AppColors.textPrimary))],
                ),
              ],
              const SizedBox(height: 12),
              _PersonSection(
                title: ar ? 'بيانات المشتري' : 'Buyer',
                person: buyer,
                onMessage: () => _message('buyer', adTitle, adId),
              ),
              const SizedBox(height: 12),
              _PersonSection(
                title: ar ? 'بيانات البائع' : 'Seller',
                person: seller,
                onMessage: () => _message('seller', adTitle, adId),
              ),
              if (history.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Section(
                  title: ar ? 'سجل القرارات' : 'History',
                  children: [
                    for (final h in history)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• ${h['label'] ?? h['actionKey']}'
                          '${'${h['by'] ?? ''}'.isNotEmpty ? ' — ${h['by']}' : ''}'
                          '${'${h['reason'] ?? ''}'.isNotEmpty ? ': ${h['reason']}' : ''}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        _actions(ar, status),
      ],
    );
  }

  Widget _actions(bool ar, String status) {
    if (_busy) {
      return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
    }
    final underReview = status == 'underReview';
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.cardBorder))),
        child: underReview
            ? Row(
                children: [
                  Expanded(child: FilledButton(onPressed: _approve, child: Text(ar ? 'اعتماد' : 'Approve'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: _freeze, child: Text(ar ? 'تجميد' : 'Freeze'))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reject,
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                      child: Text(ar ? 'رفض' : 'Reject'),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _reopen,
                  icon: const Icon(Icons.undo_rounded),
                  label: Text(ar ? 'إعادة المراجعة' : 'Review again'),
                ),
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(height: 10),
        ...children,
      ],
    ),
  );
}

class _PersonSection extends StatelessWidget {
  const _PersonSection({required this.title, required this.person, required this.onMessage});

  final String title;
  final _Person person;
  final VoidCallback onMessage;

  Widget _row(BuildContext context, IconData icon, String value, {bool copy = false}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: copy
            ? () {
                Clipboard.setData(ClipboardData(text: value));
                AppSnackBar.showInfo(context, _isArabic(context) ? 'تم النسخ' : 'Copied');
              }
            : null,
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: SelectableText(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
            if (copy) Icon(Icons.copy_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ar = _isArabic(context);
    final place = [person.governorate, person.city].where((e) => e.isNotEmpty).join(' - ');
    return _Section(
      title: title,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceMuted,
              backgroundImage: person.imageUrl.isEmpty ? null : NetworkImage(person.imageUrl),
              child: person.imageUrl.isEmpty ? Icon(Icons.person_outline, color: AppColors.textSecondary) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(person.name, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
            ),
            if (person.isVerified) Icon(Icons.verified_rounded, size: 18, color: AppColors.success),
          ],
        ),
        const SizedBox(height: 8),
        _row(context, Icons.phone_outlined, person.phone, copy: true),
        _row(context, Icons.email_outlined, person.email, copy: true),
        _row(context, Icons.place_outlined, place),
        _row(context, Icons.home_outlined, person.address),
        if (person.rating > 0) _row(context, Icons.star_outline_rounded, person.rating.toStringAsFixed(1)),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: onMessage,
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: Text(ar ? 'مراسلة' : 'Message'),
          ),
        ),
      ],
    );
  }
}
