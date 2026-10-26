import 'payment_validators.dart';

enum PaymentMethodType {
  iban('حساب بنكي (IBAN)', 'Bank account (IBAN)'),
  instapay('إنستاباي', 'InstaPay'),
  wallet('محفظة إلكترونية', 'Mobile wallet'),
  card('بطاقة فيزا', 'Visa card');

  final String labelAr;
  final String labelEn;
  const PaymentMethodType(this.labelAr, this.labelEn);
}

/// Every method starts at [pendingAdmin]: only the admin activates accounts.
enum PaymentMethodStatus {
  pendingAdmin('بانتظار اعتماد الأدمن', 'Awaiting admin approval'),
  active('معتمدة', 'Approved'),
  rejected('مرفوضة', 'Rejected'),
  suspended('مجمّدة', 'Frozen');

  final String labelAr;
  final String labelEn;
  const PaymentMethodStatus(this.labelAr, this.labelEn);
}

/// After an approved account is edited and re-approved, payouts to it stay
/// blocked for this long (protection against swapped payout details).
const Duration kPaymentEditCooldown = Duration(hours: 24);

class PaymentMethod {
  final String id;
  final String ownerId;
  final String ownerRole;
  final PaymentMethodType type;
  final WalletProvider? walletProvider;
  final String holderName;

  /// Bank name for IBAN accounts; card brand for cards.
  final String providerName;

  /// IBAN / InstaPay address / wallet mobile. For cards only the last four
  /// digits are stored — never the full number or the CVV.
  final String identifier;
  final String? cardExpiry;

  /// Token issued by the payment gateway (set by the backend later).
  final String? gatewayToken;
  final PaymentMethodStatus status;
  final bool isDefault;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? frozenUntil;
  final String decisionNote;

  const PaymentMethod({
    required this.id,
    required this.ownerId,
    required this.ownerRole,
    required this.type,
    required this.holderName,
    required this.identifier,
    required this.createdAt,
    required this.updatedAt,
    this.walletProvider,
    this.providerName = '',
    this.cardExpiry,
    this.gatewayToken,
    this.status = PaymentMethodStatus.pendingAdmin,
    this.isDefault = false,
    this.version = 1,
    this.frozenUntil,
    this.decisionNote = '',
  });

  /// Reference used in the admin queue; changes with every re-submission.
  String get adminRefId => 'pm-$id-v$version';

  bool get isCooling =>
      frozenUntil != null && DateTime.now().isBefore(frozenUntil!);

  /// Payouts may only go to approved methods that finished any cool-down.
  bool isUsable([DateTime? now]) =>
      status == PaymentMethodStatus.active &&
      (frozenUntil == null || !(now ?? DateTime.now()).isBefore(frozenUntil!));

  String get masked => switch (type) {
        PaymentMethodType.card => '•••• $identifier',
        _ => maskTail(identifier),
      };

  String get channelLabelAr => type == PaymentMethodType.wallet
      ? (walletProvider?.labelAr ?? type.labelAr)
      : type.labelAr;
  String get channelLabelEn => type == PaymentMethodType.wallet
      ? (walletProvider?.labelEn ?? type.labelEn)
      : type.labelEn;

  PaymentMethod copyWith({
    PaymentMethodType? type,
    WalletProvider? walletProvider,
    bool clearWalletProvider = false,
    String? holderName,
    String? providerName,
    String? identifier,
    String? cardExpiry,
    PaymentMethodStatus? status,
    bool? isDefault,
    int? version,
    DateTime? updatedAt,
    DateTime? frozenUntil,
    bool clearFrozenUntil = false,
    String? decisionNote,
  }) =>
      PaymentMethod(
        id: id,
        ownerId: ownerId,
        ownerRole: ownerRole,
        type: type ?? this.type,
        walletProvider:
            clearWalletProvider ? null : walletProvider ?? this.walletProvider,
        holderName: holderName ?? this.holderName,
        providerName: providerName ?? this.providerName,
        identifier: identifier ?? this.identifier,
        cardExpiry: cardExpiry ?? this.cardExpiry,
        gatewayToken: gatewayToken,
        status: status ?? this.status,
        isDefault: isDefault ?? this.isDefault,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        frozenUntil: clearFrozenUntil ? null : frozenUntil ?? this.frozenUntil,
        decisionNote: decisionNote ?? this.decisionNote,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'ownerRole': ownerRole,
        'type': type.name,
        'walletProvider': walletProvider?.name,
        'holderName': holderName,
        'providerName': providerName,
        'identifier': identifier,
        'cardExpiry': cardExpiry,
        'gatewayToken': gatewayToken,
        'status': status.name,
        'isDefault': isDefault,
        'version': version,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'frozenUntil': frozenUntil?.toIso8601String(),
        'decisionNote': decisionNote,
      };

  factory PaymentMethod.fromJson(Map<String, dynamic> j) => PaymentMethod(
        id: j['id'] as String,
        ownerId: j['ownerId'] as String,
        ownerRole: j['ownerRole'] as String? ?? 'finance',
        type: PaymentMethodType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => PaymentMethodType.iban,
        ),
        walletProvider: WalletProvider.values
            .where((w) => w.name == j['walletProvider'])
            .firstOrNull,
        holderName: j['holderName'] as String? ?? '',
        providerName: j['providerName'] as String? ?? '',
        identifier: j['identifier'] as String,
        cardExpiry: j['cardExpiry'] as String?,
        gatewayToken: j['gatewayToken'] as String?,
        status: PaymentMethodStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => PaymentMethodStatus.pendingAdmin,
        ),
        isDefault: j['isDefault'] as bool? ?? false,
        version: (j['version'] as num?)?.toInt() ?? 1,
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        frozenUntil: j['frozenUntil'] == null
            ? null
            : DateTime.parse(j['frozenUntil'] as String),
        decisionNote: j['decisionNote'] as String? ?? '',
      );
}
