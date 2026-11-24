import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

String _serverMessage(Object error, String fallback) {
  if (error is DioException) {
    final body = error.response?.data;
    final message = body is Map ? '${body['message'] ?? ''}'.trim() : '';
    if (message.isNotEmpty) return message;
  }
  return fallback;
}

DateTime? _date(Object? raw) {
  final t = '${raw ?? ''}'.trim();
  if (t.isEmpty || t == 'null') return null;
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

String _stamp(DateTime? d) {
  if (d == null) return '—';
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} • $h:$m ${d.hour < 12 ? 'ص' : 'م'}';
}

/// طلب واحد من مقدم خدمة جديد (من السيرفر).
class ProviderApplicationItem {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? governorate;
  final String? city;
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? selfieUrl;
  final List<String> services;

  /// pending | approved | rejected | suspended
  final String status;
  final String? reason;
  final int attempts;
  final DateTime? submittedAt;
  final DateTime? joinedAt;
  final DateTime? decidedAt;
  final String? decidedBy;

  const ProviderApplicationItem({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.governorate,
    this.city,
    this.idFrontUrl,
    this.idBackUrl,
    this.selfieUrl,
    this.services = const [],
    required this.status,
    this.reason,
    this.attempts = 1,
    this.submittedAt,
    this.joinedAt,
    this.decidedAt,
    this.decidedBy,
  });

  static String? _s(Object? v) {
    final t = '${v ?? ''}'.trim();
    return t.isEmpty || t == 'null' ? null : t;
  }

  factory ProviderApplicationItem.fromJson(Map json) => ProviderApplicationItem(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        name: _s(json['name']) ?? '—',
        phone: _s(json['phone']),
        email: _s(json['email']),
        governorate: _s(json['governorate']),
        city: _s(json['city']),
        idFrontUrl: _s(json['idFrontUrl']),
        idBackUrl: _s(json['idBackUrl']),
        selfieUrl: _s(json['selfieUrl']),
        services: (json['services'] as List?)?.map((e) => '$e').where((e) => e.trim().isNotEmpty).toList() ?? const [],
        status: _s(json['status']) ?? 'pending',
        reason: _s(json['reason']),
        attempts: json['attempts'] is int ? json['attempts'] as int : 1,
        submittedAt: _date(json['submittedAt']),
        joinedAt: _date(json['joinedAt']),
        decidedAt: _date(json['decidedAt']),
        decidedBy: _s(json['decidedBy']),
      );

  bool get isPending => status == 'pending';
  String get place => [city, governorate].whereType<String>().join('، ');
}

abstract class ProviderApplicationsApi {
  static Future<int> pendingCount() async {
    final r = await _api.get<Object>(ApiEndpoints.serviceProviderApplicationsPendingCount);
    final body = r.data;
    return body is Map && body['count'] is int ? body['count'] as int : 0;
  }

  static Future<({List<ProviderApplicationItem> items, int total, int pending, int archive})> list({
    required bool archive,
    int page = 1,
    int pageSize = 30,
  }) async {
    final r = await _api.get<Object>(
      ApiEndpoints.serviceProviderApplications,
      queryParameters: {'tab': archive ? 'archive' : 'pending', 'page': page, 'pageSize': pageSize},
    );
    final body = r.data;
    if (body is! Map) throw const FormatException('bad applications');
    final data = body['data'];
    final counts = body['counts'];
    return (
      items: data is List ? data.whereType<Map>().map(ProviderApplicationItem.fromJson).toList() : <ProviderApplicationItem>[],
      total: body['total'] is int ? body['total'] as int : 0,
      pending: counts is Map && counts['pending'] is int ? counts['pending'] as int : 0,
      archive: counts is Map && counts['archive'] is int ? counts['archive'] as int : 0,
    );
  }

  static Future<ProviderApplicationItem> details(int id) async {
    final r = await _api.get<Object>(ApiEndpoints.serviceProviderApplication(id));
    final body = r.data;
    final data = body is Map ? body['data'] : null;
    if (data is! Map) throw const FormatException('bad application');
    return ProviderApplicationItem.fromJson(data);
  }

  static Future<String> decide(int id, String decision, String? reason) async {
    final r = await _api.post<Object>(
      ApiEndpoints.serviceProviderApplicationDecision(id),
      data: {'decision': decision, 'reason': reason},
    );
    final body = r.data;
    return body is Map ? '${body['message'] ?? ''}' : '';
  }

