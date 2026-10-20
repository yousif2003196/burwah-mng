import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../head_supervisor_text.dart';
import '../../data/head_supervisor_audit_store.dart';
import '../../../wasalny_supervisor/data/wasalny_local_event_store.dart';

class HeadSupervisorWalletScreen extends StatefulWidget {
  const HeadSupervisorWalletScreen({super.key});

  @override
  State<HeadSupervisorWalletScreen> createState() =>
      _HeadSupervisorWalletScreenState();
}

class _HeadSupervisorWalletScreenState extends State<HeadSupervisorWalletScreen> {
  final _amountController = TextEditingController(text: '38000');
  String _accountType = 'حساب بنكي';
  String _selectedAccount = 'مصرف الراجحي';
  bool _submitting = false;

  static const _accounts = [
    _PayoutAccount(
      bank: 'مصرف الراجحي',
      number: 'SA44 8000 0001 •••• 5521',
      badge: 'الأساسي المعتمد',
    ),
    _PayoutAccount(
      bank: 'البنك الأهلي السعودي (SNB)',
      number: 'SA12 1000 0000 •••• 8894',
      badge: 'حساب بدلات إشرافية معتمد',
    ),
  ];

  static const _transactions = [
    _WalletTransaction(
      amount: '15,000 ر.س',
      bank: 'مصرف الراجحي',
      date: '12 يناير 2025',
      code: 'TXN-90218',
    ),
    _WalletTransaction(
      amount: '12,500 ر.س',
      bank: 'مصرف الراجحي',
      date: '28 ديسمبر 2024',
      code: 'TXN-87421',
    ),
    _WalletTransaction(
      amount: '8,000 ر.س',
      bank: 'الأهلي (SNB)',
      date: '15 ديسمبر 2024',
      code: 'TXN-84190',
    ),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  void _setAmount(int amount) {
    _amountController.text = '$amount';
    setState(() {});
  }

  Future<void> _submitRequest() async {
    if (_submitting) return;
    if (_amount < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'الحد الأدنى لطلب السحب هو 500 ر.س.', english: 'The minimum withdrawal is SAR 500.'))),
      );
      return;
    }
    if (_amount > 38000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'المبلغ يتجاوز الرصيد المتاح للسحب الفوري.', english: 'The amount exceeds the available balance.'))),
      );
      return;
    }

    setState(() => _submitting = true);
    final requestId = DateTime.now().millisecondsSinceEpoch;
    try {
      await HeadSupervisorAuditStore().record(
        HeadSupervisorAuditRecord(
          id: 'head-wallet-withdrawal-$requestId',
          subjectId: 'WDR-$requestId',
          kind: 'wallet',
          title: 'طلب سحب مالي بقيمة ${_amount.toStringAsFixed(0)} ر.س',
          details: 'تم إرسال الطلب إلى الإدارة المالية للتحقق من الحساب $_selectedAccount.',
          department: 'المحفظة',
          occurredAt: DateTime.now(),
        ),
      );
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
          id: 'head-wallet-withdrawal-$requestId',
          recipient: 'finance',
          source: 'head',
          titleAr: 'طلب سحب مالي جديد',
          titleEn: 'New wallet withdrawal request',
          messageAr:
              'طلب رئيس المشرفين تحويل ${_amount.toStringAsFixed(0)} ر.س إلى $_selectedAccount عبر التحويل البنكي الفوري (SARIE).',
          messageEn:
              'The head supervisor requested an instant SARIE transfer of ${_amount.toStringAsFixed(0)} SAR to $_selectedAccount.',
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'تم إرسال طلب السحب إلى الإدارة المالية للمراجعة.', english: 'Withdrawal request sent to Finance for review.'))),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor wallet request',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'تعذر إرسال الطلب. حاول مرة أخرى.', english: 'Could not send the request. Try again.'))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward),
        ),
        title: Text(headSupervisorText(context, arabic: 'محفظة رئيس المشرفين', english: 'Supervisor Wallet'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryDark,
              child: Icon(Icons.shield_outlined, color: Colors.white, size: 17),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _WalletSummaryCard(),
          const SizedBox(height: 22),
          _SectionTitle(title: headSupervisorText(context, arabic: 'طلب صرف وتحويل فوري', english: 'Instant withdrawal'), trailing: headSupervisorText(context, arabic: 'الحد الأدنى: 500 ر.س', english: 'Minimum: SAR 500')),
          const SizedBox(height: 10),
          _WithdrawalAmountCard(
            controller: _amountController,
            onChanged: (_) => setState(() {}),
            onPreset: _setAmount,
          ),
          const SizedBox(height: 22),
          _SectionTitle(
            title: headSupervisorText(context, arabic: 'طريقة وحساب الاستلام', english: 'Payout method and account'),
            action: TextButton.icon(
              onPressed: _showAddAccountDialog,
              icon: const Icon(Icons.add_circle_outline, size: 15),
              label: Text(headSupervisorText(context, arabic: 'إضافة وجهة جديدة', english: 'Add payout destination'), style: const TextStyle(fontSize: 10)),
            ),
          ),
          const SizedBox(height: 8),
          _PayoutMethodSelector(
            selected: _accountType,
            onChanged: (value) => setState(() => _accountType = value),
          ),
          const SizedBox(height: 10),
          for (final account in _accounts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PayoutAccountCard(
                account: account,
                selected: _selectedAccount == account.bank,
                onTap: () => setState(() => _selectedAccount = account.bank),
              ),
            ),
          const SizedBox(height: 12),
          const _SecurityNotice(),
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submitRequest,
              icon: _submitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_outlined, size: 17),
              label: Text(
                _submitting
                    ? headSupervisorText(context, arabic: 'جارٍ إرسال الطلب...', english: 'Sending request...')
                    : headSupervisorText(context, arabic: 'تأكيد طلب السحب والتحويل البنكي الفوري (SARIE)', english: 'Confirm instant bank withdrawal (SARIE)'),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF0F2F4),
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: Text(headSupervisorText(context, arabic: 'إلغاء والعودة لملف الحساب', english: 'Cancel and return to account'), style: const TextStyle(fontSize: 10)),
            ),
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: headSupervisorText(context, arabic: 'سجل عمليات الصرف السابقة', english: 'Withdrawal history'), action: null, trailing: headSupervisorText(context, arabic: 'عرض الأرشيف المالي', english: 'View financial archive')),
          const SizedBox(height: 10),
          for (final transaction in _transactions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TransactionCard(transaction: transaction),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddAccountDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(headSupervisorText(context, arabic: 'إضافة وجهة استلام', english: 'Add payout destination')),
        content: Text(headSupervisorText(context, arabic: 'تُضاف الحسابات البنكية بعد التحقق من ملكيتها عبر النفاذ الوطني.', english: 'Bank accounts can be added after ownership is verified through Nafath.')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(headSupervisorText(context, arabic: 'حسناً', english: 'OK')))],
      ),
    );
  }
}

