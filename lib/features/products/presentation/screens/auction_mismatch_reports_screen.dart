import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';

/// بلاغات المزادات: الفائز بلّغ إن المنتج غير مطابق للإعلان. المشرف يراجع شات الصفقة
/// ويؤكد البلاغ (يتجمد حساب البائع ويرجع تأمين الفائز) أو يتجاهله.
class AuctionMismatchReportsScreen extends StatefulWidget {
  const AuctionMismatchReportsScreen({super.key, this.openAuctionId, this.embedded = false});

  /// جوه تبويب "الشكاوى" (من غير شريط علوي خاص، ومسافة تحت للشريط السفلي).
  final bool embedded;

  /// من الإشعار: يفتح تفاصيل البلاغ ده أول ما الشاشة تتحمل.
  final int? openAuctionId;

  @override
  State<AuctionMismatchReportsScreen> createState() =>
      _AuctionMismatchReportsScreenState();
}

class _Report {
  _Report(Map<String, dynamic> j)
      : id = (j['id'] as num).toInt(),
        title = '${j['title'] ?? ''}',
        sellerName = '${j['sellerName'] ?? '—'}',
        winnerName = '${j['winnerName'] ?? '—'}',
        amount = (j['winningAmount'] as num?)?.toDouble(),
        reportedAt = DateTime.tryParse('${j['reportedAt'] ?? ''}')?.toLocal(),
        status = '${j['status'] ?? 'pending'}',
        messages = [
          for (final m in (j['messages'] as List? ?? const []))
            if (m is Map)
              (
                fromSeller: m['from'] == 'seller',
                name: '${m['fromName'] ?? ''}',
                text: '${m['text'] ?? ''}',
              ),
        ];

  final int id;
  final String title;
  final String sellerName;
  final String winnerName;
  final double? amount;
  final DateTime? reportedAt;
  final String status;
  final List<({bool fromSeller, String name, String text})> messages;

  bool get pending => status == 'pending';
}

class _AuctionMismatchReportsScreenState
    extends State<AuctionMismatchReportsScreen> {
  final ApiConsumer _api = sl<ApiConsumer>(instanceName: 'berwah');
  List<_Report> _reports = const [];
  bool _loading = true;
  bool _failed = false;
  bool _showDone = false;
  bool _openedRequested = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await _api.get<Object>(
        'api/Auctions/mismatch-reports',
        queryParameters: {'status': _showDone ? 'done' : 'pending'},
      );
      final body = response.data;
      final data = body is Map ? body['data'] : body;
      final list = [
        for (final e in (data as List? ?? const []))
          if (e is Map) _Report(Map<String, dynamic>.from(e)),
      ];
      if (!mounted) return;
      setState(() {
        _reports = list;
        _loading = false;
        _failed = false;
      });
      final wanted = widget.openAuctionId;
      if (wanted != null && !_openedRequested) {
        _openedRequested = true;
        final hit = list.where((r) => r.id == wanted);
        if (hit.isNotEmpty) _open(hit.first);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = _reports.isEmpty;
      });
    }
  }

  Future<void> _decide(_Report r, {required bool confirm}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(confirm ? 'تأكيد البلاغ؟' : 'تجاهل البلاغ؟'),
          content: Text(confirm
              ? 'هيتم إيقاف حساب البائع نهائيًا (${r.sellerName}) ورد تأمين الفائز لمحفظته. القرار ده مش بيتراجع فيه.'
              : 'هيتقفل البلاغ من غير أي إجراء على حساب البائع أو الفائز، وهيتبلغوا الاتنين.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('رجوع'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirm ? 'أيوه، أكّد' : 'أيوه، تجاهل'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await _api.post<Object>(
        'api/Auctions/${r.id}/${confirm ? 'confirm-mismatch' : 'dismiss-mismatch'}',
      );
      if (!mounted) return;
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(confirm ? 'تم تأكيد البلاغ' : 'تم تجاهل البلاغ')),
      );
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تعذر تنفيذ القرار، ممكن البلاغ اتراجع قبل كده')),
      );
      await _load();
    }
  }

  void _open(_Report r) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (_, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.all(20),
            children: [
              Text(r.title,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 6),
              Text('مزاد #${r.id}${r.amount == null ? '' : ' · سعر الرسو ${r.amount!.toStringAsFixed(r.amount! == r.amount!.roundToDouble() ? 0 : 2)} ج.م'}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 4),
              Text('البائع: ${r.sellerName}',
                  style: TextStyle(color: AppColors.textSecondary)),
              Text('الفائز (المُبلِّغ): ${r.winnerName}',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              Text('شات الصفقة',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (r.messages.isEmpty)
                Text('لا توجد رسائل في الشات',
                    style: TextStyle(color: AppColors.textMuted))
              else
                for (final m in r.messages)
                  Align(
                    alignment: m.fromSeller
                        ? AlignmentDirectional.centerStart
                        : AlignmentDirectional.centerEnd,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: AppColors.scaffold,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m.fromSeller ? 'البائع' : 'الفائز'} · ${m.name}',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 10),
                          ),
                          const SizedBox(height: 2),
                          Text(m.text,
                              style: TextStyle(
                                  color: AppColors.textPrimary, height: 1.4)),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              if (r.pending) ...[
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700),
                  onPressed: () => _decide(r, confirm: true),
                  child: const Text('تأكيد: المنتج غير مطابق وإيقاف البائع'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _decide(r, confirm: false),
                  child: const Text('تجاهل البلاغ'),
                ),
              ] else
                Text(
                  r.status == 'confirmed'
                      ? 'تم تأكيد البلاغ وإيقاف البائع'
                      : 'تم تجاهل البلاغ',
                  style: TextStyle(color: AppColors.textMuted),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: widget.embedded ? Colors.transparent : AppColors.scaffold,
        appBar: widget.embedded
            ? null
            : AppBar(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.ink,
                title: const Text('بلاغات المزادات'),
              ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('بانتظار القرار')),
                  ButtonSegment(value: true, label: Text('تمت مراجعتها')),
                ],
                selected: {_showDone},
                onSelectionChanged: (s) {
                  setState(() {
                    _showDone = s.first;
                    _loading = true;
                  });
                  _load();
                },
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _failed
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('تعذر تحميل البلاغات'),
                              const SizedBox(height: 10),
                              FilledButton(
                                onPressed: () {
                                  setState(() => _loading = true);
                                  _load();
                                },
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        )
                      : BrandRefreshIndicator(
                          onRefresh: _load,
                          child: _reports.isEmpty
                              ? ListView(children: const [
                                  SizedBox(height: 120),
                                  Center(child: Text('لا توجد بلاغات هنا')),
                                ])
                              : ListView.separated(
                                  padding: EdgeInsets.fromLTRB(16, 16, 16, widget.embedded ? 120 : 16),
                                  itemCount: _reports.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (_, i) {
                                    final r = _reports[i];
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () => _open(r),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                              color: AppColors.cardBorder),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(r.title,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(
                                              'البائع: ${r.sellerName} · الفائز: ${r.winnerName}',
                                              style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '#${r.id} · ${r.reportedAt?.toString().substring(0, 16) ?? ''}',
                                              style: TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
