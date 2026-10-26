import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:barwah_app/features/finance/data/models/bank_account_model.dart';
import 'package:barwah_app/features/finance/data/models/finance_summary_model.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_edit_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_link_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/department_wallet_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/subscription_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';

int _financialRequestSequence = 0;

String _newFinancialRequestId(String prefix, String timestamp) =>
    '$prefix-$timestamp-${_financialRequestSequence++}';

class FinanceMockDataSource implements FinanceRemoteDataSource {
  final List<BankAccountEditRequestEntity> _bankAccountEditRequests = [];
  final List<ExpenseRequestEntity> _expenseRequests = [];
  bool _expenseRequestsLoaded = false;
  List<WithdrawalRequestEntity>? _merchantWithdrawalRequests;
  List<WithdrawalRequestEntity>? _supervisorWithdrawalRequests;
  List<SubscriptionRequestEntity>? _subscriptionRequests;
  bool _supervisorRequestsLoaded = false;
  bool _merchantRequestsLoaded = false;
  static const _supervisorRequestsStorageKey =
      'finance_supervisor_operations_v1';
  static const _merchantRequestsStorageKey = 'finance_merchant_withdrawals_v1';
  static const _subscriptionDecisionsStorageKey =
      'finance_subscription_decisions_v1';
  static const _expenseRequestsStorageKey = 'finance_expense_requests_v1';
  final List<BankLinkRequestEntity> _bankLinkRequests = [
    const BankLinkRequestEntity(
      id: '#TRD-5501',
      commercialName: 'مؤسسة التجارة المتقدمة المحدودة',
      beneficiaryName: 'مؤسسة التجارة المتقدمة للخدمات والتوكيلات',
      iban: 'SA44 8000 0123 6080 1012 3456',
      bankName: 'مصرف الراجحي',
      crNumber: '1010892341',
      crExpiry: '1448/04/15هـ',
      documentName: 'doc-iban-5501.pdf',
      amlScore: '100%',
      requestType: 'طلب ربط وتوثيق حساب تجاري جديد',
      matchDescription: 'تطابق الاسم التجاري والبنكي موثق بنسبة 100%',
      commercialNameEn: 'Advanced Trading Establishment Ltd.',
      beneficiaryNameEn: 'Advanced Trading Est. for Services & Agencies',
      bankNameEn: 'Al Rajhi Bank',
      crExpiryEn: '1448/04/15 AH',
      requestTypeEn: 'New Commercial Account Link & Verification Request',
      matchDescriptionEn:
          '100% Verified match between commercial and bank name',
    ),
    const BankLinkRequestEntity(
      id: '#TRD-6022',
      commercialName: 'شركة مدار الرواد للمقاولات العامة',
      beneficiaryName: 'شركة مدار الرواد للتجارة والمقاولات ش.ش.و',
      iban: 'SA03 8000 0456 9910 2233 4455',
      bankName: 'البنك الأهلي السعودي (SNB)',
      crNumber: '1010994523',
      crExpiry: '1447/11/20هـ',
      documentName: 'doc-iban-6022.pdf',
      amlScore: '96%',
      requestType: 'طلب ربط حساب مورد معتمد',
      matchDescription: 'اختلاف طفيف في اللواحق القانونية للاسم التجاري',
      warningNote: 'تم رصد اختلاف بين لاحقة السجل والحساب البنكي',
      commercialNameEn: 'Madar Al-Ruwad General Contracting Co.',
      beneficiaryNameEn: 'Madar Al-Ruwad Trading & Contracting LLC',
      bankNameEn: 'Saudi National Bank (SNB)',
      crExpiryEn: '1447/11/20 AH',
      requestTypeEn: 'Approved Supplier Account Link Request',
      matchDescriptionEn:
          'Minor variance in legal suffixes of the commercial name',
      warningNoteEn:
          'Variance detected between CR suffix and bank account name',
    ),
    const BankLinkRequestEntity(
      id: '#TRD-7108',
      commercialName: 'مؤسسة القمة الرقمية لتقنية المعلومات',
      beneficiaryName: 'فهد سليمان عبد الله العتيبي',
      iban: 'SA12 1000 0987 5544 3322 1100',
      bankName: 'بنك الرياض',
      crNumber: '1010778899',
      crExpiry: '1448/01/10هـ',
      documentName: 'doc-iban-7108.pdf',
      amlScore: '89%',
      requestType: 'طلب ربط حساب مزود خدمة مستقل',
      matchDescription: 'مؤسسة فردية تتطلب شهادة آيبان حديثة مختومة',
      warningNote: 'شهادة الآيبان المرفقة تعود لأكثر من 6 أشهر',
      commercialNameEn: 'Digital Summit IT Establishment',
      beneficiaryNameEn: 'Fahad Sulaiman Abdullah Al-Otaibi',
      bankNameEn: 'Riyad Bank',
      crExpiryEn: '1448/01/10 AH',
      requestTypeEn: 'Freelance Service Provider Account Link Request',
      matchDescriptionEn:
          'Sole proprietorship requires a recent stamped IBAN certificate',
      warningNoteEn: 'Attached IBAN certificate is older than 6 months',
    ),
  ];
  int _nextBankAccountEditRequestId = 0;

  // القائمة المركزية الموحدة للحسابات البنكية والقنوات الرسمية
  final List<BankAccountModel> _mockBankAccounts = [
    const BankAccountModel(
      id: 'acc_01',
      bankName: 'مصرف الراجحي',
      accountRole: 'الحساب التشغيلي الرئيسي للرواتب والموردين',
      accountType: 'حساب تشغيلي',
      iban: 'SA44 8000 0213 6080 1000 9991',
      balance: 3120400.00,
      isVerified: true,
    ),
    const BankAccountModel(
      id: 'acc_02',
      bankName: 'البنك الأهلي السعودي (SNB)',
      accountRole: 'حساب الضمان المستقل لعربون «وصلني» والتجار',
      accountType: 'حساب ضمان Escrow',
      iban: 'SA98 1000 0055 4433 2211 0003',
      balance: 1450000.00,
      isVerified: true,
    ),
    const BankAccountModel(
      id: 'acc_03',
      bankName: 'بنك الرياض',
      accountRole: 'حساب عمليات الصيانة والتشغيل السريع',
      accountType: 'حساب تشغيلي',
      iban: 'SA12 2000 0001 2345 6789 0002',
      balance: 424800.00,
      isVerified: true,
    ),
    const BankAccountModel(
      id: 'acc_04',
      bankName: 'بوابة سداد و مدى (Mada Gateway)',
      accountRole: 'الرصيد المعلق بانتظار التسوية البنكية اليومية',
      accountType: 'بوابة دفع إلكتروني',
      iban: 'Gateway MID: 88401920-EGP',
      balance: 290000.00,
      isVerified: true,
    ),
    const BankAccountModel(
      id: 'acc_05',
      bankName: 'محفظة STC Pay المركزية',
      accountRole: 'تحويلات الكاش باك والسحب السريع للفنيين',
      accountType: 'محفظة رقمية',
      iban: 'Enterprise Wallet: 0500011223',
      balance: 100000.00,
      isVerified: true,
    ),
  ];

