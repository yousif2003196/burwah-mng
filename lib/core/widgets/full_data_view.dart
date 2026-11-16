import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/theme/app_colors.dart';

/// أي شاشة مشرف تفتح "كل البيانات" لإعلان/طلب خدمة: نفس ما يشوفه اليوزر + بيانات الأطراف كاملة.
enum FullDataKind { newAd, usedAd, service }

class FullDataScreen extends StatefulWidget {
  const FullDataScreen({
    super.key,
    required this.kind,
    required this.path,
    required this.title,
  });

  final FullDataKind kind;
  final String path;
  final String title;

  /// زر جاهز تحطه في أي شاشة تفاصيل.
  static Widget button(
    BuildContext context, {
    required FullDataKind kind,
    required String path,
    String label = 'عرض كل البيانات كاملة',
  }) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FullDataScreen(kind: kind, path: path, title: label),
        ),
      ),
      icon: const Icon(Icons.fact_check_outlined),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: AppColors.primaryDark,
        side: BorderSide(color: AppColors.primaryDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  State<FullDataScreen> createState() => _FullDataScreenState();
}

class _FullDataScreenState extends State<FullDataScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final api = sl<ApiConsumer>(instanceName: 'berwah');
      final response = await api.get<Object>(widget.path);
      final body = response.data;
      Object? data = body;
      if (body is Map && body['data'] is Map) data = body['data'];
      if (data is! Map) throw const FormatException('bad data');
      if (!mounted) return;
      setState(() {
        _data = Map<String, dynamic>.from(data as Map);
        _loading = false;
      });
    } on Object catch (e) {
      debugPrint('Full data load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.transparent, elevation: 0),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _failed || _data == null
                ? Center(
                    child: TextButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('تعذر التحميل — إعادة المحاولة'),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: _sections(_data!),
                  ),
      ),
    );
  }

  List<Widget> _sections(Map<String, dynamic> d) {
    Map<String, dynamic> m(Object? v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
    const gap = SizedBox(height: 12);
    switch (widget.kind) {
      case FullDataKind.newAd:
      case FullDataKind.usedAd:
        final full = m(d['full']);
        final images = <String>[
          for (final i in (full['images'] as List? ?? const [])) if (i is Map && '${i['url'] ?? ''}'.isNotEmpty) '${i['url']}',
        ];
        final head = <String, Object?>{
          'title': d['title'],
          'description': d['description'],
          'price': d['price'],
          'status': d['status'],
        };
        return [
          FullAdSection(head: head, full: full, images: images),
          gap,
          FullPersonCard(title: 'بيانات البائع', person: m(d['seller'])),
        ];
      case FullDataKind.service:
        return [
          FullServiceSection(data: d),
          gap,
          FullPersonCard(title: 'بيانات العميل', person: m(d['customer'])),
          gap,
          if (d['provider'] is Map) ...[
            FullPersonCard(title: 'بيانات مقدّم الخدمة', person: m(d['provider'])),
            gap,
            if (d['acceptedOffer'] is Map) FullOfferCard(title: 'عرض مقدّم الخدمة المقبول', offer: m(d['acceptedOffer'])),
          ] else
            const FullBox(title: 'مقدّم الخدمة', rows: [FullRow('الحالة', 'لسه ما اتحددش مقدّم خدمة للطلب')]),
          if ((d['offers'] as List? ?? const []).length > 1) ...[
            gap,
            for (final o in (d['offers'] as List))
              if (o is Map && o['isAccepted'] != true) ...[
                FullOfferCard(title: 'عرض آخر', offer: Map<String, dynamic>.from(o)),
                gap,
              ],
          ],
        ];
    }
  }
}

class FullRow {
  const FullRow(this.label, this.value);
  final String label;
  final String? value;
}

String? _s(Object? v) {
  final t = '${v ?? ''}'.trim();
  return t.isEmpty || t == 'null' ? null : t;
}

String? _date(Object? v) {
  final t = _s(v);
  if (t == null) return null;
  final p = DateTime.tryParse(t);
  if (p == null) return t;
  return DateFormat('yyyy/MM/dd  hh:mm a').format(p.toLocal());
}

