import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_conversation_screen.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/products/presentation/widgets/product_head_escalation.dart' show askProductEscalationReason;
import 'package:barwah_app/features/services_supervisor/data/datasources/services_activity_log.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_escalation_store.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _ComplaintStatus { investigating, waiting, closed }

class _ServiceComplaint {
  final String id;
  _ComplaintStatus status;
  final String priority;
  final String age;
  final String client;
  final String provider;
  final String service;
  final String description;
  final String location;
  final String price;
  final String clientPhone;
  final String providerPhone;
  final List<String> photoUrls;
  String action;
  bool escalated = false;

  _ServiceComplaint({
    required this.id,
    required this.status,
    required this.priority,
    required this.age,
    required this.client,
    required this.provider,
    required this.service,
    required this.description,
    required this.location,
    required this.price,
    required this.clientPhone,
    required this.providerPhone,
    required this.photoUrls,
    required this.action,
  });
}

class ServicesComplaintsScreen extends StatefulWidget {
  const ServicesComplaintsScreen({super.key});

  @override
  State<ServicesComplaintsScreen> createState() =>
      _ServicesComplaintsScreenState();
}

class _ServicesComplaintsScreenState extends State<ServicesComplaintsScreen> {
  static const _storageKey = 'services_supervisor_complaint_actions_v1';
  final _searchController = TextEditingController();
  int _selectedFilter = 0;
  Map<String, dynamic> _savedActions = const {};
  bool _isLoadingActions = true;
  Map<String, ServicesEscalation> _escalations = const {};
  Map<String, DateTime> _firstSeen = const {};
  final _escalationStore = ServicesEscalationStore();

  ServicesEscalation? _escalationOf(_ServiceComplaint c) =>
      _escalations[ServicesEscalation.keyOf(ServicesEscalationKind.complaint, c.id)];

  /// 24h without action for open cases, 48h once with the head.
  bool _isOverdue(_ServiceComplaint c) {
    final escalation = _escalationOf(c);
    final now = DateTime.now();
    if (escalation != null) return escalation.isOverdue(now);
    if (c.status == _ComplaintStatus.closed ||
        c.status == _ComplaintStatus.waiting) {
      return false;
    }
    final seen = _firstSeen[c.id];
    return seen != null && now.difference(seen) > const Duration(hours: 24);
  }

  Future<void> _loadEscalations() async {
    try {
      final escalations = await _escalationStore.refresh();
      final firstSeen =
          await _escalationStore.firstSeen(_complaints.map((c) => c.id));
      if (!mounted) return;
      setState(() {
        _escalations = escalations;
        _firstSeen = firstSeen;
      });
    } on Object catch (error) {
      debugPrint('Services escalations unavailable: $error');
    }
  }

