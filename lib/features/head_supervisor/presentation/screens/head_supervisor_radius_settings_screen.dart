import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';

/// إعدادات النطاقات: رئيس المشرفين بيحدد
/// - نطاق خدمة كل التجار (الدايرة حوالين المحل)،
/// - نطاق الكباتن على الدراجة الهوائية (لوحده)،
/// - نطاق باقي وسائل التوصيل (مشترك).
/// التغيير بيتطبّق فورًا على الكل وبيوصلهم إشعار.
class HeadSupervisorRadiusSettingsScreen extends StatefulWidget {
  const HeadSupervisorRadiusSettingsScreen({super.key});

  @override
  State<HeadSupervisorRadiusSettingsScreen> createState() =>
      _HeadSupervisorRadiusSettingsScreenState();
}

class _RadiusField {
  _RadiusField(this.min, this.max, this.step);
  final double min;
  final double max;
  final double step;
  double current = 0;
  double value = 0;
  double fallback = 0;
  bool get changed => (value - current).abs() > 0.01;
}

class _HeadSupervisorRadiusSettingsScreenState
    extends State<HeadSupervisorRadiusSettingsScreen> {
  ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

  final _store = _RadiusField(1, 100, 1);
  final _courier = _RadiusField(1, 100, 1);
  final _bicycle = _RadiusField(0.5, 30, 0.5);
  List<Map<String, dynamic>> _history = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  static double _num(Object? v, double fallback) =>
      v is num && v > 0 ? v.toDouble() : fallback;

  void _apply(Map<String, dynamic> data) {
    final defaults = data['defaults'] is Map
        ? Map<String, dynamic>.from(data['defaults'] as Map)
        : const <String, dynamic>{};
    void set(_RadiusField f, String key, double def) {
      f.fallback = _num(defaults[key], def);
      f.current = _num(data[key], f.fallback);
      f.value = f.current;
    }

    set(_store, 'storeServiceRadiusKm', 20);
    set(_courier, 'courierMaxTripKm', 30);
    set(_bicycle, 'bicycleMaxTripKm', 4);
    _history = [
      for (final h in (data['history'] as List? ?? const []))
        if (h is Map) Map<String, dynamic>.from(h),
    ];
  }

  Future<void> _load() async {
    try {
      final response = await _api.get<Object>(ApiEndpoints.bossRadiusSettings);
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map) throw const FormatException('bad radius settings');
      if (!mounted) return;
      setState(() {
        _apply(Map<String, dynamic>.from(data));
        _loading = false;
        _error = null;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل النطاقات. اسحب للتحديث.';
      });
    }
  }

  static String _km(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Future<void> _save() async {
    final changes = <String>[
      if (_store.changed)
        'نطاق التجار: ${_km(_store.current)} ← ${_km(_store.value)} كم (إشعار لكل التجار)',
      if (_courier.changed)
        'نطاق الكباتن: ${_km(_courier.current)} ← ${_km(_courier.value)} كم (إشعار لكباتن الموتوسيكل والعربية والتوك توك)',
      if (_bicycle.changed)
        'نطاق الدراجة الهوائية: ${_km(_bicycle.current)} ← ${_km(_bicycle.value)} كم (إشعار لكباتن الدراجة)',
    ];
    if (changes.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد تغيير النطاقات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in changes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• $c', style: const TextStyle(fontSize: 13, height: 1.5)),
                ),
              Text(
                'التغيير بيتطبّق فورًا على الكل.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('حفظ وإرسال الإشعار'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final response = await _api.put<Object>(
        ApiEndpoints.bossRadiusSettings,
        data: {
          if (_store.changed) 'storeServiceRadiusKm': _store.value,
          if (_courier.changed) 'courierMaxTripKm': _courier.value,
          if (_bicycle.changed) 'bicycleMaxTripKm': _bicycle.value,
        },
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final message = body is Map ? '${body['message'] ?? ''}'.trim() : '';
      if (!mounted) return;
      setState(() {
        if (data is Map) _apply(Map<String, dynamic>.from(data));
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message.isEmpty ? 'اتحفظت النطاقات' : message),
      ));
    } on DioException catch (error) {
      final body = error.response?.data;
      final message = body is Map ? '${body['message'] ?? ''}'.trim() : '';
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message.isEmpty ? 'تعذر حفظ النطاقات. حاول تاني.' : message),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final anyChange = _store.changed || _courier.changed || _bicycle.changed;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'إعدادات النطاقات',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        bottomNavigationBar: _loading || _error != null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FilledButton.icon(
                    onPressed: !anyChange || _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('حفظ التغييرات'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ),
              ),
        body: BrandRefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, textAlign: TextAlign.center),
                )
              else ...[
                _RadiusCard(
                  field: _store,
                  icon: Icons.storefront_outlined,
                  title: 'نطاق خدمة التجار',
                  detail:
                      'الدايرة حوالين كل محل: العميل اللي برّاها مايقدرش يطلب، وبتظهر على خرايط التجار والعملاء.',
                  onChanged: (v) => setState(() => _store.value = v),
                ),
                const SizedBox(height: 12),
                _RadiusCard(
                  field: _courier,
                  icon: Icons.two_wheeler_outlined,
                  title: 'نطاق الكباتن (موتوسيكل / عربية / توك توك)',
                  detail:
                      'أقصى مسافة لرحلة الكابتن كلها: منه للمحل وبعدين للعميل. الطلب الأطول مايظهرلوش.',
                  onChanged: (v) => setState(() => _courier.value = v),
                ),
                const SizedBox(height: 12),
                _RadiusCard(
                  field: _bicycle,
                  icon: Icons.pedal_bike_outlined,
                  title: 'نطاق الدراجة الهوائية',
                  detail: 'نطاق منفصل لكباتن الدراجة الهوائية بس (الرحلة كلها).',
                  onChanged: (v) => setState(() => _bicycle.value = v),
                ),
                const SizedBox(height: 10),
                Text(
                  'رحلات وصلني والمطار مش بتتأثر بالإعدادات دي.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                if (_history.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'آخر التعديلات',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  for (final h in _history) _HistoryTile(entry: h),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RadiusCard extends StatelessWidget {
  const _RadiusCard({
    required this.field,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onChanged,
  });

  final _RadiusField field;
  final IconData icon;
  final String title;
  final String detail;
  final ValueChanged<double> onChanged;

  static String _km(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final value = field.value.clamp(field.min, field.max).toDouble();
    final divisions = ((field.max - field.min) / field.step).round();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: field.changed ? AppColors.warningDark : AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
              ),
              Text(
                '${_km(value)} كم',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(detail, style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary)),
          Row(
            children: [
              IconButton(
                onPressed: value - field.step < field.min ? null : () => onChanged(value - field.step),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Expanded(
                child: Slider(
                  value: value,
                  min: field.min,
                  max: field.max,
                  divisions: divisions,
                  label: '${_km(value)} كم',
                  onChanged: (v) => onChanged((v / field.step).round() * field.step),
                ),
              ),
              IconButton(
                onPressed: value + field.step > field.max ? null : () => onChanged(value + field.step),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                field.changed
                    ? 'الحالي ${_km(field.current)} كم ← الجديد ${_km(value)} كم'
                    : 'الحالي ${_km(field.current)} كم',
                style: TextStyle(
                  fontSize: 11.5,
                  color: field.changed ? AppColors.warningDark : AppColors.textMuted,
                  fontWeight: field.changed ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if ((value - field.fallback).abs() > 0.01)
                TextButton(
                  onPressed: () => onChanged(field.fallback),
                  child: Text('الأصلي (${_km(field.fallback)} كم)'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final raw = '${entry['at'] ?? ''}'.trim();
    final hasZone = raw.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(raw);
    final at = DateTime.tryParse(hasZone || raw.isEmpty ? raw : '${raw}Z')?.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    final when = at == null ? '' : '${at.year}/${two(at.month)}/${two(at.day)} ${two(at.hour)}:${two(at.minute)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${entry['change'] ?? ''}',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 4),
          Text(
            [if ('${entry['by'] ?? ''}'.trim().isNotEmpty) '${entry['by']}', when].join(' • '),
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
