import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/products/presentation/widgets/product_head_escalation.dart' show askProductEscalationReason;
import 'package:barwah_app/features/services_supervisor/data/datasources/service_provider_catalog.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_activity_log.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_escalation_store.dart';
import 'package:barwah_app/features/services_supervisor/domain/entities/service_provider.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_request_details_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _ServiceCategory { maintenance, electrical, moving }

class _ServiceRequest {
  final String id;
  final String serviceAr;
  final String serviceEn;
  final String providerAr;
  final String providerEn;
  final String descriptionAr;
  final String descriptionEn;
  final String locationAr;
  final String locationEn;
  final String timeAr;
  final String timeEn;
  final String price;
  final String diagnosticFee;
  final String workFee;
  final String phone;
  final _ServiceCategory category;
  final IconData icon;
  final List<String> photoUrls;
  final bool urgent;
  final bool featured;

  const _ServiceRequest({
    required this.id,
    required this.serviceAr,
    required this.serviceEn,
    required this.providerAr,
    required this.providerEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.locationAr,
    required this.locationEn,
    required this.timeAr,
    required this.timeEn,
    required this.price,
    required this.diagnosticFee,
    required this.workFee,
    required this.phone,
    required this.category,
    required this.icon,
    this.photoUrls = const [],
    this.urgent = false,
    this.featured = false,
  });
}

const _serviceRequests = <_ServiceRequest>[
  _ServiceRequest(
    id: 'SRV-3042',
    serviceAr: 'صيانة مكيفات وتبريد',
    serviceEn: 'Air conditioning and cooling repair',
    providerAr: 'عبد العزيز بن فهد الحارثي',
    providerEn: 'Abdulaziz Fahad Al-Harthi',
    descriptionAr: 'فحص وصيانة مكيف سبليت وتنظيف الفلاتر مع ضمان على العمل.',
    descriptionEn:
        'Inspect and service a split AC unit, clean the filters, and include a workmanship warranty.',
    locationAr: 'حي النرجس، الرياض',
    locationEn: 'Al Narjis, Riyadh',
    timeAr: 'اليوم، 10:30 ص',
    timeEn: 'Today, 10:30 AM',
    price: '280',
    diagnosticFee: '80',
    workFee: '200',
    phone: '+966500003042',
    category: _ServiceCategory.maintenance,
    icon: Icons.ac_unit_outlined,
    photoUrls: [],
    featured: true,
  ),
  _ServiceRequest(
    id: 'SRV-3041',
    serviceAr: 'كهرباء وتمديدات',
    serviceEn: 'Electrical wiring',
    providerAr: 'م. خالد الشهري',
    providerEn: 'Khalid Al-Shehri',
    descriptionAr: 'تركيب قواطع كهربائية وتمديد فرعي مع اختبار الأحمال.',
    descriptionEn:
        'Install circuit breakers and a branch line, then test the electrical load.',
    locationAr: 'حي النزهة، الرياض',
    locationEn: 'Al Nuzha, Riyadh',
    timeAr: 'اليوم، 09:15 ص',
    timeEn: 'Today, 9:15 AM',
    price: '450',
    diagnosticFee: '80',
    workFee: '370',
    phone: '+966500003041',
    category: _ServiceCategory.electrical,
    icon: Icons.electrical_services_outlined,
    photoUrls: [],
  ),
  _ServiceRequest(
    id: 'SRV-3032',
    serviceAr: 'نقل وترتيب أثاث سكن',
    serviceEn: 'Home moving and furniture setup',
    providerAr: 'شركة المسار السريع للنقل',
    providerEn: 'Fast Track Moving Company',
    descriptionAr:
        'نقل الأثاث مع الفك والتركيب، وتوفير عمالة مناسبة والتزام بموعد التسليم.',
    descriptionEn:
        'Move furniture with disassembly and setup, providing an adequate crew and an agreed delivery time.',
    locationAr: 'حي النرجس، الرياض',
    locationEn: 'Al Narjis, Riyadh',
    timeAr: 'اليوم، 08:40 ص',
    timeEn: 'Today, 8:40 AM',
    price: '1,200',
    diagnosticFee: '200',
    workFee: '1,000',
    phone: '+966500003032',
    category: _ServiceCategory.moving,
    icon: Icons.local_shipping_outlined,
    photoUrls: [],
    urgent: true,
  ),
];

