import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/local_event_inbox_screen.dart';
import '../../data/head_supervisor_audit_store.dart';
import 'head_supervisor_broadcast_sheet.dart';
import 'head_supervisor_wallet_screen.dart';

const _sampleAuditEntries = [
  _AuditEntry(
    icon: Icons.cancel_outlined,
    color: Color(0xFFB91C1C),
    title: 'تعليق إعلان تجاري وإحالة للتحقيق',
    details: 'تم توجيه الإجراء العاجل بحق مشرف القطاع الشرقي وإحالته للتحقيق الإداري.',
    time: 'اليوم 11:20 ص',
    code: '#CMP-SUP-104',
    action: 'خصم حسابي مثبت',
  ),
  _AuditEntry(
    icon: Icons.gavel_outlined,
    color: Color(0xFF315F9A),
    title: 'حسم نزاع تسليم كاميرا كانون',
    details: 'قرار نهائي: إلزام البائع برد كامل المبلغ للمشتري بعد ثبوت التلف.',
    time: 'اليوم 09:15 ص',
    code: '#WAS-5510',
    action: 'إلزام فوري',
  ),
  _AuditEntry(
    icon: Icons.swap_horiz,
    color: Color(0xFF52606D),
    title: 'اعتماد إعادة إسناد طلب صيانة',
    details: 'الموافقة على تحويل طلب تكييف وتبريد حي الياسمين إلى مزود معتمد بديل.',
    time: 'أمس 04:30 م',
    code: '#SRV-3042',
    action: 'الرياض',
  ),
  _AuditEntry(
    icon: Icons.warning_amber_outlined,
    color: Color(0xFF68727D),
    title: 'لفت نظر إداري رسمي',
    details: 'توجيه إداري للمشرف لفحص المنتجات الجديدة وعدم التأخر في مراجعتها.',
    time: 'أمس 02:10 م',
    code: '#SUP-108',
    action: 'إشعار سري',
  ),
];

const _sampleAuditEntriesEnglish = [
  _AuditEntry(icon: Icons.cancel_outlined, color: Color(0xFFB91C1C), title: 'Commercial ad suspended and referred for investigation', details: 'Urgent action was taken against the East Sector supervisor and referred for administrative investigation.', time: 'Today 11:20 AM', code: '#CMP-SUP-104', action: 'Account deduction recorded'),
  _AuditEntry(icon: Icons.gavel_outlined, color: Color(0xFF315F9A), title: 'Camera delivery dispute resolved', details: 'Final decision: seller must issue a full refund after damage was confirmed.', time: 'Today 09:15 AM', code: '#WAS-5510', action: 'Immediate enforcement'),
  _AuditEntry(icon: Icons.swap_horiz, color: Color(0xFF52606D), title: 'Maintenance request reassignment approved', details: 'Approved transfer of the Yasmin District cooling request to an alternative provider.', time: 'Yesterday 04:30 PM', code: '#SRV-3042', action: 'Riyadh'),
  _AuditEntry(icon: Icons.warning_amber_outlined, color: Color(0xFF68727D), title: 'Official administrative warning', details: 'Supervisor instructed to inspect new products and complete reviews on time.', time: 'Yesterday 02:10 PM', code: '#SUP-108', action: 'Confidential notice'),
];

String _profileText(BuildContext context, String arabic, String english) =>
    arabic;

class HeadSupervisorProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HeadSupervisorProfileScreen({super.key, required this.onLogout});

  @override
  State<HeadSupervisorProfileScreen> createState() =>
      _HeadSupervisorProfileScreenState();
}

class _HeadSupervisorProfileScreenState extends State<HeadSupervisorProfileScreen> {
  List<HeadSupervisorAuditRecord> _records = const [];

  @override
  void initState() {
    super.initState();
    HeadSupervisorAuditStore.revision.addListener(_loadAuditRecords);
    _loadAuditRecords();
  }

  @override
  void dispose() {
    HeadSupervisorAuditStore.revision.removeListener(_loadAuditRecords);
    super.dispose();
  }

