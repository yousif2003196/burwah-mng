import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/repositories/wasalny_complaints_repository.dart';

class GetWasalnyComplaintsUseCase {
  final WasalnyComplaintsRepository repository;

  const GetWasalnyComplaintsUseCase(this.repository);

  Future<List<WasalnyComplaint>> call() {
    return repository.getComplaints();
  }
}