  @override
  Future<FinanceSummaryModel> getFinanceSummary() async {
    // حساب إجمالي السيولة ديناميكياً بجمع كافة أرصدة الحسابات
    final double calculatedTotalLiquidity = _mockBankAccounts.fold(
      0.0,
      (sum, account) => sum + account.balance,
    );

    final double rajhiBalance = _mockBankAccounts
        .firstWhere(
          (a) => a.bankName.contains('الراجحي'),
          orElse: () => _mockBankAccounts.first,
        )
        .balance;

    final double snbBalance = _mockBankAccounts
        .firstWhere(
          (a) => a.bankName.contains('الأهلي'),
          orElse: () => _mockBankAccounts.first,
        )
        .balance;

    // استدعاء الطلبات الحقيقية من الموك لحساب الأرقام الديناميكية
    final merchantRequests = await getMerchantWithdrawals();
    final supervisorRequests = await getSupervisorWithdrawals();
    final subscriptions = await getSubscriptions();

    final pendingAndFrozenMerchants = merchantRequests
        .where((req) =>
            req.status == RequestStatus.pending ||
            req.status == RequestStatus.underInvestigation)
        .toList();
    final int merchantCount = pendingAndFrozenMerchants.length;
    final double merchantAmount =
        pendingAndFrozenMerchants.fold(0.0, (sum, req) => sum + req.netAmount);

    final pendingAndFrozenSupervisors = supervisorRequests
        .where((req) =>
            req.status == RequestStatus.pending ||
            req.status == RequestStatus.underInvestigation)
        .toList();
    final int supervisorCount = pendingAndFrozenSupervisors.length;
    final double supervisorAmount = pendingAndFrozenSupervisors.fold(
        0.0, (sum, req) => sum + req.netAmount);

    final pendingSubscriptions = subscriptions
        .where((req) => req.reviewDecision == null)
        .toList(growable: false);
    final int subsCount = pendingSubscriptions.length;
    final double subsAmount =
        pendingSubscriptions.fold(0.0, (sum, req) => sum + req.totalAmount);

    // مصروفات الشهر الحالي = المصروفات المعتمدة فعليًا من الأدمن هذا الشهر.
    final expenses = await getExpenseRequests();
    final now = DateTime.now();
    final double monthlyExpensesTotal = expenses
        .where((e) =>
            e.status == ExpenseRequestStatus.approved &&
            e.submittedAt.year == now.year &&
            e.submittedAt.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);

    return FinanceSummaryModel(
      totalLiquidity: calculatedTotalLiquidity,
      rajhiAccountBalance: rajhiBalance,
      snbEscrowBalance: snbBalance,
      pendingMerchantWithdrawalsCount: merchantCount,
      pendingMerchantWithdrawalsAmount: merchantAmount,
      pendingSupervisorWithdrawalsCount: supervisorCount,
      pendingSupervisorWithdrawalsAmount: supervisorAmount,
      pendingSubscriptionsCount: subsCount,
      pendingSubscriptionsAmount: subsAmount,
      monthlyExpenses: monthlyExpensesTotal,
      monthlyCommissions: 142650.00,
    );
  }

  @override
  Future<List<BankAccountModel>> getBankAccounts() async {
    return _mockBankAccounts;
  }

  @override
  Future<List<BankAccountEditRequestEntity>>
      getBankAccountEditRequests() async {
    return List.unmodifiable(_bankAccountEditRequests);
  }

  @override
  Future<BankAccountEditRequestEntity> submitBankAccountEditRequest({
    required String accountId,
    required String proposedBankName,
    required String proposedAccountType,
    required String proposedIban,
  }) async {
    final accountIndex =
        _mockBankAccounts.indexWhere((account) => account.id == accountId);
    if (accountIndex == -1) {
      throw ArgumentError.value(
          accountId, 'accountId', 'Bank account not found');
    }

    if (_bankAccountEditRequests.any(
      (request) =>
          request.accountId == accountId &&
          request.status == BankAccountEditRequestStatus.pending,
    )) {
      throw StateError('An edit request is already pending for this account.');
    }

    final currentAccount = _mockBankAccounts[accountIndex];
    final bankName = proposedBankName.trim();
    final accountType = proposedAccountType.trim();
    final iban = proposedIban.trim();
    if (bankName.isEmpty || accountType.isEmpty || iban.isEmpty) {
      throw ArgumentError('Bank name, account type, and IBAN are required.');
    }
    if (bankName == currentAccount.bankName &&
        accountType == currentAccount.accountType &&
        iban == currentAccount.iban) {
      throw ArgumentError('At least one bank account field must be changed.');
    }

    final request = BankAccountEditRequestEntity(
      id: 'bank-edit-${++_nextBankAccountEditRequestId}',
      accountId: currentAccount.id,
      bankName: currentAccount.bankName,
      accountType: currentAccount.accountType,
      iban: currentAccount.iban,
      proposedBankName: bankName,
      proposedAccountType: accountType,
      proposedIban: iban,
      submittedAt: DateTime.now(),
    );
    _bankAccountEditRequests.add(request);
    return request;
  }

