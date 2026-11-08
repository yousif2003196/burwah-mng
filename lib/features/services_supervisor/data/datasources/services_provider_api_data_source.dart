import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/service_provider_catalog.dart';
import 'package:barwah_app/features/services_supervisor/domain/entities/service_provider.dart';

/// مقدمو الخدمات الحقيقيون من `api/SupervisorForSR/providers-directory`،
/// وإعادة الإسناد `reassign/{id}`.
class ServicesProviderApiDataSource {
  ServicesProviderApiDataSource._();

  static const _base = 'api/SupervisorForSR';

  static ServiceProviderCategory _categoryFor(String trade) {
    if (trade.contains('كهرب')) return ServiceProviderCategory.electrical;
    if (trade.contains('نقل') || trade.contains('أثاث') || trade.contains('توصيل')) {
      return ServiceProviderCategory.moving;
    }
    if (trade.contains('سباك')) return ServiceProviderCategory.plumbing;
    return ServiceProviderCategory.maintenance;
  }

  static IconData _iconFor(ServiceProviderCategory c) => switch (c) {
        ServiceProviderCategory.electrical => Icons.electrical_services_outlined,
        ServiceProviderCategory.moving => Icons.local_shipping_outlined,
        ServiceProviderCategory.plumbing => Icons.plumbing_outlined,
        ServiceProviderCategory.maintenance => Icons.build_circle_outlined,
      };

  static ServiceProvider _fromJson(Map<String, dynamic> j) {
    final trade = '${j['businessType'] ?? ''}';
    final name = '${j['fullName'] ?? ''}'.trim();
    final category = _categoryFor(trade);
    final city = '${j['location'] ?? ''}';
    final rating = (j['rating'] as num?)?.toDouble() ?? 0;
    return ServiceProvider(
      id: 'PRO-${j['id']}',
      nameAr: name,
      nameEn: name,
      tradeAr: trade,
      tradeEn: trade,
      cityAr: city,
      cityEn: city,
      taskCount: '${j['completedTasksCount'] ?? 0}',
      rating: rating.toStringAsFixed(1),
      completionRate: '—',
      responseTime: '—',
      phone: '${j['phone'] ?? ''}',
      category: category,
      icon: _iconFor(category),
      available: j['isAvailable'] != false,
      verified: j['isVerified'] == true,
      featured: false,
      featureAr: trade,
      featureEn: trade,
    );
  }

  /// يستبدل القايمة التجريبية بمقدمي الخدمات الحقيقيين.
  static Future<void> refreshCatalog() async {
    try {
      final api = sl<ApiConsumer>(instanceName: 'berwah');
      final response = await api.get<Object>('$_base/providers-directory');
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! List) return;
      final list = [
        for (final item in data)
          if (item is Map<String, dynamic>) _fromJson(item),
      ];
      serviceProviders
        ..clear()
        ..addAll(list);
    } catch (error) {
      debugPrint('Providers directory load failed: $error');
    }
  }

  static int idOf(String providerId) =>
      int.tryParse(providerId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  static Future<void> reassign({
    required int requestId,
    required String providerId,
    String reason = '',
  }) async {
    final api = sl<ApiConsumer>(instanceName: 'berwah');
    await api.post<Object>('$_base/reassign/$requestId', data: {
      'newProviderId': idOf(providerId),
      'reassignmentReason': reason,
      'sendInstantNotification': true,
    });
  }
}
