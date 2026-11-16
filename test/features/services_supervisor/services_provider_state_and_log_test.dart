import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/services_supervisor/data/datasources/services_activity_log.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_provider_state_store.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_reports_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('suspend needs a reason, reactivate clears it', () async {
    final store = ServicesProviderStateStore();
    expect(() => store.suspend('p1', 'x'), throwsArgumentError);
    await store.suspend('p1', 'شكاوى متكررة من العملاء');
    var all = await store.load();
    expect(all['p1']!.suspended, isTrue);
    expect(all['p1']!.reason, 'شكاوى متكررة من العملاء');

    await store.reactivate('p1');
    all = await store.load();
    expect(all['p1']?.suspended ?? false, isFalse);
  });

  test('verification override is stored', () async {
    final store = ServicesProviderStateStore();
    await store.setVerified('p2', true);
    expect((await store.load())['p2']!.verified, isTrue);
  });

  test('activity log keeps newest first', () async {
    final log = ServicesActivityLog();
    await log.record(action: 'request_approved', subject: 'R-1');
    await log.record(action: 'request_rejected', subject: 'R-2', details: 'سبب');
    await log.record(action: 'provider_suspended', subject: 'p1');
    final all = await log.getAll();
    expect(all.length, 3);
    expect(all.first.action, 'provider_suspended');
  });

  test('report reads the server numbers', () {
    final m = ServicesReportMetrics.fromJson({
      'reviewed': 4,
      'approved': 2,
      'rejected': 2,
      'approvalRate': 50,
      'providerActions': 1,
    });
    expect(m.approved, 2);
    expect(m.rejected, 2);
    expect(m.providerActions, 1);
    expect(m.approvalRate, 50);
  });

  test('report is empty-safe', () {
    final m = ServicesReportMetrics.fromJson(const {});
    expect(m.reviewed, 0);
    expect(m.averageMinutes, isNull);
  });
}