  static Future<String> reopen(int id) async {
    final r = await _api.post<Object>(ApiEndpoints.serviceProviderApplicationReopen(id), data: const {});
    final body = r.data;
    return body is Map ? '${body['message'] ?? ''}' : '';
  }
}

// ─────────────────────────── زرار تبويب مقدمو الخدمة ───────────────────────────

/// زرار "طلبات مقدمي الخدمة" فوق قايمة مقدمي الخدمة، وعليه عدد اللي قيد المراجعة.
class ProviderApplicationsEntry extends StatefulWidget {
  const ProviderApplicationsEntry({super.key, this.onChanged});

  /// بعد الرجوع من الصفحة (ممكن يكون اتقبل مزود جديد).
  final VoidCallback? onChanged;

  @override
  State<ProviderApplicationsEntry> createState() => _ProviderApplicationsEntryState();
}

class _ProviderApplicationsEntryState extends State<ProviderApplicationsEntry> {
  int? _pending;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final count = await ProviderApplicationsApi.pendingCount();
      if (mounted) setState(() => _pending = count);
    } on Object catch (error) {
      debugPrint('Provider applications count unavailable: $error');
    }
  }

  Future<void> _open() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProviderApplicationsScreen()));
    if (!mounted) return;
    await _load();
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _pending ?? 0;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _open,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: pending > 0 ? AppColors.infoDark.withValues(alpha: 0.45) : AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.person_add_alt_1_outlined, color: AppColors.infoDark, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('طلبات مقدمي الخدمة',
                        style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      _pending == null
                          ? 'الطلبات المقدمة من مقدمي الخدمة الجدد'
                          : pending == 0
                              ? 'مفيش طلبات جديدة دلوقتي'
                              : '$pending طلب في انتظار قرارك',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (pending > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(99)),
                  child: Text('$pending',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── الصفحة ───────────────────────────

/// قيد المراجعة (أي حد بيقدّم) والأرشيف (أي قرار اتاخد، ومنه إعادة مراجعة القرار).
class ProviderApplicationsScreen extends StatefulWidget {
  const ProviderApplicationsScreen({super.key, this.initialArchive = false});

  final bool initialArchive;

  @override
  State<ProviderApplicationsScreen> createState() => _ProviderApplicationsScreenState();
}

class _ProviderApplicationsScreenState extends State<ProviderApplicationsScreen> {
  static const _pageSize = 30;

  late bool _archive = widget.initialArchive;
  final Map<bool, List<ProviderApplicationItem>> _items = {false: [], true: []};
  final Map<bool, int> _total = {false: 0, true: 0};
  final Map<bool, int> _page = {false: 0, true: 0};
  final Map<bool, bool> _loaded = {false: false, true: false};
  int _pendingCount = 0;
  int _archiveCount = 0;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload({bool? tab}) async {
    final archive = tab ?? _archive;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await ProviderApplicationsApi.list(archive: archive, page: 1, pageSize: _pageSize);
      if (!mounted) return;
      setState(() {
        _items[archive] = r.items;
        _total[archive] = r.total;
        _page[archive] = 1;
        _loaded[archive] = true;
        _pendingCount = r.pending;
        _archiveCount = r.archive;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _serverMessage(error, 'تعذر تحميل الطلبات. اسحب للتحديث.');
      });
    }
  }

  Future<void> _loadMore() async {
    final archive = _archive;
    if (_loadingMore || _items[archive]!.length >= _total[archive]!) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page[archive]! + 1;
      final r = await ProviderApplicationsApi.list(archive: archive, page: next, pageSize: _pageSize);
      if (!mounted) return;
      setState(() {
        _items[archive] = [..._items[archive]!, ...r.items];
        _page[archive] = next;
        _total[archive] = r.total;
        _loadingMore = false;
      });
    } on Object {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _switchTab(bool archive) {
    if (archive == _archive) return;
    setState(() => _archive = archive);
    if (!_loaded[archive]!) _reload(tab: archive);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  /// بعد أي قرار: الطلب بيتشال من القايمة الحالية والتبويبين بيتحدّثوا.
  Future<void> _afterChange(int id) async {
    setState(() {
      _items[_archive]!.removeWhere((e) => e.id == id);
      _loaded[!_archive] = false;
    });
    await _reload();
  }

  Future<void> _decide(ProviderApplicationItem item, String decision) async {
    final reason = await askProviderDecision(context, item, decision);
    if (reason == null || !mounted) return;
    setState(() => _busy.add(item.id));
    try {
      final message = await ProviderApplicationsApi.decide(item.id, decision, reason.isEmpty ? null : reason);
      if (!mounted) return;
      _toast(message.isEmpty ? 'تم تسجيل القرار' : message);
      await _afterChange(item.id);
    } on Object catch (error) {
      if (mounted) _toast(_serverMessage(error, 'تعذر تسجيل القرار'));
    }
    if (mounted) setState(() => _busy.remove(item.id));
  }

  Future<void> _reopen(ProviderApplicationItem item) async {
    final ok = await confirmProviderReopen(context, item);
    if (ok != true || !mounted) return;
    setState(() => _busy.add(item.id));
    try {
      final message = await ProviderApplicationsApi.reopen(item.id);
      if (!mounted) return;
      _toast(message.isEmpty ? 'الطلب رجع لقيد المراجعة' : message);
      await _afterChange(item.id);
    } on Object catch (error) {
      if (mounted) _toast(_serverMessage(error, 'تعذر إعادة الطلب للمراجعة'));
    }
    if (mounted) setState(() => _busy.remove(item.id));
  }

  Future<void> _openDetails(ProviderApplicationItem item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _ApplicationDetailsScreen(id: item.id, initial: item)),
    );
    if (changed == true && mounted) await _afterChange(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items[_archive]!;
    final hasMore = items.length < _total[_archive]!;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        title: const Text('طلبات مقدمي الخدمة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _Segments(
              archive: _archive,
              pending: _pendingCount,
              archived: _archiveCount,
              onChanged: _switchTab,
            ),
          ),
          Expanded(
            child: BrandRefreshIndicator(
              onRefresh: _reload,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels > n.metrics.maxScrollExtent - 300) _loadMore();
                  return false;
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  children: [
                    if (_loading && items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null && items.isEmpty)
                      _Empty(icon: Icons.cloud_off_outlined, text: _error!)
                    else if (items.isEmpty)
                      _Empty(
                        icon: _archive ? Icons.inventory_2_outlined : Icons.task_alt_rounded,
                        text: _archive ? 'لسه مفيش قرارات في الأرشيف' : 'مفيش طلبات قيد المراجعة دلوقتي',
                      )
                    else ...[
                      for (final item in items) ...[
                        ScrollFx(
                          child: _ApplicationCard(
                            item: item,
                            busy: _busy.contains(item.id),
                            onOpen: () => _openDetails(item),
                            onDecide: (d) => _decide(item, d),
                            onReopen: () => _reopen(item),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (hasMore)
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
      ),
    );
  }
}

class _Segments extends StatelessWidget {
  const _Segments({required this.archive, required this.pending, required this.archived, required this.onChanged});

  final bool archive;
  final int pending;
  final int archived;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, int count, bool value, {bool alert = false}) {
      final selected = archive == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppColors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
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
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          seg('قيد المراجعة', pending, false, alert: true),
          const SizedBox(width: 3),
          seg('الأرشيف', archived, true),
        ],
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

({String label, Color fg, Color bg}) _statusLook(String status) => switch (status) {
      'approved' => (label: 'مقبول', fg: AppColors.successDark, bg: AppColors.successLight),
      'rejected' => (label: 'مرفوض', fg: AppColors.dangerDark, bg: AppColors.dangerLight),
      'suspended' => (label: 'معلّق', fg: AppColors.warningDark, bg: AppColors.warningLight),
      _ => (label: 'قيد المراجعة', fg: AppColors.infoDark, bg: AppColors.infoLight),
    };

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    final look = _statusLook(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: look.bg, borderRadius: BorderRadius.circular(99)),
      child: Text(look.label, style: TextStyle(color: look.fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name, this.size = 44});

  final String? url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty ? '؟' : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w.characters.first).join();
    final fallback = Center(
      child: Text(initials, style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: size * 0.3)),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceHighlight),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? fallback
          : Image.network(url!, fit: BoxFit.cover, errorBuilder: (context, error, stack) => fallback),
    );
  }
}

