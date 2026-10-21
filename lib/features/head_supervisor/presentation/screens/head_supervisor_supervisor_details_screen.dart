import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/head_supervisor_audit_store.dart';
import '../head_supervisor_text.dart';

class HeadSupervisorSupervisorDetailsScreen extends StatefulWidget {
  final String supervisorId;
  final String name;
  final String department;
  final String status;
  final String avatar;
  final Color avatarColor;
  final String email;
  final String phone;
  final String area;
  final String city;
  final String marketScope;

  const HeadSupervisorSupervisorDetailsScreen({
    super.key,
    required this.supervisorId,
    required this.name,
    required this.department,
    required this.status,
    required this.avatar,
    required this.avatarColor,
    this.email = '',
    this.phone = '',
    this.area = '',
    this.city = '',
    this.marketScope = '',
  });

  @override
  State<HeadSupervisorSupervisorDetailsScreen> createState() =>
      _HeadSupervisorSupervisorDetailsScreenState();
}

class _HeadSupervisorSupervisorDetailsScreenState
    extends State<HeadSupervisorSupervisorDetailsScreen> {
  String _filter = 'all';
  String _searchQuery = '';
  final _activitySearchController = TextEditingController();
  late Future<List<HeadSupervisorAuditRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    HeadSupervisorAuditStore.revision.addListener(_refreshRecords);
    _recordsFuture = _loadRecords();
  }

  Future<List<HeadSupervisorAuditRecord>> _loadRecords() async {
    final records = await HeadSupervisorAuditStore().getRecent(limit: 1000);
    return records
        .where((record) =>
            record.subjectId == widget.supervisorId ||
            record.subjectId == widget.supervisorId.replaceFirst('#', '') ||
            record.subjectId == 'ALL-SUPERVISORS')
        .toList(growable: false);
  }

  void _refreshRecords() {
    if (mounted) setState(() => _recordsFuture = _loadRecords());
  }

  @override
  void dispose() {
    HeadSupervisorAuditStore.revision.removeListener(_refreshRecords);
    _activitySearchController.dispose();
    super.dispose();
  }

  List<_Activity> _activitiesFor(
    List<HeadSupervisorAuditRecord> records, {
    bool applyFilter = true,
  }) {
    final activities = records.map((record) {
      final icon = switch (record.kind) {
        'supervisor_management' => Icons.manage_accounts_outlined,
        'request' => Icons.assignment_outlined,
        'complaint' => Icons.report_outlined,
        'broadcast' => Icons.campaign_outlined,
        _ => Icons.history_outlined,
      };
      final occurredAt = record.occurredAt.toLocal();
      final formattedDate =
          '${occurredAt.year}-${occurredAt.month.toString().padLeft(2, '0')}-${occurredAt.day.toString().padLeft(2, '0')} ${occurredAt.hour.toString().padLeft(2, '0')}:${occurredAt.minute.toString().padLeft(2, '0')}';
      return _Activity(
        id: record.id.length > 12
            ? '…${record.id.substring(record.id.length - 8)}'
            : record.id,
        category: record.department,
        title: record.title,
        description: record.details,
        status: 'مسجل',
        time: formattedDate,
        icon: icon,
        kind: record.kind,
      );
    }).toList(growable: false);
    final filtered = !applyFilter ? activities : switch (_filter) {
      'supervisor_management' => activities
          .where((item) => item.kind == 'supervisor_management')
          .toList(),
      'request' => activities.where((item) => item.kind == 'request').toList(),
      'complaint' =>
        activities.where((item) => item.kind == 'complaint').toList(),
      'other' => activities
          .where((item) => !{
                'supervisor_management',
                'request',
                'complaint',
              }.contains(item.kind))
          .toList(),
      _ => activities,
    };
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return filtered;
    return filtered
        .where((item) => [
              item.id,
              item.category,
              item.title,
              item.description,
              item.status,
            ].any((value) => value.toLowerCase().contains(query)))
        .toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        title: Text(headSupervisorText(context, arabic: 'بيانات المشرف', english: 'Supervisor details'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: headSupervisorText(context, arabic: 'العودة إلى قائمة المشرفين', english: 'Back to supervisors'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        children: [
          _ProfileCard(
            name: widget.name,
            id: widget.supervisorId,
            department: widget.department,
            status: widget.status,
            avatar: widget.avatar,
            color: widget.avatarColor,
            email: widget.email,
            phone: widget.phone,
            area: widget.area,
            city: widget.city,
            marketScope: widget.marketScope,
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<HeadSupervisorAuditRecord>>(
            future: _recordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text(headSupervisorText(context,
                    arabic: 'تعذر تحميل سجل إجراءات هذا المشرف.',
                    english: 'Could not load this supervisor’s activity log.'));
              }
              final records = snapshot.data ?? const <HeadSupervisorAuditRecord>[];
              final allActivities = _activitiesFor(records);
              final filterActivities =
                  _activitiesFor(records, applyFilter: false);
              final total = records.length;
              final managementActions = records
                  .where((record) => record.kind == 'supervisor_management')
                  .length;
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  TextButton(
                    onPressed: _refreshRecords,
                    child: Text(headSupervisorText(context,
                        arabic: 'تحديث', english: 'Refresh'),
                        style: const TextStyle(fontSize: 10)),
                  ),
                  const Spacer(),
                  Text(headSupervisorText(context,
                      arabic: 'المؤشرات والإجراءات المسجلة',
                      english: 'Recorded metrics and actions'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ]),
                const SizedBox(height: 8),
                _MainMetricCard(count: total),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: _SmallMetricCard(value: '$managementActions', label: headSupervisorText(context, arabic: 'إجراءات إدارة المشرف', english: 'Supervisor management actions'), helper: headSupervisorText(context, arabic: 'محفوظة في سجل رئيس المشرفين', english: 'Saved in the head supervisor audit log'), icon: Icons.manage_accounts_outlined)),
                  const SizedBox(width: 9),
                  Expanded(child: _SmallMetricCard(value: '${total - managementActions}', label: headSupervisorText(context, arabic: 'إجراءات أخرى', english: 'Other actions'), helper: headSupervisorText(context, arabic: 'مرتبطة بمعرّف هذا المشرف', english: 'Linked to this supervisor ID'), icon: Icons.history_outlined)),
                ]),
                const SizedBox(height: 17),
                Row(children: [
                  const Spacer(),
                  Text(headSupervisorText(context,
                      arabic: 'سجل الإجراءات الفعلية',
                      english: 'Actual activity log'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(width: 7),
                  _CountBadge(label: '${allActivities.length}'),
                ]),
                const SizedBox(height: 8),
                TextField(
            controller: _activitySearchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: headSupervisorText(context,
                  arabic: 'ابحث في السجل بالاسم أو الرقم أو نوع الإجراء',
                  english: 'Search records by name, ID, or action type'),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: headSupervisorText(context,
                          arabic: 'مسح البحث', english: 'Clear search'),
                      onPressed: () {
                        _activitySearchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.close, size: 18),
                    ),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE9EDF2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE9EDF2)),
              ),
            ),
                ),
                const SizedBox(height: 8),
                _ActivityFilters(
                  selected: _filter,
                  activities: filterActivities,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 10),
                if (allActivities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(headSupervisorText(context,
                        arabic: records.isEmpty
                            ? 'لا توجد إجراءات مسجلة لهذا المشرف حتى الآن.'
                            : 'لا توجد نتائج مطابقة للبحث أو الفلتر المحدد.',
                        english: records.isEmpty
                            ? 'No activity has been recorded for this supervisor yet.'
                            : 'No results match the search or selected filter.'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ),
                for (final activity in allActivities) ...[
                  _ActivityCard(activity: activity, onDetails: () => _showActivityDetails(activity)),
                  const SizedBox(height: 10),
                ],
              ]);
            },
          ),
          const SizedBox(height: 9),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.format_list_bulleted, size: 17),
            label: Text(headSupervisorText(context, arabic: 'العودة لقائمة المشرفين', english: 'Back to supervisors')),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(_Activity activity) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(activity.title, textAlign: TextAlign.right, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            Text('${activity.id} • ${_activityText(context, activity.category)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Text(_activityText(context, activity.description), textAlign: TextAlign.right, style: const TextStyle(height: 1.6, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Text('${_activityText(context, activity.status)} • ${_activityText(context, activity.time)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String id;
  final String department;
  final String status;
  final String avatar;
  final Color color;
  final String email;
  final String phone;
  final String area;
  final String city;
  final String marketScope;
  const _ProfileCard({required this.name, required this.id, required this.department, required this.status, required this.avatar, required this.color, required this.email, required this.phone, required this.area, required this.city, required this.marketScope});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 10, offset: const Offset(0, 3))]),
        child: Column(children: [
          Row(children: [
            const Spacer(),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(name, softWrap: true, textAlign: TextAlign.right, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDark))), const SizedBox(width: 6), _CountBadge(label: id)]),
              const SizedBox(height: 4),
              SizedBox(width: double.infinity, child: Text(headSupervisorText(context, arabic: '$department • التقييم العام', english: '$department • Overall rating'), textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary))),
              const SizedBox(height: 5),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE3EDFF), borderRadius: BorderRadius.circular(12)), child: Text('(${status == 'نشط ميدانياً' ? headSupervisorText(context, arabic: '● نشط ميدانياً (متصل الآن)', english: '● Active in field (online now)') : _activityText(context, status)})', style: const TextStyle(fontSize: 8, color: Color(0xFF315E9A)))),
            ])),
            const SizedBox(width: 8),
            CircleAvatar(radius: 26, backgroundColor: color, child: Text(avatar, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
          if (email.isNotEmpty || phone.isNotEmpty) ...[
            const SizedBox(height: 9),
            if (email.isNotEmpty) _ContactLine(icon: Icons.mail_outline, value: email),
            if (phone.isNotEmpty) _ContactLine(icon: Icons.phone_iphone_outlined, value: phone),
          ],
          if (area.isNotEmpty || city.isNotEmpty || marketScope.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F8),
                  borderRadius: BorderRadius.circular(11)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(headSupervisorText(context,
                    arabic: 'نطاق الصلاحيات', english: 'Access scope'),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 5),
                if (area.isNotEmpty || city.isNotEmpty)
                  Text('${headSupervisorText(context, arabic: 'النطاق الجغرافي', english: 'Location')}: $area${city.isEmpty ? '' : ' • $city'}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                if (marketScope.isNotEmpty)
                  Text('${headSupervisorText(context, arabic: 'نطاق السوق', english: 'Market scope')}: $marketScope',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              ]),
            ),
          ],
        ]),
      );
}