  late final List<_ServiceComplaint> _complaints = _createComplaints();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedActions());
    LocalEventStore.revision.addListener(_loadEscalations);
    ServicesEscalationStore.revision.addListener(_loadEscalations);
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_loadEscalations);
    ServicesEscalationStore.revision.removeListener(_loadEscalations);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(_storageKey);
      if (encoded != null) {
        _savedActions = jsonDecode(encoded) as Map<String, dynamic>;
        for (final complaint in _complaints) {
          final saved = _savedActions[complaint.id];
          if (saved is! Map<String, dynamic>) continue;
          complaint.status = _ComplaintStatus.values.byName(
            saved['status'] as String? ?? complaint.status.name,
          );
          complaint.escalated = saved['escalated'] as bool? ?? false;
          complaint.action = saved['action'] as String? ?? complaint.action;
        }
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'services complaints',
        context: ErrorDescription('while loading complaint actions'),
      ));
    } finally {
      if (mounted) setState(() => _isLoadingActions = false);
      await _loadEscalations();
    }
  }

  Future<void> _saveComplaintActions() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(
      _storageKey,
      jsonEncode({
        for (final complaint in _complaints)
          complaint.id: {
            'status': complaint.status.name,
            'escalated': complaint.escalated,
            'action': complaint.action,
          },
      }),
    );
    if (!saved) throw StateError('Could not save complaint actions.');
  }

  List<_ServiceComplaint> _createComplaints() {
    final l10n = AppLocalizations.of(context)!;
    return [
      _ServiceComplaint(
        id: 'CMP-3091',
        status: _ComplaintStatus.investigating,
        priority: l10n.servicesComplaintUrgent,
        age: l10n.servicesComplaintAgeMinutes(45),
        client: l10n.servicesComplaintClientOne,
        provider: l10n.servicesComplaintProviderOne,
        service: l10n.servicesComplaintSubjectOne,
        description: l10n.servicesComplaintDescriptionOne,
        location: l10n.servicesComplaintLocationOne,
        price: l10n.servicesComplaintPriceOne,
        clientPhone: '+966500003091',
        providerPhone: '+966500003191',
        photoUrls: const [],
        action: l10n.servicesComplaintContactParties,
      ),
      _ServiceComplaint(
        id: 'CMP-3038',
        status: _ComplaintStatus.waiting,
        priority: l10n.servicesComplaintPriorityMedium,
        age: l10n.servicesComplaintAgeHours(2),
        client: l10n.servicesComplaintClientTwo,
        provider: l10n.servicesComplaintProviderTwo,
        service: l10n.servicesComplaintSubjectTwo,
        description: l10n.servicesComplaintDescriptionTwo,
        location: l10n.servicesComplaintLocationTwo,
        price: l10n.servicesComplaintPriceTwo,
        clientPhone: '+966500003038',
        providerPhone: '+966500003138',
        photoUrls: const [],
        action: l10n.servicesComplaintReassign,
      ),
      _ServiceComplaint(
        id: 'CMP-3012',
        status: _ComplaintStatus.closed,
        priority: l10n.servicesComplaintClosed,
        age: l10n.servicesComplaintClosedToday,
        client: l10n.servicesComplaintClientThree,
        provider: l10n.servicesComplaintProviderThree,
        service: l10n.servicesComplaintSubjectThree,
        description: l10n.servicesComplaintDescriptionThree,
        location: l10n.servicesComplaintLocationThree,
        price: l10n.servicesComplaintPriceThree,
        clientPhone: '+966500003012',
        providerPhone: '+966500003112',
        photoUrls: const [],
        action: l10n.servicesComplaintShowResolution,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final complaints = _filteredComplaints();

    if (_isLoadingActions) {
      return const Center(child: CircularProgressIndicator());
    }
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        children: [
          Text(
            l10n.servicesComplaintsTitle,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.servicesComplaintsSubtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          ScrollFx(child: _buildMetrics(l10n)),
          const SizedBox(height: 12),
          ScrollFx(child: _buildSearch(l10n)),
          const SizedBox(height: 8),
          ScrollFx(child: _buildFilters(l10n)),
          const SizedBox(height: 10),
          if (complaints.isEmpty)
            _buildEmptyState(l10n)
          else
            for (final complaint in complaints) ...[
              _ComplaintCard(
                complaint: complaint,
                onOpen: () => _showDetails(complaint, l10n),
                onAction: () => _handleAction(complaint, l10n),
                onEscalate: () => _escalate(complaint, l10n),
                escalation: _escalationOf(complaint),
                overdue: _isOverdue(complaint),
              ),
              const SizedBox(height: 12),
            ],
          ScrollFx(child: _buildResolutionBanner(l10n)),
        ],
      ),
    );
  }

  List<_ServiceComplaint> _filteredComplaints() {
    final query = _searchController.text.trim().toLowerCase();
    return _complaints.where((complaint) {
      final matchesFilter = switch (_selectedFilter) {
        1 => complaint.status == _ComplaintStatus.investigating,
        2 => complaint.status == _ComplaintStatus.waiting,
        3 => complaint.status == _ComplaintStatus.closed,
        4 => _escalationOf(complaint) != null &&
            _escalationOf(complaint)!.status != ServicesEscalationStatus.decided,
        5 => _isOverdue(complaint),
        _ => true,
      };
      final text = [
        complaint.id,
        complaint.client,
        complaint.provider,
        complaint.service,
      ].join(' ').toLowerCase();
      return matchesFilter && (query.isEmpty || text.contains(query));
    }).toList();
  }

  Widget _buildMetrics(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.report_gmailerrorred_outlined,
            label: l10n.servicesComplaintActive,
            value: '${_complaints.where((complaint) => complaint.status != _ComplaintStatus.closed).length}',
            detail: l10n.servicesComplaintUrgent,
            color: AppColors.danger,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            icon: Icons.access_time,
            label: l10n.servicesComplaintResolutionTime,
            value: '18',
            detail: l10n.servicesComplaintMinutes,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            icon: Icons.handshake_outlined,
            label: l10n.servicesComplaintSatisfaction,
            value: '96.5%',
            detail: l10n.servicesComplaintApproved,
          ),
        ),
      ],
    );
  }

  Widget _buildSearch(AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: l10n.servicesComplaintSearchHint,
        prefixIcon: const MotionIcon(Icons.search),
        suffixIcon: const MotionIcon(Icons.tune),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    final labels = [
      l10n.servicesComplaintFilterAll,
      l10n.servicesComplaintFilterInvestigating,
      l10n.servicesComplaintFilterWaiting,
      l10n.servicesComplaintFilterClosed,
      l10n.localeName.startsWith('ar') ? 'عند الرئيس' : 'With head',
      l10n.localeName.startsWith('ar') ? 'متأخرة' : 'Overdue',
    ];
    final counts = [
      _complaints.length,
      _complaints.where((item) => item.status == _ComplaintStatus.investigating).length,
      _complaints.where((item) => item.status == _ComplaintStatus.waiting).length,
      _complaints.where((item) => item.status == _ComplaintStatus.closed).length,
      _complaints.where((item) => _escalationOf(item) != null && _escalationOf(item)!.status != ServicesEscalationStatus.decided).length,
      _complaints.where(_isOverdue).length,
    ].map((count) => '$count').toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 7),
              child: ChoiceChip(
                selected: _selectedFilter == index,
                onSelected: (_) => setState(() => _selectedFilter = index),
                showCheckmark: false,
                selectedColor: AppColors.primaryDark,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: _selectedFilter == index
                      ? AppColors.ink
                      : AppColors.cardBorder,
                ),
                labelStyle: TextStyle(
                  color: _selectedFilter == index
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(labels[index]),
                    const SizedBox(width: 5),
                    CountText(counts[index]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          MotionIcon(Icons.search_off, color: AppColors.textMuted, size: 32),
          const SizedBox(height: 8),
          Text(
            l10n.servicesComplaintNoResults,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionBanner(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const MotionIcon(Icons.shield_outlined, color: Colors.white, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.servicesComplaintResolutionTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.servicesComplaintResolutionDescription,
                  style: TextStyle(
                    color: AppColors.cardBorder,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetails(
    _ServiceComplaint complaint,
    AppLocalizations l10n,
  ) async {
    final isArabic = l10n.localeName.startsWith('ar');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: _ServiceComplaintDetailsSheet(
          complaint: complaint,
          l10n: l10n,
          isArabic: isArabic,
          onCall: (phone) => _callParty(phone, l10n),
          onChat: (name) => _openPartyChat(name),
          onResolve: () => _resolveComplaint(complaint, l10n),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    _ServiceComplaint complaint,
    AppLocalizations l10n,
  ) async {
    if (complaint.status == _ComplaintStatus.closed) {
      await _showDetails(complaint, l10n);
      return;
    }
    if (complaint.status == _ComplaintStatus.investigating) {
      _openPartiesConversation(complaint, l10n);
      return;
    }
    await _confirmAction(complaint, l10n.servicesComplaintReassign, l10n);
  }

  Future<void> _confirmAction(
    _ServiceComplaint complaint,
    String title,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(l10n.servicesComplaintActionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.logoutCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.productConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final previousStatus = complaint.status;
      final previousAction = complaint.action;
      setState(() {
        complaint.status = _ComplaintStatus.investigating;
        complaint.action = l10n.servicesComplaintContactParties;
      });
      final saved = await _persistComplaintActions(l10n);
      if (!saved) {
        if (mounted) {
          setState(() {
            complaint.status = previousStatus;
            complaint.action = previousAction;
          });
        }
        return;
      }
      _showMessage(l10n.servicesComplaintActionRecorded);
    }
  }

  Future<void> _resolveComplaint(
    _ServiceComplaint complaint,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.servicesComplaintInvestigateAndResolve),
        content: Text(l10n.servicesComplaintActionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.logoutCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.productConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final previousStatus = complaint.status;
    final previousAction = complaint.action;
    setState(() {
      complaint.status = _ComplaintStatus.closed;
      complaint.action = l10n.servicesComplaintShowResolution;
    });
    final saved = await _persistComplaintActions(l10n);
    if (!saved) {
      if (mounted) {
        setState(() {
          complaint.status = previousStatus;
          complaint.action = previousAction;
        });
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
      _showMessage(l10n.servicesComplaintActionRecorded);
    }
  }

  Future<bool> _persistComplaintActions(AppLocalizations l10n) async {
    try {
      await _saveComplaintActions();
      return true;
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'services complaints',
        context: ErrorDescription('while saving a complaint action'),
      ));
      if (mounted) _showMessage(l10n.servicesAccountSaveError('$error'));
      return false;
    }
  }

  Future<void> _escalate(
    _ServiceComplaint complaint,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServicesComplaintEscalationSheet(
        complaint: complaint,
        l10n: l10n,
      ),
    );
    if (confirmed != true || !mounted) return;
    final reason = await askProductEscalationReason(
      context,
      isArabic: l10n.localeName.startsWith('ar'),
    );
    if (reason == null || !mounted) return;
    try {
      await _escalationStore.escalate(
        kind: ServicesEscalationKind.complaint,
        refId: complaint.id,
        title: complaint.service,
        subject: complaint.description,
        reason: reason,
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'services complaints',
        context: ErrorDescription('while escalating to the head supervisor'),
      ));
      _showMessage(l10n.localeName.startsWith('ar')
          ? 'تعذر رفع الشكوى لرئيس المشرفين'
          : 'Could not escalate to the head supervisor');
      return;
    }
    final previousEscalated = complaint.escalated;
    setState(() => complaint.escalated = true);
    final saved = await _persistComplaintActions(l10n);
    if (!saved && mounted) {
      setState(() => complaint.escalated = previousEscalated);
    }
    await ServicesActivityLog().tryRecord(
      action: 'complaint_escalated',
      subject: complaint.id,
      details: reason,
    );
    await _loadEscalations();
    _showMessage(l10n.servicesComplaintEscalatedNotice(complaint.id));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _callParty(String phone, AppLocalizations l10n) async {
    final opened = await launchUrl(
      Uri(scheme: 'tel', path: phone.replaceAll(' ', '')),
    );
    if (!opened && mounted) _showMessage(l10n.servicesContactUnavailable);
  }

  void _openPartyChat(String name) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MerchantConversationScreen(conversationTitle: name),
      ),
    );
  }

  void _openPartiesConversation(
    _ServiceComplaint complaint,
    AppLocalizations l10n,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MerchantConversationScreen(
          conversationTitle: l10n.servicesComplaintGroupChatTitle(complaint.id),
          conversationParticipants: [complaint.client, complaint.provider],
        ),
      ),
    );
  }
}

