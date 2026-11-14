import 'package:barwah_app/features/auth/domain/entities/user_role.dart';

/// أقسام التطبيق التي يفتحها الحساب بعد الدخول.
enum AppSection {
  adminDashboard,
  adsReview,
  merchants,
  serviceRequests,
  usedGoods,
  finance,
  headOfSupervisors;

  /// الأقسام المسموح بها لكل دور: الأدمن يختار بين لوحته والأقسام الأربعة،
  /// وكل دور آخر له قسم واحد فقط.
  static List<AppSection> allowedFor(UserRole role) => switch (role) {
        UserRole.admin => const [
            adminDashboard,
            adsReview,
            merchants,
            serviceRequests,
            usedGoods,
          ],
        UserRole.productSupervisor => const [adsReview],
        UserRole.merchantSupervisor => const [merchants],
        UserRole.servicesSupervisor => const [serviceRequests],
        UserRole.wasalnySupervisor => const [usedGoods],
        UserRole.financialSupervisor => const [finance],
        UserRole.headOfSupervisors => const [headOfSupervisors],
      };

  bool isAllowedFor(UserRole role) => allowedFor(role).contains(this);
}
