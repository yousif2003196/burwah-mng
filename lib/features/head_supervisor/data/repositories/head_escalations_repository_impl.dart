import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:barwah_app/core/errors/failure_mapper.dart';
import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_escalations_remote_data_source.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/head_escalations_repository.dart';

class HeadEscalationsRepositoryImpl implements HeadEscalationsRepository {
  final HeadEscalationsRemoteDataSource dataSource;

  const HeadEscalationsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<HeadServiceEscalation>>> getServiceEscalations() =>
      _guard('service escalations', dataSource.getServiceEscalations);

  @override
  Future<Either<Failure, Unit>> decideServiceEscalation(
    int id,
    ServiceEscalationDecision decision, {
    String note = '',
  }) =>
      _guard('service escalation $id', () async {
        await dataSource.decideServiceEscalation(id, decision, note);
        return unit;
      });

  @override
  Future<Either<Failure, List<HeadProviderEscalation>>>
      getProviderEscalations() =>
          _guard('provider escalations', dataSource.getProviderEscalations);

  @override
  Future<Either<Failure, Unit>> suspendProvider(int providerId, String reason) =>
      _guard('suspend provider $providerId', () async {
        await dataSource.suspendProvider(providerId, reason);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> closeProviderEscalation(
    int providerId,
    String note,
  ) =>
      _guard('close provider escalation $providerId', () async {
        await dataSource.closeProviderEscalation(providerId, note);
        return unit;
      });

  @override
  Future<Either<Failure, List<HeadUsedComplaintEscalation>>>
      getUsedComplaintEscalations() => _guard(
            'used complaint escalations',
            dataSource.getUsedComplaintEscalations,
          );

  @override
  Future<Either<Failure, Unit>> resolveUsedComplaint(
    int complaintId,
    String note,
  ) =>
      _guard('resolve used complaint $complaintId', () async {
        await dataSource.resolveUsedComplaint(complaintId, note);
        return unit;
      });

  Future<Either<Failure, T>> _guard<T>(
    String label,
    Future<T> Function() call,
  ) async {
    try {
      return Right(await call());
    } on Object catch (error) {
      debugPrint('Head escalations: $label failed: $error');
      return Left(failureFrom(error));
    }
  }
}
