import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  const WasalnyComplaintsLoaded(this.complaints);
}

class WasalnyComplaintsCubit extends Cubit<WasalnyComplaintsState> {
  final GetWasalnyComplaintsUseCase getComplaints;
  final EscalateWasalnyComplaintUseCase escalateComplaint;
  final ResolveWasalnyComplaintUseCase resolveComplaint;

  WasalnyComplaintsCubit({
    required this.getComplaints,
    required this.escalateComplaint,
    required this.resolveComplaint,
  }) : super(const WasalnyComplaintsLoading());

  Future<void> loadComplaints() async {
    emit(const WasalnyComplaintsLoading());
    try {
      emit(WasalnyComplaintsLoaded(await getComplaints()));
    } catch (error) {
      emit(WasalnyComplaintsLoadFailure(error));
    }
  }

  /// يحدّث القائمة من غير شاشة تحميل (للسحب للتحديث).
  Future<void> refresh() async {
    try {
      emit(WasalnyComplaintsLoaded(await getComplaints()));
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Wasalny complaints',
          context: ErrorDescription('while refreshing complaints'),
        ),
      );
    }
  }

  Future<bool> resolve({required String id, required String note}) {
    return _updateComplaint(() => resolveComplaint(id, note: note), id);
  }

  Future<bool> escalate({required String id, required String reason}) {
    return _updateComplaint(() => escalateComplaint(id, reason: reason), id);
  }

  Future<bool> _updateComplaint(
    Future<WasalnyComplaint> Function() update,
    String id,
  ) async {
    final current = state;
    if (current is! WasalnyComplaintsLoaded) return false;
    try {
      final updated = await update();
      emit(WasalnyComplaintsLoaded([
        for (final complaint in current.complaints)
          complaint.id == id ? updated : complaint,
      ]));
      return true;
    } catch (error) {
      emit(WasalnyComplaintsLoadFailure(error));
      return false;
    }
  }
}
