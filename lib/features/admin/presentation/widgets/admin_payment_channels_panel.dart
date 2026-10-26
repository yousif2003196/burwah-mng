import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/payments/payment_channel_config.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// قنوات الدفع التي يتحكم بها الأدمن: تفعيل/إيقاف، حدود، ورسوم.
class AdminPaymentChannelsPanel extends StatefulWidget {
  const AdminPaymentChannelsPanel({super.key});

  @override
  State<AdminPaymentChannelsPanel> createState() =>
      _AdminPaymentChannelsPanelState();
}

class _AdminPaymentChannelsPanelState extends State<AdminPaymentChannelsPanel> {
  final _store = PaymentChannelConfigStore();
  Map<PaymentChannel, PaymentChannelConfig>? _configs;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    PaymentChannelConfigStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    PaymentChannelConfigStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final configs = await _store.load();
      if (mounted) {
        setState(() {
          _configs = configs;
          _failed = false;
        });
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'payment channels',
      ));
      if (mounted) setState(() => _failed = true);
    }
  }

  IconData _icon(PaymentChannel c) => switch (c) {
        PaymentChannel.bankTransfer => Icons.account_balance_outlined,
        PaymentChannel.instapay => Icons.bolt_rounded,
        PaymentChannel.card => Icons.credit_card_outlined,
        _ => Icons.account_balance_wallet_outlined,
      };

  String _errorText(String code) => switch (code) {
        'minNegative' => adminText(context, ar: 'الحد الأدنى لا يمكن أن يكون سالباً', en: 'Minimum cannot be negative'),
        'maxBelowMin' => adminText(context, ar: 'الحد الأقصى أقل من الأدنى', en: 'Maximum is below the minimum'),
        'dailyBelowMax' => adminText(context, ar: 'الحد اليومي أقل من الحد الأقصى للعملية', en: 'Daily limit is below the per-transfer maximum'),
        'feeNegative' => adminText(context, ar: 'الرسوم لا يمكن أن تكون سالبة', en: 'Fees cannot be negative'),
        'feePercentTooHigh' => adminText(context, ar: 'نسبة الرسوم لا تتجاوز 10%', en: 'Fee percentage cannot exceed 10%'),
        _ => adminText(context, ar: 'قيم غير صحيحة', en: 'Invalid values'),
      };

  Future<void> _save(PaymentChannelConfig config) async {
    try {
      await _store.save(config);
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          adminText(context, ar: 'تم حفظ إعدادات القناة', en: 'Channel settings saved'),
        );
      }
    } on ArgumentError catch (error) {
      if (mounted) AppSnackBar.showError(context, _errorText('${error.message}'));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'payment channels',
      ));
      if (mounted) {
        AppSnackBar.showError(
          context,
          adminText(context, ar: 'تعذر حفظ الإعدادات', en: 'Could not save settings'),
        );
      }
    }
  }

  Future<void> _edit(PaymentChannelConfig config) async {
    String fmt(double v) =>
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
    final min = TextEditingController(text: fmt(config.minAmount));
    final max = TextEditingController(text: fmt(config.maxAmount));
    final daily = TextEditingController(text: fmt(config.dailyLimit));
    final percent = TextEditingController(text: fmt(config.feePercent));
    final fixed = TextEditingController(text: fmt(config.feeFixed));
    try {
      final result = await showDialog<PaymentChannelConfig>(
        context: context,
        builder: (dialogContext) {
          Widget field(TextEditingController c, String label) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: c,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(labelText: label),
                ),
              );
          return AlertDialog(
            title: Text(adminText(
              dialogContext,
              ar: config.channel.labelAr,
              en: config.channel.labelEn,
            )),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  field(min, adminText(dialogContext, ar: 'الحد الأدنى للعملية (ج.م)', en: 'Minimum per transfer (EGP)')),
                  field(max, adminText(dialogContext, ar: 'الحد الأقصى للعملية (ج.م)', en: 'Maximum per transfer (EGP)')),
                  field(daily, adminText(dialogContext, ar: 'الحد اليومي (ج.م)', en: 'Daily limit (EGP)')),
                  field(percent, adminText(dialogContext, ar: 'نسبة الرسوم %', en: 'Fee percentage %')),
                  field(fixed, adminText(dialogContext, ar: 'رسوم ثابتة (ج.م)', en: 'Fixed fee (EGP)')),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  config.copyWith(
                    minAmount: double.tryParse(min.text) ?? -1,
                    maxAmount: double.tryParse(max.text) ?? -1,
                    dailyLimit: double.tryParse(daily.text) ?? -1,
                    feePercent: double.tryParse(percent.text) ?? -1,
                    feeFixed: double.tryParse(fixed.text) ?? -1,
                  ),
                ),
                child: Text(adminText(dialogContext, ar: 'حفظ', en: 'Save')),
              ),
            ],
          );
        },
      );
      if (result != null) await _save(result);
    } finally {
      min.dispose();
      max.dispose();
      daily.dispose();
      percent.dispose();
      fixed.dispose();
    }
  }

  List<Widget> _pills(PaymentChannelConfig c) {
    String fmt(double v) =>
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    Widget pill(IconData icon, String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MotionIcon(icon, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(text,
                  style: TextStyle(
                      fontSize: 10.5, color: AppColors.textSecondary)),
            ],
          ),
        );
    final noFee = c.feePercent == 0 && c.feeFixed == 0;
    return [
      pill(
        Icons.swap_horiz_rounded,
        adminText(context,
            ar: '${fmt(c.minAmount)} – ${fmt(c.maxAmount)} ج.م',
            en: '${fmt(c.minAmount)} – ${fmt(c.maxAmount)} EGP'),
      ),
      pill(
        Icons.today_outlined,
        adminText(context,
            ar: 'يومي ${fmt(c.dailyLimit)}', en: 'Daily ${fmt(c.dailyLimit)}'),
      ),
      pill(
        Icons.percent_rounded,
        noFee
            ? adminText(context, ar: 'بدون رسوم', en: 'No fee')
            : adminText(context,
                ar: '${fmt(c.feePercent)}% + ${fmt(c.feeFixed)} ج.م',
                en: '${fmt(c.feePercent)}% + ${fmt(c.feeFixed)} EGP'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final configs = _configs;
    if (_failed) {
      return AdminCard(
        child: Text(adminText(context,
            ar: 'تعذر تحميل قنوات الدفع', en: 'Could not load payment channels')),
      );
    }
    if (configs == null) {
      return const AdminCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AdminCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        children: [
          for (final entry in configs.values.indexed) ...[
            if (entry.$1 > 0) const Divider(height: 1),
            InkWell(
              onTap: () => _edit(entry.$2),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MotionIcon(_icon(entry.$2.channel),
                          color: AppColors.info, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              adminText(context,
                                  ar: entry.$2.channel.labelAr,
                                  en: entry.$2.channel.labelEn),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _pills(entry.$2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Switch(
                      value: entry.$2.enabled,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeThumbColor: AppColors.successDark,
                      onChanged: (v) => _save(entry.$2.copyWith(enabled: v)),
                    ),
                  ],
                ),
              ),
            ),
        ],
        ],
      ),  
    );
  }
}
