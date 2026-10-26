import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';

abstract class WasalnyComplaintsRepository {
  Future<List<WasalnyComplaint>> getComplaints();
  Future<WasalnyComplaint> escalateComplaint(
    String id, {
    required String reason,
  });
  Future<WasalnyComplaint> resolveComplaint(
    String id, {
    required String note,
  });
  Future<WasalnyComplaint> inspectComplaint(
    String id, {
    required String notes,
  });
}
