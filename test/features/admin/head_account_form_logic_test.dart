import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/features/admin/domain/entities/head_account.dart';

void main() {
  test('legacy sector text maps to known departments', () {
    expect(HeadSectors.parse('المستعمل ووصلني'), {'وصلني'});
    expect(HeadSectors.parse('قطاع الخدمات العامة'), {'خدمات وصيانة'});
    expect(HeadSectors.parse('تجار ومتاجر • المالية'), {'تجار ومتاجر', 'المالية'});
  });

  test('join keeps canonical order', () {
    expect(HeadSectors.join({'المالية', 'وصلني'}), 'وصلني • المالية');
  });

  test('describeHeadChanges reports sector and permission changes only', () {
    final before = HeadAccountRecord(
      id: '#HSUP-1',
      name: 'أ',
      email: 'a@b.com',
      sector: 'وصلني',
      permissions: const {HeadPermission.reviewAds},
      createdAt: DateTime(2026),
    );
    final after = before.copyWith(
      sector: 'وصلني • المالية',
      permissions: {HeadPermission.reviewAds, HeadPermission.approveRefunds},
    );
    final changes = describeHeadChanges(before, after);
    expect(changes.length, 2);
    expect(describeHeadChanges(before, before), isEmpty);
  });
}
