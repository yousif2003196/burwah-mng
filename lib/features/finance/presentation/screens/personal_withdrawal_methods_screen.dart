import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/finance_audit_store.dart';

enum _WithdrawalMethodType { bank, wallet }

class _PersonalWithdrawalMethod {
  final String id;
  final _WithdrawalMethodType type;
  final String provider;
  final String holderName;
  final String identifier;
  final bool isDefault;

  const _PersonalWithdrawalMethod({
    required this.id,
    required this.type,
    required this.provider,
    required this.holderName,
    required this.identifier,
    required this.isDefault,
  });

  _PersonalWithdrawalMethod copyWith({bool? isDefault}) =>
      _PersonalWithdrawalMethod(
        id: id,
        type: type,
        provider: provider,
        holderName: holderName,
        identifier: identifier,
        isDefault: isDefault ?? this.isDefault,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.name,
        'provider': provider,
        'holderName': holderName,
        'identifier': identifier,
        'isDefault': isDefault,
      };

  factory _PersonalWithdrawalMethod.fromJson(Map<String, dynamic> json) =>
      _PersonalWithdrawalMethod(
        id: json['id'] as String,
        type: _WithdrawalMethodType.values.firstWhere(
          (type) => type.name == json['type'],
          orElse: () => _WithdrawalMethodType.bank,
        ),
        provider: json['provider'] as String,
        holderName: json['holderName'] as String? ?? '',
        identifier: json['identifier'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

class PersonalWithdrawalMethodsScreen extends StatefulWidget {
  const PersonalWithdrawalMethodsScreen({super.key});

  @override
  State<PersonalWithdrawalMethodsScreen> createState() =>
      _PersonalWithdrawalMethodsScreenState();
}

class _PersonalWithdrawalMethodsScreenState
    extends State<PersonalWithdrawalMethodsScreen> {
  static const _storageKey = 'finance_profile_withdrawal_methods_v1';
  List<_PersonalWithdrawalMethod> _methods = [];
  bool _isLoading = true;
  Object? _loadError;

  bool get _isArabic =>
      AppLocalizations.of(context)!.localeName.startsWith('ar');

  String _copy(String ar, String en) => _isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_storageKey);
      final methods = <_PersonalWithdrawalMethod>[];
      if (saved != null) {
        final decoded = jsonDecode(saved);
        if (decoded is! List) {
          throw const FormatException('Withdrawal methods must be a list.');
        }
        for (final value in decoded) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Invalid withdrawal method.');
          }
          methods.add(_PersonalWithdrawalMethod.fromJson(value));
        }
      }
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

