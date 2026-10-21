import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/product_supervisor_audit_entry.dart';
import '../../domain/repositories/product_supervisor_audit_repository.dart';

enum _ComplaintStatus { newCase, inProgress, waitingCustomer, resolved, archived }

class _ProductComplaint {
  final String id;
  final String customerId;
  final String customerAr;
  final String customerEn;
  final String subjectAr;
  final String subjectEn;
  final String productAr;
  final String productEn;
  final String? latestMessage;
  final DateTime updatedAt;
  final _ComplaintStatus status;

  const _ProductComplaint({
    required this.id,
    required this.customerId,
    required this.customerAr,
    required this.customerEn,
    required this.subjectAr,
    required this.subjectEn,
    required this.productAr,
    required this.productEn,
    required this.status,
    required this.updatedAt,
    this.latestMessage,
  });

  _ProductComplaint copyWith({
    _ComplaintStatus? status,
    DateTime? updatedAt,
    String? latestMessage,
  }) =>
      _ProductComplaint(
        id: id,
        customerId: customerId,
        customerAr: customerAr,
        customerEn: customerEn,
        subjectAr: subjectAr,
        subjectEn: subjectEn,
        productAr: productAr,
        productEn: productEn,
        status: status ?? this.status,
        updatedAt: updatedAt ?? this.updatedAt,
        latestMessage: latestMessage ?? this.latestMessage,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerAr': customerAr,
        'customerEn': customerEn,
        'subjectAr': subjectAr,
        'subjectEn': subjectEn,
        'productAr': productAr,
        'productEn': productEn,
        'status': status.name,
        'updatedAt': updatedAt.toIso8601String(),
        'latestMessage': latestMessage,
      };

  factory _ProductComplaint.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String? ?? 'newCase';
    return _ProductComplaint(
      id: json['id'] as String,
      customerId: json['customerId'] as String? ?? json['id'] as String,
      customerAr: json['customerAr'] as String? ?? json['customer'] as String? ?? '',
      customerEn: json['customerEn'] as String? ?? json['customer'] as String? ?? '',
      subjectAr: json['subjectAr'] as String? ?? json['subject'] as String? ?? '',
      subjectEn: json['subjectEn'] as String? ?? json['subject'] as String? ?? '',
      productAr: json['productAr'] as String? ?? json['product'] as String? ?? '',
      productEn: json['productEn'] as String? ?? json['product'] as String? ?? '',
      status: _ComplaintStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => _ComplaintStatus.newCase,
      ),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      latestMessage: json['latestMessage'] as String?,
    );
  }
}

class ProductSupervisorComplaintsScreen extends StatefulWidget {
  const ProductSupervisorComplaintsScreen({super.key});

  @override
  State<ProductSupervisorComplaintsScreen> createState() =>
      _ProductSupervisorComplaintsScreenState();
}

