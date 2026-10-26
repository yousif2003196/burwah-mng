/// Pure validators for the payment methods the app supports:
/// Egyptian IBAN, InstaPay address, mobile wallets and cards.
/// Nothing here touches storage so it is trivially testable.
library;

enum WalletProvider {
  vodafone('فودافون كاش', 'Vodafone Cash', '010'),
  etisalat('اتصالات كاش', 'Etisalat Cash', '011'),
  orange('أورانج كاش', 'Orange Cash', '012'),
  we('وي كاش', 'WE Pay', '015');

  final String labelAr;
  final String labelEn;
  final String prefix;
  const WalletProvider(this.labelAr, this.labelEn, this.prefix);
}

/// Converts Arabic-Indic / Persian digits to ASCII so pasted numbers validate.
String normalizeDigits(String input) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final out = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final a = arabic.indexOf(ch);
    final p = persian.indexOf(ch);
    out.write(a >= 0 ? '$a' : (p >= 0 ? '$p' : ch));
  }
  return out.toString();
}

String _compact(String value) =>
    normalizeDigits(value).replaceAll(RegExp(r'[\s\-_.]'), '');

/// Upper-cased IBAN without spaces.
String normalizeIban(String value) =>
    normalizeDigits(value).replaceAll(RegExp(r'\s'), '').toUpperCase();

/// Egyptian IBAN: `EG` + 27 digits (29 chars) with a valid mod-97 checksum.
bool isValidEgyptianIban(String value) {
  final iban = normalizeIban(value);
  if (!RegExp(r'^EG\d{27}$').hasMatch(iban)) return false;
  final rearranged = iban.substring(4) + iban.substring(0, 4);
  var remainder = 0;
  for (final rune in rearranged.runes) {
    final ch = String.fromCharCode(rune);
    final code = int.tryParse(ch) ?? (rune - 55); // A=10 ... Z=35
    for (final digit in '$code'.split('')) {
      remainder = (remainder * 10 + int.parse(digit)) % 97;
    }
  }
  return remainder == 1;
}

/// Normalises +20 / 0020 / 20 prefixes to the local `01XXXXXXXXX` form.
/// Returns null when the number is not an Egyptian mobile number.
String? normalizeEgyptianMobile(String value) {
  var digits = _compact(value);
  if (digits.startsWith('+')) digits = digits.substring(1);
  if (digits.startsWith('0020')) digits = digits.substring(4);
  if (digits.startsWith('20') && digits.length == 12) {
    digits = '0${digits.substring(2)}';
  } else if (digits.length == 10 && digits.startsWith('1')) {
    digits = '0$digits';
  }
  return RegExp(r'^01[0125]\d{8}$').hasMatch(digits) ? digits : null;
}

bool isValidEgyptianMobile(String value) =>
    normalizeEgyptianMobile(value) != null;

/// 010 Vodafone, 011 Etisalat, 012 Orange, 015 WE.
WalletProvider? walletProviderForMobile(String value) {
  final mobile = normalizeEgyptianMobile(value);
  if (mobile == null) return null;
  final prefix = mobile.substring(0, 3);
  for (final provider in WalletProvider.values) {
    if (provider.prefix == prefix) return provider;
  }
  return null;
}

/// InstaPay address (`name@bank`) or a mobile number linked to InstaPay.
bool isValidInstapayAddress(String value) {
  final text = normalizeDigits(value).trim();
  if (isValidEgyptianMobile(text)) return true;
  return RegExp(r'^[A-Za-z0-9._\-]{3,40}@[A-Za-z]{2,20}$').hasMatch(text);
}

String normalizeInstapayAddress(String value) {
  final text = normalizeDigits(value).trim();
  return normalizeEgyptianMobile(text) ?? text.toLowerCase();
}

/// Luhn checksum for card numbers.
bool isValidCardNumber(String value) {
  final digits = _compact(value);
  if (!RegExp(r'^\d{13,19}$').hasMatch(digits)) return false;
  var sum = 0;
  var alternate = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = int.parse(digits[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

/// Only the last four digits are ever kept.
String cardLast4(String value) {
  final digits = _compact(value);
  return digits.length <= 4 ? digits : digits.substring(digits.length - 4);
}

bool isValidCardExpiry(int month, int year, DateTime now) {
  if (month < 1 || month > 12) return false;
  final fullYear = year < 100 ? 2000 + year : year;
  final lastDay = DateTime(fullYear, month + 1, 0, 23, 59, 59);
  return lastDay.isAfter(now);
}

/// Holder names need at least two words of two letters.
bool isValidHolderName(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  return parts.length >= 2 && parts.every((p) => p.length >= 2);
}

/// `•••• 1234` style mask used everywhere except the admin review screen.
String maskTail(String value, {int visible = 4}) {
  final compact = value.replaceAll(RegExp(r'\s'), '');
  if (compact.length <= visible) return compact;
  return '•••• ${compact.substring(compact.length - visible)}';
}