  @override
  Future<List<ExpenseRequestEntity>> getExpenseRequests() async {
    if (!_expenseRequestsLoaded) {
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.reload();
        final stored = preferences.getString(_expenseRequestsStorageKey);
        if (stored != null) {
          final decoded = jsonDecode(stored);
          if (decoded is! List) {
            throw const FormatException('Stored expense requests are invalid.');
          }
          _expenseRequests
            ..clear()
            ..addAll(decoded.map((value) {
              if (value is! Map<String, dynamic>) {
                throw const FormatException(
                    'Stored expense request is invalid.');
              }
              return _expenseRequestFromJson(value);
            }));
        }
      } on MissingPluginException {
        // Keep the mock source usable in unit tests without platform channels.
      }
      _expenseRequestsLoaded = true;
    }
    return List.unmodifiable(_expenseRequests);
  }

  @override
  Future<ExpenseRequestEntity> submitExpenseRequest({
    required double amount,
    required String bankAccountId,
    required String reason,
    String category = 'other',
    String beneficiaryName = '',
    String? attachmentName,
    String? attachmentPath,
  }) async {
    await getExpenseRequests();
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Amount must be greater than zero.');
    }
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'Expense reason is required.');
    }

    final accountIndex =
        _mockBankAccounts.indexWhere((account) => account.id == bankAccountId);
    if (accountIndex == -1) {
      throw ArgumentError.value(
          bankAccountId, 'bankAccountId', 'Bank account not found.');
    }
    final account = _mockBankAccounts[accountIndex];
    if (amount > account.balance) {
      throw ArgumentError.value(
          amount, 'amount', 'Amount exceeds the account balance.');
    }

    final normalizedAttachment = attachmentName?.trim();
    final request = ExpenseRequestEntity(
      id: 'expense-${DateTime.now().microsecondsSinceEpoch}',
      amount: amount,
      bankAccountId: account.id,
      bankName: account.bankName,
      reason: normalizedReason,
      category: category.trim().isEmpty ? 'other' : category.trim(),
      beneficiaryName: beneficiaryName.trim(),
      attachmentName:
          normalizedAttachment == null || normalizedAttachment.isEmpty
              ? null
              : normalizedAttachment,
      attachmentPath: attachmentPath,
      submittedAt: DateTime.now(),
    );
    _expenseRequests.add(request);
    try {
      await _persistExpenseRequests();
    } catch (_) {
      _expenseRequests.remove(request);
      rethrow;
    }
    return request;
  }

  @override
  Future<void> updateExpenseRequestStatus({
    required String requestId,
    required ExpenseRequestStatus status,
    String? reason,
  }) async {
    await getExpenseRequests();
    final index =
        _expenseRequests.indexWhere((request) => request.id == requestId);
    if (index < 0) {
      throw ArgumentError.value(
          requestId, 'requestId', 'Expense request not found.');
    }
    final current = _expenseRequests[index];
    if (current.status != ExpenseRequestStatus.pendingAdminApproval) {
      throw StateError('Only pending expense requests can be updated.');
    }
    final normalizedReason = reason?.trim();
    if ((status == ExpenseRequestStatus.rejected ||
            status == ExpenseRequestStatus.cancelled) &&
        (normalizedReason == null || normalizedReason.isEmpty)) {
      throw ArgumentError.value(
          reason, 'reason', 'A reason is required for this action.');
    }
    _expenseRequests[index] = current.copyWith(
      status: status,
      decisionReason: normalizedReason,
      clearDecisionReason: normalizedReason == null,
    );
    try {
      await _persistExpenseRequests();
    } catch (_) {
      _expenseRequests[index] = current;
      rethrow;
    }
  }

  @override
  Future<ExpenseRequestEntity> editExpenseRequest({
    required String requestId,
    required double amount,
    required String bankAccountId,
    required String reason,
    required String category,
    required String beneficiaryName,
    String? attachmentName,
    String? attachmentPath,
  }) async {
    await getExpenseRequests();
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Amount must be greater than zero.');
    }
    if (reason.trim().isEmpty || beneficiaryName.trim().isEmpty) {
      throw ArgumentError('Reason and beneficiary are required.');
    }
    final accountIndex =
        _mockBankAccounts.indexWhere((account) => account.id == bankAccountId);
    if (accountIndex < 0) {
      throw ArgumentError.value(
          bankAccountId, 'bankAccountId', 'Bank account not found.');
    }
    final index =
        _expenseRequests.indexWhere((request) => request.id == requestId);
    if (index < 0) {
      throw ArgumentError.value(
          requestId, 'requestId', 'Expense request not found.');
    }
    final current = _expenseRequests[index];
    if (current.status != ExpenseRequestStatus.pendingAdminApproval) {
      throw StateError('Only pending expense requests can be edited.');
    }
    if (amount > _mockBankAccounts[accountIndex].balance) {
      throw ArgumentError.value(
          amount, 'amount', 'Amount exceeds the account balance.');
    }
    final updated = current.copyWith(
      amount: amount,
      bankAccountId: bankAccountId,
      bankName: _mockBankAccounts[accountIndex].bankName,
      reason: reason.trim(),
      category: category.trim().isEmpty ? 'other' : category.trim(),
      beneficiaryName: beneficiaryName.trim(),
      attachmentName: attachmentName,
      attachmentPath: attachmentPath,
      clearAttachment: attachmentName == null,
    );
    _expenseRequests[index] = updated;
    try {
      await _persistExpenseRequests();
    } catch (_) {
      _expenseRequests[index] = current;
      rethrow;
    }
    return updated;
  }

  Future<void> _persistExpenseRequests() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _expenseRequests.map(_expenseRequestToJson).toList(growable: false),
      );
      final saved =
          await preferences.setString(_expenseRequestsStorageKey, encoded);
      if (!saved) {
        await preferences.reload();
        if (preferences.getString(_expenseRequestsStorageKey) != encoded) {
          throw StateError('Could not save expense requests.');
        }
      }
    } on MissingPluginException {
      // In-memory behavior is retained for test environments without plugins.
    }
  }

  Map<String, Object?> _expenseRequestToJson(ExpenseRequestEntity request) => {
        'id': request.id,
        'amount': request.amount,
        'bankAccountId': request.bankAccountId,
        'bankName': request.bankName,
        'reason': request.reason,
        'category': request.category,
        'beneficiaryName': request.beneficiaryName,
        'attachmentName': request.attachmentName,
        'attachmentPath': request.attachmentPath,
        'submittedAt': request.submittedAt.toIso8601String(),
        'status': request.status.name,
        'decisionReason': request.decisionReason,
      };

  ExpenseRequestEntity _expenseRequestFromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String? ??
        ExpenseRequestStatus.pendingAdminApproval.name;
    return ExpenseRequestEntity(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      bankAccountId: json['bankAccountId'] as String,
      bankName: json['bankName'] as String,
      reason: json['reason'] as String,
      category: json['category'] as String? ?? 'other',
      beneficiaryName: json['beneficiaryName'] as String? ?? '',
      attachmentName: json['attachmentName'] as String?,
      attachmentPath: json['attachmentPath'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      status: ExpenseRequestStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => ExpenseRequestStatus.pendingAdminApproval,
      ),
      decisionReason: json['decisionReason'] as String?,
    );
  }

  @override
  Future<DepartmentWalletEntity> getDepartmentWallet(
      DepartmentType type) async {
    return switch (type) {
      DepartmentType.merchants => const DepartmentWalletEntity(
          type: DepartmentType.merchants,
          totalBalance: 2150000,
          primaryMetricCount: 142,
          pendingMetricCount: 8,
          pendingMetricAmount: 94500,
          feeValue: '4.5%',
          items: [
            DepartmentWalletItemEntity(
              title: 'مؤسسة الأفق للتقنية والتجارة',
              reference: 'السجل التجاري 101089234   #TRD-9041',
              availableBalance: 412800,
              pendingBalance: 12500,
              operationsCount: 1842,
              channel: DepartmentWalletChannel.instantSettlement,
              status: DepartmentWalletStatus.activeMatched,
            ),
            DepartmentWalletItemEntity(
              title: 'متجر الصفوة الذهبي',
              reference: 'السجل التجاري 1010459810   #TRD-8820',
              availableBalance: 325400,
              pendingBalance: 24000,
              operationsCount: 965,
              channel: DepartmentWalletChannel.alRajhiMainOperating,
              status: DepartmentWalletStatus.activeMatched,
            ),
            DepartmentWalletItemEntity(
              title: 'مجوهرات البريق الراقية',
              reference: 'السجل التجاري 1010334992   #TRD-7104',
              availableBalance: 184200,
              pendingBalance: 58000,
              operationsCount: 420,
              channel: DepartmentWalletChannel.scheduledPayment,
              status: DepartmentWalletStatus.activeMatched,
            ),
            DepartmentWalletItemEntity(
              title: 'دار النخبة للأجهزة',
              reference: 'السجل التجاري 1010198421   #TRD-6519',
              availableBalance: 98600,
              pendingBalance: 0,
              operationsCount: 312,
              channel: DepartmentWalletChannel.snbEscrow,
              status: DepartmentWalletStatus.activeMatched,
            ),
          ],
        ),
      DepartmentType.usedEscrow => const DepartmentWalletEntity(
          type: DepartmentType.usedEscrow,
          totalBalance: 980000,
          primaryMetricCount: 85,
          pendingMetricCount: 3,
          pendingMetricAmount: 12400,
          feeValue: '1.5%',
          items: [
            DepartmentWalletItemEntity(
              title: 'سيارة تويوتا كامري 2020',
              reference: 'عربون الصفقة #ESC-1092',
              availableBalance: 5000,
              pendingBalance: 0,
              operationsCount: 1,
              channel: DepartmentWalletChannel.underInspection,
              status: DepartmentWalletStatus.protectedEscrow,
            ),
            DepartmentWalletItemEntity(
              title: 'آيفون 14 برو ماكس',
              reference: 'عربون الصفقة #ESC-3321',
              availableBalance: 500,
              pendingBalance: 0,
              operationsCount: 1,
              channel: DepartmentWalletChannel.inShipping,
              status: DepartmentWalletStatus.protectedEscrow,
            ),
          ],
        ),
      DepartmentType.services => const DepartmentWalletEntity(
          type: DepartmentType.services,
          totalBalance: 620000,
          primaryMetricCount: 320,
          pendingMetricCount: 15,
          pendingMetricAmount: 45200,
          feeValue: '8.0%',
          items: [
            DepartmentWalletItemEntity(
              title: 'مؤسسة التبريد المتقن',
              reference: 'رخصة 88214   #SRV-901',
              availableBalance: 25400,
              pendingBalance: 3200,
              operationsCount: 142,
              channel: DepartmentWalletChannel.instantSettlement,
              status: DepartmentWalletStatus.approvedProvider,
            ),
            DepartmentWalletItemEntity(
              title: 'مؤسسة الصيانة الشاملة',
              reference: 'رخصة 11029   #SRV-412',
              availableBalance: 18500,
              pendingBalance: 0,
              operationsCount: 89,
              channel: DepartmentWalletChannel.snbEscrow,
              status: DepartmentWalletStatus.approvedProvider,
            ),
          ],
        ),
      DepartmentType.couriers => const DepartmentWalletEntity(
          type: DepartmentType.couriers,
          totalBalance: 450000,
          primaryMetricCount: 1200,
          pendingMetricCount: 45,
          pendingMetricAmount: 18000,
          feeValue: '3',
          items: [
            DepartmentWalletItemEntity(
              title: 'شركة زاجل للشحن',
              reference: 'السجل التجاري 40301122   #DEL-551',
              availableBalance: 145000,
              pendingBalance: 12000,
              operationsCount: 14200,
              channel: DepartmentWalletChannel.weeklySettlement,
              status: DepartmentWalletStatus.strategicPartner,
            ),
            DepartmentWalletItemEntity(
              title: 'مندوب وصلني',
              reference: 'رقم المندوب #C-1902',
              availableBalance: 450,
              pendingBalance: 120,
              operationsCount: 45,
              channel: DepartmentWalletChannel.stcPay,
              status: DepartmentWalletStatus.activeCourier,
            ),
          ],
        ),
    };
  }

  @override
  Future<List<WithdrawalRequestEntity>> getMerchantWithdrawals() async {
    _merchantWithdrawalRequests ??= List.of(const [
      WithdrawalRequestEntity(
        id: '1',
        requestNumber: 'TRD-8821',
        beneficiaryName: 'متجر الأفق للأجهزة الكهربائية',
        beneficiaryRole: 'معتمد ومطابق عبر النفاذ الموحد',
        beneficiaryType: BeneficiaryType.merchant,
        grossAmount: 32500.00,
        platformFeePercentage: 2.5,
        platformFeeAmount: 812.50,
        netAmount: 31687.50,
        bankName: 'مصرف الراجحي',
        iban: 'SA42 8000 0412 **** **** 4910',
        dateText: 'اليوم، 10:45 ص (منذ ساعتين)',
        status: RequestStatus.pending,
        auditCheckResult:
            'مطابقة الفواتير: 100% | لا توجد بلاغات نزاع أو شكاوى نشطة | رصيد المحفظة مغطى بالكامل ومطابق لصافي التحصيلات التشغيلية.',
        alertNotice: null,
        isInstantTransferReady: false,
      ),
      WithdrawalRequestEntity(
        id: '2',
        requestNumber: 'SRV-201',
        beneficiaryName: 'م. أحمد الخالدي',
        beneficiaryRole: 'فني صيانة معتمد | عمولات منجزة',
        beneficiaryType: BeneficiaryType.serviceProvider,
        grossAmount: 5000.00,
        platformFeePercentage: 4.0,
        platformFeeAmount: 200.00,
        netAmount: 4800.00,
        bankName: 'البنك الأهلي السعودي (SNB)',
        iban: '',
        dateText: '',
        status: RequestStatus
            .approved, // assuming "جاهز للصرف" maps to a state we can display differently, or we can use isInstantTransferReady
        auditCheckResult: null,
        alertNotice:
            'معتمد من النظام - جاهز للإرسال البنكي الفوري عبر شبكة سريع',
        isInstantTransferReady: true,
      ),
      WithdrawalRequestEntity(
        id: '3',
        requestNumber: 'TRD-304',
        beneficiaryName: 'تاجر مستلزمات حاسب',
        beneficiaryRole: 'موقوف مؤقتاً للتحقيق الرقابي',
        beneficiaryType: BeneficiaryType.merchant,
        grossAmount: 18900.00,
        platformFeePercentage: 5.0,
        platformFeeAmount: 945.00,
        netAmount: 17955.00,
        bankName: '',
        iban: 'المرجع الرقابي\n#FAR-102',
        dateText: '',
        status: RequestStatus.underInvestigation,
        auditCheckResult: null,
        alertNotice:
            'طلب تجميد سحب صادر من مشرف التجار (Finance Action Request #FAR-102) لوجود شبهة تلاعب في عروض ترويجية #CMP-1042 مع عملاء النهائيين بشأن استرداد مبالغ مشتريات ملغاة.',
        isInstantTransferReady: false,
      ),
      WithdrawalRequestEntity(
        id: '4',
        requestNumber: 'TRD-0199',
        beneficiaryName: 'مؤسسة الأفق للتجارة',
        beneficiaryRole: 'حوالة بنكية سريعة معلقة',
        beneficiaryType: BeneficiaryType.merchant,
        grossAmount: 20310.00,
        platformFeePercentage: 5.0,
        platformFeeAmount: 1015.50,
        netAmount: 19294.50,
        bankName: '',
        iban: 'SA44*************0199',
        dateText: '25 يناير 2025',
        status: RequestStatus.frozen,
        auditCheckResult: null,
        alertNotice:
            'فشل التحقق الآلي من تطابق اسم المستفيد مع السجل التجاري لدى البنك.',
        isInstantTransferReady: false,
      ),
    ]);
    if (!_merchantRequestsLoaded) {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_merchantRequestsStorageKey);
      if (encoded != null) {
        final decoded = jsonDecode(encoded);
        if (decoded is! List<dynamic>) {
          throw const FormatException(
              'Invalid merchant financial request list.');
        }
        _merchantWithdrawalRequests = decoded.map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Invalid merchant financial request.');
          }
          return _withdrawalRequestFromJson(value);
        }).toList(growable: true);
      }
      _merchantRequestsLoaded = true;
    }
    return List.unmodifiable(_merchantWithdrawalRequests!);
  }

  @override
  Future<WithdrawalRequestEntity> submitMerchantFinancialRequest({
    required String beneficiaryName,
    required String requestTitle,
    required String sourceAccount,
    required double amount,
    BeneficiaryType beneficiaryType = BeneficiaryType.merchant,
    FinancialOperationType operationType = FinancialOperationType.deposit,
  }) async {
    await getMerchantWithdrawals();
    if (beneficiaryName.trim().isEmpty ||
        requestTitle.trim().isEmpty ||
        sourceAccount.trim().isEmpty) {
      throw ArgumentError(
          'All merchant financial request details are required.');
    }
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Amount must be positive.');
    }

    for (final request in _merchantWithdrawalRequests!) {
      if (request.sourceAccount == sourceAccount.trim() &&
          request.sourceOfFunds == requestTitle.trim() &&
          request.status != RequestStatus.rejected) {
        return request;
      }
    }

    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final request = WithdrawalRequestEntity(
      id: _newFinancialRequestId('MER-FIN', timestamp),
      requestNumber: 'MER-FIN-${timestamp.substring(timestamp.length - 6)}',
      beneficiaryName: beneficiaryName.trim(),
      beneficiaryRole: beneficiaryType == BeneficiaryType.user
          ? 'عميل وصلني'
          : 'طلب مالي من مشرف التجار',
      beneficiaryType: beneficiaryType,
      grossAmount: amount,
      platformFeePercentage: 0,
      platformFeeAmount: 0,
      netAmount: amount,
      bankName: 'طلب مالي للتاجر',
      iban: requestTitle.trim(),
      dateText: DateTime.now().toIso8601String(),
      status: RequestStatus.pending,
      sourceOfFunds: requestTitle.trim(),
      sourceAccount: sourceAccount.trim(),
      operationType: operationType,
      history: [
        FinancialRequestHistoryEvent(
          status: RequestStatus.pending,
          note: 'تم استلام الطلب وإضافته للمراجعة المالية',
          occurredAt: DateTime.now(),
        ),
      ],
    );
    final updated = List<WithdrawalRequestEntity>.of(
      _merchantWithdrawalRequests!,
    )..insert(0, request);
    await _persistMerchantRequests(updated);
    _merchantWithdrawalRequests = updated;
    return request;
  }

  @override
  Future<void> approveMerchantFinancialRequest(String requestId) =>
      _updateMerchantFinancialRequest(
        requestId,
        (request) => request.copyWith(
          status: RequestStatus.approved,
          historyNote: 'تم اعتماد الطلب من المشرف المالي',
        ),
      );

  @override
  Future<void> freezeMerchantFinancialRequest(
    String requestId,
    String reason,
  ) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
        reason,
        'reason',
        'A freeze reason is required.',
      );
    }
    await _updateMerchantFinancialRequest(
      requestId,
      (request) => request.copyWith(
        status: RequestStatus.underInvestigation,
        alertNotice: normalizedReason,
        historyNote: normalizedReason,
      ),
    );
  }

  @override
  Future<void> rejectMerchantFinancialRequest(
    String requestId,
    String reason,
  ) async {
    if (reason.trim().isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'A rejection reason is required.');
    }
    await _updateMerchantFinancialRequest(
      requestId,
      (request) => request.copyWith(
        status: RequestStatus.rejected,
        alertNotice: reason.trim(),
        historyNote: reason.trim(),
      ),
    );
  }

  Future<void> _updateMerchantFinancialRequest(
    String requestId,
    WithdrawalRequestEntity Function(WithdrawalRequestEntity) update,
  ) async {
    await getMerchantWithdrawals();
    final index = _merchantWithdrawalRequests!.indexWhere(
      (request) => request.id == requestId,
    );
    if (index < 0) {
      throw StateError('Merchant financial request $requestId was not found.');
    }
    final current = _merchantWithdrawalRequests![index];
    if (current.status != RequestStatus.pending) {
      throw StateError(
          'Only pending merchant financial requests can be updated.');
    }
    final updated = List<WithdrawalRequestEntity>.of(
      _merchantWithdrawalRequests!,
    );
    updated[index] = update(current);
    await _persistMerchantRequests(updated);
    _merchantWithdrawalRequests = updated;
  }

  Future<void> _persistMerchantRequests(
    List<WithdrawalRequestEntity> requests,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _merchantRequestsStorageKey,
      jsonEncode(requests.map(_withdrawalRequestToJson).toList()),
    );
    if (!saved) {
      throw StateError('Could not persist merchant financial requests.');
    }
  }

  @override
  Future<List<WithdrawalRequestEntity>> getSupervisorWithdrawals() async {
    _supervisorWithdrawalRequests ??= List.of(const [
      WithdrawalRequestEntity(
        id: '1',
        requestNumber: '#409-SUP',
        beneficiaryName: 'أ. سعد العتيبي',
        beneficiaryRole: 'مشرف تجار معتمد',
        beneficiaryType: BeneficiaryType.supervisor,
        grossAmount: 15000.00,
        platformFeePercentage: 0.0,
        platformFeeAmount: 0.0,
        netAmount: 15000.00,
        bankName: 'مصرف الراجحي',
        iban: 'SA42 8000 0412 **** 5521',
        dateText: '',
        status: RequestStatus.pending,
        sourceOfFunds: 'عمولات إشراف واعتماد عقود التجار المنجزة (شهر أكتوبر)',
        auditCheckResult:
            'نسبة الامتثال 98.4% | لا توجد بلاغات تظلم معلقة | رصيد المحفظة مغطى بالكامل',
        transferMethod: 'تحويل سريع عبر IBAN بنك الراجحي',
        isInstantTransferReady: false,
      ),
      WithdrawalRequestEntity(
        id: '2',
        requestNumber: '#3042-SRV',
        beneficiaryName: 'مؤسسة التبريد المتقن',
        beneficiaryRole: 'مقدم خدمة معتمد\n(م. خليل إبراهيم)',
        beneficiaryType: BeneficiaryType.serviceProvider,
        grossAmount: 10000.00,
        platformFeePercentage: 12.5,
        platformFeeAmount: 1250.00,
        netAmount: 8750.00,
        bankName: 'البنك الأهلي السعودي (SNB)',
        iban: 'آيبان موثق',
        dateText: '',
        status: RequestStatus.approved,
        sourceOfFunds:
            'أجور إنجاز 14 طلب صيانة وتبريد ميدانية معتمدة من العميل والمشرف',
        auditCheckResult: null,
        isInstantTransferReady: true,
      ),
      WithdrawalRequestEntity(
        id: '3',
        requestNumber: '#188-SRV',
        beneficiaryName: 'ورشة الإتقان للكهرباء',
        beneficiaryRole: 'مقدم خدمة صيانة',
        beneficiaryType: BeneficiaryType.serviceProvider,
        grossAmount: 7000.00,
        platformFeePercentage: 11.4,
        platformFeeAmount: 800.00,
        netAmount: 6200.00,
        bankName: 'حالة الطلب: محجوز بموجب بروتوكول حماية الجودة الإشرافي',
        iban: '',
        dateText: '',
        status: RequestStatus.underInvestigation,
        sourceOfFunds: null,
        auditCheckResult: null,
        alertNotice:
            'وجود شكوى مفتوحة من عميل (#CMP-1042) لعدم اكتمال أعمال الصيانة بانتظار فحص المشرف وإعادة تقييم الخدمة الميدانية.',
        isInstantTransferReady: false,
      ),
    ]);
    if (!_supervisorRequestsLoaded) {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_supervisorRequestsStorageKey);
      if (encoded != null) {
        final decoded = jsonDecode(encoded);
        if (decoded is! List<dynamic>) {
          throw const FormatException(
            'Invalid supervisor financial request list.',
          );
        }
        _supervisorWithdrawalRequests = decoded.map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException(
              'Invalid supervisor financial request.',
            );
          }
          return _withdrawalRequestFromJson(value);
        }).toList(growable: true);
      }
      _supervisorRequestsLoaded = true;
    }
    return List.unmodifiable(_supervisorWithdrawalRequests!);
  }

  @override
  Future<WithdrawalRequestEntity> submitSupervisorFinancialRequest({
    required String beneficiaryName,
    required String beneficiaryRole,
    required String sourceAccount,
    required double amount,
    required FinancialOperationType operationType,
    required String bankName,
    required String iban,
    required String transferMethod,
    required String dateText,
  }) async {
    if (beneficiaryName.trim().isEmpty ||
        beneficiaryRole.trim().isEmpty ||
        sourceAccount.trim().isEmpty ||
        bankName.trim().isEmpty ||
        iban.trim().isEmpty ||
        transferMethod.trim().isEmpty) {
      throw ArgumentError('All financial request details are required.');
    }
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Amount must be positive.');
    }

    await getSupervisorWithdrawals();
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    final request = WithdrawalRequestEntity(
      id: _newFinancialRequestId('SUP-OP', id),
      requestNumber: 'SUP-OP-$id',
      beneficiaryName: beneficiaryName.trim(),
      beneficiaryRole: beneficiaryRole.trim(),
      beneficiaryType: BeneficiaryType.supervisor,
      grossAmount: amount,
      platformFeePercentage: 0,
      platformFeeAmount: 0,
      netAmount: amount,
      bankName: bankName.trim(),
      iban: iban.trim(),
      dateText: dateText.trim(),
      status: RequestStatus.pending,
      sourceOfFunds: operationType == FinancialOperationType.withdrawal
          ? 'طلب سحب رصيد المحفظة؛ بانتظار اعتماد المشرف المالي.'
          : 'طلب إيداع في المحفظة؛ لن يضاف الرصيد قبل اعتماد المشرف المالي.',
      transferMethod: transferMethod.trim(),
      operationType: operationType,
      sourceAccount: sourceAccount.trim(),
      history: [
        FinancialRequestHistoryEvent(
          status: RequestStatus.pending,
          note: 'تم استلام الطلب وإضافته للمراجعة المالية',
          occurredAt: now,
        ),
      ],
    );
    _supervisorWithdrawalRequests!.insert(0, request);
    try {
      await _persistSupervisorRequests();
    } catch (_) {
      _supervisorWithdrawalRequests!
          .removeWhere((item) => item.id == request.id);
      rethrow;
    }
    return request;
  }

  @override
  Future<WithdrawalRequestEntity> submitSupervisorWithdrawal({
    required String beneficiaryName,
    required String beneficiaryRole,
    required String sourceAccount,
    required double amount,
    FinancialOperationType operationType = FinancialOperationType.withdrawal,
    required String bankName,
    required String iban,
    required String transferMethod,
  }) =>
      submitSupervisorFinancialRequest(
        beneficiaryName: beneficiaryName,
        beneficiaryRole: beneficiaryRole,
        sourceAccount: sourceAccount,
        amount: amount,
        operationType: operationType,
        bankName: bankName,
        iban: iban,
        transferMethod: transferMethod,
        dateText: DateTime.now().toIso8601String(),
      );

  @override
  Future<List<WithdrawalRequestEntity>> getFrozenWithdrawals() async {
    final merchantRequests = await getMerchantWithdrawals();
    final supervisorRequests = await getSupervisorWithdrawals();
    return List.unmodifiable(
      [...merchantRequests, ...supervisorRequests].where(
        (request) =>
            request.status == RequestStatus.frozen ||
            request.status == RequestStatus.underInvestigation,
      ),
    );
  }

  @override
  Future<void> restoreFrozenWithdrawal(
    String requestId,
    BeneficiaryType beneficiaryType,
  ) async {
    final requests = await _withdrawalListFor(beneficiaryType);
    final requestIndex = requests.indexWhere(
      (request) =>
          request.id == requestId && request.beneficiaryType == beneficiaryType,
    );
    if (requestIndex == -1) {
      throw ArgumentError.value(
          requestId, 'requestId', 'Withdrawal not found.');
    }

    final request = requests[requestIndex];
    if (request.status != RequestStatus.frozen &&
        request.status != RequestStatus.underInvestigation &&
        request.status != RequestStatus.rejected) {
      throw StateError('Only a rejected or frozen withdrawal can be restored.');
    }
    requests[requestIndex] = request.copyWith(
      status: RequestStatus.pending,
      clearAlertNotice: true,
      historyNote: 'تم التراجع عن الإجراء وإعادة الطلب إلى قائمة الانتظار',
    );
    try {
      if (beneficiaryType == BeneficiaryType.merchant ||
          beneficiaryType == BeneficiaryType.user) {
        await _persistMerchantRequests(requests);
      } else {
        await _persistSupervisorRequests();
      }
    } catch (_) {
      requests[requestIndex] = request;
      rethrow;
    }
  }

  @override
  Future<void> rejectAndForfeitWithdrawal(
    String requestId,
    BeneficiaryType beneficiaryType,
    String reason,
  ) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'Rejection reason is required.');
    }

    final requests = await _withdrawalListFor(beneficiaryType);
    final requestIndex = requests.indexWhere(
      (request) =>
          request.id == requestId && request.beneficiaryType == beneficiaryType,
    );
    if (requestIndex == -1) {
      throw ArgumentError.value(
          requestId, 'requestId', 'Withdrawal not found.');
    }

    final request = requests[requestIndex];
    if (request.status != RequestStatus.frozen &&
        request.status != RequestStatus.underInvestigation) {
      throw StateError('Withdrawal is no longer frozen.');
    }
    requests[requestIndex] = request.copyWith(
      status: RequestStatus.rejected,
      alertNotice: normalizedReason,
      historyNote: normalizedReason,
    );
    if (beneficiaryType == BeneficiaryType.supervisor ||
        beneficiaryType == BeneficiaryType.serviceProvider) {
      await _persistSupervisorRequests();
    }
  }

  @override
  Future<List<BankLinkRequestEntity>> getBankLinkRequests() async {
    return List.unmodifiable(_bankLinkRequests);
  }

  @override
  Future<void> approveBankLinkRequest(String requestId) async {
    final index = _pendingBankLinkRequestIndex(requestId);
    _bankLinkRequests[index] = _bankLinkRequests[index].copyWith(
      status: BankLinkRequestStatus.pendingManagementApproval,
    );
  }

  @override
  Future<void> requestIbanCertificate(String requestId) async {
    final index = _pendingBankLinkRequestIndex(requestId);
    _bankLinkRequests[index] = _bankLinkRequests[index].copyWith(
      status: BankLinkRequestStatus.ibanCertificateRequested,
    );
  }

  @override
  Future<void> freezeBankLinkRequest(String requestId, String reason) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'A freeze reason is required.');
    }

    final index = _pendingBankLinkRequestIndex(requestId);
    _bankLinkRequests[index] = _bankLinkRequests[index].copyWith(
      status: BankLinkRequestStatus.frozen,
      decisionReason: normalizedReason,
    );
  }

  @override
  Future<void> rejectBankLinkRequest(String requestId, String reason) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'A rejection reason is required.');
    }

    final index = _pendingBankLinkRequestIndex(requestId);
    _bankLinkRequests[index] = _bankLinkRequests[index].copyWith(
      status: BankLinkRequestStatus.rejected,
      decisionReason: normalizedReason,
    );
  }

  @override
  Future<void> restoreFrozenBankLinkRequest(String requestId) async {
    final index = _bankLinkRequests.indexWhere((request) =>
        request.id == requestId &&
        (request.status == BankLinkRequestStatus.frozen ||
            request.status == BankLinkRequestStatus.rejected));
    if (index == -1) {
      throw StateError('Bank link request is not frozen or rejected.');
    }
    _bankLinkRequests[index] = _bankLinkRequests[index].copyWith(
      status: BankLinkRequestStatus.pending,
      clearDecisionReason: true,
    );
  }

  @override
  Future<void> rejectFrozenBankLinkRequest(
    String requestId,
    String reason,
  ) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'A rejection reason is required.');
    }
    final index = _bankLinkRequestIndex(
      requestId,
      BankLinkRequestStatus.frozen,
    );
    _bankLinkRequests[index] = _bankLinkRequests[index].copyWith(
      status: BankLinkRequestStatus.rejected,
      decisionReason: normalizedReason,
    );
  }

  int _pendingBankLinkRequestIndex(String requestId) {
    return _bankLinkRequestIndex(requestId, BankLinkRequestStatus.pending);
  }

  int _bankLinkRequestIndex(
    String requestId,
    BankLinkRequestStatus expectedStatus,
  ) {
    final index = _bankLinkRequests.indexWhere((request) =>
        request.id == requestId && request.status == expectedStatus);
    if (index == -1) {
      throw StateError(
          'Bank link request is missing or no longer $expectedStatus.');
    }
    return index;
  }

  Future<List<WithdrawalRequestEntity>> _withdrawalListFor(
      BeneficiaryType beneficiaryType) async {
    switch (beneficiaryType) {
      case BeneficiaryType.merchant:
      case BeneficiaryType.user:
        await getMerchantWithdrawals();
        return _merchantWithdrawalRequests!;
      case BeneficiaryType.supervisor:
      case BeneficiaryType.serviceProvider:
        await getSupervisorWithdrawals();
        return _supervisorWithdrawalRequests!;
    }
  }

  @override
  Future<List<SubscriptionRequestEntity>> getSubscriptions() async {
    if (_subscriptionRequests != null) {
      return List.unmodifiable(_subscriptionRequests!);
    }

    final now = DateTime.now();
    final seeds = <SubscriptionRequestEntity>[
      SubscriptionRequestEntity(
        id: '1',
        providerName: 'متجر إلكترونيات النخبة',
        registrationNumber: '101099234',
        categoryName: 'اشتراك تاجر مميز',
        targetPackageName: 'الباقة الذهبية السنوية',
        durationText:
            'شامل الضريبة 15%', // Use this field for the bottom text under amount
        totalAmount: 4800.00,
        paymentMethod: 'تحويل بنكي مباشر (سداد / الراجحي)',
        status: 'قيد المطابقة',
        type: SubscriptionType.merchant,
        createdAt: now.subtract(const Duration(minutes: 35)),
      ),
      SubscriptionRequestEntity(
        id: '2',
        providerName: 'ورشة الصيانة الشاملة...',
        registrationNumber: '440219',
        categoryName: 'مقدم خدمات منزلية',
        targetPackageName: 'مزود خدمة احترافي',
        durationText: 'نصف سنوي (6 أشهر)',
        totalAmount: 1850.00,
        paymentMethod: 'خصم مباشر من رصيد المحفظة الضامنة (Escrow)',
        status: 'جاهز للاعتماد التلقائي',
        type: SubscriptionType.serviceProvider,
        createdAt: now.subtract(const Duration(hours: 2)),
        availableBalance: 'رصيد متاح 6,400 ج.م',
      ),
      SubscriptionRequestEntity(
        id: '3',
        providerName: 'ترقية مستخدم VIP',
        registrationNumber: 'USR-9021',
        categoryName: 'مستخدم مميز',
        targetPackageName: 'باقة VIP السنوية',
        durationText: 'سنوي',
        totalAmount: 500.00,
        paymentMethod: 'البطاقة الائتمانية (Mada)',
        status: 'قيد المطابقة',
        type: SubscriptionType.user,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      SubscriptionRequestEntity(
        id: '4',
        providerName: 'باقة المندوب السريع',
        registrationNumber: 'DLV-4412',
        categoryName: 'مندوب توصيل',
        targetPackageName: 'باقة التوصيل اللامحدود',
        durationText: 'شهري',
        totalAmount: 150.00,
        paymentMethod: 'خصم من المحفظة',
        status: 'جاهز للاعتماد التلقائي',
        type: SubscriptionType.courier,
        createdAt: now.subtract(const Duration(days: 2)),
        availableBalance: 'رصيد متاح 800 ج.م',
      ),
      SubscriptionRequestEntity(
        id: '5',
        providerName: 'إعلان بانر رئيسي',
        registrationNumber: 'AD-1102',
        categoryName: 'إعلانات تجارية',
        targetPackageName: 'ظهور مميز لمدة أسبوع',
        durationText: 'أسبوعي',
        totalAmount: 1200.00,
        paymentMethod: 'تحويل بنكي مباشر (الأهلي)',
        status: 'قيد المطابقة',
        type: SubscriptionType.ad,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_subscriptionDecisionsStorageKey);
    final decisions = <String, Map<String, dynamic>>{};
    if (stored != null) {
      final decoded = jsonDecode(stored);
      if (decoded is! List) {
        throw const FormatException(
            'Subscription decision archive is invalid.');
      }
      for (final item in decoded) {
        if (item is! Map<String, dynamic> || item['id'] is! String) {
          throw const FormatException(
              'Subscription decision record is invalid.');
        }
        decisions[item['id'] as String] = item;
      }
    }

    _subscriptionRequests = seeds.map((subscription) {
      final decisionData = decisions[subscription.id];
      if (decisionData == null) return subscription;
      final decisionName = decisionData['decision'];
      if (decisionName is! String) {
        throw const FormatException('Subscription decision is missing.');
      }
      final decision = SubscriptionReviewDecision.values.firstWhere(
        (value) => value.name == decisionName,
        orElse: () => throw FormatException(
          'Unknown subscription decision: $decisionName',
        ),
      );
      final reason = decisionData['reason'];
      if (reason != null && reason is! String) {
        throw const FormatException('Subscription decision reason is invalid.');
      }
      return subscription.copyWith(
        reviewDecision: decision,
        decisionReason: reason as String?,
      );
    }).toList();
    return List.unmodifiable(_subscriptionRequests!);
  }

  @override
  Future<void> updateSubscriptionDecision({
    required String requestId,
    required SubscriptionReviewDecision decision,
    required String reason,
  }) async {
    final current = await _reloadSubscriptionRequests();
    final index = current.indexWhere((request) => request.id == requestId);
    if (index < 0) {
      throw ArgumentError.value(
        requestId,
        'requestId',
        'Subscription request not found.',
      );
    }
    if (reason.trim().isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'A decision reason is required.');
    }

    final updated = current.toList();
    updated[index] = updated[index].copyWith(
      reviewDecision: decision,
      decisionReason: reason.trim(),
    );
    await _saveSubscriptionDecisions(updated);
    _subscriptionRequests = updated;
  }

  @override
  Future<void> restoreSubscriptionDecision(String requestId) async {
    final current = await _reloadSubscriptionRequests();
    final index = current.indexWhere((request) => request.id == requestId);
    if (index < 0) {
      throw ArgumentError.value(
        requestId,
        'requestId',
        'Subscription request not found.',
      );
    }
    final decision = current[index].reviewDecision;
    if (decision == null) return;
    if (decision != SubscriptionReviewDecision.frozen &&
        decision != SubscriptionReviewDecision.rejected) {
      throw StateError('Only frozen or rejected requests can be restored.');
    }

    final updated = current.toList();
    updated[index] = updated[index].copyWith(
      clearReviewDecision: true,
      clearDecisionReason: true,
    );
    await _saveSubscriptionDecisions(updated);
    _subscriptionRequests = updated;
  }

  Future<List<SubscriptionRequestEntity>> _reloadSubscriptionRequests() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    _subscriptionRequests = null;
    return getSubscriptions();
  }

  Future<void> _saveSubscriptionDecisions(
    List<SubscriptionRequestEntity> subscriptions,
  ) async {
    final archived = subscriptions
        .where((subscription) => subscription.reviewDecision != null)
        .map((subscription) => {
              'id': subscription.id,
              'decision': subscription.reviewDecision!.name,
              'reason': subscription.decisionReason,
            })
        .toList(growable: false);
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _subscriptionDecisionsStorageKey,
      jsonEncode(archived),
    );
    if (!saved) {
      // SharedPreferences may report false when the value is already present.
      // Verify the persisted value before treating that as a failed write.
      await preferences.reload();
      if (preferences.getString(_subscriptionDecisionsStorageKey) !=
          jsonEncode(archived)) {
        throw StateError('Could not save the subscription decision archive.');
      }
    }
  }

  @override
  Future<void> approveWithdrawal(String requestId) async {
    await getSupervisorWithdrawals();
    final index = _supervisorWithdrawalRequests!
        .indexWhere((request) => request.id == requestId);
    if (index == -1) {
      throw ArgumentError.value(
        requestId,
        'requestId',
        'Supervisor financial request not found.',
      );
    }
    final request = _supervisorWithdrawalRequests![index];
    if (request.status != RequestStatus.pending) {
      throw StateError('Only a pending financial request can be approved.');
    }
    _supervisorWithdrawalRequests![index] = request.copyWith(
      status: RequestStatus.approved,
      historyNote: 'تم اعتماد الطلب من المشرف المالي',
      alertNotice: request.operationType == FinancialOperationType.withdrawal
          ? 'Approved by the financial supervisor. Transfer execution requires the configured payment service.'
          : 'Deposit approved by the financial supervisor. Balance posting requires the configured payment service.',
    );
    try {
      await _persistSupervisorRequests();
    } catch (_) {
      _supervisorWithdrawalRequests![index] = request;
      rethrow;
    }
  }

  @override
  Future<void> freezeWithdrawal(String requestId, String reason) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'A freeze reason is required.');
    }
    await getSupervisorWithdrawals();
    final index = _supervisorWithdrawalRequests!
        .indexWhere((request) => request.id == requestId);
    if (index == -1) {
      throw ArgumentError.value(
        requestId,
        'requestId',
        'Supervisor financial request not found.',
      );
    }
    final request = _supervisorWithdrawalRequests![index];
    if (request.status != RequestStatus.pending) {
      throw StateError('Only a pending financial request can be frozen.');
    }
    _supervisorWithdrawalRequests![index] = request.copyWith(
      status: RequestStatus.underInvestigation,
      alertNotice: normalizedReason,
      historyNote: normalizedReason,
    );
    try {
      await _persistSupervisorRequests();
    } catch (_) {
      _supervisorWithdrawalRequests![index] = request;
      rethrow;
    }
  }

  @override
  Future<void> rejectWithdrawal(String requestId, String reason) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'A rejection reason is required.');
    }
    await getSupervisorWithdrawals();
    final index = _supervisorWithdrawalRequests!
        .indexWhere((request) => request.id == requestId);
    if (index == -1) {
      throw ArgumentError.value(
        requestId,
        'requestId',
        'Supervisor financial request not found.',
      );
    }
    final request = _supervisorWithdrawalRequests![index];
    if (request.status != RequestStatus.pending) {
      throw StateError('Only a pending financial request can be rejected.');
    }
    _supervisorWithdrawalRequests![index] = request.copyWith(
      status: RequestStatus.rejected,
      alertNotice: normalizedReason,
      historyNote: normalizedReason,
    );
    try {
      await _persistSupervisorRequests();
    } catch (_) {
      _supervisorWithdrawalRequests![index] = request;
      rethrow;
    }
  }

  Future<void> _persistSupervisorRequests() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _supervisorWithdrawalRequests!
          .map(_withdrawalRequestToJson)
          .toList(growable: false),
    );
    final saved =
        await preferences.setString(_supervisorRequestsStorageKey, encoded);
    if (!saved) {
      throw StateError('Could not save supervisor financial requests.');
    }
  }

  Map<String, Object?> _withdrawalRequestToJson(
    WithdrawalRequestEntity request,
  ) =>
      {
        'id': request.id,
        'requestNumber': request.requestNumber,
        'beneficiaryName': request.beneficiaryName,
        'beneficiaryRole': request.beneficiaryRole,
        'beneficiaryType': request.beneficiaryType.name,
        'grossAmount': request.grossAmount,
        'platformFeePercentage': request.platformFeePercentage,
        'platformFeeAmount': request.platformFeeAmount,
        'netAmount': request.netAmount,
        'bankName': request.bankName,
        'iban': request.iban,
        'dateText': request.dateText,
        'status': request.status.name,
        'auditCheckResult': request.auditCheckResult,
        'alertNotice': request.alertNotice,
        'isInstantTransferReady': request.isInstantTransferReady,
        'sourceOfFunds': request.sourceOfFunds,
        'transferMethod': request.transferMethod,
        'operationType': request.operationType.name,
        'sourceAccount': request.sourceAccount,
        'history': request.history
            .map((event) => {
                  'status': event.status.name,
                  'note': event.note,
                  'occurredAt': event.occurredAt.toIso8601String(),
                })
            .toList(growable: false),
      };

  WithdrawalRequestEntity _withdrawalRequestFromJson(
    Map<String, dynamic> json,
  ) =>
      WithdrawalRequestEntity(
        id: json['id'] as String,
        requestNumber: json['requestNumber'] as String,
        beneficiaryName: json['beneficiaryName'] as String,
        beneficiaryRole: json['beneficiaryRole'] as String,
        beneficiaryType: BeneficiaryType.values.byName(
          json['beneficiaryType'] as String,
        ),
        grossAmount: (json['grossAmount'] as num).toDouble(),
        platformFeePercentage:
            (json['platformFeePercentage'] as num).toDouble(),
        platformFeeAmount: (json['platformFeeAmount'] as num).toDouble(),
        netAmount: (json['netAmount'] as num).toDouble(),
        bankName: json['bankName'] as String,
        iban: json['iban'] as String,
        dateText: json['dateText'] as String,
        status: RequestStatus.values.byName(json['status'] as String),
        auditCheckResult: json['auditCheckResult'] as String?,
        alertNotice: json['alertNotice'] as String?,
        isInstantTransferReady:
            json['isInstantTransferReady'] as bool? ?? false,
        sourceOfFunds: json['sourceOfFunds'] as String?,
        transferMethod: json['transferMethod'] as String?,
        operationType: FinancialOperationType.values.byName(
          json['operationType'] as String? ?? 'withdrawal',
        ),
        sourceAccount: json['sourceAccount'] as String?,
        history: (json['history'] as List<dynamic>? ?? const []).map((value) {
          if (value is! Map<String, dynamic> ||
              value['status'] is! String ||
              value['note'] is! String ||
              value['occurredAt'] is! String) {
            throw const FormatException(
              'Invalid financial request history event.',
            );
          }
          return FinancialRequestHistoryEvent(
            status: RequestStatus.values.byName(value['status'] as String),
            note: value['note'] as String,
            occurredAt: DateTime.parse(value['occurredAt'] as String),
          );
        }).toList(growable: false),
      );
}
