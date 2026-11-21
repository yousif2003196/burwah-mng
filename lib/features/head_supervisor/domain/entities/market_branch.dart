/// فرع من فروع سوق برواح، بحساب تاجر خاص يدير أقسامه ومنتجاته.
class MarketBranch {
  const MarketBranch({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.phone,
    required this.managerName,
    required this.governorateId,
    required this.cityId,
    required this.governorate,
    required this.city,
    required this.address,
    required this.isActive,
    required this.deletionPending,
    required this.email,
    required this.sectionsCount,
    required this.productsCount,
    this.deletionReason = '',
  });

  final int id;
  final int merchantId;
  final String name;
  final String phone;
  final String managerName;
  final int? governorateId;
  final int? cityId;
  final String governorate;
  final String city;
  final String address;

  /// يظهر للعملاء في سوق برواح.
  final bool isActive;

  /// رئيس المشرفين طلب حذفه والأدمن لم يقرر بعد.
  final bool deletionPending;
  final String deletionReason;

  /// إيميل حساب التاجر الخاص بالفرع.
  final String email;
  final int sectionsCount;
  final int productsCount;
}

/// بيانات الفرع التي يكتبها رئيس المشرفين.
class MarketBranchDraft {
  const MarketBranchDraft({
    required this.name,
    required this.phone,
    required this.managerName,
    required this.governorateId,
    required this.cityId,
    required this.address,
    required this.isActive,
    this.email = '',
    this.password = '',
  });

  final String name;
  final String phone;
  final String managerName;
  final int governorateId;
  final int cityId;
  final String address;
  final bool isActive;

  /// حساب الفرع الجديد (عند الإضافة فقط).
  final String email;
  final String password;
}

/// طلب حذف فرع معلق عند الأدمن.
class MarketBranchDeletionRequest {
  const MarketBranchDeletionRequest({
    required this.id,
    required this.name,
    required this.place,
    required this.managerName,
    required this.reason,
    required this.requestedAt,
  });

  final int id;
  final String name;
  final String place;
  final String managerName;
  final String reason;
  final DateTime requestedAt;
}

class EgyptCity {
  const EgyptCity({required this.id, required this.name});
  final int id;
  final String name;
}

class EgyptGovernorate {
  const EgyptGovernorate({required this.id, required this.name, required this.cities});
  final int id;
  final String name;
  final List<EgyptCity> cities;
}
