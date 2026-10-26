import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/payments/payment_channel_config.dart';
import 'package:barwah_app/core/payments/payment_method.dart';
import 'package:barwah_app/core/payments/payment_method_store.dart';
import 'package:barwah_app/core/payments/payment_validators.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';

const _iban = 'EG380019000500000000263180002';
const _iban2 = 'EG380002000100000000123456789';

PaymentMethodInput _ibanInput([String iban = _iban]) => PaymentMethodInput(
      type: PaymentMethodType.iban,
      holderName: 'أحمد علي',
      bankName: 'البنك الأهلي',
      identifier: iban,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PaymentMethodStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = PaymentMethodStore();
  });

  Future<PaymentMethod> submit([PaymentMethodInput? input]) => store.submit(
        input ?? _ibanInput(),
        ownerId: 'finance',
        ownerRole: 'finance',
      );

  test('new methods are pending and never usable before the admin decides',
      () async {
    final m = await submit();
    expect(m.status, PaymentMethodStatus.pendingAdmin);
    expect(m.isUsable(), isFalse);
    expect(await store.usableFor('finance'), isEmpty);

    final queue = await AdminRequestStore().getPending();
    expect(queue.single.kind, AdminRequestKind.bankLink);
    expect(queue.single.refId, m.adminRefId);
    expect(queue.single.detailsAr, contains(_iban));
  });

  test('admin approval activates, rejection and freeze block', () async {
    final m = await submit();
    await AdminRequestStore()
        .decide('bankLink-${m.adminRefId}', AdminRequestStatus.approved, 'تم');
    var current = (await store.forOwner('finance')).single;
    expect(current.status, PaymentMethodStatus.active);
    expect(current.isUsable(), isTrue);
    expect(current.frozenUntil, isNull);

    final other = await submit(_ibanInput(_iban2));
    await AdminRequestStore().decide(
        'bankLink-${other.adminRefId}', AdminRequestStatus.rejected, 'بيانات ناقصة');
    current = (await store.forOwner('finance'))
        .firstWhere((x) => x.id == other.id);
    expect(current.status, PaymentMethodStatus.rejected);
    expect(current.decisionNote, 'بيانات ناقصة');
  });

  test('editing an approved method re-submits it and starts a cool-down',
      () async {
    final m = await submit();
    await AdminRequestStore()
        .decide('bankLink-${m.adminRefId}', AdminRequestStatus.approved, '');
    final edited = await store.update(m.id, _ibanInput(_iban2));
    expect(edited.status, PaymentMethodStatus.pendingAdmin);
    expect(edited.version, 2);
    expect(edited.isUsable(), isFalse);

    // The stale approval for v1 must not re-activate the new details.
    await store.applyAdminDecision(m.adminRefId, AdminRequestStatus.approved, '');
    expect((await store.forOwner('finance')).single.status,
        PaymentMethodStatus.pendingAdmin);

    await AdminRequestStore()
        .decide('bankLink-${edited.adminRefId}', AdminRequestStatus.approved, '');
    final after = (await store.forOwner('finance')).single;
    expect(after.status, PaymentMethodStatus.active);
    expect(after.isCooling, isTrue);
    expect(after.isUsable(), isFalse);
    expect(after.isUsable(DateTime.now().add(const Duration(hours: 25))), isTrue);
  });

  test('unchanged edit does not re-trigger approval', () async {
    final m = await submit();
    await AdminRequestStore()
        .decide('bankLink-${m.adminRefId}', AdminRequestStatus.approved, '');
    final same = await store.update(m.id, _ibanInput());
    expect(same.status, PaymentMethodStatus.active);
    expect(same.version, 1);
  });

  test('validation and duplicates', () async {
    await expectLater(
      submit(_ibanInput('EG000000000000000000000000000')),
      throwsArgumentError,
    );
    await submit();
    await expectLater(submit(), throwsStateError);
  });

  test('wallet must match its network and cards keep only last four',
      () async {
    expect(
      validatePaymentMethodInput(const PaymentMethodInput(
        type: PaymentMethodType.wallet,
        walletProvider: WalletProvider.orange,
        holderName: 'أحمد علي',
        identifier: '01012345678',
      )),
      'walletMismatch',
    );
    final card = await submit(const PaymentMethodInput(
      type: PaymentMethodType.card,
      holderName: 'أحمد علي',
      identifier: '4111 1111 1111 1111',
      expiryMonth: 12,
      expiryYear: 2099,
    ));
    expect(card.identifier, '1111');
    expect(card.masked, '•••• 1111');
    expect(card.toJson().toString().contains('4111111111111111'), isFalse);
    expect(
      validatePaymentMethodInput(const PaymentMethodInput(
        type: PaymentMethodType.card,
        holderName: 'أحمد علي',
        identifier: '5555 5555 5555 4444',
        expiryMonth: 12,
        expiryYear: 2099,
      )),
      'visaOnly',
    );
  });

  test('a frozen request can be unfrozen and decided again', () async {
    final m = await submit();
    final requests = AdminRequestStore();
    final id = 'bankLink-${m.adminRefId}';

    // Nothing to unfreeze while it is still pending.
    await requests.unfreeze(id);
    expect((await requests.getPending()).single.id, id);

    await requests.decide(id, AdminRequestStatus.frozen, 'مراجعة المستندات');
    expect((await store.forOwner('finance')).single.status,
        PaymentMethodStatus.suspended);
    expect(await requests.getPending(), isEmpty);

    await requests.unfreeze(id);
    expect((await requests.getPending()).single.status,
        AdminRequestStatus.pending);
    expect((await store.forOwner('finance')).single.status,
        PaymentMethodStatus.pendingAdmin);

    await requests.decide(id, AdminRequestStatus.approved, '');
    expect((await store.forOwner('finance')).single.status,
        PaymentMethodStatus.active);
  });

  test('only frozen requests can be unfrozen', () async {
    final m = await submit();
    final requests = AdminRequestStore();
    final id = 'bankLink-${m.adminRefId}';
    await requests.decide(id, AdminRequestStatus.rejected, 'غير مطابق');
    await requests.unfreeze(id);
    final all = await requests.getAll();
    expect(all.single.status, AdminRequestStatus.rejected);
  });

  test('default is only given to usable methods', () async {
    final first = await submit();
    expect(first.isDefault, isTrue);
    final second = await submit(_ibanInput(_iban2));
    await expectLater(store.setDefault(second.id), throwsStateError);
    await AdminRequestStore()
        .decide('bankLink-${second.adminRefId}', AdminRequestStatus.approved, '');
    await store.setDefault(second.id);
    final all = await store.forOwner('finance');
    expect(all.firstWhere((m) => m.id == second.id).isDefault, isTrue);
    expect(all.firstWhere((m) => m.id == first.id).isDefault, isFalse);
  });

  group('channel config', () {
    test('defaults, validation and amount checks', () async {
      final configStore = PaymentChannelConfigStore();
      final all = await configStore.load();
      expect(all.length, PaymentChannel.values.length);

      final bad = all[PaymentChannel.instapay]!.copyWith(maxAmount: 5);
      await expectLater(configStore.save(bad), throwsArgumentError);

      final cfg = all[PaymentChannel.instapay]!.copyWith(
        minAmount: 50,
        maxAmount: 1000,
        dailyLimit: 2000,
        feePercent: 1,
        feeFixed: 2,
      );
      await configStore.save(cfg);
      final loaded = await configStore.configFor(PaymentChannel.instapay);
      expect(loaded.checkAmount(10), 'belowMin');
      expect(loaded.checkAmount(2000), 'aboveMax');
      expect(loaded.checkAmount(900, sentToday: 1500), 'aboveDaily');
      expect(loaded.checkAmount(500), isNull);
      expect(loaded.feeFor(500), 7.0);
      expect(loaded.copyWith(enabled: false).checkAmount(500), 'disabled');
    });

    test('channel follows the wallet network', () async {
      final m = await submit(const PaymentMethodInput(
        type: PaymentMethodType.wallet,
        walletProvider: WalletProvider.we,
        holderName: 'أحمد علي',
        identifier: '01512345678',
      ));
      expect(channelOf(m), PaymentChannel.weCash);
    });
  });
}