class _ContactLine extends StatelessWidget {
  final IconData icon;
  final String value;
  const _ContactLine({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(value, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          Icon(icon, size: 13, color: const Color(0xFF42699F)),
        ]),
      );
}

class _CountBadge extends StatelessWidget {
  final String label;
  const _CountBadge({required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFE7E9EC), borderRadius: BorderRadius.circular(12)), child: Text(label, style: const TextStyle(fontSize: 8, color: AppColors.primaryDark)));
}

class _MainMetricCard extends StatelessWidget {
  final int count;
  const _MainMetricCard({required this.count});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [const Spacer(), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('$count', style: const TextStyle(fontSize: 22, height: 1, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), const SizedBox(height: 4), Text(headSupervisorText(context, arabic: 'إجمالي الإجراءات المسجلة', english: 'Total recorded actions'), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))]), const SizedBox(width: 10), const CircleAvatar(radius: 21, backgroundColor: Color(0xFFE7E9EC), child: Icon(Icons.history, color: AppColors.primaryDark, size: 21))]),
      ]));
}

class _SmallMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final String helper;
  final IconData icon;
  const _SmallMetricCard({required this.value, required this.label, required this.helper, required this.icon});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [CircleAvatar(radius: 17, backgroundColor: const Color(0xFFE7E9EC), child: Icon(icon, size: 16, color: AppColors.primaryDark)), const Spacer(), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: AppColors.primaryDark))]),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        const SizedBox(height: 4),
        Text(helper, textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, height: 1.4, color: AppColors.textSecondary)),
      ]));
}