class ServicesRequestsReviewScreen extends StatefulWidget {
  const ServicesRequestsReviewScreen({super.key});

  @override
  State<ServicesRequestsReviewScreen> createState() =>
      _ServicesRequestsReviewScreenState();
}

class _ServicesRequestsReviewScreenState
    extends State<ServicesRequestsReviewScreen> {
  static const _storageKey = 'services_supervisor_review_state_v1';
  _ServiceCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _resolvedRequestIds = {};
  final Map<String, List<String>> _requestComments = {};
  final Map<String, ServiceProvider> _assignedProviders = {};
  final Map<String, ({bool approved, String? reason})> _decisions = {};
  bool _isLoading = true;
  bool _showArchive = false;
  final _escalationStore = ServicesEscalationStore();
  Map<String, ServicesEscalation> _escalations = const {};

  ServicesEscalation? _escalationOf(_ServiceRequest r) =>
      _escalations[ServicesEscalation.keyOf(ServicesEscalationKind.request, r.id)];

  Future<void> _loadEscalations() async {
    try {
      final all = await _escalationStore.refresh();
      if (mounted) setState(() => _escalations = all);
    } on Object catch (error) {
      debugPrint('Services escalations unavailable: $error');
    }
  }

  Future<void> _escalateRequest(
    _ServiceRequest request,
    AppLocalizations l10n,
  ) async {
    final isArabic = l10n.localeName.startsWith('ar');
    final reason = await askProductEscalationReason(context, isArabic: isArabic);
    if (reason == null || !mounted) return;
    try {
      await _escalationStore.escalate(
        kind: ServicesEscalationKind.request,
        refId: request.id,
        title: isArabic ? request.serviceAr : request.serviceEn,
        subject: isArabic ? request.descriptionAr : request.descriptionEn,
        reason: reason,
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'services request review',
        context: ErrorDescription('while escalating a request'),
      ));
      if (mounted) {
        AppSnackBar.showError(
          context,
          isArabic ? 'تعذر رفع الطلب لرئيس المشرفين' : 'Could not escalate',
        );
      }
      return;
    }
    await ServicesActivityLog().tryRecord(
      action: 'request_escalated',
      subject: request.id,
      details: reason,
    );
    await _loadEscalations();
    if (!mounted) return;
    AppSnackBar.showSuccess(
      context,
      isArabic
          ? 'تم رفع الطلب ${request.id} إلى رئيس المشرفين.'
          : 'Request ${request.id} sent to the head supervisor.',
    );
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_loadEscalations);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadReviewState();
    _loadEscalations();
    LocalEventStore.revision.addListener(_loadEscalations);
  }

  Future<void> _loadReviewState() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_storageKey);
      if (encoded != null) {
        final state = jsonDecode(encoded) as Map<String, dynamic>;
        final decisions = state['decisions'] as Map<String, dynamic>? ?? {};
        for (final entry in decisions.entries) {
          final value = entry.value as Map<String, dynamic>;
          _decisions[entry.key] = (
            approved: value['approved'] as bool? ?? false,
            reason: value['reason'] as String?,
          );
          _resolvedRequestIds.add(entry.key);
        }
        final comments = state['comments'] as Map<String, dynamic>? ?? {};
        for (final entry in comments.entries) {
          _requestComments[entry.key] = (entry.value as List).cast<String>();
        }
        final assigned = state['assignments'] as Map<String, dynamic>? ?? {};
        for (final entry in assigned.entries) {
          for (final provider in serviceProviders) {
            if (provider.id == entry.value) {
              _assignedProviders[entry.key] = provider;
              break;
            }
          }
        }
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'services request review',
        context: ErrorDescription('while loading saved review decisions'),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReviewState() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode({
        'decisions': {
          for (final entry in _decisions.entries)
            entry.key: {'approved': entry.value.approved, 'reason': entry.value.reason},
        },
        'comments': _requestComments,
        'assignments': {
          for (final entry in _assignedProviders.entries)
            entry.key: entry.value.id,
        },
      }),
    );
    if (!saved) throw StateError('Could not save services review data.');
  }

  Future<void> _restoreRequest(_ServiceRequest request) async {
    final decision = _decisions[request.id];
    setState(() {
      _resolvedRequestIds.remove(request.id);
      _decisions.remove(request.id);
      _showArchive = false;
    });
    try {
      await _saveReviewState();
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'services request review',
        context: ErrorDescription('while restoring a reviewed request'),
      ));
      if (mounted) {
        setState(() {
          _resolvedRequestIds.add(request.id);
          if (decision != null) _decisions[request.id] = decision;
          _showArchive = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final pendingRequests = _serviceRequests
        .where((request) => !_resolvedRequestIds.contains(request.id))
        .toList();
    final archiveRequests = _serviceRequests
        .where((request) => _resolvedRequestIds.contains(request.id))
        .toList();
    final query = _searchController.text.trim().toLowerCase();
    final sourceRequests = (_showArchive ? archiveRequests : pendingRequests)
        .where((request) {
          if (query.isEmpty) return true;
          final searchableText = [
            request.id,
            request.serviceAr,
            request.serviceEn,
            request.providerAr,
            request.providerEn,
            request.locationAr,
            request.locationEn,
          ].join(' ').toLowerCase();
          return searchableText.contains(query);
        })
        .toList();
    final requests = sourceRequests
        .where((request) =>
            _selectedCategory == null || request.category == _selectedCategory)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        ScrollFx(child: _buildHeading(l10n, pendingRequests.length)),
        const SizedBox(height: 14),
        ScrollFx(child: _buildSummary(l10n, pendingRequests.length)),
        const SizedBox(height: 10),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              label: Text(l10n.servicesReviewTitle),
              icon: const MotionIcon(Icons.pending_actions_outlined),
            ),
            ButtonSegment(
              value: true,
              label: Text(
                l10n.localeName.startsWith('ar') ? 'الأرشيف' : 'Archive',
              ),
              icon: const MotionIcon(Icons.archive_outlined),
            ),
          ],
          selected: {_showArchive},
          onSelectionChanged: (selection) =>
              setState(() => _showArchive = selection.first),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: isArabic
                ? 'ابحث برقم الطلب أو الخدمة أو مقدمها'
                : 'Search request number, service, or provider',
            prefixIcon: const MotionIcon(Icons.search_rounded),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: isArabic ? 'مسح البحث' : 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const MotionIcon(Icons.close_rounded),
                  ),
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
        ),
        const SizedBox(height: 14),
        ScrollFx(child: _buildCategoryFilters(l10n, sourceRequests)),
        const SizedBox(height: 14),
        if (requests.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 42),
            child: Text(
              l10n.servicesRequestsEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          for (final request in requests) ...[
            _ServiceRequestCard(
              request: request,
              isArabic: isArabic,
              onApprove: () async =>
                  _confirmDecision(request, approved: true, l10n: l10n),
              onReject: () async =>
                  _confirmDecision(request, approved: false, l10n: l10n),
              onDetails: () => _showDetails(request, isArabic, l10n),
              commentCount: _requestComments[request.id]?.length ?? 0,
              onComment: () => _addComment(request, l10n),
              archived: _showArchive,
              decisionLabel: _decisions[request.id]?.approved == true
                  ? l10n.servicesRequestApproved
                  : _decisions[request.id]?.reason == null
                      ? l10n.servicesRequestRejected
                      : l10n.servicesRequestRejectedWithReason(
                          _decisions[request.id]!.reason!,
                        ),
              onRestore: () => _restoreRequest(request),
              escalation: _escalationOf(request),
              onEscalate: () => _escalateRequest(request, l10n),
            ),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  Widget _buildHeading(AppLocalizations l10n, int requestCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MotionIcon(Icons.circle, color: AppColors.info, size: 10),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.servicesReviewTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.servicesReviewSubtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.blueFill,
            border: AppColors.blueEdge,
            boxShadow: AppColors.blueGlow,
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MotionIcon(Icons.pending_actions, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Text(
                l10n.servicesNewRequestsCount('$requestCount'),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(AppLocalizations l10n, int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              value: '${_decisions.values.where((decision) => decision.approved).length}',
              label: l10n.servicesCompletedToday,
              icon: Icons.task_alt_outlined,
              iconColor: AppColors.info,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryMetric(
              value: '$pendingCount',
              label: l10n.servicesAwaitingDecision,
              icon: Icons.hourglass_top_rounded,
              iconColor: AppColors.warningDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(
    AppLocalizations l10n,
    List<_ServiceRequest> requests,
  ) {
    final categories =
        <({String label, _ServiceCategory? category, int count})>[
      (label: l10n.servicesFilterAll, category: null, count: requests.length),
      (
        label: l10n.servicesFilterMaintenance,
        category: _ServiceCategory.maintenance,
        count: requests
            .where(
              (request) => request.category == _ServiceCategory.maintenance,
            )
            .length,
      ),
      (
        label: l10n.servicesFilterElectrical,
        category: _ServiceCategory.electrical,
        count: requests
            .where(
              (request) => request.category == _ServiceCategory.electrical,
            )
            .length,
      ),
      (
        label: l10n.servicesFilterMoving,
        category: _ServiceCategory.moving,
        count: requests
            .where((request) => request.category == _ServiceCategory.moving)
            .length,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in categories)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 7),
              child: _CategoryChip(
                label: item.label,
                count: item.count,
                selected: _selectedCategory == item.category,
                onTap: () => setState(() => _selectedCategory = item.category),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> _confirmDecision(
    _ServiceRequest request, {
    required bool approved,
    required AppLocalizations l10n,
  }) async {
    final decision = await showModalBottomSheet<_DecisionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DecisionConfirmationSheet(
        request: request,
        approved: approved,
        l10n: l10n,
        isArabic: l10n.localeName.startsWith('ar'),
        onConfirm: (reason) => Navigator.of(context).pop(
          _DecisionResult(approved: approved, rejectionReason: reason),
        ),
      ),
    );
    if (decision == null || !mounted) return false;
    return _applyDecision(
      request,
      approved: decision.approved,
      rejectionReason: decision.rejectionReason,
      l10n: l10n,
    );
  }

  Future<void> _addComment(
    _ServiceRequest request,
    AppLocalizations l10n,
  ) async {
    final comment = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestCommentSheet(
        comments: _requestComments[request.id] ?? const [],
        l10n: l10n,
      ),
    );
    if (comment == null || !mounted) return;
    final previousComments = List<String>.from(
      _requestComments[request.id] ?? const [],
    );
    setState(() {
      _requestComments.putIfAbsent(request.id, () => []).add(comment);
    });
    try {
      await _saveReviewState();
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'services request review',
        context: ErrorDescription('while saving a request comment'),
      ));
      if (mounted) {
        setState(() {
          if (previousComments.isEmpty) {
            _requestComments.remove(request.id);
          } else {
            _requestComments[request.id] = previousComments;
          }
        });
        AppSnackBar.showError(
          context,
          l10n.servicesAccountSaveError('$error'),
        );
      }
      return;
    }
    AppSnackBar.showSuccess(context, l10n.servicesCommentSaved);
  }

  Future<bool> _applyDecision(
    _ServiceRequest request, {
    required bool approved,
    String? rejectionReason,
    required AppLocalizations l10n,
  }) async {
    if (!mounted) return false;
    setState(() {
      _resolvedRequestIds.add(request.id);
      _decisions[request.id] = (approved: approved, reason: rejectionReason);
    });
    try {
      await _saveReviewState();
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'services request review',
        context: ErrorDescription('while saving a review decision'),
      ));
      if (mounted) {
        setState(() {
          _resolvedRequestIds.remove(request.id);
          _decisions.remove(request.id);
        });
        AppSnackBar.showError(
          context,
          l10n.servicesAccountSaveError('$error'),
        );
      }
      return false;
    }
    AppSnackBar.showSuccess(
      context,
      approved
          ? l10n.servicesRequestApproved
          : l10n.servicesRequestRejectedWithReason(rejectionReason ?? ''),
    );
    await ServicesActivityLog().tryRecord(
      action: approved ? 'request_approved' : 'request_rejected',
      subject: request.id,
      details: rejectionReason ?? '',
    );
    return true;
  }

  Future<void> _showDetails(
    _ServiceRequest request,
    bool isArabic,
    AppLocalizations l10n,
  ) {
    final title = isArabic ? request.serviceAr : request.serviceEn;
    final provider = isArabic ? request.providerAr : request.providerEn;
    final description =
        isArabic ? request.descriptionAr : request.descriptionEn;
    final location = isArabic ? request.locationAr : request.locationEn;
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServicesRequestDetailsScreen(
          reference: request.id,
          service: title,
          provider: provider,
          description: description,
          location: location,
          requestedAt: isArabic ? request.timeAr : request.timeEn,
          phone: request.phone,
          price: request.price,
          diagnosticFee: request.diagnosticFee,
          workFee: request.workFee,
          icon: request.icon,
          photoUrls: request.photoUrls,
          onAssign: (provider) async {
            final previousProvider = _assignedProviders[request.id];
            setState(() => _assignedProviders[request.id] = provider);
            try {
              await _saveReviewState();
              return true;
            } catch (error, stackTrace) {
              FlutterError.reportError(FlutterErrorDetails(
                exception: error,
                stack: stackTrace,
                library: 'services request review',
                context: ErrorDescription('while saving provider assignment'),
              ));
              if (mounted) {
                setState(() {
                  if (previousProvider == null) {
                    _assignedProviders.remove(request.id);
                  } else {
                    _assignedProviders[request.id] = previousProvider;
                  }
                });
                AppSnackBar.showError(
                  context,
                  l10n.servicesAccountSaveError('$error'),
                );
              }
              return false;
            }
          },
          assignedProvider: _assignedProviders[request.id],
          initialCategory: request.category.name,
          onConfirm: () async =>
              _applyDecision(request, approved: true, l10n: l10n),
        ),
      ),
    );
  }
}

