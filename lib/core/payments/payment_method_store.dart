import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';

import 'payment_method.dart';
import 'payment_validators.dart';

/// Raw data typed by the user. For cards [identifier] is the full number; it
/// is reduced to the last four digits before anything is stored.
class PaymentMethodInput {
  final PaymentMethodType type;
  final WalletProvider? walletProvider;
  final String holderName;
  final String bankName;
  final String identifier;
  final int? expiryMonth;
  final int? expiryYear;

  const PaymentMethodInput({
    required this.type,
    required this.holderName,
    required this.identifier,
    this.walletProvider,
    this.bankName = '',
    this.expiryMonth,
    this.expiryYear,
  });
}

/// Returns an error code or null when the input is valid.
/// Codes: holder, bank, iban, instapay, mobile, provider, walletMismatch,
/// card, visaOnly, expiry.
String? validatePaymentMethodInput(PaymentMethodInput input, [DateTime? now]) {
  if (!isValidHolderName(input.holderName)) return 'holder';
  switch (input.type) {
    case PaymentMethodType.iban:
      if (input.bankName.trim().length < 2) return 'bank';
      return isValidEgyptianIban(input.identifier) ? null : 'iban';
    case PaymentMethodType.instapay:
      return isValidInstapayAddress(input.identifier) ? null : 'instapay';
    case PaymentMethodType.wallet:
      final provider = input.walletProvider;
      if (provider == null) return 'provider';
      if (!isValidEgyptianMobile(input.identifier)) return 'mobile';
      return walletProviderForMobile(input.identifier) == provider
          ? null
          : 'walletMismatch';
    case PaymentMethodType.card:
      if (!isValidCardNumber(input.identifier)) return 'card';
      if (!normalizeDigits(input.identifier).trim().startsWith('4')) {
        return 'visaOnly';
      }
      final month = input.expiryMonth;
      final year = input.expiryYear;
      if (month == null ||
          year == null ||
          !isValidCardExpiry(month, year, now ?? DateTime.now())) {
        return 'expiry';
      }
      return null;
  }
}

