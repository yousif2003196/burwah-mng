import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_ads_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_ad.dart';

/// إعلانات المستعمل الحقيقية من `api/SupervisorUsed`.
/// السيرفر ما بيحتفظش بحالة "طُلب تعديل" لوحدها: الإعلان بيرجع Pending ومعاه
/// سبب التعديل، فبتتعرض الحالة دي في الجلسة الحالية بس.
class WasalnyAdsApiDataSource implements WasalnyAdsDataSource {
  WasalnyAdsApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;
  static const _pageSize = 100;
  static const _maxPages = 5;

  /// الإعلانات اللي المشرف طلب تعديلها في الجلسة دي.
  final Set<String> _editRequested = {};

  static WasalnyAdStatus _statusOf(String raw) => switch (raw.toLowerCase()) {
        'approved' => WasalnyAdStatus.approved,
        'rejected' => WasalnyAdStatus.rejected,
        'suspended' => WasalnyAdStatus.suspended,
        _ => WasalnyAdStatus.pending,
      };

  WasalnyAd _fromJson(Map<String, dynamic> j) {
    final id = '${j['id']}';
    final name = '${j['publisherName'] ?? ''}'.trim();
    final city = '${j['city'] ?? ''}'.trim();
    final governorate = '${j['governorate'] ?? ''}'.trim();
    final place = [city, governorate].where((e) => e.isNotEmpty).join(' - ');
    final title = '${j['title'] ?? ''}';
    final description = '${j['description'] ?? ''}';
    final urls = [
      for (final u in (j['imageUrls'] as List<dynamic>? ?? const []))
        if (u is String && u.isNotEmpty) u,
    ];
    final note = '${j['reviewNote'] ?? ''}'.trim();
    var status = _statusOf('${j['status'] ?? ''}');
    if (status == WasalnyAdStatus.pending && _editRequested.contains(id)) {
      status = WasalnyAdStatus.editRequested;
    }
    return WasalnyAd(
      id: id,
      reference: 'AD-$id',
      titleAr: title,
      titleEn: title,
      sellerNameAr: name,
      sellerNameEn: name,
      cityAr: place,
      cityEn: place,
      price: (j['price'] as num?)?.round() ?? 0,
      categoryKey: 'other',
      categoryName: '${j['categoryName'] ?? ''}',
      status: status,
      submittedAt: DateTime.tryParse('${j['createdAt']}')?.toLocal() ??
          DateTime.now(),
      decisionNote: note.isEmpty ? null : note,
      descriptionAr: description,
      descriptionEn: description,
      photoCount: urls.length,
      imageUrls: urls,
      sellerPhone: '',
    );
  }

  @override
  Future<List<WasalnyAd>> getAds() async {
    final result = <WasalnyAd>[];
    for (var page = 1; page <= _maxPages; page++) {
      final response = await apiConsumer.get<Object>(
        ApiEndpoints.usedAds,
        queryParameters: {'page': page, 'pageSize': _pageSize},
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! List) throw const FormatException('bad used ads list');
      for (final item in data) {
        if (item is Map<String, dynamic>) result.add(_fromJson(item));
      }
      if (data.length < _pageSize) break;
    }
    return result;
  }

  @override
  Future<WasalnyAd> updateAdStatus({
    required String id,
    required WasalnyAdStatus status,
    String? decisionNote,
  }) async {
    final adId = int.tryParse(id);
    if (adId == null) throw StateError('Bad ad id: $id');
    final reason = (decisionNote ?? '').trim();
    switch (status) {
      case WasalnyAdStatus.approved:
        await apiConsumer.post<Object>(
          ApiEndpoints.usedApprove(adId),
          data: {'reason': reason, 'sendNotification': true},
        );
        _editRequested.remove(id);
      case WasalnyAdStatus.rejected:
        await apiConsumer.post<Object>(
          ApiEndpoints.usedRejectWithPenalty(adId),
          data: {'reason': reason, 'sendNotification': true},
        );
        _editRequested.remove(id);
      case WasalnyAdStatus.suspended || WasalnyAdStatus.hidden:
        await apiConsumer.post<Object>(
          ApiEndpoints.usedSuspend(adId),
          data: {'reason': reason},
        );
        _editRequested.remove(id);
      case WasalnyAdStatus.editRequested:
        await apiConsumer.post<Object>(
          ApiEndpoints.usedRequestEdit(adId),
          data: {'reason': reason, 'sendNotification': true},
        );
        _editRequested.add(id);
      case WasalnyAdStatus.pending:
        await apiConsumer.post<Object>(ApiEndpoints.usedRestore(adId));
        _editRequested.remove(id);
      case WasalnyAdStatus.awaitingApproval:
        throw UnsupportedError('awaitingApproval is not a server state');
    }
    final response = await apiConsumer.get<Object>(ApiEndpoints.usedAd(adId));
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('bad used ad details');
    }
    final details = {
      ...data,
      'publisherName': (data['publisher'] is Map)
          ? (data['publisher'] as Map)['fullName']
          : '',
      'imageUrls': [
        for (final i in (data['images'] as List<dynamic>? ?? const []))
          if (i is Map && '${i['url'] ?? ''}'.isNotEmpty) '${i['url']}',
      ],
    };
    final ad = _fromJson(details);
    return status == WasalnyAdStatus.hidden
        ? ad.copyWith(status: WasalnyAdStatus.hidden, decisionNote: reason)
        : ad;
  }
}
