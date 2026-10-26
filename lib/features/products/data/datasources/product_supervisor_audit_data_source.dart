import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';

abstract interface class ProductSupervisorAuditDataSource {
  Future<List<ProductSupervisorAuditEntry>> getEntries();

  Future<void> saveEntry(ProductSupervisorAuditEntry entry);
}
