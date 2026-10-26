import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_conversation_screen.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_case_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_complaints_cubit.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class WasalnyComplaintsScreen extends StatefulWidget {
  /// One of: all, follow, head, overdue.
  final String initialFilter;

  const WasalnyComplaintsScreen({super.key, this.initialFilter = 'all'});

  @override
  State<WasalnyComplaintsScreen> createState() =>
      _WasalnyComplaintsScreenState();
}

class _WasalnyComplaintsScreenState extends State<WasalnyComplaintsScreen> {
  late String _filter = widget.initialFilter;

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    context.read<WasalnyComplaintsCubit>().syncDecisions();
  }

  bool _matches(WasalnyComplaint c, WasalnyComplaintsLoaded state) {
    final overdue = WasalnyCaseRecord.isOverdue(
        c.status, state.cases[c.id], DateTime.now());
    return switch (_filter) {
      'follow' => c.status == WasalnyComplaintStatus.underReview ||
          c.status == WasalnyComplaintStatus.returnedByHead,
      'head' => c.status == WasalnyComplaintStatus.escalatedToChief ||
          c.status == WasalnyComplaintStatus.escalatedToAdmin,
      'overdue' => overdue,
      _ => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(l10n.wasalnyAccountFollowComplaint),
        ),
        body: BlocBuilder<WasalnyComplaintsCubit, WasalnyComplaintsState>(
          builder: (context, state) {
            if (state is WasalnyComplaintsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WasalnyComplaintsLoadFailure) {
              return _LoadFailure(
                message: l10n.wasalnyComplaintsLoadError,
                onRetry: context.read<WasalnyComplaintsCubit>().loadComplaints,
              );
            }
            if (state is! WasalnyComplaintsLoaded) {
              return const SizedBox.shrink();
            }
            if (state.complaints.isEmpty) {
              return Center(child: Text(l10n.wasalnyRequestsEmpty));
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Text(
                  l10n.wasalnyComplaintsListIntro,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in [
                        ('all', isArabic ? 'الكل' : 'All'),
                        ('follow', isArabic ? 'تحتاج متابعة' : 'Needs follow-up'),
                        ('head', isArabic ? 'عند الرئيس' : 'With head'),
                        ('overdue', isArabic ? 'متأخرة' : 'Overdue'),
                      ])
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6),
                          child: ChoiceChip(
                            label: Text(f.$2),
                            selected: _filter == f.$1,
                            onSelected: (_) => setState(() => _filter = f.$1),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                for (final complaint
                    in state.complaints.where((c) => _matches(c, state)))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ComplaintListTile(
                      complaint: complaint,
                      isArabic: isArabic,
                      l10n: l10n,
                      overdue: WasalnyCaseRecord.isOverdue(
                          complaint.status,
                          state.cases[complaint.id],
                          DateTime.now()),
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider.value(
                            value: context.read<WasalnyComplaintsCubit>(),
                            child: _WasalnyComplaintDetailsScreen(
                              complaint: complaint,
                              isArabic: isArabic,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadFailure({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const MotionIcon(Icons.refresh),
                label:
                    Text(AppLocalizations.of(context)!.wasalnyComplaintsRetry),
              ),
            ],
          ),
        ),
      );
}

class _ComplaintListTile extends StatelessWidget {
  final WasalnyComplaint complaint;
  final bool isArabic;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final bool overdue;

  const _ComplaintListTile({
    required this.complaint,
    required this.isArabic,
    required this.l10n,
    required this.onTap,
    this.overdue = false,
  });

  @override
  Widget build(BuildContext context) {
    final buyerName = isArabic ? complaint.buyerNameAr : complaint.buyerNameEn;
    final sellerName =
        isArabic ? complaint.sellerNameAr : complaint.sellerNameEn;

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  MotionIcon(Icons.report_problem_outlined,
                      color: AppColors.warningDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.wasalnyComplaintReferenceWithId(complaint.id),
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (overdue) ...[
                    _OverdueBadge(isArabic: isArabic),
                    const SizedBox(width: 6),
                  ],
                  _ComplaintStatusBadge(status: complaint.status, l10n: l10n),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                isArabic ? complaint.titleAr : complaint.titleEn,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isArabic ? complaint.itemTitleAr : complaint.itemTitleEn,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (sellerName != null || buyerName != null) ...[
                const SizedBox(height: 7),
                Text(
                  '${sellerName ?? l10n.wasalnyComplaintPartyUnavailable}  •  ${buyerName ?? l10n.wasalnyComplaintPartyUnavailable}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isArabic ? complaint.timeAgoAr : complaint.timeAgoEn,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    l10n.wasalnyComplaintOpenDetails,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WasalnyComplaintDetailsScreen extends StatelessWidget {
  final WasalnyComplaint complaint;
  final bool isArabic;

  const _WasalnyComplaintDetailsScreen({
    required this.complaint,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(l10n.wasalnyComplaintDetailsTitle),
        ),
        body: BlocBuilder<WasalnyComplaintsCubit, WasalnyComplaintsState>(
          builder: (context, state) {
            final currentComplaint = state is WasalnyComplaintsLoaded
                ? List<WasalnyComplaint>.of(state.complaints).firstWhere(
                    (item) => item.id == complaint.id,
                    orElse: () => complaint,
                  )
                : complaint;
            return _buildDetails(
              context,
              currentComplaint,
              l10n,
              state is WasalnyComplaintsLoaded
                  ? state.cases[complaint.id]
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    WasalnyComplaint currentComplaint,
    AppLocalizations l10n,
    WasalnyCaseRecord? record,
  ) {
    final sellerName = isArabic
        ? currentComplaint.sellerNameAr
        : currentComplaint.sellerNameEn;
    final buyerName =
        isArabic ? currentComplaint.buyerNameAr : currentComplaint.buyerNameEn;
    final canAct =
        currentComplaint.status == WasalnyComplaintStatus.underReview ||
            currentComplaint.status == WasalnyComplaintStatus.returnedByHead;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        ScrollFx(child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.wasalnyComplaintReferenceWithId(currentComplaint.id),
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _ComplaintStatusBadge(
              status: currentComplaint.status,
              l10n: l10n,
            ),
          ],
        )),
        const SizedBox(height: 12),
        ScrollFx(child: _DetailsSection(
          title: l10n.wasalnyComplaintDetailsSection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isArabic ? currentComplaint.titleAr : currentComplaint.titleEn,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? currentComplaint.descriptionAr
                    : currentComplaint.descriptionEn,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              if (currentComplaint.actionNoteAr != null ||
                  currentComplaint.actionNoteEn != null) ...[
                const SizedBox(height: 10),
                Text(
                  isArabic
                      ? currentComplaint.actionNoteAr ?? ''
                      : currentComplaint.actionNoteEn ?? '',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        )),
        const SizedBox(height: 12),
        ScrollFx(child: _DetailsSection(
          title: l10n.wasalnyComplaintRequestSection,
          child: Column(
            children: [
              _DetailRow(
                label: l10n.wasalnyComplaintItem,
                value: isArabic
                    ? currentComplaint.itemTitleAr
                    : currentComplaint.itemTitleEn,
              ),
              if (currentComplaint.dealCode != null)
                _DetailRow(
                  label: l10n.wasalnyComplaintDealCode,
                  value: currentComplaint.dealCode!,
                ),
              if (currentComplaint.heldAmount != null)
                _DetailRow(
                  label: l10n.wasalnyComplaintAmount,
                  value: currentComplaint.heldAmount!,
                ),
              _DetailRow(
                label: l10n.wasalnyComplaintCreatedAt,
                value: isArabic
                    ? currentComplaint.timeAgoAr
                    : currentComplaint.timeAgoEn,
              ),
              if (currentComplaint.warrantyTextAr != null)
                _DetailRow(
                  label: l10n.wasalnyComplaintWarranty,
                  value: isArabic
                      ? currentComplaint.warrantyTextAr!
                      : currentComplaint.warrantyTextEn ?? '',
                ),
            ],
          ),
        )),
        const SizedBox(height: 12),
        ScrollFx(child: _DetailsSection(
          title: l10n.wasalnyComplaintPartiesSection,
          child: Column(
            children: [
              _PartyContact(
                label: l10n.wasalnyComplaintSeller,
                name: sellerName ?? l10n.wasalnyComplaintPartyUnavailable,
                phone: currentComplaint.sellerPhone,
                callLabel: l10n.wasalnyComplaintCallSeller,
                chatLabel: l10n.wasalnyComplaintChatParty,
                onChat: sellerName == null
                    ? null
                    : () => _openComplaintChat(
                          context,
                          currentComplaint,
                          sellerName,
                          buyerName,
                        ),
                onCall: sellerName == null
                    ? null
                    : () => _callParty(
                          context,
                          currentComplaint.sellerPhone,
                          l10n,
                        ),
              ),
              if (buyerName != null) ...[
                const Divider(height: 22),
                _PartyContact(
                  label: l10n.wasalnyComplaintBuyer,
                  name: buyerName,
                  phone: currentComplaint.buyerPhone,
                  callLabel: l10n.wasalnyComplaintCallBuyer,
                  chatLabel: l10n.wasalnyComplaintChatParty,
                  onChat: () => _openComplaintChat(
                    context,
                    currentComplaint,
                    sellerName ?? l10n.wasalnyComplaintPartyUnavailable,
                    buyerName,
                  ),
                  onCall: () => _callParty(
                    context,
                    currentComplaint.buyerPhone,
                    l10n,
                  ),
                ),
              ],
            ],
          ),
        )),
        if (record != null && record.timeline.isNotEmpty) ...[
          const SizedBox(height: 12),
          _DetailsSection(
            title: isArabic ? 'مسار الشكوى' : 'Complaint path',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isArabic
                      ? 'مشرف وصلني ← رئيس المشرفين ← الأدمن (بقرار الرئيس)'
                      : 'Wasalny supervisor → Head → Admin (head decision)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                for (final note in record.timeline.reversed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: MotionIcon(Icons.circle,
                              size: 8, color: AppColors.info),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(note.text,
                                  style: const TextStyle(fontSize: 12)),
                              Text(
                                _fmt(note.at),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (canAct) ...[
          FilledButton.icon(
            onPressed: () => _resolve(context, currentComplaint, l10n),
            icon: const MotionIcon(Icons.handshake_outlined),
            label: Text(l10n.wasalnyComplaintResolveFriendly),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.successDark,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 9),
          OutlinedButton.icon(
            onPressed: () => _escalate(context, currentComplaint, l10n),
            icon: const MotionIcon(Icons.forward_to_inbox_outlined),
            label: Text(l10n.wasalnyComplaintEscalateHead),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 9),
        ],
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const MotionIcon(Icons.arrow_back),
          label: Text(l10n.wasalnyComplaintBackToList),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  void _openComplaintChat(
    BuildContext context,
    WasalnyComplaint complaint,
    String sellerName,
    String? buyerName,
  ) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MerchantConversationScreen(
          conversationTitle: AppLocalizations.of(context)!
              .wasalnyComplaintReferenceWithId(complaint.id),
          conversationParticipants: [
            sellerName,
            if (buyerName != null) buyerName,
          ],
        ),
      ),
    );
  }

  Future<void> _resolve(
    BuildContext context,
    WasalnyComplaint complaint,
    AppLocalizations l10n,
  ) async {
    final resolved = await context.read<WasalnyComplaintsCubit>().resolve(
          id: complaint.id,
          note: l10n.wasalnyComplaintResolveNote,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resolved
            ? l10n.wasalnyComplaintResolvedMessage
            : l10n.wasalnyComplaintResolveFailed),
      ),
    );
  }

  Future<void> _escalate(
    BuildContext context,
    WasalnyComplaint complaint,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComplaintEscalationSheet(
        complaint: complaint,
        isArabic: isArabic,
        l10n: l10n,
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final reason = await _askEscalationReason(context);
    if (reason == null || !context.mounted) return;

    final escalated = await context.read<WasalnyComplaintsCubit>().escalate(
          id: complaint.id,
          reason: reason,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(escalated
            ? l10n.wasalnyComplaintEscalatedMessage
            : l10n.wasalnyComplaintEscalationFailed),
      ),
    );
  }

  Future<String?> _askEscalationReason(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: AlertDialog(
          title: Text(isArabic ? 'سبب التصعيد' : 'Escalation reason'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
            decoration: InputDecoration(
              hintText: isArabic
                  ? 'اكتب سبب التصعيد (5 أحرف على الأقل)'
                  : 'Write the reason (at least 5 characters)',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text =
                    controller.text.replaceAll(' — ', ' - ').trim();
                if (text.length < 5) return;
                Navigator.of(dialogContext).pop(text);
              },
              child: Text(isArabic ? 'تصعيد' : 'Escalate'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _callParty(
    BuildContext context,
    String phone,
    AppLocalizations l10n,
  ) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    var launched = false;
    try {
      launched = await launchUrl(uri);
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.wasalnyComplaintCallFailed)),
      );
    }
  }
}

class _ComplaintEscalationSheet extends StatelessWidget {
  final WasalnyComplaint complaint;
  final bool isArabic;
  final AppLocalizations l10n;

  const _ComplaintEscalationSheet({
    required this.complaint,
    required this.isArabic,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final sellerName =
        isArabic ? complaint.sellerNameAr : complaint.sellerNameEn;
    final buyerName = isArabic ? complaint.buyerNameAr : complaint.buyerNameEn;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.94;

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                color: AppColors.primaryDark,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.wasalnyComplaintEscalationSheetKicker,
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      l10n.wasalnyComplaintEscalationSheetType,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                color: AppColors.background,
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.infoBorder,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: AppColors.cardBorder,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: l10n.wasalnyComplaintBackToList,
                            onPressed: () => Navigator.of(context).pop(false),
                            icon: MotionIcon(
                              Icons.arrow_back,
                              size: 19,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.wasalnyComplaintEscalationSheetTitle,
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                l10n.wasalnyComplaintEscalationSheetSubtitle,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: AppColors.cardBorder,
                          child: MotionIcon(
                            Icons.person_outline,
                            size: 19,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ScrollFx(child: _EscalationSummaryCard(
                        complaint: complaint,
                        l10n: l10n,
                      )),
                      const SizedBox(height: 20),
                      ScrollFx(child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.blueFill,
                          border: AppColors.blueEdge,
                          boxShadow: AppColors.blueGlow,
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    l10n.wasalnyComplaintEscalationPolicyTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    l10n.wasalnyComplaintEscalationPolicyBody,
                                    style: TextStyle(
                                      color: AppColors.cardBorder,
                                      fontSize: 11,
                                      height: 1.7,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            MotionIcon(
                              Icons.shield_outlined,
                              color: AppColors.info,
                              size: 22,
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 22),
                      ScrollFx(child: _EscalationSectionTitle(
                        title: l10n.wasalnyComplaintPartiesSection,
                        subtitle: l10n.wasalnyComplaintEscalationAuditTrail,
                      )),
                      const SizedBox(height: 8),
                      ScrollFx(child: Row(
                        children: [
                          Expanded(
                            child: _EscalationPartyCard(
                              label: l10n.wasalnyComplaintBuyer,
                              name: buyerName ??
                                  l10n.wasalnyComplaintPartyUnavailable,
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _EscalationPartyCard(
                              label: l10n.wasalnyComplaintSeller,
                              name: sellerName ??
                                  l10n.wasalnyComplaintPartyUnavailable,
                              icon: Icons.storefront_outlined,
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 8),
                      ScrollFx(child: _EscalationEvidenceCard(
                        title: isArabic
                            ? complaint.itemTitleAr
                            : complaint.itemTitleEn,
                        description: isArabic
                            ? complaint.descriptionAr
                            : complaint.descriptionEn,
                        l10n: l10n,
                      )),
                      const SizedBox(height: 16),
                      ScrollFx(child: _EscalationSectionTitle(
                        title: l10n.wasalnyComplaintEscalationEvidenceTitle,
                        subtitle: l10n.wasalnyComplaintEscalationVerifiedLabel,
                      )),
                      const SizedBox(height: 8),
                      ScrollFx(child: _EscalationEvidenceCard(
                        title: l10n.wasalnyComplaintWarranty,
                        description: isArabic
                            ? complaint.warrantyTextAr ??
                                l10n.wasalnyComplaintEscalationNoWarranty
                            : complaint.warrantyTextEn ??
                                l10n.wasalnyComplaintEscalationNoWarranty,
                        l10n: l10n,
                        verified: true,
                      )),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(color: AppColors.surfaceHighlight),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const MotionIcon(Icons.verified_user_outlined),
                      label: Text(
                        l10n.wasalnyComplaintEscalationConfirm,
                        textAlign: TextAlign.center,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.dangerDark,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const MotionIcon(Icons.close, size: 17),
                      label: Text(l10n.wasalnyComplaintBackToList),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surfaceHighlight,
                        foregroundColor: AppColors.textSecondary,
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EscalationSummaryCard extends StatelessWidget {
  final WasalnyComplaint complaint;
  final AppLocalizations l10n;

  const _EscalationSummaryCard({
    required this.complaint,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.wasalnyComplaintEscalationFileLabel,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.warningBorder,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MotionIcon(
                        Icons.circle,
                        size: 7,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        l10n.wasalnyComplaintEscalationPending,
                        style: TextStyle(
                          color: AppColors.warningDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _EscalationValueCell(
                    label: l10n.wasalnyComplaintDealCode,
                    value: complaint.dealCode ?? complaint.id,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _EscalationValueCell(
                    label: l10n.wasalnyComplaintEscalationHeldAmount,
                    value: complaint.heldAmount ??
                        l10n.wasalnyComplaintEscalationNoHeldAmount,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _EscalationValueCell extends StatelessWidget {
  final String label;
  final String value;

  const _EscalationValueCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            CountText(
              value,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}

class _EscalationSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EscalationSectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      );
}

class _EscalationPartyCard extends StatelessWidget {
  final String label;
  final String name;
  final IconData icon;

  const _EscalationPartyCard({
    required this.label,
    required this.name,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 62),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                MotionIcon(icon, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}

class _EscalationEvidenceCard extends StatelessWidget {
  final String title;
  final String description;
  final AppLocalizations l10n;
  final bool verified;

  const _EscalationEvidenceCard({
    required this.title,
    required this.description,
    required this.l10n,
    this.verified = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: verified ? AppColors.infoBorder : AppColors.surfaceHighlight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (verified)
                  MotionIcon(
                    Icons.verified_outlined,
                    color: AppColors.info,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
}

class _ComplaintStatusBadge extends StatelessWidget {
  final WasalnyComplaintStatus status;
  final AppLocalizations l10n;

  const _ComplaintStatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WasalnyComplaintStatus.underReview => (
          l10n.wasalnyComplaintOpenStatus,
          AppColors.warningDark
        ),
      WasalnyComplaintStatus.escalatedToChief => (
          l10n.wasalnyComplaintEscalatedStatus,
          AppColors.info
        ),
      WasalnyComplaintStatus.actionTakenBlocked => (
          l10n.wasalnyComplaintActionTakenStatus,
          AppColors.danger
        ),
      WasalnyComplaintStatus.resolved => (
          l10n.wasalnyComplaintResolvedStatus,
          AppColors.successDark
        ),
      WasalnyComplaintStatus.returnedByHead => (
          l10n.localeName.startsWith('ar')
              ? 'أُعيدت من الرئيس'
              : 'Returned by head',
          AppColors.warningDark
        ),
      WasalnyComplaintStatus.escalatedToAdmin => (
          l10n.localeName.startsWith('ar')
              ? 'عند الأدمن (عبر الرئيس)'
              : 'With admin (via head)',
          AppColors.dangerDark
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: CountText(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}

class _PartyContact extends StatelessWidget {
  final String label;
  final String name;
  final String phone;
  final String callLabel;
  final VoidCallback? onCall;
  final String chatLabel;
  final VoidCallback? onChat;

  const _PartyContact({
    required this.label,
    required this.name,
    required this.phone,
    required this.callLabel,
    required this.onCall,
    required this.chatLabel,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.surfaceHighlight,
            child: MotionIcon(Icons.person_outline, color: AppColors.ink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (onCall != null)
                  Text(
                    phone,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (onChat != null)
            IconButton.filledTonal(
              tooltip: chatLabel,
              onPressed: onChat,
              icon: const MotionIcon(Icons.chat_bubble_outline),
            ),
          if (onCall != null)
            IconButton.filledTonal(
              tooltip: callLabel,
              onPressed: onCall,
              icon: const MotionIcon(Icons.call_outlined),
            ),
        ],
      );
}

class _OverdueBadge extends StatelessWidget {
  final bool isArabic;
  const _OverdueBadge({required this.isArabic});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.dangerDark.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isArabic ? 'متأخرة' : 'Overdue',
          style: TextStyle(
            color: AppColors.dangerDark,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

String _fmt(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}
