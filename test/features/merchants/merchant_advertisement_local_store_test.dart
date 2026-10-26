import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/merchants/data/datasources/merchant_advertisement_local_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('advertisement status overrides are stored by reference', () async {
    await MerchantAdvertisementLocalStore.saveStatus(
      reference: 'AD-94820',
      status: MerchantAdvertisementStatus.awaitingFinance,
    );

    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString('merchant_advertisement_statuses_v1');
    expect(
      jsonDecode(encoded!)['AD-94820'],
      MerchantAdvertisementStatus.awaitingFinance.name,
    );
    expect(
      MerchantAdvertisementLocalStore.statusFor(
        'AD-94820',
        MerchantAdvertisementStatus.rejected,
      ),
      MerchantAdvertisementStatus.awaitingFinance,
    );
    expect(
      MerchantAdvertisementLocalStore.statusFor(
        'AD-unknown',
        MerchantAdvertisementStatus.underReview,
      ),
      MerchantAdvertisementStatus.underReview,
    );
  });

  test('finance approval leaves the ad awaiting management', () async {
    await MerchantAdvertisementLocalStore.saveStatus(
      reference: 'AD-94820',
      status: MerchantAdvertisementStatus.awaitingFinance,
    );
    await MerchantAdvertisementLocalStore.saveStatus(
      reference: 'AD-94820',
      status: MerchantAdvertisementStatus.awaitingManagement,
    );

    expect(
      MerchantAdvertisementLocalStore.statusFor(
        'AD-94820',
        MerchantAdvertisementStatus.underReview,
      ),
      MerchantAdvertisementStatus.awaitingManagement,
    );
  });
}