  Future<void> _persist(List<_PersonalWithdrawalMethod> methods) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(methods.map((method) => method.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save withdrawal methods.');
  }

  Future<void> _editMethod([_PersonalWithdrawalMethod? existing]) async {
    final formKey = GlobalKey<FormState>();
    var type = existing?.type ?? _WithdrawalMethodType.bank;
    final providerController = TextEditingController(
      text: existing?.provider ?? '',
    );
    final holderController = TextEditingController(
      text: existing?.holderName ?? '',
    );
    final identifierController = TextEditingController(
      text: existing?.identifier ?? '',
    );
    try {
      final result = await showDialog<_PersonalWithdrawalMethod>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(existing == null
                ? _copy('إضافة وسيلة سحب', 'Add withdrawal method')
                : _copy('تعديل وسيلة السحب', 'Edit withdrawal method')),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<_WithdrawalMethodType>(
                      initialValue: type,
                      decoration: InputDecoration(
                        labelText: _copy('نوع الوسيلة', 'Method type'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _WithdrawalMethodType.bank,
                          child: Text(_copy('حساب بنكي', 'Bank account')),
                        ),
                        DropdownMenuItem(
                          value: _WithdrawalMethodType.wallet,
                          child: Text(_copy('محفظة شخصية', 'Personal wallet')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => type = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: providerController,
                      decoration: InputDecoration(
                        labelText: type == _WithdrawalMethodType.bank
                            ? _copy('اسم البنك', 'Bank name')
                            : _copy('اسم المحفظة', 'Wallet provider'),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? _copy('هذا الحقل مطلوب', 'This field is required')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    if (type == _WithdrawalMethodType.bank) ...[
                      TextFormField(
                        controller: holderController,
                        decoration: InputDecoration(
                          labelText: _copy('اسم صاحب الحساب', 'Account holder'),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? _copy('هذا الحقل مطلوب', 'This field is required')
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: identifierController,
                      textDirection: TextDirection.ltr,
                      keyboardType: type == _WithdrawalMethodType.bank
                          ? TextInputType.text
                          : TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: type == _WithdrawalMethodType.bank
                            ? 'IBAN'
                            : _copy('رقم الجوال المرتبط بالمحفظة', 'Wallet phone number'),
                        hintText: type == _WithdrawalMethodType.bank
                            ? 'SA00 0000 0000 0000 0000 0000'
                            : '+9665XXXXXXXX',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? _copy('هذا الحقل مطلوب', 'This field is required')
                          : null,
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
                  Navigator.pop(
                    dialogContext,
                    _PersonalWithdrawalMethod(
                      id: existing?.id ??
                          'withdrawal-${DateTime.now().microsecondsSinceEpoch}',
                      type: type,
                      provider: providerController.text.trim(),
                      holderName: type == _WithdrawalMethodType.bank
                          ? holderController.text.trim()
                          : '',
                      identifier: identifierController.text.trim(),
                      isDefault: existing?.isDefault ?? _methods.isEmpty,
                    ),
                  );
                },
                child: Text(_copy('حفظ', 'Save')),
              ),
            ],
          ),
        ),
      );
      if (result == null || !mounted) return;
      final methods = [
        for (final method in _methods)
          if (method.id != result.id)
            result.isDefault ? method.copyWith(isDefault: false) : method,
        result,
      ];
      await _persist(methods);
      await _recordAudit(
        result,
        existing == null ? 'withdrawal_method_added' : 'withdrawal_method_updated',
        previous: existing,
      );
      if (mounted) setState(() => _methods = methods);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'personal withdrawal method save',
      ));
      if (mounted) _showMessage(_copy('تعذر حفظ وسيلة السحب.', 'Could not save the method.'));
    } finally {
      providerController.dispose();
      holderController.dispose();
      identifierController.dispose();
    }
  }

  Future<void> _setDefault(_PersonalWithdrawalMethod selected) async {
    final methods = [
      for (final method in _methods)
        method.copyWith(isDefault: method.id == selected.id),
    ];
    try {
      await _persist(methods);
      await _recordAudit(selected, 'withdrawal_method_default_changed');
      if (mounted) setState(() => _methods = methods);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'personal withdrawal default method',
      ));
      if (mounted) _showMessage(_copy('تعذر تحديث الوسيلة الافتراضية.', 'Could not update the default method.'));
    }
  }

  Future<void> _delete(_PersonalWithdrawalMethod selected) async {
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
    final remaining = _methods.where((method) => method.id != selected.id).toList();
    if (selected.isDefault && remaining.isNotEmpty) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }
    try {
      await _persist(remaining);
      await _recordAudit(selected, 'withdrawal_method_deleted');
      if (mounted) setState(() => _methods = remaining);
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
    _PersonalWithdrawalMethod method,
    String actionKey,
    { _PersonalWithdrawalMethod? previous }
   ) async {
    final now = DateTime.now();
    final isBank = method.type == _WithdrawalMethodType.bank;
    final identifierSuffix = method.identifier.length <= 4
        ? method.identifier
        : method.identifier.substring(method.identifier.length - 4);
    String summary(_PersonalWithdrawalMethod value, bool arabic) {
      final suffix = value.identifier.length <= 4
          ? value.identifier
          : value.identifier.substring(value.identifier.length - 4);
      final type = value.type == _WithdrawalMethodType.bank
          ? (arabic ? 'بنك' : 'Bank')
          : (arabic ? 'محفظة' : 'Wallet');
      return '$type: ${value.provider} · ${arabic ? 'آخر أرقام' : 'ending'} $suffix';
    }
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
            ? '${isBank ? 'بنك' : 'محفظة'}: ${method.provider} · آخر أرقام: $identifierSuffix'
            : 'قبل: ${summary(previous, true)} → بعد: ${summary(method, true)}',
        detailsEn: previous == null
            ? '${isBank ? 'Bank' : 'Wallet'}: ${method.provider} · ending $identifierSuffix'
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
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          title: Text(_copy('معلومات السحب الشخصية', 'Personal withdrawal details')),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading || _loadError != null ? null : () => _editMethod(),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
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
                : _methods.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined,
                                  color: AppColors.info, size: 46),
                              const SizedBox(height: 12),
                              Text(
                                _copy(
                                  'لا توجد وسائل سحب شخصية محفوظة. أضف حسابك البنكي أو محفظتك.',
                                  'No personal withdrawal methods saved. Add a bank account or wallet.',
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: () => _editMethod(),
                                icon: const Icon(Icons.add),
                                label: Text(_copy('إضافة وسيلة', 'Add method')),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: AppColors.infoDark),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    _copy(
                                      'هذه بيانات سحبك الشخصية، وهي منفصلة عن حسابات التشغيل.',
                                      'These personal withdrawal details are separate from operational accounts.',
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
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

  Widget _buildMethodCard(_PersonalWithdrawalMethod method) {
    final isBank = method.type == _WithdrawalMethodType.bank;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
                child: Icon(
                  isBank
                      ? Icons.account_balance_outlined
                      : Icons.account_balance_wallet_outlined,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.provider,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(
                      _copy(isBank ? 'حساب بنكي' : 'محفظة شخصية',
                          isBank ? 'Bank account' : 'Personal wallet'),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (method.isDefault)
                Chip(
                  label: Text(_copy('افتراضية', 'Default')),
                  visualDensity: VisualDensity.compact,
                  labelStyle: const TextStyle(fontSize: 10, color: AppColors.successDark),
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
                  PopupMenuItem(value: 'edit', child: Text(_copy('تعديل', 'Edit'))),
                  if (!method.isDefault)
                    PopupMenuItem(value: 'default', child: Text(_copy('تعيين كافتراضية', 'Set as default'))),
                  PopupMenuItem(value: 'delete', child: Text(_copy('حذف', 'Delete'))),
                ],
              ),
            ],
          ),
          const Divider(height: 22),
          if (isBank) ...[
            Text(_copy('صاحب الحساب', 'Account holder'),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            const SizedBox(height: 3),
            Text(method.holderName,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
            const SizedBox(height: 9),
          ],
          Text(isBank ? 'IBAN' : _copy('رقم الجوال', 'Phone number'),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 3),
          SelectableText(
            method.identifier,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
