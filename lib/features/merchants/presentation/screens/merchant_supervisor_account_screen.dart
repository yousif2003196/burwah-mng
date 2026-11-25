import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_theme_switcher.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/change_password_dialog.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_api.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_server_escalations_screen.dart';
import 'package:barwah_app/features/merchants/presentation/widgets/merchant_complaints_entry.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_wallet_screen.dart';

/// حساب مشرف التجار (الحساب الحقيقي): كل البيانات من السيرفر.
class MerchantSupervisorAccountScreen extends StatefulWidget {
  const MerchantSupervisorAccountScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<MerchantSupervisorAccountScreen> createState() => _MerchantSupervisorAccountScreenState();
}

class _MerchantSupervisorAccountScreenState extends State<MerchantSupervisorAccountScreen> {
  ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

  Map<String, dynamic>? _me;
  double? _balance;
  double? _dues;
  bool _loading = true;
  String? _error;
  bool _savingPush = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final me = await MerchantsApi.me();
      Map<String, dynamic>? wallet;
      try {
        final r = await _api.get<Object>(ApiEndpoints.walletSummary);
        if (r.data is Map) wallet = Map<String, dynamic>.from(r.data as Map);
      } on Object catch (error) {
        debugPrint('Merchant supervisor wallet unavailable: $error');
      }
      if (!mounted) return;
      setState(() {
        _me = me;
        _balance = (wallet?['balance'] as num?)?.toDouble();
        _dues = (wallet?['totalDues'] as num?)?.toDouble();
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

  String? _s(String key) {
    final t = '${_me?[key] ?? ''}'.trim();
    return t.isEmpty || t == 'null' ? null : t;
  }

  String _n(String key) {
    final v = _me?[key];
    return v is num ? (v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1)) : '—';
  }

  static String _money(double? v) =>
      v == null ? '—' : (v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2));

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _togglePush(bool value) async {
    if (_savingPush) return;
    final previous = _me;
    setState(() {
      _savingPush = true;
      _me = {...?_me, 'pushNotificationsEnabled': value};
    });
    try {
      await _api.dio.patch<Object>(ApiEndpoints.accountUpdatePreferences, data: {'pushNotificationsEnabled': value});
      if (mounted) _toast(value ? 'الإشعارات اتفعّلت' : 'الإشعارات اتوقفت');
    } on Object {
      if (!mounted) return;
      setState(() => _me = previous);
      _toast('تعذر تحديث الإشعارات، حاول تاني');
    }
    if (mounted) setState(() => _savingPush = false);
  }

