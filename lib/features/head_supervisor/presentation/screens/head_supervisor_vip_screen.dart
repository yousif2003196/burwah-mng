import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/products/data/datasources/product_promotion_api_data_source.dart';
import 'package:barwah_app/features/products/presentation/screens/vip_banners_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// إعلانات VIP في بنر الرئيسية: رئيس المشرفين يحدد عدد الأماكن ويدير البنرات.
/// مشرفا المنتجات ووصلني يرون العدد فقط.
class HeadSupervisorVipScreen extends StatefulWidget {
  const HeadSupervisorVipScreen({super.key});

  @override
  State<HeadSupervisorVipScreen> createState() =>
      _HeadSupervisorVipScreenState();
}

class _HeadSupervisorVipScreenState extends State<HeadSupervisorVipScreen> {
  ProductPromotionApiDataSource get _api => sl<ProductPromotionApiDataSource>();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  int? _limit;
  int _draft = 0;
  int _running = 0;
  int _waiting = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await _api.loadVipSettings();
      if (!mounted) return;
      setState(() {
        _limit = settings.limit;
        _draft = settings.limit;
        _running = settings.running;
        _waiting = settings.waiting;
        _error = null;
        _loading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor vip settings',
      ));
      if (!mounted) return;
      setState(() {
        _error = headSupervisorText(context,
            arabic: 'تعذر تحميل إعدادات VIP من السيرفر.',
            english: 'Could not load the VIP settings.');
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _api.saveVipLimit(_draft);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(headSupervisorText(context,
            arabic: 'تم حفظ حد إعلانات VIP: $_draft',
            english: 'VIP limit saved: $_draft')),
      ));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor vip limit',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(headSupervisorText(context,
            arabic: 'تعذر حفظ الحد. حاول مرة أخرى.',
            english: 'Could not save the limit. Try again.')),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        title: Text(
          headSupervisorText(context,
              arabic: 'إعلانات VIP والبنرات', english: 'VIP ads & banners'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
              _Panel(
                child: Column(children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () {
                      setState(() => _loading = true);
                      _load();
                    },
                    child: Text(headSupervisorText(context,
                        arabic: 'إعادة المحاولة', english: 'Retry')),
                  ),
                ]),
              )
            else
              _buildLimitCard(),
            const SizedBox(height: 12),
            _buildBannersEntry(),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitCard() {
    final limit = _limit ?? 0;
    return _Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
          headSupervisorText(context,
              arabic: 'الحد الأقصى لإعلانات VIP في البنر',
              english: 'Maximum VIP ads in the banner'),
          style: TextStyle(
              color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          headSupervisorText(context,
              arabic:
                  '$_running معروض الآن + $_waiting منتظر. الإعلان المنتظر تبدأ مدته عند دخوله البنر، ومشرفا المنتجات ووصلني يرون الحد فقط.',
              english:
                  '$_running shown + $_waiting waiting. A waiting ad\'s days start when it enters the banner. The products and Wasalny supervisors only see the limit.'),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 12),
        Row(children: [
          IconButton.outlined(
            onPressed: _saving || _draft <= 0
                ? null
                : () => setState(() => _draft--),
            icon: const Icon(Icons.remove),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              '$_draft',
              style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
          IconButton.outlined(
            onPressed: _saving || _draft >= 100
                ? null
                : () => setState(() => _draft++),
            icon: const Icon(Icons.add),
          ),
          const Spacer(),
          FilledButton(
            onPressed: _saving || _draft == limit ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(headSupervisorText(context,
                    arabic: 'حفظ', english: 'Save')),
          ),
        ]),
        if (_draft < _running) ...[
          const SizedBox(height: 8),
          Text(
            headSupervisorText(context,
                arabic:
                    'الحد أقل من عدد الإعلانات المعروضة الآن ($_running): الإعلانات الجارية تكمل مدتها، ولا يدخل إعلان جديد حتى يقل العدد عن الحد.',
                english:
                    'The limit is below the ads running now ($_running): running ads finish their days and no new ad enters until the count drops below the limit.'),
            style: TextStyle(color: AppColors.dangerDark, fontSize: 10),
          ),
        ],
      ]),
    );
  }

  Widget _buildBannersEntry() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const VipBannersScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(children: [
            MotionIcon(Icons.view_carousel_outlined, color: AppColors.infoDark),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headSupervisorText(context,
                          arabic: 'بنرات قسم VIP', english: 'VIP section banners'),
                      style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      headSupervisorText(context,
                          arabic: 'إضافة البنرات وتعديلها وإيقافها وحذفها',
                          english: 'Add, edit, pause and delete banners'),
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ]),
            ),
            MotionIcon(Icons.chevron_left, color: AppColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: child,
      );
}
