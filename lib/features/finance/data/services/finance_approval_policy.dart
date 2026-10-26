import 'package:flutter/foundation.dart';

import 'package:barwah_app/features/admin/data/datasources/admin_preferences_store.dart';

/// متى يحتاج اعتماد المشرف المالي إلى مصادقة الأدمن النهائية.
class FinanceApprovalPolicy {
  const FinanceApprovalPolicy._();

  /// true إذا لم يكن الطلب جاهزًا للصرف الفوري، أو تجاوز سقف الأدمن (إن وُجد).
  static Future<bool> needsAdmin(
    double amount, {
    required bool instantReady,
  }) async {
    if (!instantReady) return true;
    try {
      final cap = await AdminPreferencesStore().financeApprovalCap();
      return cap > 0 && amount > cap;
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'finance approval policy',
      ));
      // عند تعذر قراءة السقف نختار الأحوط: مصادقة الأدمن.
      return true;
    }
  }
}