class _Activity {
  final String id;
  final String category;
  final String title;
  final String description;
  final String status;
  final String time;
  final IconData icon;
  final String kind;
  const _Activity({required this.id, required this.category, required this.title, required this.description, required this.status, required this.time, required this.icon, required this.kind});
}

class _ActivityFilters extends StatelessWidget {
  final String selected;
  final List<_Activity> activities;
  final ValueChanged<String> onChanged;
  const _ActivityFilters({required this.selected, required this.activities, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final filters = <(String, String, String, int)>[
      ('all', 'الكل', 'All', activities.length),
      ('supervisor_management', 'إدارة المشرفين', 'Supervisor management', activities.where((item) => item.kind == 'supervisor_management').length),
      ('request', 'الطلبات', 'Requests', activities.where((item) => item.kind == 'request').length),
      ('complaint', 'الشكاوى', 'Complaints', activities.where((item) => item.kind == 'complaint').length),
      ('other', 'أخرى', 'Other', activities.where((item) => !{'supervisor_management', 'request', 'complaint'}.contains(item.kind)).length),
    ];
    return SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: Row(children: [for (final filter in filters) Padding(padding: const EdgeInsets.only(left: 5), child: ChoiceChip(label: Text('${headSupervisorText(context, arabic: filter.$2, english: filter.$3)} ${filter.$4}', style: const TextStyle(fontSize: 9)), selected: selected == filter.$1, onSelected: (_) => onChanged(filter.$1), selectedColor: AppColors.primaryDark, backgroundColor: Colors.white, labelStyle: TextStyle(color: selected == filter.$1 ? Colors.white : AppColors.textSecondary), side: BorderSide.none, visualDensity: VisualDensity.compact))]));
  }
}

