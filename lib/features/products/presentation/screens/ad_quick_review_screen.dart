import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/presentation/screens/ad_owner_chat_screen.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/presentation/controllers/ad_quick_review_cubit.dart';
import 'package:barwah_app/features/products/presentation/controllers/ad_quick_review_state.dart';

/// بتفتح من إشعار "إعلان جديد": تفاصيل الإعلان + شات صاحب الإعلان + القرار.
class AdQuickReviewScreen extends StatelessWidget {
  const AdQuickReviewScreen({super.key, required this.adId});

  final int adId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdQuickReviewCubit>()..load(adId),
      child: _AdQuickReviewView(adId: adId),
    );
  }
}

class _AdQuickReviewView extends StatelessWidget {
  const _AdQuickReviewView({required this.adId});

  final int adId;

  Future<void> _decide(
    BuildContext context,
    ProductReviewStatus status,
    String done, {
    String? note,
  }) async {
    final ok =
        await context.read<AdQuickReviewCubit>().decide(status, note: note);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تعذر تنفيذ القرار')));
    }
  }

  Future<void> _reject(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('سبب الرفض'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'اكتب السبب'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('رفض'),
            ),
          ],
        ),
      ),
    );
    if (reason == null || reason.isEmpty || !context.mounted) return;
    await _decide(
      context,
      ProductReviewStatus.rejected,
      'تم رفض الإعلان',
      note: reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: const Text('مراجعة الإعلان'),
        ),
        body: BlocBuilder<AdQuickReviewCubit, AdQuickReviewState>(
          builder: (context, state) {
            if (state is AdQuickReviewLoaded) {
              return _content(context, state.review, busy: state.busy);
            }
            if (state is AdQuickReviewLoadFailure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('تعذر تحميل الإعلان'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          context.read<AdQuickReviewCubit>().load(adId),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    ProductReview review, {
    required bool busy,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(review.titleAr,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text('السعر: ${review.priceAr}'),
        if (review.descriptionAr.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(review.descriptionAr),
        ],
        // المواصفات والكمية والموقع والبائع من تفاصيل الإعلان.
        for (final detail in review.details)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${detail.key}: ${detail.value}',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  AdOwnerChatScreen(adId: adId, adTitle: review.titleAr),
            ),
          ),
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('محادثة صاحب الإعلان'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => _decide(
                          context,
                          ProductReviewStatus.approved,
                          'تم قبول الإعلان ونشره',
                        ),
                child: const Text('قبول'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => _decide(
                          context,
                          ProductReviewStatus.hidden,
                          'تم إخفاء الإعلان',
                        ),
                child: const Text('إخفاء'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : () => _reject(context),
                child: const Text('رفض'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
