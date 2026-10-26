import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_complaint.dart';

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