  Future<void> _loadAuditRecords() async {
    try {
      final records = await HeadSupervisorAuditStore().getRecent(limit: 20);
      if (!mounted) return;
      setState(() => _records = records);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor profile audit',
      ));
    }
  }

  List<_AuditEntry> get _auditEntries {
    if (_records.isEmpty) {
      return _sampleAuditEntries;
    }
    return [
      for (final record in _records)
        _AuditEntry(
          icon: switch (record.kind) {
            'request' => Icons.gavel_outlined,
            'summon' => Icons.person_search_outlined,
            'wallet' => Icons.account_balance_wallet_outlined,
            'broadcast' => Icons.campaign_outlined,
            _ => Icons.policy_outlined,
          },
          color: record.kind == 'complaint'
              ? const Color(0xFFB91C1C)
              : const Color(0xFF315F9A),
          title: record.title,
          details: record.details,
          time: _auditTime(record.occurredAt),
          code: '#${record.subjectId}',
          action: record.department,
        ),
    ];
  }

  String _auditTime(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    if (local.year == now.year && local.month == now.month && local.day == now.day) {
      return 'اليوم $time';
    }
    return '${local.day}/${local.month} $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        title: Text(_profileText(context, 'رئيس المشرفين', 'Head Supervisor'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: _profileText(context, 'الإشعارات', 'Notifications'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LocalEventInboxScreen(
                  recipient: 'head',
                  title: _profileText(context, 'الإشعارات', 'Notifications'),
                ),
              ),
            ),
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _SessionBanner(),
          const SizedBox(height: 14),
          _ProfileCard(onEdit: () => _showEditProfile(context)),
          const SizedBox(height: 10),
          _BroadcastNoticeCard(onTap: () => _openBroadcast(context)),
          const SizedBox(height: 14),
          _WalletCard(onOpen: () => _showWallet(context)),
          const SizedBox(height: 18),
          _SectionHeading(
              title: _profileText(context, 'مؤشرات الرقابة والامتثال', 'Oversight & Compliance'),
              subtitle: _profileText(context, 'خلال 30 يوماً', 'Last 30 days')),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _MetricCard(value: '18', label: _profileText(context, 'مشرفاً تحت الإدارة', 'Supervisors managed'), icon: Icons.groups_outlined)),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(value: '98.4%', label: _profileText(context, 'معيار الحوكمة', 'Governance score'), icon: Icons.verified_outlined, valueColor: const Color(0xFF315F9A))),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(value: '342', label: _profileText(context, 'تدخل رقابي معتمد', 'Approved interventions'), icon: Icons.gavel_outlined)),
          ]),
          const SizedBox(height: 14),
          _AuditCard(
            entries: _auditEntries,
            totalCount: _records.isEmpty ? 142 : _records.length,
            onViewAll: () => _showAudit(context),
          ),
          const SizedBox(height: 14),
          const _SecurityCard(),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, widget.onLogout),
              icon: const Icon(Icons.logout, color: Color(0xFFB91C1C), size: 18),
              label: Text(_profileText(context, 'إنهاء الجلسة الإدارية وإغلاق التطبيق', 'End the admin session and sign out'),
                  style: const TextStyle(
                      color: const Color(0xFFB91C1C),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFE9EAEC),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _showEditProfile(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_profileText(context, 'بيانات رئيس المشرفين', 'Head Supervisor account')),
        content: Text(_profileText(context, 'لتعديل بيانات الحساب، تواصل مع مسؤول النظام.', 'To update account details, contact the system administrator.')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(_profileText(context, 'حسناً', 'OK')))],
      ),
    );
  }

  static Future<void> _showWallet(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const HeadSupervisorWalletScreen(),
      ),
    );
  }

  Future<void> _openBroadcast(BuildContext context) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HeadSupervisorBroadcastSheet(),
    );
    if (!mounted || sent != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_profileText(context, 'تم إرسال الإشعار وتسجيله في السجل الرقابي.', 'The notice was sent and recorded in the audit log.'))),
    );
  }

  Future<void> _showAudit(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .72,
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
            Text(_profileText(context, 'السجل الرقابي والإداري', 'Oversight & Administration Log'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._auditEntries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _AuditEntryTile(entry: entry))),
            Text(_profileText(context, 'إجمالي القرارات المسجلة: ${_records.isEmpty ? 142 : _records.length}', 'Total recorded decisions: ${_records.isEmpty ? 142 : _records.length}'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }

  static Future<void> _confirmLogout(BuildContext context, VoidCallback onLogout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_profileText(context, 'إنهاء الجلسة؟', 'End session?')),
        content: Text(_profileText(context, 'سيتم تسجيل الخروج من حساب رئيس المشرفين.', 'You will be signed out of the Head Supervisor account.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_profileText(context, 'إلغاء', 'Cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(_profileText(context, 'تسجيل الخروج', 'Sign out'))),
        ],
      ),
    );
    if (confirmed == true) onLogout();
  }
}

