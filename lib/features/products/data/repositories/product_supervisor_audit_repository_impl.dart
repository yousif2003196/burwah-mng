import 'package:barwah_app/features/products/data/datasources/product_supervisor_audit_data_source.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';

class ProductSupervisorAuditRepositoryImpl
    implements ProductSupervisorAuditRepository {
  final ProductSupervisorAuditDataSource dataSource;

  const ProductSupervisorAuditRepositoryImpl({required this.dataSource});

  @override
  Future<List<ProductSupervisorAuditEntry>> getEntries() async {
    final entries = await dataSource.getEntries();
    entries.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return entries;
  }

  @override
  Future<void> recordEntry(ProductSupervisorAuditEntry entry) =>
      dataSource.saveEntry(entry);
}
