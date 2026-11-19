import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_api.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_data_source.dart';
import 'package:barwah_app/features/merchants/data/models/merchant_model.dart';
import 'package:barwah_app/features/merchants/data/models/supervisor_stats_model.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';

/// التجار الحقيقيون (مطاعم / بقالة / أكل بيتي) من `api/supervisor/merchant`.
/// الكيان القديم بيتملي من رد السيرفر عشان الشاشات تفضل زي ما هي.
class MerchantsApiDataSource implements MerchantsDataSource {
  static const _egp = 'ج.م';

  @override
  Future<List<MerchantModel>> getMerchants() async {
    final rows = await MerchantsApi.merchants();
    return [for (final row in rows) _fromJson(row)];
  }

  @override
  Future<List<MerchantModel>> getSupervisedMerchants() => getMerchants();

  @override
  Future<List<MerchantModel>> searchAndFilterMerchants({
    String? query,
    MerchantStatus? statusFilter,
  }) async {
    final all = await getMerchants();
    final q = (query ?? '').trim().toLowerCase();
    return [
      for (final m in all)
        if ((statusFilter == null || m.status == statusFilter) &&
            (q.isEmpty ||
                m.name.toLowerCase().contains(q) ||
                (m.ownerName ?? '').toLowerCase().contains(q) ||
                (m.contactPhone ?? '').contains(q)))
          m,
    ];
  }

  @override
  Future<SupervisorStatsModel> getSupervisorStats() async {
    final s = await MerchantsApi.stats();
    int n(String key) => (s[key] as num?)?.toInt() ?? 0;
    final name = '${s['supervisorName'] ?? 'مشرف التجار'}';
    return SupervisorStatsModel(
      supervisorName: name,
      supervisorNameEn: name,
      supervisorTag: 'مشرف التجار',
      supervisorTagEn: 'Merchants supervisor',
      region: 'كل التجار على المنصة',
      regionEn: 'All platform merchants',
      approvedMerchantsCount: n('activeCount'),
      pendingReviewCount: n('pendingCount'),
      totalCount: n('totalMerchants'),
      activeVerifiedCount: n('activeCount'),
      underAuditCount: n('pendingCount'),
      updateRequiredCount: n('infoRequestedCount'),
      suspendedCount: n('suspendedCount') + n('rejectedCount'),
      compliancePercentage: n('compliancePercent'),
      pendingAlertsCount: n('pendingCount') + n('pendingWithdrawalsCount'),
      supervisorCode: 'SUP',
      supervisorFullName: name,
      supervisorFullNameEn: name,
      supervisionScope: 'مطاعم وبقالة وأكل بيتي',
      supervisionScopeEn: 'Restaurants, groceries & home kitchens',
    );
  }

  // ───────────────────────── mapping ─────────────────────────

  static (String, String, IconData) _category(String type) {
    final t = type.toLowerCase();
    if (t.contains('rest') || t.contains('مطعم')) {
      return ('مطعم', 'Restaurant', Icons.restaurant_outlined);
    }
    if (t.contains('groc') || t.contains('بقال')) {
      return ('بقالة', 'Grocery', Icons.local_grocery_store_outlined);
    }
    if (t.contains('kitchen') || t.contains('home') || t.contains('بيت')) {
      return ('أكل بيتي', 'Home kitchen', Icons.soup_kitchen_outlined);
    }
    return (type.isEmpty ? 'تاجر' : type, type.isEmpty ? 'Merchant' : type, Icons.storefront_outlined);
  }

  static String _money(Object? v) {
    final d = (v as num?)?.toDouble() ?? 0;
    return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
  }

