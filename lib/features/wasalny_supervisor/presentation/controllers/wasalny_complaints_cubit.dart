import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_case_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/escalate_wasalny_complaint_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/get_wasalny_complaints_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/resolve_wasalny_complaint_usecase.dart';

sealed class WasalnyComplaintsState {
  const WasalnyComplaintsState();
}

class WasalnyComplaintsLoading extends WasalnyComplaintsState {
  const WasalnyComplaintsLoading();
}

class WasalnyComplaintsLoadFailure extends WasalnyComplaintsState {
  final Object error;

  const WasalnyComplaintsLoadFailure(this.error);
}

class WasalnyComplaintsLoaded extends WasalnyComplaintsState {
  final List<WasalnyComplaint> complaints;
  final Map<String, WasalnyCaseRecord> cases;

  const WasalnyComplaintsLoaded(this.complaints, {this.cases = const {}});
}

class WasalnyComplaintsCubit extends Cubit<WasalnyComplaintsState> {
  final GetWasalnyComplaintsUseCase getComplaints;
  final EscalateWasalnyComplaintUseCase escalateComplaint;
  final ResolveWasalnyComplaintUseCase resolveComplaint;
  final ProductSupervisorAuditRepository? auditRepository;
  final WasalnyCaseStore? caseStore;

  WasalnyComplaintsCubit({
    required this.getComplaints,
    required this.escalateComplaint,
    required this.resolveComplaint,
    this.auditRepository,
    this.caseStore,
  }) : super(const WasalnyComplaintsLoading());

  Future<void> loadComplaints() async {
    emit(const WasalnyComplaintsLoading());
    try {
      emit(await _build(await getComplaints()));
    } catch (error) {
      emit(WasalnyComplaintsLoadFailure(error));
    }
  }

  /// Re-reads head decisions without showing the loading state.
  Future<void> syncDecisions() async {
    if (caseStore == null || state is! WasalnyComplaintsLoaded) return;
    try {
      emit(await _build(await getComplaints()));
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Wasalny complaints',
          context: ErrorDescription('while syncing head decisions'),
        ),
      );
    }
  }

  Future<WasalnyComplaintsLoaded> _build(List<WasalnyComplaint> raw) async {
    final store = caseStore;
    if (store == null) return WasalnyComplaintsLoaded(raw);
    final cases = await store.refresh(raw);
    return WasalnyComplaintsLoaded(WasalnyCaseStore.apply(raw, cases),
        cases: cases);
  }

  Future<bool> resolve({required String id, required String note}) {
    return _updateComplaint(
      () => resolveComplaint(id, note: note),
      id,
      actionKey: 'wasalny_complaint_resolved',
      actionDetails: note,
    );
  }

  Future<bool> escalate({required String id, required String reason}) {
    return _updateComplaint(
      () => escalateComplaint(id, reason: reason),
      id,
      actionKey: 'wasalny_complaint_escalated',
      actionDetails: reason,
    );
  }

  Future<bool> _updateComplaint(
    Future<WasalnyComplaint> Function() update,
    String id, {
    required String actionKey,
    required String actionDetails,
  }) async {
    final current = state;
    if (current is! WasalnyComplaintsLoaded) return false;
    try {
      final updated = await update();
      final store = caseStore;
      if (actionKey == 'wasalny_complaint_escalated') {
        final round = store == null ? 0 : await store.escalationCount(id);
        try {
          await LocalEventStore().publish(
            LocalEvent(
              id: round == 0 ? 'head-${updated.id}' : 'head-${updated.id}-r${round + 1}',
              recipient: 'head',
              source: 'wasalny',
              titleAr: 'تصعيد شكوى وصلني',
              titleEn: 'Wasalny complaint escalated',
              messageAr:
                  '${updated.id}: ${updated.titleAr} — ${updated.actionNoteAr ?? actionDetails}',
              messageEn:
                  '${updated.id}: ${updated.titleEn} — ${updated.actionNoteEn ?? actionDetails}',
              createdAt: DateTime.now(),
            ),
          );
        } catch (error, stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'Wasalny complaints',
              context:
                  ErrorDescription('while notifying the head supervisor'),
            ),
          );
        }
      }
      if (store != null) {
        if (actionKey == 'wasalny_complaint_escalated') {
          await store.recordEscalation(id, actionDetails);
        } else if (actionKey == 'wasalny_complaint_resolved') {
          await store.recordResolved(id, actionDetails);
        }
      }
      await auditRepository?.recordEntry(
        ProductSupervisorAuditEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          actionKey: actionKey,
          subject: updated.titleAr,
          details: [
            updated.id,
            if (updated.dealCode != null) updated.dealCode!,
            actionDetails,
          ].join(' • '),
          occurredAt: DateTime.now(),
        ),
      );
      final merged = [
        for (final complaint in current.complaints)
          complaint.id == id ? updated : complaint,
      ];
      emit(store == null
          ? WasalnyComplaintsLoaded(merged)
          : await _build(merged));
      return true;
    } catch (error) {
      emit(WasalnyComplaintsLoadFailure(error));
      return false;
    }
  }
}
