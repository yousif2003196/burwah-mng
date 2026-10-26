import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/repositories/wasalny_complaints_repository.dart';

class ResolveWasalnyComplaintUseCase {
  final WasalnyComplaintsRepository repository;

  const ResolveWasalnyComplaintUseCase(this.repository);

  Future<WasalnyComplaint> call(
    String id, {
    required String note,
  }) {
    return repository.resolveComplaint(id, note: note);
  }
}