class _ActivityCard extends StatelessWidget {
  final _Activity activity;
  final VoidCallback onDetails;
  const _ActivityCard({required this.activity, required this.onDetails});
  @override
  Widget build(BuildContext context) {
    final isDone = activity.status == 'مسجل';
    return Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        _StatusBadge(label: _activityText(context, activity.status), done: isDone),
        const Spacer(),
        Text(_activityText(context, activity.category), style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
        const SizedBox(width: 5),
        _CountBadge(label: activity.id),
      ]),
      const SizedBox(height: 9),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFF3F5F6), borderRadius: BorderRadius.circular(10)), child: Icon(activity.icon, size: 20, color: const Color(0xFF48658C))),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(activity.title, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), const SizedBox(height: 4), Text(_activityText(context, activity.description), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, height: 1.5, color: AppColors.textSecondary))])),
      ]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(10)), child: Row(children: [
        TextButton.icon(onPressed: onDetails, icon: const Icon(Icons.chevron_left, size: 14), label: Text(headSupervisorText(context, arabic: 'التفاصيل', english: 'Details'), style: const TextStyle(fontSize: 9)), style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
        const Spacer(),
        const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(child: Text(_activityText(context, activity.time), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))),
      ])),
    ]));
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool done;
  const _StatusBadge({required this.label, required this.done});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: done ? const Color(0xFFE9ECEF) : const Color(0xFFE1ECFF), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 6, color: done ? AppColors.primaryDark : const Color(0xFF42699F)), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))]));
}

String _activityText(BuildContext context, String text) => headSupervisorText(
      context,
      arabic: text,
      english: switch (text) {
        'توثيق تجاري' => 'Commercial verification',
        'ترويج وإعلان' => 'Promotion and advertising',
        'تحديث ضريبي' => 'Tax update',
        'مراجعة محتوى' => 'Content review',
        'منجز ومعتمد' || 'منجز ومطابق' => 'Completed and approved',
        'بانتظار الموافقة الرقابية' => 'Awaiting oversight approval',
        'نشط ميدانياً' => 'Active in field',
        'معلق لاستيفاء المستندات' => 'Pending documents',
        'مراجعة رخصة الترويج وتعديل هيكل عمولة التوصيل لصالح المتاجر بالتجزئة.' => 'Review the promotion license and adjust delivery commissions for retail stores.',
        'طلب اعتماد وثيقة ضريبية جديدة • مهلة استيفاء المستندات سارٍ (24 ساعة).' => 'Request to approve a new tax document • 24-hour document submission deadline.',
        'تدقيق ومطابقة اشتراطات الإعلان والحملة الترويجية وتأكّد سلامة الأسعار المعلنة.' => 'Verify advertising and campaign requirements and confirm the listed prices are accurate.',
        'توثيق سجل تجاري معتمد وإطلاق باقة حملة التخفيضات الكبرى.' => 'Verify the commercial registration and launch the major sale campaign package.',
        'آخر تحديث اليوم: 11:30 ص' => 'Updated today at 11:30 AM',
        'وارد منذ 45 دقيقة (أولوية مرتفعة)' => 'Received 45 minutes ago (high priority)',
        'تم إشعار المتجر آلياً' => 'Store notified automatically',
        'آخر تحديث: 04:15 م' => 'Updated at 4:15 PM',
        'تم تحديث مؤشرات الأداء.' => 'Performance metrics refreshed.',
        'يتم عرض أحدث سجل أولاً.' => 'Showing the latest record first.',
        'سيتم تجهيز تقرير PDF للسجل الكامل.' => 'The full record PDF will be prepared.',
        _ => text,
      },
    );
