import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/merchant_complaints_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_complaint_details_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/common/boss_state_views.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_common.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_filters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/merchant_complaint_card.dart';

/// تبويب "الشكاوى": تظلمات التجار ضد المشرفين من
/// `GET api/BossOfSupervisor/merchant-complaints`.
class HeadSupervisorComplaintsScreen extends StatelessWidget {
  const HeadSupervisorComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MerchantComplaintsCubit>()..load(),
      child: const _ComplaintsView(),
    );
  }
}

class _ComplaintsView extends StatefulWidget {
  const _ComplaintsView();

  @override
  State<_ComplaintsView> createState() => _ComplaintsViewState();
}

class _ComplaintsViewState extends State<_ComplaintsView> {
  final _search = TextEditingController();
  ComplaintsTab _tab = ComplaintsTab.underReview;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text.trim()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static bool _inTab(MerchantComplaintSummary complaint, ComplaintsTab tab) =>
      switch (tab) {
        ComplaintsTab.underReview => !complaint.status.isFinal,
        ComplaintsTab.archive => complaint.status.isFinal,
      };

  bool _matchesQuery(MerchantComplaintSummary complaint) {
    if (_query.isEmpty) return true;
    final searchable =
        '${complaint.code} ${complaint.title} ${complaint.complainant}'
            .toLowerCase();
    return searchable.contains(_query.toLowerCase());
  }

  Future<void> _open(MerchantComplaintSummary complaint) async {
    final cubit = context.read<MerchantComplaintsCubit>();
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => HeadSupervisorComplaintDetailsScreen(summary: complaint),
      ),
    );
    if (!mounted || message == null) return;
    showBossMessage(
      context,
      message,
      headSupervisorText(context,
          arabic: 'تم تنفيذ الإجراء بنجاح.', english: 'Action completed.'),
    );
    await cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantComplaintsCubit, MerchantComplaintsState>(
      builder: (context, state) {
        final cubit = context.read<MerchantComplaintsCubit>();
        final all = state is BossLoaded<List<MerchantComplaintSummary>>
            ? state.data
            : const <MerchantComplaintSummary>[];
        final visible = all
            .where((complaint) => _inTab(complaint, _tab) && _matchesQuery(complaint))
            .toList();
        return ColoredBox(
          color: AppColors.scaffold,
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ScrollFx(child: ComplaintSearchField(controller: _search)),
                const SizedBox(height: 10),
                ScrollFx(
                  child: ComplaintFilters(
                    selected: _tab,
                    counts: {
                      for (final tab in ComplaintsTab.values)
                        tab: all.where((item) => _inTab(item, tab)).length,
                    },
                    onChanged: (tab) => setState(() => _tab = tab),
                  ),
                ),
                const SizedBox(height: 11),
                ...switch (state) {
                  BossLoading() => const [
                      Padding(
                        padding: EdgeInsets.all(28),
                        child: BossLoadingView(),
                      ),
                    ],
                  BossLoadFailure(:final message) => [
                      BossErrorView(message: message, onRetry: cubit.load),
                    ],
                  BossLoaded() when visible.isEmpty => [
                      BossEmptyView(
                        message: headSupervisorText(context,
                            arabic: 'لا توجد شكاوى ضمن هذا التصنيف',
                            english: 'No complaints in this category'),
                      ),
                    ],
                  BossLoaded() => [
                      for (final complaint in visible) ...[
                        MerchantComplaintCard(
                          complaint: complaint,
                          onTap: () => _open(complaint),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                },
                const ScrollFx(child: ComplaintGovernanceNote()),
              ],
            ),
          ),
        );
      },
    );
  }
}
