import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/finance_audit_store.dart';
import '../utils/finance_profile_report_exporter.dart';
import '../widgets/finance_navigation.dart';

class AuditScreen extends StatefulWidget {
  final bool showBottomNavigation;

  const AuditScreen({super.key, this.showBottomNavigation = true});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen>
    with AutomaticKeepAliveClientMixin<AuditScreen> {
  static const _filters = [
    ('all', 'الكل', 'All'),
    ('bank', 'تحويلات بنكية', 'Bank transfers'),
    ('freeze', 'تجميد أرصدة', 'Frozen balances'),
    ('other', 'إجراءات أخرى', 'Other actions'),
  ];

  List<_AuditEvent> _events = const [];
  bool _loading = true;

  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FinanceAuditStore.revision.addListener(_loadAuditEntries);
    _loadAuditEntries();
  }

  Future<void> _loadAuditEntries() async {
    try {
      final entries = await FinanceAuditStore().getRecent();
      final now = DateTime.now();
      final events = entries.map((entry) {
        final localDate = entry.occurredAt.toLocal();
        final today = DateTime(now.year, now.month, now.day);
        final eventDay = DateTime(localDate.year, localDate.month, localDate.day);
        final group = eventDay == today
            ? 'today'
            : eventDay == today.subtract(const Duration(days: 1))
                ? 'yesterday'
                : 'older';
        final isFreeze = entry.actionKey.contains('freeze');
        final isBank = entry.actionKey.contains('bank');
        final time = '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}:${localDate.second.toString().padLeft(2, '0')}';
        return _AuditEvent(
          group: group,
          category: isFreeze ? 'freeze' : isBank ? 'bank' : 'other',
          titleAr: entry.titleAr,
          titleEn: entry.titleEn,
          amount: '—',
          amountEn: '—',
          amountColor: isFreeze ? AppColors.danger : AppColors.infoDark,
          timeAr: '${group == 'today' ? 'اليوم' : group == 'yesterday' ? 'أمس' : 'سابقًا'} • $time',
          timeEn: '${group == 'today' ? 'Today' : group == 'yesterday' ? 'Yesterday' : 'Earlier'} • $time',
          descriptionAr: entry.detailsAr.isEmpty ? entry.titleAr : entry.detailsAr,
          descriptionEn: entry.detailsEn.isEmpty ? entry.titleEn : entry.detailsEn,
          statusAr: 'المنفذ: المشرف المالي',
          statusEn: 'Performed by: Finance supervisor',
          reference: entry.reference,
          icon: isFreeze ? Icons.lock_outline_rounded : Icons.fact_check_outlined,
          color: isFreeze ? AppColors.danger : AppColors.primaryDark,
          isWarning: isFreeze,
        );
      }).toList();
      if (mounted) setState(() {
        _events = events;
        _loading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'finance audit screen',
      ));
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_AuditEvent> get _visibleEvents => _events.where((event) {
        final matchesCategory =
            _selectedFilter == 'all' || event.category == _selectedFilter;
        final query = _searchQuery.trim().toLowerCase();
        final matchesSearch = query.isEmpty ||
            [
              event.reference,
              event.titleAr,
              event.titleEn,
              event.descriptionAr,
              event.descriptionEn,
              event.statusAr,
              event.statusEn,
            ].any((value) => value.toLowerCase().contains(query));
        return matchesCategory && matchesSearch;
      }).toList();

  List<_AuditEvent> _eventsForGroup(String group) =>
      _visibleEvents.where((event) => event.group == group).toList();

  int _countForCategory(String category) => category == 'all'
      ? _events.length
      : _events.where((event) => event.category == category).length;

  @override
  void dispose() {
    FinanceAuditStore.revision.removeListener(_loadAuditEntries);
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: FinanceSwipeNavigation(
        currentIndex: 0,
        enabled: widget.showBottomNavigation,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7F9),
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              children: [
                if (widget.showBottomNavigation) _buildBrandHeader(l10n),
                const SizedBox(height: 12),
                _buildHashCard(isArabic),
                const SizedBox(height: 10),
                _buildFilters(isArabic),
                const SizedBox(height: 10),
                _buildSearchField(isArabic),
                const SizedBox(height: 10),
                _buildSummary(isArabic),
                const SizedBox(height: 14),
                if (_eventsForGroup('today').isNotEmpty) ...[
                  _buildDateHeading(
                    isArabic ? 'اليوم' : 'Today',
                    isArabic,
                  ),
                  const SizedBox(height: 8),
                  ..._eventsForGroup('today').map(
                    (event) => _AuditEventCard(
                      event: event,
                      isArabic: isArabic,
                      isLast: event == _eventsForGroup('today').last,
                      onTap: () => _showEventDetails(event, isArabic),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (_eventsForGroup('yesterday').isNotEmpty) ...[
                  _buildDateHeading(
                    isArabic ? 'أمس' : 'Yesterday',
                    isArabic,
                  ),
                  const SizedBox(height: 8),
                  ..._eventsForGroup('yesterday').map(
                    (event) => _AuditEventCard(
                      event: event,
                      isArabic: isArabic,
                      isLast: event == _eventsForGroup('yesterday').last,
                      onTap: () => _showEventDetails(event, isArabic),
                    ),
                  ),
                ],
                if (_eventsForGroup('older').isNotEmpty) ...[
                  _buildDateHeading(
                    isArabic ? 'سابقًا' : 'Earlier',
                    isArabic,
                  ),
                  const SizedBox(height: 8),
                  ..._eventsForGroup('older').map(
                    (event) => _AuditEventCard(
                      event: event,
                      isArabic: isArabic,
                      isLast: event == _eventsForGroup('older').last,
                      onTap: () => _showEventDetails(event, isArabic),
                    ),
                  ),
                ],
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_visibleEvents.isEmpty)
                  _buildEmptyState(isArabic),
                const SizedBox(height: 10),
                _buildDisclosure(isArabic),
                const SizedBox(height: 8),
                _buildExportButton(l10n),
              ],
            ),
          ),
          bottomNavigationBar: widget.showBottomNavigation
              ? const FinanceBottomNavigationBar(currentIndex: 0)
              : null,
        ),
      ),
    );
  }

  Widget _buildBrandHeader(AppLocalizations l10n) {
    return SizedBox(
      height: 66,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryDark,
              child: Icon(Icons.person_outline, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Text(l10n.certifiedFinancialAuditor,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified_user_outlined,
                      size: 12, color: AppColors.info),
                ],
              ),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.appName,
                    style: const TextStyle(
                        fontSize: 16,
                        height: 1.1,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold)),
                Text(l10n.financialDepartment,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield_outlined,
                  size: 19, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashCard(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102B4B), Color(0xFF071A31)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A071A31), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white70, size: 13),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  isArabic
                      ? 'سجل حركات المشرف المالي'
                      : 'Finance supervisor activity log',
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ),
              _pill(
                isArabic ? 'محلي' : 'Local',
                const Color(0xFF263E59),
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'سجل التدقيق المالي المركزي'
                : 'Central financial audit log',
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF07182F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.storage_outlined,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isArabic
                        ? '${_events.length} حركة محفوظة محليًا على هذا الجهاز'
                        : '${_events.length} actions saved locally on this device',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.circle, size: 7, color: Color(0xFF26D69A)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  isArabic
                      ? 'سجل محلي قابل للتعديل ولا يمثل سجلًا خلفيًا معتمدًا'
                      : 'Local editable records; not a certified server audit log',
                  style: const TextStyle(color: Colors.white70, fontSize: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isArabic) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: _filters.map((filter) {
          final selected = _selectedFilter == filter.$1;
          final count = _countForCategory(filter.$1);
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: ChoiceChip(
              label: Text('${isArabic ? filter.$2 : filter.$3} ($count)'),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = filter.$1),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              labelStyle: TextStyle(
                  fontSize: 9,
                  color: selected ? Colors.white : AppColors.textSecondary),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryDark,
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchField(bool isArabic) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        hintText: isArabic
            ? 'ابحث برقم المرجع أو العملية أو الجهة'
            : 'Search reference, operation, or entity',
        prefixIcon: const Icon(Icons.search_rounded, size: 19),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: isArabic ? 'مسح البحث' : 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE6EAF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE6EAF0)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                color: AppColors.textSecondary, size: 26),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'لا توجد سجلات تطابق البحث أو الفلتر.'
                  : 'No records match this search or filter.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      );

  Widget _buildSummary(bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: _AuditMetric(
            icon: Icons.pending_actions_outlined,
            title: isArabic ? 'السجلات الظاهرة' : 'Visible records',
            value: '${_visibleEvents.length}',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _AuditMetric(
            icon: Icons.account_balance_wallet_outlined,
            title: isArabic ? 'حركات مالية' : 'Financial actions',
            value: '${_visibleEvents.where((event) => event.category == 'bank').length}',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _AuditMetric(
            icon: Icons.fact_check_outlined,
            title: isArabic ? 'تجميد أرصدة' : 'Frozen balances',
            value: '${_visibleEvents.where((event) => event.category == 'freeze').length}',
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeading(String label, bool isArabic) {
    return Row(
      children: [
        const Icon(Icons.calendar_month_outlined,
            size: 14, color: AppColors.info),
        const SizedBox(width: 6),
        Expanded(child: Divider(color: Colors.blueGrey.shade100)),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.infoDark,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDisclosure(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E8EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gavel_rounded, size: 17, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isArabic
                  ? 'يوفر سجل التدقيق مرجعًا لمراجعة العمليات المالية وتفاصيلها.'
                  : 'The audit log provides a reference for reviewing financial operations and their details.',
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 9, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: () => _showExportOptions(l10n),
      icon: const Icon(Icons.download_rounded, size: 17),
      label: Text(
        l10n.localeName.startsWith('ar')
            ? 'تصدير الحركات الظاهرة بصيغة Excel / PDF'
            : 'Export visible activity as Excel / PDF',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
      ),
    );
  }

  Future<void> _showExportOptions(AppLocalizations l10n) async {
    final isArabic = l10n.localeName.startsWith('ar');
    final format = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isArabic ? 'تصدير سجل التدقيق' : 'Export audit log'),
        content: Text(
          isArabic
              ? 'اختر صيغة تصدير الحركات المعروضة.'
              : 'Choose a format for the visible audit activity.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'excel'),
            child: const Text('Excel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'pdf'),
            child: const Text('PDF'),
          ),
        ],
      ),
    );
    if (!mounted || format == null) return;

    try {
      if (format == 'excel') {
        final exportStarted = await FinanceProfileReportExporter.shareExcel(
          rows: [
            const [
              'Date/time',
              'Operation',
              'Amount',
              'Details',
              'Status',
              'Reference',
            ],
            ..._visibleEvents.map(
              (event) => [
                isArabic ? event.timeAr : event.timeEn,
                isArabic ? event.titleAr : event.titleEn,
                isArabic ? event.amount : event.amountEn,
                isArabic ? event.descriptionAr : event.descriptionEn,
                isArabic ? event.statusAr : event.statusEn,
                event.reference,
              ],
            ),
          ],
          fileName: 'finance_audit_log.xlsx',
          shareText: l10n.navAudit,
          sharePositionOrigin: _sharePositionOrigin(),
        );
        if (!mounted || !exportStarted) return;
      } else {
        final exported = await FinanceProfileReportExporter.printPdf(
          fileName: 'finance_audit_log.pdf',
          title: isArabic ? 'سجل التدقيق المالي' : 'Finance audit log',
          rows: [
            const [
              'Date/time',
              'Operation',
              'Amount',
              'Details',
              'Status',
              'Reference',
            ],
            ..._visibleEvents.map(
              (event) => [
                isArabic ? event.timeAr : event.timeEn,
                isArabic ? event.titleAr : event.titleEn,
                isArabic ? event.amount : event.amountEn,
                isArabic ? event.descriptionAr : event.descriptionEn,
                isArabic ? event.statusAr : event.statusEn,
                event.reference,
              ],
            ),
          ],
        );
        if (!mounted || !exported) return;
      }
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        isArabic ? 'تم تجهيز التصدير.' : 'The export is ready.',
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance reports',
          context: ErrorDescription('while exporting the audit activity'),
        ),
      );
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        isArabic
            ? 'تعذر تصدير سجل التدقيق.'
            : 'Could not export the audit log.',
      );
    }
  }

  Rect? _sharePositionOrigin() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return Offset.zero & MediaQuery.sizeOf(context);
    }
    return renderBox.localToGlobal(Offset.zero) & renderBox.size;
  }

  Future<void> _showEventDetails(_AuditEvent event, bool isArabic) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF5F7F9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isArabic ? event.titleAr : event.titleEn,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(isArabic ? event.timeAr : event.timeEn,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
            const Divider(height: 22),
            Text(isArabic ? event.descriptionAr : event.descriptionEn,
                style: const TextStyle(fontSize: 12, height: 1.55)),
            const SizedBox(height: 10),
            Text(isArabic ? event.statusAr : event.statusEn,
                style: TextStyle(color: event.color, fontSize: 11)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isArabic ? 'المرجع' : 'Reference',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10),
                  ),
                ),
                Text(event.reference,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                        color: AppColors.infoDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Text(isArabic ? event.amount : event.amountEn,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: event.amountColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _AuditMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AuditMetric({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppColors.info),
          const SizedBox(height: 3),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AuditEvent {
  final String group;
  final String category;
  final String titleAr;
  final String titleEn;
  final String amount;
  final String amountEn;
  final Color amountColor;
  final String timeAr;
  final String timeEn;
  final String descriptionAr;
  final String descriptionEn;
  final String statusAr;
  final String statusEn;
  final String reference;
  final IconData icon;
  final Color color;
  final bool isWarning;

  const _AuditEvent({
    required this.group,
    required this.category,
    required this.titleAr,
    required this.titleEn,
    required this.amount,
    required this.amountEn,
    required this.amountColor,
    required this.timeAr,
    required this.timeEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.statusAr,
    required this.statusEn,
    required this.reference,
    required this.icon,
    required this.color,
    this.isWarning = false,
  });
}

class _AuditEventCard extends StatelessWidget {
  final _AuditEvent event;
  final bool isArabic;
  final bool isLast;
  final VoidCallback onTap;

  const _AuditEventCard({
    required this.event,
    required this.isArabic,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE9EDF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(event.icon, size: 16, color: event.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isArabic ? event.titleAr : event.titleEn,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isArabic ? event.timeAr : event.timeEn,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isArabic ? event.amount : event.amountEn,
                textAlign: TextAlign.left,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                    color: event.amountColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isArabic ? event.descriptionAr : event.descriptionEn,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 10, height: 1.5),
                ),
                if (event.isWarning) ...[
                  const SizedBox(height: 7),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9E7),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 13, color: AppColors.danger),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            isArabic ? event.statusAr : event.statusEn,
                            style: const TextStyle(
                                color: AppColors.danger, fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.reference,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                            color: AppColors.infoDark,
                            fontSize: 8,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      event.isWarning
                          ? Icons.gavel_rounded
                          : Icons.verified_user_outlined,
                      size: 11,
                      color:
                          event.isWarning ? AppColors.danger : AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        event.isWarning
                            ? (isArabic
                                ? 'جهة النظر: دائرة الامتثال'
                                : 'Reviewed by compliance')
                            : (isArabic ? event.statusAr : event.statusEn),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: event.isWarning
                              ? AppColors.textSecondary
                              : AppColors.successDark,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

Widget _pill(String label, Color background, Color foreground) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(label,
        style: TextStyle(
            color: foreground, fontSize: 8, fontWeight: FontWeight.w600)),
  );
}
