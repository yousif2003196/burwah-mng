import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/repositories/wasalny_complaints_repository.dart';

class WasalnyComplaintsRepositoryImpl implements WasalnyComplaintsRepository {
  final WasalnyComplaintsDataSource dataSource;

  const WasalnyComplaintsRepositoryImpl({required this.dataSource});

  @override
  Future<List<WasalnyComplaint>> getComplaints() => dataSource.getComplaints();

  @override
  Future<WasalnyComplaint> escalateComplaint(
    String id, {
    required String reason,
  }) {
    return dataSource.escalateComplaint(id, reason: reason);
  }

  @override
  Future<WasalnyComplaint> resolveComplaint(
    String id, {
    required String note,
  }) {
    return dataSource.resolveComplaint(id, note: note);
  }

  @override
  Future<WasalnyComplaint> inspectComplaint(
    String id, {
    required String notes,
  }) {
    return dataSource.inspectComplaint(id, notes: notes);
  }
}
