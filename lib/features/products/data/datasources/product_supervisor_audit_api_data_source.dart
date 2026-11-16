import 'package:flutter/foundation.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/products/data/datasources/product_supervisor_audit_data_source.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';

/// السجل الرقابي: الأحداث اللي السيرفر بيسجلها بنفسه (قرارات الإعلانات، الترويج،
/// إغلاق الشكاوى) بتتقرأ من `GET api/SupervisorForAd/audit-log` باسم المشرف
/// والسبب. أحداث المحفظة والبروفايل بتتبعت للسيرفر `POST` بعد نجاحها، وباقي
/// الأحداث المحلية (متابعة شكوى، رسائل…) تفضل في [local].
class ProductSupervisorAuditApiDataSource
    implements ProductSupervisorAuditDataSource {
  ProductSupervisorAuditApiDataSource({
    required this.apiConsumer,
    required this.local,
  });

  final ApiConsumer apiConsumer;
  final ProductSupervisorAuditDataSource local;

  /// السيرفر هو اللي بيسجلها، فمنسجلهاش محليًا تاني.
  static const _serverLogged = {
    'product_approved',
    'product_rejected',
    'product_suspended',
    'product_hidden',
    'product_details_updated',
    'promotion_approved',
    'promotion_rejected',
    'promotion_suspended',
    // الحل والأرشفة بيقفلوا التذكرة، والسيرفر بيسجل "complaint_closed".
    'complaint_resolved',
    'complaint_archived',
  };

  /// أحداث بتحصل في التطبيق فقط: بنبعتها للسيرفر عشان تظهر للأدمن والرئيس.
  static const _clientPosted = {
    'wallet_withdrawal_requested',
    'profile_field_availability_changed',
    'profile_urgent_notifications_changed',
  };

  @override
  Future<List<ProductSupervisorAuditEntry>> getEntries() async {
    final localEntries = await local.getEntries();
    if (!AuthSession.isSignedIn) return localEntries;
    final remote = await _loadRemote();
    return [
      ...localEntries.where(
        (e) =>
            !_serverLogged.contains(e.actionKey) &&
            !_clientPosted.contains(e.actionKey),
      ),
      ...remote,
    ];
  }

  @override
  Future<void> saveEntry(ProductSupervisorAuditEntry entry) async {
    if (!AuthSession.isSignedIn) return local.saveEntry(entry);
    if (_serverLogged.contains(entry.actionKey)) return;
    if (_clientPosted.contains(entry.actionKey)) {
      try {
        await apiConsumer.post<Object>(
          ApiEndpoints.adAuditLog,
          data: {
            'actionKey': entry.actionKey,
            'subject': entry.subject,
            'details': entry.details,
          },
        );
        return;
      } on Object catch (error) {
        // لو السيرفر مش متاح نحفظها محليًا بدل ما تضيع.
        debugPrint('Audit post failed, saved locally: $error');
      }
    }
    await local.saveEntry(entry);
  }

  Future<List<ProductSupervisorAuditEntry>> _loadRemote() => fetch(apiConsumer);

  /// قراءة السجل من السيرفر. [mine] = إجراءات المشرف الحالي فقط.
  static Future<List<ProductSupervisorAuditEntry>> fetch(
    ApiConsumer apiConsumer, {
    bool mine = false,
    int pageSize = 100,
    String path = ApiEndpoints.adAuditLog,
  }) async {
    final response = await apiConsumer.get<Object>(
      path,
      queryParameters: {'page': 1, 'pageSize': pageSize, if (mine) 'mine': true},
    );
    final body = response.data;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! List) return const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) _entry(item),
    ];
  }

  static ProductSupervisorAuditEntry _entry(Map<String, dynamic> json) {
    final label = '${json['actionType'] ?? ''}';
    var key = '${json['actionKey'] ?? ''}'.trim();
    if (key.isEmpty) {
      key = label.contains('اعتماد')
          ? 'product_approved'
          : label.contains('رفض')
              ? 'product_rejected'
              : label.contains('تعليق')
                  ? 'product_suspended'
                  : 'product_returned';
    }
    final number = '${json['adNumber'] ?? ''}';
    final reason = '${json['reason'] ?? ''}'.trim();
    final supervisor = '${json['supervisorName'] ?? ''}'.trim();
    return ProductSupervisorAuditEntry(
      id: 'remote_${key}_${json['id']}',
      actionKey: key,
      subject: '$number ${json['title'] ?? ''}'.trim(),
      details: [
        if (supervisor.isNotEmpty) 'المشرف: $supervisor',
        if (reason.isNotEmpty) 'السبب: $reason',
      ].join(' • '),
      occurredAt: DateTime.tryParse('${json['at'] ?? ''}')?.toLocal() ??
          DateTime.now(),
    );
  }
}
