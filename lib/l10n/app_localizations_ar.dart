// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'borwah_mng';

  @override
  String get cfoSessionTimestamp => '1446/11/04 هـ - 10:45 ص';

  @override
  String get ordersUnit => 'طلبات';

  @override
  String get financialGovernanceTitle =>
      'لائحة الحوكمة وتفويض الصلاحيات المالية';

  @override
  String get ongoingOperatingInvoices => 'الفواتير ومستحقات التشغيل الجارية';

  @override
  String get completedAndMatched => 'مكتملة ومطابقة 100%';

  @override
  String get switchLanguage => 'تغيير اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تأكيد تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل تريد تسجيل الخروج من حسابك؟';

  @override
  String get logoutCancel => 'إلغاء';

  @override
  String get logoutConfirm => 'تسجيل الخروج';

  @override
  String get appSubtitle => 'نظام الإدارة والإشراف الميداني';

  @override
  String get secureLoginPortal => 'بوابة تسجيل دخول آمنة ومشفّرة';

  @override
  String get workEmail => 'البريد الإلكتروني الوظيفي';

  @override
  String get password => 'كلمة المرور';

  @override
  String get roleAccessNotice =>
      'يتم تحديد واجهة العمل وصلاحيات النظام تلقائياً حسب الرتبة الإشرافية فور التحقق.';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get requestAccessReset => 'طلب استعادة الوصول عبر المسؤول التقني';

  @override
  String get restrictedAccessFooter => 'هذا التطبيق مخصص للإدارة والمشرفين فقط';

  @override
  String get copyrightNotice =>
      'الإصدار 3.4.0 (داخلي) • جميع الحقوق محفوظة لشركة برواح المازوري';

  @override
  String get certifiedFinancialAuditor => 'مدقق مالي معتمد';

  @override
  String get liveFinancialSession => 'الجلسة المالية المباشرة';

  @override
  String get financialControlTitle =>
      'الرقابة المالية المركزية - برواح المازوري';

  @override
  String get cfoControlPanelSubtitle =>
      'لوحة تحكم المدير المالي | الوردية المالية النشطة ومطابقة السيولة الحية';

  @override
  String get cfoName => 'أ. سليمان الراجحي';

  @override
  String get cfoRole => 'المدير المالي التنفيذي';

  @override
  String get cfoBadgeCode => '#CF0-01';

  @override
  String get currencyEgy => 'ج.م';

  @override
  String get totalAggregatedLiquidity =>
      'إجمالي السيولة النقدية والضمانات المجمعة';

  @override
  String get alRajhiMainOperating => 'مصرف الراجحي (الحساب التشغيلي الرئيسي)';

  @override
  String get snbEscrowAccount => 'البنك الأهلي السعودي (حساب الضمان Escrow)';

  @override
  String get pendingMerchantWithdrawalsTitle =>
      'طلبات السحب المعلقة قيد المراجعة للتجار والمستخدمين';

  @override
  String get pendingSupervisorWithdrawalsTitle =>
      'طلبات السحب المعلقة قيد المراجعة للمشرفين و المساعدين';

  @override
  String get auditInvoiceNote => 'تحتاج تدقيق ومطابقة فواتير قبل التوقيع';

  @override
  String get pendingSubscriptionsTitle => 'طلبات الاشتراكات والترقيات المعلقة';

  @override
  String get pendingSubscriptionsSubtitle =>
      'ترقيات باقات المتاجر، اشتراكات الفنيين، وتجديد الاشتراكات السنوية بانتظار الاعتماد المالي';

  @override
  String get reviewSubscriptionsAction => 'مراجعة واعتماد الاشتراكات';

  @override
  String get operationalExpenses => 'المصاريف والمدفوعات التشغيلية';

  @override
  String get expensesManagementTitle => 'المصاريف والمدفوعات';

  @override
  String get amountToDisburse => 'المبلغ المطلوب دفعه وصرفه';

  @override
  String get accountAndPaymentChannel => 'الحساب وقناة الدفع للخصم المباشر';

  @override
  String get noAccountsAvailable => 'لا توجد حسابات متاحة';

  @override
  String get escrowBalanceLabel => 'رصيد حساب الضمان:';

  @override
  String get currentLedgerBalanceLabel => 'الرصيد الدفتري الحالي:';

  @override
  String get expenseCategoryAndDocuments => 'تصنيف المصروف والمستندات المؤيدة';

  @override
  String get detailedExpenseReason => 'سبب سحب وصرف المصروف تفصيلياً';

  @override
  String get expenseDetailsHint => 'أدخل بياناً تفصيلياً بالمصروف';

  @override
  String get invoiceSupportDocument => 'مرفق الفاتورة الضريبية والمستند المؤيد';

  @override
  String get attachDocumentOptional => 'إرفاق صورة المستند إن وجدت';

  @override
  String get expenseReasonRequired => 'يرجى كتابة سبب المصروف أولاً';

  @override
  String get expenseAmountInvalid => 'أدخل مبلغاً صحيحاً أكبر من صفر';

  @override
  String get expenseRequestPendingStatus => 'بانتظار موافقة الإدارة';

  @override
  String get expenseRequestNumber => 'رقم الطلب';

  @override
  String get expenseRequestAmount => 'المبلغ';

  @override
  String get expenseRequestSent =>
      'تم إرسال طلب المصروف للإدارة للموافقة. لم يتغير رصيد الحساب.';

  @override
  String get expenseRequestSendFailed =>
      'تعذر إرسال طلب المصروف. حاول مرة أخرى.';

  @override
  String get expenseRequestSubmitting => 'جارٍ إرسال الطلب...';

  @override
  String get expenseConfirmTitle => 'إرسال طلب المصروف';

  @override
  String get expenseConfirmDescription =>
      'سيتم إرسال طلب المصروف إلى الإدارة للمراجعة والموافقة، دون خصم المبلغ الآن.';

  @override
  String get expenseAttachedPrefix => 'مرفق';

  @override
  String get expenseRemoveDocumentAction => 'انقر للإزالة';

  @override
  String get expenseDocumentAttached => 'تم إرفاق المستند';

  @override
  String get expenseDocumentRemoved => 'تمت إزالة المستند المرفق';

  @override
  String get strictFinancialDisbursementGovernance =>
      'حوكمة الصرف المالي المشدد';

  @override
  String get disbursementGovernanceNote =>
      'تخضع هذه العملية للرقابة المستندية والمطابقة البنكية الآلية، ويتم توثيق أمر الصرف في سجل التدقيق المالي برقم تتبع مشفر وتتطلب تأكيد التوقيع الرقمي المباشر للمدير المالي (CFO).';

  @override
  String get approvePaymentOrder => 'اعتماد أمر الدفع وإرساله للإدارة';

  @override
  String get cancelPaymentOrder => 'إلغاء الأمر والتراجع عنه';

  @override
  String get paymentApprovedSuccessfully => 'تم اعتماد أمر الدفع بنجاح';

  @override
  String get monthlyTotalExpenses => 'إجمالي مدفوعات الشهر';

  @override
  String get expenseManagement => 'إدارة الصرف';

  @override
  String get scheduledDisbursementItems => '4 بنود صرف مجدولة';

  @override
  String get recordNewPayment => 'تسجيل بيان دفع جديد / إدارة المصاريف';

  @override
  String get monthlyEarnedCommissions => 'عمولات التطبيق المحصلة هذا الشهر';

  @override
  String get netRegulatoryRevenue => 'صافي الإيراد الرقابي';

  @override
  String get comparedToLastMonth => 'مقارنة بالشهر السابق (249,450 ج.م)';

  @override
  String get balancesUnderRegulatoryAudit => 'أرصدة معلقة تحت التدقيق الرقابي';

  @override
  String get frozenWalletsNote =>
      'محافظ مجمدة احترازياً بطلب الإدارة العامة والمشرفين لوجود بلاغات ونزاعات مفتوحة.';

  @override
  String get operationalDepartmentsWallets =>
      'محافظ الأقسام التشغيلية المباشرة';

  @override
  String get activeSectorsCount => '4 قطاعات حية';

  @override
  String get merchantsWalletTitle => 'محفظة قسم التجار والمتاجر';

  @override
  String get merchantsWalletDesc => 'رصيد دوري متاح للتسوية البنكية والسحب';

  @override
  String get usedAndEscrowWalletTitle => 'محفظة المستعمل وعربون «وصلني»';

  @override
  String get usedAndEscrowWalletDesc => 'حساب ضمان وتأمين صفقات نشط (Escrow)';

  @override
  String get servicesMaintenanceWalletTitle => 'محفظة طلبات الخدمات والصيانة';

  @override
  String get servicesMaintenanceWalletDesc =>
      'مستحقات فنيين معتمدين ومزودي الخدمات';

  @override
  String get servicesSupervisorRoleBadge => 'مشرف الخدمات';

  @override
  String get servicesSupervisorBadgeCode => '#SRV-01';

  @override
  String get servicesSupervisorAccountName => 'مشرف الخدمات';

  @override
  String get servicesProfileTitle => 'الملف الشخصي';

  @override
  String get servicesProfileName => 'م. عبد العزيز بن خالد السالم';

  @override
  String get servicesProfileIdentity => 'مشرف ميداني أول · إدارة الخدمات';

  @override
  String get servicesProfileCoverage => 'النطاق: الرياض والمناطق المجاورة';

  @override
  String get servicesProfileAvailability => 'على رأس العمل - متاح للمناوبة';

  @override
  String get servicesProfileCompletedTasks => 'الطلبات المنجزة';

  @override
  String get servicesProfileFieldTasks => 'مهمة موثقة ميدانياً';

  @override
  String get servicesProfilePerformanceRating => 'تقييم الأداء';

  @override
  String get servicesProfileRatingDetail => 'ممتاز · وفق آخر 120 مهمة';

  @override
  String get servicesProfileAssignmentTime => 'متوسط زمن الإسناد';

  @override
  String get servicesProfileMinutes => 'دقيقة';

  @override
  String get servicesProfileComplaintResolution => 'حل ومتابعة البلاغات';

  @override
  String get servicesProfileResolutionDetail => 'ضمن المعدل العام';

  @override
  String get servicesProfileDemoMetricsNotice =>
      'بيانات الملف ومؤشرات الأداء والأرصدة المعروضة تجريبية حتى ربط الحساب بمصدر بيانات معتمد.';

  @override
  String get servicesProfileLoadError =>
      'تعذر تحميل بيانات الملف المحفوظة على هذا الجهاز.';

  @override
  String get servicesProfileWalletTitle => 'محفظة المستحقات والعمولات';

  @override
  String get servicesProfileWalletDescription =>
      'إدارة المستحقات وسحب الأرباح حسب النظام';

  @override
  String get servicesProfileAvailableBalance => 'الرصيد المتاح للسحب';

  @override
  String get servicesProfilePendingDues => 'قيد التسوية والمراجعة';

  @override
  String get servicesProfileCurrency => 'ج.م';

  @override
  String get servicesProfileOpenWallet => 'فتح المحفظة وسحب الرصيد';

  @override
  String get servicesProfileWalletDetails =>
      'يمكنك مراجعة الرصيد المتاح والمستحقات قيد التسوية من صفحة المحفظة.';

  @override
  String get servicesAccountEditProfile => 'إعدادات الحساب والتنبيهات';

  @override
  String get servicesAccountName => 'الاسم';

  @override
  String get servicesAccountPhone => 'رقم الهاتف';

  @override
  String get servicesAccountCoverage => 'نطاق التغطية';

  @override
  String get servicesAccountSave => 'حفظ';

  @override
  String get servicesAccountSaved => 'تم حفظ التغييرات على هذا الجهاز';

  @override
  String servicesAccountSaveError(Object error) {
    return 'تعذر حفظ التغييرات: $error';
  }

  @override
  String get servicesAccountLoadError => 'تعذر تحميل بيانات الحساب المحلية.';

  @override
  String get servicesAccountRetry => 'إعادة المحاولة';

  @override
  String get servicesAccountNameRequired => 'يرجى إدخال الاسم.';

  @override
  String get servicesAccountLocalOnly =>
      'هذه البيانات محفوظة على هذا الجهاز فقط ولا تُحدّث الحساب على الخادم.';

  @override
  String get servicesAccountNotificationsTitle => 'تفضيلات التنبيهات';

  @override
  String get servicesAccountAssignmentAlerts => 'تنبيهات إسناد الخدمات';

  @override
  String get servicesAccountComplaintAlerts => 'تحديثات الشكاوى';

  @override
  String get servicesAccountSystemAlerts => 'التنبيهات الإدارية';

  @override
  String get servicesAccountPreferencesLocalOnly =>
      'التفضيلات محفوظة محليًا؛ لم يتم ربطها بخدمة إشعارات.';

  @override
  String get servicesAccountWalletTitle => 'المحفظة والعمليات المالية';

  @override
  String get servicesAccountWalletUnavailable => 'المحفظة غير متصلة';

  @override
  String get servicesAccountWalletUnavailableDetails =>
      'يلزم ربط خدمة مالية معتمدة لعرض الرصيد أو إرسال طلبات السحب. لا تُجرى معاملات من هذه النسخة.';

  @override
  String get servicesAccountActivityTitle => 'سجل نشاط الحساب';

  @override
  String get servicesAccountNoActivity => 'لا توجد أنشطة محفوظة حتى الآن.';

  @override
  String get servicesAccountActivityLocalOnly =>
      'السجل محلي على هذا الجهاز، وليس سجل تدقيق مركزيًا.';

  @override
  String get servicesAccountActivityProfileUpdated => 'تم تعديل بيانات الملف';

  @override
  String get servicesAccountActivityPreferencesUpdated =>
      'تم تعديل تفضيلات التنبيهات';

  @override
  String get servicesAccountActivityOther => 'نشاط الحساب';

  @override
  String get servicesAccountLogoutTitle => 'تسجيل الخروج';

  @override
  String get servicesAccountLogoutMessage =>
      'هل تريد تسجيل الخروج من حساب مشرف الخدمات؟';

  @override
  String get servicesWalletBack => 'العودة';

  @override
  String get servicesWalletTitle => 'محفظتي والعمليات المالية';

  @override
  String get servicesWalletSummaryTitle => 'ملخص المحفظة';

  @override
  String get servicesWalletLiveUpdate => 'بيانات تجريبية';

  @override
  String get servicesWalletTotalBalance => 'إجمالي الرصيد';

  @override
  String get servicesWalletAvailable => 'الرصيد المتاح';

  @override
  String get servicesWalletReadyForTransfer => 'جاهز للتحويل';

  @override
  String get servicesWalletPending => 'مستحقات معلقة';

  @override
  String get servicesWalletExpectedThisWeek => 'متوقعة هذا الأسبوع';

  @override
  String get servicesWalletMonthlyCommissions => 'عمولات الشهر الحالي';

  @override
  String get servicesWalletWithdrawalTitle => 'طلب سحب رصيد';

  @override
  String get servicesWalletAmountLabel => 'المبلغ المراد سحبه';

  @override
  String get servicesWalletMaxAmount => 'الحد الأقصى';

  @override
  String get servicesWalletMethodTitle => 'اختر طريقة التحويل';

  @override
  String get servicesWalletInstapay => 'تحويل عبر إنستاباي';

  @override
  String get servicesWalletInstapayDetails => 'تحويل فوري إلى الحساب';

  @override
  String get servicesWalletInstapayId => 'معرّف إنستاباي';

  @override
  String get servicesWalletMobileWallet => 'محفظة هاتفية';

  @override
  String get servicesWalletMobileWalletDetails => 'تحويل إلى رقم الهاتف';

  @override
  String get servicesWalletMobileNumber => 'رقم الهاتف';

  @override
  String get servicesWalletBank => 'تحويل بنكي';

  @override
  String get servicesWalletBankDetails => 'إيداع إلى الحساب البنكي';

  @override
  String get servicesWalletBankAccount => 'رقم الحساب البنكي';

  @override
  String get servicesWalletReviewNote =>
      'يتم تسجيل الطلبات لمراجعة المشرف المالي. لن يتم التحويل أو الإيداع قبل الموافقة وتكامل خدمة الدفع.';

  @override
  String get servicesWalletSubmit => 'إرسال طلب السحب';

  @override
  String get financeWalletWithdrawal => 'سحب';

  @override
  String get financeWalletDeposit => 'إيداع';

  @override
  String get financeWalletDepositTitle => 'طلب إيداع في المحفظة';

  @override
  String get financeWalletSubmitDeposit => 'إرسال طلب إيداع';

  @override
  String get financeWalletWithdrawalNote =>
      'سيظل الطلب قيد المراجعة ولن يتم تحويل أي أموال حتى موافقة المشرف المالي.';

  @override
  String get financeWalletDepositNote =>
      'لن تتم إضافة المبلغ إلى رصيدك حتى موافقة المشرف المالي.';

  @override
  String get financeWalletConfirmWithdrawal => 'تأكيد طلب السحب';

  @override
  String get financeWalletConfirmDeposit => 'تأكيد طلب الإيداع';

  @override
  String financeWalletConfirmWithdrawalMessage(Object amount, Object currency) {
    return 'هل تريد إرسال طلب سحب بقيمة $amount $currency إلى المشرف المالي؟';
  }

  @override
  String financeWalletConfirmDepositMessage(Object amount, Object currency) {
    return 'هل تريد إرسال طلب إيداع بقيمة $amount $currency إلى المشرف المالي؟';
  }

  @override
  String get financeWalletInvalidDepositAmount =>
      'أدخل مبلغًا صحيحًا أكبر من صفر.';

  @override
  String get financeWalletWithdrawalRequestSent =>
      'تم إرسال طلب السحب إلى المشرف المالي، والطلب قيد المراجعة.';

  @override
  String get financeWalletDepositRequestSent =>
      'تم إرسال طلب الإيداع إلى المشرف المالي، والطلب قيد المراجعة.';

  @override
  String get financeWalletRequestFailed =>
      'تعذر إرسال الطلب المالي. حاول مرة أخرى.';

  @override
  String get financeWalletHistoryLoadError =>
      'تعذر تحميل طلباتك المالية. اضغط لإعادة المحاولة.';

  @override
  String get financeWalletNoRequests => 'لم ترسل أي طلبات مالية حتى الآن.';

  @override
  String financeWalletPendingNotification(Object count) {
    return 'لديك $count طلبات مالية جديدة من المشرفين بانتظار المراجعة.';
  }

  @override
  String get financeOperationType => 'نوع العملية';

  @override
  String get financeSourceAccount => 'الحساب صاحب الطلب';

  @override
  String get financeRequestApprovalTitle => 'اعتماد الطلب المالي';

  @override
  String get financeRequestRejectionTitle => 'رفض الطلب المالي';

  @override
  String financeRequestApprovalConfirmation(
      Object operation, Object name, Object amount) {
    return 'هل تريد اعتماد طلب $operation الخاص بـ $name بقيمة $amount؟';
  }

  @override
  String get financeRequestApproved =>
      'تم اعتماد الطلب. يتطلب تنفيذ التحويل أو إضافة الرصيد تكامل خدمة الدفع.';

  @override
  String get financeRequestApprovedBadge => 'معتمد';

  @override
  String get financeRequestRejected => 'تم رفض الطلب المالي.';

  @override
  String get financeRequestRejectedBadge => 'مرفوض';

  @override
  String get financeRequestFrozen => 'تم تجميد الطلب المالي للتحقيق.';

  @override
  String get financeRequestDecisionFailed =>
      'تعذر حفظ القرار، ولم يتم تغيير الطلب.';

  @override
  String get servicesWalletHistoryTitle => 'سجل العمليات المالية';

  @override
  String get servicesWalletFullStatement => 'عرض الكل';

  @override
  String get servicesWalletStatementNotice =>
      'سجل الطلبات محفوظ على هذا الجهاز فقط وغير متزامن مع خادم أو خدمة مالية.';

  @override
  String get servicesWalletHistoryInstapay => 'تحويل إنستاباي';

  @override
  String get servicesWalletHistoryOneDate => 'اليوم · 10:30 ص';

  @override
  String get servicesWalletStatusCompleted => 'مكتمل';

  @override
  String get servicesWalletHistoryBank => 'تحويل بنكي';

  @override
  String get servicesWalletHistoryTwoDate => 'أمس · 02:15 م';

  @override
  String get servicesWalletHistoryReview => 'طلب سحب';

  @override
  String get servicesWalletHistoryThreeDate => '18 مايو 2025 · 11:20 ص';

  @override
  String get servicesWalletHistoryNewRequest => 'طلب سحب جديد';

  @override
  String get servicesWalletHistoryJustNow => 'الآن';

  @override
  String get servicesWalletStatusReview => 'قيد المراجعة';

  @override
  String get servicesWalletComplianceTitle => 'تنويه رقابي';

  @override
  String get servicesWalletComplianceBody =>
      'الأرصدة المعروضة تجريبية. تُحفظ الطلبات محليًا لموافقة المشرف المالي؛ ولا يحدث تحويل أو إيداع فعلي أو إشعار فوري أو إرسال إلى خادم.';

  @override
  String get servicesWalletAmountError =>
      'أدخل مبلغًا أكبر من صفر ولا يتجاوز الرصيد المتاح.';

  @override
  String get servicesWalletDestinationError =>
      'أدخل بيانات الوجهة قبل إرسال الطلب.';

  @override
  String get servicesWalletConfirmTitle => 'تأكيد طلب السحب';

  @override
  String servicesWalletConfirmMessage(Object amount, Object currency) {
    return 'هل تريد إضافة طلب سحب بقيمة $amount $currency إلى السجل التجريبي؟';
  }

  @override
  String get servicesWalletRequestSent =>
      'أُضيف الطلب إلى السجل التجريبي فقط، ولم يُرسل إلى جهة مالية.';

  @override
  String get servicesProfileAdministrationTitle =>
      'البيانات الإدارية والاعتمادات';

  @override
  String get servicesProfileDelegationTitle => 'التفويض المهني واعتماد الإشراف';

  @override
  String get servicesProfileDelegationDetail =>
      'ساري المفعول حتى 1447/06/30 هـ';

  @override
  String get servicesProfileActive => 'مفعل';

  @override
  String get servicesProfileNotificationsTitle => 'تنبيهات البلاغات الفورية';

  @override
  String get servicesProfileNotificationsDetail =>
      'إشعار فوري للمهام ذات الأولوية العالية';

  @override
  String get servicesProfileEnabled => 'مفعل';

  @override
  String get servicesProfileAuditTitle => 'سجل نشاطات المشرف والتدقيق';

  @override
  String get servicesProfileAuditDetail =>
      'سجل الإجراءات ومراجعات التشغيل الميدانية';

  @override
  String get servicesProfileLogout => 'تسجيل الخروج من الجلسة الإشرافية';

  @override
  String get servicesProfileFooter =>
      'بوابة إدارة الخدمات الميدانية · الإصدار 2.4.1';

  @override
  String get servicesReviewTab => 'قيد المراجعة';

  @override
  String get servicesProvidersTab => 'مقدمو الخدمة';

  @override
  String get servicesComplaintsTab => 'الشكاوى';

  @override
  String get servicesReviewTitle => 'طلبات الخدمات قيد المراجعة';

  @override
  String get servicesReviewSubtitle =>
      'فحص الطلبات والتحقق من الأعمال الفنية وإسناد التشغيل';

  @override
  String servicesNewRequestsCount(Object count) {
    return '$count جديدة';
  }

  @override
  String get servicesCompletedToday => 'الطلبات المعتمدة';

  @override
  String get servicesAwaitingDecision => 'بانتظار القرار';

  @override
  String get servicesFilterAll => 'الكل';

  @override
  String get servicesFilterMaintenance => 'صيانة وأجهزة';

  @override
  String get servicesFilterElectrical => 'كهرباء وتمديدات';

  @override
  String get servicesFilterMoving => 'نقل وترتيب';

  @override
  String get servicesRequestsEmpty => 'لا توجد طلبات مطابقة لهذا التصنيف.';

  @override
  String get servicesUnderReview => 'قيد المراجعة';

  @override
  String get servicesUrgent => 'عاجل';

  @override
  String get servicesVerifiedProvider => 'فني موثق';

  @override
  String get servicesWorkDescription => 'بيان الأعمال المطلوبة:';

  @override
  String get servicesCurrency => 'ج.م';

  @override
  String get servicesUrgentNotice =>
      'تنبيه تأخير ميداني: يرجى مراجعة الموعد والتواصل مع مزود الخدمة.';

  @override
  String get servicesApproveAction => 'قبول الطلب';

  @override
  String get servicesRejectAction => 'رفض الطلب';

  @override
  String get servicesViewDetails => 'معاينة تفاصيل الطلب الفنية';

  @override
  String get servicesApproveTitle => 'هل أنت متأكد من قبول الطلب؟';

  @override
  String get servicesRejectTitle => 'رفض طلب الخدمة';

  @override
  String get servicesApproveMessage =>
      'سيتم قبول الطلب وإزالته من قائمة المراجعة الحالية.';

  @override
  String get servicesRejectMessage =>
      'سيتم رفض الطلب وإزالته من قائمة المراجعة الحالية.';

  @override
  String get servicesRequestApproved =>
      'تم تحديث حالة الطلب في قائمة المراجعة.';

  @override
  String get servicesRequestRejected => 'تم رفض الطلب.';

  @override
  String servicesRequestRejectedWithReason(String reason) {
    return 'تم رفض الطلب. السبب: $reason';
  }

  @override
  String get servicesFeaturedRequest => 'إعلان مميز';

  @override
  String get servicesCommentAction => 'تعليق';

  @override
  String get servicesCommentTitle => 'إضافة تعليق على الطلب';

  @override
  String get servicesCommentHint => 'اكتب تعليقك أو ملاحظاتك على الطلب...';

  @override
  String get servicesCommentSave => 'حفظ التعليق';

  @override
  String get servicesCommentSaved => 'تم حفظ التعليق على الطلب.';

  @override
  String get servicesDecisionProvider => 'مقدم الخدمة';

  @override
  String get servicesDecisionDiagnosticFee => 'التكلفة المقدرة';

  @override
  String get servicesApprovalNotification =>
      'سيتم إشعار العميل ومقدم الخدمة بقبول الطلب وإتاحته للتنفيذ.';

  @override
  String get servicesApproveConfirmPublish => 'تأكيد النشر والقبول';

  @override
  String get servicesRejectionQuickReasons => 'نماذج أسباب سريعة';

  @override
  String get servicesRejectionReasonScope => 'خارج النطاق الجغرافي';

  @override
  String get servicesRejectionReasonDetails => 'بيانات العمل غير مكتملة';

  @override
  String get servicesRejectionReasonTerms => 'مخالفة شروط الخدمة';

  @override
  String get servicesRejectionReasonLabel => 'سبب الرفض الإلزامي';

  @override
  String get servicesRejectionReasonHint => 'اكتب سبب الرفض بالتفصيل...';

  @override
  String get servicesRejectionAuditNote =>
      'سيتم تسجيل سبب الرفض وإشعار العميل به مع توثيق الإجراء في سجل الطلب.';

  @override
  String get servicesRejectConfirm => 'تأكيد رفض الطلب';

  @override
  String get servicesProvidersComingSoon =>
      'سيتم تجهيز صفحة إدارة واعتماد مقدمي الخدمة في المرحلة التالية.';

  @override
  String get servicesProvidersPortalBadge => 'بوابة الإسناد والفرز الميداني';

  @override
  String get servicesProvidersTitle => 'مقدمو الخدمات المتاحين';

  @override
  String get servicesProvidersSubtitle =>
      'قاعدة بيانات مزودي الخدمة المعتمدين والموثوقين والمهيئين للمطابقة والإسناد المباشر';

  @override
  String get servicesCertifiedProviders => 'مزود معتمد';

  @override
  String get servicesAvailableNow => 'متاح الآن';

  @override
  String get servicesCommitmentRate => 'نسبة الالتزام';

  @override
  String get servicesProvidersSearchHint =>
      'ابحث بالاسم، السجل التجاري، التخصص أو الحي...';

  @override
  String get servicesProvidersClearSearch => 'مسح البحث';

  @override
  String get servicesProvidersFilterPlumbing => 'سباكة';

  @override
  String get servicesProvidersEmpty =>
      'لا يوجد مقدمو خدمة يطابقون البحث أو التصنيف المحدد.';

  @override
  String get servicesProvidersAvailable => 'متاح فوراً';

  @override
  String get servicesProvidersBusy => 'في مهمة حالياً';

  @override
  String get servicesProvidersCommercialRegister => 'سجل تجاري موثق';

  @override
  String get servicesProvidersLicense => 'ترخيص مهني معتمد';

  @override
  String get servicesProvidersServiceTerms => 'استجابة خلال 15 دقيقة';

  @override
  String get servicesProvidersExecutionWindow =>
      'متاح بعد ساعتين (03:30 م تقريباً)';

  @override
  String servicesProvidersTasksCount(Object count) {
    return '$count مهمة منجزة';
  }

  @override
  String servicesProvidersCommitment(Object rate) {
    return 'التزام $rate';
  }

  @override
  String get servicesProvidersViewProfile => 'عرض ملف مقدم الخدمة وسجله';

  @override
  String get servicesProvidersGovernanceTitle => 'حوكمة بيانات وسجلات المزودين';

  @override
  String get servicesProvidersGovernanceMessage =>
      'صلاحية المشرف الميداني تقتصر على الفرز والمطابقة وإسناد الطلبات. تعديل السجلات الثابتة أو اعتماد مزودين جدد يتطلب تفويضاً إلكترونياً لإدارة شؤون المزودين والتراخيص المركزية.';

  @override
  String get servicesProvidersSpecialty => 'التخصص الفني';

  @override
  String get servicesProvidersRegisteredSkills => 'المهارات المسجلة';

  @override
  String get servicesProvidersCoverage => 'نطاق التغطية';

  @override
  String get servicesProvidersRating => 'تقييم العملاء';

  @override
  String get servicesProvidersCompletedTasks => 'المهام المكتملة';

  @override
  String get servicesProvidersSampleProfileNotice =>
      'بيانات الملف والسجل المعروض تجريبية وتحتاج ربطها ببيانات مزودي الخدمة.';

  @override
  String get servicesProviderProfileTitle => 'الملف والسجل المهني للمزود';

  @override
  String get servicesProviderProfileRegistryNumber => 'رقم المزود';

  @override
  String get servicesProviderProfileVerified =>
      'بيانات المزود واعتماداته موثقة';

  @override
  String get servicesProviderProfileFeatured => 'مزود مميز';

  @override
  String get servicesProviderProfileNeedsReview => 'يحتاج إلى مراجعة';

  @override
  String get servicesProviderProfileCall => 'اتصال';

  @override
  String get servicesProviderProfileChat => 'محادثة';

  @override
  String get servicesProviderProfileCallUnavailable =>
      'تعذر بدء الاتصال من هذا الجهاز.';

  @override
  String get servicesProviderProfileCertifications => 'التراخيص والاعتمادات';

  @override
  String get servicesProviderProfileSpecialties => 'التخصصات وفرق العمل';

  @override
  String get servicesProviderProfileFieldTeam => 'فريق العمل الميداني';

  @override
  String get servicesProviderProfileApprovedTeam => 'فريق معتمد ومتاح للإسناد';

  @override
  String get servicesProviderProfileRecentTasks =>
      'أحدث المهام والعمليات المنجزة';

  @override
  String get servicesProviderProfileTaskDetail =>
      'تم تنفيذ الخدمة ومراجعتها من العميل.';

  @override
  String get servicesProviderProfileTaskCompleted => 'مكتمل';

  @override
  String get servicesProviderProfileTaskRecord => 'عرض السجل';

  @override
  String get servicesProviderProfileCompletedTasksDetail => 'مهمة موثقة';

  @override
  String get servicesProviderProfileRatingDetail => 'تقييم العملاء';

  @override
  String get servicesProviderProfileCommitmentDetail =>
      'نسبة الالتزام بالمواعيد';

  @override
  String get servicesProviderProfileResponseTime => 'سرعة الاستجابة';

  @override
  String get servicesProviderProfileMinutes => 'دقيقة';

  @override
  String get servicesChatsTitle => 'محادثات الخدمات';

  @override
  String get servicesComplaintsTitle => 'شكاوى وبلاغات الخدمات';

  @override
  String get servicesComplaintsSubtitle =>
      'معالجة النزاعات الميدانية وضمان جودة التنفيذ وإجراءات الضمان';

  @override
  String get servicesComplaintActive => 'الشكاوى النشطة';

  @override
  String get servicesComplaintUrgent => 'عاجلة';

  @override
  String get servicesComplaintPriorityMedium => 'متوسطة الأولوية';

  @override
  String get servicesComplaintResolutionTime => 'معدل الحل';

  @override
  String get servicesComplaintMinutes => 'دقيقة';

  @override
  String get servicesComplaintSatisfaction => 'رضا العملاء';

  @override
  String get servicesComplaintApproved => 'رضا معتمد';

  @override
  String get servicesComplaintSearchHint =>
      'بحث برقم الشكوى أو اسم العميل أو المزود...';

  @override
  String get servicesComplaintFilterAll => 'الكل';

  @override
  String get servicesComplaintFilterInvestigating => 'قيد الفحص';

  @override
  String get servicesComplaintFilterWaiting => 'بانتظار الرد';

  @override
  String get servicesComplaintFilterClosed => 'تم الحل';

  @override
  String get servicesComplaintNoResults =>
      'لا توجد شكاوى تطابق البحث أو المرشح.';

  @override
  String servicesComplaintAgeMinutes(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String servicesComplaintAgeHours(int count) {
    return 'منذ $count ساعتين';
  }

  @override
  String get servicesComplaintClient => 'العميل الشاكي';

  @override
  String get servicesComplaintProvider => 'المزود المشكو ضده';

  @override
  String get servicesComplaintClientOne => 'د. مها الدبيسي';

  @override
  String get servicesComplaintClientTwo => 'سارة العتيبي';

  @override
  String get servicesComplaintClientThree => 'العميل فهد';

  @override
  String get servicesComplaintProviderOne => 'مؤسسة التبريد المتقن';

  @override
  String get servicesComplaintProviderTwo => 'فريق الإتقان الشامل';

  @override
  String get servicesComplaintProviderThree => 'فهد الأرجحي';

  @override
  String servicesComplaintProviderId(String id) {
    return 'طلب مرتبط: $id';
  }

  @override
  String get servicesComplaintRiyadh => 'الرياض';

  @override
  String get servicesComplaintSubjectOne => 'صيانة مكيفات سبليت وتبريد';

  @override
  String get servicesComplaintDescriptionOne =>
      'تسرب مياه مستمر من الوحدة الداخلية بعد الصيانة. تمت مراجعة البلاغ وتحديد موعد للفحص الميداني للتأكد من جودة تنفيذ الضمان.';

  @override
  String get servicesComplaintSubjectTwo => 'تجديدات كهربائية وإعدادات ذكية';

  @override
  String get servicesComplaintDescriptionTwo =>
      'تجاوز الموعد المحدد للزيارة الميدانية ساعة كاملة دون تقديم اعتذار أو إشعار مسبق بتأخر الفني.';

  @override
  String get servicesComplaintSubjectThree => 'نقل وتركيب أثاث غرفة نوم';

  @override
  String get servicesComplaintDescriptionThree =>
      'تمت معالجة الطلب واعتماده بعد تأكيد العميل استلام الخدمة.';

  @override
  String get servicesComplaintLocationOne => 'حي النرجس، الرياض';

  @override
  String get servicesComplaintLocationTwo => 'حي الملقا، الرياض';

  @override
  String get servicesComplaintLocationThree => 'حي الياسمين، الرياض';

  @override
  String get servicesComplaintPriceOne => '280';

  @override
  String get servicesComplaintPriceTwo => '450';

  @override
  String get servicesComplaintPriceThree => '1,200';

  @override
  String get servicesComplaintClosedToday => 'أغلقت اليوم 11:30 ص';

  @override
  String get servicesComplaintUnderReview => 'قيد فحص المشرف';

  @override
  String get servicesComplaintWaitingProvider => 'بانتظار إفادة المزود';

  @override
  String get servicesComplaintClosed => 'تم الحل والإغلاق';

  @override
  String get servicesComplaintInvestigateAndResolve =>
      'معاينة وبدء التحقيق والحل';

  @override
  String get servicesComplaintContactParties => 'تواصل مع الطرفين';

  @override
  String servicesComplaintGroupChatTitle(String id) {
    return 'محادثة الشكوى $id';
  }

  @override
  String get servicesComplaintReassign => 'إعادة إسناد فوري';

  @override
  String get servicesComplaintEscalate => 'تصعيد لرئيس المشرفين';

  @override
  String get servicesComplaintShowResolution => 'عرض محضر الصلح';

  @override
  String get servicesComplaintResolutionRecorded =>
      'الإجراء الإشرافي المعتمد: تم حل المشكلة ميدانياً مع تعويض العميل عن التأخير.';

  @override
  String get servicesComplaintClosedAudit => 'سجل تدقيق مغلق غير قابل للتعديل';

  @override
  String get servicesComplaintResolutionTitle => 'جودة حل النزاعات الميدانية';

  @override
  String get servicesComplaintResolutionDescription =>
      'يمتلك مشرف الخدمات صلاحية التصالح وجدولة زيارات التنفيذ وإجراءات الضمان، مع إمكانية إعادة الإسناد لمزود بديل.';

  @override
  String get servicesComplaintDetails => 'تفاصيل الشكوى';

  @override
  String get servicesComplaintActionConfirmation =>
      'سيتم تسجيل الإجراء في سجل الشكوى وإشعار الأطراف المرتبطة. هل تريد المتابعة؟';

  @override
  String get servicesComplaintEscalationConfirmation =>
      'سيتم إحالة الشكوى إلى رئيس المشرفين للمراجعة. هل تريد التصعيد؟';

  @override
  String get servicesComplaintEscalated => 'تم التصعيد';

  @override
  String servicesComplaintEscalatedNotice(String id) {
    return 'تم تصعيد الشكوى $id إلى رئيس المشرفين.';
  }

  @override
  String get servicesComplaintContactNotice =>
      'تم فتح خيارات التواصل مع العميل ومزود الخدمة.';

  @override
  String get servicesComplaintActionRecorded =>
      'تم تسجيل الإجراء وإشعار الأطراف.';

  @override
  String get servicesNoNewNotifications => 'لا توجد إشعارات جديدة.';

  @override
  String get servicesNotificationsTitle => 'الإشعارات';

  @override
  String get servicesDetailsTitle => 'معاينة وتفاصيل الطلب';

  @override
  String get servicesRequestWorkDetailsTitle => 'تفاصيل الخدمة وموقع التنفيذ';

  @override
  String get servicesRequestLocationLabel => 'عنوان الخدمة';

  @override
  String get servicesRequestPhotosTitle => 'صور الخدمة المرفقة';

  @override
  String get servicesRequestNoPhotos => 'لا توجد صور مرفقة مع هذا الطلب.';

  @override
  String get servicesRequestAssignmentTitle => 'إسناد الخدمة لمقدم خدمة';

  @override
  String get servicesRequestAssignmentDescription =>
      'اختر مقدم خدمة متاحاً ومطابقاً لتصنيف الخدمة من قائمة مقدمي الخدمات.';

  @override
  String get servicesRequestChooseProvider => 'اختر مقدم الخدمة';

  @override
  String get servicesRequestNoMatchingProviders =>
      'لا يوجد مقدمو خدمة متاحون لهذا التصنيف حالياً.';

  @override
  String get servicesRequestAssignProvider => 'إسناد الخدمة';

  @override
  String servicesRequestAssigned(String provider) {
    return 'تم إسناد الخدمة إلى $provider';
  }

  @override
  String get servicesComplaintPartiesTitle => 'طرفا النزاع والتواصل';

  @override
  String get servicesComplaintProblemTitle => 'بيان المشكلة المسجلة';

  @override
  String get servicesComplaintFiledBy => 'الطرف الشاكي';

  @override
  String get servicesComplaintServiceInfoTitle => 'بيانات الخدمة محل الشكوى';

  @override
  String get servicesComplaintPriceLabel => 'سعر الخدمة';

  @override
  String get servicesComplaintPhotosTitle => 'صور المشكلة المرفقة';

  @override
  String get servicesComplaintNoPhotos => 'لا توجد صور مرفقة للمشكلة.';

  @override
  String get servicesBackToRequests => 'العودة إلى الطلبات';

  @override
  String get servicesCallPhone => 'اتصال هاتف';

  @override
  String get servicesContactWhatsApp => 'محادثة واتساب';

  @override
  String get servicesEstimatedCost => 'التكلفة التقديرية للخدمة';

  @override
  String get servicesApprovedEstimate => 'تقدير آلي معتمد';

  @override
  String get servicesEstimatedCostTotal => 'إجمالي التكلفة المقدرة';

  @override
  String get servicesInspectionFee => 'رسوم الكشف المبدئي';

  @override
  String get servicesLaborAndPartsFee => 'تكلفة العمل وقطع الغيار';

  @override
  String get servicesRequestMoreInfoTitle =>
      'طلب معلومات وتوضيحات إضافية من العميل';

  @override
  String get servicesRequestMoreInfoDescription =>
      'في حال عدم وضوح بيانات الطلب أو الحاجة لمعلومات إضافية لإتمام الفحص قبل التعيين، أرسل استفساراً مباشراً للعميل.';

  @override
  String get servicesRequestMoreInfoHint =>
      'اكتب استفسارك أو التفاصيل المطلوبة من العميل هنا...';

  @override
  String get servicesRequireExtraPhotos => 'إلزام بإرفاق صور توضيحية إضافية';

  @override
  String get servicesSendInfoRequest => 'إرسال الطلب';

  @override
  String get servicesInfoRequestRequired =>
      'اكتب تفاصيل الاستفسار قبل الإرسال.';

  @override
  String get servicesInfoRequestSent => 'تم إرسال طلب المعلومات للعميل.';

  @override
  String get servicesEditClassification => 'تعديل التصنيف الفني للخدمة';

  @override
  String get servicesCurrentClassification => 'التصنيف الفني المعتمد حالياً';

  @override
  String get servicesApprovedClassification => 'التصنيف المعتمد للطلب';

  @override
  String get servicesExecutionPeriod => 'فترة التنفيذ المناسبة';

  @override
  String get servicesDayPeriod => 'صباحية (09:00 ص - 01:00 م)';

  @override
  String get servicesEveningPeriod => 'مسائية (04:00 م - 09:00 م)';

  @override
  String get servicesSaveClassification => 'تحديث وحفظ التصنيف';

  @override
  String get servicesClassificationSaved =>
      'تم حفظ تصنيف الخدمة وفترة التنفيذ.';

  @override
  String get servicesContactUnavailable => 'تعذر بدء التواصل من هذا الجهاز.';

  @override
  String get servicesPublishConfirm => 'تأكيد نشر الطلب';

  @override
  String get deliveryLogisticsWalletTitle => 'محفظة مناديب التوصيل واللوجستيات';

  @override
  String get deliveryLogisticsWalletDesc =>
      'أجور ومستحقات الشحن والتسليم الميداني';

  @override
  String get instantLiquidityAdequacyRatio =>
      'مؤشر كفاية السيولة المصرفية الفورية';

  @override
  String get verySafeAndStable => 'آمن ومستقر جداً';

  @override
  String get dailyWithdrawalCoverageRatio => 'نسبة تغطية طلبات السحب اليومية';

  @override
  String get excessCashCoverage => 'تغطية نقدية فائضة';

  @override
  String get statutoryMinimumRequirement =>
      'الحد الأدنى النظامي المشترط: 85.0%';

  @override
  String get autoBankingSettlement =>
      'التسوية المصرفية التلقائية عبر نظام سداد & SARIE: مكتملة ومطابقة 100%';

  @override
  String get governancePolicyNotice =>
      'وفق لائحة الحوكمة والسياسات المالية: المشرفون الميدانيون ورؤساء الأقسام لا يملكون أي صلاحية لتعديل الأرصدة أو السحب أو التحويل البنكي. تنفيذ وتوثيق العمليات المالية حصري للمدير المالي المعتمد برقم تفويض مصرفي رسمي.';

  @override
  String get governancePolicyClause => 'بند #04 - أ';

  @override
  String get urgentWithdrawalsAction =>
      'مراجعة طلبات السحب العاجلة (14 طلباً جاهزاً للصرف)';

  @override
  String get exportDailyReportPdf =>
      'تصدير تقرير السيولة والمركز المالي اليومي (PDF)';

  @override
  String get liquidityDistributedOnChannels =>
      'السيولة الموزعة على القنوات المصرفية';

  @override
  String get liveBankingReconciliation =>
      'مطابقة بنكية حية (SARI/SARIE نشط 100%)';

  @override
  String get instantSync => 'تزامن فوري';

  @override
  String get mainBanksCount => '3 بنوك رئيسية';

  @override
  String get instaPayCount => '2 إنستاباي InstaPay';

  @override
  String get digitalWalletsCount => '2 محافظ رقمية';

  @override
  String get officialBankAccountsAndIban =>
      'الحسابات البنكية الرسمية وحسابات الآيبان';

  @override
  String get bankAccountsScreenSubtitle =>
      'إدارة السيولة والمطابقة مع الشبكة السعودية للمدفوعات';

  @override
  String get refreshBalances => 'تحديث الأرصدة';

  @override
  String get noAccountsInCategory => 'لا توجد حسابات مسجلة ضمن هذا التصنيف';

  @override
  String get operationalAccountsFilter => 'حسابات تشغيلية';

  @override
  String get escrowAccountsFilter => 'حسابات ضمان Escrow';

  @override
  String get paymentGatewaysFilter => 'بوابات الدفع الإلكتروني';

  @override
  String get digitalWalletsFilter => 'المحافظ الرقمية';

  @override
  String get instantBankSyncNote =>
      'تحديث ومطابقة تلقائية متزامنة مع كافة القنوات';

  @override
  String get createBankAccount => 'إضافة حساب جديد';

  @override
  String get exportAccountStatementButton => 'تصدير كشف PDF';

  @override
  String get openDailyLedger => 'سجل الحركات المصرفية والعمليات اليومية';

  @override
  String get dailyLedgerDescription =>
      'عرض قيود اليومية، الإيداعات، والحوالات الصادرة والواردة';

  @override
  String get escrowAccountBadge => 'حساب ضمان';

  @override
  String get availableLedgerBalanceLabel => 'الرصيد الدفتري المتاح:';

  @override
  String get ibanOrIdentifierLabel => 'الآيبان / المعرّف:';

  @override
  String get connectedReconciledViaSarie => 'متصل ومطابق لحظياً عبر SARIE';

  @override
  String get linkBankAccountTitle => 'ربط حساب مصرفي جديد';

  @override
  String get enterBankDetailsToApprove => 'أدخل تفاصيل الحساب المصرفي للاعتماد';

  @override
  String get bankNameField => 'اسم البنك';

  @override
  String get accountTypeField => 'نوع الحساب / التصنيف';

  @override
  String get ibanField => 'رقم الآيبان (IBAN)';

  @override
  String get editBankAccountAction => 'تعديل بيانات الحساب';

  @override
  String get bankEditNotice =>
      'لن تتغير بيانات الحساب المعتمدة الآن. سيُرسل طلب التعديل للأدمن للموافقة أو الرفض.';

  @override
  String get bankEditSubmitAction => 'حفظ وإرسال للأدمن';

  @override
  String get bankEditPendingStatus => 'طلب تعديل بانتظار قرار الأدمن';

  @override
  String get bankEditPendingDetails => 'البيانات المقترحة';

  @override
  String get bankEditRequestNumber => 'رقم الطلب';

  @override
  String get bankEditSubmitting => 'جارٍ إرسال الطلب...';

  @override
  String get bankEditRequestSent =>
      'تم إرسال طلب التعديل للأدمن. ستظل بيانات الحساب الحالية معتمدة حتى صدور القرار.';

  @override
  String get bankEditRequestFailed => 'تعذر إرسال طلب التعديل. حاول مرة أخرى.';

  @override
  String get bankEditRequired => 'هذا الحقل مطلوب';

  @override
  String get bankEditNoChanges => 'لم يتم تغيير أي بيانات';

  @override
  String get bankLinkRequestSent => 'تم إرسال طلب الربط';

  @override
  String get saveAccount => 'حفظ الحساب';

  @override
  String get exportAccountsTitle => 'تصدير كشف الحسابات';

  @override
  String get pdfReportExplanation =>
      'سيتم توليد تقرير رسمي مفصل بصيغة PDF بجميع الأرصدة المصرفية المتطابقة.';

  @override
  String get download => 'تحميل';

  @override
  String get cancelAction => 'إلغاء';

  @override
  String get accountsExportSuccess => 'تم تصدير كشف الحسابات بنجاح';

  @override
  String get accountsCount => '3 حسابات';

  @override
  String get collectionAndDistribution => 'تحصيل وتوزيع';

  @override
  String get sadadAndSarie => 'سداد & SARIE';

  @override
  String get frozenEscrowAccount => 'حساب مجمد للأمانات';

  @override
  String get emergencyAccount => 'حساب الطوارئ والتسويات البنكية الفورية';

  @override
  String get approvedT0 => 'معتمد T+0';

  @override
  String get dailyLedgerBalance => 'الرصيد الدفتري الحالي';

  @override
  String get ibanNumber => 'رقم الآيبان (IBAN)';

  @override
  String get internalAccountNumber => 'رقم الحساب الداخلي';

  @override
  String get dailyLogLedger => 'سجل الحركات اليومية';

  @override
  String get reviewHeldEscrow => 'مراجعة المحتجزات';

  @override
  String get reconciliationDisputesNote =>
      'خاضع للمطابقة المالية الآلية مع بوابة النزاعات';

  @override
  String get approvedEWallets => 'المحافظ الإلكترونية المعتمدة (E-Wallets)';

  @override
  String get walletsCount => 'محفظتان';

  @override
  String get stcPayEnterprise => 'محفظة stc pay للأعمال (Enterprise)';

  @override
  String get apiConnected => 'مربوطة API';

  @override
  String get actualWalletBalance => 'الرصيد الفعلي في المحفظة';

  @override
  String get withdrawalFeesFree => 'رسوم السحب: مجاناً (اتفاقية شركات)';

  @override
  String get urpayBusiness => 'محفظة urpay (يورباي للأعمال)';

  @override
  String get activeStatus => 'نشطة';

  @override
  String get salarySupportDisbursement => 'صرف رواتب مساندة';

  @override
  String get feedWalletBalance => 'تغذية رصيد المحفظة';

  @override
  String get bankingGovernanceAuthNote =>
      'تعديل أو سحب أو إلغاء ربط أي قناة مصرفية يخضع لمعايير الأمن المالي المشدد، ويتطلب مصادقة ثنائية عبر منصة نفاذ (2FA) ومصادقة التوقيع الإلكتروني المشفر (SHA-256) للمدير المالي التنفيذي.';

  @override
  String get addNewBankAccount => 'إضافة حساب بنكي أو قناة دفع جديدة';

  @override
  String get exportAccountsStatementPdf => 'تصدير بيان الحسابات (PDF)';

  @override
  String get exportDetailedStatementExcel => 'بيان تفصيلي (Excel)';

  @override
  String get bankingAndCashSurveillanceGateway =>
      'بوابة الصرف والرقابة النقدية';

  @override
  String get merchantWithdrawalsHeaderTitle =>
      'طلبات سحب مستحقات التجار و المستخدمين و المناديب';

  @override
  String get merchantWithdrawalsHeaderSubtitle =>
      'قائمة طلبات السحب النقدي المعتمدة للمتاجر والمزودين';

  @override
  String get pendingRequests => 'الطلبات المعلقة';

  @override
  String get underRegulatoryHold => 'تحت الاحتراز';

  @override
  String get regulatoryFreeze => 'تجميد رقابي';

  @override
  String get allTab => 'الكل';

  @override
  String get merchantsTab => 'التجار';

  @override
  String get usersTab => 'المستخدمين';

  @override
  String get verifiedViaNafath => 'معتمد ومطابق عبر النفاذ الموحد';

  @override
  String get underReviewStatus => 'قيد المراجعة';

  @override
  String get grossAmount => 'إجمالي المبلغ المطلوب (Gross):';

  @override
  String get platformFee => 'عمولة المنصة والخدمات';

  @override
  String get netTransferredAmount => 'صافي المبلغ المحول للحساب البنكي:';

  @override
  String get receivingBank => 'المصرف المستلم:';

  @override
  String get submissionDate => 'تاريخ تقديم الطلب:';

  @override
  String get automatedTaxAuditResult =>
      'نتيجة الفحص الآلي للمطابقة الضريبية والمحفظة';

  @override
  String get automatedTaxAuditDetails =>
      'مطابقة الفواتير: 100% | لا توجد بلاغات نزاع أو شكاوى نشطة | رصيد المحفظة مغطى بالكامل ومطابق لصافي التحصيلات التشغيلية.';

  @override
  String get approveAndSendToAdmin => 'اعتماد و ارسال الطلب للادارة';

  @override
  String get freezeRequestTemporarily => 'تجميد مؤقت للطلب';

  @override
  String get readyForInstantDisbursement => 'جاهز للصرف';

  @override
  String get readyForInstantBankingTransfer =>
      'معتمد من النظام - جاهز للإرسال البنكي عبر شبكة سريع';

  @override
  String get approveAndIssueBankOrder => 'اعتماد و اعطاء أمر الصرف البنكي';

  @override
  String get temporarilySuspendedForAudit => 'موقوف مؤقتاً للتحقيق الرقابي';

  @override
  String get grossHeldAmount => 'إجمالي المبلغ المطلوب تحت الحظر (Gross):';

  @override
  String get estimatedPlatformFee => 'عمولة المنصة التقديرية';

  @override
  String get netFrozenAmount => 'الصافي المحتجز للتجميد:';

  @override
  String get auditReferenceCode => 'المرجع الرقابي';

  @override
  String get regulatoryNoticeFromSupervisor =>
      'مذكرة إشعار رقابي من مشرف التجار';

  @override
  String get rejectAndNotifyCustomer => 'الرفض و اشعار العميل';

  @override
  String get freezeRequest => 'تجميد الطلب';

  @override
  String get totalAwaitingApproval => 'إجمالي المبالغ بانتظار الاعتماد';

  @override
  String get remainingForReview => 'المتبقي للمراجعة';

  @override
  String get supervisorWithdrawalsHeaderTitle =>
      'طلبات سحب مستحقات المشرفين ومقدمي الخدمة';

  @override
  String get supervisorWithdrawalsHeaderSubtitle =>
      'قائمة طلبات سحب الأتعاب وعمولات الإشراف وأجور الصيانة المعتمدة للصرف';

  @override
  String get awaitingApprovalTab => 'بانتظار الاعتماد';

  @override
  String get platformSupervisorsTab => 'مشرفو المنصة';

  @override
  String get awaitingDisbursementBadge => 'بانتظار الصرف';

  @override
  String get totalFeesAndCommissions => 'إجمالي أتعاب وعمولات الإشراف:';

  @override
  String get netAmountDueForDisbursement => 'صافي المبلغ المستحق للصرف:';

  @override
  String get disbursementSource => 'مصدر المستحقات';

  @override
  String get complianceAndAuditResult => 'نتيجة الفحص الآلي لمطابقة الأداء';

  @override
  String get verifiedIban => 'آيبان موثق';

  @override
  String get fieldCompletionDetails => 'تفاصيل الإنجاز الميداني';

  @override
  String get temporarilySuspendedBadge => 'موقوف مؤقتاً';

  @override
  String get grossClaimedAmount => 'إجمالي المبلغ المطالب به:';

  @override
  String get deductedPlatformFee => 'عمولة المنصة المستقطعة';

  @override
  String get netHeldAmount => 'صافي المبلغ المحجوز احترازياً:';

  @override
  String get requestStatusProtocol =>
      'حالة الطلب: محجوز بموجب بروتوكول حماية الجودة الإشرافي';

  @override
  String get regulatoryNoticeFromServicesSupervisor =>
      'إشعار رقابي من مشرف الخدمات';

  @override
  String get batchApproval => 'اعتماد جماعي';

  @override
  String get samaComplianceNotice =>
      'التحويلات تخضع لمعايير البنك المركزي السعودي (SAMA)';

  @override
  String get subscriptionOrdersTitle => 'طلبات الاشتراكات';

  @override
  String get financialManagementSubtitle => 'برواح المازوري - الإدارة المالية';

  @override
  String get financialAuditAndLicenses => 'الرقابة المالية والتراخيص';

  @override
  String get subscriptionsAndUpgradesReviewTitle =>
      'طلبات الاشتراكات والترقيات';

  @override
  String get subscriptionsAndUpgradesReviewSubtitle =>
      'مراجعة وتفعيل اشتراكات المتاجر ومزودي الخدمات • برواح المازوري';

  @override
  String get currentSubscriptionsCycleSummary => 'موجز دورة الاشتراكات الجارية';

  @override
  String get updatedNow => 'محدث الآن';

  @override
  String get pendingSubscriptionFees => 'رسوم الاشتراكات المعلقة';

  @override
  String get ordersUnderAudit => 'طلباً قيد التدقيق';

  @override
  String get activatedThisMonth => 'المفعلة هذا الشهر';

  @override
  String get revenueGrowth => '+24% نمو إيرادات';

  @override
  String get expiredAwaitingRenewal => 'منتهية بانتظار التجديد';

  @override
  String get autoCommercialAlert => 'تنبيه تجاري آلي';

  @override
  String get couriersTab => 'المناديب';

  @override
  String get advertisementsTab => 'الإعلانات';

  @override
  String get corporateAccount => 'حساب الشركات';

  @override
  String get subscriptionsHistoryTitle =>
      'سجل الاشتراكات والترقيات النشطة وغير النشطة';

  @override
  String get browsePreviousOperations => 'تصفح تاريخ جميع العمليات السابقة';

  @override
  String get openingSubscriptionsRegister => 'جاري فتح السجل...';

  @override
  String get storesAndMerchants => 'المتاجر والتجار';

  @override
  String get serviceProviders => 'مزودو الخدمات';

  @override
  String get awaitingCertificationRequests => 'طلبات بانتظار المصادقة';

  @override
  String get sortByNewest => 'ترتيب حسب الأحدث';

  @override
  String get underMatching => 'قيد المطابقة';

  @override
  String get commercialRegister => 'س.ت:';

  @override
  String get licenseNumber => 'رخصة رقم:';

  @override
  String get premiumMerchantSubscription => 'اشتراك تاجر مميز';

  @override
  String get homeServicesProvider => 'مزود خدمات منزلية';

  @override
  String get targetedPackageType => 'نوع الباقة المستهدفة';

  @override
  String get annualGoldenPackage => 'الباقة الذهبية السنوية';

  @override
  String get proServiceProviderPackage => 'مزود خدمة احترافي';

  @override
  String get taxInclusive15 => 'شامل الضريبة 15%';

  @override
  String get semiAnnualDuration => 'نصف سنوي (6 أشهر)';

  @override
  String get sufficientWalletBalance => 'رصيد كافي بالمحفظة';

  @override
  String get paymentMethod => 'طريقة السداد:';

  @override
  String get directBankTransfer =>
      'تحويل بنكي مباشر (سداد / الراجحي - حساب الشركات)';

  @override
  String get directDeductionFromEscrow =>
      'خصم مباشر من رصيد المحفظة الضامنة (Escrow)';

  @override
  String get availableBalance => 'رصيد متاح';

  @override
  String get previewReceiptAndTransferData => 'معاينة الإيصال وبيانات التحويل';

  @override
  String get autoApprovalReady => 'جاهز للاعتماد التلقائي';

  @override
  String get rejectWithReason => 'رفض مع السبب';

  @override
  String get licensesGovernanceTitle => 'حوكمة اعتماد التراخيص والترقيات';

  @override
  String get licensesGovernanceDesc =>
      'تفعيل الباقات يمنح فوراً الصلاحيات التجارية وأولوية الظهور والإعفاءات الرقابية المحددة في النظام المالي لشركة برواح المازوري. تخضع كافة العمليات للتدقيق المستندي والضريبي اللاحق.';

  @override
  String get certifiedAndDocumentedRecord => 'سجل معتمد وموثق';

  @override
  String get pdfReport => 'تقرير PDF';

  @override
  String get exportExcel => 'تصدير Excel';

  @override
  String get navLiquidity => 'السيولة';

  @override
  String get navWithdrawalOrders => 'طلبات السحب';

  @override
  String get navReconciliation => 'المطابقة';

  @override
  String get navSettlements => 'التسويات';

  @override
  String get navCommissions => 'العمولات';

  @override
  String get navAudit => 'التدقيق';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get profileTitle => 'ملفك الشخصي';

  @override
  String get financialDepartment => 'الإدارة المالية';

  @override
  String get encryptedBit256 => 'تشفير bit-256';

  @override
  String get secureApprovedSession => 'جلسة رقابية آمنة ومصادق عليها';

  @override
  String get cfoAuditingTitle => 'CFO ورئيس التدقيق المالي';

  @override
  String get sovereignApprovalPowers =>
      'صلاحيات الاعتماد السيادي والمصادقة البنكية';

  @override
  String get certifiedAuditorAuthority =>
      'مدقق مالي معتمد • مفوض التوقيع والمصادقة البنكية المزدوجة لدى مؤسسة برواح المازوري';

  @override
  String get officialPhone => 'الهاتف المعتمد';

  @override
  String get corporateEmail => 'البريد المؤسسي';

  @override
  String get enabledNafath => 'نفاذ وطني مفعل';

  @override
  String get authorizationEffectiveFrom => 'سريان الاعتماد الرقابي من: 2027م';

  @override
  String get activeAndReconciled => 'نشط ومطابق';

  @override
  String get duesWalletTitle => 'محفظة المستحقات والأتعاب';

  @override
  String get executiveWalletDescription =>
      'حساب الإدارة والرقابة التنفيذية المباشر';

  @override
  String get totalAccountingDues => 'إجمالي رصيد المستحقات المحاسبية';

  @override
  String get pendingRegulatoryBalance => 'رصيد معلق رقابياً';

  @override
  String get awaitingQuarterlyClose => 'بانتظار الإقفال الربع سنوي';

  @override
  String get approvedWithoutConditions => 'معتمد دون شروط';

  @override
  String get approvedPayoutAccount => 'الحساب المصفي المعتمد للصرف';

  @override
  String get requestOwnerProfitWithdrawal => 'طلب سحب الأرباح من المالك';

  @override
  String get editWithdrawalInformation => 'تعديل معلومات السحب';

  @override
  String get cfoExclusive => 'مقتصرة على CFO';

  @override
  String get sovereignControls => 'التحكم والإجراءات السيادية';

  @override
  String get feesAndCommissionsMatrix => 'مصفوفة الرسوم والعمولات العامة';

  @override
  String get feesAndCommissionsMatrixDesc =>
      'ضبط النسب المئوية للمنصة، اقتطاعات بوابات الدفع الإلكترونية، وتعديل تسعير العمليات التعاقدية.';

  @override
  String get exclusivePermission => 'صلاحية حصرية';

  @override
  String get editMatrix => 'تعديل المصفوفة';

  @override
  String get fastSettlementFees => 'رسوم التسوية السريعة';

  @override
  String get currentBaseCommission => 'العمولة الأساسية الحالية';

  @override
  String get comprehensivePaymentsReports => 'كشف المدفوعات والإيرادات الشامل';

  @override
  String get comprehensivePaymentsReportsDesc =>
      'توليد كشوف التدفقات النقدية، تقارير الضريبة العامة المضافة، وحزم التسويات المصرفية المجمعة.';

  @override
  String get exportDetailedExcel => 'تصدير Excel تفصيلي';

  @override
  String get exportApprovedPdf => 'تصدير PDF معتمد';

  @override
  String get liveDocumented => 'مباشر • موثق';

  @override
  String get auditActivityLog => 'سجل الرقابة وحركات المدير المالي';

  @override
  String get ownerDisputeSettlementApproval => 'مصادقة صرف تسوية نزاع مالك';

  @override
  String get todayAtEleven => 'اليوم 11:00 ص';

  @override
  String get approveDisputeSettlement =>
      'اعتماد صرف تسوية النزاع #CMP-1035 بقيمة 1,200.00 ج.م للعميل د. طارق العمري.';

  @override
  String get referenceCode => 'المرجع:';

  @override
  String get validDigitalSignature => 'توقيع رقمي ساري SHA-256';

  @override
  String get aggregatedProfitWithdrawal => 'اعتماد سحب أرباح مجمعة (SARIE)';

  @override
  String get todayAtNineThirty => 'اليوم 09:30 ص';

  @override
  String get periodicMerchantTransfers =>
      'تحويل مستحقات دورية لـ 12 متجر معتمد عبر نظام المدفوعات الفورية بإجمالي 142,500.00 ج.م.';

  @override
  String get alRajhiBank => 'مصرف الراجحي';

  @override
  String get executedAndPosted => 'منفذة بنكياً ومقيدة';

  @override
  String get precautionaryWalletFreeze => 'تجميد احترازي لمحفظة متجر';

  @override
  String get yesterdayAtFourFifteen => 'أمس 04:15 م';

  @override
  String get suspendMerchantDisbursement =>
      'إيقاف عمليات الصرف لمتجر مستلزمات حاسب (#TRD-304) لوجود شبهة نزاع مدفوعات متكرر.';

  @override
  String get auditNoticeReference => 'إشعار التدقيق #771';

  @override
  String get underInvestigation => 'قيد التحقيق والتدقيق';

  @override
  String get maintenanceCommissionUpdate => 'تحديث عمولة قطاع الصيانة';

  @override
  String get yesterdayAtOneTwenty => 'أمس 01:20 م';

  @override
  String get commissionUpdatedByBoard =>
      'تعديل نسبة العمولة المحصلة إلى 8.0% بموجب قرار مجلس الإدارة رقم BOD-44/B.';

  @override
  String get activeSystemUpdate => 'تحديث نظامي نافذ';

  @override
  String get viewFullAuditActivity =>
      'عرض سجل الرقابة والحركات الكامل (342 حركة موثقة)';

  @override
  String get reconciliationEngine => 'KYC & IBAN VERIFICATION ENGINE';

  @override
  String get reconciliationImmediateCompliance => 'امتثال مصرفي فوري';

  @override
  String get reconciliationPageTitle =>
      'مطابقة الحسابات البنكية ومكافحة الاحتيال';

  @override
  String get reconciliationAuthorityTitle => 'صلاحية إشرافية تنفيذية مقيدة';

  @override
  String get reconciliationAuthorityNotice =>
      'للاطلاع والتحقق والاعتماد مصرح للمدير المالي حصرياً. تعديل بيانات الحساب البنكية ممنوع بتاتاً من قبل المشرفين الميدانيين.';

  @override
  String get reconciliationGovernmentPortal => 'بوابة وثائق وربط حكومي';

  @override
  String get reconciliationGovernmentSync =>
      'تزامن حي ومباشر مع السجل التجاري والبنك المركزي';

  @override
  String get reconciliationConnected => 'متصل';

  @override
  String get reconciliationAccountDetails => 'بيانات المطابقة التفصيلية للحساب';

  @override
  String get reconciliationCommercialName => 'الاسم المعتمد في السجل التجاري';

  @override
  String get reconciliationCommercialEntity =>
      'مؤسسة مدار التقنية لتقنية المعلومات';

  @override
  String get reconciliationBeneficiaryName => 'اسم المستفيد في الحساب البنكي';

  @override
  String get reconciliationBeneficiaryEntity => 'مؤسسة مدار التقنية';

  @override
  String get reconciliationFinalActions =>
      'إجراءات الاعتماد النهائي (حصر صلاحيات المدير المالي):';

  @override
  String get reconciliationApproveAccount =>
      'اعتماد الحساب البنكي وإرساله للإدارة';

  @override
  String get reconciliationApproveSuccess =>
      'تم اعتماد الحساب البنكي وإرساله للإدارة.';

  @override
  String get reconciliationLoadFailed =>
      'تعذر تحميل طلبات ربط الحسابات البنكية.';

  @override
  String get reconciliationNoPendingRequests =>
      'لا توجد طلبات ربط حسابات بنكية بانتظار المراجعة.';

  @override
  String get reconciliationFreezeSuccess => 'تم تجميد الطلب للمراجعة الرقابية.';

  @override
  String get reconciliationFrozenRequestsTitle => 'طلبات ربط الحسابات المجمدة';

  @override
  String get reconciliationFreezeReasonLabel => 'سبب التجميد:';

  @override
  String get reconciliationFreezeDialogDescription =>
      'سيتم تعليق طلب ربط الحساب وتسجيله للمراجعة المالية، وإزالته من قائمة المراجعة النشطة.';

  @override
  String get reconciliationActionFailed =>
      'تعذر تنفيذ الإجراء. يرجى المحاولة مرة أخرى.';

  @override
  String get reconciliationRequestIban => 'طلب شهادة آيبان حديثة ومختومة';

  @override
  String get reconciliationIbanRequestSent =>
      'تم إرسال طلب شهادة آيبان حديثة ومختومة.';

  @override
  String get reconciliationRejectTransfer => 'رفض وتجميد التحويل للحساب';

  @override
  String get reconciliationRejectSuccess =>
      'تم رفض الطلب وتسجيل سبب الرفض للمراجعة.';

  @override
  String get reconciliationComplianceReview =>
      'فحص الامتثال المالي - بوابة وثائق الحكومة';

  @override
  String get reconciliationBusinessName => 'شركة مدار التقنية للتجارة';

  @override
  String get reconciliationNewAccountRequest =>
      'طلب اعتماد حساب بنكي رئيسي جديد للصرف الدوري';

  @override
  String get reconciliationAmlScore => 'مؤشر توافق المعايير الرقابية (AML/CFT)';

  @override
  String get reconciliationAmlMatched =>
      'تطابق آمن وفق بروتوكول مكافحة غسل الأموال وتمويل الإرهاب.';

  @override
  String get reconciliationMatchVerified => 'مطابق 100%  ✓';

  @override
  String get reconciliationBankName => 'مصرف الراجحي';

  @override
  String get reconciliationIbanLabel =>
      '3. رقم الحساب الدولي (IBAN) والجهة البنكية';

  @override
  String get reconciliationRegistrationLabel =>
      '4. السجل التجاري وحالة الصلاحية';

  @override
  String get reconciliationValidUntil => 'ساري المفعول حتى 1447/06/15هـ';

  @override
  String get reconciliationPreviewDocument => 'معاينة';

  @override
  String get reconciliationDocumentPreviewToast =>
      'معاينة مستند doc-iban-5501.pdf';

  @override
  String get reconciliationNextAccount => 'الحساب التالي في قائمة الانتظار';

  @override
  String get reconciliationQueueTitle => 'قائمة طلبات المطابقة';

  @override
  String get reconciliationSearchHint =>
      'ابحث بالاسم أو رقم الطلب أو البنك أو الآيبان';

  @override
  String get reconciliationFilterAll => 'الكل';

  @override
  String get reconciliationFilterAttention => 'تحتاج إلى مراجعة';

  @override
  String get reconciliationNeedsAttention => 'مراجعة';

  @override
  String get reconciliationNoMatchingRequests =>
      'لا توجد طلبات مطابقة لخيارات البحث.';

  @override
  String get reconciliationAwaitingManagement => 'بانتظار اعتماد الإدارة';

  @override
  String get reconciliationAwaitingCertificate => 'بانتظار شهادة آيبان محدثة';

  @override
  String get reconciliationInProgressTab => 'قيد الإجراء';

  @override
  String get reconciliationArchiveTab => 'الأرشيف';

  @override
  String get reconciliationArchiveEmpty => 'لا توجد طلبات في الأرشيف.';

  @override
  String get reconciliationDecisionReason => 'سبب القرار';

  @override
  String get reconciliationNextBusiness => 'متجر السهيلة للعطور';

  @override
  String get reconciliationNextBank =>
      'البنك الأهلي السعودي  •  SA22 1000 **** **** 8819';

  @override
  String get reconciliationNameMismatch =>
      'حالة المطابقة: اختلاف طفيف في اللقب التجاري (يتطلب مراجعة مستند التفويض والوكالة الشرعية قبل الصرف).';

  @override
  String get reconciliationAuditAlert => 'تنبيه تدقيق';

  @override
  String get reconciliationOpenAudit =>
      'فتح ملف التدقيق الكامل للحساب #TRD-6022';

  @override
  String get withdrawSheetBrand => 'برواح المازوري للخدمات المالية';

  @override
  String get withdrawSheetTitle => 'طلب سحب الارباح من المالك';

  @override
  String get withdrawSheetAccount =>
      'حساب الإدارة والرقابة التنفيذية — أ. سليمان الراجحي';

  @override
  String get withdrawSheetInstantAuth => 'مصادقة نفاذ فوري • سحب لحظي SARIE';

  @override
  String get withdrawSheetRequestId => 'طلب رقم #WD-8842';

  @override
  String get withdrawSheetAvailableBalance =>
      'الرصيد المتاح الجاهز للصرف الفوري';

  @override
  String get withdrawSheetMinimumNotice =>
      'الحد الأدنى للسحب 1,000 ج.م • بدون رسوم تحويل إدارية';

  @override
  String get withdrawSheetEnterAmount => 'أدخل المبلغ المطلوب سحبه';

  @override
  String get withdrawSheetSetMaximum => 'تحديد الحد الأقصى';

  @override
  String get withdrawSheetSelectBank => 'الحساب البنكي المستلم المعتمد';

  @override
  String get withdrawSheetIbanVerified => 'مدقق IBAN';

  @override
  String get withdrawSheetBankName => 'مصرف الراجحي';

  @override
  String get withdrawSheetBankStatus => 'حساب موثق لدى SAMA • نشط ومطابق';

  @override
  String get withdrawSheetPrimaryAccount => 'الحساب الرئيسي';

  @override
  String get withdrawSheetSubmitSuccess => 'تم رفع طلب السحب بنجاح';

  @override
  String get withdrawSheetConfirm => 'تأكيد ارسال طلب السحب للادارة';

  @override
  String get withdrawSheetCancel => 'إلغاء والتراجع';

  @override
  String get withdrawSheetAllAmount => 'الكل (52,000 ج.م)';

  @override
  String get withdrawSheetAmount25k => '25,000 ج.م';

  @override
  String get withdrawSheetAmount10k => '10,000 ج.م';

  @override
  String get withdrawSheetAmount5k => '5,000 ج.م';

  @override
  String get matrixLive => 'إعدادات محلية';

  @override
  String get matrixCfoPermission =>
      'صلاحية سيادية حصرية للمدير المالي (CFO-01)';

  @override
  String get matrixIntro =>
      'مراجعة نسب العمولات والرسوم وحفظ التعديلات محليًا للمراجعة.';

  @override
  String get matrixLastUpdate =>
      'آخر تحديث: 01 يناير 2025 بموجب قرار مجلس الإدارة رقم BOD-44/B';

  @override
  String get matrixSalesRateTitle => 'النسبة العامة للمبيعات والمتاجر';

  @override
  String get matrixRateRange => 'النطاق: 10.0% - 2.0%';

  @override
  String get matrixCurrentRate => 'النسبة المطبقة حالياً';

  @override
  String get matrixSetTargetRate => 'ضبط النسبة المستهدفة';

  @override
  String get matrixMinimumRate => 'الحد الأدنى 2.0%';

  @override
  String get matrixReferenceRate => 'المرجعي 5.0%';

  @override
  String get matrixMaximumRate => 'الحد الأقصى 10.0%';

  @override
  String get matrixSalesRateNote =>
      'تُطبق على جميع صفقات المتاجر، المنتجات الجديدة، ومبيعات الأجهزة المباشرة دون استثناءات محلية.';

  @override
  String get matrixSettlementFeesTitle => 'رسوم تسوية المحافظ والاسترداد';

  @override
  String get matrixCurrentSettlementFee => 'رسم التسوية الحالية';

  @override
  String get matrixFixedInstantFee => 'رسم ثابت إضافي (تسوية فورية)';

  @override
  String get matrixCostCoverage => 'تفصيل التغطية التكلفة:';

  @override
  String get matrixDeliveryFleet => 'أسطول وصلني & الشركاء';

  @override
  String get matrixCurrentCommission => 'العمولة المعتمدة حالياً';

  @override
  String get matrixDeliveryPercentage => 'نسبة مئوية من قيمة التوصيل';

  @override
  String get matrixFixedPerShipment => 'مبلغ مقطوع ثابت لكل شحنة';

  @override
  String get matrixAccountingReason => 'المسوغ المحاسبي والإلزامي للرقابة';

  @override
  String get matrixCancel => 'إلغاء';

  @override
  String get reconciliationFinanceSubtitle => 'الإدارة المالية والحسابات';

  @override
  String get departmentMerchantsTitle => 'محفظة قسم التجار والمتاجر';

  @override
  String get departmentEscrowTitle => 'محفظة المستعمل وعربون «وصلني»';

  @override
  String get departmentServicesTitle => 'محفظة طلبات الخدمات والصيانة';

  @override
  String get departmentCouriersTitle => 'محفظة مناديب التوصيل واللوجستيات';

  @override
  String get departmentActiveStores => 'المتاجر النشطة';

  @override
  String get departmentPendingRequests => 'طلبات معلقة';

  @override
  String get departmentPlatformCommission => 'عمولة المنصة';

  @override
  String get departmentActiveDeals => 'صفقات نشطة';

  @override
  String get departmentDisputes => 'نزاعات';

  @override
  String get departmentProtectionFee => 'رسوم حماية';

  @override
  String get departmentServiceProviders => 'مزودي خدمات';

  @override
  String get departmentActiveCouriers => 'مناديب نشطين';

  @override
  String get departmentPendingEntitlements => 'مستحقات معلقة';

  @override
  String get departmentShipmentFee => 'رسوم شحنة';

  @override
  String get departmentAuditedBadge => 'مدقق ومعتمد';

  @override
  String get departmentTotalBalance =>
      'إجمالي الرصيد التجميعي المتاح للتسوية والسحب';

  @override
  String get departmentWalletSectionTitle => 'الرقابة وحسابات المتاجر';

  @override
  String get departmentSyncStatus => 'سداد وسريع متزامنان';

  @override
  String get departmentGovernanceTitle =>
      'حوكمة التسويات والضوابط البنكية (CFO)';

  @override
  String get departmentLastReconciliation => 'آخر مطابقة بنكية: اليوم 02:45 م';

  @override
  String get departmentAvailableBalance => 'الرصيد المتاح للسحب';

  @override
  String get departmentUnderReview => 'تحت التدقيق والتسوية';

  @override
  String get departmentMonthlySales => 'المبيعات المكتملة للشهر';

  @override
  String get departmentOperationsUnit => 'عملية';

  @override
  String get departmentViewHistory => 'عرض سجل العمليات';

  @override
  String get departmentInstantSettlement => 'تسوية سريعة';

  @override
  String get departmentScheduledPayment => 'دفعة بنكية مجدولة';

  @override
  String get departmentUnderInspection => 'قيد المعاينة';

  @override
  String get departmentInShipping => 'قيد الشحن';

  @override
  String get departmentWeeklySettlement => 'تسوية أسبوعية';

  @override
  String get departmentActiveMatched => 'نشط ومطابق';

  @override
  String get departmentProtectedEscrow => 'ضمان محفوظ';

  @override
  String get departmentApprovedProvider => 'مزود معتمد';

  @override
  String get departmentStrategicPartner => 'شريك استراتيجي';

  @override
  String get departmentActiveCourier => 'مندوب نشط';

  @override
  String get departmentPendingSuffix => 'معلق';

  @override
  String get departmentMerchantHorizon => 'مؤسسة الأفق للتقنية والتجارة';

  @override
  String get departmentStoreElite => 'متجر الصفوة الذهبي';

  @override
  String get departmentSparkleJewelry => 'مجوهرات البريق الراقية';

  @override
  String get departmentEliteDevices => 'دار النخبة للأجهزة';

  @override
  String get departmentCamryEscrow => 'سيارة تويوتا كامري 2020';

  @override
  String get departmentIphoneEscrow => 'آيفون 14 برو ماكس';

  @override
  String get departmentItqanAc => 'مؤسسة إتقان للتكييف';

  @override
  String get departmentComprehensiveMaintenance => 'شركة الصيانة الشاملة';

  @override
  String get departmentZajelShipping => 'شركة زاجل للشحن';

  @override
  String get departmentWaslniCourier => 'مندوب أسطول وصلني (محمد أحمد)';

  @override
  String get departmentRecordPrefix => 'سجل:';

  @override
  String get departmentLicensePrefix => 'رخصة:';

  @override
  String get departmentEscrowPrefix => 'عربون تأمين';

  @override
  String get departmentCourierNumberPrefix => 'رقم المندوب:';

  @override
  String get departmentAllFilter => 'الكل';

  @override
  String get departmentHighestBalanceFilter => 'أعلى رصيد';

  @override
  String get departmentWithdrawalFilter => 'قيد السحب (8)';

  @override
  String get departmentGovernanceNotice =>
      'تخضع جميع تحويلات المحفظة لمطابقة يومية تلقائية مع شبكة سريع للمدفوعات الفورية ونظام سداد. ووفقاً لتعليمات البنك المركزي السعودي، تُحجز العمليات المشتبه بها للتدقيق اليدوي من إدارة الامتثال المالي ببرواح المازوري.';

  @override
  String get matrixScreenTitle => 'تعديل مصفوفة نسب الأرباح والرسوم';

  @override
  String get matrixDefaultReason =>
      'تعديل دوري لمواكبة تحديثات رسوم بوابات الدفع البنكية وتوسعة شبكة التوصيل الميداني';

  @override
  String get matrixLastUpdated => 'آخر حفظ:';

  @override
  String get matrixCfoDescription =>
      'تعديل نسب العمولات المقترحة وحفظها محليًا للمراجعة؛ لا تُفعّل التغييرات على محرك الدفع من هذه الصفحة.';

  @override
  String get matrixAppliedRate => 'النسبة المحفوظة';

  @override
  String get matrixTargetRate => 'ضبط النسبة المستهدفة';

  @override
  String get matrixMinimumValue => 'الحد الأدنى 2.0%';

  @override
  String get matrixReferenceValue => 'المرجعي 5.0%';

  @override
  String get matrixMaximumValue => 'الحد الأقصى 10.0%';

  @override
  String get matrixSalesNote =>
      'تُطبق على جميع صفقات المتاجر، المنتجات الجديدة، ومبيعات الأجهزة المباشرة دون استثناءات محلية.';

  @override
  String get matrixCurrentSettlementRate => 'رسم التسوية الحالية';

  @override
  String get matrixInstantFixedFee => 'رسم ثابت إضافي (تسوية فورية)';

  @override
  String get matrixInstantFixedFeeNote =>
      'تطبيق رسم مقطوع بقيمة 5.00 ج.م لكل تسوية مستعجلة';

  @override
  String get matrixCoverageDetails => 'تفصيل تغطية التكلفة:';

  @override
  String get matrixGatewayCoverage =>
      'تغطية مصاريف بوابات الدفع (Mada / Visa / SARIE) بنسبة 0.85%';

  @override
  String get matrixOperatingMargin => '+ هامش تشغيلي وقائي بنسبة 0.40%';

  @override
  String get matrixSettlementNote =>
      'تُقتطع تلقائياً عند طلب التسوية السريعة عبر شبكة المدفوعات اللوجستية الفورية واسترداد النزاعات.';

  @override
  String get matrixDeliveryTitle => 'عمولة قطاع التوصيل والنقل والشحن';

  @override
  String get matrixDeliveryDescription =>
      'تُحتسب على كل عملية توصيل ناجحة لمناديب أسطول وصلني والشركات اللوجستية المتعاقدة وتُودع بالمحفظة المركزية.';

  @override
  String get matrixAuditReasonTitle => 'المسوغ المحاسبي والإلزامي للرقابة';

  @override
  String get matrixAuditReasonPrompt =>
      'سبب وموجب تعديل النسب (إلزامي للرقابة والتدقيق المركزي):';

  @override
  String get matrixNotifyUsers =>
      'تفضيل إشعار التجار والمناديب والمشرفين عند تطبيق تحديث للمصفوفة.';

  @override
  String get matrixSaveSuccess => 'تم حفظ تعديلات المصفوفة على هذا الجهاز.';

  @override
  String get matrixSaveAndSend => 'حفظ التعديلات';

  @override
  String get matrixAuditTrailNotice =>
      'تُحفظ التعديلات محلياً مع وقت الحفظ وسبب التعديل. اضغط لعرض السجل.';

  @override
  String get settlementsScreenTitle => 'إدارة التسويات';

  @override
  String get settlementsSubtitle => 'برواح المازوري - الإدارة المالية';

  @override
  String get settlementBack => 'العودة';

  @override
  String get settlementsAuthority => 'صلاحيات المدير المالي التنفيذي';

  @override
  String get settlementsPageTitle => 'إدارة المحافظ الإلكترونية والتسويات';

  @override
  String get settlementsPageDescription =>
      'تنفيذ حركات النقود المالية المصرح بها مع إرفاق السند القانوني ومحضر النزاع المالي المعتمد.';

  @override
  String get settlementsEscrowWallet => 'محفظة الضمان (Escrow)';

  @override
  String get settlementsReservedOrders => 'محجوز لأوامر نشطة';

  @override
  String get settlementsPendingBalance => 'رصيد التسويات المعلقة';

  @override
  String get settlementsReadyRefund => 'طلب استرداد جاهز للإقفال';

  @override
  String get settlementSheetTitle => 'إضافة طلب تسوية';

  @override
  String get settlementOffsetMode => 'مقاصة الرصيد';

  @override
  String get settlementRefundMode => 'استرداد';

  @override
  String get settlementTypeLabel => 'نوع التسوية';

  @override
  String get settlementTypeInstant => 'التسوية الفورية';

  @override
  String get settlementBeneficiaryLabel => 'المستفيد';

  @override
  String get settlementBeneficiaryAudit => 'التحقق والتدقيق';

  @override
  String get settlementAmountLabel => 'قيمة التسوية';

  @override
  String get settlementReferenceLabel => 'المرجع';

  @override
  String get settlementNotesLabel => 'ملاحظات التسوية';

  @override
  String get settlementNotesHint => 'أدخل تفاصيل طلب التسوية';

  @override
  String get settlementPaymentDetailsTitle => 'تفاصيل الدفع';

  @override
  String get settlementPaymentMethodLabel => 'طريقة الدفع';

  @override
  String get settlementPaymentBankTransfer => 'حوالة بنكية';

  @override
  String get settlementDateLabel => 'التاريخ';

  @override
  String get settlementStatusLabel => 'الحالة';

  @override
  String get settlementStatusUnderReview => 'قيد المراجعة';

  @override
  String get settlementSubmit => 'إرسال الطلب';

  @override
  String get settlementSubmitSuccess => 'تم إرسال طلب التسوية بنجاح';

  @override
  String get addNewSettlement => 'إضافة تسوية جديدة';

  @override
  String get instantRefundSettlement => 'استرداد / تسوية فورية';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterInReview => 'قيد المراجعة';

  @override
  String get filterApproved => 'معتمدة';

  @override
  String get filterDisputed => 'قيد نزاع';

  @override
  String get pendingSettlementRequests => 'طلبات التسوية المعلقة';

  @override
  String get settlementRequestOne => 'طلب';

  @override
  String get settlementVerifiedBank => 'حساب بنكي موثق';

  @override
  String get settlementMaintenanceDispute => 'نزاع صيانة';

  @override
  String get settlementFullRefund => 'استرداد مالي كامل';

  @override
  String get settlementAge35Minutes => 'منذ 35 دقيقة';

  @override
  String get settlementBeneficiaryTariq => 'د. طارق العمري';

  @override
  String get settlementInitialTariq => 'ط';

  @override
  String get settlementApprovedPartner => 'شريك معتمد - سجل تجاري';

  @override
  String get settlementBeneficiaryRealEstate => 'مؤسسة الضمان العقارية';

  @override
  String get settlementInitialRealEstate => 'ض';

  @override
  String get settlementCommissionCorrection => 'تصحيح عمولة';

  @override
  String get settlementCommissionSettlement => 'تسوية عمولة';

  @override
  String get settlementAgeTwoHours => 'منذ ساعتين';

  @override
  String get settlementIndependentProvider => 'مزود خدمة مستقل';

  @override
  String get settlementBeneficiaryKhalid => 'خالد المهيوب';

  @override
  String get settlementInitialKhalid => 'خ';

  @override
  String get settlementMediationDelivery => 'تسليم وساطة';

  @override
  String get settlementPenaltyDeduction => 'خصم جزائي';

  @override
  String get settlementAgeToday => 'اليوم 08:30 ص';

  @override
  String get recentSettlementsTitle => 'آخر التسويات المنفذة حديثاً';

  @override
  String get bankRefund => 'استرداد بنكي';

  @override
  String get settlementCustomerBank => 'العميل #USR-8810 - بنك البلاد';

  @override
  String get settlementToday1130 => 'اليوم 11:30 ص';

  @override
  String get compensationSettlement => 'تسوية تعويضية';

  @override
  String get settlementProviderCorrection => 'مزود الخدمة - تصحيح عمولة';

  @override
  String get settlementYesterday0915 => 'أمس 09:15 م';

  @override
  String get settlementsLinkedRajhiEscrow =>
      'مصرف الراجحي - حساب الضمان المركزي';

  @override
  String get settlementRecentOperationsCount => '142 عملية';

  @override
  String get viewLabel => 'عرض';

  @override
  String get viewAllLabel => 'عرض الكل';

  @override
  String get createSettlementToast => 'إضافة تسوية جديدة';

  @override
  String get frozenScreenTitle => 'إظهار الطلبات المعلقة والمجمدة';

  @override
  String get frozenTotalTitle => 'إجمالي المبالغ والعمليات المجمدة احترازياً';

  @override
  String get frozenRequestCount => 'طلبات مجمدة';

  @override
  String get frozenProtocol => 'بروتوكول المادة 18 مكافحة الاحتيال';

  @override
  String get frozenAllFilter => 'الكل';

  @override
  String get frozenMerchantsFilter => 'تجار ومتاجر';

  @override
  String get frozenProvidersFilter => 'مقدمو خدمات';

  @override
  String get frozenSupervisorsFilter => 'المشرفون';

  @override
  String get frozenCouriersFilter => 'المناديب';

  @override
  String get frozenUsersFilter => 'المستخدمون';

  @override
  String get frozenAdsFilter => 'الإعلانات';

  @override
  String get frozenExport => 'تصدير بيان الأموال المجمدة (PDF / Excel)';

  @override
  String get frozenRefresh => 'تحديث حالة الحركات ومزامنة الرقابة اللحظية';

  @override
  String get frozenRequestOneName => 'تاجر مستلزمات حاسب';

  @override
  String get frozenRequestOneSubtitle => 'طلب سحب أرباح مالي دوري';

  @override
  String get frozenMerchantType => 'تجار ومتاجر';

  @override
  String get frozenPrecautionaryStatus => 'مجمد احترازياً';

  @override
  String get frozenRequestOneReason =>
      'سبب التجميد: بلاغ نزاع مفتوح #CMP-1042 مع شبهة تلاعب في عروض ترويجية.';

  @override
  String get frozenSupervisorSaad => 'أ. سعد العتيبي';

  @override
  String get frozenTodayFourHours => 'اليوم • منذ 4 ساعات';

  @override
  String get frozenRestoreAndRelease => 'إعادة العمل وفك التجميد للصرف';

  @override
  String get frozenRejectAndForfeit => 'تأكيد الرفض والمصادرة';

  @override
  String get frozenRequestTwoName => 'ورشة الإتقان للكهرباء';

  @override
  String get frozenAnnualMaintenance => 'مستحقات عقود صيانة سنوية';

  @override
  String get frozenProviderType => 'مقدمو خدمات';

  @override
  String get frozenRequestTwoReason =>
      'سبب التجميد: شكوى عدم اكتمال الصيانة المنزلية';

  @override
  String get frozenSupervisorAhmed => 'أ. أحمد حسان';

  @override
  String get frozenYesterdayJanuary => 'أمس • 27 يناير';

  @override
  String get frozenPartialFullRelease => 'فك التجميد الجزئي / الكامل';

  @override
  String get frozenCustomerRefund => 'تسوية استرداد للعميل';

  @override
  String get frozenRequestThreeName => 'مؤسسة الأفق للتجارة';

  @override
  String get frozenFastTransferPending => 'حوالة بنكية سريعة (SARIE) معلقة';

  @override
  String get frozenIbanMismatch => 'تعارض آيبان';

  @override
  String get frozenRequestThreeReason =>
      'سبب التجميد: فشل التحقق الآلي من تطابق اسم المستفيد مع السجل التجاري في البنك المركزي السعودي.';

  @override
  String get frozenJanuary25 => '25 يناير 2025';

  @override
  String get frozenRecheckTransfer => 'إعادة التحقق وتنشيط الحوالة';

  @override
  String get frozenRequestIbanCertificate =>
      'طلب شهادة آيبان جديدة مختومة من البنك';

  @override
  String get frozenPendingTransferAmount => 'المبلغ المعلق للحوالة:';

  @override
  String get frozenHeldAmount => 'المبلغ المحتجز للتجميد:';

  @override
  String get frozenRegisteredIban => 'الآيبان المسجل:';

  @override
  String get frozenGrossTransaction => 'إجمالي المعاملة:';

  @override
  String get frozenAccountNameMismatch => 'عدم تطابق اسم الحساب';

  @override
  String get frozenPlatformFeeDeduction => 'خصم عمولة المنصة:';

  @override
  String get frozenSupervisorLabel => 'مشرف:';

  @override
  String get frozenThawSuccess =>
      'تم فك التجميد وإرسال طلب الصرف للإدارة للموافقة';

  @override
  String get frozenForfeitSuccess => 'تم رفض الطلب ومصادرته وحفظ سبب الرفض';

  @override
  String get frozenForfeitReasonHint =>
      'اكتب سبب الرفض والمصادرة الرقابية بالتفصيل...';

  @override
  String get frozenBankLinksTitle => 'طلبات ربط الحسابات البنكية المجمدة';

  @override
  String get frozenBankLinkReason => 'سبب التجميد:';

  @override
  String get frozenBankLinkRestore => 'فك التجميد وإعادته للمراجعة';

  @override
  String get frozenBankLinkReject => 'رفض مع تسجيل السبب';

  @override
  String get frozenBankLinkRestoreDialogTitle =>
      'إعادة طلب ربط الحساب للمراجعة';

  @override
  String get frozenBankLinkRestoreDialogDescription =>
      'هل تريد فك تجميد طلب ربط الحساب وإعادته إلى قائمة المطابقة النشطة؟';

  @override
  String get frozenBankLinkRestoreConfirm => 'فك التجميد والإعادة';

  @override
  String get frozenBankLinkRestoreSuccess =>
      'تم فك تجميد الطلب وإعادته إلى قائمة المطابقة البنكية.';

  @override
  String get frozenBankLinkRejectDialogTitle => 'رفض طلب ربط الحساب المجمد';

  @override
  String get frozenBankLinkRejectReasonHint => 'اكتب سبب رفض طلب ربط الحساب...';

  @override
  String get frozenBankLinkRejectSuccess =>
      'تم رفض طلب ربط الحساب المجمد وحفظ السبب.';

  @override
  String get frozenForfeitReasonNotice =>
      'سيتم حفظ السبب مع قرار الرفض والمصادرة وإرساله للإدارة للمراجعة.';

  @override
  String get frozenActionFailed =>
      'تعذر تنفيذ الإجراء. حدّث الطلب وحاول مرة أخرى.';

  @override
  String get frozenLoadFailed => 'تعذر تحميل الطلبات المعلقة والمجمدة.';

  @override
  String get frozenNoRequests => 'لا توجد طلبات معلقة أو مجمدة حالياً.';

  @override
  String get transactionHistoryTitle => 'سجل العمليات';

  @override
  String get transactionFinancialSubtitle => 'برواح المازوري - الإدارة المالية';

  @override
  String get transactionSupervisedBy => 'تحت إشراف: أ. سعد العتيبي';

  @override
  String get transactionAvailableBalance => 'رصيد المحفظة المتاح للتسوية';

  @override
  String get transactionTotalWithdrawals => 'إجمالي السحوبات';

  @override
  String get transactionTotalDeposits => 'إجمالي الإيداعات';

  @override
  String get transactionApprovedHistory => 'سجل الحركات المصرفية المعتمدة';

  @override
  String get transactionThisMonth => 'هذا الشهر (يناير 2025)';

  @override
  String get transactionAllFilter => 'الكل (6)';

  @override
  String get transactionDepositsFilter => 'عمليات الإيداع (+3)';

  @override
  String get transactionWithdrawalsFilter => 'عمليات السحب (-3)';

  @override
  String get transactionTodayGroup => 'اليوم • 28 يناير 2025';

  @override
  String get transactionTwoOperations => 'عمليتان';

  @override
  String get transactionDepositSales => 'إيداع مبيعات نقدية - متجر إلكتروني';

  @override
  String get transactionNationalGateway => 'بطاقة مدى • بوابة الدفع الوطنية';

  @override
  String get transactionSuccess => 'ناجح ومكتمل';

  @override
  String get transactionTimeTodayDeposit => '02:45 م';

  @override
  String get transactionProfitWithdrawal => 'سحب أرباح للبنك - مصرف الراجحي';

  @override
  String get transactionFastNetwork => 'آيبان: SA44****5521 • سريع SARIE';

  @override
  String get transactionApproved => 'تحويل معتمد';

  @override
  String get transactionTimeTodayWithdrawal => '11:15 ص';

  @override
  String get transactionYesterdayGroup => 'أمس • 27 يناير 2025';

  @override
  String get transactionWaslniDeposit => 'إيداع طلبات وصلني';

  @override
  String get transactionAutomatedSettlement => 'تسوية لوجستية آلية متوافقة';

  @override
  String get transactionCompleted => 'مكتمل';

  @override
  String get transactionTimeYesterdayDeposit => '06:30 م';

  @override
  String get transactionSnbWithdrawal => 'سحب أرباح - البنك الأهلي';

  @override
  String get transactionCorporateVerification =>
      'آيبان: SA12****8894 • توثيق مؤسسي';

  @override
  String get transactionCertified => 'مصدق رقابياً';

  @override
  String get transactionTimeYesterdayWithdrawal => '09:20 ص';

  @override
  String get transactionLastWeekGroup => 'الأسبوع الماضي • 23 يناير 2025';

  @override
  String get transactionMerchantDisputeDeposit =>
      'إيداع تسوية نزاع لصالح التاجر...';

  @override
  String get transactionArbitrationDecision =>
      'قرار تحكيمي منصة المدفوعات #ARB-209';

  @override
  String get transactionEffectiveSettlement => 'تسوية نافذة';

  @override
  String get transactionTimeLastWeekDeposit => '04:10 م';

  @override
  String get transactionWithdrawalReview =>
      'طلب سحب أرباح قيد المراجعة الفورية...';

  @override
  String get transactionAmlReview => 'مراجعة مطابقة الامتثال المالي (AML)';

  @override
  String get transactionBankAudit => 'قيد التدقيق البنكي';

  @override
  String get transactionTimeLastWeekWithdrawal => '01:15 م';

  @override
  String get transactionHeldBalance => 'الرصيد المحجوز:';

  @override
  String get transactionBalanceAfter => 'الرصيد بعد الحركة:';

  @override
  String get transactionDownloadStatement => 'تحميل كشف الحساب المعتمد (PDF)';

  @override
  String get totalRequiredAmount => 'إجمالي السعر المطلوب';

  @override
  String get goldenAnnualPackage => 'الباقة الذهبية السنوية';

  @override
  String get proServiceProvider => 'مزود خدمة احترافي';

  @override
  String get vipAnnualPackage => 'باقة VIP السنوية';

  @override
  String get unlimitedDeliveryPackage => 'باقة التوصيل اللامحدود';

  @override
  String get featuredWeekPackage => 'إعلان مميز (أسبوع واحد)';

  @override
  String get directBankTransferSadad => 'تحويل بنكي مباشر (سداد / الراجحي)';

  @override
  String get directDebitEscrow => 'خصم مباشر من المحفظة الضامنة (Escrow)';

  @override
  String get creditCardMada => 'بطاقة ائتمانية (مدى)';

  @override
  String get walletDeduction => 'خصم من المحفظة';

  @override
  String get directBankTransferSnb => 'تحويل بنكي مباشر (الأهلي)';

  @override
  String get availableBalanceLabel => 'رصيد متاح';

  @override
  String get featuredMerchantSubscription => 'اشتراك تاجر مميز';

  @override
  String get premiumUser => 'مستخدم مميز';

  @override
  String get deliveryCourier => 'مندوب توصيل';

  @override
  String get commercialAds => 'إعلانات تجارية';

  @override
  String get eliteElectronicsStore => 'متجر النخبة للإلكترونيات';

  @override
  String get maintenanceWorkshop => 'ورشة الصيانة المتكاملة...';

  @override
  String get vipUserUpgrade => 'ترقية مستخدم VIP';

  @override
  String get fastCourierPackage => 'باقة المندوب السريع';

  @override
  String get mainBannerAd => 'إعلان بانر رئيسي';

  @override
  String get alRajhiBankName => 'مصرف الراجحي';

  @override
  String get snbBankName => 'البنك الأهلي السعودي (SNB)';

  @override
  String get riyadBankName => 'بنك الرياض';

  @override
  String get madaGatewayName => 'بوابة سداد و مدى (Mada Gateway)';

  @override
  String get stcPayWalletName => 'محفظة STC Pay المركزية';

  @override
  String get operatingAccountType => 'حساب تشغيلي';

  @override
  String get escrowAccountType => 'حساب ضمان Escrow';

  @override
  String get electronicPaymentGatewayType => 'بوابة دفع إلكتروني';

  @override
  String get digitalWalletType => 'محفظة رقمية';

  @override
  String get reconciliationNewCommercialAccountRequest =>
      'طلب ربط وتوثيق حساب تجاري جديد';

  @override
  String get reconciliationSupplierAccountRequest => 'طلب ربط حساب مورد معتمد';

  @override
  String get reconciliationFreelanceProviderRequest =>
      'طلب ربط حساب مزود خدمة مستقل';

  @override
  String get reconciliationMatchDescription100 =>
      'تطابق الاسم التجاري والبنكي موثق بنسبة 100%';

  @override
  String get reconciliationMatchDescription96 =>
      'اختلاف طفيف في اللواحق القانونية للاسم التجاري';

  @override
  String get reconciliationMatchDescription89 =>
      'مؤسسة فردية تتطلب شهادة آيبان حديثة مختومة';

  @override
  String get reconciliationWarning96 =>
      'تم رصد اختلاف بين لاحقة السجل والحساب البنكي';

  @override
  String get reconciliationWarning89 =>
      'شهادة الآيبان المرفقة تعود لأكثر من 6 أشهر';

  @override
  String get reconciliationCommercialName1 => 'مؤسسة التجارة المتقدمة المحدودة';

  @override
  String get reconciliationBeneficiaryName1 =>
      'مؤسسة التجارة المتقدمة للخدمات والتوكيلات';

  @override
  String get reconciliationCommercialName2 =>
      'شركة مدار الرواد للمقاولات العامة';

  @override
  String get reconciliationBeneficiaryName2 =>
      'شركة مدار الرواد للتجارة والمقاولات ش.ش.و';

  @override
  String get reconciliationCommercialName3 =>
      'مؤسسة القمة الرقمية لتقنية المعلومات';

  @override
  String get reconciliationBeneficiaryName3 => 'فهد سليمان عبد الله العتيبي';

  @override
  String get reconciliationHijriSuffix => 'هـ';

  @override
  String get reconciliationFreezeRequest => 'تجميد الطلب';

  @override
  String get merchantsSupervisorTitle => 'Merchants';

  @override
  String get merchantSupervisorRoleBadge => 'مشرف تجار';

  @override
  String get merchantSupervisorAdminSubtitle => 'برواح المازوري - الإدارة';

  @override
  String get welcomeSupervisorAhmed => 'مرحباً، المشرف أحمد';

  @override
  String get fieldSupervisorTag => 'ميداني';

  @override
  String get merchantsPortfolioSubtitle =>
      'محفظة التجار الموكلة إليك - منطقة الرياض';

  @override
  String get approvedMerchantsMetric => 'تاجر معتمد';

  @override
  String get pendingReviewMetric => 'بانتظار المراجعة';

  @override
  String get searchMerchantsHint => 'ابحث بالاسم، السجل التجاري، أو التصنيف';

  @override
  String get filterActiveVerified => 'نشط وموثق';

  @override
  String get filterUnderAudit => 'قيد التدقيق';

  @override
  String get filterUpdateRequired => 'تحديث بيانات مطلوب';

  @override
  String get filterSuspended => 'معلق مؤقتاً';

  @override
  String get registeredStoresSection => 'المتاجر المسجلة تحت إشرافك';

  @override
  String storesRatio(Object current, Object total) {
    return '$current من أصل $total';
  }

  @override
  String get recentlyActiveSort => 'الأحدث نشاطاً';

  @override
  String get crShortLabel => 'س.ت';

  @override
  String get linkNewMerchant => 'ربط تاجر جديد';

  @override
  String get navMerchants => 'التجار';

  @override
  String get navAds => 'الإعلانات';

  @override
  String get navFinancialRequests => 'الطلبات المالية';

  @override
  String get navAccount => 'الحساب';

  @override
  String merchantSectionComingSoon(Object section) {
    return 'قسم $section قيد التجهيز';
  }

  @override
  String get adsManagementTitle => 'إدارة الإعلانات قبل النشر';

  @override
  String get adsReviewGateway => 'بوابة التدقيق الإشرافي المباشر';

  @override
  String get adsUrgentDecision => 'يتطلب قراراً فورياً';

  @override
  String get adsHiddenToday => 'المخفية';

  @override
  String get adsPendingToday => 'المعتمدة اليوم';

  @override
  String get adsUnderReviewCount => 'قيد المراجعة';

  @override
  String get adsAllFilter => 'الكل';

  @override
  String get adsVehiclesFilter => 'سيارات ومركبات';

  @override
  String get adsElectronicsFilter => 'إلكترونيات';

  @override
  String get adsRealEstateFilter => 'عقارات';

  @override
  String get adsSearchHint => 'ابحث بالعنوان أو التاجر أو الكود...';

  @override
  String get adsClearSearch => 'مسح البحث';

  @override
  String get adsPendingHeading => 'الإعلانات المعلقة للتدقيق';

  @override
  String get adsRecentSort => 'الأحدث وصولاً';

  @override
  String get adsOldestSort => 'الأقدم وصولاً';

  @override
  String adsImageCount(Object count) {
    return '$count صور';
  }

  @override
  String get adsCarMerchant => 'مؤسسة الأفق لتجارة السيارات';

  @override
  String get adsCarCategory => 'معرض سيارات • الرياض';

  @override
  String get adsCarTitle => 'مرسيدس E300 موديل 2023 فل كامل AMG';

  @override
  String get adsCarDetails => 'عداد: 15,000 كم';

  @override
  String get adsCarPrice => '245,000 ج.م';

  @override
  String get adsPhoneMerchant => 'متجر الصفوة للإلكترونيات';

  @override
  String get adsPhoneCategory => 'موثق في معروف • الرياض';

  @override
  String get adsPhoneTitle => 'آيفون 16 برو ماكس 256GB تيتانيوم طبيعي جديد';

  @override
  String get adsPhoneDetails => 'الكفالة المحلية: 5 سنوات';

  @override
  String get adsPhonePrice => '4,699 ج.م';

  @override
  String get adsVillaMerchant => 'شركة اليمامة للمقاولات والعقارات';

  @override
  String get adsVillaCategory => 'وسيط عقاري معتمد • الرياض';

  @override
  String get adsVillaTitle => 'فيلا مودرن فاخرة درج صالة - حي النرجس';

  @override
  String get adsVillaDetails => 'مساحة الأرض 375 م²';

  @override
  String get adsVillaPrice => '2,850,000 ج.م';

  @override
  String get adsLicenseVerified => 'الترخيص التجاري موثق';

  @override
  String get adsMarketPriceMatched => 'سعر متوافق مع متوسط السوق';

  @override
  String get adsReviewHidden => 'مخفي بانتظار المراجعة';

  @override
  String adsMinutesAgo(Object count) {
    return 'منذ $count دقيقة';
  }

  @override
  String get adsHoursAgo => 'منذ ساعتين';

  @override
  String get adsReviewAndApprove => 'مراجعة وتدقيق الإعلان';

  @override
  String get adsHideAction => 'إخفاء الإعلان';

  @override
  String get adsApproveAction => 'قبول واعتماد النشر';

  @override
  String get adsRejectAction => 'رفض مع ذكر السبب';

  @override
  String get adsRejectReasonTitle => 'سبب رفض الإعلان';

  @override
  String get adsRejectReasonHint => 'اكتب سبب الرفض ليظهر للتاجر';

  @override
  String get adsRejectReasonInstructions =>
      'يرجى اختيار سبب واضح ليتم إبلاغ التاجر به وتوثيقه في سجل التدقيق الإداري.';

  @override
  String get adsRejectReasonPrice => 'سعر غير منطقي أو وهمي';

  @override
  String get adsRejectReasonMisleading => 'وصف مضلل أو بيانات غير دقيقة';

  @override
  String get adsRejectReasonPhotos =>
      'صور غير مطابقة للمواصفات أو ذات جودة رديئة';

  @override
  String get adsRejectReasonPolicy => 'مخالفة سياسة النشر وشروط المنصة';

  @override
  String get adsRejectGuidanceOptional => 'توجيه مخصص للتاجر (اختياري)';

  @override
  String get adsRejectGuidanceDirectLabel => 'يظهر في إشعار التاجر المباشر';

  @override
  String get adsRejectGuidanceHint =>
      'أدخل نص التوجيه لتعديل الإعلان وإعادة رفعه...';

  @override
  String get adsConfirmRejectAndNotify => 'تأكيد الرفض وإشعار التاجر';

  @override
  String get adsCancelAction => 'إلغاء';

  @override
  String get adsConfirmReject => 'تأكيد الرفض';

  @override
  String get adsApprovedStatus => 'تم اعتماد الإعلان';

  @override
  String get adsPremiumWaitingFinance => 'بانتظار مراجعة المشرف المالي';

  @override
  String get adsPremiumWaitingManagement =>
      'بانتظار اعتماد الإدارة وخصم الرسوم';

  @override
  String get adsHiddenStatus => 'الإعلان مخفي';

  @override
  String get adsRejectedStatus => 'تم رفض الإعلان';

  @override
  String get adsNoResults => 'لا توجد إعلانات مطابقة';

  @override
  String get adsDetailsTitle => 'تفاصيل الإعلان';

  @override
  String get adsInImageReviewStatus => 'إعلان معلق قيد المراجعة';

  @override
  String get adsNotPublishedYet => 'غير منشور حالياً';

  @override
  String adsMerchantRegistrationNumber(Object number) {
    return 'سجل تجاري: $number';
  }

  @override
  String get productSupervisorRoleBadge => 'مشرف المنتجات الجديدة';

  @override
  String get productReviewTab => 'قيد المراجعة';

  @override
  String get productReportsTab => 'التقارير';

  @override
  String get productSubscriptionsTab => 'ترويج المنتجات';

  @override
  String get productAccountTab => 'الحساب';

  @override
  String get wasalnySupervisorRoleBadge => 'مشرف وصلني';

  @override
  String get wasalnyRequestsTab => 'طلبات وصلني';

  @override
  String get wasalnyAccountFollowComplaint => 'متابعة الشكوى';

  @override
  String get wasalnyReportOverview => 'ملخص الأداء الميداني';

  @override
  String get wasalnyReportCompletionRate => 'نسبة إتمام الصفقات';

  @override
  String get wasalnyReportDealsDetail => 'صفقة مكتملة خلال الفترة المحددة';

  @override
  String get wasalnyReportCompletionDetail => 'من الصفقات التي تمت متابعتها';

  @override
  String get wasalnyReportResponseTime => 'متوسط سرعة الاستجابة';

  @override
  String get wasalnyReportResponseDetail => 'أسرع من المعيار المعتمد';

  @override
  String get wasalnyReportSatisfaction => 'معدل رضا الأطراف';

  @override
  String get wasalnyReportRatingDetail => 'استناداً إلى التقييمات الميدانية';

  @override
  String get wasalnyComplaintReference => 'الشكوى #CMP-1042';

  @override
  String get wasalnyComplaintOpenStatus => 'قيد المتابعة';

  @override
  String get wasalnyComplaintSubject => 'تأخر استلام شحنة بعد إتمام البيع';

  @override
  String get wasalnyComplaintDescription =>
      'تم تسجيل الشكوى وإحالتها للمراجعة. يجري حالياً التنسيق مع أطراف الطلب للتحقق من حالة الشحنة.';

  @override
  String get wasalnyComplaintReceived => 'تم استلام الشكوى وتسجيلها';

  @override
  String get wasalnyComplaintUnderReview => 'الشكوى قيد المراجعة من فريق وصلني';

  @override
  String get wasalnyComplaintWaitingAction => 'بانتظار الإجراء وتحديث الأطراف';

  @override
  String get wasalnyComplaintsListIntro =>
      'اختر شكوى لمراجعة تفاصيلها وأطراف النزاع';

  @override
  String wasalnyComplaintReferenceWithId(String id) {
    return 'الشكوى #$id';
  }

  @override
  String get wasalnyComplaintOpenDetails => 'عرض التفاصيل';

  @override
  String get wasalnyComplaintDetailsTitle => 'تفاصيل الشكوى';

  @override
  String get wasalnyComplaintDetailsSection => 'بيانات الشكوى';

  @override
  String get wasalnyComplaintRequestSection => 'بيانات الطلب';

  @override
  String get wasalnyComplaintPartiesSection => 'أطراف النزاع';

  @override
  String get wasalnyComplaintSeller => 'البائع';

  @override
  String get wasalnyComplaintBuyer => 'المشتري';

  @override
  String get wasalnyComplaintRequest => 'رقم الطلب';

  @override
  String get wasalnyComplaintAmount => 'قيمة الصفقة';

  @override
  String get wasalnyComplaintCreatedAt => 'تاريخ تسجيل الشكوى';

  @override
  String get wasalnyComplaintResolvedStatus => 'تم الحل وديًا';

  @override
  String get wasalnyComplaintEscalatedStatus => 'مصعّدة لرئيس المشرفين';

  @override
  String get wasalnyComplaintResolveFriendly => 'تم حل الشكوى والنزاع وديًا';

  @override
  String get wasalnyComplaintEscalateHead => 'تصعيد الشكوى لرئيس المشرفين';

  @override
  String get wasalnyComplaintEscalationSheetKicker =>
      'وحدة 03: تصعيد الشكوى للإدارة';

  @override
  String get wasalnyComplaintEscalationSheetType => 'نوع النافذة: نافذة سفلية';

  @override
  String get wasalnyComplaintEscalationSheetTitle => 'إجراء تصعيد الشكوى';

  @override
  String get wasalnyComplaintEscalationSheetSubtitle =>
      'تصعيد الشكوى لرئيس المشرفين';

  @override
  String get wasalnyComplaintEscalationFileLabel => 'ملف الشكوى الرقابي';

  @override
  String get wasalnyComplaintEscalationPending => 'بانتظار تصعيد إداري';

  @override
  String get wasalnyComplaintEscalationHeldAmount => 'مبلغ الضمان المحتجز';

  @override
  String get wasalnyComplaintEscalationNoHeldAmount => 'لا يوجد مبلغ محتجز';

  @override
  String get wasalnyComplaintEscalationPolicyTitle =>
      'صلاحيات وضوابط اللجنة الرقابية';

  @override
  String get wasalnyComplaintEscalationPolicyBody =>
      'يتم رفع الشكوى لرئيس المشرفين لمراجعة الوقائع والأدلة المسجلة، واعتماد الإجراء الإداري المناسب وفق سياسات المنصة. لا يؤدي التصعيد إلى تغيير حالة المبلغ المحتجز.';

  @override
  String get wasalnyComplaintEscalationAuditTrail => 'سجل النافذة موثق';

  @override
  String get wasalnyComplaintEscalationEvidenceTitle =>
      'ملخص الشكوى والأدلة المسجلة';

  @override
  String get wasalnyComplaintEscalationVerifiedLabel => 'بيانات موثقة';

  @override
  String get wasalnyComplaintEscalationNoWarranty =>
      'لا توجد بيانات ضمان ميداني مسجلة.';

  @override
  String get wasalnyComplaintEscalationConfirm =>
      'تأكيد رفع تصعيد الشكوى رسمياً';

  @override
  String get wasalnyComplaintBackToList => 'العودة لقائمة الشكاوى';

  @override
  String get wasalnyComplaintCallSeller => 'اتصال بالبائع';

  @override
  String get wasalnyComplaintCallBuyer => 'اتصال بالمشتري';

  @override
  String get wasalnyComplaintResolvedMessage => 'تم تسجيل حل الشكوى وديًا';

  @override
  String get wasalnyComplaintEscalatedMessage =>
      'تم تصعيد الشكوى لرئيس المشرفين';

  @override
  String get wasalnyComplaintCallFailed => 'تعذر بدء الاتصال من هذا الجهاز';

  @override
  String get wasalnyComplaintsLoadError => 'تعذر تحميل الشكاوى';

  @override
  String get wasalnyComplaintsRetry => 'إعادة المحاولة';

  @override
  String get wasalnyComplaintPartyUnavailable => 'غير مرتبط بطرف';

  @override
  String get wasalnyComplaintItem => 'السلعة';

  @override
  String get wasalnyComplaintDealCode => 'رقم الصفقة';

  @override
  String get wasalnyComplaintWarranty => 'الضمان الميداني';

  @override
  String get wasalnyComplaintResolveNote =>
      'تم الاتفاق بين البائع والمشتري على حل ودي';

  @override
  String get wasalnyComplaintResolveFailed => 'تعذر تسجيل الحل الودي';

  @override
  String get wasalnyComplaintEscalationReason =>
      'تتطلب الشكوى مراجعة رئيس المشرفين';

  @override
  String get wasalnyComplaintEscalationFailed => 'تعذر تصعيد الشكوى';

  @override
  String get wasalnyComplaintActionTakenStatus => 'تم اتخاذ إجراء';

  @override
  String get wasalnyAuditComplaintResolved => 'حل شكوى وديًا';

  @override
  String get wasalnyAuditComplaintEscalated => 'تصعيد شكوى لرئيس المشرفين';

  @override
  String get wasalnyAuditAdApproved => 'اعتماد إعلان وصلني';

  @override
  String get wasalnyAuditAdHidden => 'إخفاء إعلان وصلني';

  @override
  String get wasalnyAuditAdRejected => 'رفض إعلان وصلني';

  @override
  String get wasalnyAuditAdSuspended => 'تعليق إعلان وصلني';

  @override
  String get wasalnyAuditAdEditRequested => 'طلب تعديل إعلان وصلني';

  @override
  String get wasalnyAuditContactRevealed => 'إظهار بيانات تواصل طلب';

  @override
  String get wasalnyAuditContactHidden => 'إخفاء بيانات تواصل طلب';

  @override
  String get wasalnyNotificationsTitle => 'إشعارات وصلني';

  @override
  String get wasalnyNotificationNewRequest => 'طلب وصلني جديد';

  @override
  String get wasalnyNotificationNewRequestDescription =>
      'يوجد طلب جديد بانتظار متابعة مرحلة التوصيل.';

  @override
  String get wasalnyNotificationComplaint => 'تحديث على شكوى';

  @override
  String get wasalnyNotificationComplaintDescription =>
      'تم تحديث حالة الشكوى CMP-1042 وهي قيد المتابعة.';

  @override
  String get wasalnyNotificationInspection => 'اكتمل فحص شحنة';

  @override
  String get wasalnyNotificationInspectionDescription =>
      'تم تسجيل نتيجة فحص شحنة الطلب W-1038.';

  @override
  String get wasalnyPromotionSendToFinance => 'إرسال للمشرف المالي';

  @override
  String get wasalnyPromotionSentToFinance =>
      'تم إرسال طلب الترويج للمشرف المالي للمراجعة.';

  @override
  String get wasalnyPromotionFinancePending =>
      'لا يزال طلب الترويج بانتظار موافقة المشرف المالي.';

  @override
  String get wasalnyPromotionFinanceRequestType => 'طلب ترويج منتج';

  @override
  String wasalnyPromotionFinanceApprovalConfirmation(
      Object amount, Object beneficiary) {
    return 'هل تريد اعتماد ترويج $beneficiary بمبلغ $amount وإحالته للإدارة لتنفيذ الخصم؟';
  }

  @override
  String get wasalnyPromotionFinanceApproved =>
      'تم اعتماد طلب الترويج وإحالته للإدارة لتنفيذ الخصم.';

  @override
  String get wasalnyPromotionFinanceRejected =>
      'تم رفض طلب الترويج وإشعار مشرف وصلني بسبب الرفض.';

  @override
  String get wasalnyComplaintChatParty => 'دردشة مع الطرفين';

  @override
  String get wasalnyRequestsMonthlyLimitTitle => 'اكتمل الحد الشهري';

  @override
  String get wasalnyRequestsMonthlyLimitMessage =>
      'تم استخدام طلبَي إظهار البيانات لهذا المشتري هذا الشهر. يلزم الاشتراك في التطبيق لإظهار بيانات إضافية.';

  @override
  String get wasalnyPremiumCustomer => 'عميل مميز';

  @override
  String get wasalnyPremiumAdChoiceTitle => 'هل الإعلان ضمن الباقة؟';

  @override
  String get wasalnyPremiumAdChoiceMessage =>
      'هذا العميل مميز. هل يُحتسب الإعلان ضمن باقته أم يُعامل كإعلان ترويجي مدفوع؟';

  @override
  String get wasalnyPremiumAdIncluded => 'ضمن الباقة';

  @override
  String get wasalnyPremiumAdPaid => 'إعلان ترويجي مدفوع';

  @override
  String get wasalnyHeadInboxTitle => 'تصعيدات وصلني';

  @override
  String get wasalnyNotificationSourceFinance => 'المشرف المالي';

  @override
  String get wasalnyNotificationSourceChief => 'رئيس المشرفين';

  @override
  String get wasalnyNotificationSourceWasalny => 'حساب وصلني';

  @override
  String get wasalnyNotificationEmpty => 'لا توجد إشعارات جديدة.';

  @override
  String get wasalnyPromotionTitle => 'طلبات ترويج منتجات وصلني';

  @override
  String get wasalnyPromotionSubtitle =>
      'راجع طلبات إبراز المنتجات المستعملة وتابع حالة كل طلب';

  @override
  String get wasalnyRequestsSafetyTitle => 'بروتوكول أمان وساطة وصلني';

  @override
  String get wasalnyRequestsSafetyDescription =>
      'مراجعة طلبات وصلني من خلال إظهار بيانات التواصل فقط بعد تأكيد موافقة الطرفين.';

  @override
  String get wasalnyRequestsCompletionRate => 'نسبة الإتمام';

  @override
  String get wasalnyRequestsActiveDeals => 'صفقة نشطة';

  @override
  String get wasalnyRequestsAll => 'الكل';

  @override
  String get wasalnyRequestsAwaitingApproval => 'بانتظار الموافقة';

  @override
  String get wasalnyRequestsCommunication => 'جاري التواصل';

  @override
  String get wasalnyRequestsUnderReview => 'قيد المراجعة';

  @override
  String get wasalnyRequestsSold => 'تم البيع';

  @override
  String get wasalnyRequestsDelivery => 'توصيل';

  @override
  String get wasalnyRequestsInspection => 'الفحص الميداني';

  @override
  String get wasalnyRequestsEmpty => 'لا توجد طلبات في هذه المرحلة.';

  @override
  String get wasalnyRequestsEstimatedValue => 'القيمة المقدرة';

  @override
  String get wasalnyRequestsSeller => 'البائع';

  @override
  String get wasalnyRequestsBuyer => 'المشتري';

  @override
  String get wasalnyRequestsOrderNumber => 'رقم الطلب';

  @override
  String get wasalnyRequestsCurrentStatus => 'الحالة الحالية';

  @override
  String get wasalnyRequestsLocation => 'الموقع';

  @override
  String get wasalnyRequestsRevealTitle => 'إظهار بيانات التواصل';

  @override
  String get wasalnyRequestsRevealConfirmation =>
      'هل تريد إظهار بيانات التواصل للطرفين في هذا الطلب؟';

  @override
  String get wasalnyRequestsRevealAction => 'إظهار البيانات للمشتري';

  @override
  String get wasalnyRequestsHideData => 'إخفاء البيانات';

  @override
  String get wasalnyRequestsPreviewAction => 'معاينة الطلب';

  @override
  String get wasalnyRequestsPreviewTitle => 'تفاصيل الطلب';

  @override
  String get wasalnyAdsTitle => 'إعلانات المنتجات المستعملة';

  @override
  String get wasalnyAdsSubtitle => 'وحدة الرقابة والمطابقة الفنية';

  @override
  String get wasalnyAdsPendingToday => 'بانتظار المراجعة';

  @override
  String get wasalnyAdsApprovedToday => 'المعتمد اليوم';

  @override
  String get wasalnyAdsFilterAll => 'الكل';

  @override
  String get wasalnyAdsFilterPending => 'بانتظار المراجعة';

  @override
  String get wasalnyAdsFilterEdit => 'فحص وتعديل';

  @override
  String get wasalnyAdsFilterApproved => 'المعتمدة';

  @override
  String get wasalnyAdsEmpty => 'لا توجد إعلانات ضمن هذا التصنيف.';

  @override
  String get wasalnyAdsAuditNote =>
      'تم تدقيق وتأمين جميع الإجراءات الرقابية بتسجيل التدقيق الإداري.';

  @override
  String get wasalnyAdsLoadError => 'تعذر تحميل إعلانات وصلني.';

  @override
  String get wasalnyAdsUpdateError => 'تعذر تحديث حالة الإعلان.';

  @override
  String get wasalnyAdsPendingStatus => 'بانتظار المراجعة';

  @override
  String get wasalnyAdsApprovedStatus => 'منشور - مسار وصلني نشط';

  @override
  String get wasalnyAdsHiddenStatus => 'الإعلان مخفي';

  @override
  String get wasalnyAdsRejectedStatus => 'مرفوض - بانتظار تعديل البائع';

  @override
  String get wasalnyAdsAwaitingApprovalStatus => 'بانتظار الموافقة';

  @override
  String get wasalnyAdsSuspendedStatus => 'الإعلان معلّق';

  @override
  String get wasalnyAdsEditRequestedStatus => 'مطلوب تعديل الإعلان';

  @override
  String get wasalnyAdsAcceptAction => 'قبول';

  @override
  String get wasalnyAdsHideAction => 'إخفاء';

  @override
  String get wasalnyAdsSuspendAction => 'تعليق الإعلان';

  @override
  String get wasalnyAdsRejectAction => 'رفض بسبب';

  @override
  String get wasalnyAdsHideTitle => 'إخفاء الإعلان';

  @override
  String get wasalnyAdsSuspendTitle => 'تعليق الإعلان';

  @override
  String get wasalnyAdsEditRequestTitle => 'طلب تعديل الإعلان';

  @override
  String get wasalnyAdsRejectTitle => 'رفض الإعلان';

  @override
  String get wasalnyAdsHideReason => 'أدخل سبب إخفاء الإعلان';

  @override
  String get wasalnyAdsSuspendReason => 'أدخل سبب تعليق الإعلان';

  @override
  String get wasalnyAdsEditRequestReason => 'أدخل التعديلات المطلوبة من الناشر';

  @override
  String get wasalnyAdsRejectReason => 'أدخل سبب رفض الإعلان';

  @override
  String get wasalnyAdsReasonRequired => 'السبب مطلوب لإكمال العملية.';

  @override
  String get wasalnyAdsApproved => 'تم قبول الإعلان ونشره.';

  @override
  String get wasalnyAdsHidden => 'تم إخفاء الإعلان.';

  @override
  String get wasalnyAdsRejected => 'تم رفض الإعلان.';

  @override
  String get wasalnyAdsSuspended => 'تم تعليق الإعلان.';

  @override
  String get wasalnyAdsEditRequested => 'تم إرسال طلب التعديل إلى الناشر.';

  @override
  String get wasalnyAdDetailsTitle => 'تعديل وفحص بيانات الإعلان المستعمل';

  @override
  String get wasalnyAdDetailsPermission =>
      'صلاحية إشرافية مقيدة: تعديل البيانات الفنية فقط';

  @override
  String get wasalnyAdDetailsReadOnly => 'بيانات المعلن ثابتة (للاطلاع فقط)';

  @override
  String get wasalnyAdDetailsSellerVerified => 'موثق النفاذ';

  @override
  String get wasalnyAdDetailsSubmitted => 'تاريخ الإدراج';

  @override
  String get wasalnyAdDetailsPriceMatch =>
      'القيمة الحالية عادلة جداً ومطابقة لنطاق السعر.';

  @override
  String get wasalnyCategoryCamera => 'إلكترونيات وتصوير ‹ كاميرات احترافية';

  @override
  String get wasalnyCategoryConsole => 'ألعاب إلكترونية ‹ منصات ألعاب';

  @override
  String get wasalnyCategoryLaptop => 'إلكترونيات ‹ أجهزة كمبيوتر محمولة';

  @override
  String get wasalnyCategoryBicycle => 'رياضة وترفيه ‹ دراجات';

  @override
  String get wasalnyAdDetailsImageGallery => 'معرض صور المنتج المفحوص';

  @override
  String wasalnyAdDetailsPhotosCount(Object count, Object total) {
    return '$count من $total مقبولة';
  }

  @override
  String get wasalnyAdDetailsFront => 'هيكل الكاميرا الأمامي';

  @override
  String get wasalnyAdDetailsControls => 'الشاشة وأزرار التحكم';

  @override
  String get wasalnyAdDetailsLens => 'قاعدة العدسة والمستشعر';

  @override
  String get wasalnyAdDetailsAddPhoto => 'إضافة صورة توثيق';

  @override
  String get wasalnyAdDetailsCategory => 'التصنيف والقسم المعتمد';

  @override
  String get wasalnyAdDetailsCategoryMatch =>
      'تمت مطابقة القسم آلياً وفق نوع المنتج المستعمل والفئة السعرية.';

  @override
  String get wasalnyAdDetailsPrice => 'السعر المعتمد للنشر';

  @override
  String get wasalnyAdDetailsPriceRange => 'نطاق السعر العادل';

  @override
  String get wasalnyAdDetailsDescription => 'الوصف المعتمد وتدقيق المحتوى';

  @override
  String get wasalnyAdDetailsAutoCheck =>
      'فحص تلقائي: نظيف وخالٍ من الكلمات المحظورة';

  @override
  String get wasalnyAdDetailsCharacters => 'حرف';

  @override
  String get wasalnyAdDetailsApprove => 'اعتماد الإعلان للنشر';

  @override
  String get wasalnyAdDetailsRequestEdit => 'طلب تعديل من الناشر';

  @override
  String get wasalnyAdDetailsSuspend => 'تعليق الإعلان';

  @override
  String get wasalnyAdDetailsReject => 'رفض الإعلان ومخالفة المعايير';

  @override
  String get wasalnyChatWithSeller => 'دردشة مع المعلن';

  @override
  String get wasalnyCallSeller => 'الاتصال بالمعلن';

  @override
  String get wasalnyChatOrCallSeller => 'دردشة مع المعلن أو الاتصال به';

  @override
  String get wasalnyContactSellerTitle => 'التواصل مع الشخص المعلن';

  @override
  String get wasalnyContactSellerSubtitle =>
      'تواصل مباشرة مع المعلن لمناقشة تفاصيل الإعلان أو طلب توضيحات فنية';

  @override
  String get wasalnyCallNow => 'اتصال الآن';

  @override
  String wasalnyCallingSeller(Object phone) {
    return 'جاري الاتصال بالمعلن: $phone';
  }

  @override
  String get wasalnyCopyPhone => 'نسخ رقم الهاتف';

  @override
  String get wasalnyPhoneCopied => 'تم نسخ رقم المعلن إلى الحافظة';

  @override
  String get wasalnySellerPhoneLabel => 'رقم هاتف المعلن';

  @override
  String get wasalnyAdsUpdated => 'تم تحديث الإعلان.';

  @override
  String get wasalnyAdsReason => 'سبب الإجراء';

  @override
  String productComingSoon(Object section) {
    return 'قسم $section قيد التجهيز';
  }

  @override
  String get productSupervisorWelcome => 'مرحباً، المشرف محمد';

  @override
  String get productReviewSubtitle => 'مشرف مراجعة المنتجات الجديدة';

  @override
  String get productPendingAdsCount => 'بانتظار المراجعة';

  @override
  String get productApprovedAdsCount => 'إعلان معتمد';

  @override
  String get productSearchHint => 'ابحث برقم الإعلان أو عنوان المنتج...';

  @override
  String get productCategoryAll => 'الكل';

  @override
  String get productCategoryHome => 'أجهزة منزلية';

  @override
  String get productCategoryElectronics => 'إلكترونيات';

  @override
  String get productCategoryWatches => 'عطور وساعات';

  @override
  String get productReviewListTitle => 'المنتجات الجديدة قيد المراجعة';

  @override
  String productReceivedMinutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String get productConditionNew => 'جديد بالكرتون';

  @override
  String get productConditionUsed => 'غير مستخدم';

  @override
  String get productAcceptAction => 'قبول';

  @override
  String get productHideAction => 'إخفاء';

  @override
  String get productRejectAction => 'رفض';

  @override
  String get productSuspendAction => 'تعليق';

  @override
  String get productSuspendConfirmTitle => 'تأكيد تعليق الإعلان';

  @override
  String productSuspendConfirmMessage(String title) {
    return 'هل تريد تعليق «$title» وإيقاف ظهوره مؤقتًا؟';
  }

  @override
  String get productStatusSuspended => 'تم التعليق';

  @override
  String get productFeaturedBadge => 'إعلان مميز';

  @override
  String get productSuspendSheetTitle => 'تعديل الإجراء الرقابي';

  @override
  String productSuspendSheetSubtitle(String reference, String title) {
    return 'إعلان #$reference • $title';
  }

  @override
  String get productSuspendChooseAction => 'تحديد الحالة الرقابية الجديدة';

  @override
  String get productSuspendRepublish => 'إظهار وإعادة النشر (مفعل)';

  @override
  String get productSuspendRepublishHint =>
      'تفعيل الظهور المباشر في سوق المنتجات الجديدة';

  @override
  String get productSuspendHideTemporarily => 'إخفاء مؤقت (تعليق الإعلان)';

  @override
  String get productSuspendHideTemporarilyHint =>
      'حجب مؤقت بانتظار استيفاء الشروط الرقابية';

  @override
  String get productSuspendRejectFinal => 'رفض نهائي';

  @override
  String get productSuspendRejectFinalHint =>
      'مخالفة المعايير الجديدة وإغلاق التذكرة فورًا';

  @override
  String get productSuspendSelected => 'محدد';

  @override
  String get productSuspendCurrent => 'الحالي';

  @override
  String get productSuspendReasonTitle => 'سبب تغيير الحالة وملاحظات المعتمد';

  @override
  String get productSuspendReasonHint => 'اكتب سبب الإجراء الرقابي...';

  @override
  String get productSuspendDefaultReason =>
      'تم استيفاء صور التغليف والتحقق بنجاح وإعادة تفعيل الإعلان';

  @override
  String get productSuspendReasonNote => 'سيظهر هذا التوضيح في سجل التدقيق';

  @override
  String get productSuspendNotifyTitle => 'إرسال إشعار فوري للناشر';

  @override
  String get productSuspendNotifyHint =>
      'تنبيه فوري عن التغيير والسبب المحدد للحالة';

  @override
  String get productSuspendSaveAction => 'حفظ وتحديث الحالة';

  @override
  String get productReviewImagesHint =>
      'اضغط لمراجعة صور السلعة وفاتورة الشراء';

  @override
  String get productAcceptConfirmTitle => 'تأكيد قبول المنتج';

  @override
  String productAcceptConfirmMessage(Object title) {
    return 'هل تريد قبول «$title» واعتماده للنشر؟';
  }

  @override
  String get productHideConfirmTitle => 'تأكيد إخفاء المنتج';

  @override
  String productHideConfirmMessage(Object title) {
    return 'هل تريد إخفاء «$title» من قائمة المنتجات المعروضة؟';
  }

  @override
  String get productRejectConfirmTitle => 'تأكيد رفض المنتج';

  @override
  String get productRejectReasonHint => 'أدخل سبب رفض المنتج';

  @override
  String get productRejectReasonRequired => 'سبب الرفض مطلوب لإكمال العملية';

  @override
  String get productHideReasonHint => 'أدخل سبب إخفاء المنتج';

  @override
  String get productHideReasonRequired => 'سبب الإخفاء مطلوب لإكمال العملية';

  @override
  String get productConfirmAction => 'تأكيد العملية';

  @override
  String get productCancelAction => 'إلغاء';

  @override
  String get productStatusApproved => 'تم القبول';

  @override
  String get productStatusHidden => 'تم الإخفاء';

  @override
  String get productStatusRejected => 'تم الرفض';

  @override
  String get productEmptyResults => 'لا توجد منتجات مطابقة';

  @override
  String get productReviewActionSuccess => 'تم تحديث حالة المنتج';

  @override
  String get productReviewLoadError =>
      'تعذر تحميل المنتجات قيد المراجعة. حاول مرة أخرى.';

  @override
  String get productReviewUpdateError =>
      'تعذر حفظ قرار المنتج. حدّث الصفحة وحاول مرة أخرى.';

  @override
  String get productDetailsTitle => 'مراجعة المنتج';

  @override
  String get productDetailsAppBarTitle => 'عرض الإعلان';

  @override
  String get productDetailsInvoice => 'فاتورة الشراء';

  @override
  String get productDetailsPhotos => 'صور المنتج';

  @override
  String get productDetailsMerchant => 'التاجر';

  @override
  String get productDetailsPrice => 'السعر';

  @override
  String get productDetailsCategory => 'التصنيف';

  @override
  String get productDetailsCondition => 'حالة المنتج';

  @override
  String get productReviewSessionInProgress => 'جلسة فحص ومراجعة نشطة';

  @override
  String get productSellerLabel => 'المعلن:';

  @override
  String get productSellerVerified => 'موثق';

  @override
  String get productViewFullAd => 'عرض تفاصيل الإعلان الكاملة';

  @override
  String get productViewFullAdHint =>
      'شاشة لمراجعة وتعديل تفاصيل الإعلان والوصف';

  @override
  String get productInvoiceAttached => 'فاتورة الشراء مرفقة';

  @override
  String get productImageQualityChecked => 'جودة الصور مفحوصة';

  @override
  String get productAuditChecklistTitle =>
      'قائمة التدقيق الإلزامي للمنتجات الجديدة:';

  @override
  String get productAuditPackagingTitle =>
      'شريط الأمان والغلاف البلاستيكي سليم تماماً';

  @override
  String get productAuditPackagingHint =>
      'تم فحص التغليف ولم يظهر أي تمزق أو إعادة إغلاق حراري.';

  @override
  String get productAuditSerialTitle =>
      'الرقم التسلسلي مطابق للمواصفات المحلية';

  @override
  String get productAuditSerialHint =>
      'الباركود المسجل متطابق مع قاعدة بيانات الهيئة الرسمية.';

  @override
  String get productAuditDescriptionTitle =>
      'لا يوجد وصف يلمح لأي استخدام مسبق أو تجريبي';

  @override
  String get productAuditDescriptionHint =>
      'خلو نصوص الإعلان من عبارات مثل «مفتوح للتجربة» أو «شبه جديد».';

  @override
  String get productInstantPublishingTitle => 'نشر تلقائي فوري';

  @override
  String get productInstantPublishingHint =>
      'اعتماد هذا الفحص سيقوم بنشر الإعلان مباشرة في السوق المفتوح. وإرسال إشعار رسمي للمعلن بانتهاء التدقيق.';

  @override
  String get productApproveAndPublishNow => 'اعتماد ونشر فوراً';

  @override
  String get productBackToReview => 'إغلاق / رجوع';

  @override
  String get productFullDetailsTitle => 'عرض تفاصيل الإعلان';

  @override
  String get productPhotoDocumentationTitle => 'معاينة صور التوثيق والتغليف';

  @override
  String get productPhotoCount => 'صور مرفوعة';

  @override
  String get productPhotoAdOriginal => 'منتج جديد - مغلق أصلي';

  @override
  String get productPhotoQualityCheck => 'فحص الملصق';

  @override
  String get productSellerInquiryTitle => 'استفسار للمعلن';

  @override
  String get productSellerInquiryHint =>
      'طلب توضيح أو إشعار المعلن بتعديل فوري';

  @override
  String get productSendInquiry => 'مراسلة';

  @override
  String get productInquiryMessageHint => 'اكتب استفسارك للمعلن...';

  @override
  String get productApprovedCategory => 'التصنيف المعتمد';

  @override
  String get productDescriptionAndCondition => 'وصف المنتج وحالته';

  @override
  String get productWarrantyLabel => 'إضافة صيغة الضمان';

  @override
  String get productDescriptionHint => 'اكتب وصف المنتج وتفاصيل حالته...';

  @override
  String productDescriptionCharacterCount(int count) {
    return '$count حرف';
  }

  @override
  String get productDescriptionSafetyCheck =>
      'تم التحقق من خلو النص من الألفاظ المضللة';

  @override
  String get productAdHistoryTitle => 'سجل حالة الإعلان';

  @override
  String get productHistoryOpenStatus => 'مفتوح';

  @override
  String get productHistoryCreated => 'تم إنشاء الإعلان بواسطة المستخدم';

  @override
  String get productHistoryDocumentsAttached => 'إرفاق صور التغليف والباركود';

  @override
  String get productHistoryAssigned => 'إسناد الإعلان للمشرف الميداني';

  @override
  String get productHistoryCurrent =>
      'الحالة الحالية: قيد فحص المواصفات والاستيفاءات';

  @override
  String get productEditPermissionHint =>
      'صلاحية التعديل الرقابي مقتصرة على التصنيف والسعر والوصف فقط. لا يمكن تغيير بيانات الناشر.';

  @override
  String get productFinalDecisionLabel => 'قرار المشرف الإداري النهائي';

  @override
  String get productRequiredFieldsError =>
      'يرجى استكمال السعر والوصف قبل المتابعة.';

  @override
  String get productInvalidPriceError => 'أدخل سعرًا صحيحًا بالأرقام.';

  @override
  String get productWorkspaceComingSoon => 'هذه الصفحة قيد التجهيز';

  @override
  String get productPromotionTitle => 'إدارة ترويج المنتجات المميزة';

  @override
  String get productPromotionSubtitle =>
      'راجع طلبات إبراز المنتجات وتابع العروض النشطة';

  @override
  String get productPromotionPending => 'بانتظار القرار';

  @override
  String get productPromotionActive => 'نشط';

  @override
  String get productPromotionTotal => 'إجمالي الطلبات';

  @override
  String get productPromotionRequests => 'طلبات الترويج';

  @override
  String get productPromotionFilterAll => 'الكل';

  @override
  String get productPromotionCompleted => 'مكتمل';

  @override
  String get productPromotionEmpty => 'لا توجد طلبات ضمن هذا التصنيف.';

  @override
  String get productPromotionPlanInfo =>
      'راجع أهلية الإعلان وحالة الدفع قبل تفعيل باقة الترويج. مدة الباقة تبدأ بعد الاعتماد.';

  @override
  String get productPromotionFeaturedPlan => 'ظهور مميز';

  @override
  String get productPromotionPremiumPlan => 'ظهور مميز بلس';

  @override
  String get productPromotionDays => 'يوم';

  @override
  String get productPromotionRequestedAt => 'تاريخ الطلب:';

  @override
  String get productPromotionDecisionNote => 'ملاحظة القرار';

  @override
  String get productPromotionApprove => 'اعتماد الترويج';

  @override
  String get productPromotionReject => 'رفض الطلب';

  @override
  String get productPromotionApproveTitle => 'تأكيد اعتماد الترويج';

  @override
  String productPromotionApproveMessage(Object title) {
    return 'هل تريد اعتماد طلب ترويج «$title»؟';
  }

  @override
  String get productPromotionConfirmApprove => 'تأكيد الاعتماد';

  @override
  String get productPromotionPaymentStatusTitle => 'حالة الدفع';

  @override
  String get productPromotionViewPaymentStatus => 'عرض حالة الدفع';

  @override
  String get productPromotionPaidByFinance => 'تم تأكيد الدفع من المالية';

  @override
  String get productPromotionUnpaid => 'لم يتم الدفع بعد';

  @override
  String get productPromotionUnpaidMessage =>
      'لا يمكن اعتماد طلب الترويج قبل تأكيد المالية استلام المبلغ.';

  @override
  String get productPromotionRejectTitle => 'رفض طلب الترويج';

  @override
  String get productPromotionRejectReasonHint => 'اكتب سبب رفض الطلب';

  @override
  String get productPromotionConfirmReject => 'تأكيد الرفض';

  @override
  String get productPromotionApproved => 'تم اعتماد طلب الترويج.';

  @override
  String get productPromotionRejected => 'تم رفض طلب الترويج.';

  @override
  String get productPromotionExpired => 'منتهي';

  @override
  String get productPromotionDisclaimer =>
      'بيانات الطلبات المعروضة تجريبية؛ يلزم ربطها بخدمة الاشتراكات والمدفوعات قبل التشغيل الفعلي.';

  @override
  String get productPromotionAuditApproved => 'اعتماد طلب ترويج منتج';

  @override
  String get productPromotionAuditRejected => 'رفض طلب ترويج منتج';

  @override
  String get productWalletTitle => 'محفظة المشرف';

  @override
  String get productWalletBack => 'رجوع';

  @override
  String get productWalletSupervisorId => 'SUP-9942';

  @override
  String get productWalletVerified => 'موثق';

  @override
  String get productWalletAvailableForWithdrawal =>
      'الرصيد المتاح للسحب الفوري';

  @override
  String get productWalletBalanceAmount => '8,450 ج.م';

  @override
  String get productWalletReady => 'نشط وجاهز';

  @override
  String get productWalletBalanceNote =>
      'يشمل مستحقات الإشراف المعتمدة وبدلات التدقيق المنتهية وجاهزة للتحويل الفوري.';

  @override
  String get productWalletTotalDues => 'إجمالي المستحقات';

  @override
  String get productWalletTotalDuesAmount => '12,500 ج.م';

  @override
  String get productWalletDuesDetail => 'الراتب + الحوافز المحققة';

  @override
  String get productWalletPendingReview => 'قيد التدقيق المالي';

  @override
  String get productWalletPendingAmount => '4,050 ج.م';

  @override
  String get productWalletPendingDetail => 'مراجعة الفحص والمكافآت';

  @override
  String get productWalletSettlementRate => 'دورة تسوية أسبوعية منتظمة';

  @override
  String get productWalletSettlementPercent => 'معدل جاهزية الصرف: 68%';

  @override
  String get productWalletRequestTitle => 'طلب سحب المستحقات المالية';

  @override
  String get productWalletNoFees => 'بدون رسوم تحويل';

  @override
  String get productWalletAmountToWithdraw => 'مبلغ السحب المطلوب';

  @override
  String get productWalletWithdrawableHint =>
      'سحب كامل المبلغ المتاح (8,450 ج.م)';

  @override
  String get productWalletCurrency => 'ج.م';

  @override
  String get productWalletLimitNote =>
      'الحد الأدنى لعملية السحب 100 ج.م، الحد الأقصى اليومي 20,000 ج.م.';

  @override
  String get productWalletChooseDestination => 'اختر وجهة التحويل';

  @override
  String get productWalletInstapay => 'إنستاباي';

  @override
  String get productWalletFast => 'فوري';

  @override
  String get productWalletMobileWallet => 'محفظة هاتف';

  @override
  String get productWalletWalletProviders => 'فودافون / أورنج';

  @override
  String get productWalletBankTransfer => 'تحويل بنكي';

  @override
  String get productWalletIban => 'آيبان (IBAN)';

  @override
  String get productWalletIbanAddress =>
      'عنوان الدفع اللحظي (IPA) أو رقم الآيبان المصرفي';

  @override
  String get productWalletPaymentAddress =>
      'عنوان الدفع اللحظي (IPA) أو رقم الهاتف المرتبط';

  @override
  String get productWalletProcessingTime =>
      'سرعة المعالجة: فوري ومباشر على مدار الساعة';

  @override
  String get productWalletFeeDetails =>
      'رسوم المعالجة والتحويل: 0.5 ج.م (محفظة بالكامل للمشرف)';

  @override
  String get productWalletSubmitRequest => 'تأكيد وطلب السحب المالي';

  @override
  String get productWalletAmountError => 'أدخل مبلغاً بين 100 و8,450 ج.م.';

  @override
  String get productWalletDetailsError =>
      'أكمل بيانات الحساب قبل إرسال طلب السحب.';

  @override
  String get productWalletConfirmTitle => 'تأكيد طلب السحب';

  @override
  String productWalletConfirmMessage(Object amount) {
    return 'هل تريد تأكيد سحب مبلغ $amount ج.م؟';
  }

  @override
  String get productWalletConfirmAction => 'تأكيد السحب';

  @override
  String get productWalletRequestSent => 'تم تسجيل طلب السحب بنجاح.';

  @override
  String get productWalletBonusTitle => 'حافز الإنجاز الأسبوعي متاح!';

  @override
  String get productWalletBonusAmount => '+500 ج.م';

  @override
  String get productWalletBonusDescription =>
      'أنجزت 4 من 5 أهداف ميدانياً بنجاح يفوق المعايير المحددة.';

  @override
  String get productWalletHistoryTitle => 'سجل العمليات والتحويلات الأخيرة';

  @override
  String get productWalletFullStatement => 'عرض كشف الحساب الكامل';

  @override
  String get productWalletTransactionOne => 'سحب بنكي - مصرف الراجحي';

  @override
  String get productWalletTransactionOneMeta => 'TRX-9821 • أمس، 02:40 م';

  @override
  String get productWalletTransactionOneAmount => '-5,000';

  @override
  String get productWalletTransactionTwo => 'عمولة فحص ميداني معتمد';

  @override
  String get productWalletTransactionTwoMeta =>
      'أجهزة إلكترونية • WS-4088 • 24 أكتوبر';

  @override
  String get productWalletTransactionTwoAmount => '+350';

  @override
  String get productWalletTransactionThree => 'تحويل فوري - InstaPay';

  @override
  String get productWalletTransactionThreeMeta => 'IPA-3310 • 21 أكتوبر';

  @override
  String get productWalletTransactionThreeAmount => '-2,200';

  @override
  String get productWalletPaid => 'مكتمل';

  @override
  String get productWalletDeposit => 'إيداع';

  @override
  String get productWalletAuditTitle =>
      'العمليات المالية مشفرة وتخضع لتدقيق هيئة الرقابة المحاسبية لمنصة وسوقي';

  @override
  String get productWalletAuditCode => 'رمز التدقيق الدوري: AUDIT-SEC-2024-v9';

  @override
  String get productWalletStatementUnavailable =>
      'سيتم عرض تفاصيل كشف الحساب عند ربط المحفظة بالخدمات المالية.';

  @override
  String get productSupervisorToolsTitle => 'سجل المشرف والمساندة';

  @override
  String get productAuditHistoryTitle => 'سجل القرارات والتدقيق الرقابي';

  @override
  String get productAuditHistorySubtitle =>
      'مراجعة سجل قراراتك وإجراءاتك السابقة';

  @override
  String get productAuditEmpty => 'لا توجد عمليات مسجلة حتى الآن.';

  @override
  String get productAuditLoadError => 'تعذر تحميل سجل التدقيق. حاول مرة أخرى.';

  @override
  String get productAuditSaveError =>
      'تعذر حفظ العملية في سجل التدقيق. لم يتم تسجيل الطلب.';

  @override
  String get productAuditActionApproved => 'اعتماد منتج';

  @override
  String get productAuditActionHidden => 'إخفاء منتج';

  @override
  String get productAuditActionRejected => 'رفض منتج';

  @override
  String get productAuditActionSuspended => 'تعليق إعلان';

  @override
  String get productAuditActionUpdated => 'تعديل تفاصيل منتج';

  @override
  String get productAuditActionFieldAvailability => 'تغيير التوفر الميداني';

  @override
  String get productAuditActionUrgentNotifications =>
      'تغيير تنبيهات البلاغات العاجلة';

  @override
  String get productAuditEnabled => 'تم التفعيل';

  @override
  String get productAuditDisabled => 'تم التعطيل';

  @override
  String get productAuditActionWithdrawalRequested => 'طلب سحب مستحقات مالية';

  @override
  String get productAuditActionOther => 'إجراء رقابي';

  @override
  String get productSupportTitle => 'مركز المساندة والدعم';

  @override
  String get productSupportSubtitle =>
      'الدعم الإداري والتقني والتواصل مع رئيس المشرفين';

  @override
  String get productAdminSupportTitle => 'الدعم الإداري';

  @override
  String get productAdminSupportDetail =>
      'استفسارات الإجراءات والسياسات والتصعيد الإداري';

  @override
  String get productTechnicalSupportTitle => 'الدعم التقني';

  @override
  String get productTechnicalSupportDetail =>
      'المساعدة في مشكلات التطبيق والحساب والأدوات';

  @override
  String get productSupportContactTitle => 'التواصل مع فريق الدعم';

  @override
  String get productHeadSupervisorName => 'رئيس المشرفين';

  @override
  String get productHeadSupervisorRole => 'التصعيد والمتابعة الإدارية';

  @override
  String get productTechnicalSupportName => 'فريق الدعم التقني';

  @override
  String get productTechnicalSupportHours => 'متاح لمتابعة الأعطال التقنية';

  @override
  String get productSupportOpenChat => 'بدء محادثة';

  @override
  String get productSupportHours =>
      'تواصل مع الدعم عبر المحادثة، وتظهر ساعات العمل وفق الجدول المعتمد.';

  @override
  String get productChatsTitle => 'الدردشات';

  @override
  String get productChatToday => 'اليوم';

  @override
  String get productChatYesterday => 'أمس';

  @override
  String get productHeadSupervisorPreview =>
      'يمكنك إرسال الاستفسارات وطلبات التصعيد هنا.';

  @override
  String get productTechnicalSupportPreview => 'تواصل معنا للمساعدة التقنية.';

  @override
  String get productNotificationsTitle => 'الإشعارات';

  @override
  String get productNotificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get productNotificationNewReviewTitle => 'طلبات جديدة قيد المراجعة';

  @override
  String get productNotificationNewReviewBody =>
      'توجد منتجات جديدة بانتظار إجراء المراجعة.';

  @override
  String get productNotificationWalletTitle => 'تحديث المستحقات المالية';

  @override
  String get productNotificationWalletBody =>
      'تم تحديث ملخص مستحقاتك ودورة التسوية الأسبوعية.';

  @override
  String get productNotificationPolicyTitle => 'تنبيه رقابي';

  @override
  String get productNotificationPolicyBody =>
      'يرجى مراجعة قائمة التدقيق قبل اعتماد المنتجات.';

  @override
  String get productNotificationToday => 'اليوم';

  @override
  String get productNotificationYesterday => 'أمس';

  @override
  String get productNotificationEarlier => 'سابقاً';

  @override
  String get productReportEyebrow => 'الرقابة والجودة التنفيذية';

  @override
  String get productReportTitle => 'تقارير قسم المنتجات الجديدة';

  @override
  String get productReportExport => 'تصدير';

  @override
  String get productReportToday => 'اليوم';

  @override
  String get productReportThisWeek => 'هذا الأسبوع';

  @override
  String get productReportThisMonth => 'هذا الشهر';

  @override
  String get productReportCustom => 'مخصص';

  @override
  String get productReportReviewedAds => 'الإعلانات المفحوصة';

  @override
  String get productReportComparedToPrevious => 'مقارنة بالفترة السابقة';

  @override
  String get productReportApprovalRate => 'معدل الاعتماد';

  @override
  String productReportApprovedCount(int count) {
    return '$count إعلان معتمد';
  }

  @override
  String get productReportDeclinedRate => 'الحجب والرفض';

  @override
  String productReportDeclinedCount(int count) {
    return '$count إعلان محجوب';
  }

  @override
  String get productReportAverageReview => 'متوسط سرعة الفحص';

  @override
  String get productReportMinutesAndFaster => 'أسرع بنسبة 25%';

  @override
  String get productReportMinuteUnit => 'دقيقة';

  @override
  String get productReportStandardsTitle => 'معايير التحقق الصارمة للجديد';

  @override
  String get productReportStandardsVersion => 'بروتوكول 4.2';

  @override
  String get productReportPackagingTitle => 'شرط التغليف الحراري';

  @override
  String get productReportPackagingHint =>
      'التأكد من عدم فتح الشريط الأمني الأصلي';

  @override
  String get productReportSerialTitle => 'التحقق التسلسلي';

  @override
  String get productReportSerialHint =>
      'فحص قاعدة بيانات الضمان المحلي المعتمد';

  @override
  String get productReportCategoryTitle => 'توزيع أصناف المنتجات الجديدة';

  @override
  String productReportAdsCount(int count) {
    return '$count إعلان';
  }

  @override
  String get productReportElectronics => 'إلكترونيات وهواتف ذكية';

  @override
  String get productReportGames => 'أجهزة وألعاب ترفيهية';

  @override
  String get productReportPerfumes => 'عطور وساعات فاخرة';

  @override
  String get productReportHomeAppliances => 'أجهزة منزلية ومطبخ';

  @override
  String get productReportAuditTitle => 'أحدث الإجراءات الرقابية المسجلة';

  @override
  String get productReportLive => 'تحديث حي';

  @override
  String get productReportHidden => 'تم الإخفاء';

  @override
  String get productReportApproved => 'تم الاعتماد';

  @override
  String get productReportRejected => 'تم الرفض';

  @override
  String productReportActionHeadline(String adNumber) {
    return 'إعلان $adNumber';
  }

  @override
  String get productReportEditAction => 'تعديل الإجراء';

  @override
  String get productReportEditDialogTitle => 'تعديل الإجراء الرقابي';

  @override
  String get productReportActionStatus => 'حالة الإجراء';

  @override
  String get productReportActionReason => 'سبب الإجراء';

  @override
  String get productReportApplyEdit => 'تطبيق';

  @override
  String get productReportRecentActionsNote =>
      'هذه أحدث الإجراءات المسجلة في الفترة المحددة.';

  @override
  String get productReportDataNote =>
      'بيانات عرض تجريبية تتغير حسب الفترة المحددة';

  @override
  String get productReportSaveAndUpdate => 'حفظ وتحديث الحالة فورًا';

  @override
  String get productReportDiscardChanges => 'إلغاء والتراجع';

  @override
  String get productReportSaved => 'تم حفظ تحديثات التقرير محليًا';

  @override
  String get productReportExportTitle => 'تصدير التقرير بصيغة CSV';

  @override
  String get productReportCopyCsv => 'نسخ CSV';

  @override
  String get productReportExportCopied => 'تم نسخ بيانات التقرير';

  @override
  String get productProfileMetricsTitle => 'المؤشرات الرقابية والتشغيلية';

  @override
  String get productProfileLastUpdated => 'آخر تحديث: 12 دقيقة';

  @override
  String get productProfileName => 'م. طارق بن عبد العزيز العتيبي';

  @override
  String get productProfileRegion => 'منطقة الرياض والمحافظات المجاورة';

  @override
  String get productProfileSupervisorId => 'SUP-1082';

  @override
  String get productProfileVerified => 'مشرف ميداني معتمد';

  @override
  String get productProfileFieldAvailability => 'متاح ميدانيًا لاستلام الفحص';

  @override
  String get productProfileFieldAvailabilityHint =>
      'الاستجابة المباشرة ضمن نطاق 15 كم';

  @override
  String get productProfilePreferenceLocalOnlyNotice =>
      'تُحفظ هذه الإعدادات على هذا الجهاز فقط؛ إرسال الإشعارات غير متصل حالياً.';

  @override
  String get productProfilePreferenceLoadError =>
      'تعذّر تحميل الإعدادات المحفوظة. اضغط لإعادة المحاولة.';

  @override
  String get productProfileReviewed => 'الصفقات المفحوصة';

  @override
  String get productProfileSinceLastMonth => '+18% عن الشهر الماضي';

  @override
  String get productProfileApprovalMetric => 'التوفيق والحل الودي';

  @override
  String get productProfileApprovedOfTotal => 'من أصل 263 نزاعًا مفتوحًا';

  @override
  String get productProfileResponseSpeed => 'متوسط سرعة الاستجابة';

  @override
  String get productProfileFasterThanAverage => 'أسرع بـ 6 دقائق من المعيار';

  @override
  String get productProfileQualityMetric => 'معدل الرضا الرقابي';

  @override
  String get productProfileQualityDetail => 'استنادًا إلى 210 تقييمًا فنيًا';

  @override
  String get productProfileDocumentsTitle =>
      'الوثائق والتفويضات الإشرافية المعتمدة';

  @override
  String get productProfileAuthorization => 'بطاقة الرقابة الميدانية';

  @override
  String get productProfileAuthorizationSubtitle =>
      'تفويض إشرافي نشط • ينتهي 15/06/1447 هـ';

  @override
  String get productProfileActive => 'نشطة';

  @override
  String get productProfilePolicy => 'لائحة ضوابط وحجز الضمان';

  @override
  String get productProfilePolicySubtitle => 'الإصدار 4.2 المعتمد';

  @override
  String get productProfileDelegation => 'وثيقة صلاحيات حسم النزاع';

  @override
  String get productProfileDelegationSubtitle => 'تفويض إشرافي مباشر';

  @override
  String get productProfileReview => 'مراجعة';

  @override
  String get productProfileWalletTitle => 'محفظتي والبيانات المالية';

  @override
  String get productProfileJustUpdated => 'محدثة الآن';

  @override
  String get productProfileWalletBalance => 'الرصيد المتاح والمستحقات';

  @override
  String get productProfileWalletAmount => '14,850 ج.م';

  @override
  String get productProfileWalletDetail =>
      'بدلات الإشراف الميداني + مستحقات التوفيق';

  @override
  String get productProfileOperationsTitle =>
      'الإعدادات التشغيلية والمهام الميدانية';

  @override
  String get productProfileUrgentAlerts =>
      'تنبيهات البلاغات العاجلة (VIP Dispatch)';

  @override
  String get productProfileUrgentAlertsSubtitle =>
      'إشعار صوتي فوري لأولوية قصوى للنزاعات والاستلام';

  @override
  String get productProfileAuditLog => 'سجل القرارات والتدقيق الرقابي السابق';

  @override
  String get productProfileAuditLogSubtitle =>
      'أرشيف محاضر التفتيش وإغلاق البلاغات المنجزة';

  @override
  String get productProfileAuditLogDetail =>
      'سجل القرارات الرقابية متاح للمراجعة من لوحة التقارير.';

  @override
  String get productProfileSupport => 'مركز المساندة والدعم الإداري والتقني';

  @override
  String get productProfileSupportSubtitle =>
      'اتصال مباشر بمدير العمليات المركزية';

  @override
  String get productProfileSupportDetail =>
      'للحصول على المساندة، تواصل مع مدير العمليات المركزية عبر قنوات الدعم المعتمدة.';

  @override
  String get productProfileEndSession => 'إنهاء الجلسة الإشرافية وتسجيل الخروج';

  @override
  String get productProfileFooter =>
      'بوابة الرقابة الميدانية • تطبيق برواح المازوري للإدارة';

  @override
  String get productProfileBuild => 'Build 2.9.44 - Auth Token Valid';

  @override
  String get adsMerchantVerified => 'موثق';

  @override
  String adsPhotoPosition(Object current, Object total) {
    return '$current من $total صور';
  }

  @override
  String get adsAdPhotoVerified => 'فحص الصورة';

  @override
  String adsIdentifier(Object number) {
    return 'معرف الإعلان: #$number';
  }

  @override
  String get adsAskingPrice => 'السعر المطلوب من التاجر';

  @override
  String get adsAdDescription => 'نص إعلان التاجر';

  @override
  String get adsLicenseChecklist => 'قائمة التحقق النظامية للترخيص';

  @override
  String adsChecklistCount(int passed, int total) {
    return '$passed / $total بنود';
  }

  @override
  String get adsAutoHideReportsTitle => 'إخفاء تلقائي عند ورود بلاغات';

  @override
  String get adsAutoHideReportsDescription =>
      'إخفاء الإعلان مؤقتاً لحين إعادة التدقيق';

  @override
  String get adsDeliveryTitle => 'مصاريف التوصيل والشحن الخاصة بالمنتج';

  @override
  String get adsDeliveryActive => 'خدمة مفعلة';

  @override
  String get adsDeliveryDescription =>
      'خدمة التوصيل مطلوبة مع هذا الإعلان. يحق للمشرف تعديل رسوم التوصيل قبل الاعتماد أو الإخفاء.';

  @override
  String get adsDeliveryFee => 'مبلغ ثابت (ج.م)';

  @override
  String get adsUpdateDeliveryFee => 'تحديث الرسوم';

  @override
  String get adsDeliveryFeeNote => 'تم تدقيق وتعديل التوصيل وفق اللائحة';

  @override
  String get adsSupervisorDecision => 'قرار المشرف الإداري';

  @override
  String get adsSupervisorLevel => 'صلاحية الاعتماد: المستوى 1';

  @override
  String get adsRequestEdit => 'طلب تعديل بيانات';

  @override
  String get adsEditRequestTitle => 'طلب تعديل بيانات الإعلان';

  @override
  String get adsEditRequestSubtitle =>
      'اكتب الملاحظات والتوجيهات المطلوبة من التاجر لتعديل الإعلان قبل النشر';

  @override
  String adsEditRequestAdTitle(Object title) {
    return 'الإعلان: $title';
  }

  @override
  String get adsEditRequestGuidanceTitle =>
      'ملاحظات وتوجيهات المشرف للتاجر (إلزامي)';

  @override
  String get adsEditRequestInstructions =>
      'يرجى توضيح جميع التفاصيل والبنود المطلوب تعديلها بوضوح لتوجيه التاجر مباشرة إلى ما يحتاج لتصحيحه قبل إعادة مراجعة الإعلان.';

  @override
  String get adsEditRequestHint => 'اكتب التعديلات المطلوبة من التاجر...';

  @override
  String get adsEditRequestRequired => 'هذا الحقل مطلوب لإرسال طلب التعديل';

  @override
  String get adsEditRequestSend => 'إرسال طلب التعديل للتاجر';

  @override
  String get adsEditRequestCancel => 'إلغاء وتراجع';

  @override
  String get adsFeeUpdated => 'تم تحديث رسوم التوصيل';

  @override
  String get adsFeeInvalid => 'أدخل مبلغاً صحيحاً غير سالب';

  @override
  String get adsRequestEditUnavailable => 'طلب تعديل البيانات غير متاح حالياً';

  @override
  String get adsMileage => 'العداد الحالي';

  @override
  String get adsExteriorColor => 'اللون الخارجي';

  @override
  String get adsAccidentRecord => 'تقرير الحوادث';

  @override
  String get adsTransmission => 'ناقل الحركة';

  @override
  String get adsMileageValue => '15,000 كم';

  @override
  String get adsWhiteColorValue => 'أبيض لؤلؤي';

  @override
  String get adsNoAccidentsValue => 'خالٍ من الحوادث';

  @override
  String get adsAutomaticValue => 'أوتوماتيك';

  @override
  String get adsPhoneWarranty => 'الكفالة المحلية';

  @override
  String get adsPhoneCondition => 'حالة المنتج';

  @override
  String get adsPhoneColor => 'اللون';

  @override
  String get adsPhoneStorage => 'سعة التخزين';

  @override
  String get adsWarrantyValue => '5 سنوات';

  @override
  String get adsNewConditionValue => 'جديد';

  @override
  String get adsNaturalTitaniumValue => 'تيتانيوم طبيعي';

  @override
  String get adsStorageValue => '256 جيجابايت';

  @override
  String get adsVillaArea => 'مساحة الأرض';

  @override
  String get adsVillaRooms => 'عدد الغرف';

  @override
  String get adsVillaLicense => 'الترخيص العقاري';

  @override
  String get adsVillaLocation => 'الموقع';

  @override
  String get adsVillaAreaValue => '375 م²';

  @override
  String get adsVillaRoomsValue => '5 غرف نوم';

  @override
  String get adsVillaLicensedValue => 'ساري وموثق';

  @override
  String get adsVillaLocationValue => 'حي النرجس، الرياض';

  @override
  String get adsVehicleDescription =>
      'السيارة بحالة الوكالة، شبه جديدة، صيانة كاملة لدى الوكيل. جميع الصيانات الدورية تمت في مراكز مرسيدس المعتمدة. لا يوجد رش أو تعديل نهائياً.';

  @override
  String get adsPhoneDescription =>
      'جهاز جديد غير مستخدم، بضمان محلي ساري، مع كامل الملحقات والفاتورة. تمت مطابقة الرقم التسلسلي والمواصفات مع المستندات المرفقة.';

  @override
  String get adsVillaDescription =>
      'فيلا مودرن فاخرة بتصميم حديث وتشطيبات عالية الجودة، في موقع مميز قريب من الخدمات. رخصة البناء والوثائق العقارية متوفرة للمراجعة.';

  @override
  String get adsCheckPrice => 'السعر والشروط المالية متوافقة';

  @override
  String get adsCheckPhotos => 'الصور واقعية ومطابقة';

  @override
  String get adsCheckSpecifications => 'تطابق المواصفات مع فحص السلامة';

  @override
  String get adsCheckMerchantLicense => 'سريان رخصة المعرض التجاري والمفوضين';

  @override
  String get adsCheckExpiryReminder => 'تنتهي بعد 90 يوماً - تذكير آلي مفعل';

  @override
  String get adsCheckReminder => 'تنبيه';

  @override
  String get adsCheckReviewRecommended => 'تنبيه';

  @override
  String get adsCheckPassed => 'مفحوص';

  @override
  String get finRequestReadOnlyNotice =>
      'الإجراءات المالية من صلاحية المدير المالي فقط';

  @override
  String get finRequestMerchantProceeds => 'مستحقات التجار المعلقة';

  @override
  String get finRequestTotalProceeds => '142,500';

  @override
  String get finRequestProceedsNote => 'ضمن نطاق إشرافك';

  @override
  String get finRequestReviewQueue => 'لدى الإدارة المالية';

  @override
  String get finRequestUnderReview => 'قيد التدقيق المالي';

  @override
  String get finRequestHistoryTitle => 'سجل العمليات والمطالبات';

  @override
  String get finRequestUpdatedJustNow => 'تحديث فوري';

  @override
  String get finRequestAllFilter => 'الكل (3)';

  @override
  String get finRequestSalesFilter => 'أرباح مبيعات';

  @override
  String get finRequestWithdrawalFilter => 'سحب أرصدة';

  @override
  String get finRequestPackageFilter => 'رسوم باقات';

  @override
  String get finRequestNoResults => 'لا توجد طلبات مطابقة لهذا التصنيف';

  @override
  String get finRequestCarMerchant => 'مؤسسة الأفق لتجارة السيارات';

  @override
  String get finRequestCarTitle => 'طلب تحويل أرباح مبيعات';

  @override
  String get finRequestCarAmount => '48,000';

  @override
  String get finRequestTodayTime => 'اليوم، 10:45 ص';

  @override
  String get finRequestBankVerified => 'حساب الآيبان مدقق ومعتمد ميدانياً';

  @override
  String get finRequestPackageMerchant => 'متجر الصفوة للإلكترونيات';

  @override
  String get finRequestPackageTitle => 'سداد رسوم اشتراك باقة ذهبية - سنوي';

  @override
  String get finRequestPackageAmount => '3,500';

  @override
  String get finRequestYesterdayTime => 'أمس، 04:15 م';

  @override
  String get finRequestCompleted => 'مكتمل ومعتمد من المالية';

  @override
  String get finRequestApprovedByFinance =>
      'تم الاعتماد بواسطة: إدارة الحسابات العامة';

  @override
  String get finRequestJewelryMerchant => 'مجوهرات البريق';

  @override
  String get finRequestWithdrawalTitle => 'طلب سحب رصيد محفظة';

  @override
  String get finRequestWithdrawalAmount => '22,000';

  @override
  String get finRequestOlderTime => '20 أكتوبر، 02:20 م';

  @override
  String get finRequestAwaitingManager => 'بانتظار موافقة المدير المالي';

  @override
  String get finRequestSalesMatched => 'مطابقة كشوفات المبيعات مكتملة';

  @override
  String get finRequestCurrency => 'ج.م';

  @override
  String get finRequestRestrictedStatus => 'جاهز للمطابقة';

  @override
  String get finRequestSendToFinance => 'إرسال للمشرف المالي';

  @override
  String get finRequestViewDetails => 'عرض تفاصيل الطلب';

  @override
  String get finRequestPolicyTitle => 'سياسة التدقيق المزدوج';

  @override
  String get finRequestPolicyMessage =>
      'أي طلب مالي يتطلب اعتماداً نهائياً من الإدارة المالية. صلاحيات مشرف التجار للعرض والمتابعة فقط.';

  @override
  String get finRequestNumber => 'رقم الطلب';

  @override
  String get finRequestClose => 'إغلاق';

  @override
  String get merchantProfileName => 'أحمد بن عبد العزيز الشهري';

  @override
  String get merchantProfileRegion => 'مشرف تجار ميداني - منطقة الرياض';

  @override
  String get merchantProfileSupervisorId => 'SUP-4092';

  @override
  String get merchantProfileActive => 'نشط وموثق';

  @override
  String get merchantProfileMonthlyAds => 'إعلان هذا الشهر';

  @override
  String get merchantProfileStores => 'تاجر نشط تحت إشرافك';

  @override
  String get withdrawalRequestDetails => 'عرض تفاصيل الطلب';

  @override
  String get withdrawalDetailsTitle => 'تفاصيل طلب السحب';

  @override
  String get withdrawalDetailsRequestNumber => 'رقم الطلب';

  @override
  String get withdrawalDetailsBeneficiary => 'المستفيد';

  @override
  String get withdrawalDetailsBeneficiaryRole => 'صفة المستفيد';

  @override
  String get withdrawalDetailsGrossAmount => 'إجمالي المبلغ';

  @override
  String get withdrawalDetailsFeePercentage => 'نسبة العمولة';

  @override
  String get withdrawalDetailsFeeAmount => 'قيمة العمولة';

  @override
  String get withdrawalDetailsNetAmount => 'صافي المبلغ المستحق';

  @override
  String get withdrawalDetailsBankName => 'البنك';

  @override
  String get withdrawalDetailsIban => 'رقم الآيبان';

  @override
  String get withdrawalDetailsDate => 'تاريخ الطلب';

  @override
  String get withdrawalDetailsAuditResult => 'نتيجة الفحص';

  @override
  String get withdrawalDetailsAlert => 'ملاحظة رقابية';

  @override
  String get withdrawalDetailsSource => 'مصدر المستحقات';

  @override
  String get withdrawalDetailsTransferMethod => 'طريقة التحويل';

  @override
  String get withdrawalDetailsInstantReady => 'متاح للتحويل الفوري';

  @override
  String get withdrawalDetailsStatusPending => 'قيد المراجعة';

  @override
  String get withdrawalDetailsStatusInvestigation => 'قيد التحقيق والتدقيق';

  @override
  String get withdrawalDetailsStatusApproved => 'معتمد';

  @override
  String get withdrawalDetailsStatusFrozen => 'مجمّد';

  @override
  String get withdrawalDetailsStatusRejected => 'مرفوض';

  @override
  String get withdrawalDetailsNoValue => 'غير متوفر';

  @override
  String get merchantProfileDocumentsTitle =>
      'الملفات والمستندات الرقابية المعتمدة';

  @override
  String get merchantProfileAuthorizationCard =>
      'بطاقة التفويض الإشرافي الميداني';

  @override
  String get merchantProfileValidUntil => 'صلاحية حتى 31 ديسمبر 2025';

  @override
  String get merchantProfileOpenDocument => 'استعراض البطاقة';

  @override
  String get merchantProfileGovernanceGuide => 'دليل معايير اعتماد الإعلانات';

  @override
  String get merchantProfileGuideSubtitle =>
      'اللوائح الإعلانية والضوابط التنظيمية';

  @override
  String get merchantProfileDelegationDocument =>
      'وثيقة تفويض الصلاحيات للإدارة';

  @override
  String get merchantProfileDelegationSubtitle =>
      'الامتثال القانوني ومصفوفة القرارات';

  @override
  String get merchantProfileFieldPermissions =>
      'إدارة الاتصال والصلاحيات الميدانية';

  @override
  String get merchantProfileUpdatedAutomatically => 'محدث تلقائياً';

  @override
  String get merchantProfileAvailability => 'التوفر الميداني والجاهزية';

  @override
  String get merchantProfileAvailabilitySubtitle =>
      'تلقي طلبات المراجعة الميدانية';

  @override
  String get merchantProfileDirectNotifications =>
      'التنبيهات المباشرة للإعلانات';

  @override
  String get merchantProfileNotificationsSubtitle =>
      'إشعار فوري عند رفع إعلان أو تأهيله';

  @override
  String get merchantProfileLocalOnlyNotice =>
      'تُحفظ التغييرات على هذا الجهاز فقط؛ إرسال الإشعارات غير متصل حالياً.';

  @override
  String get merchantProfileLocalAuditNotice =>
      'يعرض هذا السجل المحلي تغييرات الملف الشخصي على هذا الجهاز فقط، وليس سجل تدقيق على الخادم.';

  @override
  String get merchantProfileNoLocalActivity =>
      'لا توجد تغييرات محلية مسجلة على الملف الشخصي بعد.';

  @override
  String get merchantProfilePreferenceUpdated => 'تم تغيير تفضيل الملف الشخصي';

  @override
  String get merchantProfileEnabled => 'مُفعّل';

  @override
  String get merchantProfileDisabled => 'مُعطّل';

  @override
  String get merchantProfileLoadError =>
      'تعذّر تحميل إعدادات الملف الشخصي المحفوظة.';

  @override
  String get merchantProfileSaveError =>
      'تعذّر حفظ هذا الإعداد على الجهاز. حاول مرة أخرى.';

  @override
  String get merchantProfileRetry => 'إعادة المحاولة';

  @override
  String get merchantProfileSecurityAudit => 'الأمان والتدقيق الإداري';

  @override
  String get merchantProfileChangeSettings => 'تغيير الإعدادات';

  @override
  String get merchantAuditSuspended => 'تعليق التاجر';

  @override
  String get merchantAuditUnsuspended => 'فك تعليق التاجر';

  @override
  String get merchantAuditFinancialSubmitted => 'إحالة طلب مالي للمشرف المالي';

  @override
  String get merchantAuditFinancialRejected => 'رفض طلب مالي';

  @override
  String get merchantAuditAdModerated => 'مراجعة إعلان تاجر';

  @override
  String get merchantAuditCommissionUpdated => 'تحديث عمولة التاجر';

  @override
  String get merchantAuditLoadError => 'تعذر تحميل سجل العمليات الرقابية.';

  @override
  String get merchantProfileViewAll => 'السجل الشامل';

  @override
  String get merchantProfileLatestActivities => 'آخر العمليات الرقابية المنفذة';

  @override
  String get merchantProfileToday => 'اليوم';

  @override
  String get merchantProfileActivityApproved =>
      'اعتماد حملة إعلانية: متجر أفق العطور';

  @override
  String get merchantProfileLicenseNumber => 'رقم الترخيص: LIC-9902';

  @override
  String get merchantProfileActivityEdit =>
      'طلب تعديل إعلان: معرض مطابخ النخبة';

  @override
  String get merchantProfileActivityEditDetails => 'مخالفة لمعيار وضوح الأسعار';

  @override
  String get merchantProfileActivityLocation =>
      'معاينة ميدانية وتثبيت موقع: أسواق المدى';

  @override
  String get merchantProfileActivityLocationDetails => 'فرع حي الصحافة';

  @override
  String get merchantProfileFinancialWallet => 'محفظتي والبيانات المالية';

  @override
  String get merchantWalletTitle => 'محفظتك';

  @override
  String get merchantWalletSupervisorStatus =>
      'مشرف معتمد • قطاع المستقل وصالني';

  @override
  String get merchantWalletReady => 'نشط وجاهز';

  @override
  String get merchantWalletAvailableBalance => 'الرصيد المتاح للسحب الفوري';

  @override
  String get merchantWalletAvailableAmount => '8,450';

  @override
  String get merchantWalletBalanceDescription =>
      'يشمل مستحقات الإشراف الميداني المعتمدة وبدلات التحقق الميدانية وجاهزة للتحويل الفوري.';

  @override
  String get merchantWalletPendingDues => 'قيد التدقيق المالي';

  @override
  String get merchantWalletPendingAmount => '4,050';

  @override
  String get merchantWalletTotalDues => 'إجمالي المستحقات';

  @override
  String get merchantWalletTotalAmount => '12,500';

  @override
  String get merchantWalletSettlementCycle => 'دورة تسوية أسبوعية منتظمة';

  @override
  String get merchantWalletReadiness => 'معدل جاهزية الصرف: 68%';

  @override
  String get merchantWalletWithdrawTitle => 'طلب سحب المستحقات المالية';

  @override
  String get merchantWalletNoTransferFees => 'بدون رسوم تحويل';

  @override
  String get merchantWalletRequestedAmount => 'مبلغ السحب المطلوب';

  @override
  String get merchantWalletFullBalance => 'سحب كامل الرصيد (8,450 ج.م)';

  @override
  String get merchantWalletTransferLimit =>
      'الحد الأدنى لعملية السحب 100 ج.م، الحد الأقصى اليومي 20,000 ج.م';

  @override
  String get merchantWalletChooseMethod => 'اختر وجهة التحويل';

  @override
  String get merchantWalletBankTransfer => 'تحويل بنكي';

  @override
  String get merchantWalletIban => 'آيبان (IBAN)';

  @override
  String get merchantWalletDigitalWallet => 'محفظة رقمية';

  @override
  String get merchantWalletWalletProvider => 'VFC / E&';

  @override
  String get merchantWalletInstantTransfer => 'إنستاباي';

  @override
  String get merchantWalletInstant => 'فوري';

  @override
  String get merchantWalletTransferAddress =>
      'عنوان الدفع اللحظي (IPA) أو رقم الهاتف المرتبط';

  @override
  String get merchantWalletIbanValue => 'SA0380000000608010167519';

  @override
  String get merchantWalletPhoneValue => '01012345678';

  @override
  String get merchantWalletInstantAddress => 'supervisor.audit@instapay';

  @override
  String get merchantWalletAccountName =>
      'اسم الحساب المسجل: م. عبد الرحمن الشهري (موثق)';

  @override
  String get merchantWalletProcessingDetails =>
      'سرعة المعالجة: فوري ومباشر على مدار الساعة\nرسوم المعالجة والتحويل: 0.5 ج.م (محفظة بالكامل للمشرف)';

  @override
  String get merchantWalletConfirmWithdrawal => 'تأكيد وطلب السحب المالي';

  @override
  String get merchantWalletBonusTitle => 'حافز الإنجاز الأسبوعي متاح!  +500';

  @override
  String get merchantWalletBonusDescription =>
      'أنجزت 5 مهام ميدانية بنجاح بتفوق المعايير المحددة.';

  @override
  String get merchantWalletTransactionHistory =>
      'سجل العمليات والتحويلات الأخيرة';

  @override
  String get merchantWalletTransactionBank => 'سحب بنكي - مصرف الراجحي';

  @override
  String get merchantWalletTransactionDateOne => 'أمس، 02:40 م';

  @override
  String get merchantWalletTransactionAmountOne => '-5,000';

  @override
  String get merchantWalletTransactionInstant => 'تحويل فوري - InstaPay';

  @override
  String get merchantWalletTransactionDateTwo => '21 أكتوبر';

  @override
  String get merchantWalletTransactionAmountTwo => '-2,200';

  @override
  String get merchantWalletCompleted => 'مكتمل';

  @override
  String get merchantWalletAuditNotice =>
      'العمليات المالية مشفرة وتخضع لآلية الرقابة المحاسبية لمنصة وصالني';

  @override
  String get merchantWalletAuditCode => 'رمز التحقق الدوري: AUDIT-SEC-2024-v9';

  @override
  String get merchantWalletActionUnavailable => 'طلب السحب غير متاح حالياً';

  @override
  String get merchantProfileJustUpdated => 'محدث لحظياً';

  @override
  String get merchantProfileBalanceTitle => 'الرصيد المتاح والمستحقات';

  @override
  String get merchantProfileBalance => '14,850';

  @override
  String get merchantProfileBalanceDetails =>
      'بدلات الإشراف الميداني + مستحقات التوثيق';

  @override
  String get merchantProfileWalletDetails => 'تفاصيل المحفظة';

  @override
  String get merchantProfileDocumentDetails => 'مستند معتمد للمشرف';

  @override
  String get merchantProfileDocumentNumber => 'رقم المستند';

  @override
  String get merchantProfileClose => 'إغلاق';

  @override
  String get merchantProfileMinutesUnit => 'دقيقة مضت';

  @override
  String get merchantProfileTwoHoursAgo => 'منذ ساعتين';

  @override
  String get merchantProfileMorningAbbreviation => 'ص';

  @override
  String get merchantInfoTitle => 'معلومات التاجر';

  @override
  String get merchantInfoProfile => 'ملف التاجر';

  @override
  String get merchantInfoLiveMonitoring => 'مراقبة مباشرة';

  @override
  String get merchantInfoStatusActive => 'نشط';

  @override
  String get merchantInfoStatusActiveVerified => 'نشط وموثق';

  @override
  String get merchantInfoStatusUnderAudit => 'قيد المراجعة';

  @override
  String get merchantInfoStatusUpdateRequired => 'تحديث البيانات مطلوب';

  @override
  String get merchantInfoStatusSuspended => 'معلق مؤقتاً';

  @override
  String merchantInfoAccreditedCategory(Object category) {
    return 'معتمد لدى $category';
  }

  @override
  String get merchantInfoTotalAds => 'إجمالي الإعلانات';

  @override
  String merchantInfoActiveAds(Object count) {
    return '$count نشط';
  }

  @override
  String merchantInfoAdsUnderReview(Object count) {
    return '$count قيد المراجعة';
  }

  @override
  String get merchantInfoAdsShort => 'إعلان';

  @override
  String get merchantInfoAdsGroup => 'الإعلانات';

  @override
  String get merchantInfoPendingOperations => 'العمليات المعلقة';

  @override
  String get merchantInfoSuspendTemporarily => 'تعليق مؤقت';

  @override
  String get merchantInfoMessageMerchant => 'مراسلة التاجر';

  @override
  String get merchantInfoActionUnavailable => 'هذا الإجراء غير متاح حالياً';

  @override
  String get merchantPendingOperationsEmpty =>
      'لا توجد عمليات أو إعلانات معلقة لهذا التاجر';

  @override
  String merchantPendingCount(Object count) {
    return '$count عملية معلقة';
  }

  @override
  String get merchantPendingMoreDetailsUnavailable =>
      'عدد الإعلانات المعلقة معروف، لكن تفاصيل القائمة الكاملة غير متوفرة حالياً.';

  @override
  String get merchantPendingReference => 'رقم الإعلان';

  @override
  String get merchantPendingPrice => 'السعر';

  @override
  String get merchantPendingApprove => 'اعتماد';

  @override
  String get merchantPendingReject => 'رفض';

  @override
  String get merchantPendingOperationHandled => 'تم تحديث حالة الإعلان';

  @override
  String get merchantConversationEmpty => 'ابدأ محادثة مع هذا التاجر';

  @override
  String get merchantConversationInputHint => 'اكتب رسالتك...';

  @override
  String get merchantConversationSend => 'إرسال';

  @override
  String get merchantInfoFinancialSettings =>
      'الإعدادات المالية وسياسة التوصيل';

  @override
  String get merchantInfoMerchantDashboard => 'تحكم المشرف';

  @override
  String get merchantInfoFinancialSettingsDescription =>
      'لوحة التحكم الرقابي للعمولات والخدمات اللوجستية وتحديد النمط المالي';

  @override
  String get merchantInfoCfoPermission =>
      'الصلاحية حصرية للمشرف المالي المعتمد';

  @override
  String get merchantInfoSalesCommission => 'عمولة التطبيق من المبيعات';

  @override
  String get merchantInfoFixedAmount => 'مبلغ ثابت بالأرقام (ج.م)';

  @override
  String get merchantInfoPercentage => 'نسبة مئوية (%)';

  @override
  String get merchantInfoAdjustCommission => 'تعديل نسبة العمولة المئوية (%)';

  @override
  String get merchantInfoSave => 'حفظ';

  @override
  String get merchantInfoCommissionExample =>
      'حاسبة تقريبية لعملية بيع بقيمة 100 ج.م:';

  @override
  String merchantInfoCommissionValue(Object amount, Object currency) {
    return 'عمولة المنصة: $amount $currency';
  }

  @override
  String get merchantInfoInvalidCommission => 'أدخل عمولة من 0 إلى 100';

  @override
  String get merchantInfoCommissionSaved => 'تم تحديث العمولة';

  @override
  String get merchantInfoVerification => 'بيانات التوثيق والاعتماد';

  @override
  String get merchantInfoVerifiedBadge => 'بيانات موثقة';

  @override
  String get merchantInfoOwner => 'اسم المفوض / المالك';

  @override
  String get merchantInfoPhone => 'رقم الهاتف المعتمد';

  @override
  String get merchantInfoEmail => 'البريد الإلكتروني الرسمي';

  @override
  String get merchantInfoJoinedDate => 'تاريخ الربط الإشرافي';

  @override
  String get merchantInfoNotProvided => 'غير متوفر';

  @override
  String get merchantInfoFieldAds => 'إعلانات التاجر الميدانية';

  @override
  String merchantInfoShowAll(Object count) {
    return 'عرض الكل ($count)';
  }

  @override
  String get merchantInfoNoAds => 'لا توجد إعلانات متاحة';

  @override
  String get merchantInfoAdApproved => 'معتمد';

  @override
  String get merchantInfoAdUnderReview => 'تحت الفحص';

  @override
  String get merchantSuspendBadge => 'إجراء احترازي';

  @override
  String get merchantSuspendTitle => 'إجراء تعليق متجر';

  @override
  String get merchantSuspendSubtitle => 'قرار رقابي وإداري عاجل';

  @override
  String get merchantSuspendImpact =>
      'تعليق المتجر سيوقف ظهور جميع إعلانات التاجر فوراً في محركات البحث وتطبيق المشترك، مع تجميد استقبال الطلبات الجديدة حتى تصحيح المخالفة واعتمادها.';

  @override
  String get merchantSuspendDetails => 'تفاصيل المخالفة والملاحظات الميدانية';

  @override
  String merchantSuspendCharacterCount(Object count) {
    return '$count / 500';
  }

  @override
  String get merchantSuspendDetailsHint =>
      'اكتب وصفاً مفصلاً للمخالفة يظهر للتاجر في لوحة تحكمه مع توضيح الخطوات المطلوبة للتسوية...';

  @override
  String get merchantSuspendPrivateNote =>
      'هذا النص سيظهر كسجل رسمي للتاجر في حسابه الموثق.';

  @override
  String get merchantSuspendAttachments =>
      'المستندات التوثيقية ومحاضر المعاينة';

  @override
  String get merchantSuspendUpload => 'انقر لإرفاق محضر المعاينة أو الصور';

  @override
  String get merchantSuspendFileTypes =>
      'صيغ مدعومة: PDF, JPG, PNG (بحد أقصى 10 ميجابايت)';

  @override
  String get merchantSuspendDuration => 'فترة التعليق المقترحة';

  @override
  String get merchantSuspendReasonCorrection =>
      'لحين تصحيح الوضع ومعالجة المخالفة';

  @override
  String get merchantSuspendReasonCorrectionDescription =>
      'إجراء موصى به من جهة الرقابة';

  @override
  String get merchantSuspendReasonDuration => 'تعليق محدد بـ 7 أيام';

  @override
  String get merchantSuspendReasonDurationDescription =>
      'رفع تلقائي بعد انقضاء المدة';

  @override
  String get merchantSuspendReasonLegal => 'إحالة عاجلة للشؤون القانونية';

  @override
  String get merchantSuspendReasonLegalDescription =>
      'يتطلب تحقيقاً وتدقيقاً قانونياً';

  @override
  String get merchantSuspendConfirm => 'تأكيد التعليق المؤقت وإشعار التاجر';

  @override
  String get merchantSuspendCancel => 'إلغاء والعودة لملف التاجر';

  @override
  String get noMerchantsFound => 'لا توجد متاجر مطابقة لخيارات البحث';

  @override
  String get merchantsUnderSupervisionTitle => 'التجار تحت الإشراف';

  @override
  String get supervisedAreaLabel =>
      'نطاق الإشراف: منطقة الرياض (وسط وشمال العاصمة)';

  @override
  String get supervisorFullName => 'المشرف: أحمد بن عبد العزيز الخضيري';

  @override
  String get totalFieldAccountsTitle => 'إجمالي الحسابات الميدانية';

  @override
  String get merchantsUnderYourSupervision => 'تاجراً تحت إشرافك';

  @override
  String get complianceRate => 'الامتثال';

  @override
  String get activeAndVerifiedMetric => 'نشط وموثق';

  @override
  String get pendingAlertsMetric => 'تنبيهات معلقة';

  @override
  String get temporarySuspendedMetric => 'تعليق مؤقت';

  @override
  String get searchMerchantPlaceholder =>
      'ابحث باسم المتجر، كود التاجر، أو السجل...';

  @override
  String filterAllWithCount(Object count) {
    return 'الكل ($count)';
  }

  @override
  String filterActiveWithCount(Object count) {
    return '$count نشط وموثق';
  }

  @override
  String filterPendingWithCount(Object count) {
    return '$count تنبيهات معلقة';
  }

  @override
  String filterSuspendedWithCount(Object count) {
    return '$count تعليق مؤقت';
  }

  @override
  String get sortMostActive => 'الترتيب: الأكثر نشاطاً';

  @override
  String get activeAdsHeader => 'إعلانات نشطة';

  @override
  String get pendingReviewHeader => 'معلق للمراجعة';

  @override
  String get platformCommissionHeader => 'عمولة المنصة';

  @override
  String get viewProfileAndControl => 'عرض الملف والتحكم';

  @override
  String get pendingProfitWithdrawalAlert => 'طلب سحب أرباح معلق';

  @override
  String get supervisoryNoteActive => 'ملاحظة إشرافية نشطة';

  @override
  String get deliveryStatusFieldInspection => 'فحص الميدان';

  @override
  String get deliveryStatusHeader => 'حالة التوصيل';

  @override
  String get descriptionStandardsViolation => 'مخالفة معايير الوصف VR3-858';

  @override
  String get zeroAdsDisplayedSuspended => '0 إعلان معروض (إيقاف إداري احترازي)';

  @override
  String get summonAction => 'استدعاء';

  @override
  String get reviewViolationAndUnfreeze => 'مراجعة المخالفة والفك';

  @override
  String get suspendedBadge => 'موقوف';

  @override
  String get remainingMerchantsTitle =>
      'يوجد 13 تاجر آخر بحالة نشطة وممتثلة تماماً';

  @override
  String get remainingMerchantsSubtitle =>
      'تم فحص سجلاتهم الدورية للأسبوع الحالي بنجاح';

  @override
  String get loadAndShowRemainingList => 'تحميل واستعراض بقية القائمة';

  @override
  String get fieldGovernanceCardTitle => 'حوكمة وتفويض المشرف الميداني';

  @override
  String get fieldGovernanceCardBody =>
      'كافة التجار المسجلين أعلاه مرتبطون مباشرة بنطاق إشرافك الميداني والرقابي بموجب قرار الحوكمة والتفويض الإداري رقم SUP-4092.';

  @override
  String get addNewMerchantToSupervision => 'إضافة تاجر جديد للإشراف';

  @override
  String get retryLoadMerchants => 'إعادة المحاولة';

  @override
  String get merchantNameField => 'اسم التاجر أو المنشأة';

  @override
  String get merchantCrField => 'رقم السجل التجاري';

  @override
  String get merchantPhoneField => 'رقم الهاتف المعتمد';

  @override
  String get supervisedMerchantsBadge => 'مشرف التجار';

  @override
  String get servicesSupervisorTitle => 'مشرف الخدمات';

  @override
  String get servicesSupervisorBadge => 'مشرف الخدمات · SRV-01';

  @override
  String get serviceProvidersTab => 'مقدمو الخدمات';

  @override
  String get servicesAccountTab => 'حسابي';

  @override
  String serviceProvidersCount(int count) {
    return '$count مقدمي خدمة';
  }

  @override
  String get serviceProviderProfileTitle => 'الملف والسجل المهني للمزود';

  @override
  String get serviceProviderAvailableForWork =>
      'متاح ومستعد لإسناد المهام الفورية';

  @override
  String get serviceProviderVerified => 'موثق';

  @override
  String get serviceProviderRegistryNumber => 'رقم السجل التجاري';

  @override
  String get serviceProviderViewProfileAndHistory => 'عرض ملف المقدم وسجله';

  @override
  String get serviceProviderPerformanceTitle => 'مؤشرات الأداء التشغيلي (KPIs)';

  @override
  String get serviceProviderUpdatedNow => 'تحديث مباشر';

  @override
  String get serviceProviderCompletedTasks => 'المهام المنجزة';

  @override
  String get serviceProviderTaskCompletionRate => 'نسبة الإنجاز 99.1%';

  @override
  String get serviceProviderOverallRating => 'التقييم العام';

  @override
  String get serviceProviderRatingOutOfFive => 'من 5.0 · 162 تقييماً';

  @override
  String get serviceProviderOnTimeRate => 'الالتزام بالمواعيد';

  @override
  String get serviceProviderPunctualityDetail => 'انضباط وجودة في الميدان';

  @override
  String get serviceProviderResponseSpeed => 'سرعة الاستجابة';

  @override
  String get serviceProviderMinutes => 'دقيقة';

  @override
  String get serviceProviderSpecialtiesTitle => 'التخصصات والاعتمادات الرسمية';

  @override
  String get serviceProviderSpecialtyAirConditioning =>
      'صيانة مكيفات سبليت ومركزي وتحديثات دكت احترافية';

  @override
  String get serviceProviderSpecialtyAppliances =>
      'شحن وتفريغ واختبار غاز تبريد R410A وفق المعايير';

  @override
  String get serviceProviderSpecialtyElectrical =>
      'غسيل دوري مضغوط وصيانة وقائية للمجمعات السكنية';

  @override
  String get serviceProviderPlanTitle => 'الامتياز المهني المعتمد';

  @override
  String get serviceProviderPlanDescription =>
      'خضوعات أمنية وتدريب عملي على جودة الخدمة';

  @override
  String get serviceProviderPlanTier => '6 فنيين';

  @override
  String get serviceProviderRecentTasksTitle =>
      'سجل أحدث المهام والعمليات المنجزة';

  @override
  String get serviceProviderFullHistory => 'السجل الكامل';

  @override
  String get serviceProviderViewFullHistory => 'عرض السجل الكامل';

  @override
  String get serviceProviderTaskAreaOne => 'حي الملقا';

  @override
  String get serviceProviderTaskAreaTwo => 'حي الياسمين';

  @override
  String get serviceProviderTaskAreaThree => 'حي الصحافة';

  @override
  String get serviceProviderTaskTitleOne => 'صيانة مكيف كونسيلد مركزي';

  @override
  String get serviceProviderTaskTitleTwo => 'فحص وتعبئة غاز فريون لمبنى تجاري';

  @override
  String get serviceProviderTaskTitleThree => 'فك وتركيب 4 وحدات سبليت جديدة';

  @override
  String get serviceProviderTaskDetailOne =>
      'دقة متناهية وسرعة فائقة، مع إنهاء الفحص قبل الوقت المحدد.';

  @override
  String get serviceProviderTaskDetailTwo =>
      'تم التأكد من سلامة التبريد قبل تسليم الموقع.';

  @override
  String get serviceProviderTaskDetailThree =>
      'اختبار عزل المواسير بعد التركيب.';

  @override
  String get serviceProviderTaskCompleted => 'مكتمل ومعتمد';

  @override
  String get serviceProviderHistoryEntryOne =>
      'صيانة مكيف كونسيلد مركزي · حي الملقا · 5.0';

  @override
  String get serviceProviderHistoryEntryTwo =>
      'فحص وتعبئة غاز فريون · حي الياسمين · 4.8';

  @override
  String get serviceProviderHistoryEntryThree =>
      'فك وتركيب وحدات سبليت · حي الصحافة · مكتمل';

  @override
  String get serviceProviderHistoryEntryFour =>
      'صيانة دورية لوحدات التكييف · حي النرجس · 5.0';

  @override
  String get serviceProviderHistoryEntryFive =>
      'فحص تمديدات الكهرباء · حي الورود · 4.9';

  @override
  String get servicesComplaintFilters => 'مرشحات الشكاوى';

  @override
  String get servicesComplaintRequireCompensation => 'إلزام المزود بالتعويض';

  @override
  String get servicesComplaintAlreadyClosed =>
      'الشكوى مغلقة؛ يمكنك مراجعة محضر الحل فقط.';

  @override
  String get servicesComplaintFiltersHint =>
      'استخدم مرشحات الحالة أو اكتب رقم الشكوى واسم العميل أو المزود.';

  @override
  String get merchantFeaturedBadge => 'تاجر مميز';

  @override
  String get merchantStandardBadge => 'تاجر عادي';

  @override
  String get merchantSuspendedSection => 'التجار المعلقون';

  @override
  String get merchantUnsuspendAction => 'فك التعليق';

  @override
  String get merchantUnsuspendConfirm =>
      'هل تريد إعادة تفعيل هذا التاجر وإزالته من قائمة التجار المعلقين؟';

  @override
  String get merchantUnsuspendSuccess =>
      'تم فك تعليق التاجر وإعادته إلى قائمة التجار.';

  @override
  String get merchantSuspendSuccess =>
      'تم تعليق التاجر وإضافته إلى قائمة التجار المعلقين.';

  @override
  String get merchantSuspensionSaveError =>
      'تعذر حفظ تغيير حالة التاجر. حاول مرة أخرى.';

  @override
  String get merchantFinanceStatusTitle => 'حالة طلب المشرف المالي';

  @override
  String get merchantFinanceViewStatus => 'عرض حالة الطلب';

  @override
  String get merchantFinanceStatusPending => 'قيد مراجعة المشرف المالي';

  @override
  String get merchantFinanceStatusApproved => 'تمت الموافقة';

  @override
  String get merchantFinanceStatusRejected => 'تم الرفض';

  @override
  String get merchantFinanceStatusOnHold => 'معلق / قيد التحقق';

  @override
  String get merchantFinanceRequestTitle => 'تفاصيل العملية';

  @override
  String get merchantFinanceAmountLabel => 'المبلغ';

  @override
  String get merchantFinanceDateLabel => 'تاريخ الطلب';

  @override
  String get merchantFinanceStatusLabel => 'الحالة';

  @override
  String get merchantFinanceNoteLabel => 'ملاحظة الطلب';

  @override
  String get merchantLinkHasCommercialRegister => 'لدى التاجر سجل تجاري';

  @override
  String get merchantLinkLocalScopeNotice =>
      'عند عدم وجود سجل، استخدم رقم الهاتف الموثق. يحفظ النموذج الطلب على هذا الجهاز فقط ضمن الحساب المسجل؛ الإسناد المشترك الآمن يتطلب ربطاً بالخادم.';

  @override
  String get merchantLinkValidationError =>
      'أدخل اسم التاجر ورقم هاتف صحيحاً ورقم السجل عند انطباقه.';

  @override
  String get merchantLinkSessionRequired =>
      'سجل الدخول مجدداً قبل إرسال طلب ربط التاجر.';

  @override
  String get merchantLinkSavedLocally =>
      'تم حفظ طلب الربط محلياً. لم يُرسل للتاجر أو للمنصة.';

  @override
  String get merchantLinkSaveFailed => 'تعذر حفظ طلب الربط.';

  @override
  String get merchantLinkSaving => 'جارٍ حفظ الطلب...';

  @override
  String get adsArchiveTitle => 'أرشيف الإعلانات';

  @override
  String get adsReviewQueueTab => 'قائمة المراجعة';

  @override
  String get adsPremium => 'مميز';

  @override
  String get adsRegular => 'عادي';

  @override
  String get adsSaveFailed => 'تعذر حفظ القرار. يرجى المحاولة مرة أخرى.';

  @override
  String get adsLoadFailed => 'تعذر تحميل قرارات الإعلانات المحفوظة.';

  @override
  String get adsFrozenStatus => 'مجمد';

  @override
  String get adsFreezeAction => 'تجميد الإعلان';

  @override
  String get adsUnfreezeAction => 'استعادة الإعلان';

  @override
  String get finRequestLocalWorkflowNotice =>
      'تُحفظ الطلبات محلياً وتُدرج لمراجعة المشرف المالي في هذه النسخة التجريبية. لا يتم خصم مبالغ أو إرسال إشعارات فعلية للتاجر.';

  @override
  String get finRequestSentConfirmation => 'تم إرسال الطلب إلى المشرف المالي.';

  @override
  String get finRequestActionFailed =>
      'تعذر إكمال الإجراء. يرجى المحاولة مرة أخرى.';

  @override
  String get finRequestRejectTitle => 'رفض طلب التاجر';

  @override
  String get finRequestRejectReason => 'أدخل سبب الرفض ليظهر للتاجر';

  @override
  String get finRequestRejectAction => 'رفض الطلب';

  @override
  String get finRequestRejected => 'مرفوض';

  @override
  String get finRequestRejectionSaved => 'تم حفظ سبب الرفض.';

  @override
  String get financeWalletRequestSubmitted =>
      'أُرسل الطلب إلى المشرف المالي للمراجعة. لم يتم أي تحويل.';

  @override
  String get financeRequestsInProgressTab => 'قيد الإجراء';

  @override
  String get financeRequestsArchiveTab => 'الأرشيف';

  @override
  String get financeRequestsArchiveSearchHint =>
      'ابحث برقم الطلب أو المستفيد أو مصدر الطلب';

  @override
  String get financeRequestsArchiveEmpty =>
      'ستظهر الطلبات المعتمدة والمرفوضة هنا.';

  @override
  String get financeRequestsArchiveNoResults =>
      'لا توجد طلبات مؤرشفة تطابق البحث أو التصفية.';

  @override
  String get financeRequestsInProgressEmpty =>
      'لا توجد طلبات بانتظار المراجعة.';

  @override
  String get financeRequestRefreshFailed =>
      'تم حفظ القرار، لكن تعذر تحديث قائمة الطلبات.';

  @override
  String get financeRequestListFailed =>
      'تعذر تحميل الطلبات المالية. اسحب لأسفل لإعادة المحاولة.';

  @override
  String get financeRecordApproval => 'تسجيل الموافقة';

  @override
  String get financeApproveOnlyConfirmation =>
      'هل تسجل الموافقة على هذا الطلب؟ لن يؤدي ذلك إلى تحويل الأموال. المبلغ:';

  @override
  String get withdrawalDetailsSourceAccount => 'الحساب مصدر الطلب';

  @override
  String get withdrawalDetailsOperationType => 'نوع العملية';

  @override
  String get financeOperationWithdrawal => 'سحب';

  @override
  String get financeOperationDeposit => 'إيداع';

  @override
  String get financeWalletRequestTitle => 'طلب عملية محفظة';

  @override
  String get financeWalletAmountLabel => 'المبلغ';

  @override
  String get financeWalletInvalidWithdrawalAmount =>
      'أدخل مبلغ سحب بين 100 و8,450 ج.م.';

  @override
  String get financeWalletInvalidDetails =>
      'أدخل مبلغاً صحيحاً بين 100 و20,000 ج.م وحدد وجهة الدفع.';

  @override
  String get financeWalletConfirmDepositTitle => 'تأكيد طلب الإيداع';

  @override
  String get financeWalletConfirmDepositAction => 'تأكيد طلب الإيداع';

  @override
  String get financeWalletSubmitRequest => 'إرسال الطلب للمراجعة المالية';

  @override
  String get financeWalletOperationNote =>
      'يجب أن يوافق المشرف المالي على الطلب. تُسجل الموافقة في التطبيق ولا تتحرك الأموال قبل تكامل خدمة الدفع.';

  @override
  String get departmentPendingAmount => 'أرصدة معلقة';

  @override
  String get departmentPendingOnlyFilter => 'لديها مبالغ معلقة';

  @override
  String get departmentNoPendingItems => 'لا توجد محافظ بمبالغ معلقة.';

  @override
  String get departmentExportReport => 'تصدير التقرير';

  @override
  String get departmentExportExcel => 'تصدير إلى Excel';

  @override
  String get departmentExportPdf => 'طباعة أو حفظ PDF';

  @override
  String get departmentReportName => 'الاسم';

  @override
  String get departmentReportReference => 'المرجع';

  @override
  String get departmentSearchHint => 'ابحث بالاسم أو المرجع أو الحالة';

  @override
  String get departmentNoSearchResults => 'لا توجد محافظ مطابقة لمعايير البحث.';

  @override
  String get departmentViewDetails => 'عرض تفاصيل المحفظة';

  @override
  String get departmentStatusLabel => 'حالة الحساب';

  @override
  String get departmentOperationsCount => 'عدد العمليات';

  @override
  String get merchantInfoAdRejected => 'مرفوض';

  @override
  String get merchantInfoAdFrozen => 'مجمد';

  @override
  String get merchantInfoAdHidden => 'مخفي';
}
