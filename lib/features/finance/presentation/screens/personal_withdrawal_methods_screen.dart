import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/payments/payment_method.dart';
import 'package:barwah_app/core/payments/payment_method_store.dart';
import 'package:barwah_app/core/payments/payment_validators.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_audit_store.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_audit_entry.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

/// وسائل السحب الشخصية للمشرف المالي: IBAN، إنستاباي، محافظ، فيزا.
/// كل وسيلة (جديدة أو معدّلة) تُرسل للأدمن وتبقى غير قابلة للاستخدام حتى يعتمدها.
class PersonalWithdrawalMethodsScreen extends StatefulWidget {
  const PersonalWithdrawalMethodsScreen({super.key});

  @override
  State<PersonalWithdrawalMethodsScreen> createState() =>
      _PersonalWithdrawalMethodsScreenState();
}

class _PersonalWithdrawalMethodsScreenState
    extends State<PersonalWithdrawalMethodsScreen> {
  static const _ownerId = 'finance';
  static const _ownerRole = 'finance';
  final _store = PaymentMethodStore();
  List<PaymentMethod> _methods = [];
  bool _isLoading = true;
  Object? _loadError;

  bool get _isArabic =>
      AppLocalizations.of(context)!.localeName.startsWith('ar');

  String _copy(String ar, String en) => _isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    PaymentMethodStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    PaymentMethodStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final methods = await _store.forOwner(_ownerId);
      if (!mounted) return;
      setState(() {
        _methods = methods;
        _isLoading = false;
        _loadError = null;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'personal withdrawal methods',
      ));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = error;
        });
      }
    }
  }

  String _errorText(String code) => switch (code) {
        'holder' => _copy('اكتب الاسم الثنائي على الأقل', 'Enter at least two names'),
        'bank' => _copy('اكتب اسم البنك', 'Enter the bank name'),
        'iban' => _copy('IBAN مصري غير صحيح (EG + 27 رقم)', 'Invalid Egyptian IBAN (EG + 27 digits)'),
        'instapay' => _copy('عنوان إنستاباي أو رقم موبايل غير صحيح', 'Invalid InstaPay address or mobile'),
        'mobile' => _copy('رقم موبايل مصري غير صحيح', 'Invalid Egyptian mobile number'),
        'provider' => _copy('اختر المحفظة', 'Choose the wallet'),
        'walletMismatch' => _copy('رقم الموبايل لا يتبع المحفظة المختارة', 'The number does not belong to this wallet'),
        'card' => _copy('رقم البطاقة غير صحيح', 'Invalid card number'),
        'visaOnly' => _copy('مسموح ببطاقات فيزا فقط', 'Only Visa cards are accepted'),
        'expiry' => _copy('تاريخ الانتهاء غير صحيح أو منتهي', 'Invalid or expired date'),
        _ => _copy('بيانات غير صحيحة', 'Invalid data'),
      };

  PaymentMethodInput _inputFrom(PaymentMethod m) => PaymentMethodInput(
        type: m.type,
        walletProvider: m.walletProvider,
        holderName: m.holderName,
        bankName: m.type == PaymentMethodType.iban ? m.providerName : '',
        identifier: m.identifier,
      );

  Future<void> _editMethod([PaymentMethod? existing]) async {
    final formKey = GlobalKey<FormState>();
    var type = existing?.type ?? PaymentMethodType.iban;
    var provider = existing?.walletProvider;
    final holder = TextEditingController(text: existing?.holderName ?? '');
    final bank = TextEditingController(
      text: existing?.type == PaymentMethodType.iban ? existing!.providerName : '',
    );
    final identifier = TextEditingController(text: existing?.identifier ?? '');
    final month = TextEditingController();
    final year = TextEditingController();
    try {
      final input = await showDialog<PaymentMethodInput>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            PaymentMethodInput build() => PaymentMethodInput(
                  type: type,
                  walletProvider: provider,
                  holderName: holder.text,
                  bankName: bank.text,
                  identifier: identifier.text,
                  expiryMonth: int.tryParse(normalizeDigits(month.text)),
                  expiryYear: int.tryParse(normalizeDigits(year.text)),
                );
            String? check(String code, String? value) =>
                validatePaymentMethodInput(build()) == code
                    ? _errorText(code)
                    : null;
            return AlertDialog(
              title: Text(existing == null
                  ? _copy('إضافة وسيلة سحب', 'Add withdrawal method')
                  : _copy('تعديل وسيلة السحب', 'Edit withdrawal method')),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<PaymentMethodType>(
                        initialValue: type,
                        decoration: InputDecoration(
                          labelText: _copy('نوع الوسيلة', 'Method type'),
                        ),
                        items: [
                          for (final t in PaymentMethodType.values)
                            DropdownMenuItem(
                              value: t,
                              child: Text(_copy(t.labelAr, t.labelEn)),
                            ),
                        ],
                        onChanged: existing != null
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() => type = value);
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: holder,
                        decoration: InputDecoration(
                          labelText: _copy('اسم صاحب الحساب', 'Account holder'),
                        ),
                        validator: (v) => check('holder', v),
                      ),
                      const SizedBox(height: 12),
                      if (type == PaymentMethodType.iban) ...[
                        TextFormField(
                          controller: bank,
                          decoration: InputDecoration(
                            labelText: _copy('اسم البنك', 'Bank name'),
                          ),
                          validator: (v) => check('bank', v),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (type == PaymentMethodType.wallet) ...[
                        DropdownButtonFormField<WalletProvider>(
                          initialValue: provider,
                          decoration: InputDecoration(
                            labelText: _copy('المحفظة', 'Wallet'),
                          ),
                          items: [
                            for (final w in WalletProvider.values)
                              DropdownMenuItem(
                                value: w,
                                child: Text(_copy(w.labelAr, w.labelEn)),
                              ),
                          ],
                          onChanged: (value) =>
                              setDialogState(() => provider = value),
                          validator: (v) => check('provider', null),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: identifier,
                        textDirection: TextDirection.ltr,
                        keyboardType: type == PaymentMethodType.iban ||
                                type == PaymentMethodType.instapay
                            ? TextInputType.text
                            : TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: switch (type) {
                            PaymentMethodType.iban => 'IBAN',
                            PaymentMethodType.instapay =>
                              _copy('عنوان إنستاباي أو رقم الموبايل', 'InstaPay address or mobile'),
                            PaymentMethodType.wallet =>
                              _copy('رقم موبايل المحفظة', 'Wallet mobile number'),
                            PaymentMethodType.card =>
                              _copy('رقم البطاقة', 'Card number'),
                          },
                          hintText: switch (type) {
                            PaymentMethodType.iban => 'EG00 0000 0000 0000 0000 0000 0000 0',
                            PaymentMethodType.instapay => 'name@instapay',
                            PaymentMethodType.wallet => '01XXXXXXXXX',
                            PaymentMethodType.card => '4XXX XXXX XXXX XXXX',
                          },
                        ),
                        validator: (v) {
                          final code = validatePaymentMethodInput(build());
                          const ids = {'iban', 'instapay', 'mobile', 'walletMismatch', 'card', 'visaOnly'};
                          return ids.contains(code) ? _errorText(code!) : null;
                        },
                      ),
                      if (type == PaymentMethodType.card) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: month,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _copy('الشهر', 'Month'),
                                  hintText: 'MM',
                                ),
                                validator: (v) => check('expiry', v),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: year,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _copy('السنة', 'Year'),
                                  hintText: 'YY',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _copy(
                            'لا نحفظ رقم البطاقة كاملاً ولا رمز CVV؛ نحتفظ بآخر 4 أرقام فقط.',
                            'The full number and CVV are never stored; only the last 4 digits are kept.',
                          ),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        _copy(
                          'تُرسل الوسيلة للأدمن للاعتماد، ولا يمكن السحب عليها قبل ذلك.',
                          'The method is sent to the admin and cannot be used until approved.',
                        ),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(_copy('إلغاء', 'Cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(dialogContext, build());
                  },
                  child: Text(_copy('إرسال للاعتماد', 'Submit for approval')),
                ),
              ],
            );
          },
        ),
      );
      if (input == null || !mounted) return;
      final saved = existing == null
          ? await _store.submit(input, ownerId: _ownerId, ownerRole: _ownerRole)
          : await _store.update(existing.id, input);
      await _recordAudit(
        saved,
        existing == null ? 'withdrawal_method_added' : 'withdrawal_method_updated',
        previous: existing,
      );
      if (mounted) {
        _showMessage(_copy(
          'تم إرسال الوسيلة للأدمن بانتظار الاعتماد.',
          'Sent to the admin for approval.',
        ));
      }
    } on StateError catch (error) {
      if (mounted) {
        _showMessage(error.message == 'duplicate'
            ? _copy('هذه الوسيلة مسجلة بالفعل.', 'This method already exists.')
            : _copy('تعذر حفظ وسيلة السحب.', 'Could not save the method.'));
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'personal withdrawal method save',
      ));
      if (mounted) _showMessage(_copy('تعذر حفظ وسيلة السحب.', 'Could not save the method.'));
    } finally {
      holder.dispose();
      bank.dispose();
      identifier.dispose();
      month.dispose();
      year.dispose();
    }
  }

  Future<void> _setDefault(PaymentMethod selected) async {
    try {
      await _store.setDefault(selected.id);
      await _recordAudit(selected, 'withdrawal_method_default_changed');
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'personal withdrawal default method',
      ));
      if (mounted) _showMessage(_copy('تعذر تحديث الوسيلة الافتراضية.', 'Could not update the default method.'));
    }
  }

  Future<void> _delete(PaymentMethod selected) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_copy('حذف وسيلة السحب؟', 'Delete withdrawal method?')),
        content: Text(_copy(
          'سيتم حذف هذه الوسيلة من بياناتك الشخصية.',
          'This method will be removed from your personal details.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_copy('إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_copy('حذف', 'Delete')),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _store.delete(selected.id);
      await _recordAudit(selected, 'withdrawal_method_deleted');
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'personal withdrawal method deletion',
      ));
      if (mounted) _showMessage(_copy('تعذر حذف الوسيلة.', 'Could not delete the method.'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _recordAudit(
    PaymentMethod method,
    String actionKey, {
    PaymentMethod? previous,
  }) async {
    final now = DateTime.now();
    String summary(PaymentMethod value, bool arabic) =>
        '${arabic ? value.channelLabelAr : value.channelLabelEn} · ${value.masked}';
    try {
      await FinanceAuditStore().record(FinanceAuditEntry(
        id: '$actionKey-${now.microsecondsSinceEpoch}',
        actionKey: actionKey,
        titleAr: switch (actionKey) {
          'withdrawal_method_added' => 'إضافة وسيلة سحب شخصية',
          'withdrawal_method_updated' => 'تعديل وسيلة سحب شخصية',
          'withdrawal_method_default_changed' => 'تغيير وسيلة السحب الافتراضية',
          _ => 'حذف وسيلة سحب شخصية',
        },
        titleEn: switch (actionKey) {
          'withdrawal_method_added' => 'Personal withdrawal method added',
          'withdrawal_method_updated' => 'Personal withdrawal method updated',
          'withdrawal_method_default_changed' => 'Default withdrawal method changed',
          _ => 'Personal withdrawal method deleted',
        },
        detailsAr: previous == null
            ? summary(method, true)
            : 'قبل: ${summary(previous, true)} → بعد: ${summary(method, true)}',
        detailsEn: previous == null
            ? summary(method, false)
            : 'Before: ${summary(previous, false)} → After: ${summary(method, false)}',
        reference: method.id,
        actor: 'finance',
        occurredAt: now,
      ));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'personal withdrawal method audit',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _isArabic;
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(_copy('معلومات السحب الشخصية', 'Personal withdrawal details')),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading || _loadError != null ? null : () => _editMethod(),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          icon: const MotionIcon(Icons.add),
          label: Text(_copy('إضافة وسيلة', 'Add method')),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_copy('تعذر تحميل بيانات السحب.', 'Could not load withdrawal details.')),
                        const SizedBox(height: 10),
                        FilledButton(onPressed: _load, child: Text(_copy('إعادة المحاولة', 'Retry'))),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      ScrollFx(child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            MotionIcon(Icons.info_outline, color: AppColors.infoDark),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                _copy(
                                  'كل وسيلة سحب (جديدة أو معدّلة) يعتمدها الأدمن قبل استخدامها، وبعد تعديل وسيلة معتمدة يُوقف السحب عليها 24 ساعة.',
                                  'Every withdrawal method (new or edited) must be approved by the admin; an edited method is blocked for 24 hours after re-approval.',
                                ),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 12),
                      if (_methods.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            _copy(
                              'لا توجد وسائل سحب محفوظة. أضف حساباً بنكياً أو إنستاباي أو محفظة أو بطاقة.',
                              'No withdrawal methods yet. Add a bank account, InstaPay, wallet or card.',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      for (final method in _methods)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildMethodCard(method),
                        ),
                    ],
                  ),
      ),
    );
  }

  IconData _iconOf(PaymentMethodType type) => switch (type) {
        PaymentMethodType.iban => Icons.account_balance_outlined,
        PaymentMethodType.instapay => Icons.bolt_rounded,
        PaymentMethodType.wallet => Icons.account_balance_wallet_outlined,
        PaymentMethodType.card => Icons.credit_card_outlined,
      };

  (Color, Color) _statusColors(PaymentMethodStatus status) => switch (status) {
        PaymentMethodStatus.active => (AppColors.successLight, AppColors.successDark),
        PaymentMethodStatus.pendingAdmin => (AppColors.surfaceLight, AppColors.infoDark),
        PaymentMethodStatus.rejected => (AppColors.dangerLight, AppColors.dangerDark),
        PaymentMethodStatus.suspended => (AppColors.dangerLight, AppColors.dangerDark),
      };

  Widget _buildMethodCard(PaymentMethod method) {
    final (bg, fg) = _statusColors(method.status);
    final cooling = method.status == PaymentMethodStatus.active && method.isCooling;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.surfaceLight,
                child: MotionIcon(_iconOf(method.type), color: AppColors.ink),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _copy(method.channelLabelAr, method.channelLabelEn),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      method.holderName,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (method.isDefault && method.isUsable())
                Chip(
                  label: Text(_copy('افتراضية', 'Default')),
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(fontSize: 10, color: AppColors.successDark),
                  backgroundColor: AppColors.successLight,
                  side: BorderSide.none,
                ),
              PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') _editMethod(method);
                  if (action == 'default') _setDefault(method);
                  if (action == 'delete') _delete(method);
                },
                itemBuilder: (context) => [
                  if (method.type != PaymentMethodType.card)
                    PopupMenuItem(value: 'edit', child: Text(_copy('تعديل', 'Edit'))),
                  if (!method.isDefault && method.isUsable())
                    PopupMenuItem(value: 'default', child: Text(_copy('تعيين كافتراضية', 'Set as default'))),
                  PopupMenuItem(value: 'delete', child: Text(_copy('حذف', 'Delete'))),
                ],
              ),
            ],
          ),
          const Divider(height: 22),
          if (method.type == PaymentMethodType.iban && method.providerName.isNotEmpty) ...[
            Text(method.providerName,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  method.masked,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (method.type != PaymentMethodType.card)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: _copy('نسخ', 'Copy'),
                  icon: const MotionIcon(Icons.copy, size: 16),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: method.identifier)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _copy(method.status.labelAr, method.status.labelEn),
              style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          if (cooling)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _copy(
                  'السحب على هذه الوسيلة متوقف حتى انتهاء فترة الحماية بعد التعديل.',
                  'Payouts are blocked until the post-edit protection period ends.',
                ),
                style: TextStyle(color: AppColors.warning, fontSize: 10),
              ),
            ),
          if (method.decisionNote.isNotEmpty &&
              (method.status == PaymentMethodStatus.rejected ||
                  method.status == PaymentMethodStatus.suspended))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${_copy('ملاحظة الأدمن', 'Admin note')}: ${method.decisionNote}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
