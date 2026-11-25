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

String _num(Object? v) {
  final d = v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
  return d == d.truncateToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
}

/// عمولة المنصة على التجار: رئيس المشرفين بيحدد العامة (نسبة أو مبلغ ثابت من كل طلب)
/// وممكن يحط عمولة خاصة لأي تاجر. العمولة بتتخصم قبل ما فلوس الطلب تنزل محفظة التاجر.
class HeadSupervisorMerchantCommissionScreen extends StatefulWidget {
  const HeadSupervisorMerchantCommissionScreen({super.key});

  @override
  State<HeadSupervisorMerchantCommissionScreen> createState() => _HeadSupervisorMerchantCommissionScreenState();
}

class _HeadSupervisorMerchantCommissionScreenState extends State<HeadSupervisorMerchantCommissionScreen> {
  final _search = TextEditingController();
  Map<String, dynamic>? _global;
  List<Map<String, dynamic>> _merchants = [];
  bool _loading = true;
  String? _error;
  bool _onlyCustom = false;

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
        ApiEndpoints.bossMerchantCommission,
        queryParameters: {if (_search.text.trim().isNotEmpty) 'q': _search.text.trim()},
      );
      final body = r.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map) throw const FormatException('bad commission');
      if (!mounted) return;
      setState(() {
        _global = data['global'] is Map ? Map<String, dynamic>.from(data['global'] as Map) : null;
        _merchants = [
          for (final m in (data['merchants'] as List? ?? const []))
            if (m is Map) Map<String, dynamic>.from(m),
        ];
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _serverMessage(error, 'تعذر تحميل العمولات. اسحب للتحديث.');
      });
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _editGlobal() async {
    final result = await _askCommission(
      title: 'العمولة العامة لكل التجار',
      note: 'بتتطبق على كل تاجر ملوش عمولة خاصة، وهيوصلهم إشعار. الطلبات القديمة مش هتتأثر.',
      current: _global,
      allowDefault: false,
    );
    if (result == null || !mounted) return;
    try {
      final r = await _api.put<Object>(ApiEndpoints.bossMerchantCommission, data: {'type': result.type, 'value': result.value});
      final body = r.data;
      _toast(body is Map ? '${body['message'] ?? 'اتحفظت'}' : 'اتحفظت');
      await _load();
    } on Object catch (error) {
      _toast(_serverMessage(error, 'تعذر حفظ العمولة'));
    }
  }

  Future<void> _editMerchant(Map<String, dynamic> m) async {
    final custom = m['isCustom'] == true;
    final result = await _askCommission(
      title: 'عمولة ${m['storeName'] ?? 'التاجر'}',
      note: 'عمولة خاصة بالتاجر ده بس بدل العامة، وهيوصله إشعار.',
      current: custom && m['commission'] is Map ? Map<String, dynamic>.from(m['commission'] as Map) : _global,
      allowDefault: custom,
    );
    if (result == null || !mounted) return;
    try {
      final r = await _api.put<Object>(
        ApiEndpoints.bossMerchantCommissionFor((m['id'] as num).toInt()),
        data: {'type': result.type, 'value': result.value},
      );
      final body = r.data;
      _toast(body is Map ? '${body['message'] ?? 'اتحفظت'}' : 'اتحفظت');
      await _load();
    } on Object catch (error) {
      _toast(_serverMessage(error, 'تعذر حفظ العمولة'));
    }
  }

  /// بيرجّع النوع (percent | fixed | default) والقيمة، أو null لو اتلغى.
  Future<({String type, double? value})?> _askCommission({
    required String title,
    required String note,
    required Map<String, dynamic>? current,
    required bool allowDefault,
  }) {
    var fixed = current?['type'] == 'fixed';
    final controller = TextEditingController(text: current == null ? '' : _num(current['value']));
    return showDialog<({String type, double? value})>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, setLocal) {
          final value = double.tryParse(controller.text.trim());
          final valid = value != null && value >= 0 && (fixed ? value <= 10000 : value <= 50);
          final example = value == null
              ? null
              : fixed
                  ? 'على طلب بـ 200 ج.م: المنصة تاخد ${_num(value)} ج.م والتاجر ${_num((200 - value).clamp(0, 200))} ج.م'
                  : 'على طلب بـ 200 ج.م: المنصة تاخد ${_num(200 * value / 100)} ج.م والتاجر ${_num(200 - 200 * value / 100)} ج.م';
          Widget choice(String label, bool isFixed) => Expanded(
                child: GestureDetector(
                  onTap: () => setLocal(() => fixed = isFixed),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: fixed == isFixed ? AppColors.primaryDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: fixed == isFixed ? AppColors.primaryDark : AppColors.cardBorder),
                    ),
                    child: Text(label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: fixed == isFixed ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              );
          return AlertDialog(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(note, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
                  const SizedBox(height: 12),
                  Row(children: [choice('نسبة (%)', false), const SizedBox(width: 8), choice('مبلغ ثابت (ج.م)', true)]),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    onChanged: (_) => setLocal(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: fixed ? 'المبلغ على كل طلب' : 'النسبة من كل طلب',
                      suffixText: fixed ? 'ج.م' : '%',
                      helperText: fixed ? 'من 0 لـ 10000 ج.م' : 'من 0 لـ 50%',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (example != null && valid) ...[
                    const SizedBox(height: 8),
                    Text(example, style: TextStyle(color: AppColors.successDark, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  ],
                  if (allowDefault) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(dialog).pop((type: 'default', value: null)),
                        icon: const Icon(Icons.restart_alt_rounded, size: 16),
                        label: Text('رجّعه للعامة (${_global?['label'] ?? ''})'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialog).pop(), child: const Text('إلغاء')),
              FilledButton(
                onPressed: valid ? () => Navigator.of(dialog).pop((type: fixed ? 'fixed' : 'percent', value: value)) : null,
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final list = _onlyCustom ? _merchants.where((m) => m['isCustom'] == true).toList() : _merchants;
    final customCount = _merchants.where((m) => m['isCustom'] == true).length;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        title: const Text('عمولة المنصة على التجار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: BrandRefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            ScrollFx(child: _globalCard()),
            const SizedBox(height: 16),
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
            const SizedBox(height: 10),
            Row(
              children: [
                Text('التجار', style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                FilterChip(
                  label: Text('عمولة خاصة ($customCount)', style: const TextStyle(fontSize: 11.5)),
                  selected: _onlyCustom,
                  onSelected: (v) => setState(() => _onlyCustom = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading && _merchants.isEmpty)
              const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: CircularProgressIndicator()))
            else if (_error != null && _merchants.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              )
            else if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text('مفيش تجار هنا', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              )
            else
              for (final m in list) ...[
                ScrollFx(child: _merchantTile(m)),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }

  Widget _globalCard() {
    final g = _global;
    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.percent_rounded, color: AppColors.successDark, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('العمولة العامة', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(g == null ? '—' : '${g['label']}',
                        style: TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: g == null ? null : _editGlobal,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('تعديل'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'بتتخصم من كل طلب بيتم عن طريق التطبيق قبل ما الفلوس تنزل محفظة التاجر، لكل تاجر ملوش عمولة خاصة.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _merchantTile(Map<String, dynamic> m) {
    final custom = m['isCustom'] == true;
    final commission = m['commission'] is Map ? m['commission'] as Map : const {};
    final name = '${m['storeName'] ?? '—'}';
    final image = '${m['imageUrl'] ?? ''}'.trim();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _editMerchant(m),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: custom ? AppColors.successDark.withValues(alpha: 0.4) : AppColors.cardBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceHighlight,
                backgroundImage: image.startsWith('http') ? NetworkImage(image) : null,
                child: image.startsWith('http') ? null : Icon(Icons.storefront_outlined, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${commission['label'] ?? '—'}${'${m['city'] ?? ''}'.trim().isEmpty ? '' : ' • ${m['city']}'}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: custom ? AppColors.successLight : AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(custom ? 'خاصة' : 'العامة',
                    style: TextStyle(
                      color: custom ? AppColors.successDark : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
