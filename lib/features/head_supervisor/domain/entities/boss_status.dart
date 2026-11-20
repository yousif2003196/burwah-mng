/// الفئة الموحدة لحالة يرسلها الباك إند بالعربي أو بالإنجليزي.
enum BossStatusKind {
  open,
  pending,
  underReview,
  escalated,
  rejected,
  approved,
  resolved,
  closed,
  succeeded,
  failed,
  unknown,
}

/// حالة من الخادم: النص الأصلي كما وصل + فئة آمنة للاستخدام في الواجهة.
///
/// القيم تخلط العربي والإنجليزي (`Rejected`, `مصعد لرئيس المشرفين`, `ناجح`)،
/// وأي قيمة غير معروفة تتحول إلى [BossStatusKind.unknown] بدون أن تكسر الشاشة.
class BossStatus {
  final String raw;
  final BossStatusKind kind;

  const BossStatus({required this.raw, required this.kind});

  const BossStatus.unknown() : raw = '', kind = BossStatusKind.unknown;

  bool get isUrgent =>
      kind == BossStatusKind.rejected ||
      kind == BossStatusKind.escalated ||
      kind == BossStatusKind.failed;

  /// الحالات التي تعني أن الملف انتهى ولم يعد ينتظر قرارًا.
  bool get isFinal =>
      kind == BossStatusKind.approved ||
      kind == BossStatusKind.resolved ||
      kind == BossStatusKind.closed;
}
