import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';

/// التصعيدات الواردة لرئيس المشرفين من أقسام الخدمات والمستعمل.
abstract class HeadEscalationsRepository {
  Future<Either<Failure, List<HeadServiceEscalation>>> getServiceEscalations();

  Future<Either<Failure, Unit>> decideServiceEscalation(
    int id,
    ServiceEscalationDecision decision, {
    String note = '',
  });

  Future<Either<Failure, List<HeadProviderEscalation>>> getProviderEscalations();

  Future<Either<Failure, Unit>> suspendProvider(int providerId, String reason);

  Future<Either<Failure, Unit>> closeProviderEscalation(
    int providerId,
    String note,
  );

  Future<Either<Failure, List<HeadUsedComplaintEscalation>>>
      getUsedComplaintEscalations();

  Future<Either<Failure, Unit>> resolveUsedComplaint(
    int complaintId,
    String note,
  );
}
