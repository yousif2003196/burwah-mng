import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class SummonSupervisorChatUseCase {
  final BossSupervisorRepository repository;

  const SummonSupervisorChatUseCase(this.repository);

  Future<Either<Failure, SummonChatResult>> call(
    int complaintId, {
    required SummonTopic topic,
    required String initialMessage,
    required bool attachCaseDocument,
  }) {
    return repository.summonSupervisorChat(
      complaintId,
      topic: topic,
      initialMessage: initialMessage,
      attachCaseDocument: attachCaseDocument,
    );
  }
}