/// صورة (بطاقة / سيلفي) بتتفتح كبيرة بالضغط.
class _DocThumb extends StatelessWidget {
  const _DocThumb({required this.label, required this.url, required this.icon, this.height = 64});

  final String label;
  final String? url;
  final IconData icon;
  final double height;

  void _open(BuildContext context) {
    if (url == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(label, style: const TextStyle(fontSize: 15)),
        ),
        body: Center(child: InteractiveViewer(maxScale: 5, child: Image.network(url!, fit: BoxFit.contain))),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _open(context),
      child: Container(
        height: height,
        decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: url == null
            ? placeholder
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(url!, fit: BoxFit.cover, errorBuilder: (context, error, stack) => placeholder),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black45,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ServiceChips extends StatelessWidget {
  const _ServiceChips(this.services);

  final List<String> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text('—', style: TextStyle(color: AppColors.textSecondary, fontSize: 11));
    }
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final s in services)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(99)),
            child: Text(s, style: TextStyle(color: AppColors.infoDark, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _DecisionButtons extends StatelessWidget {
  const _DecisionButtons({required this.busy, required this.onDecide});

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
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () => onDecide('approve'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.successDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text('قبول', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 6),
        outlined('تعليق', AppColors.warningDark, 'suspend'),
        const SizedBox(width: 6),
        outlined('رفض', AppColors.dangerDark, 'reject'),
      ],
    );
  }
}

class _ReopenButton extends StatelessWidget {
  const _ReopenButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.infoDark,
          side: BorderSide(color: AppColors.cardBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        icon: busy
            ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('إعادة مراجعة القرار', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.item,
    required this.busy,
    required this.onOpen,
    required this.onDecide,
    required this.onReopen,
  });

