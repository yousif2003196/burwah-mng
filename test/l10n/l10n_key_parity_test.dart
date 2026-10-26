import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic and English ARB files have matching keys', () async {
    final arabic = jsonDecode(await File('lib/l10n/app_ar.arb').readAsString())
        as Map<String, dynamic>;
    final english = jsonDecode(await File('lib/l10n/app_en.arb').readAsString())
        as Map<String, dynamic>;

    expect(arabic.keys.toSet(), equals(english.keys.toSet()));
  });
}
