import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_cubit.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_state.dart';
import 'package:barwah_app/features/products/presentation/screens/product_review_details_screen.dart';
import 'package:barwah_app/features/products/presentation/widgets/product_review_dialogs.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

/// مراجعة إعلان مميز / VIP من تبويب ترويج المنتجات: نفس شاشة العرض والعمليات
/// (قبول، رفض، إخفاء، تعليق، تعديل) المتاحة لإعلانات قيد المراجعة.
class PromotedAdReviewScreen extends StatelessWidget {
  const PromotedAdReviewScreen({super.key, required this.adId});

  final String adId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductReviewCubit>(
      create: (_) => sl<ProductReviewCubit>()..loadReviews(),
      child: _Body(adId: adId),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.adId});

  final String adId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    return BlocBuilder<ProductReviewCubit, ProductReviewState>(
      // بعد أول تحميل لا نعيد بناء الشاشة حتى لا تضيع حالة التعديل.
      buildWhen: (previous, current) => previous is! ProductReviewLoaded,
      builder: (context, state) {
        if (state is ProductReviewLoaded) {
          ProductReview? product;
          for (final review in state.reviews) {
            if (review.id == adId) product = review;
          }
          if (product == null) {
            return _Message(
              isArabic ? 'الإعلان غير موجود' : 'Ad not found',
            );
          }
          final cubit = context.read<ProductReviewCubit>();
          return ProductReviewDetailsScreen(
            product: product,
            isArabic: isArabic,
            loadFullDetails: () => cubit.loadDetails(adId),
            onSubmit: (edited, status) =>
                _submit(context, cubit, edited, status, l10n),
          );
        }
        if (state is ProductReviewError) {
          return _Message(l10n.productReviewLoadError);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<void> _submit(
    BuildContext context,
    ProductReviewCubit cubit,
    ProductReview product,
    ProductReviewStatus status,
    AppLocalizations l10n,
  ) async {
    final navigator = Navigator.of(context);
    final decision = await ProductReviewDialogs.requestDecision(
      context,
      product: product,
      status: status,
    );
    if (decision == null || !context.mounted) return;

    final saved = await cubit.updateDetails(product);
    if (!saved || !context.mounted) {
      if (context.mounted) {
        AppSnackBar.showError(context, l10n.productReviewUpdateError);
      }
      return;
    }
    final updated = await cubit.updateStatus(
      id: product.id,
      status: decision.status,
      decisionNote: decision.note,
      merchantNotificationRequested: decision.notifyMerchant,
    );
    if (!context.mounted) return;
    if (!updated) {
      AppSnackBar.showError(context, l10n.productReviewUpdateError);
      return;
    }
    AppSnackBar.showSuccess(context, l10n.productReviewActionSuccess);
    navigator.pop();
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
