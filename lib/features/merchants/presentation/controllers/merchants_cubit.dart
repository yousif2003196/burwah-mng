import 'package:flutter_bloc/flutter_bloc.dart';

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
  }) : super(const MerchantsInitial());

  Future<void> loadMerchants() async {
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
