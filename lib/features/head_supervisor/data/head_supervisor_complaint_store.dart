import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeadSupervisorComplaintAction {
  final String title;
  final String detail;
  final int iconCodePoint;
  final bool summon;
  final bool unblockInvestigation;

  const HeadSupervisorComplaintAction({
    required this.title,
    required this.detail,
    required this.iconCodePoint,
    this.summon = false,
    this.unblockInvestigation = false,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Map<String, Object?> toJson() => {
        'title': title,
        'detail': detail,
        'iconCodePoint': iconCodePoint,
        'summon': summon,
        'unblockInvestigation': unblockInvestigation,
      };

  factory HeadSupervisorComplaintAction.fromJson(Map<String, dynamic> json) =>
      HeadSupervisorComplaintAction(
        title: json['title'] as String,
        detail: json['detail'] as String,
        iconCodePoint: (json['iconCodePoint'] as num).toInt(),
        summon: json['summon'] as bool? ?? false,
        unblockInvestigation: json['unblockInvestigation'] as bool? ?? false,
      );
}

class HeadSupervisorComplaint {
  final String id;
  final String status;
  final String statusLabel;
  final String title;
  final String description;
  final String merchant;
  final String merchantCode;
  final String supervisor;
  final String supervisorCode;
  final String department;
  final String recipient;
  final String evidence;
  final String urgency;
  final bool warning;
  final DateTime createdAt;
  final List<HeadSupervisorComplaintAction> actions;
  final bool reopenedForReview;
  final String assignedSupervisorId;
  final String assignedSupervisorName;

  const HeadSupervisorComplaint({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.title,
    required this.description,
    required this.merchant,
    required this.merchantCode,
    required this.supervisor,
    required this.supervisorCode,
    required this.department,
    required this.recipient,
    required this.evidence,
    required this.urgency,
    required this.warning,
    required this.createdAt,
    required this.actions,
    this.reopenedForReview = false,
    this.assignedSupervisorId = '',
    this.assignedSupervisorName = '',
  });

  HeadSupervisorComplaint copyWith({
    String? statusLabel,
    bool? reopenedForReview,
    String? assignedSupervisorId,
    String? assignedSupervisorName,
  }) =>
      HeadSupervisorComplaint(
        id: id,
        status: status,
        statusLabel: statusLabel ?? this.statusLabel,
        title: title,
        description: description,
        merchant: merchant,
        merchantCode: merchantCode,
        supervisor: supervisor,
        supervisorCode: supervisorCode,
        department: department,
        recipient: recipient,
        evidence: evidence,
        urgency: urgency,
        warning: warning,
        createdAt: createdAt,
        actions: actions,
        reopenedForReview: reopenedForReview ?? this.reopenedForReview,
        assignedSupervisorId: assignedSupervisorId ?? this.assignedSupervisorId,
        assignedSupervisorName: assignedSupervisorName ?? this.assignedSupervisorName,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'status': status,
        'statusLabel': statusLabel,
        'title': title,
        'description': description,
        'merchant': merchant,
        'merchantCode': merchantCode,
        'supervisor': supervisor,
        'supervisorCode': supervisorCode,
        'department': department,
        'recipient': recipient,
        'evidence': evidence,
        'urgency': urgency,
        'warning': warning,
        'createdAt': createdAt.toIso8601String(),
        'actions': actions.map((action) => action.toJson()).toList(),
        'reopenedForReview': reopenedForReview,
        'assignedSupervisorId': assignedSupervisorId,
        'assignedSupervisorName': assignedSupervisorName,
      };

  factory HeadSupervisorComplaint.fromJson(Map<String, dynamic> json) {
    final actions = json['actions'];
    if (actions is! List<dynamic>) {
      throw const FormatException('Invalid head supervisor complaint actions.');
    }
    return HeadSupervisorComplaint(
      id: json['id'] as String,
      status: json['status'] as String,
      statusLabel: json['statusLabel'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      merchant: json['merchant'] as String,
      merchantCode: json['merchantCode'] as String,
      supervisor: json['supervisor'] as String,
      supervisorCode: json['supervisorCode'] as String,
      department: json['department'] as String,
      recipient: json['recipient'] as String,
      evidence: json['evidence'] as String,
      urgency: json['urgency'] as String,
      warning: json['warning'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      actions: actions.map((value) {
        if (value is! Map<String, dynamic>) {
          throw const FormatException('Invalid head supervisor complaint action.');
        }
        return HeadSupervisorComplaintAction.fromJson(value);
      }).toList(),
      reopenedForReview: json['reopenedForReview'] as bool? ?? false,
      assignedSupervisorId: json['assignedSupervisorId'] as String? ?? '',
      assignedSupervisorName: json['assignedSupervisorName'] as String? ?? '',
    );
  }
}

class HeadSupervisorComplaintStore {
  static const _storageKey = 'head_supervisor_complaints_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static final seedComplaints = <HeadSupervisorComplaint>[
    HeadSupervisorComplaint(
      id: 'CMP-SUP-104',
      status: 'تعسف في حجب الإعلانات',
      statusLabel: 'قيد المراجعة والتحقيق',
      title: 'تعليق إعلان تجاري بدعوى مخالفة التسعير دون توجيه إنذار مسبق أو مراجعة السجل التجاري المعتمد',
      description: 'تقدم التاجر بطلب تظلم رسمي ضد إجراء المشرف الميداني، حيث تم تعليق الحملة الترويجية لمنتجات السيارات خلال عطلة الأسبوع دون فحص التفويضات المرفقة بالنظام.',
      merchant: 'متجر الأفق للسيارات والتجارة',
      merchantCode: 'TRD-8821',
      supervisor: 'أ. سعد العتيبي',
      supervisorCode: 'SUP-409',
      department: 'مشرف التجار',
      recipient: 'merchant',
      evidence: 'صورة ترخيص التخفيضات من وزارة التجارة',
      urgency: 'قرار موقوف ميدانياً',
      warning: false,
      createdAt: DateTime(2026, 10, 19),
      actions: [
        HeadSupervisorComplaintAction(
          title: 'إلغاء حظر الإعلان والتحقيق مع المشرف',
          detail: 'إعادة الإعلان للمراجعة وطلب مسوغات قرار الحجب من المشرف.',
          iconCodePoint: Icons.fact_check_outlined.codePoint,
          unblockInvestigation: true,
        ),
        HeadSupervisorComplaintAction(
          title: 'استدعاء المشرف للتوضيح',
          detail: 'إرسال طلب إفادة رسمية للمشرف وتوثيق رده في سجل التحقيق.',
          iconCodePoint: Icons.person_search_outlined.codePoint,
          summon: true,
        ),
      ],
    ),
    HeadSupervisorComplaint(
      id: 'CMP-SUP-109',
      status: 'تأخير غير مبرر في المعالجة',
      statusLabel: 'تجاوز مهلة 24 ساعة',
      title: 'تأخر فحص وتوثيق (14) إعلاناً جديداً لأكثر من 72 ساعة مما تسبب في أضرار تجارية لموسم العروض',
      description: 'إيداع التاجر مستندات تثبت خسارة آلاف المبيعات المؤكدة بسبب تعطيل الحملات التجارية من قبل المشرف الميداني المسؤول عن النطاق.',
      merchant: 'مؤسسة مدار التقنية',
      merchantCode: 'TRD-5501',
      supervisor: 'م. فهد الزهراني',
      supervisorCode: 'SUP-108',
      department: 'مشرف الخدمات الميدانية',
      recipient: 'services',
      evidence: 'سجل التأخير وتقرير المبيعات المرفق',
      urgency: 'ملاحظة التزام النظام',
      warning: true,
      createdAt: DateTime(2026, 10, 20),
      actions: [
        HeadSupervisorComplaintAction(
          title: 'سحب الإعلانات وإسنادها لمشرف آخر فوراً',
          detail: 'تحويل مراجعة الإعلانات المتأخرة إلى مشرف بديل وإشعار التاجر.',
          iconCodePoint: Icons.swap_horiz.codePoint,
        ),
        HeadSupervisorComplaintAction(
          title: 'توجيه تنبيه إداري ولفت نظر للمشرف',
          detail: 'تسجيل التأخير في سجل أداء المشرف وطلب إفادة حول أسباب التعطيل.',
          iconCodePoint: Icons.notification_important_outlined.codePoint,
        ),
      ],
    ),
  ];

  Future<List<HeadSupervisorComplaint>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) {
      await saveAll(seedComplaints);
      return List.unmodifiable(seedComplaints);
    }
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid head supervisor complaint list.');
    }
    final complaints = decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid head supervisor complaint.');
      }
      return HeadSupervisorComplaint.fromJson(value);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(complaints);
  }

  Future<void> add(HeadSupervisorComplaint complaint) async {
    final complaints = (await getAll()).toList();
    if (complaints.any((item) => item.id == complaint.id)) {
      throw StateError('A complaint with this ID already exists.');
    }
    complaints.insert(0, complaint);
    await saveAll(complaints);
  }

  Future<void> saveAll(List<HeadSupervisorComplaint> complaints) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(complaints.map((complaint) => complaint.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save head supervisor complaints.');
    revision.value++;
  }
}
