import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/core/payments/payment_validators.dart';

void main() {
  group('IBAN', () {
    test('accepts a valid Egyptian IBAN with spaces and lowercase', () {
      expect(isValidEgyptianIban('EG380019000500000000263180002'), isTrue);
      expect(isValidEgyptianIban('eg38 0019 0005 0000 0000 2631 8000 2'), isTrue);
    });
    test('rejects wrong checksum, country and length', () {
      expect(isValidEgyptianIban('EG390019000500000000263180002'), isFalse);
      expect(isValidEgyptianIban('SA380019000500000000263180002'), isFalse);
      expect(isValidEgyptianIban('EG3800190005000000002631800'), isFalse);
    });
  });

  group('mobile and wallets', () {
    test('normalises country-code forms', () {
      expect(normalizeEgyptianMobile('+201012345678'), '01012345678');
      expect(normalizeEgyptianMobile('00201112345678'), '01112345678');
      expect(normalizeEgyptianMobile('201212345678'), '01212345678');
      expect(normalizeEgyptianMobile('١٠١٢٣٤٥٦٧٨'), '01012345678');
    });
    test('rejects non Egyptian numbers', () {
      expect(isValidEgyptianMobile('0131234567'), isFalse);
      expect(isValidEgyptianMobile('0501234567'), isFalse);
      expect(isValidEgyptianMobile('abc'), isFalse);
    });
    test('prefix selects the wallet network', () {
      expect(walletProviderForMobile('01012345678'), WalletProvider.vodafone);
      expect(walletProviderForMobile('01112345678'), WalletProvider.etisalat);
      expect(walletProviderForMobile('01212345678'), WalletProvider.orange);
      expect(walletProviderForMobile('01512345678'), WalletProvider.we);
    });
  });

  group('InstaPay', () {
    test('accepts address or mobile', () {
      expect(isValidInstapayAddress('ahmed.ali@instapay'), isTrue);
      expect(isValidInstapayAddress('01012345678'), isTrue);
      expect(normalizeInstapayAddress('Ahmed@InstaPay'), 'ahmed@instapay');
    });
    test('rejects malformed addresses', () {
      expect(isValidInstapayAddress('ahmed@'), isFalse);
      expect(isValidInstapayAddress('no-at-sign'), isFalse);
    });
  });

  group('cards', () {
    test('Luhn and last four only', () {
      expect(isValidCardNumber('4111 1111 1111 1111'), isTrue);
      expect(isValidCardNumber('4111111111111112'), isFalse);
      expect(cardLast4('4111 1111 1111 1111'), '1111');
    });
    test('expiry', () {
      final now = DateTime(2026, 10, 25);
      expect(isValidCardExpiry(10, 26, now), isTrue);
      expect(isValidCardExpiry(9, 26, now), isFalse);
      expect(isValidCardExpiry(13, 30, now), isFalse);
    });
  });

  test('holder name needs two words', () {
    expect(isValidHolderName('أحمد علي'), isTrue);
    expect(isValidHolderName('أحمد'), isFalse);
  });

  test('mask shows the tail only', () {
    expect(maskTail('EG380019000500000000263180002'), '•••• 0002');
  });
}
