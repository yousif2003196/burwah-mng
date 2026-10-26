import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/repositories/wasalny_complaints_repository.dart';

class EscalateWasalnyComplaintUseCase {
  final WasalnyComplaintsRepository repository;

  const EscalateWasalnyComplaintUseCase(this.repository);

  Future<WasalnyComplaint> call(
    String id, {
    required String reason,
  }) {
    return repository.escalateComplaint(id, reason: reason);
  }
}