  Future<void> _showMyAccess() async {
    Map<String, dynamic>? data;
    String? error;
    try {
      final r = await _api.get<Object>(ApiEndpoints.adMyAccess);
      final body = r.data;
      if (body is Map && body['data'] is Map) data = Map<String, dynamic>.from(body['data'] as Map);
    } on Object {
      error = 'تعذر تحميل صلاحياتك. حاول تاني.';
    }
    if (!mounted) return;
    Widget line(bool allowed, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Icon(allowed ? Icons.check_circle_outline : Icons.block,
                size: 18, color: allowed ? AppColors.successDark : AppColors.dangerDark),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$text: ${allowed ? 'مسموح' : 'موقوف من رئيس المشرفين'}',
                  style: TextStyle(fontSize: 13, color: AppColors.ink)),
            ),
          ]),
        );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('صلاحياتي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 10),
                if (error != null)
                  Text(error, style: TextStyle(color: AppColors.dangerDark))
                else if (data != null) ...[
                  line(data['canReviewAds'] != false, 'مراجعة التجار (قبول/رفض/طلب بيانات) والعمولة'),
                  line(data['canHideAds'] != false, 'إيقاف التجار وإخفاء المنتجات'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAccountInfo() {
    String t(String key) => _s(key) ?? '—';
    final rows = <(IconData, String, String)>[
      (Icons.person_outline, 'الاسم', t('fullName')),
      (Icons.tag, 'كود الحساب', t('code')),
      (Icons.phone_outlined, 'الموبايل', t('phone')),
      (Icons.alternate_email, 'البريد الإلكتروني', t('email')),
      (Icons.place_outlined, 'المنطقة', t('region')),
      (Icons.task_alt, 'كل قراراتي على التجار', _n('decisionsTotal')),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('بيانات الحساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('للعرض بس — لو فيه تعديل كلّم رئيس المشرفين.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                for (final r in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Icon(r.$1, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(r.$2, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const Spacer(),
                      Flexible(
                        child: Text(r.$3,
                            textAlign: TextAlign.end,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      ),
                    ]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('متأكد إنك عاوز تخرج من الحساب؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('إلغاء')),
            FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('خروج')),
          ],
        ),
      ),
    );
    if (ok == true && mounted) widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
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
                ScrollFx(child: _identity()),
                const SizedBox(height: 14),
                ScrollFx(child: _metrics()),
                const SizedBox(height: 14),
                ScrollFx(child: _wallet()),
                const SizedBox(height: 18),
                Text('الإدارة', style: TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ScrollFx(child: _management()),
                const SizedBox(height: 14),
                const ScrollFx(child: MerchantComplaintsEntry()),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('تسجيل الخروج'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration get _card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      );

  Widget _identity() {
    final photo = _s('profileImageUrl');
    final available = _me?['isAvailable'] != false;
    final contact = [_s('phone'), _s('email')].whereType<String>().join(' • ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 64,
                decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(14)),
                clipBehavior: Clip.antiAlias,
                child: photo == null
                    ? Icon(Icons.person, color: AppColors.ink, size: 34)
                    : Image.network(photo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Icon(Icons.person, color: AppColors.ink, size: 34)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_s('fullName') ?? AuthSession.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('مشرف التجار • ${_s('code') == null ? '' : '#${_s('code')}'}',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                    if (contact.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(contact, style: TextStyle(color: AppColors.textMuted, fontSize: 10.5)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(11)),
            child: Row(
              children: [
                Icon(Icons.circle, color: available ? AppColors.success : AppColors.textMuted, size: 10),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(available ? 'متاح للعمل' : 'غير متاح حالياً',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                Text(_s('region') ?? 'المنطقة غير محددة',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          if (_s('code') != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_2_rounded, color: AppColors.infoDark, size: 22),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('كودك للتجار: ${_s('code')}',
                            style: TextStyle(color: AppColors.infoDark, fontSize: 14, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('ابعته للتاجر يكتبه وهو بيعمل حسابه، وطلبه هيوصلك إنت على طول.',
                            style: TextStyle(color: AppColors.infoDark, fontSize: 10.5, height: 1.4)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'نسخ الكود',
                    icon: Icon(Icons.copy_rounded, color: AppColors.infoDark, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _s('code')!));
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(content: Text('اتنسخ الكود'), behavior: SnackBarBehavior.floating));
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metrics() {
    final avg = _me?['myAverageReviewMinutes'];
    final avgText = avg is num ? (avg < 10 ? avg.toStringAsFixed(1) : avg.round().toString()) : '—';
    final tiles = <(IconData, String, String, String, Color)>[
      (Icons.task_alt, 'قراراتي الشهر ده', _n('decisionsThisMonth'), 'على التجار ومنتجاتهم', AppColors.info),
      (Icons.verified_outlined, 'تجار قبلتهم', _n('approvedThisMonth'), '${_n('rejectedThisMonth')} رفض/طلب بيانات', AppColors.success),
      (Icons.timer_outlined, 'متوسط وقت المراجعة', avgText, 'دقيقة من الفتح للقرار (${_n('myMeasuredDecisions')} قرار)', AppColors.info),
      (Icons.block, 'إيقاف وإخفاء', '${_n('suspendedThisMonth')} / ${_n('productsHiddenThisMonth')}', 'تجار موقوفين / منتجات اتخفت', AppColors.warning),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 9.0;
        final w = (c.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles)
              Container(
                width: w,
                height: 98,
                padding: const EdgeInsets.all(10),
                decoration: _card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(t.$1, size: 16, color: t.$5),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(t.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                      ),
                    ]),
                    const Spacer(),
                    Text(t.$3, style: TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w800)),
                    Text(t.$4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: t.$5, fontSize: 9)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _wallet() {
    Widget amount(String label, double? v) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.cardBorder, fontSize: 10)),
                const SizedBox(height: 4),
                Text('${_money(v)} ج.م',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Row(children: [
            const Expanded(
              child: Text('محفظتي', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            ),
            Icon(Icons.account_balance_wallet_outlined, color: AppColors.infoBorder, size: 24),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            amount('الرصيد المتاح', _balance),
            const SizedBox(width: 8),
            amount('مستحقات معلّقة', _dues),
          ]),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const ServicesSupervisorWalletScreen(owner: SupervisorWalletOwner.merchant),
                ));
                if (mounted) await _load();
              },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('فتح المحفظة والسحب'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                backgroundColor: AppColors.infoBorder,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String title, String subtitle, VoidCallback onTap, {Widget? trailing}) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: AppColors.ink, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    ],
                  ),
                ),
                trailing ?? Icon(Icons.chevron_left, color: AppColors.textMuted, size: 20),
              ],
            ),
          ),
        ),
      );

  Widget _management() {
    final push = _me?['pushNotificationsEnabled'] != false;
    const divider = Divider(height: 1, indent: 14, endIndent: 14);
    return Container(
      decoration: _card,
      child: Column(
        children: [
          _row(Icons.manage_accounts_outlined, 'بيانات الحساب', 'بياناتك كما على السيرفر (عرض فقط)', _showAccountInfo),
          divider,
          _row(Icons.admin_panel_settings_outlined, 'صلاحياتي', 'الصلاحيات اللي حددها لك رئيس المشرفين', _showMyAccess),
          divider,
          _row(
            push ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
            'الإشعارات',
            push ? 'مفعّلة: بيوصلك إشعار بالتجار الجداد والسحوبات وقرارات الرئيس' : 'متوقفة: مش هيوصلك إشعارات على الموبايل',
            () => _togglePush(!push),
            trailing: _savingPush
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Switch.adaptive(value: push, onChanged: _togglePush),
          ),
          divider,
          _row(Icons.campaign_outlined, 'تصعيداتي لرئيس المشرفين', 'المشاكل اللي صعّدتها وقرار الرئيس عليها',
              () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const MerchantServerEscalationsScreen()),
                  )),
          divider,
          _row(Icons.lock_outline, 'تغيير كلمة المرور', 'غيّر كلمة مرور حسابك', () async {
            final changed = await showChangePasswordDialog(context, arabic: true);
            if (changed && mounted) _toast('تم تغيير كلمة المرور');
          }),
          divider,
          _row(Icons.translate, 'اللغة', 'عربي / English', AppLocaleController.instance.toggle),
          divider,
          _row(Icons.palette_outlined, 'المظهر', 'فاتح / داكن', () => showAppThemeSheet(context)),
        ],
      ),
    );
  }
}
