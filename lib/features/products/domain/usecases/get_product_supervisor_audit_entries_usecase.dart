import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';

class GetProductSupervisorAuditEntriesUseCase {
  final ProductSupervisorAuditRepository repository;

  const GetProductSupervisorAuditEntriesUseCase({required this.repository});

  Future<List<ProductSupervisorAuditEntry>> call() => repository.getEntries();
}
