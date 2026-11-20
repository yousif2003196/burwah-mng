import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_wallet.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/boss_formatters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// بطاقات شاشة محفظة رئيس المشرفين.

/// اسم طريقة الصرف كما يرسلها الخادم (`bank` / `instapay` / `wallet`).
String payoutMethodLabel(BuildContext context, String method) =>
    switch (method.toLowerCase()) {
      'bank' => headSupervisorText(context, arabic: 'حساب بنكي', english: 'Bank account'),
      'instapay' =>
        headSupervisorText(context, arabic: 'إنستاباي (IPA)', english: 'Instapay (IPA)'),
      'wallet' =>
        headSupervisorText(context, arabic: 'محفظة ذكية', english: 'Digital wallet'),
      _ => method,
    };

IconData payoutMethodIcon(String method) => switch (method.toLowerCase()) {
      'bank' => Icons.account_balance_outlined,
      'instapay' => Icons.bolt,
      _ => Icons.wallet_outlined,
    };

class WalletSummaryCard extends StatelessWidget {
  final BossWallet wallet;
  const WalletSummaryCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.blueFill,
          border: AppColors.blueEdge,
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: AppPalette.overlay18000000,
                blurRadius: 12,
                offset: Offset(0, 6))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            WalletPill(
                text: headSupervisorText(context,
                    arabic: 'محفظة المستحقات الإشرافية',
                    english: 'Supervision earnings wallet'),
                icon: Icons.verified_user_outlined),
          ]),
          const SizedBox(height: 17),
          Text(
              headSupervisorText(context,
                  arabic: 'إجمالي الرصيد', english: 'Total balance'),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: AppColors.info)),
          const SizedBox(height: 3),
          CountText(bossMoney(wallet.totalBalance, showDecimals: true),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 17),
          Row(children: [
            Expanded(
                child: WalletBalanceTile(
                    label: headSupervisorText(context,
                        arabic: 'الرصيد المقفل', english: 'Locked balance'),
                    value: bossMoney(wallet.lockedBalance, showDecimals: true),
                    icon: Icons.hourglass_top)),
            const SizedBox(width: 8),
            Expanded(
                child: WalletBalanceTile(
                    label: headSupervisorText(context,
                        arabic: 'المتاح للسحب الفوري',
                        english: 'Available for withdrawal'),
                    value: bossMoney(wallet.availableForWithdrawal,
                        showDecimals: true),
                    icon: Icons.account_balance_wallet_outlined,
                    emphasized: true)),
          ]),
        ]),
      );
}

class WalletAmountCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<double> onPreset;
  final double available;

  const WalletAmountCard({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onPreset,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    const quickAmounts = <double>[20000, 10000, 5000];
    return WalletWhitePanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
            headSupervisorText(context,
                arabic: 'المبلغ المطلوب سحبه', english: 'Withdrawal amount'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 5),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            WalletPill(text: headSupervisorText(context, arabic: 'جنيه EGP', english: 'EGP')),
            const Spacer(),
            SizedBox(
              width: 140,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    suffixIcon: MotionIcon(Icons.account_balance_wallet_outlined,
                        size: 18, color: AppColors.infoDark)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 15),
        Text(
            headSupervisorText(context,
                arabic: 'تحديد مبلغ سريع', english: 'Quick amount'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 7),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 7,
          runSpacing: 7,
          children: [
            WalletPresetButton(
                label: headSupervisorText(context,
                    arabic: 'كامل المتاح (${bossMoney(available)})',
                    english: 'Full available (${bossMoney(available)})'),
                selected: true,
                icon: Icons.bolt,
                onTap: available > 0 ? () => onPreset(available) : null),
            for (final amount in quickAmounts)
              if (amount <= available)
                WalletPresetButton(
                    label: bossMoney(amount), onTap: () => onPreset(amount)),
          ],
        ),
      ]),
    );
  }
}

class WalletPayoutMethodSelector extends StatelessWidget {
  final List<String> methods;
  final String? selected;
  final ValueChanged<String> onChanged;