  static String _date(Object? iso) {
    final d = DateTime.tryParse('$iso')?.toLocal();
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  static MerchantModel _fromJson(Map<String, dynamic> j) {
    final id = '${j['id']}';
    final status = '${j['status']}';
    final (catAr, catEn, icon) = _category('${j['businessType'] ?? ''}');
    final name = '${j['storeName'] ?? ''}'.trim();
    final owner = '${j['ownerName'] ?? ''}'.trim();
    final place = [j['city'], j['governorate']]
        .map((e) => '${e ?? ''}'.trim())
        .where((e) => e.isNotEmpty)
        .join(' - ');
    final address = '${j['address'] ?? ''}'.trim();
    final location = place.isNotEmpty ? place : address;

    final merchantStatus = switch (status) {
      'pending' => MerchantStatus.underAudit,
      'info' => MerchantStatus.updateRequired,
      'suspended' || 'rejected' => MerchantStatus.temporarilySuspended,
      _ => MerchantStatus.activeVerified,
    };
    final suspended = status == 'suspended' || status == 'rejected';

    final (footerAr, footerEn, footerIcon, footerColor) = switch (status) {
      'pending' => (
          'بانتظار مراجعة التسجيل',
          'Registration awaiting review',
          Icons.hourglass_top_rounded,
          AppColors.warningDark
        ),
      'info' => (
          'مطلوب استكمال بيانات',
          'More information required',
          Icons.edit_note_rounded,
          AppColors.warningDark
        ),
      'rejected' => (
          'تسجيل مرفوض',
          'Registration rejected',
          Icons.cancel_outlined,
          AppColors.dangerDark
        ),
      'suspended' => (
          'موقوف',
          'Suspended',
          Icons.pause_circle_outline_rounded,
          AppColors.dangerDark
        ),
      _ => (
          'نشط',
          'Active',
          Icons.verified_outlined,
          AppColors.successDark
        ),
    };

    final products = <MerchantAdvertisement>[
      for (final p in (j['products'] as List<dynamic>? ?? const []))
        if (p is Map)
          MerchantAdvertisement(
            title: '${p['name'] ?? ''}',
            titleEn: '${p['name'] ?? ''}',
            reference: 'P-${p['id']}',
            price: _money(p['price']),
            status: p['isActive'] == false
                ? MerchantAdvertisementStatus.hidden
                : MerchantAdvertisementStatus.approved,
          ),
    ];

    final productsCount = (j['productsCount'] as num?)?.toInt() ?? 0;
    final active = (j['activeProductsCount'] as num?)?.toInt() ?? 0;
    final hidden = (j['hiddenProductsCount'] as num?)?.toInt() ?? 0;
    final orders = (j['ordersCount'] as num?)?.toInt() ?? 0;
    final withdrawal = (j['pendingWithdrawalAmount'] as num?)?.toDouble() ?? 0;

    final violation = [
      '${j['violationType'] ?? ''}'.trim(),
      '${j['violationDescription'] ?? ''}'.trim(),
    ].where((e) => e.isNotEmpty).join(' - ');
    final reviewNote = '${j['reviewNote'] ?? ''}'.trim();
    final notice = suspended || status == 'info'
        ? (status == 'suspended' ? violation : reviewNote)
        : '';

    return MerchantModel(
      id: id,
      code: 'MER-$id',
      name: name.isEmpty ? owner : name,
      nameEn: name.isEmpty ? owner : name,
      category: catAr,
      categoryEn: catEn,
      categoryIcon: icon,
      crNumber: '${j['commercialRegister'] ?? ''}'.trim().isEmpty
          ? '—'
          : '${j['commercialRegister']}',
      logoUrl: (j['logoUrl'] as String?)?.isEmpty ?? true
          ? null
          : j['logoUrl'] as String?,
      logoIcon: icon,
      status: merchantStatus,
      location: location,
      locationEn: location,
      adsCount: productsCount,
      adsCountLabel: '$productsCount منتج',
      adsCountLabelEn: '$productsCount products',
      adsSectionTitle: 'المنتجات',
      adsSectionTitleEn: 'Products',
      adsIcon: Icons.inventory_2_outlined,
      activityNote: 'الطلبات: $orders',
      activityNoteEn: 'Orders: $orders',
      footerStatusText: footerAr,
      footerStatusTextEn: footerEn,
      footerStatusIcon: footerIcon,
      footerStatusColor: footerColor,
      actionButtonText: 'سجل التاجر >',
      actionButtonTextEn: 'Merchant Record >',
      isSuspended: suspended,
      ownerName: owner,
      ownerNameEn: owner,
      contactPhone: '${j['phone'] ?? ''}',
      contactEmail: '${j['email'] ?? ''}',
      joinedDate: _date(j['joinedAt']),
      joinedDateEn: _date(j['joinedAt']),
      commissionPercent: (j['effectiveCommission'] as num?)?.toDouble(),
      activeAdsCount: active,
      underReviewAdsCount: hidden,
      pendingReviewCount: status == 'pending' ? 1 : 0,
      financialWithdrawalAlert:
          withdrawal > 0 ? 'طلب سحب معلق: ${_money(withdrawal)} $_egp' : null,
      financialWithdrawalAlertEn:
          withdrawal > 0 ? 'Pending withdrawal: ${_money(withdrawal)} EGP' : null,
      violationNotice: notice.isEmpty ? null : notice,
      violationNoticeEn: notice.isEmpty ? null : notice,
      recentAdvertisements: products.take(5).toList(),
      allAdvertisements: products,
    );
  }
}