class _SessionBanner extends StatelessWidget {
  const _SessionBanner();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const _Tag(text: 'SUP-HEAD-01', icon: Icons.shield_outlined),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_profileText(context, 'جلسة نفاذ الوطني موثقة', 'Verified national access session'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(_profileText(context, 'الرقابة الإدارية النشطة • تشفير قياسي', 'Active administration • Standard encryption'), style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          ]),
          const SizedBox(width: 8),
          const CircleAvatar(radius: 14, backgroundColor: Color(0xFFDCE4EC), child: Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF315F9A))),
        ]),
      );
}

class _BroadcastNoticeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _BroadcastNoticeCard({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE7EBEF)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.campaign_outlined, color: Color(0xFF315F9A), size: 21),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_profileText(context, 'إشعار المشرفين', 'Supervisor announcement'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                Text(_profileText(context, 'أرسل توجيهاً لجميع المشرفين أو لمشرف محدد', 'Send guidance to all supervisors or a selected supervisor'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              ])),
              const SizedBox(width: 7),
              const Icon(Icons.arrow_back_ios_new, size: 13, color: AppColors.textSecondary),
            ]),
          ),
        ),
      );
}

class _ProfileCard extends StatelessWidget {
  final VoidCallback onEdit;
  const _ProfileCard({required this.onEdit});

  @override
  Widget build(BuildContext context) => _WhiteCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 18), style: IconButton.styleFrom(backgroundColor: const Color(0xFFF0F2F4))),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(children: [Text(_profileText(context, 'عادل الشمري', 'Adel Alshammari'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), const SizedBox(width: 4), const Icon(Icons.verified, color: Color(0xFF315F9A), size: 15)]),
              Text(_profileText(context, 'رئيس هيئة المشرفين والرقابة الميدانية', 'Head of Supervisors & Field Oversight'), style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              Text(_profileText(context, '4.9 ★  (1,280 تقييم امتثال)', '4.9 ★  (1,280 compliance ratings)'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            ]),
            const SizedBox(width: 8),
            const _Avatar(),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _ProfileInfo(icon: Icons.mail_outline, text: 'adel.alshammari@almazouri.sa', tag: _profileText(context, 'رسمي', 'Official')),
              const SizedBox(height: 8),
              _ProfileInfo(icon: Icons.phone_iphone, text: '+966 50 ••• 8821', tag: _profileText(context, 'نفاذ موثق', 'Verified')),
              const SizedBox(height: 8),
              _ProfileInfo(icon: Icons.location_city_outlined, text: _profileText(context, 'نطاق الإشراف: الرياض، الغربية، الشرقية، الشمالي (4 قطاعات)', 'Coverage: Riyadh, West, East and North (4 sectors)')),
            ]),
          ),
          const SizedBox(height: 10),
          Text(_profileText(context, 'الصلاحيات التنفيذية السيادية:', 'Executive authorities:'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(alignment: WrapAlignment.end, spacing: 5, runSpacing: 5, children: [
            _PermissionChip(text: _profileText(context, 'فك الحظر والإلغاء (Override)', 'Override restrictions'), icon: Icons.history),
            _PermissionChip(text: _profileText(context, 'التحقيق الإداري الإلزامي', 'Mandatory administrative investigation'), icon: Icons.policy_outlined),
            _PermissionChip(text: _profileText(context, 'التدخل المالي المشروط', 'Conditional financial intervention'), icon: Icons.account_balance_outlined),
          ]),
        ]),
      );
}

