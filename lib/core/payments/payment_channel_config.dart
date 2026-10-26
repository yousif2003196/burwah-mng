import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'payment_method.dart';
import 'payment_validators.dart';

/// Channels the admin can configure. Wallets are separate channels because
/// each network has its own limits and fees.
enum PaymentChannel {
  bankTransfer('تحويل بنكي (IBAN)', 'Bank transfer (IBAN)'),
  instapay('إنستاباي', 'InstaPay'),
  vodafoneCash('فودافون كاش', 'Vodafone Cash'),
  orangeCash('أورانج كاش', 'Orange Cash'),
  etisalatCash('اتصالات كاش', 'Etisalat Cash'),
  weCash('وي كاش', 'WE Pay'),
  card('بطاقة فيزا', 'Visa card');

  final String labelAr;
  final String labelEn;
  const PaymentChannel(this.labelAr, this.labelEn);
}

PaymentChannel channelOf(PaymentMethod method) => switch (method.type) {
      PaymentMethodType.iban => PaymentChannel.bankTransfer,
      PaymentMethodType.instapay => PaymentChannel.instapay,
      PaymentMethodType.card => PaymentChannel.card,
      PaymentMethodType.wallet => switch (method.walletProvider) {
          WalletProvider.orange => PaymentChannel.orangeCash,
          WalletProvider.etisalat => PaymentChannel.etisalatCash,
          WalletProvider.we => PaymentChannel.weCash,
          _ => PaymentChannel.vodafoneCash,
        },
    };

class PaymentChannelConfig {
  final PaymentChannel channel;
  final bool enabled;
  final double minAmount;
  final double maxAmount;
  final double dailyLimit;
  final double feePercent;
  final double feeFixed;

  const PaymentChannelConfig({
    required this.channel,
    this.enabled = true,
    this.minAmount = 10,
    this.maxAmount = 50000,
    this.dailyLimit = 200000,
    this.feePercent = 0,
    this.feeFixed = 0,
  });

  /// Returns an error code or null: minNegative, maxBelowMin, dailyBelowMax,
  /// feeNegative, feePercentTooHigh.
  String? validate() {
    if (minAmount < 0) return 'minNegative';
    if (maxAmount < minAmount) return 'maxBelowMin';
    if (dailyLimit < maxAmount) return 'dailyBelowMax';
    if (feePercent < 0 || feeFixed < 0) return 'feeNegative';
    if (feePercent > 10) return 'feePercentTooHigh';
    return null;
  }

  /// Returns an error code or null: disabled, belowMin, aboveMax, aboveDaily.
  String? checkAmount(double amount, {double sentToday = 0}) {
    if (!enabled) return 'disabled';
    if (amount < minAmount) return 'belowMin';
    if (amount > maxAmount) return 'aboveMax';
    if (sentToday + amount > dailyLimit) return 'aboveDaily';
    return null;
  }

  double feeFor(double amount) =>
      double.parse((amount * feePercent / 100 + feeFixed).toStringAsFixed(2));

  PaymentChannelConfig copyWith({
    bool? enabled,
    double? minAmount,
    double? maxAmount,
    double? dailyLimit,
    double? feePercent,
    double? feeFixed,
  }) =>
      PaymentChannelConfig(
        channel: channel,
        enabled: enabled ?? this.enabled,
        minAmount: minAmount ?? this.minAmount,
        maxAmount: maxAmount ?? this.maxAmount,
        dailyLimit: dailyLimit ?? this.dailyLimit,
        feePercent: feePercent ?? this.feePercent,
        feeFixed: feeFixed ?? this.feeFixed,
      );

  Map<String, Object?> toJson() => {
        'channel': channel.name,
        'enabled': enabled,
        'minAmount': minAmount,
        'maxAmount': maxAmount,
        'dailyLimit': dailyLimit,
        'feePercent': feePercent,
        'feeFixed': feeFixed,
      };

  factory PaymentChannelConfig.fromJson(
    PaymentChannel channel,
    Map<String, dynamic> j,
  ) =>
      PaymentChannelConfig(
        channel: channel,
        enabled: j['enabled'] as bool? ?? true,
        minAmount: (j['minAmount'] as num?)?.toDouble() ?? 10,
        maxAmount: (j['maxAmount'] as num?)?.toDouble() ?? 50000,
        dailyLimit: (j['dailyLimit'] as num?)?.toDouble() ?? 200000,
        feePercent: (j['feePercent'] as num?)?.toDouble() ?? 0,
        feeFixed: (j['feeFixed'] as num?)?.toDouble() ?? 0,
      );
}

/// Admin-owned channel settings (local until the backend arrives).
class PaymentChannelConfigStore {
  static const _storageKey = 'payment_channel_configs_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<Map<PaymentChannel, PaymentChannelConfig>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    final saved = <String, Map<String, dynamic>>{};
    if (encoded != null) {
      final decoded = jsonDecode(encoded);
      if (decoded is! List<dynamic>) {
        throw const FormatException('Invalid channel configs.');
      }
      for (final value in decoded) {
        final map = value as Map<String, dynamic>;
        saved[map['channel'] as String] = map;
      }
    }
    return {
      for (final channel in PaymentChannel.values)
        channel: saved.containsKey(channel.name)
            ? PaymentChannelConfig.fromJson(channel, saved[channel.name]!)
            : PaymentChannelConfig(channel: channel),
    };
  }

  Future<void> save(PaymentChannelConfig config) async {
    final error = config.validate();
    if (error != null) throw ArgumentError(error);
    final all = await load();
    all[config.channel] = config;
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _storageKey,
      jsonEncode(all.values.map((c) => c.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save channel configs.');
    revision.value++;
  }

  Future<PaymentChannelConfig> configFor(PaymentChannel channel) async =>
      (await load())[channel]!;
}
