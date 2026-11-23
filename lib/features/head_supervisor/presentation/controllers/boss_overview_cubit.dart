import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/supervisor_escalations_api.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_merchant_complaints_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_provider_escalations_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_service_escalations_usecase.dart';
import 'package:barwah_app/features/head_supervisor/domain/usecases/get_used_complaint_escalations_usecase.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';

/// مصدر عنصر ينتظر قرار رئيس المشرفين.
enum BossDecisionKind {
  serviceRequest,
  provider,
  usedComplaint,
  merchantComplaint,

  /// تصعيد من مشرف المنتجات الجديدة / التجار / شكاوى الخدمات.
  supervisorEscalation,
}

/// عنصر واحد في "يحتاج قرارك الآن".
class BossDecisionItem {
  final BossDecisionKind kind;
  final int id;
  final String title;
  final String subtitle;
  final DateTime? createdAt;

  const BossDecisionItem({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
  });
}

/// مؤشرات "نظرة عامة" اللي محتاجة قرار رئيس المشرفين.
class BossOverviewSnapshot {
  /// كل اللي مستني قراره: التصعيدات + الشكاوى المفتوحة.
  final int pendingDecisions;
  final int openComplaints;
  final List<BossDecisionItem> latestItems;

  /// مصادر فشل تحميلها (الباقي ظاهر عادي).
  final int failedSources;

  const BossOverviewSnapshot({
    required this.pendingDecisions,
    required this.openComplaints,
    required this.latestItems,
    required this.failedSources,
  });
}

typedef BossOverviewState = BossLoadState<BossOverviewSnapshot>;

/// يجمع كل اللي مستني قرار رئيس المشرفين من الأقسام:
/// طلبات خدمات مشبوهة، مقدمي خدمات مرفوعين، شكاوى مستعمل مصعّدة، وشكاوى مفتوحة.
class BossOverviewCubit extends Cubit<BossOverviewState> {
  BossOverviewCubit({
    required this.getServiceEscalations,
    required this.getProviderEscalations,
    required this.getUsedComplaintEscalations,
    required this.getComplaints,
    this.escalations,
  }) : super(const BossLoading());

  final GetServiceEscalationsUseCase getServiceEscalations;
  final GetProviderEscalationsUseCase getProviderEscalations;
  final GetUsedComplaintEscalationsUseCase getUsedComplaintEscalations;
  final GetMerchantComplaintsUseCase getComplaints;
  final SupervisorEscalationsApi? escalations;
  int _requestId = 0;

  /// عدد العناصر الظاهرة في اللوحة.
  static const visibleItems = 5;

  Future<void> load() async {
    final id = ++_requestId;
    if (state is! BossLoaded<BossOverviewSnapshot>) emit(const BossLoading());

    final results = await Future.wait<Either<Failure, List<BossDecisionItem>>>([
      _map(getServiceEscalations(), (items) => [
            for (final item in items)
              BossDecisionItem(
                kind: BossDecisionKind.serviceRequest,
                id: item.id,
                title: item.subCategory.isEmpty
                    ? 'طلب خدمة #${item.id}'
                    : '${item.subCategory} #${item.id}',
                subtitle: item.referralReason.isNotEmpty
                    ? item.referralReason
                    : item.client,
                createdAt: null,
              ),
          ]),
      _map(getProviderEscalations(), (items) => [
            for (final item in items)
              BossDecisionItem(
                kind: BossDecisionKind.provider,
                id: item.providerId,
                title: item.name.isEmpty ? 'مقدم خدمة #${item.providerId}' : item.name,
                subtitle: item.reason.isNotEmpty ? item.reason : item.businessType,
                createdAt: item.at,
              ),
          ]),
      _map(getUsedComplaintEscalations(), (items) => [
            for (final item in items)
              BossDecisionItem(
                kind: BossDecisionKind.usedComplaint,
                id: item.complaintId,
                title: item.title.isEmpty ? 'شكوى #${item.complaintId}' : item.title,
                subtitle: item.reason.isNotEmpty ? item.reason : item.buyerName,
                createdAt: null,
              ),
          ]),
      _map(getComplaints(), (items) => [
            for (final item in items)
              if (!item.status.isFinal)
                BossDecisionItem(
                  kind: BossDecisionKind.merchantComplaint,
                  id: item.id,
                  title: item.title.isEmpty ? item.code : item.title,
                  subtitle: item.complainant,
                  createdAt: item.createdAt,
                ),
          ]),
      _supervisorEscalations(),
    ]);
    if (isClosed || id != _requestId) return;

    final failures = results.where((result) => result.isLeft()).toList();
    if (failures.length == results.length) {
      emit(BossLoadFailure(failures.first.fold((f) => f.message, (_) => '')));
      return;
    }

    final all = [
      for (final result in results)
        ...result.getOrElse(() => const <BossDecisionItem>[]),
    ];
    final complaints = results[3].getOrElse(() => const <BossDecisionItem>[]);
    // الأحدث أولًا؛ العناصر من غير تاريخ تيجي بعد المؤرّخة.
    all.sort((a, b) {
      final at = a.createdAt, bt = b.createdAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    emit(BossLoaded(BossOverviewSnapshot(
      pendingDecisions: all.length,
      openComplaints: complaints.length,
      latestItems: all.take(visibleItems).toList(),
      failedSources: failures.length,
    )));
  }

  Future<Either<Failure, List<BossDecisionItem>>> _supervisorEscalations() async {
    final api = escalations;
    if (api == null || !SupervisorEscalationsApi.headCanUse) return const Right([]);
    try {
      final items = await api.pending();
      return Right([
        for (final item in items)
          BossDecisionItem(
            kind: BossDecisionKind.supervisorEscalation,
            id: item.id,
            title: item.title.isEmpty ? 'تصعيد #${item.id}' : item.title,
            subtitle: '${item.departmentName} • ${item.supervisorName}',
            createdAt: item.createdAt,
          ),
      ]);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  static Future<Either<Failure, List<BossDecisionItem>>> _map<T>(
    Future<Either<Failure, List<T>>> call,
    List<BossDecisionItem> Function(List<T> items) toItems,
  ) async {
    try {
      final result = await call;
      return result.map(toItems);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