class _WalletSummaryCard extends StatelessWidget {
  const _WalletSummaryCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _WalletPill(text: headSupervisorText(context, arabic: 'نظام رسمي نشط', english: 'Official system active'), icon: Icons.circle, dot: true),
            _WalletPill(text: headSupervisorText(context, arabic: 'اعتماد الرقابة المالية الإدارية', english: 'Financial oversight approved'), icon: Icons.verified_user_outlined),
          ]),
          const SizedBox(height: 17),
          Text(headSupervisorText(context, arabic: 'إجمالي المستحقات المعتمدة للإشراف', english: 'Total approved supervisor earnings'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Color(0xFF9CB2CD))),
          const SizedBox(height: 3),
          Text(headSupervisorText(context, arabic: '45,800.00 ر.س', english: 'SAR 45,800.00'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 17),
          Row(children: [
            Expanded(child: _BalanceTile(label: headSupervisorText(context, arabic: 'الرصيد المعلق', english: 'Pending balance'), value: '7,800.00', icon: Icons.hourglass_top)),
            const SizedBox(width: 8),
            Expanded(child: _BalanceTile(label: headSupervisorText(context, arabic: 'المتاح للسحب الفوري', english: 'Available for withdrawal'), value: '38,000.00', icon: Icons.account_balance_wallet_outlined, emphasized: true)),
          ]),
        ]),
      );
}