class _ServicesComplaintEscalationSheet extends StatelessWidget {
  final _ServiceComplaint complaint;
  final AppLocalizations l10n;

  const _ServicesComplaintEscalationSheet({
    required this.complaint,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: AppColors.surfaceLight,
                          child: MotionIcon(
                            Icons.forward_to_inbox_outlined,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.servicesComplaintEscalate,
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${l10n.servicesComplaintDetails} · ${complaint.id}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.logoutCancel,
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const MotionIcon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                  children: [
                    ScrollFx(child: _EscalationInfoCard(
                      title: complaint.service,
                      content: complaint.description,
                      icon: Icons.home_repair_service_outlined,
                    )),
                    const SizedBox(height: 10),
                    ScrollFx(child: _EscalationInfoCard(
                      title: l10n.servicesComplaintPartiesTitle,
                      content:
                          '${l10n.servicesComplaintClient}: ${complaint.client}\n${l10n.servicesComplaintProvider}: ${complaint.provider}',
                      icon: Icons.people_outline,
                    )),
                    const SizedBox(height: 10),
                    ScrollFx(child: _EscalationInfoCard(
                      title: l10n.servicesComplaintPriceLabel,
                      content:
                          '${complaint.price} ${l10n.servicesCurrency}\n${l10n.servicesRequestLocationLabel}: ${complaint.location}',
                      icon: Icons.payments_outlined,
                    )),
                    const SizedBox(height: 10),
                    ScrollFx(child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppColors.blueFill,
                        border: AppColors.blueEdge,
                        boxShadow: AppColors.blueGlow,
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        l10n.servicesComplaintEscalationConfirmation,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const MotionIcon(Icons.verified_user_outlined),
                      label: Text(l10n.productConfirmAction),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        l10n.logoutCancel,
                        style: TextStyle(color: AppColors.textSecondary),
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

class _EscalationInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _EscalationInfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MotionIcon(icon, color: AppColors.infoDark, size: 19),
            const SizedBox(width: 9),
            Expanded(
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
                  const SizedBox(height: 5),
                  Text(
                    content,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ServiceComplaintDetailsSheet extends StatelessWidget {
  final _ServiceComplaint complaint;
  final AppLocalizations l10n;
  final bool isArabic;
  final ValueChanged<String> onCall;
  final ValueChanged<String> onChat;
  final VoidCallback onResolve;

  const _ServiceComplaintDetailsSheet({
    required this.complaint,
    required this.l10n,
    required this.isArabic,
    required this.onCall,
    required this.onChat,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${l10n.servicesComplaintDetails} · ${complaint.id}',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.service,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                children: [
                  ScrollFx(child: _ComplaintDetailSection(
                    title: l10n.servicesComplaintPartiesTitle,
                    child: Column(
                      children: [
                        _ComplaintPartyRow(
                          label: l10n.servicesComplaintClient,
                          name: complaint.client,
                          phone: complaint.clientPhone,
                          onCall: () => onCall(complaint.clientPhone),
                          onChat: () => onChat(complaint.client),
                          l10n: l10n,
                        ),
                        const Divider(height: 20),
                        _ComplaintPartyRow(
                          label: l10n.servicesComplaintProvider,
                          name: complaint.provider,
                          phone: complaint.providerPhone,
                          onCall: () => onCall(complaint.providerPhone),
                          onChat: () => onChat(complaint.provider),
                          l10n: l10n,
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 10),
                  ScrollFx(child: _ComplaintDetailSection(
                    title: l10n.servicesComplaintProblemTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          complaint.description,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ComplaintDetailValue(
                          label: l10n.servicesComplaintFiledBy,
                          value: complaint.client,
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 10),
                  ScrollFx(child: _ComplaintDetailSection(
                    title: l10n.servicesComplaintServiceInfoTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ComplaintDetailValue(
                          label: l10n.servicesComplaintPriceLabel,
                          value: '${complaint.price} ${l10n.servicesCurrency}',
                        ),
                        const SizedBox(height: 9),
                        _ComplaintDetailValue(
                          label: l10n.servicesRequestLocationLabel,
                          value: complaint.location,
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 10),
                  ScrollFx(child: _ComplaintDetailSection(
                    title: l10n.servicesComplaintPhotosTitle,
                    child: complaint.photoUrls.isEmpty
                        ? Text(
                            l10n.servicesComplaintNoPhotos,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          )
                        : SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: complaint.photoUrls.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) => ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  complaint.photoUrls[index],
                                  width: 145,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 145,
                                    height: 120,
                                    color: AppColors.surfaceLight,
                                    alignment: Alignment.center,
                                    child: MotionIcon(
                                      Icons.broken_image_outlined,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  )),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (complaint.status != _ComplaintStatus.closed) ...[
                        SizedBox(
                          height: 46,
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: onResolve,
                            icon: const MotionIcon(Icons.task_alt_outlined),
                            label: Text(l10n.servicesComplaintInvestigateAndResolve),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      SizedBox(
                        height: 46,
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const MotionIcon(Icons.close),
                          label: Text(l10n.logoutCancel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintDetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ComplaintDetailSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
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

class _ComplaintDetailValue extends StatelessWidget {
  final String label;
  final String value;

  const _ComplaintDetailValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          CountText(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
}

class _ComplaintPartyRow extends StatelessWidget {
  final String label;
  final String name;
  final String phone;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final AppLocalizations l10n;

  const _ComplaintPartyRow({
    required this.label,
    required this.name,
    required this.phone,
    required this.onCall,
    required this.onChat,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceLight,
            child: MotionIcon(
              Icons.person_outline,
              size: 19,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
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
                const SizedBox(height: 3),
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  phone,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.servicesCallPhone,
            onPressed: onCall,
            icon: const MotionIcon(Icons.call_outlined),
          ),
          IconButton(
            tooltip: l10n.servicesProviderProfileChat,
            onPressed: onChat,
            icon: const MotionIcon(Icons.chat_outlined),
          ),
        ],
      );
}

class _ComplaintCard extends StatelessWidget {
  final _ServiceComplaint complaint;
  final VoidCallback onOpen;
  final VoidCallback onAction;
  final VoidCallback onEscalate;
  final ServicesEscalation? escalation;
  final bool overdue;

  const _ComplaintCard({
    required this.complaint,
    required this.onOpen,
    required this.onAction,
    required this.onEscalate,
    this.escalation,
    this.overdue = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isClosed = complaint.status == _ComplaintStatus.closed;
    final isWaiting = complaint.status == _ComplaintStatus.waiting;
    final statusLabel = isClosed
        ? l10n.servicesComplaintClosed
        : isWaiting
            ? l10n.servicesComplaintWaitingProvider
            : l10n.servicesComplaintUnderReview;
    final statusColor = isClosed
        ? AppColors.success
        : isWaiting
            ? AppColors.info
            : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isClosed
                      ? AppColors.successBorder
                      : AppColors.dangerBorder,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: MotionIcon(
                  isClosed
                      ? Icons.check_circle
                      : isWaiting
                          ? Icons.cloud_upload_outlined
                          : Icons.priority_high,
                  color: isClosed ? AppColors.success : AppColors.danger,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '#${complaint.id}',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (overdue) ...[
                _Badge(
                  label: l10n.localeName.startsWith('ar') ? 'متأخرة' : 'Overdue',
                  color: AppColors.danger,
                ),
                const SizedBox(width: 5),
              ],
              _Badge(
                label: escalation != null
                    ? escalation!.status.labelAr
                    : complaint.escalated
                        ? l10n.servicesComplaintEscalated
                        : complaint.priority,
                color: complaint.escalated || escalation != null
                    ? AppColors.danger
                    : AppColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Flexible(child: _Badge(label: statusLabel, color: statusColor)),
              const SizedBox(width: 7),
              MotionIcon(Icons.access_time,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  complaint.age,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _PartiesPanel(complaint: complaint, l10n: l10n),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: Text(
                  complaint.service,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              MotionIcon(Icons.home_repair_service_outlined,
                  color: AppColors.info, size: 19),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            complaint.description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          if (isClosed) ...[
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.servicesComplaintResolutionRecorded,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onOpen,
              icon: const MotionIcon(Icons.lock_outline, size: 15),
              label: Text(l10n.servicesComplaintClosedAudit),
            ),
          ] else ...[
            SizedBox(
              height: 44,
              child: FilledButton.icon(
                onPressed: onOpen,
                icon: const MotionIcon(Icons.manage_search, size: 18),
                label: Text(
                  l10n.servicesComplaintInvestigateAndResolve,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: isWaiting
                        ? Icons.swap_horiz
                        : Icons.contact_support_outlined,
                    label: complaint.action,
                    onPressed: onAction,
                  ),
                ),
                if (!isWaiting &&
                    (escalation == null || escalation!.canEscalateAgain)) ...[
                  const SizedBox(width: 7),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.north_east,
                      label: l10n.servicesComplaintEscalate,
                      onPressed: onEscalate,
                      danger: true,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PartiesPanel extends StatelessWidget {
  final _ServiceComplaint complaint;
  final AppLocalizations l10n;

  const _PartiesPanel({required this.complaint, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PartyInfo(
              icon: Icons.person_outline,
              label: l10n.servicesComplaintClient,
              name: complaint.client,
              detail: l10n.servicesComplaintRiyadh,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _PartyInfo(
              icon: Icons.storefront_outlined,
              label: l10n.servicesComplaintProvider,
              name: complaint.provider,
              detail: l10n.servicesComplaintProviderId(complaint.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;
  final String detail;

  const _PartyInfo({
    required this.icon,
    required this.label,
    required this.name,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MotionIcon(icon, color: AppColors.info, size: 15),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 8)),
              const SizedBox(height: 3),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color? _color;
  Color get color => _color ?? AppColors.primaryDark;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    Color? color,
  }) : _color = color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(9),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MotionIcon(icon, color: color, size: 14),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CountText(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 7),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool danger;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = danger ? AppColors.danger : AppColors.primaryDark;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: AppColors.surfaceLight,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        textStyle: const TextStyle(fontSize: 9),
      ),
      child: Row(
        children: [
          MotionIcon(icon, size: 15),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.cardBorder),
  );
}