  const WalletPayoutMethodSelector({
    super.key,
    required this.methods,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          for (final method in methods)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(method),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
                  decoration: BoxDecoration(
                      color: method == selected
                          ? AppColors.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    MotionIcon(payoutMethodIcon(method),
                        size: 15, color: AppColors.ink),
                    const SizedBox(width: 3),
                    Flexible(
                        child: Text(payoutMethodLabel(context, method),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 8, color: AppColors.textPrimary))),
                  ]),
                ),
              ),
            ),
        ]),
      );
}

/// حقل نص بنفس شكل بطاقات المحفظة (الحساب المستلم / رمز التحقق).
class WalletInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final int? maxLength;

  const WalletInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.enabled = true,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) => WalletWhitePanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(label,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
            style: TextStyle(
                fontSize: 14, letterSpacing: .5, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceLight,
              prefixIcon: MotionIcon(icon, size: 18, color: AppColors.infoDark),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
        ]),
      );
}

class WalletSecurityNotice extends StatelessWidget {
  const WalletSecurityNotice({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: AppColors.infoLight,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          MotionIcon(Icons.lock_outline, color: AppColors.ink, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                  headSupervisorText(context,
                      arabic: 'التحقق والحوكمة الإدارية المشددة',
                      english: 'Verification and administrative governance'),
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 5),
              Text(
                  headSupervisorText(context,
                      arabic:
                          'لا تُنفّذ الحوالة إلا بعد إدخال رمز التحقق (OTP) المرسل إلى جوال رئيس المشرفين المعتمد.',
                      english:
                          'The transfer runs only after you enter the one-time code (OTP) sent to the approved Head Supervisor phone.'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 10, height: 1.5, color: AppColors.infoDark)),
            ]),
          ),
        ]),
      );
}

class WalletTransactionCard extends StatelessWidget {
  final BossWalletTransaction transaction;
  const WalletTransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final outgoing = transaction.amount < 0;
    final statusColor = transaction.status.isUrgent
        ? AppColors.dangerDark
        : AppColors.infoDark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.surfaceLight,
            child: MotionIcon(outgoing ? Icons.south_west : Icons.north_east,
                size: 17, color: AppColors.ink)),
        const SizedBox(width: 9),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              CountText(bossMoney(transaction.amount, showDecimals: true),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: outgoing ? AppColors.ink : AppColors.successDark)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                    transaction.description.isEmpty
                        ? transaction.kind
                        : transaction.description,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
              ),
            ]),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 7,
              children: [
                if (transaction.status.raw.isNotEmpty)
                  Text('● ${transaction.status.raw}',
                      style: TextStyle(fontSize: 10, color: statusColor)),
                if (transaction.referenceCode.isNotEmpty)
                  Text(transaction.referenceCode,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink)),
                Text(bossDateTime(transaction.createdAt),
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ]),
        ),
      ]),
    );
  }
}

class WalletSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const WalletSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Row(children: [
        if (trailing != null)
          Text(trailing!,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const Spacer(),
        Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
                color: AppColors.infoDark,
                borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 7),
        Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
      ]);
}

class WalletWhitePanel extends StatelessWidget {
  final Widget child;
  const WalletWhitePanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(18)),
        child: child,
      );
}

class WalletPresetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  const WalletPresetButton({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              color: selected ? AppColors.infoBorder : AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(9)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) MotionIcon(icon!, size: 13, color: AppColors.ink),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ]),
        ),
      );
}

class WalletPill extends StatelessWidget {
  final String text;
  final IconData? icon;

  const WalletPill({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(9)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text,
              style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          if (icon != null) ...[
            const SizedBox(width: 4),
            MotionIcon(icon!, size: 11, color: AppColors.textSecondary),
          ],
        ]),
      );
}

class WalletBalanceTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool emphasized;

  const WalletBalanceTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
            color: AppColors.infoDark, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Flexible(
              child: Text(label,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10, color: AppColors.info)),
            ),
            const SizedBox(width: 4),
            MotionIcon(icon, size: 14, color: AppColors.info),
          ]),
          const SizedBox(height: 5),
          CountText(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 3),
          Text(
              emphasized
                  ? headSupervisorText(context,
                      arabic: 'متاح ومؤهل للتحويل',
                      english: 'Available for transfer')
                  : headSupervisorText(context,
                      arabic: 'غير متاح للسحب حالياً',
                      english: 'Not withdrawable yet'),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 9, color: AppColors.info)),
        ]),
      );
}