class _WithdrawalAmountCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<int> onPreset;
  const _WithdrawalAmountCard({required this.controller, required this.onChanged, required this.onPreset});

  @override
  Widget build(BuildContext context) => _WhitePanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(headSupervisorText(context, arabic: 'المبلغ المطلوب سحبه', english: 'Withdrawal amount'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 5),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
          _WalletPill(text: headSupervisorText(context, arabic: 'ريال SAR', english: 'SAR')),
              const Spacer(),
              SizedBox(
                width: 125,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  decoration: const InputDecoration(border: InputBorder.none, suffixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF315F9A))),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 15),
          Text(headSupervisorText(context, arabic: 'تحديد مبلغ سريع', english: 'Quick amount'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 7),
          Wrap(alignment: WrapAlignment.spaceBetween, runSpacing: 7, children: [
            _PresetButton(label: headSupervisorText(context, arabic: 'كامل المتاح (38,000)', english: 'Full available (38,000)'), selected: true, icon: Icons.bolt, onTap: () => onPreset(38000)),
            _PresetButton(label: headSupervisorText(context, arabic: '20,000 ر.س', english: 'SAR 20,000'), onTap: () => onPreset(20000)),
            _PresetButton(label: headSupervisorText(context, arabic: '10,000 ر.س', english: 'SAR 10,000'), onTap: () => onPreset(10000)),
            _PresetButton(label: headSupervisorText(context, arabic: '5,000 ر.س', english: 'SAR 5,000'), onTap: () => onPreset(5000)),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.info_outline, color: Color(0xFF315F9A), size: 17),
              const SizedBox(width: 6),
              Expanded(child: Text(headSupervisorText(context, arabic: 'تتم معالجة وإيداع المبالغ فورياً على مدار الساعة وطوال أيام الأسبوع عبر نظام المدفوعات الفورية السريع (SARIE).', english: 'Transfers are processed instantly, 24/7, through the SARIE instant payment system.'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, height: 1.4, color: AppColors.textSecondary))),
            ]),
          ),
        ]),
      );
}

class _PayoutMethodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _PayoutMethodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFFE5E7E9), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          for (final method in const ['حساب بنكي', 'إنستاباي (IPA)', 'محفظة ذكية'])
            Expanded(
              child: InkWell(
                onTap: () => onChanged(method),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
                  decoration: BoxDecoration(color: method == selected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(method == 'حساب بنكي' ? Icons.account_balance_outlined : method.startsWith('إنستاباي') ? Icons.bolt : Icons.wallet_outlined, size: 15, color: AppColors.primaryDark),
                    const SizedBox(width: 3),
                    Flexible(child: Text(headSupervisorText(context, arabic: method, english: switch (method) { 'حساب بنكي' => 'Bank account', 'إنستاباي (IPA)' => 'Instapay (IPA)', _ => 'Digital wallet' }), textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: AppColors.textPrimary))),
                  ]),
                ),
              ),
            ),
        ]),
      );
}

class _PayoutAccount {
  final String bank;
  final String number;
  final String badge;
  const _PayoutAccount({required this.bank, required this.number, required this.badge});
}

class _PayoutAccountCard extends StatelessWidget {
  final _PayoutAccount account;
  final bool selected;
  final VoidCallback onTap;
  const _PayoutAccountCard({required this.account, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7EAED)), borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Icon(Icons.account_balance_outlined, color: selected ? const Color(0xFF315F9A) : AppColors.textSecondary, size: 19),
                const SizedBox(width: 8),
                const Spacer(),
                if (account.badge == 'الأساسي المعتمد') _WalletPill(text: headSupervisorText(context, arabic: 'الأساسي المعتمد', english: 'Primary verified'), blue: true),
                const SizedBox(width: 6),
                Text(account.bank, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                const SizedBox(width: 7),
                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? AppColors.primaryDark : const Color(0xFFE1E4E7), size: 19),
              ]),
              const SizedBox(height: 8),
              Text(account.number, textAlign: TextAlign.left, style: const TextStyle(fontSize: 12, letterSpacing: .5, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [const Icon(Icons.verified_outlined, size: 13, color: Color(0xFF315F9A)), const SizedBox(width: 4), Text(account.badge == 'الأساسي المعتمد' ? headSupervisorText(context, arabic: 'موثق بالبنك المركزي السعودي (SAMA) • معتمد', english: 'Verified by Saudi Central Bank (SAMA)') : headSupervisorText(context, arabic: account.badge, english: account.badge == 'حساب بدلات إشرافية معتمد' ? 'Verified supervisor allowances account' : account.badge), style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))]),
            ]),
          ),
        ),
      );
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.lock_outline, color: AppColors.primaryDark, size: 20),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(headSupervisorText(context, arabic: 'التحقق والحوكمة الإدارية المشددة', english: 'Verification and administrative governance'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            const SizedBox(height: 5),
            Text(headSupervisorText(context, arabic: 'لضمان سلامة العمليات المالية الحساسة، يتم إرسال رمز تحقق مؤقت عبر نفاذ الوطني أو رسالة نصية مسجلة إلى جوال رئيس المشرفين المعتمد قبل تنفيذ وتأكيد الحوالة.', english: 'For security, a one-time verification code is sent through Nafath or SMS to the approved Head Supervisor phone before the transfer is confirmed.'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, height: 1.45, color: Color(0xFF315F9A))),
          ])),
        ]),
      );
}

