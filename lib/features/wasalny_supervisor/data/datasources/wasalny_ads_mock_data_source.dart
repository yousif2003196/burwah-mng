import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_ads_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_ad.dart';

class WasalnyAdsMockDataSource implements WasalnyAdsDataSource {
  WasalnyAdsMockDataSource() : _ads = _sampleAds();

  static const _storageKey = 'wasalny_ad_decisions_v1';
  final List<WasalnyAd> _ads;

  @override
  Future<List<WasalnyAd>> getAds() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded != null) {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid Wasalny ad decisions.');
      }
      for (var index = 0; index < _ads.length; index++) {
        final decision = decoded[_ads[index].id];
        if (decision is! Map<String, dynamic>) continue;
        final statusName = decision['status'];
        if (statusName is! String) {
          throw const FormatException('Invalid Wasalny ad status.');
        }
        _ads[index] = _ads[index].copyWith(
          status: WasalnyAdStatus.values.byName(statusName),
          decisionNote: decision['decisionNote'] as String?,
        );
      }
    }
    return List.unmodifiable(_ads);
  }

  @override
  Future<WasalnyAd> updateAdStatus({
    required String id,
    required WasalnyAdStatus status,
    String? decisionNote,
  }) async {
    final index = _ads.indexWhere((ad) => ad.id == id);
    if (index < 0) {
      throw StateError('Wasalny ad $id was not found.');
    }
    final updated = _ads[index].copyWith(
      status: status,
      decisionNote: decisionNote,
    );
    final previous = _ads[index];
    _ads[index] = updated;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _storageKey,
        jsonEncode({
          for (final ad in _ads)
            ad.id: {
              'status': ad.status.name,
              'decisionNote': ad.decisionNote,
            },
        }),
      );
    } catch (_) {
      _ads[index] = previous;
      rethrow;
    }
    return updated;
  }

  static List<WasalnyAd> _sampleAds() {
    final now = DateTime.now();
    return [
      WasalnyAd(
        id: 'wasalny-ad-1',
        reference: 'AD-94021',
        titleAr: 'كاميرا كانون EOS R6 مستعملة',
        titleEn: 'Used Canon EOS R6 Camera',
        sellerNameAr: 'عبد الرحمن الشمري',
        sellerNameEn: 'Abdulrahman Al-Shammari',
        cityAr: 'الرياض',
        cityEn: 'Riyadh',
        price: 6400,
        categoryKey: 'camera',
        status: WasalnyAdStatus.pending,
        submittedAt: now.subtract(const Duration(hours: 2)),
        descriptionAr:
            'كاميرا كانون EOS R6 بحالة الوكالة شبه جديدة، تم استخدامها في تغطيات داخلية محدودة. خالية من أي خدوش أو عيوب تشغيلية، تعمل على الكرتون الأصلي والشاحن والبطارية الأصلية.',
        descriptionEn:
            'Canon EOS R6 camera in near-new condition, used for a limited number of indoor shoots. No scratches or operational defects; includes the original box, charger, and battery.',
        photoCount: 4,
        sellerPhone: '050 000 1042',
        isSellerPremium: true,
      ),
      WasalnyAd(
        id: 'wasalny-ad-2',
        reference: 'AD-93880',
        titleAr: 'بلايستيشن 5 مع ذراعين ولعبة',
        titleEn: 'PlayStation 5 with two controllers and a game',
        sellerNameAr: 'محمد الدوسري',
        sellerNameEn: 'Mohammed Al-Dosari',
        cityAr: 'جدة',
        cityEn: 'Jeddah',
        price: 1850,
        categoryKey: 'console',
        status: WasalnyAdStatus.approved,
        submittedAt: now.subtract(const Duration(hours: 4)),
        sellerPhone: '050 000 1038',
      ),
      WasalnyAd(
        id: 'wasalny-ad-3',
        reference: 'AD-93710',
        titleAr: 'ماك بوك برو M2 نظيف (2GB)',
        titleEn: 'MacBook Pro M2 in great condition (2GB)',
        sellerNameAr: 'فهد العتيبي',
        sellerNameEn: 'Fahad Al-Otaibi',
        cityAr: 'الدمام',
        cityEn: 'Dammam',
        price: 5200,
        categoryKey: 'laptop',
        status: WasalnyAdStatus.awaitingApproval,
        submittedAt: now.subtract(const Duration(hours: 4)),
        sellerPhone: '050 000 1031',
      ),
      WasalnyAd(
        id: 'wasalny-ad-4',
        reference: 'AD-93452',
        titleAr: 'دراجة جبلية احترافية Marlin 7',
        titleEn: 'Marlin 7 professional mountain bike',
        sellerNameAr: 'خالد المنصور',
        sellerNameEn: 'Khalid Al-Mansour',
        cityAr: 'أبها',
        cityEn: 'Abha',
        price: 2100,
        categoryKey: 'bicycle',
        status: WasalnyAdStatus.rejected,
        submittedAt: now.subtract(const Duration(days: 1)),
        decisionNote: 'عدم وضوح صور ناقل الحركة',
        sellerPhone: '050 000 1024',
      ),
    ];
  }
}
