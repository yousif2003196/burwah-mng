import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/supervisor_escalations_api.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_api.dart';

/// تصعيدات مشرف التجار لرئيس المشرفين (من السيرفر): تصعيد جديد عن تاجر أو مشكلة،
/// ومتابعة قرار الرئيس على كل تصعيد.
class MerchantServerEscalationsScreen extends StatefulWidget {
  const MerchantServerEscalationsScreen({super.key});

  @override
  State<MerchantServerEscalationsScreen> createState() => _MerchantServerEscalationsScreenState();
}

enum _Filter { all, pending, returned, decided }

class _MerchantServerEscalationsScreenState extends State<MerchantServerEscalationsScreen> {
  List<SupervisorEscalationRecord> _rows = const [];
  bool _loading = true;
  String? _error;
  _Filter _filter = _Filter.all;

  SupervisorEscalationsApi get _api => sl<SupervisorEscalationsApi>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await _api.mine();
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
        _error = null;
      });
    } on SupervisorEscalationRejection catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل التصعيدات. اسحب للتحديث.';
      });
    }
  }

  bool _match(SupervisorEscalationRecord r) => _matches(r, _filter);

  static bool _matches(SupervisorEscalationRecord r, _Filter filter) => switch (filter) {
        _Filter.all => true,
        _Filter.pending => r.pending,
        _Filter.returned => r.status == 2,
        _Filter.decided => r.status == 1 || r.status == 3,
      };

  Future<void> _create() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _NewEscalationSheet(),
    );
    if (created == true) {
      setState(() => _loading = true);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _rows.where(_match).toList();
    int count(_Filter f) => _rows.where((r) => _matches(r, f)).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          centerTitle: true,
          title: const Text('تصعيداتي لرئيس المشرفين', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _create,
          icon: const Icon(Icons.campaign_outlined),
          label: const Text('تصعيد جديد'),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                children: [
                  for (final f in _Filter.values)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: ChoiceChip(
                        label: Text('${switch (f) {
                          _Filter.all => 'الكل',
                          _Filter.pending => 'عند الرئيس',
                          _Filter.returned => 'رجعتلي',
                          _Filter.decided => 'اتحسمت',
                        }} (${count(f)})'),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: BrandRefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                  children: [
                    if (_loading)
                      const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                    else if (_error != null)
                      Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center))
                    else if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(children: [
                          Icon(Icons.inbox_outlined, size: 42, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          Text(_rows.isEmpty ? 'لسه مصعّدتش حاجة لرئيس المشرفين' : 'مفيش تصعيدات هنا',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ]),
                      )
                    else
                      for (final r in visible) ...[
                        ScrollFx(child: _EscalationCard(record: r)),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EscalationCard extends StatelessWidget {
  const _EscalationCard({required this.record});

  final SupervisorEscalationRecord record;

  static String _stamp(DateTime? d) {
    if (d == null) return '';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}/${two(d.month)}/${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (record.status) {
      1 => (AppColors.successDark, AppColors.successLight),
      2 => (AppColors.warningDark, AppColors.warningLight),
      3 => (AppColors.dangerDark, AppColors.dangerLight),
      _ => (AppColors.infoDark, AppColors.infoLight),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: record.status == 2 ? AppColors.warningDark : AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(record.title,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
                child: Text(record.statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('السبب: ${record.reason}', style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('${record.refKey} • ${_stamp(record.createdAt)}', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          if (!record.pending) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Text(
                'قرار رئيس المشرفين${record.decidedAt == null ? '' : ' (${_stamp(record.decidedAt)})'}: '
                '${record.decisionNote.isEmpty ? record.statusText : record.decisionNote}',
                style: TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w700, color: fg),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// تصعيد جديد: النوع، والتاجر (اختياري)، والعنوان والسبب.
class _NewEscalationSheet extends StatefulWidget {
  const _NewEscalationSheet();

  @override
  State<_NewEscalationSheet> createState() => _NewEscalationSheetState();
}

class _NewEscalationSheetState extends State<_NewEscalationSheet> {
  static const _kinds = <(String, String)>[
    ('complaint', 'شكوى عميل'),
    ('violation', 'مخالفة تاجر'),
    ('payment', 'مشكلة مالية'),
    ('unblock', 'طلب رفع إيقاف'),
    ('other', 'أخرى'),
  ];

  String _kind = 'complaint';
  final _title = TextEditingController();
  final _reason = TextEditingController();
  List<Map<String, dynamic>> _merchants = const [];
  Map<String, dynamic>? _merchant;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    MerchantsApi.merchants(pageSize: 100).then((rows) {
      if (mounted) setState(() => _merchants = rows);
    }).catchError((Object _) {});
  }

  @override
  void dispose() {
    _title.dispose();
    _reason.dispose();
    super.dispose();
  }

  String _merchantName(Map<String, dynamic> m) => '${m['storeName'] ?? m['ownerName'] ?? ''}'.trim();

  Future<void> _send() async {
    final title = _title.text.trim();
    final reason = _reason.text.trim();
    if (title.isEmpty || reason.isEmpty) {
      setState(() => _error = 'اكتب العنوان والسبب');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final kindLabel = _kinds.firstWhere((k) => k.$1 == _kind).$2;
    final merchant = _merchant;
    try {
      await sl<SupervisorEscalationsApi>().create(
        kind: _kind,
        refKey: merchant == null ? 'MRC-GEN-${DateTime.now().millisecondsSinceEpoch}' : 'MER-${merchant['id']}',
        title: '$kindLabel: $title${merchant == null ? '' : ' — التاجر: ${_merchantName(merchant)}'}',
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اتصعّد لرئيس المشرفين ووصله إشعار')));
      Navigator.of(context).pop(true);
    } on SupervisorEscalationRejection catch (e) {
      if (mounted) setState(() {
        _sending = false;
        _error = e.message;
      });
    } on Object {
      if (mounted) setState(() {
        _sending = false;
        _error = 'تعذر إرسال التصعيد، حاول تاني';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تصعيد جديد لرئيس المشرفين',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in _kinds)
                    ChoiceChip(
                      label: Text(k.$2),
                      selected: _kind == k.$1,
                      onSelected: (_) => setState(() => _kind = k.$1),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _merchant == null ? null : (_merchant!['id'] as num?)?.toInt(),
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'التاجر (اختياري)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('بدون تاجر محدد')),
                  for (final m in _merchants)
                    DropdownMenuItem<int?>(
                      value: (m['id'] as num?)?.toInt(),
                      child: Text(_merchantName(m), overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (id) => setState(() {
                  _merchant = id == null ? null : _merchants.firstWhere((m) => (m['id'] as num?)?.toInt() == id);
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                maxLength: 120,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              TextField(
                controller: _reason,
                minLines: 3,
                maxLines: 6,
                maxLength: 900,
                decoration: InputDecoration(
                  labelText: 'السبب والتفاصيل',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: TextStyle(color: AppColors.dangerDark, fontSize: 12)),
                ),
              FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_outlined),
                label: const Text('إرسال لرئيس المشرفين'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زرار التصعيدات في رئيسية مشرف التجار، وعليه عدد اللي عند الرئيس واللي رجعتله.
class MerchantServerEscalationsButton extends StatefulWidget {
  const MerchantServerEscalationsButton({super.key});

  @override
  State<MerchantServerEscalationsButton> createState() => _MerchantServerEscalationsButtonState();
}

class _MerchantServerEscalationsButtonState extends State<MerchantServerEscalationsButton> {
  int _pending = 0;
  int _returned = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await sl<SupervisorEscalationsApi>().mine();
      if (!mounted) return;
      setState(() {
        _pending = rows.where((r) => r.pending).length;
        _returned = rows.where((r) => r.status == 2).length;
      });
    } on Object catch (error) {
      debugPrint('Merchant escalations count unavailable: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _returned > 0
        ? '$_returned رجعتلك من الرئيس • $_pending عنده'
        : _pending > 0
            ? '$_pending تصعيد بانتظار قرار رئيس المشرفين'
            : 'صعّد مشكلة تاجر لرئيس المشرفين وتابع قراره';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const MerchantServerEscalationsScreen()),
          );
          if (mounted) await _load();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _returned > 0 ? AppColors.warningDark : AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.campaign_outlined, color: AppColors.warningDark, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التصعيدات لرئيس المشرفين',
                        style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              if (_returned + _pending > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _returned > 0 ? AppColors.danger : AppColors.infoDark,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('${_returned > 0 ? _returned : _pending}',
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
