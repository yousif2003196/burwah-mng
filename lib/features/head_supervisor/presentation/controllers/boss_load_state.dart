/// حالة تحميل عامة لشاشات رئيس المشرفين: تحميل / فشل / بيانات.
sealed class BossLoadState<T> {
  const BossLoadState();
}

class BossLoading<T> extends BossLoadState<T> {
  const BossLoading();
}

class BossLoadFailure<T> extends BossLoadState<T> {
  final String message;

  const BossLoadFailure(this.message);
}

class BossLoaded<T> extends BossLoadState<T> {
  final T data;

  const BossLoaded(this.data);
}

/// نتيجة إجراء (قرار / صرف / استدعاء): النجاح + رسالة الخادم كما هي.
class BossActionResult<T> {
  final bool success;
  final String message;
  final T? data;

  const BossActionResult.success(this.message, [this.data]) : success = true;

  const BossActionResult.failure(this.message)
      : success = false,
        data = null;
}
