import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/payments/payment_method_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_advertisement_local_store.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_supervisor_local_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/domain/repositories/merchants_repository.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_instruction_store.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_instruction.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_audit_store.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_audit_record.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

/// طابور قرارات الأدمن (محلي عبر SharedPreferences مثل بقية المخازن).
class AdminRequestStore {
  static const _storageKey = 'admin_requests_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  final LocalEventStore _events = LocalEventStore();

  Future<List<AdminRequest>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid admin request list.');
    }
    return decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid admin request.');
      }
      return AdminRequest.fromJson(value);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<AdminRequest>> getPending() async =>
      (await getAll()).where((item) => item.isPending).toList();

  Future<void> _saveAll(List<AdminRequest> items) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save admin requests.');
    revision.value++;
  }

  /// يضيف طلبًا جديدًا (لا يكرر نفس المعرّف) ويُشعر الأدمن.
  Future<void> submit(AdminRequest request) async {
    final items = await getAll();
    if (items.any((item) => item.id == request.id)) return;
    await _saveAll([request, ...items]);
    await _events.publish(LocalEvent(
      id: 'admin-req-${request.id}',
      recipient: 'admin',
      source: request.origin,
      titleAr: request.titleAr,
      titleEn: request.titleEn,
      messageAr: '${request.fromAr}: ${request.detailsAr}',
      messageEn: '${request.fromEn}: ${request.detailsEn}',
      createdAt: request.createdAt,
    ));
  }

  /// قرار الأدمن: يحفظ الحالة، ينفذ الأثر على الكيان الأصلي، ويُشعر الجهة المرسلة.
  Future<void> decide(
    String id,
    AdminRequestStatus status,
    String note,
  ) async {
    final items = await getAll();
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0 || !items[index].isPending) return;
    final decided = items[index].copyWith(
      status: status,
      decisionNote: note,
      decidedAt: DateTime.now(),
    );
    items[index] = decided;
    await _saveAll(items);
    if (decided.kind == AdminRequestKind.deletion &&
        status != AdminRequestStatus.frozen) {
      await _applyDeletion(decided);
      await markApplied(decided.id);
    }
    if (decided.kind == AdminRequestKind.escalation) {
      await _applyEscalation(decided);
      await markApplied(decided.id);
    }
    if (decided.kind == AdminRequestKind.withdrawal &&
        decided.origin == 'head' &&
        status == AdminRequestStatus.approved) {
      await _forwardHeadWithdrawalToFinance(decided);
      await markApplied(decided.id);
    }
    if (decided.kind == AdminRequestKind.bankLink &&
        decided.refId.startsWith('pm-')) {
      await PaymentMethodStore()
          .applyAdminDecision(decided.refId, status, note);
      await markApplied(decided.id);
    }
    final isEscalation = decided.kind == AdminRequestKind.escalation;
    final labelAr = switch (status) {
      AdminRequestStatus.approved => isEscalation ? 'قبول التصعيد' : 'اعتماد',
      AdminRequestStatus.frozen => isEscalation ? 'إعادة للدراسة' : 'تجميد',
      AdminRequestStatus.rejected =>
        isEscalation ? 'تأييد القرار الأصلي' : 'رفض',
      AdminRequestStatus.pending => 'مراجعة',
    };
    final labelEn = switch (status) {
      AdminRequestStatus.approved =>
        isEscalation ? 'escalation accepted' : 'approved',
      AdminRequestStatus.frozen =>
        isEscalation ? 'returned for study' : 'frozen',
      AdminRequestStatus.rejected =>
        isEscalation ? 'original decision upheld' : 'rejected',
      AdminRequestStatus.pending => 'under review',
    };
    await _events.publish(LocalEvent(
      id: 'admin-decision-${decided.id}-${decided.decidedAt!.millisecondsSinceEpoch}',
      recipient: decided.origin,
      source: 'admin',
      titleAr: 'قرار الأدمن: $labelAr',
      titleEn: 'Admin decision: $labelEn',
      messageAr: '${decided.titleAr} (${decided.refId}). $note',
      messageEn: '${decided.titleEn} (${decided.refId}). $note',
      createdAt: DateTime.now(),
    ));
  }

  /// فك تجميد طلب مجمَّد وإعادته لطابور قراراتك (اعتماد / تجميد / رفض).
  /// لا يعمل إلا على الطلبات المجمَّدة، ويُبلَّغ المرسل بإعادة فتح الطلب.
  Future<void> unfreeze(String id, {String note = ''}) async {
    final items = await getAll();
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0 || items[index].status != AdminRequestStatus.frozen) return;
    final request = items[index];
    final reopened = request.copyWith(
      status: AdminRequestStatus.pending,
      decisionNote: '',
      applied: false,
    );
    items[index] = reopened;
    await _saveAll(items);
    if (request.kind == AdminRequestKind.bankLink &&
        request.refId.startsWith('pm-')) {
      await PaymentMethodStore().reopenAfterUnfreeze(request.refId);
    }
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final suffix = note.trim().isEmpty ? '' : ' ${note.trim()}';
    await _events.publish(LocalEvent(
      id: 'admin-unfreeze-${request.id}-$stamp',
      recipient: request.origin,
      source: 'admin',
      titleAr: 'الأدمن فك تجميد الطلب',
      titleEn: 'Admin unfroze the request',
      messageAr:
          '${request.titleAr} (${request.refId}). أُعيد للمراجعة وبانتظار القرار.$suffix',
      messageEn:
          '${request.titleEn} (${request.refId}). Reopened and awaiting a decision.$suffix',
      createdAt: DateTime.now(),
    ));
  }

  Future<void> markApplied(String id) async {
    final items = await getAll();
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0 || items[index].applied) return;
    items[index] = items[index].copyWith(applied: true);
    await _saveAll(items);
  }

  /// أثر قرار الأدمن على تصعيد رئيس المشرفين:
  /// - قبول/تأييد: يُبلَّغ الحساب المُحيل (المشرف) ويُسجَّل القرار عند الرئيس.
  /// - إعادة للدراسة: تعود الحالة لطابور الرئيس بملاحظة الأدمن.
  Future<void> _applyEscalation(AdminRequest request) async {
    var actionAr = '';
    var actionEn = '';
    if (request.status == AdminRequestStatus.approved &&
        request.requestedAction.isNotEmpty) {
      (actionAr, actionEn) = await _runRequestedAction(request);
    }
    final now = DateTime.now();
    final stamp = now.microsecondsSinceEpoch;
    final (titleAr, titleEn, outcomeAr, outcomeEn) = switch (request.status) {
      AdminRequestStatus.approved => (
          'الأدمن قبل التصعيد',
          'Admin accepted the escalation',
          'قبل الأدمن التصعيد ونُفّذ طلب رئيس المشرفين',
          'The admin accepted the escalation and the head supervisor request is carried out',
        ),
      AdminRequestStatus.rejected => (
          'الأدمن أيّد القرار الأصلي',
          'Admin upheld the original decision',
          'أيّد الأدمن القرار الأصلي ولا يلزم إجراء إضافي',
          'The admin upheld the original decision; no further action is needed',
        ),
      _ => (
          'أُعيدت الحالة للدراسة',
          'Case returned for study',
          'أعاد الأدمن الحالة للدراسة',
          'The admin returned the case for study',
        ),
    };
    final liftedAr = actionAr;
    final liftedEn = actionEn;
    final note = request.decisionNote.isEmpty ? '' : ' ${request.decisionNote}';
    await HeadSupervisorAuditStore().record(
      HeadSupervisorAuditRecord(
        id: 'admin-escalation-${request.id}-$stamp',
        subjectId: request.refId,
        kind: 'request',
        title: titleAr,
        details: '$outcomeAr (${request.refId}).$liftedAr$note',
        department: 'التصعيدات',
        occurredAt: now,
      ),
    );
    if (request.sourceAccount.isNotEmpty) {
      await _events.publish(LocalEvent(
        id: 'admin-escalation-source-${request.id}-$stamp',
        recipient: request.sourceAccount,
        source: 'admin',
        titleAr: titleAr,
        titleEn: titleEn,
        messageAr: '${request.titleAr} (${request.refId}). $outcomeAr.$liftedAr$note',
        messageEn: '${request.titleEn} (${request.refId}). $outcomeEn.$liftedEn$note',
        createdAt: now,
      ));
    }
    if (request.status == AdminRequestStatus.frozen) {
      // تعود الحالة لطابور رئيس المشرفين كطلب جديد بملاحظة الأدمن.
      await _events.publish(LocalEvent(
        id: 'admin-return-${request.id}-$stamp',
        recipient: 'head',
        source: request.sourceAccount.isEmpty ? 'admin' : request.sourceAccount,
        titleAr: request.titleAr,
        titleEn: request.titleEn,
        messageAr:
            'أعاد الأدمن الطلب ${request.refId} للدراسة.$note ${request.detailsAr}',
        messageEn:
            'The admin returned request ${request.refId} for study.$note ${request.detailsEn}',
        createdAt: now,
      ));
    }
  }

  /// يفك الحجب/الإخفاء عن إعلانات التاجر المطابق للكود. يعيد عدد الإعلانات.
  /// ينفّذ الإجراء المطلوب مع التصعيد ويرجع وصفه (عربي، إنجليزي) للإشعار والسجل.
  /// الصيغ: liftAdBlock | suspendMerchant | compensateMerchant:<مبلغ> | refundCustomer:<مبلغ>
  Future<(String, String)> _runRequestedAction(AdminRequest request) async {
    final parts = request.requestedAction.split(':');
    final action = parts.first;
    final amount = parts.length > 1 ? double.tryParse(parts[1]) : null;
    switch (action) {
      case 'liftAdBlock':
        final lifted = await _liftAdBlocks(request.targetRef);
        return lifted > 0
            ? (' أُعيد بث $lifted إعلان.', ' $lifted ad(s) restored.')
            : ('', '');
      case 'suspendMerchant':
        final merchant = await _findMerchant(request.targetRef);
        if (merchant == null) {
          return (
            ' تعذر إيقاف التاجر تلقائيًا (لم يُعثر عليه).',
            ' The merchant could not be suspended automatically (not found).'
          );
        }
        try {
          await MerchantSupervisorLocalStore.setMerchantSuspended(
            merchantId: merchant.id,
            merchantName: merchant.name,
            isSuspended: true,
            action: 'إيقاف التاجر بقرار الأدمن',
            details: '${request.titleAr} (${request.refId}). ${request.decisionNote}',
          );
          return (' أُوقف التاجر ${merchant.name}.', ' Merchant ${merchant.nameEn} was suspended.');
        } catch (error, stackTrace) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'suspend merchant',
          ));
          return (' تعذر إيقاف التاجر.', ' Could not suspend the merchant.');
        }
      case 'compensateMerchant':
      case 'refundCustomer':
        if (amount == null || amount <= 0) {
          return ('', '');
        }
        final isRefund = action == 'refundCustomer';
        final value = amount.toStringAsFixed(0);
        final now = DateTime.now();
        await FinanceInstructionStore().add(FinanceInstruction(
          id: 'instruction-${request.id}',
          kind: isRefund
              ? FinanceInstructionKind.refund
              : FinanceInstructionKind.compensation,
          amount: amount,
          reference: request.refId,
          title: request.titleAr,
          adminNote: request.decisionNote,
          createdAt: now,
        ));
        await _events.publish(LocalEvent(
          id: 'admin-fin-instruction-${request.id}-${now.microsecondsSinceEpoch}',
          recipient: 'finance',
          source: 'admin',
          titleAr: isRefund ? 'تعليمات الأدمن: استرداد للعميل' : 'تعليمات الأدمن: تعويض التاجر',
          titleEn: isRefund ? 'Admin instruction: customer refund' : 'Admin instruction: merchant compensation',
          messageAr:
              '${isRefund ? 'نفّذ استرداد' : 'نفّذ تعويض'} بقيمة $value ج.م. المرجع ${request.refId} — ${request.titleAr}. ${request.decisionNote}',
          messageEn:
              '${isRefund ? 'Execute a refund' : 'Execute a compensation'} of EGP $value. Ref ${request.refId} — ${request.titleEn}. ${request.decisionNote}',
          createdAt: now,
        ));
        return (
          isRefund
              ? ' أُرسلت للمالية تعليمات استرداد $value ج.م.'
              : ' أُرسلت للمالية تعليمات تعويض $value ج.م.',
          isRefund
              ? ' Refund instruction of EGP $value sent to finance.'
              : ' Compensation instruction of EGP $value sent to finance.',
        );
      default:
        return ('', '');
    }
  }

  Future<MerchantEntity?> _findMerchant(String merchantCode) async {
    final digits = merchantCode.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    try {
      final merchants = await sl<MerchantsRepository>().getMerchants();
      for (final merchant in merchants) {
        if ((merchant.code ?? '').replaceAll(RegExp(r'\D'), '') == digits) {
          return merchant;
        }
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'find merchant',
      ));
    }
    return null;
  }

  Future<int> _liftAdBlocks(String merchantCode) async {
    final digits = RegExp(r'\d+').allMatches(merchantCode).map((m) => m.group(0)).join();
    if (digits.isEmpty) return 0;
    try {
      final merchants = await sl<MerchantsRepository>().getMerchants();
      await MerchantAdvertisementLocalStore.ensureLoaded();
      var lifted = 0;
      for (final merchant in merchants) {
        final code = (merchant.code ?? '').replaceAll(RegExp(r'\D'), '');
        if (code != digits) continue;
        for (final ad in merchant.recentAdvertisements) {
          final current = MerchantAdvertisementLocalStore.statusFor(
              ad.reference, ad.status);
          if (current == MerchantAdvertisementStatus.frozen ||
              current == MerchantAdvertisementStatus.hidden) {
            await MerchantAdvertisementLocalStore.saveStatus(
              reference: ad.reference,
              status: MerchantAdvertisementStatus.approved,
            );
            lifted++;
          }
        }
      }
      return lifted;
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'lift ad blocks',
      ));
      return 0;
    }
  }

  /// سحب رئيس المشرفين: بعد اعتماد الأدمن يصل للمالية للتنفيذ.
  Future<void> _forwardHeadWithdrawalToFinance(AdminRequest request) async {
    final now = DateTime.now();
    await HeadSupervisorAuditStore().record(
      HeadSupervisorAuditRecord(
        id: 'admin-head-withdrawal-${request.id}-${now.microsecondsSinceEpoch}',
        subjectId: request.refId,
        kind: 'wallet',
        title: 'اعتماد الأدمن لسحب يتجاوز السقف',
        details: '${request.detailsAr} ${request.decisionNote}',
        department: 'المحفظة',
        occurredAt: now,
      ),
    );
    await _events.publish(LocalEvent(
      id: 'head-wallet-approved-${request.id}',
      recipient: 'finance',
      source: 'head',
      titleAr: 'طلب سحب معتمد من الأدمن',
      titleEn: 'Admin-approved withdrawal request',
      messageAr: request.detailsAr,
      messageEn: request.detailsEn,
      createdAt: now,
    ));
  }

  Future<void> _applyDeletion(AdminRequest request) async {
    final roster = HeadSupervisorRosterStore();
    final supervisors = await roster.getAll();
    final index = supervisors.indexWhere((item) => item.id == request.refId);
    if (index < 0) return;
    final supervisor = supervisors[index];
    final approved = request.status == AdminRequestStatus.approved;
    if (approved) {
      supervisors.removeAt(index);
    } else {
      supervisors[index] = supervisor.copyWith(
        deletionPending: false,
        deletionRequestId: '',
        deletionReason: '',
        deletionNotes: '',
      );
    }
    await roster.saveAll(supervisors);
    final now = DateTime.now();
    await HeadSupervisorAuditStore().record(
      HeadSupervisorAuditRecord(
        id: 'admin-deletion-${request.id}-${now.microsecondsSinceEpoch}',
        subjectId: supervisor.id,
        kind: 'supervisor_management',
        title: approved ? 'اعتماد حذف مشرف' : 'رفض حذف مشرف',
        details: 'المنفذ: الأدمن. ${supervisor.name}. ${request.decisionNote}',
        department: supervisor.department,
        occurredAt: now,
      ),
    );
  }
}

/// يرفع طلبًا اعتمده المشرف المالي إلى طابور الأدمن للمصادقة النهائية.
/// لا يرمي أخطاء: فشل الإرسال يُسجَّل فقط حتى لا يعطل شاشة المالية.
Future<void> forwardFinanceRequestToAdmin({
  required AdminRequestKind kind,
  required String refId,
  required String titleAr,
  required String titleEn,
  required String detailsAr,
  required String detailsEn,
  double? amount,
}) async {
  try {
    await AdminRequestStore().submit(AdminRequest(
      id: '${kind.name}-$refId',
      kind: kind,
      titleAr: titleAr,
      titleEn: titleEn,
      detailsAr: detailsAr,
      detailsEn: detailsEn,
      fromAr: 'المشرف المالي',
      fromEn: 'Finance supervisor',
      origin: 'finance',
      refId: refId,
      amount: amount,
      createdAt: DateTime.now(),
      // مهلة قرار الأدمن: بعدها يظهر الطلب متأخرًا في الأدمن وفي مكتب المالية.
      deadline: DateTime.now().add(const Duration(hours: 48)),
    ));
  } catch (error, stackTrace) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'forward to admin',
    ));
  }
}
