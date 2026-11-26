import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_merchant_case_sheet.dart';

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

/// توزيع التجار على مشرفي التجار عند رئيس المشرفين:
/// - "من غير مشرف": التجار القدام (شغالين عادي لحد ما يتوزعوا) والجداد اللي مفيش مشرف في منطقتهم (مستنيين موافقتك).
/// - "كل التجار": مشرف كل تاجر، ونقل أي تاجر لمشرف تاني.
class HeadSupervisorMerchantAssignmentScreen extends StatefulWidget {
  const HeadSupervisorMerchantAssignmentScreen({super.key});

  @override
  State<HeadSupervisorMerchantAssignmentScreen> createState() => _HeadSupervisorMerchantAssignmentScreenState();
}

class _HeadSupervisorMerchantAssignmentScreenState extends State<HeadSupervisorMerchantAssignmentScreen> {
  final _search = TextEditingController();
  bool _all = false;
  bool _loading = true;
  String? _error;
  int _unassigned = 0;
  int _waiting = 0;
  List<Map<String, dynamic>> _merchants = [];
  List<Map<String, dynamic>> _supervisors = [];
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _api.get<Object>(
        ApiEndpoints.bossMerchantAssignment,
        queryParameters: {
          'filter': _all ? 'all' : 'unassigned',
          if (_search.text.trim().isNotEmpty) 'q': _search.text.trim(),
        },
      );
      final body = r.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map) throw const FormatException('bad assignment');
      if (!mounted) return;
      setState(() {
        _unassigned = (data['unassignedCount'] as num?)?.toInt() ?? 0;
        _waiting = (data['waitingCount'] as num?)?.toInt() ?? 0;
        _merchants = [
          for (final m in (data['merchants'] as List? ?? const []))
            if (m is Map) Map<String, dynamic>.from(m),
        ];
        _supervisors = [
          for (final s in (data['supervisors'] as List? ?? const []))
            if (s is Map) Map<String, dynamic>.from(s),
        ];
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _serverMessage(error, 'تعذر تحميل التجار. اسحب للتحديث.');
      });
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _submit(Map<String, dynamic> m, {int? supervisorId, bool approve = false}) async {
    final id = (m['id'] as num).toInt();
    setState(() => _busy.add(id));
    try {
      final r = await _api.post<Object>(
        ApiEndpoints.bossAssignMerchant(id),
        data: {'supervisorId': supervisorId, 'approve': approve},
      );
      final body = r.data;
      _toast(body is Map ? '${body['message'] ?? 'تم'}' : 'تم');
      await _load();
    } on Object catch (error) {
      _toast(_serverMessage(error, 'تعذر تنفيذ العملية'));
    }
    if (mounted) setState(() => _busy.remove(id));
  }

  /// اختيار مشرف للتاجر (ولو جديد مستني الموافقة: يتوافق عليه كمان).
  Future<void> _pickSupervisor(Map<String, dynamic> m) async {
    final pending = m['status'] == 'pending';
    final current = (m['supervisorId'] as num?)?.toInt();
    var approve = pending;
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setLocal) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheet).height * 0.75),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
                  child: Text('وزّع «${m['storeName'] ?? 'التاجر'}» على مشرف',
                      style: TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w800)),
                ),
                if (_s(m['place']) != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text('مكان التاجر: ${m['place']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                if (pending)
                  CheckboxListTile(
                    value: approve,
                    onChanged: (v) => setLocal(() => approve = v ?? false),
                    title: const Text('وافق عليه كمان (يشتغل على طول)', style: TextStyle(fontSize: 13)),
                    subtitle: const Text('لو شلت العلامة، المشرف هو اللي هيراجعه ويوافق', style: TextStyle(fontSize: 11)),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                const Divider(height: 1),
                if (_supervisors.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('مفيش مشرفين تجار شغالين دلوقتي',
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final s in _supervisors)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.surfaceHighlight,
                              child: Icon(Icons.person_outline, color: AppColors.textSecondary),
                            ),
                            title: Text('${s['name']}', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              '${s['code']} • ${_s(s['area']) ?? 'المنطقة مش محددة'} • ${s['merchantsCount']} تاجر',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                            ),
                            trailing: (s['id'] as num).toInt() == current
                                ? Icon(Icons.check_circle, color: AppColors.successDark)
                                : null,
                            onTap: () => Navigator.of(sheet).pop((s['id'] as num).toInt()),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    if (picked == current && !approve) return;
    await _submit(m, supervisorId: picked == current ? null : picked, approve: approve);
  }

  /// ملف التاجر: مراجعة قرار مشرفه (إيقاف / رفض) وإلغاؤه أو إيقاف تاجر شغال.
  Future<void> _openCase(Map<String, dynamic> m) async {
    final changed = await showHeadMerchantCaseSheet(
      context,
      merchantId: (m['id'] as num).toInt(),
    );
    if (changed == true && mounted) await _load();
  }

  Future<void> _approveOnly(Map<String, dynamic> m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('موافقة من غير مشرف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text('«${m['storeName']}» هيشتغل ويظهر للعملاء، وهيفضل في "من غير مشرف" لحد ما توزّعه. متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.successDark),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: const Text('موافقة'),
          ),
        ],
      ),
    );
    if (ok == true) await _submit(m, approve: true);
  }

  ({Color fg, Color bg}) _look(String status) => switch (status) {
        'pending' => (fg: AppColors.warningDark, bg: AppColors.warningLight),
        'info' => (fg: AppColors.infoDark, bg: AppColors.infoLight),
        'rejected' || 'suspended' => (fg: AppColors.dangerDark, bg: AppColors.dangerLight),
        _ => (fg: AppColors.successDark, bg: AppColors.successLight),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        title: const Text('توزيع التجار على المشرفين', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: BrandRefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _seg('من غير مشرف', _unassigned, !_all, () {
                    if (!_all) return;
                    setState(() => _all = false);
                    _load();
                  }),
                  const SizedBox(width: 3),
                  _seg('كل التجار', 0, _all, () {
                    if (_all) return;
                    setState(() => _all = true);
                    _load();
                  }),
                ],
              ),
            ),
            if (!_all && _waiting > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top_rounded, color: AppColors.warningDark, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$_waiting تاجر جديد مفيش مشرف في منطقته ومستني موافقتك. مش هيقدر يشتغل غير لما توافق عليه أو توزّعه.',
                        style: TextStyle(color: AppColors.warningDark, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'ابحث باسم المتجر أو الموبايل',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.cardBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.cardBorder)),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading && _merchants.isEmpty)
              const Padding(padding: EdgeInsets.only(top: 60), child: Center(child: CircularProgressIndicator()))
            else if (_error != null && _merchants.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              )
            else if (_merchants.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.task_alt_rounded, size: 42, color: AppColors.textMuted),
                    const SizedBox(height: 10),
                    Text(_all ? 'مفيش تجار' : 'كل التجار متوزعين على مشرفين',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              )
            else
              for (final m in _merchants) ...[
                ScrollFx(child: _tile(m)),
                const SizedBox(height: 9),
              ],
          ],
        ),
      ),
    );
  }

  Widget _seg(String label, int count, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryDark : Colors.transparent,
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
                  decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(99)),
                  child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(Map<String, dynamic> m) {
    final id = (m['id'] as num).toInt();
    final busy = _busy.contains(id);
    final status = '${m['status'] ?? 'working'}';
    final look = _look(status);
    final pending = status == 'pending';
    final stopped = status == 'suspended' || status == 'rejected';
    final supervisor = _s(m['supervisorName']);
    final image = _s(m['imageUrl']);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pending ? AppColors.warningDark.withValues(alpha: 0.45) : AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.surfaceHighlight,
                backgroundImage: image != null && image.startsWith('http') ? NetworkImage(image) : null,
                child: image != null && image.startsWith('http')
                    ? null
                    : Icon(Icons.storefront_outlined, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${m['storeName'] ?? '—'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      [_s(m['ownerName']), _s(m['place']), _s(m['phone'])].whereType<String>().join(' • '),
                      maxLines: 2,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: look.bg, borderRadius: BorderRadius.circular(99)),
                child: Text('${m['statusLabel'] ?? ''}',
                    style: TextStyle(color: look.fg, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(Icons.support_agent_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  supervisor == null ? 'من غير مشرف' : 'المشرف: $supervisor (${m['supervisorCode']})',
                  style: TextStyle(
                    color: supervisor == null ? AppColors.warningDark : AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          if (busy)
            const Center(child: SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _pickSupervisor(m),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: Text(supervisor == null ? 'وزّع على مشرف' : 'نقل لمشرف تاني', style: const TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (pending) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _approveOnly(m),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('موافقة بس', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.successDark,
                        side: BorderSide(color: AppColors.successDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          if (!busy && !pending)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _openCase(m),
                icon: Icon(stopped ? Icons.gavel_outlined : Icons.folder_open_outlined, size: 17),
                label: Text(stopped ? 'مراجعة قرار ${m['statusLabel'] ?? 'الإيقاف'}' : 'ملف التاجر',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                  foregroundColor: stopped ? AppColors.dangerDark : AppColors.infoDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