String? _money(Object? v) {
  if (v is! num) return null;
  return '${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)} ج.م';
}

String? _yes(Object? v) => v == null ? null : (v == true ? 'نعم' : 'لا');

class FullBox extends StatelessWidget {
  const FullBox({super.key, required this.title, required this.rows, this.leading});

  final String title;
  final List<FullRow> rows;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final shown = rows.where((r) => (r.value ?? '').isNotEmpty).toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
          if (leading != null) ...[const SizedBox(height: 10), leading!],
          const SizedBox(height: 6),
          for (final r in shown)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(r.label, style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  ),
                  Expanded(
                    child: SelectableText(
                      r.value!,
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FullAdSection extends StatelessWidget {
  const FullAdSection({super.key, required this.head, required this.full, required this.images});

  final Map<String, Object?> head;
  final Map<String, dynamic> full;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final specs = <FullRow>[
      for (final s in (full['specifications'] as List? ?? const []))
        if (s is Map) FullRow('${s['key']}', _s(s['value'])),
    ];
    final cond = switch ('${full['condition']}') {
      'New' => 'جديد',
      'Used' => 'مستعمل',
      final c => c,
    };
    final plan = switch ('${full['effectivePlan']}') {
      'Free' => 'مجاني',
      'Featured' => 'مميز',
      'VIP' => 'VIP',
      final c => c,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FullBox(
          title: 'بيانات الإعلان (زي ما اليوزر بيشوفها)',
          leading: images.isEmpty
              ? null
              : SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (c, i) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        images[i],
                        width: 170,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => SizedBox(width: 170, child: ColoredBox(color: AppColors.surfaceMuted)),
                      ),
                    ),
                  ),
                ),
          rows: [
            FullRow('العنوان', _s(head['title'])),
            FullRow('الوصف', _s(head['description'])),
            FullRow('السعر', _money(head['price'])),
            FullRow('قابل للتفاوض', _yes(full['isNegotiable'])),
            FullRow('الكمية', _s(full['quantity'])),
            FullRow('الحالة', cond),
            FullRow('القسم', _s(full['categoryName'])),
            FullRow('القسم الفرعي', _s(full['subCategoryName'])),
            FullRow('المحافظة', _s(full['governorate'])),
            FullRow('المدينة', _s(full['city'])),
            FullRow(
              'الموقع على الخريطة',
              (full['latitude'] != null && full['longitude'] != null) ? '${full['latitude']}, ${full['longitude']}' : null,
            ),
            FullRow('حالة الإعلان', _s(head['status'])),
            FullRow('الباقة', plan),
            FullRow('انتهاء الباقة', _date(full['promotionEndsAt'])),
            FullRow('مدة الباقة (يوم)', _s(full['promotionDays'])),
            FullRow('تاريخ النشر', _date(full['createdAt'])),
            FullRow('ينتهي الإعلان', _date(full['expiresAt'])),
            FullRow('آخر مراجعة', _date(full['reviewedAt'])),
            FullRow('ملاحظة المشرف', _s(full['reviewNote'])),
          ],
        ),
        if (specs.isNotEmpty) ...[
          const SizedBox(height: 12),
          FullBox(title: 'المواصفات', rows: specs),
        ],
      ],
    );
  }
}

class FullPersonCard extends StatelessWidget {
  const FullPersonCard({super.key, required this.title, required this.person});

  final String title;
  final Map<String, dynamic> person;

  @override
  Widget build(BuildContext context) {
    if (person.isEmpty) {
      return FullBox(title: title, rows: const [FullRow('الحالة', 'البيانات غير متاحة')]);
    }
    final img = _s(person['imageUrl']);
    final name = _s(person['fullName']) ?? _s(person['name']) ?? '';
    return FullBox(
      title: title,
      leading: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.surfaceMuted,
            backgroundImage: img == null ? null : NetworkImage(img),
            child: img == null ? Icon(Icons.person, color: AppColors.textMuted) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ],
      ),
      rows: [
        FullRow('رقم المعرّف', _s(person['id'])),
        FullRow('الموبايل', _s(person['phoneNumber']) ?? _s(person['phone'])),
        FullRow('الإيميل', _s(person['email'])),
        FullRow('المحافظة', _s(person['governorate'])),
        FullRow('المدينة', _s(person['city'])),
        FullRow('العنوان', _s(person['address'])),
        FullRow('التقييم', person['rating'] is num && (person['rating'] as num) > 0 ? '${person['rating']}' : null),
        FullRow('موثّق', _yes(person['isVerified'])),
        FullRow('الحساب مجمّد', person['isFrozen'] == true ? 'نعم' : null),
        FullRow('اسم النشاط', _s(person['businessName'])),
        FullRow('نوع النشاط', _s(person['businessType'])),
        FullRow('مسجّل من', _date(person['joinedAt'])),
      ],
    );
  }
}