  final ProviderApplicationItem item;
  final bool busy;
  final VoidCallback onOpen;
  final ValueChanged<String> onDecide;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (item.phone != null) item.phone!,
      if (item.place.isNotEmpty) item.place,
      _ago(item.submittedAt),
    ].join(' • ');
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
                children: [
                  _Avatar(url: item.selfieUrl, name: item.name),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  if (item.isPending && item.attempts > 1)
                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(99)),
                      child: Text('إعادة تقديم (${item.attempts})',
                          style: TextStyle(color: AppColors.warningDark, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  else if (!item.isPending)
                    _StatusPill(item.status),
                ],
              ),
              if (item.isPending) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _DocThumb(label: 'البطاقة وش', url: item.idFrontUrl, icon: Icons.badge_outlined)),
                    const SizedBox(width: 6),
                    Expanded(child: _DocThumb(label: 'البطاقة ضهر', url: item.idBackUrl, icon: Icons.credit_card)),
                    const SizedBox(width: 6),
                    Expanded(child: _DocThumb(label: 'سيلفي', url: item.selfieUrl, icon: Icons.photo_camera_front_outlined)),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              _ServiceChips(item.services),
              if (!item.isPending) ...[
                const SizedBox(height: 8),
                if (item.reason != null)
                  Text('السبب: ${item.reason}',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  'القرار: ${_stamp(item.decidedAt)}${item.decidedBy == null ? '' : ' • ${item.decidedBy}'}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
              const SizedBox(height: 10),
              item.isPending
                  ? _DecisionButtons(busy: busy, onDecide: onDecide)
                  : _ReopenButton(busy: busy, onTap: onReopen),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── الحوارات ───────────────────────────

/// القبول بتأكيد؛ الرفض والتعليق بسبب إجباري. يرجّع السبب ('' للقبول) أو null لو اتلغى.
Future<String?> askProviderDecision(BuildContext context, ProviderApplicationItem item, String decision) async {
  if (decision == 'approve') {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('قبول مقدم الخدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text('هيتفعّل ${item.name} كمقدم خدمة ويقدر يقدّم عروض على الخدمات اللي اختارها. متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.successDark),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: const Text('قبول'),
          ),
        ],
      ),
    );
    return ok == true ? '' : null;
  }

  final suspend = decision == 'suspend';
  final controller = TextEditingController();
  final presets = suspend
      ? const ['صورة البطاقة مش واضحة', 'الصورة الشخصية مش واضحة', 'البيانات مش مكتملة']
      : const ['البطاقة مش مطابقة للصورة الشخصية', 'بيانات غير صحيحة', 'حساب مكرر'];
  final reason = await showDialog<String>(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (dialog, setLocal) => AlertDialog(
        title: Text(suspend ? 'تعليق الطلب' : 'رفض الطلب',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                suspend
                    ? 'اكتب المطلوب من ${item.name} علشان يكمّله ويبعت الطلب تاني.'
                    : 'اكتب سبب الرفض، هيوصل لـ ${item.name} ويقدر يقدّم تاني.',
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
                  hintText: suspend ? 'المطلوب منه' : 'سبب الرفض',
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

Future<bool?> confirmProviderReopen(BuildContext context, ProviderApplicationItem item) {
  return showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('إعادة مراجعة القرار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      content: Text(
        item.status == 'approved'
            ? 'الطلب هيرجع لقيد المراجعة، و${item.name} هيتوقف كمقدم خدمة لحد قرارك الجديد.'
            : 'الطلب هيرجع لقيد المراجعة علشان تاخد فيه قرار جديد.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: const Text('إلغاء')),
        FilledButton(onPressed: () => Navigator.of(dialog).pop(true), child: const Text('إعادة للمراجعة')),
      ],
    ),
  );
}

// ─────────────────────────── تفاصيل طلب ───────────────────────────

class _ApplicationDetailsScreen extends StatefulWidget {
  const _ApplicationDetailsScreen({required this.id, required this.initial});

  final int id;
  final ProviderApplicationItem initial;

  @override
  State<_ApplicationDetailsScreen> createState() => _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<_ApplicationDetailsScreen> {
  late ProviderApplicationItem _item = widget.initial;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// فتح التفاصيل بيسجّل بداية وقت المراجعة على السيرفر.
  Future<void> _load() async {
    try {
      final item = await ProviderApplicationsApi.details(widget.id);
      if (mounted) setState(() => _item = item);
    } on Object catch (error) {
      debugPrint('Provider application details unavailable: $error');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _decide(String decision) async {
    final reason = await askProviderDecision(context, _item, decision);
    if (reason == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final message = await ProviderApplicationsApi.decide(_item.id, decision, reason.isEmpty ? null : reason);
      if (!mounted) return;
      _toast(message.isEmpty ? 'تم تسجيل القرار' : message);
      Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(_serverMessage(error, 'تعذر تسجيل القرار'));
    }
  }

  Future<void> _reopen() async {
    final ok = await confirmProviderReopen(context, _item);
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final message = await ProviderApplicationsApi.reopen(_item.id);
      if (!mounted) return;
      _toast(message.isEmpty ? 'الطلب رجع لقيد المراجعة' : message);
      Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(_serverMessage(error, 'تعذر إعادة الطلب للمراجعة'));
    }
  }

  Widget _row(IconData icon, String label, String? value, {bool copy = false}) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(width: 92, child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          Expanded(
            child: Text(value, style: TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          if (copy)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                _toast('اتنسخ');
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.copy_rounded, size: 16, color: AppColors.infoDark),
              ),
            ),
        ],
      ),
    );
  }

  Widget _panel(List<Widget> children) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(text, style: TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        title: const Text('طلب مقدم خدمة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: BrandRefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Row(
              children: [
                _Avatar(url: item.selfieUrl, name: item.name, size: 58),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: TextStyle(color: AppColors.ink, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text('قدّم ${_ago(item.submittedAt)}${item.attempts > 1 ? ' • المحاولة رقم ${item.attempts}' : ''}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                _StatusPill(item.status),
              ],
            ),
            _title('الصور'),
            Row(
              children: [
                Expanded(child: _DocThumb(label: 'البطاقة وش', url: item.idFrontUrl, icon: Icons.badge_outlined, height: 110)),
                const SizedBox(width: 8),
                Expanded(child: _DocThumb(label: 'البطاقة ضهر', url: item.idBackUrl, icon: Icons.credit_card, height: 110)),
              ],
            ),
            const SizedBox(height: 8),
            _DocThumb(label: 'الصورة الشخصية (كاميرا)', url: item.selfieUrl, icon: Icons.photo_camera_front_outlined, height: 200),
            _title('الخدمات المختارة'),
            _panel([const SizedBox(height: 6), _ServiceChips(item.services), const SizedBox(height: 6)]),
            _title('بيانات الحساب'),
            _panel([
              _row(Icons.phone_outlined, 'الموبايل', item.phone, copy: true),
              _row(Icons.alternate_email, 'البريد', item.email, copy: true),
              _row(Icons.map_outlined, 'المكان', item.place.isEmpty ? null : item.place),
              _row(Icons.event_available_outlined, 'عضو من', _stamp(item.joinedAt)),
              _row(Icons.schedule_outlined, 'وقت التقديم', _stamp(item.submittedAt)),
            ]),
            if (!item.isPending) ...[
              _title('القرار'),
              _panel([
                _row(Icons.gavel_outlined, 'القرار', _statusLook(item.status).label),
                _row(Icons.notes_outlined, 'السبب', item.reason),
                _row(Icons.person_outline, 'بواسطة', item.decidedBy),
                _row(Icons.schedule_outlined, 'الوقت', _stamp(item.decidedAt)),
              ]),
            ],
            const SizedBox(height: 18),
            item.isPending
                ? _DecisionButtons(busy: _busy, onDecide: _decide)
                : _ReopenButton(busy: _busy, onTap: _reopen),
          ],
        ),
      ),
    );
  }
}