class _WalletCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _WalletCard({required this.onOpen});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(15)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            _Tag(text: _profileText(context, 'سارية المفعول', 'Active'), icon: Icons.verified_outlined, light: true),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_profileText(context, 'محفظة البدلات ومستحقات الإشراف', 'Supervisor Allowances Wallet'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(width: 8),
            const CircleAvatar(radius: 15, backgroundColor: Color(0xFF294B75), child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 17)),
          ]),
          const SizedBox(height: 16),
          Text(_profileText(context, 'الرصيد الحالي المتاح للمشرف الرئاسي', 'Available balance'), textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF9DB4D0), fontSize: 9)),
          const SizedBox(height: 4),
          Text(_profileText(context, '45,800.00 ر.س', 'SAR 45,800.00'), textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _WalletAmount(label: _profileText(context, 'معلق تحت الإقفال الدوري', 'Pending settlement'), value: '7,800.00'),
            _WalletAmount(label: _profileText(context, 'جاهز للصرف الفوري', 'Available to withdraw'), value: '38,000.00'),
          ]),
          const SizedBox(height: 16),
          SizedBox(height: 42, child: FilledButton.icon(onPressed: onOpen, icon: const Icon(Icons.account_balance_wallet_outlined, size: 17), label: Text(_profileText(context, 'فتح المحفظة وإدارة السحب المالي', 'Open wallet and manage withdrawals'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9CC3FF), foregroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
        ]),
      );
}

class _AuditCard extends StatelessWidget {
  final List<_AuditEntry> entries;
  final int totalCount;
  final VoidCallback onViewAll;
  const _AuditCard({required this.entries, required this.totalCount, required this.onViewAll});

  @override
  Widget build(BuildContext context) => _WhiteCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [_Tag(text: _profileText(context, 'مشفر', 'Encrypted')), const Spacer(), Text(_profileText(context, 'السجل الرقابي والإداري الأخير', 'Recent oversight log'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)), const SizedBox(width: 6), const Icon(Icons.receipt_long_outlined, size: 17, color: Color(0xFF315F9A))]),
          const SizedBox(height: 10),
          for (final entry in entries.take(4)) ...[
            _AuditEntryTile(entry: entry),
            const SizedBox(height: 7),
          ],
          SizedBox(height: 34, child: TextButton.icon(onPressed: onViewAll, icon: const Icon(Icons.arrow_back, size: 15), label: Text(_profileText(context, 'عرض كامل السجل الإداري والقرارات ($totalCount قرار)', 'View all administrative decisions ($totalCount)'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), style: TextButton.styleFrom(backgroundColor: const Color(0xFFE9ECEF), foregroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))))),
        ]),
      );
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();

  @override
  Widget build(BuildContext context) => _WhiteCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(_profileText(context, 'الأمان وصلاحيات النظام', 'Security & System Access'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 10),
          _SecurityRow(icon: Icons.shield_outlined, title: _profileText(context, 'المصادقة الثنائية التلقائية (2FA)', 'Two-factor authentication (2FA)'), subtitle: _profileText(context, 'مفعلة تلقائياً عبر النفاذ الموحد', 'Enabled through unified access'), status: _profileText(context, 'نشطة', 'Active')),
          const SizedBox(height: 7),
          _SecurityRow(icon: Icons.devices_outlined, title: _profileText(context, 'الجلسات المفتوحة والمصرحة', 'Active authorized sessions'), subtitle: _profileText(context, 'جهازك الحالي (iPad Pro) • الرياض', 'Current device (iPad Pro) • Riyadh'), status: '1 device'),
          const SizedBox(height: 7),
          _SecurityRow(icon: Icons.campaign_outlined, title: _profileText(context, 'إشعارات البلاغات العاجلة', 'Urgent report notifications'), subtitle: _profileText(context, 'تنبيهات فورية عند التجاوز الرقابي', 'Instant alerts for oversight violations'), status: _profileText(context, 'مفعلة', 'Enabled')),
        ]),
      );
}

