import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_ads_api_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/repositories/wasalny_ads_repository_impl.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/get_wasalny_ads_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/update_wasalny_ad_status_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_ads_cubit.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_ads_review_screen.dart';

/// مراجعة إعلان وصلني مميز / VIP من تبويب الترويج: نفس شاشة التفاصيل
/// والعمليات (قبول، رفض، تجميد، تعديل) بتاعة مراجعة إعلانات وصلني.
class WasalnyPromotedAdReviewScreen extends StatelessWidget {
  const WasalnyPromotedAdReviewScreen({super.key, required this.adId});

  final String adId;

  @override
  Widget build(BuildContext context) {
    final repository = WasalnyAdsRepositoryImpl(
      dataSource: WasalnyAdsApiDataSource(
        apiConsumer: sl<ApiConsumer>(instanceName: 'berwah'),
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
      ),
      body: BlocProvider(
        create: (_) => WasalnyAdsCubit(
          getAds: GetWasalnyAdsUseCase(repository: repository),
          updateAdStatus: UpdateWasalnyAdStatusUseCase(repository: repository),
        )..loadAds(),
        child: WasalnyAdsReviewScreen(openAdId: adId),
      ),
    );
  }
}