/// Local store for payment methods. Every account is approved by the admin
/// only: this store never activates a method by itself.
class PaymentMethodStore {
  static const _storageKey = 'payment_methods_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<List<PaymentMethod>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded == null) return [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid payment methods.');
    }
    return [
      for (final value in decoded)
        PaymentMethod.fromJson(value as Map<String, dynamic>),
    ];
  }

  Future<List<PaymentMethod>> forOwner(String ownerId) async =>
      (await loadAll()).where((m) => m.ownerId == ownerId).toList();

  /// Approved methods whose cool-down (if any) is over.
  Future<List<PaymentMethod>> usableFor(String ownerId) async =>
      (await forOwner(ownerId)).where((m) => m.isUsable()).toList();

  Future<void> _save(List<PaymentMethod> all) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _storageKey,
      jsonEncode(all.map((m) => m.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save payment methods.');
    revision.value++;
  }

  static String _normalizedIdentifier(PaymentMethodInput input) =>
      switch (input.type) {
        PaymentMethodType.iban => normalizeIban(input.identifier),
        PaymentMethodType.instapay =>
          normalizeInstapayAddress(input.identifier),
        PaymentMethodType.wallet =>
          normalizeEgyptianMobile(input.identifier) ?? input.identifier,
        PaymentMethodType.card => cardLast4(input.identifier),
      };

  static String _expiry(PaymentMethodInput input) =>
      '${input.expiryMonth.toString().padLeft(2, '0')}/${(input.expiryYear! % 100).toString().padLeft(2, '0')}';

  void _ensureValid(PaymentMethodInput input) {
    final error = validatePaymentMethodInput(input);
    if (error != null) throw ArgumentError(error);
  }

  void _ensureNoDuplicate(
    List<PaymentMethod> all,
    String ownerId,
    PaymentMethodInput input, {
    String? exceptId,
  }) {
    final identifier = _normalizedIdentifier(input);
    final duplicate = all.any((m) =>
        m.ownerId == ownerId &&
        m.id != exceptId &&
        m.type == input.type &&
        m.identifier == identifier &&
        (input.type != PaymentMethodType.card ||
            m.cardExpiry == _expiry(input)));
    if (duplicate) throw StateError('duplicate');
  }

  /// Adds a new method as `pendingAdmin` and sends it to the admin queue.
  Future<PaymentMethod> submit(
    PaymentMethodInput input, {
    required String ownerId,
    required String ownerRole,
  }) async {
    _ensureValid(input);
    final all = await loadAll();
    _ensureNoDuplicate(all, ownerId, input);
    final now = DateTime.now();
    final method = PaymentMethod(
      id: 'pm${now.microsecondsSinceEpoch}',
      ownerId: ownerId,
      ownerRole: ownerRole,
      type: input.type,
      walletProvider:
          input.type == PaymentMethodType.wallet ? input.walletProvider : null,
      holderName: input.holderName.trim(),
      providerName: input.type == PaymentMethodType.card
          ? 'Visa'
          : input.bankName.trim(),
      identifier: _normalizedIdentifier(input),
      cardExpiry: input.type == PaymentMethodType.card ? _expiry(input) : null,
      createdAt: now,
      updatedAt: now,
      isDefault: !all.any((m) => m.ownerId == ownerId),
    );
    await _save([...all, method]);
    await _sendToAdmin(method);
    return method;
  }

  /// Any change to the payout details sends the method back to the admin and
  /// blocks it until it is approved again.
  Future<PaymentMethod> update(String id, PaymentMethodInput input) async {
    _ensureValid(input);
    final all = await loadAll();
    final index = all.indexWhere((m) => m.id == id);
    if (index < 0) throw StateError('missing');
    final current = all[index];
    _ensureNoDuplicate(all, current.ownerId, input, exceptId: id);
    final identifier = _normalizedIdentifier(input);
    final changed = current.type != input.type ||
        current.identifier != identifier ||
        current.holderName != input.holderName.trim() ||
        current.walletProvider !=
            (input.type == PaymentMethodType.wallet
                ? input.walletProvider
                : null) ||
        (input.type == PaymentMethodType.iban &&
            current.providerName != input.bankName.trim());
    if (!changed) return current;
    final updated = current.copyWith(
      type: input.type,
      walletProvider: input.walletProvider,
      clearWalletProvider: input.type != PaymentMethodType.wallet,
      holderName: input.holderName.trim(),
      providerName: input.type == PaymentMethodType.card
          ? 'Visa'
          : input.bankName.trim(),
      identifier: identifier,
      cardExpiry: input.type == PaymentMethodType.card ? _expiry(input) : null,
      status: PaymentMethodStatus.pendingAdmin,
      version: current.version + 1,
      updatedAt: DateTime.now(),
      clearFrozenUntil: true,
      decisionNote: '',
    );
    all[index] = updated;
    await _save(all);
    await _sendToAdmin(updated);
    return updated;
  }

  Future<void> setDefault(String id) async {
    final all = await loadAll();
    final target = all.where((m) => m.id == id).firstOrNull;
    if (target == null) throw StateError('missing');
    if (!target.isUsable()) throw StateError('notUsable');
    await _save([
      for (final m in all)
        if (m.ownerId == target.ownerId) m.copyWith(isDefault: m.id == id) else m,
    ]);
  }

  Future<void> delete(String id) async {
    final all = await loadAll();
    final target = all.where((m) => m.id == id).firstOrNull;
    if (target == null) return;
    var remaining = all.where((m) => m.id != id).toList();
    if (target.isDefault) {
      final next = remaining
          .where((m) => m.ownerId == target.ownerId && m.isUsable())
          .firstOrNull;
      if (next != null) {
        remaining = [
          for (final m in remaining)
            m.id == next.id ? m.copyWith(isDefault: true) : m,
        ];
      }
    }
    await _save(remaining);
  }

  /// Called by the admin queue once the admin decides. Stale decisions
  /// (for an older version of the method) are ignored.
  Future<void> applyAdminDecision(
    String refId,
    AdminRequestStatus decision,
    String note,
  ) async {
    final match = RegExp(r'^pm-(.+)-v(\d+)$').firstMatch(refId);
    if (match == null) return;
    final id = match.group(1)!;
    final version = int.parse(match.group(2)!);
    final all = await loadAll();
    final index = all.indexWhere((m) => m.id == id);
    if (index < 0 || all[index].version != version) return;
    final method = all[index];
    final now = DateTime.now();
    all[index] = switch (decision) {
      AdminRequestStatus.approved => method.copyWith(
          status: PaymentMethodStatus.active,
          decisionNote: note,
          updatedAt: now,
          // First approval is immediate; re-approved edits cool down.
          frozenUntil: version > 1 ? now.add(kPaymentEditCooldown) : null,
          clearFrozenUntil: version <= 1,
        ),
      AdminRequestStatus.rejected => method.copyWith(
          status: PaymentMethodStatus.rejected,
          decisionNote: note,
          updatedAt: now,
        ),
      AdminRequestStatus.frozen => method.copyWith(
          status: PaymentMethodStatus.suspended,
          decisionNote: note,
          updatedAt: now,
        ),
      AdminRequestStatus.pending => method,
    };
    await _save(all);
  }

  /// When the admin unfreezes the request, a frozen method goes back to
  /// `pendingAdmin` (same version, so the reopened request still matches it).
  Future<void> reopenAfterUnfreeze(String refId) async {
    final match = RegExp(r'^pm-(.+)-v(\d+)$').firstMatch(refId);
    if (match == null) return;
    final id = match.group(1)!;
    final version = int.parse(match.group(2)!);
    final all = await loadAll();
    final index = all.indexWhere((m) => m.id == id);
    if (index < 0 ||
        all[index].version != version ||
        all[index].status != PaymentMethodStatus.suspended) {
      return;
    }
    all[index] = all[index].copyWith(
      status: PaymentMethodStatus.pendingAdmin,
      decisionNote: '',
      updatedAt: DateTime.now(),
    );
    await _save(all);
  }

  Future<void> _sendToAdmin(PaymentMethod m) {
    final shown = m.type == PaymentMethodType.card
        ? '•••• ${m.identifier}'
        : m.identifier;
    return AdminRequestStore().submit(AdminRequest(
      id: 'bankLink-${m.adminRefId}',
      kind: AdminRequestKind.bankLink,
      titleAr: m.version > 1
          ? 'تعديل وسيلة دفع بانتظار الاعتماد'
          : 'وسيلة دفع جديدة بانتظار الاعتماد',
      titleEn: m.version > 1
          ? 'Payment method change awaiting approval'
          : 'New payment method awaiting approval',
      detailsAr: '${m.channelLabelAr} — ${m.holderName} — $shown'
          '${m.providerName.isNotEmpty && m.type == PaymentMethodType.iban ? ' (${m.providerName})' : ''}.',
      detailsEn: '${m.channelLabelEn} — ${m.holderName} — $shown'
          '${m.providerName.isNotEmpty && m.type == PaymentMethodType.iban ? ' (${m.providerName})' : ''}.',
      fromAr: m.ownerRole == 'finance' ? 'المشرف المالي' : m.ownerRole,
      fromEn: m.ownerRole == 'finance' ? 'Finance supervisor' : m.ownerRole,
      origin: m.ownerRole,
      refId: m.adminRefId,
      createdAt: DateTime.now(),
    ));
  }
}