class _TransactionCard extends StatelessWidget {
  final _WalletTransaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE8EBEF)), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const CircleAvatar(radius: 17, backgroundColor: Color(0xFFF0F2F4), child: Icon(Icons.south_west, size: 17, color: AppColors.primaryDark)),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(headSupervisorText(context, arabic: transaction.amount, english: transaction.amount.replaceAll(' ر.س', ' SAR')), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), Flexible(child: Text(headSupervisorText(context, arabic: 'سحب فوري - ${transaction.bank}', english: 'Instant withdrawal • ${transaction.bank}'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: AppColors.textPrimary)))]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(headSupervisorText(context, arabic: '● ناجح', english: '● Successful'), style: const TextStyle(fontSize: 8, color: Color(0xFF315F9A))), const SizedBox(width: 12), Text(transaction.code, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), const SizedBox(width: 7), const Text('•', style: TextStyle(fontSize: 8, color: AppColors.textMuted)), const SizedBox(width: 7), Text(headSupervisorText(context, arabic: transaction.date, english: switch (transaction.date) { '12 يناير 2025' => 'Jan 12, 2025', '28 ديسمبر 2024' => 'Dec 28, 2024', _ => 'Dec 15, 2024' }), style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))]),
          ])),
        ]),
      );
}

class _WalletTransaction {
  final String amount;
  final String bank;
  final String date;
  final String code;
  const _WalletTransaction({required this.amount, required this.bank, required this.date, required this.code});
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget? action;
  const _SectionTitle({required this.title, this.trailing, this.action});

  @override
  Widget build(BuildContext context) => Row(children: [
        if (action != null) action!,
        if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
        const Spacer(),
        Container(width: 4, height: 14, decoration: BoxDecoration(color: const Color(0xFF315F9A), borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
      ]);
}

class _WhitePanel extends StatelessWidget {
  final Widget child;
  const _WhitePanel({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE8EBEF)), borderRadius: BorderRadius.circular(15)),
        child: child,
      );
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;
  const _PresetButton({required this.label, required this.onTap, this.selected = false, this.icon});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(color: selected ? const Color(0xFFD8E5FF) : const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(9)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [if (icon != null) Icon(icon, size: 13, color: AppColors.primaryDark), Text(label, style: TextStyle(fontSize: 8, color: AppColors.textPrimary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))]),
        ),
      );
}

class _WalletPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool blue;
  final bool dot;
  const _WalletPill({required this.text, this.icon, this.blue = false, this.dot = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: blue ? const Color(0xFFD8E5FF) : const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(9)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text, style: TextStyle(fontSize: 7, color: blue ? const Color(0xFF315F9A) : AppColors.textSecondary, fontWeight: FontWeight.w600)),
          if (icon != null) ...[const SizedBox(width: 4), Icon(icon, size: 11, color: blue ? const Color(0xFF315F9A) : AppColors.textSecondary)],
          if (dot) ...[const SizedBox(width: 4), const Icon(Icons.circle, size: 7, color: Color(0xFF9CC3FF))],
        ]),
      );
}

class _BalanceTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool emphasized;
  const _BalanceTile({required this.label, required this.value, required this.icon, this.emphasized = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: emphasized ? const Color(0xFF243F63) : const Color(0xFF1B3658), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF9CB2CD))), const SizedBox(width: 4), Icon(icon, size: 14, color: const Color(0xFFB7CAE1))]),
          const SizedBox(height: 5),
          Text(headSupervisorText(context, arabic: '$value ر.س', english: 'SAR $value'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 3),
          Text(emphasized ? headSupervisorText(context, arabic: 'متاح ومؤهل للتحويل', english: 'Available for transfer') : headSupervisorText(context, arabic: 'بدلات قيد التدقيق المحاسبي', english: 'Allowances under accounting review'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 7, color: Color(0xFF9CB2CD))),
        ]),
      );
}
