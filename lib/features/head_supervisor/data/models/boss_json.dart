import 'package:barwah_app/features/head_supervisor/domain/entities/boss_status.dart';

/// قراءة آمنة لحقول JSON في ردود `BossOfSupervisor`.
///
/// الأرقام قد تصل `int` أو `double` أو نصًا، فكلها تُقرأ من `num`.
abstract final class BossJson {
  static Map<String, dynamic> map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static List<Map<String, dynamic>> mapList(Object? value) => [
        if (value is List)
          for (final item in value)
            if (item is Map) Map<String, dynamic>.from(item),
      ];

  static List<String> stringList(Object? value) => [
        if (value is List)
          for (final item in value)
            if (item != null && '$item'.trim().isNotEmpty) '$item'.trim(),
      ];

  static String text(Object? value) => value == null ? '' : '$value'.trim();

  static double number(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static int integer(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return num.tryParse(value.trim())?.toInt() ?? 0;
    return 0;
  }

  static int? optionalInteger(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return num.tryParse(value.trim())?.toInt();
    return null;
  }

  static bool boolean(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.trim().toLowerCase() == 'true';
    return false;
  }

  /// تواريخ السيرفر UTC وبتيجي أحيانًا من غير `Z`، فبنعتبرها UTC صراحةً
  /// (وإلا تظهر متأخرة ساعتين بتوقيت مصر).
  static DateTime? date(Object? value) {
    final raw = text(value);
    if (raw.isEmpty) return null;
    final hasZone =
        raw.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(raw);
    return DateTime.tryParse(hasZone ? raw : '${raw}Z')?.toLocal();
  }

  static BossStatus status(Object? value) {
    final raw = text(value);
    return BossStatus(raw: raw, kind: _statusKind(raw));
  }

  static BossStatusKind _statusKind(String raw) {
    final value = raw.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    if (value.isEmpty) return BossStatusKind.unknown;
    const english = <String, BossStatusKind>{
      'open': BossStatusKind.open,
      'new': BossStatusKind.open,
      'pending': BossStatusKind.pending,
      'onhold': BossStatusKind.pending,
      'frozen': BossStatusKind.pending,
      'suspended': BossStatusKind.pending,
      'underreview': BossStatusKind.underReview,
      'inreview': BossStatusKind.underReview,
      'inprogress': BossStatusKind.underReview,
      'investigating': BossStatusKind.underReview,
      'escalated': BossStatusKind.escalated,
      'rejected': BossStatusKind.rejected,
      'declined': BossStatusKind.rejected,
      'approved': BossStatusKind.approved,
      'accepted': BossStatusKind.approved,
      'resolved': BossStatusKind.resolved,
      'closed': BossStatusKind.closed,
      'completed': BossStatusKind.succeeded,
      'success': BossStatusKind.succeeded,
      'succeeded': BossStatusKind.succeeded,
      'failed': BossStatusKind.failed,
      'cancelled': BossStatusKind.failed,
      'canceled': BossStatusKind.failed,
    };
    final known = english[value];
    if (known != null) return known;
    // العربية: نبحث عن الجذر بدل التطابق الكامل.
    if (raw.contains('مصعد') || raw.contains('تصعيد')) {
      return BossStatusKind.escalated;
    }
    if (raw.contains('مرفوض') || raw.contains('رفض')) {
      return BossStatusKind.rejected;
    }
    if (raw.contains('معتمد') || raw.contains('مقبول') || raw.contains('موافق')) {
      return BossStatusKind.approved;
    }
    if (raw.contains('ناجح') || raw.contains('مكتمل') || raw.contains('تم')) {
      return BossStatusKind.succeeded;
    }
    if (raw.contains('فاشل') || raw.contains('فشل') || raw.contains('ملغ')) {
      return BossStatusKind.failed;
    }
    if (raw.contains('مغلق')) return BossStatusKind.closed;
    if (raw.contains('محسوم') || raw.contains('حسم') || raw.contains('محلول')) {
      return BossStatusKind.resolved;
    }
    if (raw.contains('مراجعة') || raw.contains('تحقيق') || raw.contains('فحص')) {
      return BossStatusKind.underReview;
    }
    if (raw.contains('معلق') || raw.contains('انتظار') || raw.contains('مجمد')) {
      return BossStatusKind.pending;
    }
    if (raw.contains('مفتوح') || raw.contains('جديد')) {
      return BossStatusKind.open;
    }
    return BossStatusKind.unknown;
  }
}
