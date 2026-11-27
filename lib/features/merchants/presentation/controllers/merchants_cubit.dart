import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/merchants/data/datasources/merchant_advertisement_local_store.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_supervisor_local_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/domain/usecases/get_merchants_usecase.dart';
import 'package:barwah_app/features/merchants/domain/usecases/get_supervised_merchants_usecase.dart';
import 'package:barwah_app/features/merchants/domain/usecases/get_supervisor_stats_usecase.dart';
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_state.dart';

class MerchantsCubit extends Cubit<MerchantsState> {
  final GetMerchantsUseCase getMerchantsUseCase;
  final GetSupervisorStatsUseCase getSupervisorStatsUseCase;
  final GetSupervisedMerchantsUseCase? getSupervisedMerchantsUseCase;

  MerchantsCubit({
    required this.getMerchantsUseCase,
    required this.getSupervisorStatsUseCase,
    this.getSupervisedMerchantsUseCase,
  }) : super(const MerchantsInitial()) {
    MerchantSupervisorLocalStore.revision.addListener(_silentRefresh);
    MerchantAdvertisementLocalStore.version.addListener(_silentRefresh);
  }

  @override
  Future<void> close() {
    MerchantSupervisorLocalStore.revision.removeListener(_silentRefresh);
    MerchantAdvertisementLocalStore.version.removeListener(_silentRefresh);
    return super.close();
  }

  /// يعيد تحميل التجار من السيرفر بعد أي إجراء (إيقاف/عمولة/إخفاء منتج)
  /// بدون وميض شاشة التحميل، مع الحفاظ على الفلتر والبحث.
  Future<void> _silentRefresh() async {
    final current = state;
    if (current is! MerchantsLoaded || isClosed) return;
    try {
      final stats = await getSupervisorStatsUseCase();
      final merchants = _supervised && getSupervisedMerchantsUseCase != null
          ? await getSupervisedMerchantsUseCase!()
          : await getMerchantsUseCase();
      if (isClosed) return;
      emit(current.copyWith(
        stats: stats,
        allMerchants: merchants,
        filteredMerchants: _applyFilters(
          merchants: merchants,
          status: current.activeStatusFilter,
          query: current.searchQuery,
        ),
      ));
    } catch (_) {
      // نسيب القائمة الحالية زي ما هي لو التحديث فشل.
    }
  }

  /// آخر تحميل كان لتجار المشرف بس ولا لكل التجار (التحديث يكمّل على نفس المصدر).
  bool _supervised = false;

  /// سحب للتحديث: القائمة تفضل ظاهرة (من غير شاشة تحميل تشيل الـ ListView
  /// من تحت مؤشر السحب) والفلتر والبحث يفضلوا زي ما هما.
  Future<void> refresh() async {
    if (state is! MerchantsLoaded) {
      return _supervised ? loadSupervisedMerchants() : loadMerchants();
    }
    await _silentRefresh();
  }

  Future<void> loadMerchants() async {
    _supervised = false;
    emit(const MerchantsLoading());
    try {
      final stats = await getSupervisorStatsUseCase();
      final merchants = await getMerchantsUseCase();
      emit(MerchantsLoaded(
        stats: stats,
        allMerchants: merchants,
        filteredMerchants: merchants,
      ));
    } catch (e) {
      emit(MerchantsError(message: e.toString()));
    }
  }

  Future<void> loadSupervisedMerchants() async {
    _supervised = true;
    emit(const MerchantsLoading());
    try {
      final stats = await getSupervisorStatsUseCase();
      final merchants = getSupervisedMerchantsUseCase != null
          ? await getSupervisedMerchantsUseCase!()
          : await getMerchantsUseCase();
      emit(MerchantsLoaded(
        stats: stats,
        allMerchants: merchants,
        filteredMerchants: merchants,
      ));
    } catch (e) {
      emit(MerchantsError(message: e.toString()));
    }
  }

  void setFilterIndex(int index) {
    if (state is! MerchantsLoaded) return;
    final currentState = state as MerchantsLoaded;

    MerchantStatus? filter;
    if (index == 1) {
      filter = MerchantStatus.activeVerified;
    } else if (index == 2) {
      filter = MerchantStatus.underAudit;
    } else if (index == 3) {
      filter = MerchantStatus.updateRequired;
    } else if (index == 4) {
      filter = MerchantStatus.temporarilySuspended;
    }

    final filtered = _applyFilters(
      merchants: currentState.allMerchants,
      status: filter,
      query: currentState.searchQuery,
    );

    emit(currentState.copyWith(
      selectedFilterIndex: index,
      activeStatusFilter: () => filter,
      filteredMerchants: filtered,
    ));
  }

  void setFilterStatus(MerchantStatus? status, int index) {
    if (state is! MerchantsLoaded) return;
    final currentState = state as MerchantsLoaded;

    final filtered = _applyFilters(
      merchants: currentState.allMerchants,
      status: status,
      query: currentState.searchQuery,
    );

    emit(currentState.copyWith(
      selectedFilterIndex: index,
      activeStatusFilter: () => status,
      filteredMerchants: filtered,
    ));
  }

  void searchMerchants(String query) {
    if (state is! MerchantsLoaded) return;
    final currentState = state as MerchantsLoaded;

    final filtered = _applyFilters(
      merchants: currentState.allMerchants,
      status: currentState.activeStatusFilter,
      query: query,
    );

    emit(currentState.copyWith(
      searchQuery: query,
      filteredMerchants: filtered,
    ));
  }

  List<MerchantEntity> _applyFilters({
    required List<MerchantEntity> merchants,
    MerchantStatus? status,
    String query = '',
  }) {
    return merchants.where((m) {
      if (status != null && m.status != status) {
        return false;
      }
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = m.name.toLowerCase().contains(q) ||
            m.nameEn.toLowerCase().contains(q);
        final matchCr = m.crNumber.contains(q);
        final matchCategory = m.category.toLowerCase().contains(q) ||
            m.categoryEn.toLowerCase().contains(q);
        final matchCode = (m.code ?? '').toLowerCase().contains(q);
        final matchLocation = (m.location ?? '').toLowerCase().contains(q) ||
            (m.locationEn ?? '').toLowerCase().contains(q);
        final matchDelegate = (m.delegateName ?? '').toLowerCase().contains(q) ||
            (m.delegateNameEn ?? '').toLowerCase().contains(q);
        return matchName ||
            matchCr ||
            matchCategory ||
            matchCode ||
            matchLocation ||
            matchDelegate;
      }
      return true;
    }).toList();
  }
}
