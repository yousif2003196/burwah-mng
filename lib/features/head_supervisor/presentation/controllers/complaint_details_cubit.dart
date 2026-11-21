import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/decide_complaint_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_complaint_details_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/summon_supervisor_chat_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/unban_and_investigate_usecase.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';

typedef ComplaintDetailsState = BossLoadState<MerchantComplaintDetails>;

/// تفاصيل تظلم واحد + إجراءاته (استدعاء / فك حظر وتحقيق / قرار).
class ComplaintDetailsCubit extends Cubit<ComplaintDetailsState> {
  ComplaintDetailsCubit({
    required this.getDetails,
    required this.summonChat,
    required this.unbanAndInvestigate,
    required this.decideComplaint,
  }) : super(const BossLoading());

  final GetComplaintDetailsUseCase getDetails;
  final SummonSupervisorChatUseCase summonChat;
  final UnbanAndInvestigateUseCase unbanAndInvestigate;
  final DecideComplaintUseCase decideComplaint;
  int? _complaintId;

  Future<void> load(int complaintId) async {
    _complaintId = complaintId;
    emit(const BossLoading());
    final result = await getDetails(complaintId);
    if (isClosed || _complaintId != complaintId) return;
    emit(result.fold<ComplaintDetailsState>(
      (failure) => BossLoadFailure(failure.message),
      (details) => BossLoaded(details),
    ));
  }

  Future<void> retry() async {
    final id = _complaintId;
    if (id != null) await load(id);
  }

  Future<BossActionResult<SummonChatResult>> summon({
    required SummonTopic topic,
    required String initialMessage,
    required bool attachCaseDocument,
  }) async {
    final id = _complaintId;
    if (id == null) return const BossActionResult.failure('');
    final result = await summonChat(
      id,
      topic: topic,
      initialMessage: initialMessage.trim(),
      attachCaseDocument: attachCaseDocument,
    );
    return result.fold(
      (failure) => BossActionResult.failure(failure.message),
      (chat) => BossActionResult.success(chat.message, chat),
    );
  }

  Future<BossActionResult<void>> unban(UnbanInvestigationRequest request) async {
    final id = _complaintId;
    if (id == null) return const BossActionResult.failure('');
    final result = await unbanAndInvestigate(id, request);
    return result.fold(
      (failure) => BossActionResult<void>.failure(failure.message),
      (message) => BossActionResult<void>.success(message),
    );
  }

  Future<BossActionResult<void>> decide({
    required ComplaintDecisionType decisionType,
    required String notes,
  }) async {
    final id = _complaintId;
    if (id == null) return const BossActionResult.failure('');
    final result = await decideComplaint(
      id,
      decisionType: decisionType,
      notes: notes.trim(),
    );
    return result.fold(
      (failure) => BossActionResult<void>.failure(failure.message),
      (message) => BossActionResult<void>.success(message),
    );
  }
}
