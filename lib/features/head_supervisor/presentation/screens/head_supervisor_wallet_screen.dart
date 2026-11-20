import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_wallet.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_wallet_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/boss_formatters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/common/boss_state_views.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/wallet/wallet_cards.dart';

/// محفظة رئيس المشرفين:
/// - `GET api/BossOfSupervisor/wallet` للرصيد والسجل
/// - `POST api/BossOfSupervisor/wallet/payout` للصرف الفوري (SARIE)
class HeadSupervisorWalletScreen extends StatelessWidget {
  const HeadSupervisorWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BossWalletCubit>()..load(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const MotionIcon(Icons.arrow_forward),
        ),
        title: Text(
            headSupervisorText(context,
                arabic: 'محفظة رئيس المشرفين', english: 'Supervisor Wallet'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryDark,
              child: const MotionIcon(Icons.shield_outlined,
                  color: Colors.white, size: 17),
            ),
          ),
        ],
      ),
      body: BlocBuilder<BossWalletCubit, BossWalletState>(
        builder: (context, state) => switch (state) {
          BossLoading() => const BossLoadingView(),
          BossLoadFailure(:final message) => BossErrorView(
              message: message,
              onRetry: context.read<BossWalletCubit>().load,
            ),
          BossLoaded(:final data) => _WalletBody(wallet: data),
        },
      ),
    );
  }
}

class _WalletBody extends StatefulWidget {
  final BossWallet wallet;

  const _WalletBody({required this.wallet});

  @override
  State<_WalletBody> createState() => _WalletBodyState();
}