class _DecisionResult {
  final bool approved;
  final String? rejectionReason;

  const _DecisionResult({
    required this.approved,
    this.rejectionReason,
  });
}

class _DecisionConfirmationSheet extends StatefulWidget {
  final _ServiceRequest request;
  final bool approved;
  final AppLocalizations l10n;
  final bool isArabic;
  final ValueChanged<String?> onConfirm;

  const _DecisionConfirmationSheet({
    required this.request,
    required this.approved,
    required this.l10n,
    required this.isArabic,
    required this.onConfirm,
  });

  @override
  State<_DecisionConfirmationSheet> createState() =>
      _DecisionConfirmationSheetState();
}

class _DecisionConfirmationSheetState
    extends State<_DecisionConfirmationSheet> {
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedReason;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final request = widget.request;
    final service = widget.isArabic ? request.serviceAr : request.serviceEn;
    final provider = widget.isArabic ? request.providerAr : request.providerEn;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final reasons = [
      l10n.servicesRejectionReasonScope,
      l10n.servicesRejectionReasonDetails,
      l10n.servicesRejectionReasonTerms,
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: widget.approved
                ? _buildApproval(l10n, request, service, provider)
                : _buildRejection(l10n, request, service, provider, reasons),
          ),
        ),
      ),
    );
  }

  Widget _buildApproval(
    AppLocalizations l10n,
    _ServiceRequest request,
    String service,
    String provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SheetHandle(),
        const SizedBox(height: 12),
        Center(
          child: _DecisionIcon(
            icon: Icons.fact_check_outlined,
            color: AppColors.primaryDark,
            background: AppColors.surfaceLight,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            l10n.servicesApproveTitle,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.servicesApproveMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _DecisionRequestSummary(
          request: request,
          service: service,
          provider: provider,
          l10n: l10n,
          approved: true,
        ),
        const SizedBox(height: 12),
        _DecisionNote(
          icon: Icons.notifications_active_outlined,
          text: l10n.servicesApprovalNotification,
          color: AppColors.infoLight,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => widget.onConfirm(null),
            icon: const MotionIcon(Icons.check_circle_outline),
            label: Text(l10n.servicesApproveConfirmPublish),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.logoutCancel,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildRejection(
    AppLocalizations l10n,
    _ServiceRequest request,
    String service,
    String provider,
    List<String> reasons,
  ) {
    final canSubmit = _reasonController.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SheetHandle(),
        const SizedBox(height: 12),
        Row(
          children: [
            _DecisionIcon(
              icon: Icons.block_outlined,
              color: AppColors.danger,
              background: AppColors.dangerLight,
            ),
            const Spacer(),
            IconButton(
              tooltip: l10n.logoutCancel,
              onPressed: () => Navigator.of(context).pop(),
              icon: const MotionIcon(Icons.close),
            ),
          ],
        ),
        Center(
          child: Text(
            l10n.servicesRejectTitle,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.servicesRejectMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        _DecisionRequestSummary(
          request: request,
          service: service,
          provider: provider,
          l10n: l10n,
          approved: false,
        ),
        const SizedBox(height: 14),
        Text(
          l10n.servicesRejectionQuickReasons,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          runSpacing: 6,
          children: [
            for (final reason in reasons)
              ChoiceChip(
                label: Text(reason),
                selected: _selectedReason == reason,
                onSelected: (_) {
                  setState(() {
                    _selectedReason = reason;
                    _reasonController.text = reason;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.servicesRejectionReasonLabel,
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text('*', style: TextStyle(color: AppColors.danger)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _reasonController,
          maxLength: 300,
          maxLines: 4,
          onChanged: (_) => setState(() => _selectedReason = null),
          decoration: InputDecoration(
            hintText: l10n.servicesRejectionReasonHint,
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _DecisionNote(
          icon: Icons.verified_user_outlined,
          text: l10n.servicesRejectionAuditNote,
          color: AppColors.surfaceLight,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: canSubmit
                ? () => widget.onConfirm(_reasonController.text.trim())
                : null,
            icon: const MotionIcon(Icons.edit_note_outlined),
            label: Text(l10n.servicesRejectConfirm),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.danger.withValues(alpha: .4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.logoutCancel),
        ),
      ],
    );
  }
}

class _RequestCommentSheet extends StatefulWidget {
  final List<String> comments;
  final AppLocalizations l10n;

  const _RequestCommentSheet({required this.comments, required this.l10n});

  @override
  State<_RequestCommentSheet> createState() => _RequestCommentSheetState();
}

class _RequestCommentSheetState extends State<_RequestCommentSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScrollFx(child: const _SheetHandle()),
                const SizedBox(height: 14),
                Text(
                  l10n.servicesCommentTitle,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.comments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  for (final comment in widget.comments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        comment,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: 500,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n.servicesCommentHint,
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {
                    final comment = _controller.text.trim();
                    if (comment.isNotEmpty) {
                      Navigator.of(context).pop(comment);
                    }
                  },
                  icon: const MotionIcon(Icons.send_outlined),
                  label: Text(l10n.servicesCommentSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceRequestCard extends StatelessWidget {
  final _ServiceRequest request;
  final bool isArabic;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDetails;
  final int commentCount;
  final VoidCallback onComment;
  final bool archived;
  final String decisionLabel;
  final VoidCallback onRestore;
  final ServicesEscalation? escalation;
  final VoidCallback onEscalate;

  const _ServiceRequestCard({
    required this.request,
    required this.isArabic,
    required this.onApprove,
    required this.onReject,
    required this.onDetails,
    required this.commentCount,
    required this.onComment,
    required this.archived,
    required this.decisionLabel,
    required this.onRestore,
    required this.escalation,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = isArabic ? request.serviceAr : request.serviceEn;
    final provider = isArabic ? request.providerAr : request.providerEn;
    final location = isArabic ? request.locationAr : request.locationEn;
    final time = isArabic ? request.timeAr : request.timeEn;
    final description =
        isArabic ? request.descriptionAr : request.descriptionEn;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MotionIcon(
                  request.icon,
                  color: AppColors.ink,
                  size: 25,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '#${request.id} • $time',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _StatusBadge(
                label: archived
                    ? decisionLabel
                    : request.urgent
                        ? l10n.servicesUrgent
                        : l10n.servicesUnderReview,
                urgent: archived ? false : request.urgent,
              ),
            ],
          ),
          if (request.featured) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _FeaturedBadge(label: l10n.servicesFeaturedRequest),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                MotionIcon(
                  Icons.person_pin_circle_outlined,
                  color: AppColors.ink,
                  size: 19,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    provider,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.infoBorder,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.servicesVerifiedProvider,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _ServiceIllustration(
            icon: request.icon,
            location: location,
            price: request.price,
            currency: l10n.servicesCurrency,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.servicesWorkDescription,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (request.urgent) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.dangerBorder),
              ),
              child: Text(
                l10n.servicesUrgentNotice,
                style: TextStyle(
                  color: AppColors.dangerDark,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (archived) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRestore,
                icon: const MotionIcon(Icons.restart_alt),
                label: Text(
                  l10n.localeName.startsWith('ar')
                      ? 'إعادة إلى المراجعة'
                      : 'Return to review',
                ),
              ),
            ),
          ] else ...[
          Row(
            children: [
              Expanded(
                child: _DecisionButton(
                  label: l10n.servicesRejectAction,
                  icon: Icons.cancel_outlined,
                  onPressed: onReject,
                  rejected: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DecisionButton(
                  label: l10n.servicesApproveAction,
                  icon: Icons.check_circle_outline,
                  onPressed: onApprove,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: escalation != null && !escalation!.canEscalateAgain
                ? Text(
                    '${isArabic ? 'مرفوع للرئيس' : 'With head'}: ${escalation!.status.labelAr}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: onEscalate,
                    icon: const MotionIcon(Icons.north_east, size: 16),
                    label: Text(isArabic
                        ? 'رفع لرئيس المشرفين (طلب مشبوه)'
                        : 'Escalate to head (suspicious)'),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextButton.icon(
                    onPressed: onDetails,
                    icon: const MotionIcon(Icons.visibility_outlined, size: 18),
                    label: Text(l10n.servicesViewDetails),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      backgroundColor: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onComment,
                    icon: const MotionIcon(Icons.comment_outlined, size: 17),
                    label: Text(
                      commentCount == 0
                          ? l10n.servicesCommentAction
                          : '${l10n.servicesCommentAction} ($commentCount)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ],
        ],
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  final String label;

  const _FeaturedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warningBorder,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(Icons.stars_rounded, color: AppColors.warningDark, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.warningDark,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.cardBorder,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
}

class _DecisionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _DecisionIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(15),
        ),
        child: MotionIcon(icon, color: color, size: 30),
      );
}

class _DecisionRequestSummary extends StatelessWidget {
  final _ServiceRequest request;
  final String service;
  final String provider;
  final AppLocalizations l10n;
  final bool approved;

  const _DecisionRequestSummary({
    required this.request,
    required this.service,
    required this.provider,
    required this.l10n,
    required this.approved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '#${request.id}',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${l10n.servicesDecisionProvider}: $provider',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          if (approved) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DecisionAmount(
                    label: l10n.servicesDecisionDiagnosticFee,
                    value: request.diagnosticFee,
                    currency: l10n.servicesCurrency,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DecisionAmount(
                    label: l10n.servicesEstimatedCost,
                    value: request.price,
                    currency: l10n.servicesCurrency,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              l10n.servicesUnderReview,
              style: TextStyle(color: AppColors.danger, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionAmount extends StatelessWidget {
  final String label;
  final String value;
  final String currency;

  const _DecisionAmount({
    required this.label,
    required this.value,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 4),
            CountText(
              '$value $currency',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
}

class _DecisionNote extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _DecisionNote({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            MotionIcon(icon, color: AppColors.info, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ServiceIllustration extends StatelessWidget {
  final IconData icon;
  final String location;
  final String price;
  final String currency;

  const _ServiceIllustration({
    required this.icon,
    required this.location,
    required this.price,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardBorder, AppColors.textSecondary, AppColors.infoDark],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: -45,
            child: MotionIcon(
              icon,
              size: 180,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 10,
            child: _ImageLabel(text: '$price $currency'),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: _ImageLabel(
              icon: Icons.location_on_outlined,
              text: location,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageLabel extends StatelessWidget {
  final IconData? icon;
  final String text;

  const _ImageLabel({this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            MotionIcon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 3),
          ],
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _SummaryMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MotionIcon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          CountText(
            value,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryDark : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primaryDark : AppColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.16)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CountText(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.ink,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool urgent;

  const _StatusBadge({required this.label, required this.urgent});

  @override
  Widget build(BuildContext context) {
    final color = urgent ? AppColors.dangerDark : AppColors.infoDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: urgent ? AppColors.dangerLight : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(
            urgent ? Icons.warning_amber_rounded : Icons.circle,
            color: color,
            size: 10,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool rejected;

  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.rejected = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = rejected ? AppColors.dangerDark : Colors.white;
    return SizedBox(
      height: 44,
      child: rejected
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: MotionIcon(icon, size: 17),
              label: Text(label, maxLines: 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: foreground,
                side: BorderSide(color: AppColors.borderLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: MotionIcon(icon, size: 17),
              label: Text(label, maxLines: 1),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: foreground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
    );
  }
}
