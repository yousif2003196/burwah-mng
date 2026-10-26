import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';

class RecordProductSupervisorAuditEntryUseCase {
  final ProductSupervisorAuditRepository repository;

  const RecordProductSupervisorAuditEntryUseCase({required this.repository});

  Future<void> call(ProductSupervisorAuditEntry entry) =>
      repository.recordEntry(entry);
}
