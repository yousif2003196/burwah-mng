import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_operations_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_intervention_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_request_review_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/common/boss_state_views.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_provider_escalations_panel.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_service_escalations_panel.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_used_complaint_escalations_panel.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/requests/boss_operation_card.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/requests/boss_requests_governance_footer.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/requests/boss_requests_toolbar.dart';

/// تبويب "كل الطلبات": العمليات الحرجة والنزاعات من
/// `GET api/BossOfSupervisor/orders-and-disputes`.
class HeadSupervisorRequestsScreen extends StatelessWidget {
  const HeadSupervisorRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BossOperationsCubit>()..load(),
      child: const _RequestsView(),
    );
  }
}

class _RequestsView extends StatefulWidget {
  const _RequestsView();

  @override
  State<_RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<_RequestsView> {
  final _search = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) context.read<BossOperationsCubit>().search(value);
    });
  }

  Future<void> _open(BossOperation operation, {required bool intervene}) async {
    final cubit = context.read<BossOperationsCubit>();
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: intervene
              ? HeadSupervisorInterventionScreen(operation: operation)
              : HeadSupervisorRequestReviewScreen(operation: operation),
        ),
      ),
    );
    if (!mounted || message == null) return;
    showBossMessage(
      context,
      message,
      headSupervisorText(context,
          arabic: 'تم إرسال القرار بنجاح.', english: 'Decision sent.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BossOperationsCubit, BossOperationsState>(
      builder: (context, state) {
        final cubit = context.read<BossOperationsCubit>();
        final page = state.page;
        return ColoredBox(
          color: AppColors.background,
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ScrollFx(
                  child: BossRequestsSearchBar(
                    controller: _search,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 10),
                ScrollFx(
                  child: BossRequestsFilterBar(
                    selected: state.filter,
                    selectedCount: page is BossLoaded<BossOperationsPage>
                        ? page.data.operations.length
                        : null,
                    onChanged: cubit.changeFilter,
                  ),
                ),
                const SizedBox(height: 12),
                if (page is BossLoaded<BossOperationsPage>) ...[
                  ScrollFx(
                    child: BossRequestsSummary(
                        count: page.data.totalOperations),
                  ),
                  const SizedBox(height: 12),
                ],
                if (AuthSession.isSignedIn) ...[
                  const HeadServiceEscalationsPanel(),
                  const SizedBox(height: 12),
                  const HeadProviderEscalationsPanel(),
                  const SizedBox(height: 12),
                  const HeadUsedComplaintEscalationsPanel(),
                  const SizedBox(height: 12),
                ],
                ..._buildOperations(page, cubit),
                const ScrollFx(child: BossRequestsGovernanceFooter()),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildOperations(
    BossLoadState<BossOperationsPage> page,
    BossOperationsCubit cubit,
  ) {
    return switch (page) {
      BossLoading() => const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: BossLoadingView(),
          ),
        ],
      BossLoadFailure(:final message) => [
          BossErrorView(message: message, onRetry: cubit.load),
        ],
      BossLoaded(:final data) when data.operations.isEmpty => [
          BossEmptyView(
            message: headSupervisorText(context,
                arabic: 'لا توجد عمليات حرجة أو نزاعات بانتظار القرار',
                english: 'No critical operations or disputes awaiting a decision'),
          ),
        ],
      BossLoaded(:final data) => [
          for (final operation in data.operations) ...[
            BossOperationCard(
              operation: operation,
              onReview: () => _open(operation, intervene: false),
              onIntervene: () => _open(operation, intervene: true),
            ),
            const SizedBox(height: 12),
          ],
        ],
    };
  }
}