class _ProductSupervisorComplaintsScreenState
    extends State<ProductSupervisorComplaintsScreen> {
  static const _storageKey = 'product_supervisor_complaints_v1';
  final TextEditingController _searchController = TextEditingController();
  final List<_ProductComplaint> _complaints = [
    _ProductComplaint(
      id: 'C-201',
      customerId: 'buyer-C-201',
      customerAr: 'أحمد محمد',
      customerEn: 'Ahmed Mohamed',
      subjectAr: 'تأخر استلام المنتج',
      subjectEn: 'Product delivery delay',
      productAr: 'ساعة ذكية',
      productEn: 'Smart watch',
      status: _ComplaintStatus.newCase,
      updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    _ProductComplaint(
      id: 'C-202',
      customerId: 'buyer-C-202',
      customerAr: 'سارة علي',
      customerEn: 'Sarah Ali',
      subjectAr: 'شكوى عامة عن المتجر',
      subjectEn: 'General store complaint',
      productAr: 'شكوى عامة',
      productEn: 'General complaint',
      status: _ComplaintStatus.inProgress,
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];
  _ComplaintStatus? _statusFilter;
  bool _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        final decoded = jsonDecode(saved);
        if (decoded is! List) {
          throw const FormatException('Saved product complaints must be a list.');
        }
        final restored = decoded.map((value) {
          if (value is! Map<String, dynamic> || value['id'] is! String) {
            throw const FormatException('Saved product complaint is invalid.');
          }
          return _ProductComplaint.fromJson(value);
        }).toList();
        _complaints
          ..clear()
          ..addAll(restored);
      }
      if (mounted) {
        setState(() {
        _isLoading = false;
        _loadError = null;
      });
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'product supervisor complaints',
      ));
      if (mounted) {
        setState(() {
        _isLoading = false;
        _loadError = error;
      });
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(
      _storageKey,
      jsonEncode(_complaints.map((item) => item.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save product complaints.');
  }

  String _copy(bool isArabic, String ar, String en) => isArabic ? ar : en;

  List<_ProductComplaint> _visibleComplaints(bool isArabic) {
    final query = _searchController.text.trim().toLowerCase();
    return _complaints.where((complaint) {
      final matchesStatus = _statusFilter == null || complaint.status == _statusFilter;
      final searchable = [
        complaint.id,
        complaint.customerAr,
        complaint.customerEn,
        complaint.subjectAr,
        complaint.subjectEn,
        complaint.productAr,
        complaint.productEn,
      ].join(' ').toLowerCase();
      final matchesSearch = query.isEmpty || searchable.contains(query);
      return matchesStatus && matchesSearch;
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _changeStatus(
    _ProductComplaint complaint,
    _ComplaintStatus status,
    bool isArabic,
  ) async {
    final index = _complaints.indexOf(complaint);
    if (index < 0) return;
    final previous = complaint;
    final updated = complaint.copyWith(status: status, updatedAt: DateTime.now());
    setState(() => _complaints[index] = updated);
    try {
      await _save();
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'product complaint status persistence',
      ));
      if (!mounted) return;
      setState(() => _complaints[index] = previous);
      _message(_copy(isArabic, 'تعذر حفظ التغيير.', 'Could not save the change.'));
      return;
    }
    try {
      await _recordAudit(
        updated,
        'complaint_${status.name}',
        _statusLabel(status, isArabic),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'product complaint audit recording',
      ));
    }
    if (mounted) {
      _message(
      _copy(isArabic, 'تم تحديث حالة الشكوى.', 'Complaint status updated.'),
    );
    }
  }

  Future<void> _sendCustomerMessage(
    _ProductComplaint complaint,
    bool isArabic,
  ) async {
    final controller = TextEditingController();
    try {
      final message = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_copy(isArabic, 'إرسال رسالة للعميل', 'Message customer')),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: _copy(isArabic, 'اكتب الرسالة', 'Write a message'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_copy(isArabic, 'إلغاء', 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) Navigator.pop(dialogContext, value);
              },
              child: Text(_copy(isArabic, 'إرسال', 'Send')),
            ),
          ],
        ),
      );
      if (message == null || !mounted) return;
      final index = _complaints.indexOf(complaint);
      if (index < 0) return;
      final previous = complaint;
      final updated = complaint.copyWith(
        status: _ComplaintStatus.waitingCustomer,
        updatedAt: DateTime.now(),
        latestMessage: message,
      );
      setState(() => _complaints[index] = updated);
      await _save();
      await _recordAudit(updated, 'complaint_message_queued', message);
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
          id: 'product-complaint-message-${complaint.id}-${updated.updatedAt.microsecondsSinceEpoch}',
          recipient: complaint.customerId,
          source: 'products',
          titleAr: 'رسالة بخصوص شكواك',
          titleEn: 'Message about your complaint',
          messageAr: '${complaint.id}: $message',
          messageEn: '${complaint.id}: $message',
          createdAt: updated.updatedAt,
        ),
      );
      if (mounted) {
        _message(_copy(
        isArabic,
        'حُفظت الرسالة في صندوق التنبيهات المحلي.',
        'Message saved to the local notification inbox.',
      ));
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'product complaint customer message',
      ));
      if (mounted) {
        _message(_copy(
        isArabic,
        'تعذر حفظ الرسالة أو إرسال التنبيه المحلي.',
        'Could not save the message or local notice.',
      ));
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _escalate(_ProductComplaint complaint, bool isArabic) async {
    try {
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
          id: 'product-complaint-escalated-${complaint.id}',
          recipient: 'head',
          source: 'products',
          titleAr: 'تصعيد شكوى من مشرف المنتجات',
          titleEn: 'Product complaint escalated',
          messageAr: '${complaint.id} · ${complaint.subjectAr}',
          messageEn: '${complaint.id} · ${complaint.subjectEn}',
          createdAt: DateTime.now(),
        ),
      );
      await _recordAudit(complaint, 'complaint_escalated', 'head');
      if (mounted) {
        _message(_copy(
        isArabic,
        'تم حفظ التصعيد وإشعار الرئيس محليًا.',
        'Escalation and local notice saved.',
      ));
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'product complaint escalation',
      ));
      if (mounted) _message(_copy(isArabic, 'تعذر حفظ التصعيد.', 'Could not save escalation.'));
    }
  }

  Future<void> _recordAudit(
    _ProductComplaint complaint,
    String actionKey,
    String details,
  ) => sl<ProductSupervisorAuditRepository>().recordEntry(
        ProductSupervisorAuditEntry(
          id: 'complaint-${complaint.id}-${DateTime.now().microsecondsSinceEpoch}',
          actionKey: actionKey,
          subject: complaint.id,
          details: '${complaint.customerAr}: $details',
          occurredAt: DateTime.now(),
        ),
      );

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  String _statusLabel(_ComplaintStatus status, bool isArabic) => switch (status) {
        _ComplaintStatus.newCase => _copy(isArabic, 'جديدة', 'New'),
        _ComplaintStatus.inProgress => _copy(isArabic, 'قيد المتابعة', 'In progress'),
        _ComplaintStatus.waitingCustomer => _copy(isArabic, 'بانتظار العميل', 'Waiting for customer'),
        _ComplaintStatus.resolved => _copy(isArabic, 'تم الحل', 'Resolved'),
        _ComplaintStatus.archived => _copy(isArabic, 'الأرشيف', 'Archived'),
      };

  Color _statusColor(_ComplaintStatus status) => switch (status) {
        _ComplaintStatus.newCase => AppColors.infoDark,
        _ComplaintStatus.inProgress => AppColors.warningDark,
        _ComplaintStatus.waitingCustomer => AppColors.info,
        _ComplaintStatus.resolved || _ComplaintStatus.archived => AppColors.successDark,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final visible = _visibleComplaints(isArabic);
    final filters = <({String label, _ComplaintStatus? value})>[
      (label: _copy(isArabic, 'الكل', 'All'), value: null),
      (label: _statusLabel(_ComplaintStatus.newCase, isArabic), value: _ComplaintStatus.newCase),
      (label: _statusLabel(_ComplaintStatus.inProgress, isArabic), value: _ComplaintStatus.inProgress),
      (label: _statusLabel(_ComplaintStatus.waitingCustomer, isArabic), value: _ComplaintStatus.waitingCustomer),
      (label: _statusLabel(_ComplaintStatus.resolved, isArabic), value: _ComplaintStatus.resolved),
      (label: _statusLabel(_ComplaintStatus.archived, isArabic), value: _ComplaintStatus.archived),
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_copy(isArabic, 'شكاوى العملاء', 'Customer complaints')),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_copy(isArabic, 'تعذر تحميل الشكاوى.', 'Could not load complaints.')),
                        const SizedBox(height: 10),
                        FilledButton(onPressed: _load, child: Text(_copy(isArabic, 'إعادة المحاولة', 'Retry'))),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: _copy(isArabic, 'ابحث برقم الشكوى أو العميل أو المنتج', 'Search complaint, customer, or product'),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: _copy(isArabic, 'مسح البحث', 'Clear search'),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final filter in filters)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(end: 7),
                                child: ChoiceChip(
                                  label: Text('${filter.label} (${_complaints.where((item) => filter.value == null || item.status == filter.value).length})'),
                                  selected: _statusFilter == filter.value,
                                  onSelected: (_) => setState(() => _statusFilter = filter.value),
                                  selectedColor: AppColors.primaryDark,
                                  labelStyle: TextStyle(color: _statusFilter == filter.value ? Colors.white : AppColors.textSecondary),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: AppColors.cardBorder),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (visible.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Text(_copy(isArabic, 'لا توجد شكاوى مطابقة.', 'No complaints match these filters.'), textAlign: TextAlign.center),
                        )
                      else
                        for (final complaint in visible) ...[
                          Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text('${complaint.id} · ${isArabic ? complaint.customerAr : complaint.customerEn}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                      Chip(label: Text(_statusLabel(complaint.status, isArabic)), labelStyle: TextStyle(color: _statusColor(complaint.status), fontSize: 11), visualDensity: VisualDensity.compact, side: BorderSide.none, backgroundColor: _statusColor(complaint.status).withValues(alpha: .09)),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text('${isArabic ? complaint.subjectAr : complaint.subjectEn} · ${isArabic ? complaint.productAr : complaint.productEn}'),
                                  if (complaint.latestMessage?.isNotEmpty == true) ...[
                                    const SizedBox(height: 6),
                                    Text('${_copy(isArabic, 'آخر رسالة:', 'Latest message:')} ${complaint.latestMessage}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ],
                                  const SizedBox(height: 7),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    children: [
                                      if (complaint.status != _ComplaintStatus.archived) ...[
                                        TextButton(onPressed: () => _changeStatus(complaint, _ComplaintStatus.inProgress, isArabic), child: Text(_copy(isArabic, 'متابعة', 'Investigate'))),
                                        TextButton(onPressed: () => _changeStatus(complaint, _ComplaintStatus.waitingCustomer, isArabic), child: Text(_copy(isArabic, 'بانتظار العميل', 'Wait for customer'))),
                                        TextButton(onPressed: () => _changeStatus(complaint, _ComplaintStatus.resolved, isArabic), child: Text(_copy(isArabic, 'حل الشكوى', 'Resolve'))),
                                        TextButton(onPressed: () => _sendCustomerMessage(complaint, isArabic), child: Text(_copy(isArabic, 'إرسال رسالة', 'Message'))),
                                        TextButton(onPressed: () => _escalate(complaint, isArabic), child: Text(_copy(isArabic, 'تصعيد', 'Escalate'))),
                                        TextButton(onPressed: () => _changeStatus(complaint, _ComplaintStatus.archived, isArabic), child: Text(_copy(isArabic, 'أرشفة', 'Archive'))),
                                      ] else
                                        TextButton(onPressed: () => _changeStatus(complaint, _ComplaintStatus.newCase, isArabic), child: Text(_copy(isArabic, 'استعادة', 'Restore'))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                        ],
                    ],
                  ),
      ),
    );
  }
}
