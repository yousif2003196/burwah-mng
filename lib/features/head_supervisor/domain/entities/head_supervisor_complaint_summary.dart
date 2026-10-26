import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_audit_store.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_complaint_store.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_audit_record.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_complaint.dart';

class HeadSupervisorComplaintSummary {
  static Future<int> getOpenCount() async {
    final results = await Future.wait<Object>([
      HeadSupervisorAuditStore().getAll(),
      HeadSupervisorComplaintStore().getAll(),
    ]);
    final auditRecords = results[0] as List<HeadSupervisorAuditRecord>;
    final complaints = results[1] as List<HeadSupervisorComplaint>;
    final actionIds = auditRecords.map((record) => record.subjectId).toSet();
    return complaints
        .where((complaint) =>
            complaint.reopenedForReview || !actionIds.contains(complaint.id))
        .length;
  }
}