class _WalletBodyState extends State<_WalletBody> {
  final _amount = TextEditingController();
  final _destination = TextEditingController();
  final _otp = TextEditingController();
  String? _method;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final methods = widget.wallet.payoutMethods;
    _method = methods.isEmpty ? null : methods.first;
  }

  @override
  void didUpdateWidget(covariant _WalletBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final methods = widget.wallet.payoutMethods;
    if (_method == null || !methods.contains(_method)) {
      _method = methods.isEmpty ? null : methods.first;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _destination.dispose();
    _otp.dispose();
    super.dispose();
  }

  double get _amountValue => double.tryParse(_amount.text.trim()) ?? 0;

  void _setAmount(double amount) {
    _amount.text = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    setState(() {});
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// تحقق مبدئي قبل الإرسال. الخادم يكرر التحقق ويرجع رسالته العربية.
  String? _validate() {
    final wallet = widget.wallet;
    final amount = _amountValue;
    if (amount <= 0) {
      return headSupervisorText(context,
          arabic: 'أدخل المبلغ المطلوب سحبه.', english: 'Enter the amount.');
    }
    if (amount < wallet.minimumWithdrawal) {
      return headSupervisorText(context,
          arabic: 'الحد الأدنى للسحب الفوري ${bossMoney(wallet.minimumWithdrawal)}',
          english: 'The minimum withdrawal is ${bossMoney(wallet.minimumWithdrawal)}');
    }
    if (amount > wallet.availableForWithdrawal) {
      return headSupervisorText(context,
          arabic: 'الرصيد المتاح غير كافٍ لإتمام طلب الصرف الفوري',
          english: 'The available balance is not enough for this withdrawal');
    }
    if (_method == null) {
      return headSupervisorText(context,
          arabic: 'لا توجد طريقة صرف متاحة لهذا الحساب.',
          english: 'No payout method is available for this account.');
    }
    if (_destination.text.trim().isEmpty) {
      return headSupervisorText(context,
          arabic: 'أدخل رقم الحساب أو المحفظة المستلمة.',
          english: 'Enter the destination account.');
    }
    if (_otp.text.trim().isEmpty) {
      return headSupervisorText(context,
          arabic: 'أدخل رمز التحقق (OTP).', english: 'Enter the OTP code.');
    }
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final error = _validate();
    if (error != null) {
      _show(error);
      return;
    }
    setState(() => _submitting = true);
    // TODO(backend): الـ payout يتطلب otpCode، لكن لا يوجد endpoint لطلب
    // إرسال الرمز. المستخدم يُدخل الرمز يدويًا حتى يوفّر الباك إند endpoint.
    final outcome = await context.read<BossWalletCubit>().payout(
          BossPayoutRequest(
            amount: _amountValue,
            payoutMethod: _method!,
            destinationAccount: _destination.text.replaceAll(' ', ''),
            otpCode: _otp.text.trim(),
          ),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (outcome.success) {
      _amount.clear();
      _otp.clear();
      _show(outcome.message.isEmpty
          ? headSupervisorText(context,
              arabic: 'تم تأكيد طلب السحب والتحويل الفوري بنجاح',
              english: 'The withdrawal was confirmed')
          : outcome.message);
    } else {
      _show(outcome.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = widget.wallet;
    return RefreshIndicator(
      onRefresh: context.read<BossWalletCubit>().load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ScrollFx(child: WalletSummaryCard(wallet: wallet)),
          const SizedBox(height: 22),
          ScrollFx(
            child: WalletSectionTitle(
              title: headSupervisorText(context,
                  arabic: 'طلب صرف وتحويل فوري', english: 'Instant withdrawal'),
              trailing: headSupervisorText(context,
                  arabic: 'الحد الأدنى: ${bossMoney(wallet.minimumWithdrawal)}',
                  english: 'Minimum: ${bossMoney(wallet.minimumWithdrawal)}'),
            ),
          ),
          const SizedBox(height: 10),
          ScrollFx(
            child: WalletAmountCard(
              controller: _amount,
              onChanged: (_) => setState(() {}),
              onPreset: _setAmount,
              available: wallet.availableForWithdrawal,
            ),
          ),
          const SizedBox(height: 22),
          ScrollFx(
            child: WalletSectionTitle(
              title: headSupervisorText(context,
                  arabic: 'طريقة وحساب الاستلام',
                  english: 'Payout method and account'),
            ),
          ),
          const SizedBox(height: 8),
          if (wallet.payoutMethods.isNotEmpty)
            ScrollFx(
              child: WalletPayoutMethodSelector(
                methods: wallet.payoutMethods,
                selected: _method,
                onChanged: (value) => setState(() => _method = value),
              ),
            ),
          const SizedBox(height: 10),
          WalletInputField(
            controller: _destination,
            enabled: !_submitting,
            label: headSupervisorText(context,
                arabic: 'رقم الحساب / الآيبان / المحفظة المستلمة',
                english: 'Destination account / IBAN / wallet'),
            hint: 'SA44 8000 0001 0000 0000 5521',
            icon: _method == null
                ? Icons.account_balance_outlined
                : payoutMethodIcon(_method!),
          ),
          const SizedBox(height: 10),
          WalletInputField(
            controller: _otp,
            enabled: !_submitting,
            label: headSupervisorText(context,
                arabic: 'رمز التحقق (OTP)', english: 'Verification code (OTP)'),
            hint: '••••••',
            icon: Icons.password_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 8,
          ),
          const SizedBox(height: 12),
          const ScrollFx(child: WalletSecurityNotice()),
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const MotionIcon(Icons.send_outlined, size: 17),
              label: Text(
                _submitting
                    ? headSupervisorText(context,
                        arabic: 'جارٍ إرسال الطلب...', english: 'Sending request...')
                    : headSupervisorText(context,
                        arabic: 'تأكيد طلب السحب والتحويل الفوري',
                        english: 'Confirm instant withdrawal'),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: TextButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceLight,
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
              ),
              child: Text(
                  headSupervisorText(context,
                      arabic: 'إلغاء والعودة لملف الحساب',
                      english: 'Cancel and return to account'),
                  style: const TextStyle(fontSize: 10)),
            ),
          ),
          const SizedBox(height: 22),
          ScrollFx(
            child: WalletSectionTitle(
              title: headSupervisorText(context,
                  arabic: 'سجل العمليات المالية', english: 'Transaction history'),
            ),
          ),
          const SizedBox(height: 10),
          if (wallet.transactions.isEmpty)
            BossEmptyView(
              icon: Icons.receipt_long_outlined,
              message: headSupervisorText(context,
                  arabic: 'لا توجد عمليات مالية سابقة',
                  english: 'No previous transactions'),
            )
          else
            for (final transaction in wallet.transactions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: WalletTransactionCard(transaction: transaction),
              ),
        ],
      ),
    );
  }
}
