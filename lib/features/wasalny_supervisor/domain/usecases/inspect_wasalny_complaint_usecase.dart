import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/repositories/wasalny_complaints_repository.dart';

class InspectWasalnyComplaintUseCase {
  final WasalnyComplaintsRepository repository;

  const InspectWasalnyComplaintUseCase(this.repository);

  Future<WasalnyComplaint> call(
    String id, {
    required String notes,
  }) {
    return repository.inspectComplaint(id, notes: notes);
  }
}

