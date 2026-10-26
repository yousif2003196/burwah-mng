import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/domain/entities/supervisor_stats_entity.dart';

abstract class MerchantsState {
  const MerchantsState();
}

class MerchantsInitial extends MerchantsState {
  const MerchantsInitial();
}

class MerchantsLoading extends MerchantsState {
  const MerchantsLoading();
}

class MerchantsLoaded extends MerchantsState {
  final SupervisorStatsEntity stats;
  final List<MerchantEntity> allMerchants;
  final List<MerchantEntity> filteredMerchants;
  final MerchantStatus? activeStatusFilter;
  final String searchQuery;
  final int selectedFilterIndex; // 0: الكل, 1: نشط وموثق, 2: قيد التدقيق, 3: تحديث بيانات, 4: معلق مؤقتاً

  const MerchantsLoaded({
    required this.stats,
    required this.allMerchants,
    required this.filteredMerchants,
    this.activeStatusFilter,
    this.searchQuery = '',
    this.selectedFilterIndex = 0,
  });

  MerchantsLoaded copyWith({
    SupervisorStatsEntity? stats,
    List<MerchantEntity>? allMerchants,
    List<MerchantEntity>? filteredMerchants,
    MerchantStatus? Function()? activeStatusFilter,
    String? searchQuery,
    int? selectedFilterIndex,
  }) {
    return MerchantsLoaded(
      stats: stats ?? this.stats,
      allMerchants: allMerchants ?? this.allMerchants,
      filteredMerchants: filteredMerchants ?? this.filteredMerchants,
      activeStatusFilter: activeStatusFilter != null
          ? activeStatusFilter()
          : this.activeStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
    );
  }
}

class MerchantsError extends MerchantsState {
  final String message;

  const MerchantsError({required this.message});
}