class FullOfferCard extends StatelessWidget {
  const FullOfferCard({super.key, required this.title, required this.offer});

  final String title;
  final Map<String, dynamic> offer;

  @override
  Widget build(BuildContext context) {
    final provider = offer['provider'] is Map ? Map<String, dynamic>.from(offer['provider'] as Map) : <String, dynamic>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FullBox(
          title: title,
          rows: [
            FullRow('السعر', _money(offer['price'])),
            FullRow('وصف العرض', _s(offer['description'])),
            FullRow('مدة التنفيذ', _s(offer['executionPeriod'])),
            FullRow('مرفق', _s(offer['attachmentUrl'])),
            FullRow('تم سحبه', offer['withdrawn'] == true ? 'نعم' : null),
            FullRow('تاريخ العرض', _date(offer['createdAt'])),
            if (offer['isAccepted'] != true) FullRow('مقدّم العرض', _s(provider['fullName']) ?? _s(provider['name'])),
            if (offer['isAccepted'] != true) FullRow('موبايله', _s(provider['phoneNumber'])),
          ],
        ),
      ],
    );
  }
}

class FullServiceSection extends StatelessWidget {
  const FullServiceSection({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final f = data['full'] is Map ? Map<String, dynamic>.from(data['full'] as Map) : <String, dynamic>{};
    String? coords(Object? a, Object? b) => (a != null && b != null) ? '$a, $b' : null;
    final photos = <String>[
      for (final u in (data['imageUrls'] as List? ?? const [])) if (_s(u) != null) '$u',
    ];
    return FullBox(
      title: 'بيانات الخدمة المطلوبة',
      leading: photos.isEmpty
          ? null
          : SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    photos[i],
                    width: 150,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => SizedBox(width: 150, child: ColoredBox(color: AppColors.surfaceMuted)),
                  ),
                ),
              ),
            ),
      rows: [
        FullRow('رقم الطلب', _s(data['requestNumber'])),
        FullRow('الخدمة', _s(data['subCategoryName'])),
        FullRow('الخيار المختار', _s(f['serviceOptionName'])),
        FullRow('الحالة', _s(data['status'])),
        FullRow('الوصف', _s(data['description'])),
        FullRow('السعر التقديري', _money(data['estimatedPrice'])),
        FullRow('المحافظة', _s(f['governorate'])),
        FullRow('المدينة', _s(f['city'])),
        FullRow('عنوان الاستلام', _s(f['pickupAddress'])),
        FullRow('إحداثيات الاستلام', coords(f['pickupLatitude'], f['pickupLongitude'])),
        FullRow('عنوان الخدمة / التوصيل', _s(f['deliveryAddress'])),
        FullRow('إحداثيات التوصيل', coords(f['deliveryLatitude'], f['deliveryLongitude'])),
        FullRow('الموعد المفضل', _date(f['preferredDate'])),
        FullRow('الفترة المفضلة', _s(f['preferredTimeSlot'])),
        FullRow('تاريخ الطلب', _date(f['createdAt'])),
        FullRow('انتهى المزوّد', _date(f['providerDoneAt'])),
        FullRow('اكتمل في', _date(f['completedAt'])),
        FullRow('تقييم العميل', _s(f['customerRating'])),
        FullRow('تعليق العميل', _s(f['customerReview'])),
        FullRow('موقع المزوّد', coords(f['providerLatitude'], f['providerLongitude'])),
        FullRow('سبب الرفض', _s(f['rejectionReason'])),
      ],
    );
  }
}
