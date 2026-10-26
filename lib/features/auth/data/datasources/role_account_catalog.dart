import 'package:barwah_app/features/auth/domain/entities/user_role.dart';

/// Role account metadata resolved from the e-mail prefix (development accounts
/// until the backend returns the role).
class RoleAccount {
  final UserRole role;
  final String name;
  final String badgeCode;

  const RoleAccount(this.role, this.name, this.badgeCode);
}

class RoleAccountCatalog {
  const RoleAccountCatalog._();

  static const Map<String, RoleAccount> byPrefix = {
    'admin': RoleAccount(UserRole.admin, 'مدير النظام', '#ADM-01'),
    'head': RoleAccount(UserRole.headOfSupervisors, 'رئيس المشرفين', '#HOS-01'),
    'merchant': RoleAccount(UserRole.merchantSupervisor, 'مشرف التجار', '#MER-01'),
    'wasalny': RoleAccount(UserRole.wasalnySupervisor, 'مشرف وصلني', '#WAS-01'),
    'services': RoleAccount(UserRole.servicesSupervisor, 'مشرف الخدمات', '#SRV-01'),
    'products': RoleAccount(UserRole.productSupervisor, 'مشرف المنتجات', '#PRD-01'),
    'finance': RoleAccount(UserRole.financialSupervisor, 'المشرف المالي', '#FIN-01'),
  };

  /// Department account id (as stored in the supervisor roster) -> role account.
  static RoleAccount? forDepartment(String accountId) => switch (accountId) {
        'merchant' => byPrefix['merchant'],
        'wasalny' => byPrefix['wasalny'],
        'products' => byPrefix['products'],
        'services' => byPrefix['services'],
        'finance' => byPrefix['finance'],
        _ => null,
      };
}