class _SecurityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  const _SecurityRow({required this.icon, required this.title, required this.subtitle, required this.status});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(11)),
        child: Row(children: [
          _Tag(text: status),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.primaryDark)), Text(subtitle, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))]),
          const SizedBox(width: 8),
          CircleAvatar(radius: 15, backgroundColor: const Color(0xFFE1E5E8), child: Icon(icon, size: 16, color: AppColors.primaryDark)),
        ]),
      );
}

class _AuditEntry {
  final IconData icon;
  final Color color;
  final String title;
  final String details;
  final String time;
  final String code;
  final String action;
  const _AuditEntry({required this.icon, required this.color, required this.title, required this.details, required this.time, required this.code, required this.action});
}

class _AuditEntryTile extends StatelessWidget {
  final _AuditEntry entry;
  const _AuditEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(11)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 14, backgroundColor: entry.color.withValues(alpha: .12), child: Icon(entry.icon, size: 16, color: entry.color)),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(entry.time, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)), Flexible(child: Text(entry.title, textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark)))]),
            const SizedBox(height: 4),
            Text(entry.details, textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, height: 1.4, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(entry.action, style: const TextStyle(fontSize: 8, color: Color(0xFF315F9A))), const SizedBox(width: 9), _Tag(text: entry.code)]),
          ])),
        ]),
      );
}

class _ProfileInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? tag;
  const _ProfileInfo({required this.icon, required this.text, this.tag});

  @override
  Widget build(BuildContext context) => Row(children: [
        if (tag != null) _Tag(text: tag!),
        const Spacer(),
        Flexible(child: Text(text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary))),
        const SizedBox(width: 5),
        Icon(icon, size: 14, color: const Color(0xFF315F9A)),
      ]);
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color valueColor;
  const _MetricCard({required this.value, required this.label, required this.icon, this.valueColor = AppColors.primaryDark});

  @override
  Widget build(BuildContext context) => _WhiteCard(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        child: Column(children: [
          CircleAvatar(radius: 15, backgroundColor: const Color(0xFFF0F2F4), child: Icon(icon, size: 16, color: valueColor)),
          const SizedBox(height: 7),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
        ]),
      );
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Row(children: [Text(subtitle, style: const TextStyle(fontSize: 8, color: Color(0xFF315F9A))), const Spacer(), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark))]);
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _WhiteCard({required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE8EBEF))),
        child: child,
      );
}

class _Tag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool light;
  const _Tag({required this.text, this.icon, this.light = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: light ? const Color(0xFF294B75) : const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(9)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text, style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: light ? Colors.white : AppColors.textSecondary)),
          if (icon != null) ...[const SizedBox(width: 3), Icon(icon, size: 11, color: light ? Colors.white : const Color(0xFF315F9A))],
        ]),
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) => Container(
        width: 54,
        height: 58,
        decoration: BoxDecoration(color: const Color(0xFFDCE4EC), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.person, color: Color(0xFF315F9A), size: 30),
      );
}

class _PermissionChip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _PermissionChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: const Color(0xFFF0F2F4), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Text(text, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: AppColors.primaryDark)), const SizedBox(width: 3), Icon(icon, size: 11, color: const Color(0xFF315F9A))]),
      );
}

class _WalletAmount extends StatelessWidget {
  final String label;
  final String value;
  const _WalletAmount({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF9DB4D0))), Text('$value ر.س', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))]);
}

