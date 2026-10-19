import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'borwah_mng'**
  String get appName;

  /// No description provided for @cfoSessionTimestamp.
  ///
  /// In ar, this message translates to:
  /// **'1446/11/04 هـ - 10:45 ص'**
  String get cfoSessionTimestamp;

  /// No description provided for @ordersUnit.
  ///
  /// In ar, this message translates to:
  /// **'طلبات'**
  String get ordersUnit;

  /// No description provided for @financialGovernanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'لائحة الحوكمة وتفويض الصلاحيات المالية'**
  String get financialGovernanceTitle;

  /// No description provided for @ongoingOperatingInvoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير ومستحقات التشغيل الجارية'**
  String get ongoingOperatingInvoices;

  /// No description provided for @completedAndMatched.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة ومطابقة 100%'**
  String get completedAndMatched;

  /// No description provided for @switchLanguage.
  ///
  /// In ar, this message translates to:
  /// **'تغيير اللغة'**
  String get switchLanguage;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تسجيل الخروج'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج من حسابك؟'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get logoutCancel;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logoutConfirm;

  /// No description provided for @appSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نظام الإدارة والإشراف الميداني'**
  String get appSubtitle;

  /// No description provided for @secureLoginPortal.
  ///
  /// In ar, this message translates to:
  /// **'بوابة تسجيل دخول آمنة ومشفّرة'**
  String get secureLoginPortal;

  /// No description provided for @workEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني الوظيفي'**
  String get workEmail;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @roleAccessNotice.
  ///
  /// In ar, this message translates to:
  /// **'يتم تحديد واجهة العمل وصلاحيات النظام تلقائياً حسب الرتبة الإشرافية فور التحقق.'**
  String get roleAccessNotice;

  /// No description provided for @loginButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @requestAccessReset.
  ///
  /// In ar, this message translates to:
  /// **'طلب استعادة الوصول عبر المسؤول التقني'**
  String get requestAccessReset;

  /// No description provided for @restrictedAccessFooter.
  ///
  /// In ar, this message translates to:
  /// **'هذا التطبيق مخصص للإدارة والمشرفين فقط'**
  String get restrictedAccessFooter;

  /// No description provided for @copyrightNotice.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار 3.4.0 (داخلي) • جميع الحقوق محفوظة لشركة برواح المازوري'**
  String get copyrightNotice;

  /// No description provided for @certifiedFinancialAuditor.
  ///
  /// In ar, this message translates to:
  /// **'مدقق مالي معتمد'**
  String get certifiedFinancialAuditor;

  /// No description provided for @liveFinancialSession.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة المالية المباشرة'**
  String get liveFinancialSession;

  /// No description provided for @financialControlTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرقابة المالية المركزية - برواح المازوري'**
  String get financialControlTitle;

  /// No description provided for @cfoControlPanelSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة تحكم المدير المالي | الوردية المالية النشطة ومطابقة السيولة الحية'**
  String get cfoControlPanelSubtitle;

  /// No description provided for @cfoName.
  ///
  /// In ar, this message translates to:
  /// **'أ. سليمان الراجحي'**
  String get cfoName;

  /// No description provided for @cfoRole.
  ///
  /// In ar, this message translates to:
  /// **'المدير المالي التنفيذي'**
  String get cfoRole;

  /// No description provided for @cfoBadgeCode.
  ///
  /// In ar, this message translates to:
  /// **'#CF0-01'**
  String get cfoBadgeCode;

  /// No description provided for @currencyEgy.
  ///
  /// In ar, this message translates to:
  /// **'ج.م'**
  String get currencyEgy;

  /// No description provided for @totalAggregatedLiquidity.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السيولة النقدية والضمانات المجمعة'**
  String get totalAggregatedLiquidity;

  /// No description provided for @alRajhiMainOperating.
  ///
  /// In ar, this message translates to:
  /// **'مصرف الراجحي (الحساب التشغيلي الرئيسي)'**
  String get alRajhiMainOperating;

  /// No description provided for @snbEscrowAccount.
  ///
  /// In ar, this message translates to:
  /// **'البنك الأهلي السعودي (حساب الضمان Escrow)'**
  String get snbEscrowAccount;

  /// No description provided for @pendingMerchantWithdrawalsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات السحب المعلقة قيد المراجعة للتجار والمستخدمين'**
  String get pendingMerchantWithdrawalsTitle;

  /// No description provided for @pendingSupervisorWithdrawalsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات السحب المعلقة قيد المراجعة للمشرفين و المساعدين'**
  String get pendingSupervisorWithdrawalsTitle;

  /// No description provided for @auditInvoiceNote.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج تدقيق ومطابقة فواتير قبل التوقيع'**
  String get auditInvoiceNote;

  /// No description provided for @pendingSubscriptionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الاشتراكات والترقيات المعلقة'**
  String get pendingSubscriptionsTitle;

  /// No description provided for @pendingSubscriptionsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ترقيات باقات المتاجر، اشتراكات الفنيين، وتجديد الاشتراكات السنوية بانتظار الاعتماد المالي'**
  String get pendingSubscriptionsSubtitle;

  /// No description provided for @reviewSubscriptionsAction.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة واعتماد الاشتراكات'**
  String get reviewSubscriptionsAction;

  /// No description provided for @operationalExpenses.
  ///
  /// In ar, this message translates to:
  /// **'المصاريف والمدفوعات التشغيلية'**
  String get operationalExpenses;

  /// No description provided for @expensesManagementTitle.
  ///
  /// In ar, this message translates to:
  /// **'المصاريف والمدفوعات'**
  String get expensesManagementTitle;

  /// No description provided for @amountToDisburse.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب دفعه وصرفه'**
  String get amountToDisburse;

  /// No description provided for @accountAndPaymentChannel.
  ///
  /// In ar, this message translates to:
  /// **'الحساب وقناة الدفع للخصم المباشر'**
  String get accountAndPaymentChannel;

  /// No description provided for @noAccountsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حسابات متاحة'**
  String get noAccountsAvailable;

  /// No description provided for @escrowBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'رصيد حساب الضمان:'**
  String get escrowBalanceLabel;

  /// No description provided for @currentLedgerBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الدفتري الحالي:'**
  String get currentLedgerBalanceLabel;

  /// No description provided for @expenseCategoryAndDocuments.
  ///
  /// In ar, this message translates to:
  /// **'تصنيف المصروف والمستندات المؤيدة'**
  String get expenseCategoryAndDocuments;

  /// No description provided for @detailedExpenseReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب سحب وصرف المصروف تفصيلياً'**
  String get detailedExpenseReason;

  /// No description provided for @expenseDetailsHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بياناً تفصيلياً بالمصروف'**
  String get expenseDetailsHint;

  /// No description provided for @invoiceSupportDocument.
  ///
  /// In ar, this message translates to:
  /// **'مرفق الفاتورة الضريبية والمستند المؤيد'**
  String get invoiceSupportDocument;

  /// No description provided for @attachDocumentOptional.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق صورة المستند إن وجدت'**
  String get attachDocumentOptional;

  /// No description provided for @expenseReasonRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة سبب المصروف أولاً'**
  String get expenseReasonRequired;

  /// No description provided for @expenseAmountInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغاً صحيحاً أكبر من صفر'**
  String get expenseAmountInvalid;

  /// No description provided for @expenseRequestPendingStatus.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار موافقة الإدارة'**
  String get expenseRequestPendingStatus;

  /// No description provided for @expenseRequestNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get expenseRequestNumber;

  /// No description provided for @expenseRequestAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get expenseRequestAmount;

  /// No description provided for @expenseRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب المصروف للإدارة للموافقة. لم يتغير رصيد الحساب.'**
  String get expenseRequestSent;

  /// No description provided for @expenseRequestSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال طلب المصروف. حاول مرة أخرى.'**
  String get expenseRequestSendFailed;

  /// No description provided for @expenseRequestSubmitting.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ إرسال الطلب...'**
  String get expenseRequestSubmitting;

  /// No description provided for @expenseConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب المصروف'**
  String get expenseConfirmTitle;

  /// No description provided for @expenseConfirmDescription.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إرسال طلب المصروف إلى الإدارة للمراجعة والموافقة، دون خصم المبلغ الآن.'**
  String get expenseConfirmDescription;

  /// No description provided for @expenseAttachedPrefix.
  ///
  /// In ar, this message translates to:
  /// **'مرفق'**
  String get expenseAttachedPrefix;

  /// No description provided for @expenseRemoveDocumentAction.
  ///
  /// In ar, this message translates to:
  /// **'انقر للإزالة'**
  String get expenseRemoveDocumentAction;

  /// No description provided for @expenseDocumentAttached.
  ///
  /// In ar, this message translates to:
  /// **'تم إرفاق المستند'**
  String get expenseDocumentAttached;

  /// No description provided for @expenseDocumentRemoved.
  ///
  /// In ar, this message translates to:
  /// **'تمت إزالة المستند المرفق'**
  String get expenseDocumentRemoved;

  /// No description provided for @strictFinancialDisbursementGovernance.
  ///
  /// In ar, this message translates to:
  /// **'حوكمة الصرف المالي المشدد'**
  String get strictFinancialDisbursementGovernance;

  /// No description provided for @disbursementGovernanceNote.
  ///
  /// In ar, this message translates to:
  /// **'تخضع هذه العملية للرقابة المستندية والمطابقة البنكية الآلية، ويتم توثيق أمر الصرف في سجل التدقيق المالي برقم تتبع مشفر وتتطلب تأكيد التوقيع الرقمي المباشر للمدير المالي (CFO).'**
  String get disbursementGovernanceNote;

  /// No description provided for @approvePaymentOrder.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد أمر الدفع وإرساله للإدارة'**
  String get approvePaymentOrder;

  /// No description provided for @cancelPaymentOrder.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الأمر والتراجع عنه'**
  String get cancelPaymentOrder;

  /// No description provided for @paymentApprovedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد أمر الدفع بنجاح'**
  String get paymentApprovedSuccessfully;

  /// No description provided for @monthlyTotalExpenses.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي مدفوعات الشهر'**
  String get monthlyTotalExpenses;

  /// No description provided for @expenseManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الصرف'**
  String get expenseManagement;

  /// No description provided for @scheduledDisbursementItems.
  ///
  /// In ar, this message translates to:
  /// **'4 بنود صرف مجدولة'**
  String get scheduledDisbursementItems;

  /// No description provided for @recordNewPayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل بيان دفع جديد / إدارة المصاريف'**
  String get recordNewPayment;

  /// No description provided for @monthlyEarnedCommissions.
  ///
  /// In ar, this message translates to:
  /// **'عمولات التطبيق المحصلة هذا الشهر'**
  String get monthlyEarnedCommissions;

  /// No description provided for @netRegulatoryRevenue.
  ///
  /// In ar, this message translates to:
  /// **'صافي الإيراد الرقابي'**
  String get netRegulatoryRevenue;

  /// No description provided for @comparedToLastMonth.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة بالشهر السابق (249,450 ج.م)'**
  String get comparedToLastMonth;

  /// No description provided for @balancesUnderRegulatoryAudit.
  ///
  /// In ar, this message translates to:
  /// **'أرصدة معلقة تحت التدقيق الرقابي'**
  String get balancesUnderRegulatoryAudit;

  /// No description provided for @frozenWalletsNote.
  ///
  /// In ar, this message translates to:
  /// **'محافظ مجمدة احترازياً بطلب الإدارة العامة والمشرفين لوجود بلاغات ونزاعات مفتوحة.'**
  String get frozenWalletsNote;

  /// No description provided for @operationalDepartmentsWallets.
  ///
  /// In ar, this message translates to:
  /// **'محافظ الأقسام التشغيلية المباشرة'**
  String get operationalDepartmentsWallets;

  /// No description provided for @activeSectorsCount.
  ///
  /// In ar, this message translates to:
  /// **'4 قطاعات حية'**
  String get activeSectorsCount;

  /// No description provided for @merchantsWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة قسم التجار والمتاجر'**
  String get merchantsWalletTitle;

  /// No description provided for @merchantsWalletDesc.
  ///
  /// In ar, this message translates to:
  /// **'رصيد دوري متاح للتسوية البنكية والسحب'**
  String get merchantsWalletDesc;

  /// No description provided for @usedAndEscrowWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة المستعمل وعربون «وصلني»'**
  String get usedAndEscrowWalletTitle;

  /// No description provided for @usedAndEscrowWalletDesc.
  ///
  /// In ar, this message translates to:
  /// **'حساب ضمان وتأمين صفقات نشط (Escrow)'**
  String get usedAndEscrowWalletDesc;

  /// No description provided for @servicesMaintenanceWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة طلبات الخدمات والصيانة'**
  String get servicesMaintenanceWalletTitle;

  /// No description provided for @servicesMaintenanceWalletDesc.
  ///
  /// In ar, this message translates to:
  /// **'مستحقات فنيين معتمدين ومزودي الخدمات'**
  String get servicesMaintenanceWalletDesc;

  /// No description provided for @servicesSupervisorRoleBadge.
  ///
  /// In ar, this message translates to:
  /// **'مشرف الخدمات'**
  String get servicesSupervisorRoleBadge;

  /// No description provided for @servicesSupervisorBadgeCode.
  ///
  /// In ar, this message translates to:
  /// **'#SRV-01'**
  String get servicesSupervisorBadgeCode;

  /// No description provided for @servicesSupervisorAccountName.
  ///
  /// In ar, this message translates to:
  /// **'مشرف الخدمات'**
  String get servicesSupervisorAccountName;

  /// No description provided for @servicesProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get servicesProfileTitle;

  /// No description provided for @servicesProfileName.
  ///
  /// In ar, this message translates to:
  /// **'م. عبد العزيز بن خالد السالم'**
  String get servicesProfileName;

  /// No description provided for @servicesProfileIdentity.
  ///
  /// In ar, this message translates to:
  /// **'مشرف ميداني أول · إدارة الخدمات'**
  String get servicesProfileIdentity;

  /// No description provided for @servicesProfileCoverage.
  ///
  /// In ar, this message translates to:
  /// **'النطاق: الرياض والمناطق المجاورة'**
  String get servicesProfileCoverage;

  /// No description provided for @servicesProfileAvailability.
  ///
  /// In ar, this message translates to:
  /// **'على رأس العمل - متاح للمناوبة'**
  String get servicesProfileAvailability;

  /// No description provided for @servicesProfileCompletedTasks.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المنجزة'**
  String get servicesProfileCompletedTasks;

  /// No description provided for @servicesProfileFieldTasks.
  ///
  /// In ar, this message translates to:
  /// **'مهمة موثقة ميدانياً'**
  String get servicesProfileFieldTasks;

  /// No description provided for @servicesProfilePerformanceRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الأداء'**
  String get servicesProfilePerformanceRating;

  /// No description provided for @servicesProfileRatingDetail.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز · وفق آخر 120 مهمة'**
  String get servicesProfileRatingDetail;

  /// No description provided for @servicesProfileAssignmentTime.
  ///
  /// In ar, this message translates to:
  /// **'متوسط زمن الإسناد'**
  String get servicesProfileAssignmentTime;

  /// No description provided for @servicesProfileMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get servicesProfileMinutes;

  /// No description provided for @servicesProfileComplaintResolution.
  ///
  /// In ar, this message translates to:
  /// **'حل ومتابعة البلاغات'**
  String get servicesProfileComplaintResolution;

  /// No description provided for @servicesProfileResolutionDetail.
  ///
  /// In ar, this message translates to:
  /// **'ضمن المعدل العام'**
  String get servicesProfileResolutionDetail;

  /// No description provided for @servicesProfileDemoMetricsNotice.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الملف ومؤشرات الأداء والأرصدة المعروضة تجريبية حتى ربط الحساب بمصدر بيانات معتمد.'**
  String get servicesProfileDemoMetricsNotice;

  /// No description provided for @servicesProfileLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل بيانات الملف المحفوظة على هذا الجهاز.'**
  String get servicesProfileLoadError;

  /// No description provided for @servicesProfileWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة المستحقات والعمولات'**
  String get servicesProfileWalletTitle;

  /// No description provided for @servicesProfileWalletDescription.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستحقات وسحب الأرباح حسب النظام'**
  String get servicesProfileWalletDescription;

  /// No description provided for @servicesProfileAvailableBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح للسحب'**
  String get servicesProfileAvailableBalance;

  /// No description provided for @servicesProfilePendingDues.
  ///
  /// In ar, this message translates to:
  /// **'قيد التسوية والمراجعة'**
  String get servicesProfilePendingDues;

  /// No description provided for @servicesProfileCurrency.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get servicesProfileCurrency;

  /// No description provided for @servicesProfileOpenWallet.
  ///
  /// In ar, this message translates to:
  /// **'فتح المحفظة وسحب الرصيد'**
  String get servicesProfileOpenWallet;

  /// No description provided for @servicesProfileWalletDetails.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك مراجعة الرصيد المتاح والمستحقات قيد التسوية من صفحة المحفظة.'**
  String get servicesProfileWalletDetails;

  /// No description provided for @servicesAccountEditProfile.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب والتنبيهات'**
  String get servicesAccountEditProfile;

  /// No description provided for @servicesAccountName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get servicesAccountName;

  /// No description provided for @servicesAccountPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get servicesAccountPhone;

  /// No description provided for @servicesAccountCoverage.
  ///
  /// In ar, this message translates to:
  /// **'نطاق التغطية'**
  String get servicesAccountCoverage;

  /// No description provided for @servicesAccountSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get servicesAccountSave;

  /// No description provided for @servicesAccountSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات على هذا الجهاز'**
  String get servicesAccountSaved;

  /// No description provided for @servicesAccountSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ التغييرات: {error}'**
  String servicesAccountSaveError(Object error);

  /// No description provided for @servicesAccountLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل بيانات الحساب المحلية.'**
  String get servicesAccountLoadError;

  /// No description provided for @servicesAccountRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get servicesAccountRetry;

  /// No description provided for @servicesAccountNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال الاسم.'**
  String get servicesAccountNameRequired;

  /// No description provided for @servicesAccountLocalOnly.
  ///
  /// In ar, this message translates to:
  /// **'هذه البيانات محفوظة على هذا الجهاز فقط ولا تُحدّث الحساب على الخادم.'**
  String get servicesAccountLocalOnly;

  /// No description provided for @servicesAccountNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفضيلات التنبيهات'**
  String get servicesAccountNotificationsTitle;

  /// No description provided for @servicesAccountAssignmentAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات إسناد الخدمات'**
  String get servicesAccountAssignmentAlerts;

  /// No description provided for @servicesAccountComplaintAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تحديثات الشكاوى'**
  String get servicesAccountComplaintAlerts;

  /// No description provided for @servicesAccountSystemAlerts.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات الإدارية'**
  String get servicesAccountSystemAlerts;

  /// No description provided for @servicesAccountPreferencesLocalOnly.
  ///
  /// In ar, this message translates to:
  /// **'التفضيلات محفوظة محليًا؛ لم يتم ربطها بخدمة إشعارات.'**
  String get servicesAccountPreferencesLocalOnly;

  /// No description provided for @servicesAccountWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة والعمليات المالية'**
  String get servicesAccountWalletTitle;

  /// No description provided for @servicesAccountWalletUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة غير متصلة'**
  String get servicesAccountWalletUnavailable;

  /// No description provided for @servicesAccountWalletUnavailableDetails.
  ///
  /// In ar, this message translates to:
  /// **'يلزم ربط خدمة مالية معتمدة لعرض الرصيد أو إرسال طلبات السحب. لا تُجرى معاملات من هذه النسخة.'**
  String get servicesAccountWalletUnavailableDetails;

  /// No description provided for @servicesAccountActivityTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل نشاط الحساب'**
  String get servicesAccountActivityTitle;

  /// No description provided for @servicesAccountNoActivity.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أنشطة محفوظة حتى الآن.'**
  String get servicesAccountNoActivity;

  /// No description provided for @servicesAccountActivityLocalOnly.
  ///
  /// In ar, this message translates to:
  /// **'السجل محلي على هذا الجهاز، وليس سجل تدقيق مركزيًا.'**
  String get servicesAccountActivityLocalOnly;

  /// No description provided for @servicesAccountActivityProfileUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديل بيانات الملف'**
  String get servicesAccountActivityProfileUpdated;

  /// No description provided for @servicesAccountActivityPreferencesUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديل تفضيلات التنبيهات'**
  String get servicesAccountActivityPreferencesUpdated;

  /// No description provided for @servicesAccountActivityOther.
  ///
  /// In ar, this message translates to:
  /// **'نشاط الحساب'**
  String get servicesAccountActivityOther;

  /// No description provided for @servicesAccountLogoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get servicesAccountLogoutTitle;

  /// No description provided for @servicesAccountLogoutMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج من حساب مشرف الخدمات؟'**
  String get servicesAccountLogoutMessage;

  /// No description provided for @servicesWalletBack.
  ///
  /// In ar, this message translates to:
  /// **'العودة'**
  String get servicesWalletBack;

  /// No description provided for @servicesWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظتي والعمليات المالية'**
  String get servicesWalletTitle;

  /// No description provided for @servicesWalletSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص المحفظة'**
  String get servicesWalletSummaryTitle;

  /// No description provided for @servicesWalletLiveUpdate.
  ///
  /// In ar, this message translates to:
  /// **'بيانات تجريبية'**
  String get servicesWalletLiveUpdate;

  /// No description provided for @servicesWalletTotalBalance.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الرصيد'**
  String get servicesWalletTotalBalance;

  /// No description provided for @servicesWalletAvailable.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح'**
  String get servicesWalletAvailable;

  /// No description provided for @servicesWalletReadyForTransfer.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للتحويل'**
  String get servicesWalletReadyForTransfer;

  /// No description provided for @servicesWalletPending.
  ///
  /// In ar, this message translates to:
  /// **'مستحقات معلقة'**
  String get servicesWalletPending;

  /// No description provided for @servicesWalletExpectedThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'متوقعة هذا الأسبوع'**
  String get servicesWalletExpectedThisWeek;

  /// No description provided for @servicesWalletMonthlyCommissions.
  ///
  /// In ar, this message translates to:
  /// **'عمولات الشهر الحالي'**
  String get servicesWalletMonthlyCommissions;

  /// No description provided for @servicesWalletWithdrawalTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب رصيد'**
  String get servicesWalletWithdrawalTitle;

  /// No description provided for @servicesWalletAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المراد سحبه'**
  String get servicesWalletAmountLabel;

  /// No description provided for @servicesWalletMaxAmount.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى'**
  String get servicesWalletMaxAmount;

  /// No description provided for @servicesWalletMethodTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة التحويل'**
  String get servicesWalletMethodTitle;

  /// No description provided for @servicesWalletInstapay.
  ///
  /// In ar, this message translates to:
  /// **'تحويل عبر إنستاباي'**
  String get servicesWalletInstapay;

  /// No description provided for @servicesWalletInstapayDetails.
  ///
  /// In ar, this message translates to:
  /// **'تحويل فوري إلى الحساب'**
  String get servicesWalletInstapayDetails;

  /// No description provided for @servicesWalletInstapayId.
  ///
  /// In ar, this message translates to:
  /// **'معرّف إنستاباي'**
  String get servicesWalletInstapayId;

  /// No description provided for @servicesWalletMobileWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة هاتفية'**
  String get servicesWalletMobileWallet;

  /// No description provided for @servicesWalletMobileWalletDetails.
  ///
  /// In ar, this message translates to:
  /// **'تحويل إلى رقم الهاتف'**
  String get servicesWalletMobileWalletDetails;

  /// No description provided for @servicesWalletMobileNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get servicesWalletMobileNumber;

  /// No description provided for @servicesWalletBank.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get servicesWalletBank;

  /// No description provided for @servicesWalletBankDetails.
  ///
  /// In ar, this message translates to:
  /// **'إيداع إلى الحساب البنكي'**
  String get servicesWalletBankDetails;

  /// No description provided for @servicesWalletBankAccount.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحساب البنكي'**
  String get servicesWalletBankAccount;

  /// No description provided for @servicesWalletReviewNote.
  ///
  /// In ar, this message translates to:
  /// **'يتم تسجيل الطلبات لمراجعة المشرف المالي. لن يتم التحويل أو الإيداع قبل الموافقة وتكامل خدمة الدفع.'**
  String get servicesWalletReviewNote;

  /// No description provided for @servicesWalletSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب السحب'**
  String get servicesWalletSubmit;

  /// No description provided for @financeWalletWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'سحب'**
  String get financeWalletWithdrawal;

  /// No description provided for @financeWalletDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع'**
  String get financeWalletDeposit;

  /// No description provided for @financeWalletDepositTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب إيداع في المحفظة'**
  String get financeWalletDepositTitle;

  /// No description provided for @financeWalletSubmitDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب إيداع'**
  String get financeWalletSubmitDeposit;

  /// No description provided for @financeWalletWithdrawalNote.
  ///
  /// In ar, this message translates to:
  /// **'سيظل الطلب قيد المراجعة ولن يتم تحويل أي أموال حتى موافقة المشرف المالي.'**
  String get financeWalletWithdrawalNote;

  /// No description provided for @financeWalletDepositNote.
  ///
  /// In ar, this message translates to:
  /// **'لن تتم إضافة المبلغ إلى رصيدك حتى موافقة المشرف المالي.'**
  String get financeWalletDepositNote;

  /// No description provided for @financeWalletConfirmWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد طلب السحب'**
  String get financeWalletConfirmWithdrawal;

  /// No description provided for @financeWalletConfirmDeposit.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد طلب الإيداع'**
  String get financeWalletConfirmDeposit;

  /// No description provided for @financeWalletConfirmWithdrawalMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إرسال طلب سحب بقيمة {amount} {currency} إلى المشرف المالي؟'**
  String financeWalletConfirmWithdrawalMessage(Object amount, Object currency);

  /// No description provided for @financeWalletConfirmDepositMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إرسال طلب إيداع بقيمة {amount} {currency} إلى المشرف المالي؟'**
  String financeWalletConfirmDepositMessage(Object amount, Object currency);

  /// No description provided for @financeWalletInvalidDepositAmount.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغًا صحيحًا أكبر من صفر.'**
  String get financeWalletInvalidDepositAmount;

  /// No description provided for @financeWalletWithdrawalRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب السحب إلى المشرف المالي، والطلب قيد المراجعة.'**
  String get financeWalletWithdrawalRequestSent;

  /// No description provided for @financeWalletDepositRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الإيداع إلى المشرف المالي، والطلب قيد المراجعة.'**
  String get financeWalletDepositRequestSent;

  /// No description provided for @financeWalletRequestFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال الطلب المالي. حاول مرة أخرى.'**
  String get financeWalletRequestFailed;

  /// No description provided for @financeWalletHistoryLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل طلباتك المالية. اضغط لإعادة المحاولة.'**
  String get financeWalletHistoryLoadError;

  /// No description provided for @financeWalletNoRequests.
  ///
  /// In ar, this message translates to:
  /// **'لم ترسل أي طلبات مالية حتى الآن.'**
  String get financeWalletNoRequests;

  /// No description provided for @financeWalletPendingNotification.
  ///
  /// In ar, this message translates to:
  /// **'لديك {count} طلبات مالية جديدة من المشرفين بانتظار المراجعة.'**
  String financeWalletPendingNotification(Object count);

  /// No description provided for @financeOperationType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العملية'**
  String get financeOperationType;

  /// No description provided for @financeSourceAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب صاحب الطلب'**
  String get financeSourceAccount;

  /// No description provided for @financeRequestApprovalTitle.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد الطلب المالي'**
  String get financeRequestApprovalTitle;

  /// No description provided for @financeRequestRejectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب المالي'**
  String get financeRequestRejectionTitle;

  /// No description provided for @financeRequestApprovalConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد اعتماد طلب {operation} الخاص بـ {name} بقيمة {amount}؟'**
  String financeRequestApprovalConfirmation(
      Object operation, Object name, Object amount);

  /// No description provided for @financeRequestApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد الطلب. يتطلب تنفيذ التحويل أو إضافة الرصيد تكامل خدمة الدفع.'**
  String get financeRequestApproved;

  /// No description provided for @financeRequestApprovedBadge.
  ///
  /// In ar, this message translates to:
  /// **'معتمد'**
  String get financeRequestApprovedBadge;

  /// No description provided for @financeRequestRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب المالي.'**
  String get financeRequestRejected;

  /// No description provided for @financeRequestRejectedBadge.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get financeRequestRejectedBadge;

  /// No description provided for @financeRequestFrozen.
  ///
  /// In ar, this message translates to:
  /// **'تم تجميد الطلب المالي للتحقيق.'**
  String get financeRequestFrozen;

  /// No description provided for @financeRequestDecisionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ القرار، ولم يتم تغيير الطلب.'**
  String get financeRequestDecisionFailed;

  /// No description provided for @servicesWalletHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات المالية'**
  String get servicesWalletHistoryTitle;

  /// No description provided for @servicesWalletFullStatement.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get servicesWalletFullStatement;

  /// No description provided for @servicesWalletStatementNotice.
  ///
  /// In ar, this message translates to:
  /// **'سجل الطلبات محفوظ على هذا الجهاز فقط وغير متزامن مع خادم أو خدمة مالية.'**
  String get servicesWalletStatementNotice;

  /// No description provided for @servicesWalletHistoryInstapay.
  ///
  /// In ar, this message translates to:
  /// **'تحويل إنستاباي'**
  String get servicesWalletHistoryInstapay;

  /// No description provided for @servicesWalletHistoryOneDate.
  ///
  /// In ar, this message translates to:
  /// **'اليوم · 10:30 ص'**
  String get servicesWalletHistoryOneDate;

  /// No description provided for @servicesWalletStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get servicesWalletStatusCompleted;

  /// No description provided for @servicesWalletHistoryBank.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get servicesWalletHistoryBank;

  /// No description provided for @servicesWalletHistoryTwoDate.
  ///
  /// In ar, this message translates to:
  /// **'أمس · 02:15 م'**
  String get servicesWalletHistoryTwoDate;

  /// No description provided for @servicesWalletHistoryReview.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب'**
  String get servicesWalletHistoryReview;

  /// No description provided for @servicesWalletHistoryThreeDate.
  ///
  /// In ar, this message translates to:
  /// **'18 مايو 2025 · 11:20 ص'**
  String get servicesWalletHistoryThreeDate;

  /// No description provided for @servicesWalletHistoryNewRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب جديد'**
  String get servicesWalletHistoryNewRequest;

  /// No description provided for @servicesWalletHistoryJustNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get servicesWalletHistoryJustNow;

  /// No description provided for @servicesWalletStatusReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get servicesWalletStatusReview;

  /// No description provided for @servicesWalletComplianceTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنويه رقابي'**
  String get servicesWalletComplianceTitle;

  /// No description provided for @servicesWalletComplianceBody.
  ///
  /// In ar, this message translates to:
  /// **'الأرصدة المعروضة تجريبية. تُحفظ الطلبات محليًا لموافقة المشرف المالي؛ ولا يحدث تحويل أو إيداع فعلي أو إشعار فوري أو إرسال إلى خادم.'**
  String get servicesWalletComplianceBody;

  /// No description provided for @servicesWalletAmountError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغًا أكبر من صفر ولا يتجاوز الرصيد المتاح.'**
  String get servicesWalletAmountError;

  /// No description provided for @servicesWalletDestinationError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بيانات الوجهة قبل إرسال الطلب.'**
  String get servicesWalletDestinationError;

  /// No description provided for @servicesWalletConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد طلب السحب'**
  String get servicesWalletConfirmTitle;

  /// No description provided for @servicesWalletConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إضافة طلب سحب بقيمة {amount} {currency} إلى السجل التجريبي؟'**
  String servicesWalletConfirmMessage(Object amount, Object currency);

  /// No description provided for @servicesWalletRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف الطلب إلى السجل التجريبي فقط، ولم يُرسل إلى جهة مالية.'**
  String get servicesWalletRequestSent;

  /// No description provided for @servicesProfileAdministrationTitle.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الإدارية والاعتمادات'**
  String get servicesProfileAdministrationTitle;

  /// No description provided for @servicesProfileDelegationTitle.
  ///
  /// In ar, this message translates to:
  /// **'التفويض المهني واعتماد الإشراف'**
  String get servicesProfileDelegationTitle;

  /// No description provided for @servicesProfileDelegationDetail.
  ///
  /// In ar, this message translates to:
  /// **'ساري المفعول حتى 1447/06/30 هـ'**
  String get servicesProfileDelegationDetail;

  /// No description provided for @servicesProfileActive.
  ///
  /// In ar, this message translates to:
  /// **'مفعل'**
  String get servicesProfileActive;

  /// No description provided for @servicesProfileNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات البلاغات الفورية'**
  String get servicesProfileNotificationsTitle;

  /// No description provided for @servicesProfileNotificationsDetail.
  ///
  /// In ar, this message translates to:
  /// **'إشعار فوري للمهام ذات الأولوية العالية'**
  String get servicesProfileNotificationsDetail;

  /// No description provided for @servicesProfileEnabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعل'**
  String get servicesProfileEnabled;

  /// No description provided for @servicesProfileAuditTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل نشاطات المشرف والتدقيق'**
  String get servicesProfileAuditTitle;

  /// No description provided for @servicesProfileAuditDetail.
  ///
  /// In ar, this message translates to:
  /// **'سجل الإجراءات ومراجعات التشغيل الميدانية'**
  String get servicesProfileAuditDetail;

  /// No description provided for @servicesProfileLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من الجلسة الإشرافية'**
  String get servicesProfileLogout;

  /// No description provided for @servicesProfileFooter.
  ///
  /// In ar, this message translates to:
  /// **'بوابة إدارة الخدمات الميدانية · الإصدار 2.4.1'**
  String get servicesProfileFooter;

  /// No description provided for @servicesReviewTab.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get servicesReviewTab;

  /// No description provided for @servicesProvidersTab.
  ///
  /// In ar, this message translates to:
  /// **'مقدمو الخدمة'**
  String get servicesProvidersTab;

  /// No description provided for @servicesComplaintsTab.
  ///
  /// In ar, this message translates to:
  /// **'الشكاوى'**
  String get servicesComplaintsTab;

  /// No description provided for @servicesReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الخدمات قيد المراجعة'**
  String get servicesReviewTitle;

  /// No description provided for @servicesReviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فحص الطلبات والتحقق من الأعمال الفنية وإسناد التشغيل'**
  String get servicesReviewSubtitle;

  /// No description provided for @servicesNewRequestsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} جديدة'**
  String servicesNewRequestsCount(Object count);

  /// No description provided for @servicesCompletedToday.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المعتمدة'**
  String get servicesCompletedToday;

  /// No description provided for @servicesAwaitingDecision.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار القرار'**
  String get servicesAwaitingDecision;

  /// No description provided for @servicesFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get servicesFilterAll;

  /// No description provided for @servicesFilterMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة وأجهزة'**
  String get servicesFilterMaintenance;

  /// No description provided for @servicesFilterElectrical.
  ///
  /// In ar, this message translates to:
  /// **'كهرباء وتمديدات'**
  String get servicesFilterElectrical;

  /// No description provided for @servicesFilterMoving.
  ///
  /// In ar, this message translates to:
  /// **'نقل وترتيب'**
  String get servicesFilterMoving;

  /// No description provided for @servicesRequestsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات مطابقة لهذا التصنيف.'**
  String get servicesRequestsEmpty;

  /// No description provided for @servicesUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get servicesUnderReview;

  /// No description provided for @servicesUrgent.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get servicesUrgent;

  /// No description provided for @servicesVerifiedProvider.
  ///
  /// In ar, this message translates to:
  /// **'فني موثق'**
  String get servicesVerifiedProvider;

  /// No description provided for @servicesWorkDescription.
  ///
  /// In ar, this message translates to:
  /// **'بيان الأعمال المطلوبة:'**
  String get servicesWorkDescription;

  /// No description provided for @servicesCurrency.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get servicesCurrency;

  /// No description provided for @servicesUrgentNotice.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه تأخير ميداني: يرجى مراجعة الموعد والتواصل مع مزود الخدمة.'**
  String get servicesUrgentNotice;

  /// No description provided for @servicesApproveAction.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب'**
  String get servicesApproveAction;

  /// No description provided for @servicesRejectAction.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get servicesRejectAction;

  /// No description provided for @servicesViewDetails.
  ///
  /// In ar, this message translates to:
  /// **'معاينة تفاصيل الطلب الفنية'**
  String get servicesViewDetails;

  /// No description provided for @servicesApproveTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من قبول الطلب؟'**
  String get servicesApproveTitle;

  /// No description provided for @servicesRejectTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض طلب الخدمة'**
  String get servicesRejectTitle;

  /// No description provided for @servicesApproveMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم قبول الطلب وإزالته من قائمة المراجعة الحالية.'**
  String get servicesApproveMessage;

  /// No description provided for @servicesRejectMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم رفض الطلب وإزالته من قائمة المراجعة الحالية.'**
  String get servicesRejectMessage;

  /// No description provided for @servicesRequestApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة الطلب في قائمة المراجعة.'**
  String get servicesRequestApproved;

  /// No description provided for @servicesRequestRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب.'**
  String get servicesRequestRejected;

  /// No description provided for @servicesRequestRejectedWithReason.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب. السبب: {reason}'**
  String servicesRequestRejectedWithReason(String reason);

  /// No description provided for @servicesFeaturedRequest.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مميز'**
  String get servicesFeaturedRequest;

  /// No description provided for @servicesCommentAction.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get servicesCommentAction;

  /// No description provided for @servicesCommentTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تعليق على الطلب'**
  String get servicesCommentTitle;

  /// No description provided for @servicesCommentHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليقك أو ملاحظاتك على الطلب...'**
  String get servicesCommentHint;

  /// No description provided for @servicesCommentSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعليق'**
  String get servicesCommentSave;

  /// No description provided for @servicesCommentSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التعليق على الطلب.'**
  String get servicesCommentSaved;

  /// No description provided for @servicesDecisionProvider.
  ///
  /// In ar, this message translates to:
  /// **'مقدم الخدمة'**
  String get servicesDecisionProvider;

  /// No description provided for @servicesDecisionDiagnosticFee.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة المقدرة'**
  String get servicesDecisionDiagnosticFee;

  /// No description provided for @servicesApprovalNotification.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إشعار العميل ومقدم الخدمة بقبول الطلب وإتاحته للتنفيذ.'**
  String get servicesApprovalNotification;

  /// No description provided for @servicesApproveConfirmPublish.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد النشر والقبول'**
  String get servicesApproveConfirmPublish;

  /// No description provided for @servicesRejectionQuickReasons.
  ///
  /// In ar, this message translates to:
  /// **'نماذج أسباب سريعة'**
  String get servicesRejectionQuickReasons;

  /// No description provided for @servicesRejectionReasonScope.
  ///
  /// In ar, this message translates to:
  /// **'خارج النطاق الجغرافي'**
  String get servicesRejectionReasonScope;

  /// No description provided for @servicesRejectionReasonDetails.
  ///
  /// In ar, this message translates to:
  /// **'بيانات العمل غير مكتملة'**
  String get servicesRejectionReasonDetails;

  /// No description provided for @servicesRejectionReasonTerms.
  ///
  /// In ar, this message translates to:
  /// **'مخالفة شروط الخدمة'**
  String get servicesRejectionReasonTerms;

  /// No description provided for @servicesRejectionReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض الإلزامي'**
  String get servicesRejectionReasonLabel;

  /// No description provided for @servicesRejectionReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب الرفض بالتفصيل...'**
  String get servicesRejectionReasonHint;

  /// No description provided for @servicesRejectionAuditNote.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تسجيل سبب الرفض وإشعار العميل به مع توثيق الإجراء في سجل الطلب.'**
  String get servicesRejectionAuditNote;

  /// No description provided for @servicesRejectConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد رفض الطلب'**
  String get servicesRejectConfirm;

  /// No description provided for @servicesProvidersComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تجهيز صفحة إدارة واعتماد مقدمي الخدمة في المرحلة التالية.'**
  String get servicesProvidersComingSoon;

  /// No description provided for @servicesProvidersPortalBadge.
  ///
  /// In ar, this message translates to:
  /// **'بوابة الإسناد والفرز الميداني'**
  String get servicesProvidersPortalBadge;

  /// No description provided for @servicesProvidersTitle.
  ///
  /// In ar, this message translates to:
  /// **'مقدمو الخدمات المتاحين'**
  String get servicesProvidersTitle;

  /// No description provided for @servicesProvidersSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قاعدة بيانات مزودي الخدمة المعتمدين والموثوقين والمهيئين للمطابقة والإسناد المباشر'**
  String get servicesProvidersSubtitle;

  /// No description provided for @servicesCertifiedProviders.
  ///
  /// In ar, this message translates to:
  /// **'مزود معتمد'**
  String get servicesCertifiedProviders;

  /// No description provided for @servicesAvailableNow.
  ///
  /// In ar, this message translates to:
  /// **'متاح الآن'**
  String get servicesAvailableNow;

  /// No description provided for @servicesCommitmentRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الالتزام'**
  String get servicesCommitmentRate;

  /// No description provided for @servicesProvidersSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم، السجل التجاري، التخصص أو الحي...'**
  String get servicesProvidersSearchHint;

  /// No description provided for @servicesProvidersClearSearch.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get servicesProvidersClearSearch;

  /// No description provided for @servicesProvidersFilterPlumbing.
  ///
  /// In ar, this message translates to:
  /// **'سباكة'**
  String get servicesProvidersFilterPlumbing;

  /// No description provided for @servicesProvidersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مقدمو خدمة يطابقون البحث أو التصنيف المحدد.'**
  String get servicesProvidersEmpty;

  /// No description provided for @servicesProvidersAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متاح فوراً'**
  String get servicesProvidersAvailable;

  /// No description provided for @servicesProvidersBusy.
  ///
  /// In ar, this message translates to:
  /// **'في مهمة حالياً'**
  String get servicesProvidersBusy;

  /// No description provided for @servicesProvidersCommercialRegister.
  ///
  /// In ar, this message translates to:
  /// **'سجل تجاري موثق'**
  String get servicesProvidersCommercialRegister;

  /// No description provided for @servicesProvidersLicense.
  ///
  /// In ar, this message translates to:
  /// **'ترخيص مهني معتمد'**
  String get servicesProvidersLicense;

  /// No description provided for @servicesProvidersServiceTerms.
  ///
  /// In ar, this message translates to:
  /// **'استجابة خلال 15 دقيقة'**
  String get servicesProvidersServiceTerms;

  /// No description provided for @servicesProvidersExecutionWindow.
  ///
  /// In ar, this message translates to:
  /// **'متاح بعد ساعتين (03:30 م تقريباً)'**
  String get servicesProvidersExecutionWindow;

  /// No description provided for @servicesProvidersTasksCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مهمة منجزة'**
  String servicesProvidersTasksCount(Object count);

  /// No description provided for @servicesProvidersCommitment.
  ///
  /// In ar, this message translates to:
  /// **'التزام {rate}'**
  String servicesProvidersCommitment(Object rate);

  /// No description provided for @servicesProvidersViewProfile.
  ///
  /// In ar, this message translates to:
  /// **'عرض ملف مقدم الخدمة وسجله'**
  String get servicesProvidersViewProfile;

  /// No description provided for @servicesProvidersGovernanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'حوكمة بيانات وسجلات المزودين'**
  String get servicesProvidersGovernanceTitle;

  /// No description provided for @servicesProvidersGovernanceMessage.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية المشرف الميداني تقتصر على الفرز والمطابقة وإسناد الطلبات. تعديل السجلات الثابتة أو اعتماد مزودين جدد يتطلب تفويضاً إلكترونياً لإدارة شؤون المزودين والتراخيص المركزية.'**
  String get servicesProvidersGovernanceMessage;

  /// No description provided for @servicesProvidersSpecialty.
  ///
  /// In ar, this message translates to:
  /// **'التخصص الفني'**
  String get servicesProvidersSpecialty;

  /// No description provided for @servicesProvidersRegisteredSkills.
  ///
  /// In ar, this message translates to:
  /// **'المهارات المسجلة'**
  String get servicesProvidersRegisteredSkills;

  /// No description provided for @servicesProvidersCoverage.
  ///
  /// In ar, this message translates to:
  /// **'نطاق التغطية'**
  String get servicesProvidersCoverage;

  /// No description provided for @servicesProvidersRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييم العملاء'**
  String get servicesProvidersRating;

  /// No description provided for @servicesProvidersCompletedTasks.
  ///
  /// In ar, this message translates to:
  /// **'المهام المكتملة'**
  String get servicesProvidersCompletedTasks;

  /// No description provided for @servicesProvidersSampleProfileNotice.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الملف والسجل المعروض تجريبية وتحتاج ربطها ببيانات مزودي الخدمة.'**
  String get servicesProvidersSampleProfileNotice;

  /// No description provided for @servicesProviderProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف والسجل المهني للمزود'**
  String get servicesProviderProfileTitle;

  /// No description provided for @servicesProviderProfileRegistryNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم المزود'**
  String get servicesProviderProfileRegistryNumber;

  /// No description provided for @servicesProviderProfileVerified.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المزود واعتماداته موثقة'**
  String get servicesProviderProfileVerified;

  /// No description provided for @servicesProviderProfileFeatured.
  ///
  /// In ar, this message translates to:
  /// **'مزود مميز'**
  String get servicesProviderProfileFeatured;

  /// No description provided for @servicesProviderProfileNeedsReview.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج إلى مراجعة'**
  String get servicesProviderProfileNeedsReview;

  /// No description provided for @servicesProviderProfileCall.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get servicesProviderProfileCall;

  /// No description provided for @servicesProviderProfileChat.
  ///
  /// In ar, this message translates to:
  /// **'محادثة'**
  String get servicesProviderProfileChat;

  /// No description provided for @servicesProviderProfileCallUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر بدء الاتصال من هذا الجهاز.'**
  String get servicesProviderProfileCallUnavailable;

  /// No description provided for @servicesProviderProfileCertifications.
  ///
  /// In ar, this message translates to:
  /// **'التراخيص والاعتمادات'**
  String get servicesProviderProfileCertifications;

  /// No description provided for @servicesProviderProfileSpecialties.
  ///
  /// In ar, this message translates to:
  /// **'التخصصات وفرق العمل'**
  String get servicesProviderProfileSpecialties;

  /// No description provided for @servicesProviderProfileFieldTeam.
  ///
  /// In ar, this message translates to:
  /// **'فريق العمل الميداني'**
  String get servicesProviderProfileFieldTeam;

  /// No description provided for @servicesProviderProfileApprovedTeam.
  ///
  /// In ar, this message translates to:
  /// **'فريق معتمد ومتاح للإسناد'**
  String get servicesProviderProfileApprovedTeam;

  /// No description provided for @servicesProviderProfileRecentTasks.
  ///
  /// In ar, this message translates to:
  /// **'أحدث المهام والعمليات المنجزة'**
  String get servicesProviderProfileRecentTasks;

  /// No description provided for @servicesProviderProfileTaskDetail.
  ///
  /// In ar, this message translates to:
  /// **'تم تنفيذ الخدمة ومراجعتها من العميل.'**
  String get servicesProviderProfileTaskDetail;

  /// No description provided for @servicesProviderProfileTaskCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get servicesProviderProfileTaskCompleted;

  /// No description provided for @servicesProviderProfileTaskRecord.
  ///
  /// In ar, this message translates to:
  /// **'عرض السجل'**
  String get servicesProviderProfileTaskRecord;

  /// No description provided for @servicesProviderProfileCompletedTasksDetail.
  ///
  /// In ar, this message translates to:
  /// **'مهمة موثقة'**
  String get servicesProviderProfileCompletedTasksDetail;

  /// No description provided for @servicesProviderProfileRatingDetail.
  ///
  /// In ar, this message translates to:
  /// **'تقييم العملاء'**
  String get servicesProviderProfileRatingDetail;

  /// No description provided for @servicesProviderProfileCommitmentDetail.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الالتزام بالمواعيد'**
  String get servicesProviderProfileCommitmentDetail;

  /// No description provided for @servicesProviderProfileResponseTime.
  ///
  /// In ar, this message translates to:
  /// **'سرعة الاستجابة'**
  String get servicesProviderProfileResponseTime;

  /// No description provided for @servicesProviderProfileMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get servicesProviderProfileMinutes;

  /// No description provided for @servicesChatsTitle.
  ///
  /// In ar, this message translates to:
  /// **'محادثات الخدمات'**
  String get servicesChatsTitle;

  /// No description provided for @servicesComplaintsTitle.
  ///
  /// In ar, this message translates to:
  /// **'شكاوى وبلاغات الخدمات'**
  String get servicesComplaintsTitle;

  /// No description provided for @servicesComplaintsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'معالجة النزاعات الميدانية وضمان جودة التنفيذ وإجراءات الضمان'**
  String get servicesComplaintsSubtitle;

  /// No description provided for @servicesComplaintActive.
  ///
  /// In ar, this message translates to:
  /// **'الشكاوى النشطة'**
  String get servicesComplaintActive;

  /// No description provided for @servicesComplaintUrgent.
  ///
  /// In ar, this message translates to:
  /// **'عاجلة'**
  String get servicesComplaintUrgent;

  /// No description provided for @servicesComplaintPriorityMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسطة الأولوية'**
  String get servicesComplaintPriorityMedium;

  /// No description provided for @servicesComplaintResolutionTime.
  ///
  /// In ar, this message translates to:
  /// **'معدل الحل'**
  String get servicesComplaintResolutionTime;

  /// No description provided for @servicesComplaintMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get servicesComplaintMinutes;

  /// No description provided for @servicesComplaintSatisfaction.
  ///
  /// In ar, this message translates to:
  /// **'رضا العملاء'**
  String get servicesComplaintSatisfaction;

  /// No description provided for @servicesComplaintApproved.
  ///
  /// In ar, this message translates to:
  /// **'رضا معتمد'**
  String get servicesComplaintApproved;

  /// No description provided for @servicesComplaintSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث برقم الشكوى أو اسم العميل أو المزود...'**
  String get servicesComplaintSearchHint;

  /// No description provided for @servicesComplaintFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get servicesComplaintFilterAll;

  /// No description provided for @servicesComplaintFilterInvestigating.
  ///
  /// In ar, this message translates to:
  /// **'قيد الفحص'**
  String get servicesComplaintFilterInvestigating;

  /// No description provided for @servicesComplaintFilterWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الرد'**
  String get servicesComplaintFilterWaiting;

  /// No description provided for @servicesComplaintFilterClosed.
  ///
  /// In ar, this message translates to:
  /// **'تم الحل'**
  String get servicesComplaintFilterClosed;

  /// No description provided for @servicesComplaintNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد شكاوى تطابق البحث أو المرشح.'**
  String get servicesComplaintNoResults;

  /// No description provided for @servicesComplaintAgeMinutes.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String servicesComplaintAgeMinutes(int count);

  /// No description provided for @servicesComplaintAgeHours.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} ساعتين'**
  String servicesComplaintAgeHours(int count);

  /// No description provided for @servicesComplaintClient.
  ///
  /// In ar, this message translates to:
  /// **'العميل الشاكي'**
  String get servicesComplaintClient;

  /// No description provided for @servicesComplaintProvider.
  ///
  /// In ar, this message translates to:
  /// **'المزود المشكو ضده'**
  String get servicesComplaintProvider;

  /// No description provided for @servicesComplaintClientOne.
  ///
  /// In ar, this message translates to:
  /// **'د. مها الدبيسي'**
  String get servicesComplaintClientOne;

  /// No description provided for @servicesComplaintClientTwo.
  ///
  /// In ar, this message translates to:
  /// **'سارة العتيبي'**
  String get servicesComplaintClientTwo;

  /// No description provided for @servicesComplaintClientThree.
  ///
  /// In ar, this message translates to:
  /// **'العميل فهد'**
  String get servicesComplaintClientThree;

  /// No description provided for @servicesComplaintProviderOne.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة التبريد المتقن'**
  String get servicesComplaintProviderOne;

  /// No description provided for @servicesComplaintProviderTwo.
  ///
  /// In ar, this message translates to:
  /// **'فريق الإتقان الشامل'**
  String get servicesComplaintProviderTwo;

  /// No description provided for @servicesComplaintProviderThree.
  ///
  /// In ar, this message translates to:
  /// **'فهد الأرجحي'**
  String get servicesComplaintProviderThree;

  /// No description provided for @servicesComplaintProviderId.
  ///
  /// In ar, this message translates to:
  /// **'طلب مرتبط: {id}'**
  String servicesComplaintProviderId(String id);

  /// No description provided for @servicesComplaintRiyadh.
  ///
  /// In ar, this message translates to:
  /// **'الرياض'**
  String get servicesComplaintRiyadh;

  /// No description provided for @servicesComplaintSubjectOne.
  ///
  /// In ar, this message translates to:
  /// **'صيانة مكيفات سبليت وتبريد'**
  String get servicesComplaintSubjectOne;

  /// No description provided for @servicesComplaintDescriptionOne.
  ///
  /// In ar, this message translates to:
  /// **'تسرب مياه مستمر من الوحدة الداخلية بعد الصيانة. تمت مراجعة البلاغ وتحديد موعد للفحص الميداني للتأكد من جودة تنفيذ الضمان.'**
  String get servicesComplaintDescriptionOne;

  /// No description provided for @servicesComplaintSubjectTwo.
  ///
  /// In ar, this message translates to:
  /// **'تجديدات كهربائية وإعدادات ذكية'**
  String get servicesComplaintSubjectTwo;

  /// No description provided for @servicesComplaintDescriptionTwo.
  ///
  /// In ar, this message translates to:
  /// **'تجاوز الموعد المحدد للزيارة الميدانية ساعة كاملة دون تقديم اعتذار أو إشعار مسبق بتأخر الفني.'**
  String get servicesComplaintDescriptionTwo;

  /// No description provided for @servicesComplaintSubjectThree.
  ///
  /// In ar, this message translates to:
  /// **'نقل وتركيب أثاث غرفة نوم'**
  String get servicesComplaintSubjectThree;

  /// No description provided for @servicesComplaintDescriptionThree.
  ///
  /// In ar, this message translates to:
  /// **'تمت معالجة الطلب واعتماده بعد تأكيد العميل استلام الخدمة.'**
  String get servicesComplaintDescriptionThree;

  /// No description provided for @servicesComplaintLocationOne.
  ///
  /// In ar, this message translates to:
  /// **'حي النرجس، الرياض'**
  String get servicesComplaintLocationOne;

  /// No description provided for @servicesComplaintLocationTwo.
  ///
  /// In ar, this message translates to:
  /// **'حي الملقا، الرياض'**
  String get servicesComplaintLocationTwo;

  /// No description provided for @servicesComplaintLocationThree.
  ///
  /// In ar, this message translates to:
  /// **'حي الياسمين، الرياض'**
  String get servicesComplaintLocationThree;

  /// No description provided for @servicesComplaintPriceOne.
  ///
  /// In ar, this message translates to:
  /// **'280'**
  String get servicesComplaintPriceOne;

  /// No description provided for @servicesComplaintPriceTwo.
  ///
  /// In ar, this message translates to:
  /// **'450'**
  String get servicesComplaintPriceTwo;

  /// No description provided for @servicesComplaintPriceThree.
  ///
  /// In ar, this message translates to:
  /// **'1,200'**
  String get servicesComplaintPriceThree;

  /// No description provided for @servicesComplaintClosedToday.
  ///
  /// In ar, this message translates to:
  /// **'أغلقت اليوم 11:30 ص'**
  String get servicesComplaintClosedToday;

  /// No description provided for @servicesComplaintUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد فحص المشرف'**
  String get servicesComplaintUnderReview;

  /// No description provided for @servicesComplaintWaitingProvider.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار إفادة المزود'**
  String get servicesComplaintWaitingProvider;

  /// No description provided for @servicesComplaintClosed.
  ///
  /// In ar, this message translates to:
  /// **'تم الحل والإغلاق'**
  String get servicesComplaintClosed;

  /// No description provided for @servicesComplaintInvestigateAndResolve.
  ///
  /// In ar, this message translates to:
  /// **'معاينة وبدء التحقيق والحل'**
  String get servicesComplaintInvestigateAndResolve;

  /// No description provided for @servicesComplaintContactParties.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الطرفين'**
  String get servicesComplaintContactParties;

  /// No description provided for @servicesComplaintGroupChatTitle.
  ///
  /// In ar, this message translates to:
  /// **'محادثة الشكوى {id}'**
  String servicesComplaintGroupChatTitle(String id);

  /// No description provided for @servicesComplaintReassign.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إسناد فوري'**
  String get servicesComplaintReassign;

  /// No description provided for @servicesComplaintEscalate.
  ///
  /// In ar, this message translates to:
  /// **'تصعيد لرئيس المشرفين'**
  String get servicesComplaintEscalate;

  /// No description provided for @servicesComplaintShowResolution.
  ///
  /// In ar, this message translates to:
  /// **'عرض محضر الصلح'**
  String get servicesComplaintShowResolution;

  /// No description provided for @servicesComplaintResolutionRecorded.
  ///
  /// In ar, this message translates to:
  /// **'الإجراء الإشرافي المعتمد: تم حل المشكلة ميدانياً مع تعويض العميل عن التأخير.'**
  String get servicesComplaintResolutionRecorded;

  /// No description provided for @servicesComplaintClosedAudit.
  ///
  /// In ar, this message translates to:
  /// **'سجل تدقيق مغلق غير قابل للتعديل'**
  String get servicesComplaintClosedAudit;

  /// No description provided for @servicesComplaintResolutionTitle.
  ///
  /// In ar, this message translates to:
  /// **'جودة حل النزاعات الميدانية'**
  String get servicesComplaintResolutionTitle;

  /// No description provided for @servicesComplaintResolutionDescription.
  ///
  /// In ar, this message translates to:
  /// **'يمتلك مشرف الخدمات صلاحية التصالح وجدولة زيارات التنفيذ وإجراءات الضمان، مع إمكانية إعادة الإسناد لمزود بديل.'**
  String get servicesComplaintResolutionDescription;

  /// No description provided for @servicesComplaintDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الشكوى'**
  String get servicesComplaintDetails;

  /// No description provided for @servicesComplaintActionConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تسجيل الإجراء في سجل الشكوى وإشعار الأطراف المرتبطة. هل تريد المتابعة؟'**
  String get servicesComplaintActionConfirmation;

  /// No description provided for @servicesComplaintEscalationConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إحالة الشكوى إلى رئيس المشرفين للمراجعة. هل تريد التصعيد؟'**
  String get servicesComplaintEscalationConfirmation;

  /// No description provided for @servicesComplaintEscalated.
  ///
  /// In ar, this message translates to:
  /// **'تم التصعيد'**
  String get servicesComplaintEscalated;

  /// No description provided for @servicesComplaintEscalatedNotice.
  ///
  /// In ar, this message translates to:
  /// **'تم تصعيد الشكوى {id} إلى رئيس المشرفين.'**
  String servicesComplaintEscalatedNotice(String id);

  /// No description provided for @servicesComplaintContactNotice.
  ///
  /// In ar, this message translates to:
  /// **'تم فتح خيارات التواصل مع العميل ومزود الخدمة.'**
  String get servicesComplaintContactNotice;

  /// No description provided for @servicesComplaintActionRecorded.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الإجراء وإشعار الأطراف.'**
  String get servicesComplaintActionRecorded;

  /// No description provided for @servicesNoNewNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات جديدة.'**
  String get servicesNoNewNotifications;

  /// No description provided for @servicesNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get servicesNotificationsTitle;

  /// No description provided for @servicesDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'معاينة وتفاصيل الطلب'**
  String get servicesDetailsTitle;

  /// No description provided for @servicesRequestWorkDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الخدمة وموقع التنفيذ'**
  String get servicesRequestWorkDetailsTitle;

  /// No description provided for @servicesRequestLocationLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الخدمة'**
  String get servicesRequestLocationLabel;

  /// No description provided for @servicesRequestPhotosTitle.
  ///
  /// In ar, this message translates to:
  /// **'صور الخدمة المرفقة'**
  String get servicesRequestPhotosTitle;

  /// No description provided for @servicesRequestNoPhotos.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صور مرفقة مع هذا الطلب.'**
  String get servicesRequestNoPhotos;

  /// No description provided for @servicesRequestAssignmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'إسناد الخدمة لمقدم خدمة'**
  String get servicesRequestAssignmentTitle;

  /// No description provided for @servicesRequestAssignmentDescription.
  ///
  /// In ar, this message translates to:
  /// **'اختر مقدم خدمة متاحاً ومطابقاً لتصنيف الخدمة من قائمة مقدمي الخدمات.'**
  String get servicesRequestAssignmentDescription;

  /// No description provided for @servicesRequestChooseProvider.
  ///
  /// In ar, this message translates to:
  /// **'اختر مقدم الخدمة'**
  String get servicesRequestChooseProvider;

  /// No description provided for @servicesRequestNoMatchingProviders.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مقدمو خدمة متاحون لهذا التصنيف حالياً.'**
  String get servicesRequestNoMatchingProviders;

  /// No description provided for @servicesRequestAssignProvider.
  ///
  /// In ar, this message translates to:
  /// **'إسناد الخدمة'**
  String get servicesRequestAssignProvider;

  /// No description provided for @servicesRequestAssigned.
  ///
  /// In ar, this message translates to:
  /// **'تم إسناد الخدمة إلى {provider}'**
  String servicesRequestAssigned(String provider);

  /// No description provided for @servicesComplaintPartiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'طرفا النزاع والتواصل'**
  String get servicesComplaintPartiesTitle;

  /// No description provided for @servicesComplaintProblemTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيان المشكلة المسجلة'**
  String get servicesComplaintProblemTitle;

  /// No description provided for @servicesComplaintFiledBy.
  ///
  /// In ar, this message translates to:
  /// **'الطرف الشاكي'**
  String get servicesComplaintFiledBy;

  /// No description provided for @servicesComplaintServiceInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الخدمة محل الشكوى'**
  String get servicesComplaintServiceInfoTitle;

  /// No description provided for @servicesComplaintPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الخدمة'**
  String get servicesComplaintPriceLabel;

  /// No description provided for @servicesComplaintPhotosTitle.
  ///
  /// In ar, this message translates to:
  /// **'صور المشكلة المرفقة'**
  String get servicesComplaintPhotosTitle;

  /// No description provided for @servicesComplaintNoPhotos.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صور مرفقة للمشكلة.'**
  String get servicesComplaintNoPhotos;

  /// No description provided for @servicesBackToRequests.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الطلبات'**
  String get servicesBackToRequests;

  /// No description provided for @servicesCallPhone.
  ///
  /// In ar, this message translates to:
  /// **'اتصال هاتف'**
  String get servicesCallPhone;

  /// No description provided for @servicesContactWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'محادثة واتساب'**
  String get servicesContactWhatsApp;

  /// No description provided for @servicesEstimatedCost.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة التقديرية للخدمة'**
  String get servicesEstimatedCost;

  /// No description provided for @servicesApprovedEstimate.
  ///
  /// In ar, this message translates to:
  /// **'تقدير آلي معتمد'**
  String get servicesApprovedEstimate;

  /// No description provided for @servicesEstimatedCostTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التكلفة المقدرة'**
  String get servicesEstimatedCostTotal;

  /// No description provided for @servicesInspectionFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الكشف المبدئي'**
  String get servicesInspectionFee;

  /// No description provided for @servicesLaborAndPartsFee.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة العمل وقطع الغيار'**
  String get servicesLaborAndPartsFee;

  /// No description provided for @servicesRequestMoreInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب معلومات وتوضيحات إضافية من العميل'**
  String get servicesRequestMoreInfoTitle;

  /// No description provided for @servicesRequestMoreInfoDescription.
  ///
  /// In ar, this message translates to:
  /// **'في حال عدم وضوح بيانات الطلب أو الحاجة لمعلومات إضافية لإتمام الفحص قبل التعيين، أرسل استفساراً مباشراً للعميل.'**
  String get servicesRequestMoreInfoDescription;

  /// No description provided for @servicesRequestMoreInfoHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب استفسارك أو التفاصيل المطلوبة من العميل هنا...'**
  String get servicesRequestMoreInfoHint;

  /// No description provided for @servicesRequireExtraPhotos.
  ///
  /// In ar, this message translates to:
  /// **'إلزام بإرفاق صور توضيحية إضافية'**
  String get servicesRequireExtraPhotos;

  /// No description provided for @servicesSendInfoRequest.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get servicesSendInfoRequest;

  /// No description provided for @servicesInfoRequestRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تفاصيل الاستفسار قبل الإرسال.'**
  String get servicesInfoRequestRequired;

  /// No description provided for @servicesInfoRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب المعلومات للعميل.'**
  String get servicesInfoRequestSent;

  /// No description provided for @servicesEditClassification.
  ///
  /// In ar, this message translates to:
  /// **'تعديل التصنيف الفني للخدمة'**
  String get servicesEditClassification;

  /// No description provided for @servicesCurrentClassification.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف الفني المعتمد حالياً'**
  String get servicesCurrentClassification;

  /// No description provided for @servicesApprovedClassification.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف المعتمد للطلب'**
  String get servicesApprovedClassification;

  /// No description provided for @servicesExecutionPeriod.
  ///
  /// In ar, this message translates to:
  /// **'فترة التنفيذ المناسبة'**
  String get servicesExecutionPeriod;

  /// No description provided for @servicesDayPeriod.
  ///
  /// In ar, this message translates to:
  /// **'صباحية (09:00 ص - 01:00 م)'**
  String get servicesDayPeriod;

  /// No description provided for @servicesEveningPeriod.
  ///
  /// In ar, this message translates to:
  /// **'مسائية (04:00 م - 09:00 م)'**
  String get servicesEveningPeriod;

  /// No description provided for @servicesSaveClassification.
  ///
  /// In ar, this message translates to:
  /// **'تحديث وحفظ التصنيف'**
  String get servicesSaveClassification;

  /// No description provided for @servicesClassificationSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ تصنيف الخدمة وفترة التنفيذ.'**
  String get servicesClassificationSaved;

  /// No description provided for @servicesContactUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر بدء التواصل من هذا الجهاز.'**
  String get servicesContactUnavailable;

  /// No description provided for @servicesPublishConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد نشر الطلب'**
  String get servicesPublishConfirm;

  /// No description provided for @deliveryLogisticsWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة مناديب التوصيل واللوجستيات'**
  String get deliveryLogisticsWalletTitle;

  /// No description provided for @deliveryLogisticsWalletDesc.
  ///
  /// In ar, this message translates to:
  /// **'أجور ومستحقات الشحن والتسليم الميداني'**
  String get deliveryLogisticsWalletDesc;

  /// No description provided for @instantLiquidityAdequacyRatio.
  ///
  /// In ar, this message translates to:
  /// **'مؤشر كفاية السيولة المصرفية الفورية'**
  String get instantLiquidityAdequacyRatio;

  /// No description provided for @verySafeAndStable.
  ///
  /// In ar, this message translates to:
  /// **'آمن ومستقر جداً'**
  String get verySafeAndStable;

  /// No description provided for @dailyWithdrawalCoverageRatio.
  ///
  /// In ar, this message translates to:
  /// **'نسبة تغطية طلبات السحب اليومية'**
  String get dailyWithdrawalCoverageRatio;

  /// No description provided for @excessCashCoverage.
  ///
  /// In ar, this message translates to:
  /// **'تغطية نقدية فائضة'**
  String get excessCashCoverage;

  /// No description provided for @statutoryMinimumRequirement.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى النظامي المشترط: 85.0%'**
  String get statutoryMinimumRequirement;

  /// No description provided for @autoBankingSettlement.
  ///
  /// In ar, this message translates to:
  /// **'التسوية المصرفية التلقائية عبر نظام سداد & SARIE: مكتملة ومطابقة 100%'**
  String get autoBankingSettlement;

  /// No description provided for @governancePolicyNotice.
  ///
  /// In ar, this message translates to:
  /// **'وفق لائحة الحوكمة والسياسات المالية: المشرفون الميدانيون ورؤساء الأقسام لا يملكون أي صلاحية لتعديل الأرصدة أو السحب أو التحويل البنكي. تنفيذ وتوثيق العمليات المالية حصري للمدير المالي المعتمد برقم تفويض مصرفي رسمي.'**
  String get governancePolicyNotice;

  /// No description provided for @governancePolicyClause.
  ///
  /// In ar, this message translates to:
  /// **'بند #04 - أ'**
  String get governancePolicyClause;

  /// No description provided for @urgentWithdrawalsAction.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة طلبات السحب العاجلة (14 طلباً جاهزاً للصرف)'**
  String get urgentWithdrawalsAction;

  /// No description provided for @exportDailyReportPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير تقرير السيولة والمركز المالي اليومي (PDF)'**
  String get exportDailyReportPdf;

  /// No description provided for @liquidityDistributedOnChannels.
  ///
  /// In ar, this message translates to:
  /// **'السيولة الموزعة على القنوات المصرفية'**
  String get liquidityDistributedOnChannels;

  /// No description provided for @liveBankingReconciliation.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة بنكية حية (SARI/SARIE نشط 100%)'**
  String get liveBankingReconciliation;

  /// No description provided for @instantSync.
  ///
  /// In ar, this message translates to:
  /// **'تزامن فوري'**
  String get instantSync;

  /// No description provided for @mainBanksCount.
  ///
  /// In ar, this message translates to:
  /// **'3 بنوك رئيسية'**
  String get mainBanksCount;

  /// No description provided for @instaPayCount.
  ///
  /// In ar, this message translates to:
  /// **'2 إنستاباي InstaPay'**
  String get instaPayCount;

  /// No description provided for @digitalWalletsCount.
  ///
  /// In ar, this message translates to:
  /// **'2 محافظ رقمية'**
  String get digitalWalletsCount;

  /// No description provided for @officialBankAccountsAndIban.
  ///
  /// In ar, this message translates to:
  /// **'الحسابات البنكية الرسمية وحسابات الآيبان'**
  String get officialBankAccountsAndIban;

  /// No description provided for @bankAccountsScreenSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة السيولة والمطابقة مع الشبكة السعودية للمدفوعات'**
  String get bankAccountsScreenSubtitle;

  /// No description provided for @refreshBalances.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الأرصدة'**
  String get refreshBalances;

  /// No description provided for @noAccountsInCategory.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حسابات مسجلة ضمن هذا التصنيف'**
  String get noAccountsInCategory;

  /// No description provided for @operationalAccountsFilter.
  ///
  /// In ar, this message translates to:
  /// **'حسابات تشغيلية'**
  String get operationalAccountsFilter;

  /// No description provided for @escrowAccountsFilter.
  ///
  /// In ar, this message translates to:
  /// **'حسابات ضمان Escrow'**
  String get escrowAccountsFilter;

  /// No description provided for @paymentGatewaysFilter.
  ///
  /// In ar, this message translates to:
  /// **'بوابات الدفع الإلكتروني'**
  String get paymentGatewaysFilter;

  /// No description provided for @digitalWalletsFilter.
  ///
  /// In ar, this message translates to:
  /// **'المحافظ الرقمية'**
  String get digitalWalletsFilter;

  /// No description provided for @instantBankSyncNote.
  ///
  /// In ar, this message translates to:
  /// **'تحديث ومطابقة تلقائية متزامنة مع كافة القنوات'**
  String get instantBankSyncNote;

  /// No description provided for @createBankAccount.
  ///
  /// In ar, this message translates to:
  /// **'إضافة حساب جديد'**
  String get createBankAccount;

  /// No description provided for @exportAccountStatementButton.
  ///
  /// In ar, this message translates to:
  /// **'تصدير كشف PDF'**
  String get exportAccountStatementButton;

  /// No description provided for @openDailyLedger.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحركات المصرفية والعمليات اليومية'**
  String get openDailyLedger;

  /// No description provided for @dailyLedgerDescription.
  ///
  /// In ar, this message translates to:
  /// **'عرض قيود اليومية، الإيداعات، والحوالات الصادرة والواردة'**
  String get dailyLedgerDescription;

  /// No description provided for @escrowAccountBadge.
  ///
  /// In ar, this message translates to:
  /// **'حساب ضمان'**
  String get escrowAccountBadge;

  /// No description provided for @availableLedgerBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الدفتري المتاح:'**
  String get availableLedgerBalanceLabel;

  /// No description provided for @ibanOrIdentifierLabel.
  ///
  /// In ar, this message translates to:
  /// **'الآيبان / المعرّف:'**
  String get ibanOrIdentifierLabel;

  /// No description provided for @connectedReconciledViaSarie.
  ///
  /// In ar, this message translates to:
  /// **'متصل ومطابق لحظياً عبر SARIE'**
  String get connectedReconciledViaSarie;

  /// No description provided for @linkBankAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'ربط حساب مصرفي جديد'**
  String get linkBankAccountTitle;

  /// No description provided for @enterBankDetailsToApprove.
  ///
  /// In ar, this message translates to:
  /// **'أدخل تفاصيل الحساب المصرفي للاعتماد'**
  String get enterBankDetailsToApprove;

  /// No description provided for @bankNameField.
  ///
  /// In ar, this message translates to:
  /// **'اسم البنك'**
  String get bankNameField;

  /// No description provided for @accountTypeField.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحساب / التصنيف'**
  String get accountTypeField;

  /// No description provided for @ibanField.
  ///
  /// In ar, this message translates to:
  /// **'رقم الآيبان (IBAN)'**
  String get ibanField;

  /// No description provided for @editBankAccountAction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الحساب'**
  String get editBankAccountAction;

  /// No description provided for @bankEditNotice.
  ///
  /// In ar, this message translates to:
  /// **'لن تتغير بيانات الحساب المعتمدة الآن. سيُرسل طلب التعديل للأدمن للموافقة أو الرفض.'**
  String get bankEditNotice;

  /// No description provided for @bankEditSubmitAction.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وإرسال للأدمن'**
  String get bankEditSubmitAction;

  /// No description provided for @bankEditPendingStatus.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل بانتظار قرار الأدمن'**
  String get bankEditPendingStatus;

  /// No description provided for @bankEditPendingDetails.
  ///
  /// In ar, this message translates to:
  /// **'البيانات المقترحة'**
  String get bankEditPendingDetails;

  /// No description provided for @bankEditRequestNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get bankEditRequestNumber;

  /// No description provided for @bankEditSubmitting.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ إرسال الطلب...'**
  String get bankEditSubmitting;

  /// No description provided for @bankEditRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب التعديل للأدمن. ستظل بيانات الحساب الحالية معتمدة حتى صدور القرار.'**
  String get bankEditRequestSent;

  /// No description provided for @bankEditRequestFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال طلب التعديل. حاول مرة أخرى.'**
  String get bankEditRequestFailed;

  /// No description provided for @bankEditRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get bankEditRequired;

  /// No description provided for @bankEditNoChanges.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تغيير أي بيانات'**
  String get bankEditNoChanges;

  /// No description provided for @bankLinkRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الربط'**
  String get bankLinkRequestSent;

  /// No description provided for @saveAccount.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الحساب'**
  String get saveAccount;

  /// No description provided for @exportAccountsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصدير كشف الحسابات'**
  String get exportAccountsTitle;

  /// No description provided for @pdfReportExplanation.
  ///
  /// In ar, this message translates to:
  /// **'سيتم توليد تقرير رسمي مفصل بصيغة PDF بجميع الأرصدة المصرفية المتطابقة.'**
  String get pdfReportExplanation;

  /// No description provided for @download.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get download;

  /// No description provided for @cancelAction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelAction;

  /// No description provided for @accountsExportSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير كشف الحسابات بنجاح'**
  String get accountsExportSuccess;

  /// No description provided for @accountsCount.
  ///
  /// In ar, this message translates to:
  /// **'3 حسابات'**
  String get accountsCount;

  /// No description provided for @collectionAndDistribution.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل وتوزيع'**
  String get collectionAndDistribution;

  /// No description provided for @sadadAndSarie.
  ///
  /// In ar, this message translates to:
  /// **'سداد & SARIE'**
  String get sadadAndSarie;

  /// No description provided for @frozenEscrowAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب مجمد للأمانات'**
  String get frozenEscrowAccount;

  /// No description provided for @emergencyAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب الطوارئ والتسويات البنكية الفورية'**
  String get emergencyAccount;

  /// No description provided for @approvedT0.
  ///
  /// In ar, this message translates to:
  /// **'معتمد T+0'**
  String get approvedT0;

  /// No description provided for @dailyLedgerBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الدفتري الحالي'**
  String get dailyLedgerBalance;

  /// No description provided for @ibanNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الآيبان (IBAN)'**
  String get ibanNumber;

  /// No description provided for @internalAccountNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحساب الداخلي'**
  String get internalAccountNumber;

  /// No description provided for @dailyLogLedger.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحركات اليومية'**
  String get dailyLogLedger;

  /// No description provided for @reviewHeldEscrow.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة المحتجزات'**
  String get reviewHeldEscrow;

  /// No description provided for @reconciliationDisputesNote.
  ///
  /// In ar, this message translates to:
  /// **'خاضع للمطابقة المالية الآلية مع بوابة النزاعات'**
  String get reconciliationDisputesNote;

  /// No description provided for @approvedEWallets.
  ///
  /// In ar, this message translates to:
  /// **'المحافظ الإلكترونية المعتمدة (E-Wallets)'**
  String get approvedEWallets;

  /// No description provided for @walletsCount.
  ///
  /// In ar, this message translates to:
  /// **'محفظتان'**
  String get walletsCount;

  /// No description provided for @stcPayEnterprise.
  ///
  /// In ar, this message translates to:
  /// **'محفظة stc pay للأعمال (Enterprise)'**
  String get stcPayEnterprise;

  /// No description provided for @apiConnected.
  ///
  /// In ar, this message translates to:
  /// **'مربوطة API'**
  String get apiConnected;

  /// No description provided for @actualWalletBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الفعلي في المحفظة'**
  String get actualWalletBalance;

  /// No description provided for @withdrawalFeesFree.
  ///
  /// In ar, this message translates to:
  /// **'رسوم السحب: مجاناً (اتفاقية شركات)'**
  String get withdrawalFeesFree;

  /// No description provided for @urpayBusiness.
  ///
  /// In ar, this message translates to:
  /// **'محفظة urpay (يورباي للأعمال)'**
  String get urpayBusiness;

  /// No description provided for @activeStatus.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get activeStatus;

  /// No description provided for @salarySupportDisbursement.
  ///
  /// In ar, this message translates to:
  /// **'صرف رواتب مساندة'**
  String get salarySupportDisbursement;

  /// No description provided for @feedWalletBalance.
  ///
  /// In ar, this message translates to:
  /// **'تغذية رصيد المحفظة'**
  String get feedWalletBalance;

  /// No description provided for @bankingGovernanceAuthNote.
  ///
  /// In ar, this message translates to:
  /// **'تعديل أو سحب أو إلغاء ربط أي قناة مصرفية يخضع لمعايير الأمن المالي المشدد، ويتطلب مصادقة ثنائية عبر منصة نفاذ (2FA) ومصادقة التوقيع الإلكتروني المشفر (SHA-256) للمدير المالي التنفيذي.'**
  String get bankingGovernanceAuthNote;

  /// No description provided for @addNewBankAccount.
  ///
  /// In ar, this message translates to:
  /// **'إضافة حساب بنكي أو قناة دفع جديدة'**
  String get addNewBankAccount;

  /// No description provided for @exportAccountsStatementPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير بيان الحسابات (PDF)'**
  String get exportAccountsStatementPdf;

  /// No description provided for @exportDetailedStatementExcel.
  ///
  /// In ar, this message translates to:
  /// **'بيان تفصيلي (Excel)'**
  String get exportDetailedStatementExcel;

  /// No description provided for @bankingAndCashSurveillanceGateway.
  ///
  /// In ar, this message translates to:
  /// **'بوابة الصرف والرقابة النقدية'**
  String get bankingAndCashSurveillanceGateway;

  /// No description provided for @merchantWithdrawalsHeaderTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات سحب مستحقات التجار و المستخدمين و المناديب'**
  String get merchantWithdrawalsHeaderTitle;

  /// No description provided for @merchantWithdrawalsHeaderSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة طلبات السحب النقدي المعتمدة للمتاجر والمزودين'**
  String get merchantWithdrawalsHeaderSubtitle;

  /// No description provided for @pendingRequests.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المعلقة'**
  String get pendingRequests;

  /// No description provided for @underRegulatoryHold.
  ///
  /// In ar, this message translates to:
  /// **'تحت الاحتراز'**
  String get underRegulatoryHold;

  /// No description provided for @regulatoryFreeze.
  ///
  /// In ar, this message translates to:
  /// **'تجميد رقابي'**
  String get regulatoryFreeze;

  /// No description provided for @allTab.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allTab;

  /// No description provided for @merchantsTab.
  ///
  /// In ar, this message translates to:
  /// **'التجار'**
  String get merchantsTab;

  /// No description provided for @usersTab.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمين'**
  String get usersTab;

  /// No description provided for @verifiedViaNafath.
  ///
  /// In ar, this message translates to:
  /// **'معتمد ومطابق عبر النفاذ الموحد'**
  String get verifiedViaNafath;

  /// No description provided for @underReviewStatus.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get underReviewStatus;

  /// No description provided for @grossAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبلغ المطلوب (Gross):'**
  String get grossAmount;

  /// No description provided for @platformFee.
  ///
  /// In ar, this message translates to:
  /// **'عمولة المنصة والخدمات'**
  String get platformFee;

  /// No description provided for @netTransferredAmount.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبلغ المحول للحساب البنكي:'**
  String get netTransferredAmount;

  /// No description provided for @receivingBank.
  ///
  /// In ar, this message translates to:
  /// **'المصرف المستلم:'**
  String get receivingBank;

  /// No description provided for @submissionDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ تقديم الطلب:'**
  String get submissionDate;

  /// No description provided for @automatedTaxAuditResult.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة الفحص الآلي للمطابقة الضريبية والمحفظة'**
  String get automatedTaxAuditResult;

  /// No description provided for @automatedTaxAuditDetails.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة الفواتير: 100% | لا توجد بلاغات نزاع أو شكاوى نشطة | رصيد المحفظة مغطى بالكامل ومطابق لصافي التحصيلات التشغيلية.'**
  String get automatedTaxAuditDetails;

  /// No description provided for @approveAndSendToAdmin.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد و ارسال الطلب للادارة'**
  String get approveAndSendToAdmin;

  /// No description provided for @freezeRequestTemporarily.
  ///
  /// In ar, this message translates to:
  /// **'تجميد مؤقت للطلب'**
  String get freezeRequestTemporarily;

  /// No description provided for @readyForInstantDisbursement.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للصرف'**
  String get readyForInstantDisbursement;

  /// No description provided for @readyForInstantBankingTransfer.
  ///
  /// In ar, this message translates to:
  /// **'معتمد من النظام - جاهز للإرسال البنكي عبر شبكة سريع'**
  String get readyForInstantBankingTransfer;

  /// No description provided for @approveAndIssueBankOrder.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد و اعطاء أمر الصرف البنكي'**
  String get approveAndIssueBankOrder;

  /// No description provided for @temporarilySuspendedForAudit.
  ///
  /// In ar, this message translates to:
  /// **'موقوف مؤقتاً للتحقيق الرقابي'**
  String get temporarilySuspendedForAudit;

  /// No description provided for @grossHeldAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبلغ المطلوب تحت الحظر (Gross):'**
  String get grossHeldAmount;

  /// No description provided for @estimatedPlatformFee.
  ///
  /// In ar, this message translates to:
  /// **'عمولة المنصة التقديرية'**
  String get estimatedPlatformFee;

  /// No description provided for @netFrozenAmount.
  ///
  /// In ar, this message translates to:
  /// **'الصافي المحتجز للتجميد:'**
  String get netFrozenAmount;

  /// No description provided for @auditReferenceCode.
  ///
  /// In ar, this message translates to:
  /// **'المرجع الرقابي'**
  String get auditReferenceCode;

  /// No description provided for @regulatoryNoticeFromSupervisor.
  ///
  /// In ar, this message translates to:
  /// **'مذكرة إشعار رقابي من مشرف التجار'**
  String get regulatoryNoticeFromSupervisor;

  /// No description provided for @rejectAndNotifyCustomer.
  ///
  /// In ar, this message translates to:
  /// **'الرفض و اشعار العميل'**
  String get rejectAndNotifyCustomer;

  /// No description provided for @freezeRequest.
  ///
  /// In ar, this message translates to:
  /// **'تجميد الطلب'**
  String get freezeRequest;

  /// No description provided for @totalAwaitingApproval.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبالغ بانتظار الاعتماد'**
  String get totalAwaitingApproval;

  /// No description provided for @remainingForReview.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي للمراجعة'**
  String get remainingForReview;

  /// No description provided for @supervisorWithdrawalsHeaderTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات سحب مستحقات المشرفين ومقدمي الخدمة'**
  String get supervisorWithdrawalsHeaderTitle;

  /// No description provided for @supervisorWithdrawalsHeaderSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة طلبات سحب الأتعاب وعمولات الإشراف وأجور الصيانة المعتمدة للصرف'**
  String get supervisorWithdrawalsHeaderSubtitle;

  /// No description provided for @awaitingApprovalTab.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الاعتماد'**
  String get awaitingApprovalTab;

  /// No description provided for @platformSupervisorsTab.
  ///
  /// In ar, this message translates to:
  /// **'مشرفو المنصة'**
  String get platformSupervisorsTab;

  /// No description provided for @awaitingDisbursementBadge.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الصرف'**
  String get awaitingDisbursementBadge;

  /// No description provided for @totalFeesAndCommissions.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي أتعاب وعمولات الإشراف:'**
  String get totalFeesAndCommissions;

  /// No description provided for @netAmountDueForDisbursement.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبلغ المستحق للصرف:'**
  String get netAmountDueForDisbursement;

  /// No description provided for @disbursementSource.
  ///
  /// In ar, this message translates to:
  /// **'مصدر المستحقات'**
  String get disbursementSource;

  /// No description provided for @complianceAndAuditResult.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة الفحص الآلي لمطابقة الأداء'**
  String get complianceAndAuditResult;

  /// No description provided for @verifiedIban.
  ///
  /// In ar, this message translates to:
  /// **'آيبان موثق'**
  String get verifiedIban;

  /// No description provided for @fieldCompletionDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الإنجاز الميداني'**
  String get fieldCompletionDetails;

  /// No description provided for @temporarilySuspendedBadge.
  ///
  /// In ar, this message translates to:
  /// **'موقوف مؤقتاً'**
  String get temporarilySuspendedBadge;

  /// No description provided for @grossClaimedAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبلغ المطالب به:'**
  String get grossClaimedAmount;

  /// No description provided for @deductedPlatformFee.
  ///
  /// In ar, this message translates to:
  /// **'عمولة المنصة المستقطعة'**
  String get deductedPlatformFee;

  /// No description provided for @netHeldAmount.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبلغ المحجوز احترازياً:'**
  String get netHeldAmount;

  /// No description provided for @requestStatusProtocol.
  ///
  /// In ar, this message translates to:
  /// **'حالة الطلب: محجوز بموجب بروتوكول حماية الجودة الإشرافي'**
  String get requestStatusProtocol;

  /// No description provided for @regulatoryNoticeFromServicesSupervisor.
  ///
  /// In ar, this message translates to:
  /// **'إشعار رقابي من مشرف الخدمات'**
  String get regulatoryNoticeFromServicesSupervisor;

  /// No description provided for @batchApproval.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد جماعي'**
  String get batchApproval;

  /// No description provided for @samaComplianceNotice.
  ///
  /// In ar, this message translates to:
  /// **'التحويلات تخضع لمعايير البنك المركزي السعودي (SAMA)'**
  String get samaComplianceNotice;

  /// No description provided for @subscriptionOrdersTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الاشتراكات'**
  String get subscriptionOrdersTitle;

  /// No description provided for @financialManagementSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'برواح المازوري - الإدارة المالية'**
  String get financialManagementSubtitle;

  /// No description provided for @financialAuditAndLicenses.
  ///
  /// In ar, this message translates to:
  /// **'الرقابة المالية والتراخيص'**
  String get financialAuditAndLicenses;

  /// No description provided for @subscriptionsAndUpgradesReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الاشتراكات والترقيات'**
  String get subscriptionsAndUpgradesReviewTitle;

  /// No description provided for @subscriptionsAndUpgradesReviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة وتفعيل اشتراكات المتاجر ومزودي الخدمات • برواح المازوري'**
  String get subscriptionsAndUpgradesReviewSubtitle;

  /// No description provided for @currentSubscriptionsCycleSummary.
  ///
  /// In ar, this message translates to:
  /// **'موجز دورة الاشتراكات الجارية'**
  String get currentSubscriptionsCycleSummary;

  /// No description provided for @updatedNow.
  ///
  /// In ar, this message translates to:
  /// **'محدث الآن'**
  String get updatedNow;

  /// No description provided for @pendingSubscriptionFees.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الاشتراكات المعلقة'**
  String get pendingSubscriptionFees;

  /// No description provided for @ordersUnderAudit.
  ///
  /// In ar, this message translates to:
  /// **'طلباً قيد التدقيق'**
  String get ordersUnderAudit;

  /// No description provided for @activatedThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'المفعلة هذا الشهر'**
  String get activatedThisMonth;

  /// No description provided for @revenueGrowth.
  ///
  /// In ar, this message translates to:
  /// **'+24% نمو إيرادات'**
  String get revenueGrowth;

  /// No description provided for @expiredAwaitingRenewal.
  ///
  /// In ar, this message translates to:
  /// **'منتهية بانتظار التجديد'**
  String get expiredAwaitingRenewal;

  /// No description provided for @autoCommercialAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه تجاري آلي'**
  String get autoCommercialAlert;

  /// No description provided for @couriersTab.
  ///
  /// In ar, this message translates to:
  /// **'المناديب'**
  String get couriersTab;

  /// No description provided for @advertisementsTab.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get advertisementsTab;

  /// No description provided for @corporateAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب الشركات'**
  String get corporateAccount;

  /// No description provided for @subscriptionsHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الاشتراكات والترقيات النشطة وغير النشطة'**
  String get subscriptionsHistoryTitle;

  /// No description provided for @browsePreviousOperations.
  ///
  /// In ar, this message translates to:
  /// **'تصفح تاريخ جميع العمليات السابقة'**
  String get browsePreviousOperations;

  /// No description provided for @openingSubscriptionsRegister.
  ///
  /// In ar, this message translates to:
  /// **'جاري فتح السجل...'**
  String get openingSubscriptionsRegister;

  /// No description provided for @storesAndMerchants.
  ///
  /// In ar, this message translates to:
  /// **'المتاجر والتجار'**
  String get storesAndMerchants;

  /// No description provided for @serviceProviders.
  ///
  /// In ar, this message translates to:
  /// **'مزودو الخدمات'**
  String get serviceProviders;

  /// No description provided for @awaitingCertificationRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات بانتظار المصادقة'**
  String get awaitingCertificationRequests;

  /// No description provided for @sortByNewest.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب حسب الأحدث'**
  String get sortByNewest;

  /// No description provided for @underMatching.
  ///
  /// In ar, this message translates to:
  /// **'قيد المطابقة'**
  String get underMatching;

  /// No description provided for @commercialRegister.
  ///
  /// In ar, this message translates to:
  /// **'س.ت:'**
  String get commercialRegister;

  /// No description provided for @licenseNumber.
  ///
  /// In ar, this message translates to:
  /// **'رخصة رقم:'**
  String get licenseNumber;

  /// No description provided for @premiumMerchantSubscription.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك تاجر مميز'**
  String get premiumMerchantSubscription;

  /// No description provided for @homeServicesProvider.
  ///
  /// In ar, this message translates to:
  /// **'مزود خدمات منزلية'**
  String get homeServicesProvider;

  /// No description provided for @targetedPackageType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الباقة المستهدفة'**
  String get targetedPackageType;

  /// No description provided for @annualGoldenPackage.
  ///
  /// In ar, this message translates to:
  /// **'الباقة الذهبية السنوية'**
  String get annualGoldenPackage;

  /// No description provided for @proServiceProviderPackage.
  ///
  /// In ar, this message translates to:
  /// **'مزود خدمة احترافي'**
  String get proServiceProviderPackage;

  /// No description provided for @taxInclusive15.
  ///
  /// In ar, this message translates to:
  /// **'شامل الضريبة 15%'**
  String get taxInclusive15;

  /// No description provided for @semiAnnualDuration.
  ///
  /// In ar, this message translates to:
  /// **'نصف سنوي (6 أشهر)'**
  String get semiAnnualDuration;

  /// No description provided for @sufficientWalletBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد كافي بالمحفظة'**
  String get sufficientWalletBalance;

  /// No description provided for @paymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة السداد:'**
  String get paymentMethod;

  /// No description provided for @directBankTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي مباشر (سداد / الراجحي - حساب الشركات)'**
  String get directBankTransfer;

  /// No description provided for @directDeductionFromEscrow.
  ///
  /// In ar, this message translates to:
  /// **'خصم مباشر من رصيد المحفظة الضامنة (Escrow)'**
  String get directDeductionFromEscrow;

  /// No description provided for @availableBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد متاح'**
  String get availableBalance;

  /// No description provided for @previewReceiptAndTransferData.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الإيصال وبيانات التحويل'**
  String get previewReceiptAndTransferData;

  /// No description provided for @autoApprovalReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للاعتماد التلقائي'**
  String get autoApprovalReady;

  /// No description provided for @rejectWithReason.
  ///
  /// In ar, this message translates to:
  /// **'رفض مع السبب'**
  String get rejectWithReason;

  /// No description provided for @licensesGovernanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'حوكمة اعتماد التراخيص والترقيات'**
  String get licensesGovernanceTitle;

  /// No description provided for @licensesGovernanceDesc.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الباقات يمنح فوراً الصلاحيات التجارية وأولوية الظهور والإعفاءات الرقابية المحددة في النظام المالي لشركة برواح المازوري. تخضع كافة العمليات للتدقيق المستندي والضريبي اللاحق.'**
  String get licensesGovernanceDesc;

  /// No description provided for @certifiedAndDocumentedRecord.
  ///
  /// In ar, this message translates to:
  /// **'سجل معتمد وموثق'**
  String get certifiedAndDocumentedRecord;

  /// No description provided for @pdfReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير PDF'**
  String get pdfReport;

  /// No description provided for @exportExcel.
  ///
  /// In ar, this message translates to:
  /// **'تصدير Excel'**
  String get exportExcel;

  /// No description provided for @navLiquidity.
  ///
  /// In ar, this message translates to:
  /// **'السيولة'**
  String get navLiquidity;

  /// No description provided for @navWithdrawalOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات السحب'**
  String get navWithdrawalOrders;

  /// No description provided for @navReconciliation.
  ///
  /// In ar, this message translates to:
  /// **'المطابقة'**
  String get navReconciliation;

  /// No description provided for @navSettlements.
  ///
  /// In ar, this message translates to:
  /// **'التسويات'**
  String get navSettlements;

  /// No description provided for @navCommissions.
  ///
  /// In ar, this message translates to:
  /// **'العمولات'**
  String get navCommissions;

  /// No description provided for @navAudit.
  ///
  /// In ar, this message translates to:
  /// **'التدقيق'**
  String get navAudit;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملفك الشخصي'**
  String get profileTitle;

  /// No description provided for @financialDepartment.
  ///
  /// In ar, this message translates to:
  /// **'الإدارة المالية'**
  String get financialDepartment;

  /// No description provided for @encryptedBit256.
  ///
  /// In ar, this message translates to:
  /// **'تشفير bit-256'**
  String get encryptedBit256;

  /// No description provided for @secureApprovedSession.
  ///
  /// In ar, this message translates to:
  /// **'جلسة رقابية آمنة ومصادق عليها'**
  String get secureApprovedSession;

  /// No description provided for @cfoAuditingTitle.
  ///
  /// In ar, this message translates to:
  /// **'CFO ورئيس التدقيق المالي'**
  String get cfoAuditingTitle;

  /// No description provided for @sovereignApprovalPowers.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيات الاعتماد السيادي والمصادقة البنكية'**
  String get sovereignApprovalPowers;

  /// No description provided for @certifiedAuditorAuthority.
  ///
  /// In ar, this message translates to:
  /// **'مدقق مالي معتمد • مفوض التوقيع والمصادقة البنكية المزدوجة لدى مؤسسة برواح المازوري'**
  String get certifiedAuditorAuthority;

  /// No description provided for @officialPhone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف المعتمد'**
  String get officialPhone;

  /// No description provided for @corporateEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد المؤسسي'**
  String get corporateEmail;

  /// No description provided for @enabledNafath.
  ///
  /// In ar, this message translates to:
  /// **'نفاذ وطني مفعل'**
  String get enabledNafath;

  /// No description provided for @authorizationEffectiveFrom.
  ///
  /// In ar, this message translates to:
  /// **'سريان الاعتماد الرقابي من: 2027م'**
  String get authorizationEffectiveFrom;

  /// No description provided for @activeAndReconciled.
  ///
  /// In ar, this message translates to:
  /// **'نشط ومطابق'**
  String get activeAndReconciled;

  /// No description provided for @duesWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة المستحقات والأتعاب'**
  String get duesWalletTitle;

  /// No description provided for @executiveWalletDescription.
  ///
  /// In ar, this message translates to:
  /// **'حساب الإدارة والرقابة التنفيذية المباشر'**
  String get executiveWalletDescription;

  /// No description provided for @totalAccountingDues.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي رصيد المستحقات المحاسبية'**
  String get totalAccountingDues;

  /// No description provided for @pendingRegulatoryBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد معلق رقابياً'**
  String get pendingRegulatoryBalance;

  /// No description provided for @awaitingQuarterlyClose.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الإقفال الربع سنوي'**
  String get awaitingQuarterlyClose;

  /// No description provided for @approvedWithoutConditions.
  ///
  /// In ar, this message translates to:
  /// **'معتمد دون شروط'**
  String get approvedWithoutConditions;

  /// No description provided for @approvedPayoutAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب المصفي المعتمد للصرف'**
  String get approvedPayoutAccount;

  /// No description provided for @requestOwnerProfitWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب الأرباح من المالك'**
  String get requestOwnerProfitWithdrawal;

  /// No description provided for @editWithdrawalInformation.
  ///
  /// In ar, this message translates to:
  /// **'تعديل معلومات السحب'**
  String get editWithdrawalInformation;

  /// No description provided for @cfoExclusive.
  ///
  /// In ar, this message translates to:
  /// **'مقتصرة على CFO'**
  String get cfoExclusive;

  /// No description provided for @sovereignControls.
  ///
  /// In ar, this message translates to:
  /// **'التحكم والإجراءات السيادية'**
  String get sovereignControls;

  /// No description provided for @feesAndCommissionsMatrix.
  ///
  /// In ar, this message translates to:
  /// **'مصفوفة الرسوم والعمولات العامة'**
  String get feesAndCommissionsMatrix;

  /// No description provided for @feesAndCommissionsMatrixDesc.
  ///
  /// In ar, this message translates to:
  /// **'ضبط النسب المئوية للمنصة، اقتطاعات بوابات الدفع الإلكترونية، وتعديل تسعير العمليات التعاقدية.'**
  String get feesAndCommissionsMatrixDesc;

  /// No description provided for @exclusivePermission.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية حصرية'**
  String get exclusivePermission;

  /// No description provided for @editMatrix.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المصفوفة'**
  String get editMatrix;

  /// No description provided for @fastSettlementFees.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التسوية السريعة'**
  String get fastSettlementFees;

  /// No description provided for @currentBaseCommission.
  ///
  /// In ar, this message translates to:
  /// **'العمولة الأساسية الحالية'**
  String get currentBaseCommission;

  /// No description provided for @comprehensivePaymentsReports.
  ///
  /// In ar, this message translates to:
  /// **'كشف المدفوعات والإيرادات الشامل'**
  String get comprehensivePaymentsReports;

  /// No description provided for @comprehensivePaymentsReportsDesc.
  ///
  /// In ar, this message translates to:
  /// **'توليد كشوف التدفقات النقدية، تقارير الضريبة العامة المضافة، وحزم التسويات المصرفية المجمعة.'**
  String get comprehensivePaymentsReportsDesc;

  /// No description provided for @exportDetailedExcel.
  ///
  /// In ar, this message translates to:
  /// **'تصدير Excel تفصيلي'**
  String get exportDetailedExcel;

  /// No description provided for @exportApprovedPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير PDF معتمد'**
  String get exportApprovedPdf;

  /// No description provided for @liveDocumented.
  ///
  /// In ar, this message translates to:
  /// **'مباشر • موثق'**
  String get liveDocumented;

  /// No description provided for @auditActivityLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الرقابة وحركات المدير المالي'**
  String get auditActivityLog;

  /// No description provided for @ownerDisputeSettlementApproval.
  ///
  /// In ar, this message translates to:
  /// **'مصادقة صرف تسوية نزاع مالك'**
  String get ownerDisputeSettlementApproval;

  /// No description provided for @todayAtEleven.
  ///
  /// In ar, this message translates to:
  /// **'اليوم 11:00 ص'**
  String get todayAtEleven;

  /// No description provided for @approveDisputeSettlement.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد صرف تسوية النزاع #CMP-1035 بقيمة 1,200.00 ج.م للعميل د. طارق العمري.'**
  String get approveDisputeSettlement;

  /// No description provided for @referenceCode.
  ///
  /// In ar, this message translates to:
  /// **'المرجع:'**
  String get referenceCode;

  /// No description provided for @validDigitalSignature.
  ///
  /// In ar, this message translates to:
  /// **'توقيع رقمي ساري SHA-256'**
  String get validDigitalSignature;

  /// No description provided for @aggregatedProfitWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد سحب أرباح مجمعة (SARIE)'**
  String get aggregatedProfitWithdrawal;

  /// No description provided for @todayAtNineThirty.
  ///
  /// In ar, this message translates to:
  /// **'اليوم 09:30 ص'**
  String get todayAtNineThirty;

  /// No description provided for @periodicMerchantTransfers.
  ///
  /// In ar, this message translates to:
  /// **'تحويل مستحقات دورية لـ 12 متجر معتمد عبر نظام المدفوعات الفورية بإجمالي 142,500.00 ج.م.'**
  String get periodicMerchantTransfers;

  /// No description provided for @alRajhiBank.
  ///
  /// In ar, this message translates to:
  /// **'مصرف الراجحي'**
  String get alRajhiBank;

  /// No description provided for @executedAndPosted.
  ///
  /// In ar, this message translates to:
  /// **'منفذة بنكياً ومقيدة'**
  String get executedAndPosted;

  /// No description provided for @precautionaryWalletFreeze.
  ///
  /// In ar, this message translates to:
  /// **'تجميد احترازي لمحفظة متجر'**
  String get precautionaryWalletFreeze;

  /// No description provided for @yesterdayAtFourFifteen.
  ///
  /// In ar, this message translates to:
  /// **'أمس 04:15 م'**
  String get yesterdayAtFourFifteen;

  /// No description provided for @suspendMerchantDisbursement.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف عمليات الصرف لمتجر مستلزمات حاسب (#TRD-304) لوجود شبهة نزاع مدفوعات متكرر.'**
  String get suspendMerchantDisbursement;

  /// No description provided for @auditNoticeReference.
  ///
  /// In ar, this message translates to:
  /// **'إشعار التدقيق #771'**
  String get auditNoticeReference;

  /// No description provided for @underInvestigation.
  ///
  /// In ar, this message translates to:
  /// **'قيد التحقيق والتدقيق'**
  String get underInvestigation;

  /// No description provided for @maintenanceCommissionUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تحديث عمولة قطاع الصيانة'**
  String get maintenanceCommissionUpdate;

  /// No description provided for @yesterdayAtOneTwenty.
  ///
  /// In ar, this message translates to:
  /// **'أمس 01:20 م'**
  String get yesterdayAtOneTwenty;

  /// No description provided for @commissionUpdatedByBoard.
  ///
  /// In ar, this message translates to:
  /// **'تعديل نسبة العمولة المحصلة إلى 8.0% بموجب قرار مجلس الإدارة رقم BOD-44/B.'**
  String get commissionUpdatedByBoard;

  /// No description provided for @activeSystemUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تحديث نظامي نافذ'**
  String get activeSystemUpdate;

  /// No description provided for @viewFullAuditActivity.
  ///
  /// In ar, this message translates to:
  /// **'عرض سجل الرقابة والحركات الكامل (342 حركة موثقة)'**
  String get viewFullAuditActivity;

  /// No description provided for @reconciliationEngine.
  ///
  /// In ar, this message translates to:
  /// **'KYC & IBAN VERIFICATION ENGINE'**
  String get reconciliationEngine;

  /// No description provided for @reconciliationImmediateCompliance.
  ///
  /// In ar, this message translates to:
  /// **'امتثال مصرفي فوري'**
  String get reconciliationImmediateCompliance;

  /// No description provided for @reconciliationPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة الحسابات البنكية ومكافحة الاحتيال'**
  String get reconciliationPageTitle;

  /// No description provided for @reconciliationAuthorityTitle.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية إشرافية تنفيذية مقيدة'**
  String get reconciliationAuthorityTitle;

  /// No description provided for @reconciliationAuthorityNotice.
  ///
  /// In ar, this message translates to:
  /// **'للاطلاع والتحقق والاعتماد مصرح للمدير المالي حصرياً. تعديل بيانات الحساب البنكية ممنوع بتاتاً من قبل المشرفين الميدانيين.'**
  String get reconciliationAuthorityNotice;

  /// No description provided for @reconciliationGovernmentPortal.
  ///
  /// In ar, this message translates to:
  /// **'بوابة وثائق وربط حكومي'**
  String get reconciliationGovernmentPortal;

  /// No description provided for @reconciliationGovernmentSync.
  ///
  /// In ar, this message translates to:
  /// **'تزامن حي ومباشر مع السجل التجاري والبنك المركزي'**
  String get reconciliationGovernmentSync;

  /// No description provided for @reconciliationConnected.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get reconciliationConnected;

  /// No description provided for @reconciliationAccountDetails.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المطابقة التفصيلية للحساب'**
  String get reconciliationAccountDetails;

  /// No description provided for @reconciliationCommercialName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم المعتمد في السجل التجاري'**
  String get reconciliationCommercialName;

  /// No description provided for @reconciliationCommercialEntity.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة مدار التقنية لتقنية المعلومات'**
  String get reconciliationCommercialEntity;

  /// No description provided for @reconciliationBeneficiaryName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستفيد في الحساب البنكي'**
  String get reconciliationBeneficiaryName;

  /// No description provided for @reconciliationBeneficiaryEntity.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة مدار التقنية'**
  String get reconciliationBeneficiaryEntity;

  /// No description provided for @reconciliationFinalActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات الاعتماد النهائي (حصر صلاحيات المدير المالي):'**
  String get reconciliationFinalActions;

  /// No description provided for @reconciliationApproveAccount.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد الحساب البنكي وإرساله للإدارة'**
  String get reconciliationApproveAccount;

  /// No description provided for @reconciliationApproveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد الحساب البنكي وإرساله للإدارة.'**
  String get reconciliationApproveSuccess;

  /// No description provided for @reconciliationLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل طلبات ربط الحسابات البنكية.'**
  String get reconciliationLoadFailed;

  /// No description provided for @reconciliationNoPendingRequests.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات ربط حسابات بنكية بانتظار المراجعة.'**
  String get reconciliationNoPendingRequests;

  /// No description provided for @reconciliationFreezeSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تجميد الطلب للمراجعة الرقابية.'**
  String get reconciliationFreezeSuccess;

  /// No description provided for @reconciliationFrozenRequestsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات ربط الحسابات المجمدة'**
  String get reconciliationFrozenRequestsTitle;

  /// No description provided for @reconciliationFreezeReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'سبب التجميد:'**
  String get reconciliationFreezeReasonLabel;

  /// No description provided for @reconciliationFreezeDialogDescription.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تعليق طلب ربط الحساب وتسجيله للمراجعة المالية، وإزالته من قائمة المراجعة النشطة.'**
  String get reconciliationFreezeDialogDescription;

  /// No description provided for @reconciliationActionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تنفيذ الإجراء. يرجى المحاولة مرة أخرى.'**
  String get reconciliationActionFailed;

  /// No description provided for @reconciliationRequestIban.
  ///
  /// In ar, this message translates to:
  /// **'طلب شهادة آيبان حديثة ومختومة'**
  String get reconciliationRequestIban;

  /// No description provided for @reconciliationIbanRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب شهادة آيبان حديثة ومختومة.'**
  String get reconciliationIbanRequestSent;

  /// No description provided for @reconciliationRejectTransfer.
  ///
  /// In ar, this message translates to:
  /// **'رفض وتجميد التحويل للحساب'**
  String get reconciliationRejectTransfer;

  /// No description provided for @reconciliationRejectSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب وتسجيل سبب الرفض للمراجعة.'**
  String get reconciliationRejectSuccess;

  /// No description provided for @reconciliationComplianceReview.
  ///
  /// In ar, this message translates to:
  /// **'فحص الامتثال المالي - بوابة وثائق الحكومة'**
  String get reconciliationComplianceReview;

  /// No description provided for @reconciliationBusinessName.
  ///
  /// In ar, this message translates to:
  /// **'شركة مدار التقنية للتجارة'**
  String get reconciliationBusinessName;

  /// No description provided for @reconciliationNewAccountRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب اعتماد حساب بنكي رئيسي جديد للصرف الدوري'**
  String get reconciliationNewAccountRequest;

  /// No description provided for @reconciliationAmlScore.
  ///
  /// In ar, this message translates to:
  /// **'مؤشر توافق المعايير الرقابية (AML/CFT)'**
  String get reconciliationAmlScore;

  /// No description provided for @reconciliationAmlMatched.
  ///
  /// In ar, this message translates to:
  /// **'تطابق آمن وفق بروتوكول مكافحة غسل الأموال وتمويل الإرهاب.'**
  String get reconciliationAmlMatched;

  /// No description provided for @reconciliationMatchVerified.
  ///
  /// In ar, this message translates to:
  /// **'مطابق 100%  ✓'**
  String get reconciliationMatchVerified;

  /// No description provided for @reconciliationBankName.
  ///
  /// In ar, this message translates to:
  /// **'مصرف الراجحي'**
  String get reconciliationBankName;

  /// No description provided for @reconciliationIbanLabel.
  ///
  /// In ar, this message translates to:
  /// **'3. رقم الحساب الدولي (IBAN) والجهة البنكية'**
  String get reconciliationIbanLabel;

  /// No description provided for @reconciliationRegistrationLabel.
  ///
  /// In ar, this message translates to:
  /// **'4. السجل التجاري وحالة الصلاحية'**
  String get reconciliationRegistrationLabel;

  /// No description provided for @reconciliationValidUntil.
  ///
  /// In ar, this message translates to:
  /// **'ساري المفعول حتى 1447/06/15هـ'**
  String get reconciliationValidUntil;

  /// No description provided for @reconciliationPreviewDocument.
  ///
  /// In ar, this message translates to:
  /// **'معاينة'**
  String get reconciliationPreviewDocument;

  /// No description provided for @reconciliationDocumentPreviewToast.
  ///
  /// In ar, this message translates to:
  /// **'معاينة مستند doc-iban-5501.pdf'**
  String get reconciliationDocumentPreviewToast;

  /// No description provided for @reconciliationNextAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب التالي في قائمة الانتظار'**
  String get reconciliationNextAccount;

  /// No description provided for @reconciliationQueueTitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة طلبات المطابقة'**
  String get reconciliationQueueTitle;

  /// No description provided for @reconciliationSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو رقم الطلب أو البنك أو الآيبان'**
  String get reconciliationSearchHint;

  /// No description provided for @reconciliationFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get reconciliationFilterAll;

  /// No description provided for @reconciliationFilterAttention.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج إلى مراجعة'**
  String get reconciliationFilterAttention;

  /// No description provided for @reconciliationNeedsAttention.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get reconciliationNeedsAttention;

  /// No description provided for @reconciliationNoMatchingRequests.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات مطابقة لخيارات البحث.'**
  String get reconciliationNoMatchingRequests;

  /// No description provided for @reconciliationAwaitingManagement.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار اعتماد الإدارة'**
  String get reconciliationAwaitingManagement;

  /// No description provided for @reconciliationAwaitingCertificate.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار شهادة آيبان محدثة'**
  String get reconciliationAwaitingCertificate;

  /// No description provided for @reconciliationInProgressTab.
  ///
  /// In ar, this message translates to:
  /// **'قيد الإجراء'**
  String get reconciliationInProgressTab;

  /// No description provided for @reconciliationArchiveTab.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف'**
  String get reconciliationArchiveTab;

  /// No description provided for @reconciliationArchiveEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات في الأرشيف.'**
  String get reconciliationArchiveEmpty;

  /// No description provided for @reconciliationDecisionReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب القرار'**
  String get reconciliationDecisionReason;

  /// No description provided for @reconciliationNextBusiness.
  ///
  /// In ar, this message translates to:
  /// **'متجر السهيلة للعطور'**
  String get reconciliationNextBusiness;

  /// No description provided for @reconciliationNextBank.
  ///
  /// In ar, this message translates to:
  /// **'البنك الأهلي السعودي  •  SA22 1000 **** **** 8819'**
  String get reconciliationNextBank;

  /// No description provided for @reconciliationNameMismatch.
  ///
  /// In ar, this message translates to:
  /// **'حالة المطابقة: اختلاف طفيف في اللقب التجاري (يتطلب مراجعة مستند التفويض والوكالة الشرعية قبل الصرف).'**
  String get reconciliationNameMismatch;

  /// No description provided for @reconciliationAuditAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه تدقيق'**
  String get reconciliationAuditAlert;

  /// No description provided for @reconciliationOpenAudit.
  ///
  /// In ar, this message translates to:
  /// **'فتح ملف التدقيق الكامل للحساب #TRD-6022'**
  String get reconciliationOpenAudit;

  /// No description provided for @withdrawSheetBrand.
  ///
  /// In ar, this message translates to:
  /// **'برواح المازوري للخدمات المالية'**
  String get withdrawSheetBrand;

  /// No description provided for @withdrawSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب الارباح من المالك'**
  String get withdrawSheetTitle;

  /// No description provided for @withdrawSheetAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب الإدارة والرقابة التنفيذية — أ. سليمان الراجحي'**
  String get withdrawSheetAccount;

  /// No description provided for @withdrawSheetInstantAuth.
  ///
  /// In ar, this message translates to:
  /// **'مصادقة نفاذ فوري • سحب لحظي SARIE'**
  String get withdrawSheetInstantAuth;

  /// No description provided for @withdrawSheetRequestId.
  ///
  /// In ar, this message translates to:
  /// **'طلب رقم #WD-8842'**
  String get withdrawSheetRequestId;

  /// No description provided for @withdrawSheetAvailableBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح الجاهز للصرف الفوري'**
  String get withdrawSheetAvailableBalance;

  /// No description provided for @withdrawSheetMinimumNotice.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للسحب 1,000 ج.م • بدون رسوم تحويل إدارية'**
  String get withdrawSheetMinimumNotice;

  /// No description provided for @withdrawSheetEnterAmount.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المبلغ المطلوب سحبه'**
  String get withdrawSheetEnterAmount;

  /// No description provided for @withdrawSheetSetMaximum.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الحد الأقصى'**
  String get withdrawSheetSetMaximum;

  /// No description provided for @withdrawSheetSelectBank.
  ///
  /// In ar, this message translates to:
  /// **'الحساب البنكي المستلم المعتمد'**
  String get withdrawSheetSelectBank;

  /// No description provided for @withdrawSheetIbanVerified.
  ///
  /// In ar, this message translates to:
  /// **'مدقق IBAN'**
  String get withdrawSheetIbanVerified;

  /// No description provided for @withdrawSheetBankName.
  ///
  /// In ar, this message translates to:
  /// **'مصرف الراجحي'**
  String get withdrawSheetBankName;

  /// No description provided for @withdrawSheetBankStatus.
  ///
  /// In ar, this message translates to:
  /// **'حساب موثق لدى SAMA • نشط ومطابق'**
  String get withdrawSheetBankStatus;

  /// No description provided for @withdrawSheetPrimaryAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب الرئيسي'**
  String get withdrawSheetPrimaryAccount;

  /// No description provided for @withdrawSheetSubmitSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع طلب السحب بنجاح'**
  String get withdrawSheetSubmitSuccess;

  /// No description provided for @withdrawSheetConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد ارسال طلب السحب للادارة'**
  String get withdrawSheetConfirm;

  /// No description provided for @withdrawSheetCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء والتراجع'**
  String get withdrawSheetCancel;

  /// No description provided for @withdrawSheetAllAmount.
  ///
  /// In ar, this message translates to:
  /// **'الكل (52,000 ج.م)'**
  String get withdrawSheetAllAmount;

  /// No description provided for @withdrawSheetAmount25k.
  ///
  /// In ar, this message translates to:
  /// **'25,000 ج.م'**
  String get withdrawSheetAmount25k;

  /// No description provided for @withdrawSheetAmount10k.
  ///
  /// In ar, this message translates to:
  /// **'10,000 ج.م'**
  String get withdrawSheetAmount10k;

  /// No description provided for @withdrawSheetAmount5k.
  ///
  /// In ar, this message translates to:
  /// **'5,000 ج.م'**
  String get withdrawSheetAmount5k;

  /// No description provided for @matrixLive.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات محلية'**
  String get matrixLive;

  /// No description provided for @matrixCfoPermission.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية سيادية حصرية للمدير المالي (CFO-01)'**
  String get matrixCfoPermission;

  /// No description provided for @matrixIntro.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة نسب العمولات والرسوم وحفظ التعديلات محليًا للمراجعة.'**
  String get matrixIntro;

  /// No description provided for @matrixLastUpdate.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: 01 يناير 2025 بموجب قرار مجلس الإدارة رقم BOD-44/B'**
  String get matrixLastUpdate;

  /// No description provided for @matrixSalesRateTitle.
  ///
  /// In ar, this message translates to:
  /// **'النسبة العامة للمبيعات والمتاجر'**
  String get matrixSalesRateTitle;

  /// No description provided for @matrixRateRange.
  ///
  /// In ar, this message translates to:
  /// **'النطاق: 10.0% - 2.0%'**
  String get matrixRateRange;

  /// No description provided for @matrixCurrentRate.
  ///
  /// In ar, this message translates to:
  /// **'النسبة المطبقة حالياً'**
  String get matrixCurrentRate;

  /// No description provided for @matrixSetTargetRate.
  ///
  /// In ar, this message translates to:
  /// **'ضبط النسبة المستهدفة'**
  String get matrixSetTargetRate;

  /// No description provided for @matrixMinimumRate.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى 2.0%'**
  String get matrixMinimumRate;

  /// No description provided for @matrixReferenceRate.
  ///
  /// In ar, this message translates to:
  /// **'المرجعي 5.0%'**
  String get matrixReferenceRate;

  /// No description provided for @matrixMaximumRate.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى 10.0%'**
  String get matrixMaximumRate;

  /// No description provided for @matrixSalesRateNote.
  ///
  /// In ar, this message translates to:
  /// **'تُطبق على جميع صفقات المتاجر، المنتجات الجديدة، ومبيعات الأجهزة المباشرة دون استثناءات محلية.'**
  String get matrixSalesRateNote;

  /// No description provided for @matrixSettlementFeesTitle.
  ///
  /// In ar, this message translates to:
  /// **'رسوم تسوية المحافظ والاسترداد'**
  String get matrixSettlementFeesTitle;

  /// No description provided for @matrixCurrentSettlementFee.
  ///
  /// In ar, this message translates to:
  /// **'رسم التسوية الحالية'**
  String get matrixCurrentSettlementFee;

  /// No description provided for @matrixFixedInstantFee.
  ///
  /// In ar, this message translates to:
  /// **'رسم ثابت إضافي (تسوية فورية)'**
  String get matrixFixedInstantFee;

  /// No description provided for @matrixCostCoverage.
  ///
  /// In ar, this message translates to:
  /// **'تفصيل التغطية التكلفة:'**
  String get matrixCostCoverage;

  /// No description provided for @matrixDeliveryFleet.
  ///
  /// In ar, this message translates to:
  /// **'أسطول وصلني & الشركاء'**
  String get matrixDeliveryFleet;

  /// No description provided for @matrixCurrentCommission.
  ///
  /// In ar, this message translates to:
  /// **'العمولة المعتمدة حالياً'**
  String get matrixCurrentCommission;

  /// No description provided for @matrixDeliveryPercentage.
  ///
  /// In ar, this message translates to:
  /// **'نسبة مئوية من قيمة التوصيل'**
  String get matrixDeliveryPercentage;

  /// No description provided for @matrixFixedPerShipment.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ مقطوع ثابت لكل شحنة'**
  String get matrixFixedPerShipment;

  /// No description provided for @matrixAccountingReason.
  ///
  /// In ar, this message translates to:
  /// **'المسوغ المحاسبي والإلزامي للرقابة'**
  String get matrixAccountingReason;

  /// No description provided for @matrixCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get matrixCancel;

  /// No description provided for @reconciliationFinanceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الإدارة المالية والحسابات'**
  String get reconciliationFinanceSubtitle;

  /// No description provided for @departmentMerchantsTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة قسم التجار والمتاجر'**
  String get departmentMerchantsTitle;

  /// No description provided for @departmentEscrowTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة المستعمل وعربون «وصلني»'**
  String get departmentEscrowTitle;

  /// No description provided for @departmentServicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة طلبات الخدمات والصيانة'**
  String get departmentServicesTitle;

  /// No description provided for @departmentCouriersTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة مناديب التوصيل واللوجستيات'**
  String get departmentCouriersTitle;

  /// No description provided for @departmentActiveStores.
  ///
  /// In ar, this message translates to:
  /// **'المتاجر النشطة'**
  String get departmentActiveStores;

  /// No description provided for @departmentPendingRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات معلقة'**
  String get departmentPendingRequests;

  /// No description provided for @departmentPlatformCommission.
  ///
  /// In ar, this message translates to:
  /// **'عمولة المنصة'**
  String get departmentPlatformCommission;

  /// No description provided for @departmentActiveDeals.
  ///
  /// In ar, this message translates to:
  /// **'صفقات نشطة'**
  String get departmentActiveDeals;

  /// No description provided for @departmentDisputes.
  ///
  /// In ar, this message translates to:
  /// **'نزاعات'**
  String get departmentDisputes;

  /// No description provided for @departmentProtectionFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم حماية'**
  String get departmentProtectionFee;

  /// No description provided for @departmentServiceProviders.
  ///
  /// In ar, this message translates to:
  /// **'مزودي خدمات'**
  String get departmentServiceProviders;

  /// No description provided for @departmentActiveCouriers.
  ///
  /// In ar, this message translates to:
  /// **'مناديب نشطين'**
  String get departmentActiveCouriers;

  /// No description provided for @departmentPendingEntitlements.
  ///
  /// In ar, this message translates to:
  /// **'مستحقات معلقة'**
  String get departmentPendingEntitlements;

  /// No description provided for @departmentShipmentFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم شحنة'**
  String get departmentShipmentFee;

  /// No description provided for @departmentAuditedBadge.
  ///
  /// In ar, this message translates to:
  /// **'مدقق ومعتمد'**
  String get departmentAuditedBadge;

  /// No description provided for @departmentTotalBalance.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الرصيد التجميعي المتاح للتسوية والسحب'**
  String get departmentTotalBalance;

  /// No description provided for @departmentWalletSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرقابة وحسابات المتاجر'**
  String get departmentWalletSectionTitle;

  /// No description provided for @departmentSyncStatus.
  ///
  /// In ar, this message translates to:
  /// **'سداد وسريع متزامنان'**
  String get departmentSyncStatus;

  /// No description provided for @departmentGovernanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'حوكمة التسويات والضوابط البنكية (CFO)'**
  String get departmentGovernanceTitle;

  /// No description provided for @departmentLastReconciliation.
  ///
  /// In ar, this message translates to:
  /// **'آخر مطابقة بنكية: اليوم 02:45 م'**
  String get departmentLastReconciliation;

  /// No description provided for @departmentAvailableBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح للسحب'**
  String get departmentAvailableBalance;

  /// No description provided for @departmentUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'تحت التدقيق والتسوية'**
  String get departmentUnderReview;

  /// No description provided for @departmentMonthlySales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات المكتملة للشهر'**
  String get departmentMonthlySales;

  /// No description provided for @departmentOperationsUnit.
  ///
  /// In ar, this message translates to:
  /// **'عملية'**
  String get departmentOperationsUnit;

  /// No description provided for @departmentViewHistory.
  ///
  /// In ar, this message translates to:
  /// **'عرض سجل العمليات'**
  String get departmentViewHistory;

  /// No description provided for @departmentInstantSettlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية سريعة'**
  String get departmentInstantSettlement;

  /// No description provided for @departmentScheduledPayment.
  ///
  /// In ar, this message translates to:
  /// **'دفعة بنكية مجدولة'**
  String get departmentScheduledPayment;

  /// No description provided for @departmentUnderInspection.
  ///
  /// In ar, this message translates to:
  /// **'قيد المعاينة'**
  String get departmentUnderInspection;

  /// No description provided for @departmentInShipping.
  ///
  /// In ar, this message translates to:
  /// **'قيد الشحن'**
  String get departmentInShipping;

  /// No description provided for @departmentWeeklySettlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية أسبوعية'**
  String get departmentWeeklySettlement;

  /// No description provided for @departmentActiveMatched.
  ///
  /// In ar, this message translates to:
  /// **'نشط ومطابق'**
  String get departmentActiveMatched;

  /// No description provided for @departmentProtectedEscrow.
  ///
  /// In ar, this message translates to:
  /// **'ضمان محفوظ'**
  String get departmentProtectedEscrow;

  /// No description provided for @departmentApprovedProvider.
  ///
  /// In ar, this message translates to:
  /// **'مزود معتمد'**
  String get departmentApprovedProvider;

  /// No description provided for @departmentStrategicPartner.
  ///
  /// In ar, this message translates to:
  /// **'شريك استراتيجي'**
  String get departmentStrategicPartner;

  /// No description provided for @departmentActiveCourier.
  ///
  /// In ar, this message translates to:
  /// **'مندوب نشط'**
  String get departmentActiveCourier;

  /// No description provided for @departmentPendingSuffix.
  ///
  /// In ar, this message translates to:
  /// **'معلق'**
  String get departmentPendingSuffix;

  /// No description provided for @departmentMerchantHorizon.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة الأفق للتقنية والتجارة'**
  String get departmentMerchantHorizon;

  /// No description provided for @departmentStoreElite.
  ///
  /// In ar, this message translates to:
  /// **'متجر الصفوة الذهبي'**
  String get departmentStoreElite;

  /// No description provided for @departmentSparkleJewelry.
  ///
  /// In ar, this message translates to:
  /// **'مجوهرات البريق الراقية'**
  String get departmentSparkleJewelry;

  /// No description provided for @departmentEliteDevices.
  ///
  /// In ar, this message translates to:
  /// **'دار النخبة للأجهزة'**
  String get departmentEliteDevices;

  /// No description provided for @departmentCamryEscrow.
  ///
  /// In ar, this message translates to:
  /// **'سيارة تويوتا كامري 2020'**
  String get departmentCamryEscrow;

  /// No description provided for @departmentIphoneEscrow.
  ///
  /// In ar, this message translates to:
  /// **'آيفون 14 برو ماكس'**
  String get departmentIphoneEscrow;

  /// No description provided for @departmentItqanAc.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة إتقان للتكييف'**
  String get departmentItqanAc;

  /// No description provided for @departmentComprehensiveMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'شركة الصيانة الشاملة'**
  String get departmentComprehensiveMaintenance;

  /// No description provided for @departmentZajelShipping.
  ///
  /// In ar, this message translates to:
  /// **'شركة زاجل للشحن'**
  String get departmentZajelShipping;

  /// No description provided for @departmentWaslniCourier.
  ///
  /// In ar, this message translates to:
  /// **'مندوب أسطول وصلني (محمد أحمد)'**
  String get departmentWaslniCourier;

  /// No description provided for @departmentRecordPrefix.
  ///
  /// In ar, this message translates to:
  /// **'سجل:'**
  String get departmentRecordPrefix;

  /// No description provided for @departmentLicensePrefix.
  ///
  /// In ar, this message translates to:
  /// **'رخصة:'**
  String get departmentLicensePrefix;

  /// No description provided for @departmentEscrowPrefix.
  ///
  /// In ar, this message translates to:
  /// **'عربون تأمين'**
  String get departmentEscrowPrefix;

  /// No description provided for @departmentCourierNumberPrefix.
  ///
  /// In ar, this message translates to:
  /// **'رقم المندوب:'**
  String get departmentCourierNumberPrefix;

  /// No description provided for @departmentAllFilter.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get departmentAllFilter;

  /// No description provided for @departmentHighestBalanceFilter.
  ///
  /// In ar, this message translates to:
  /// **'أعلى رصيد'**
  String get departmentHighestBalanceFilter;

  /// No description provided for @departmentWithdrawalFilter.
  ///
  /// In ar, this message translates to:
  /// **'قيد السحب (8)'**
  String get departmentWithdrawalFilter;

  /// No description provided for @departmentGovernanceNotice.
  ///
  /// In ar, this message translates to:
  /// **'تخضع جميع تحويلات المحفظة لمطابقة يومية تلقائية مع شبكة سريع للمدفوعات الفورية ونظام سداد. ووفقاً لتعليمات البنك المركزي السعودي، تُحجز العمليات المشتبه بها للتدقيق اليدوي من إدارة الامتثال المالي ببرواح المازوري.'**
  String get departmentGovernanceNotice;

  /// No description provided for @matrixScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل مصفوفة نسب الأرباح والرسوم'**
  String get matrixScreenTitle;

  /// No description provided for @matrixDefaultReason.
  ///
  /// In ar, this message translates to:
  /// **'تعديل دوري لمواكبة تحديثات رسوم بوابات الدفع البنكية وتوسعة شبكة التوصيل الميداني'**
  String get matrixDefaultReason;

  /// No description provided for @matrixLastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر حفظ:'**
  String get matrixLastUpdated;

  /// No description provided for @matrixCfoDescription.
  ///
  /// In ar, this message translates to:
  /// **'تعديل نسب العمولات المقترحة وحفظها محليًا للمراجعة؛ لا تُفعّل التغييرات على محرك الدفع من هذه الصفحة.'**
  String get matrixCfoDescription;

  /// No description provided for @matrixAppliedRate.
  ///
  /// In ar, this message translates to:
  /// **'النسبة المحفوظة'**
  String get matrixAppliedRate;

  /// No description provided for @matrixTargetRate.
  ///
  /// In ar, this message translates to:
  /// **'ضبط النسبة المستهدفة'**
  String get matrixTargetRate;

  /// No description provided for @matrixMinimumValue.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى 2.0%'**
  String get matrixMinimumValue;

  /// No description provided for @matrixReferenceValue.
  ///
  /// In ar, this message translates to:
  /// **'المرجعي 5.0%'**
  String get matrixReferenceValue;

  /// No description provided for @matrixMaximumValue.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى 10.0%'**
  String get matrixMaximumValue;

  /// No description provided for @matrixSalesNote.
  ///
  /// In ar, this message translates to:
  /// **'تُطبق على جميع صفقات المتاجر، المنتجات الجديدة، ومبيعات الأجهزة المباشرة دون استثناءات محلية.'**
  String get matrixSalesNote;

  /// No description provided for @matrixCurrentSettlementRate.
  ///
  /// In ar, this message translates to:
  /// **'رسم التسوية الحالية'**
  String get matrixCurrentSettlementRate;

  /// No description provided for @matrixInstantFixedFee.
  ///
  /// In ar, this message translates to:
  /// **'رسم ثابت إضافي (تسوية فورية)'**
  String get matrixInstantFixedFee;

  /// No description provided for @matrixInstantFixedFeeNote.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق رسم مقطوع بقيمة 5.00 ج.م لكل تسوية مستعجلة'**
  String get matrixInstantFixedFeeNote;

  /// No description provided for @matrixCoverageDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفصيل تغطية التكلفة:'**
  String get matrixCoverageDetails;

  /// No description provided for @matrixGatewayCoverage.
  ///
  /// In ar, this message translates to:
  /// **'تغطية مصاريف بوابات الدفع (Mada / Visa / SARIE) بنسبة 0.85%'**
  String get matrixGatewayCoverage;

  /// No description provided for @matrixOperatingMargin.
  ///
  /// In ar, this message translates to:
  /// **'+ هامش تشغيلي وقائي بنسبة 0.40%'**
  String get matrixOperatingMargin;

  /// No description provided for @matrixSettlementNote.
  ///
  /// In ar, this message translates to:
  /// **'تُقتطع تلقائياً عند طلب التسوية السريعة عبر شبكة المدفوعات اللوجستية الفورية واسترداد النزاعات.'**
  String get matrixSettlementNote;

  /// No description provided for @matrixDeliveryTitle.
  ///
  /// In ar, this message translates to:
  /// **'عمولة قطاع التوصيل والنقل والشحن'**
  String get matrixDeliveryTitle;

  /// No description provided for @matrixDeliveryDescription.
  ///
  /// In ar, this message translates to:
  /// **'تُحتسب على كل عملية توصيل ناجحة لمناديب أسطول وصلني والشركات اللوجستية المتعاقدة وتُودع بالمحفظة المركزية.'**
  String get matrixDeliveryDescription;

  /// No description provided for @matrixAuditReasonTitle.
  ///
  /// In ar, this message translates to:
  /// **'المسوغ المحاسبي والإلزامي للرقابة'**
  String get matrixAuditReasonTitle;

  /// No description provided for @matrixAuditReasonPrompt.
  ///
  /// In ar, this message translates to:
  /// **'سبب وموجب تعديل النسب (إلزامي للرقابة والتدقيق المركزي):'**
  String get matrixAuditReasonPrompt;

  /// No description provided for @matrixNotifyUsers.
  ///
  /// In ar, this message translates to:
  /// **'تفضيل إشعار التجار والمناديب والمشرفين عند تطبيق تحديث للمصفوفة.'**
  String get matrixNotifyUsers;

  /// No description provided for @matrixSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ تعديلات المصفوفة على هذا الجهاز.'**
  String get matrixSaveSuccess;

  /// No description provided for @matrixSaveAndSend.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get matrixSaveAndSend;

  /// No description provided for @matrixAuditTrailNotice.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ التعديلات محلياً مع وقت الحفظ وسبب التعديل. اضغط لعرض السجل.'**
  String get matrixAuditTrailNotice;

  /// No description provided for @settlementsScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التسويات'**
  String get settlementsScreenTitle;

  /// No description provided for @settlementsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'برواح المازوري - الإدارة المالية'**
  String get settlementsSubtitle;

  /// No description provided for @settlementBack.
  ///
  /// In ar, this message translates to:
  /// **'العودة'**
  String get settlementBack;

  /// No description provided for @settlementsAuthority.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيات المدير المالي التنفيذي'**
  String get settlementsAuthority;

  /// No description provided for @settlementsPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المحافظ الإلكترونية والتسويات'**
  String get settlementsPageTitle;

  /// No description provided for @settlementsPageDescription.
  ///
  /// In ar, this message translates to:
  /// **'تنفيذ حركات النقود المالية المصرح بها مع إرفاق السند القانوني ومحضر النزاع المالي المعتمد.'**
  String get settlementsPageDescription;

  /// No description provided for @settlementsEscrowWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة الضمان (Escrow)'**
  String get settlementsEscrowWallet;

  /// No description provided for @settlementsReservedOrders.
  ///
  /// In ar, this message translates to:
  /// **'محجوز لأوامر نشطة'**
  String get settlementsReservedOrders;

  /// No description provided for @settlementsPendingBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد التسويات المعلقة'**
  String get settlementsPendingBalance;

  /// No description provided for @settlementsReadyRefund.
  ///
  /// In ar, this message translates to:
  /// **'طلب استرداد جاهز للإقفال'**
  String get settlementsReadyRefund;

  /// No description provided for @settlementSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طلب تسوية'**
  String get settlementSheetTitle;

  /// No description provided for @settlementOffsetMode.
  ///
  /// In ar, this message translates to:
  /// **'مقاصة الرصيد'**
  String get settlementOffsetMode;

  /// No description provided for @settlementRefundMode.
  ///
  /// In ar, this message translates to:
  /// **'استرداد'**
  String get settlementRefundMode;

  /// No description provided for @settlementTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع التسوية'**
  String get settlementTypeLabel;

  /// No description provided for @settlementTypeInstant.
  ///
  /// In ar, this message translates to:
  /// **'التسوية الفورية'**
  String get settlementTypeInstant;

  /// No description provided for @settlementBeneficiaryLabel.
  ///
  /// In ar, this message translates to:
  /// **'المستفيد'**
  String get settlementBeneficiaryLabel;

  /// No description provided for @settlementBeneficiaryAudit.
  ///
  /// In ar, this message translates to:
  /// **'التحقق والتدقيق'**
  String get settlementBeneficiaryAudit;

  /// No description provided for @settlementAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'قيمة التسوية'**
  String get settlementAmountLabel;

  /// No description provided for @settlementReferenceLabel.
  ///
  /// In ar, this message translates to:
  /// **'المرجع'**
  String get settlementReferenceLabel;

  /// No description provided for @settlementNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات التسوية'**
  String get settlementNotesLabel;

  /// No description provided for @settlementNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل تفاصيل طلب التسوية'**
  String get settlementNotesHint;

  /// No description provided for @settlementPaymentDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الدفع'**
  String get settlementPaymentDetailsTitle;

  /// No description provided for @settlementPaymentMethodLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get settlementPaymentMethodLabel;

  /// No description provided for @settlementPaymentBankTransfer.
  ///
  /// In ar, this message translates to:
  /// **'حوالة بنكية'**
  String get settlementPaymentBankTransfer;

  /// No description provided for @settlementDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get settlementDateLabel;

  /// No description provided for @settlementStatusLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get settlementStatusLabel;

  /// No description provided for @settlementStatusUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get settlementStatusUnderReview;

  /// No description provided for @settlementSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get settlementSubmit;

  /// No description provided for @settlementSubmitSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب التسوية بنجاح'**
  String get settlementSubmitSuccess;

  /// No description provided for @addNewSettlement.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تسوية جديدة'**
  String get addNewSettlement;

  /// No description provided for @instantRefundSettlement.
  ///
  /// In ar, this message translates to:
  /// **'استرداد / تسوية فورية'**
  String get instantRefundSettlement;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterInReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get filterInReview;

  /// No description provided for @filterApproved.
  ///
  /// In ar, this message translates to:
  /// **'معتمدة'**
  String get filterApproved;

  /// No description provided for @filterDisputed.
  ///
  /// In ar, this message translates to:
  /// **'قيد نزاع'**
  String get filterDisputed;

  /// No description provided for @pendingSettlementRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات التسوية المعلقة'**
  String get pendingSettlementRequests;

  /// No description provided for @settlementRequestOne.
  ///
  /// In ar, this message translates to:
  /// **'طلب'**
  String get settlementRequestOne;

  /// No description provided for @settlementVerifiedBank.
  ///
  /// In ar, this message translates to:
  /// **'حساب بنكي موثق'**
  String get settlementVerifiedBank;

  /// No description provided for @settlementMaintenanceDispute.
  ///
  /// In ar, this message translates to:
  /// **'نزاع صيانة'**
  String get settlementMaintenanceDispute;

  /// No description provided for @settlementFullRefund.
  ///
  /// In ar, this message translates to:
  /// **'استرداد مالي كامل'**
  String get settlementFullRefund;

  /// No description provided for @settlementAge35Minutes.
  ///
  /// In ar, this message translates to:
  /// **'منذ 35 دقيقة'**
  String get settlementAge35Minutes;

  /// No description provided for @settlementBeneficiaryTariq.
  ///
  /// In ar, this message translates to:
  /// **'د. طارق العمري'**
  String get settlementBeneficiaryTariq;

  /// No description provided for @settlementInitialTariq.
  ///
  /// In ar, this message translates to:
  /// **'ط'**
  String get settlementInitialTariq;

  /// No description provided for @settlementApprovedPartner.
  ///
  /// In ar, this message translates to:
  /// **'شريك معتمد - سجل تجاري'**
  String get settlementApprovedPartner;

  /// No description provided for @settlementBeneficiaryRealEstate.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة الضمان العقارية'**
  String get settlementBeneficiaryRealEstate;

  /// No description provided for @settlementInitialRealEstate.
  ///
  /// In ar, this message translates to:
  /// **'ض'**
  String get settlementInitialRealEstate;

  /// No description provided for @settlementCommissionCorrection.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح عمولة'**
  String get settlementCommissionCorrection;

  /// No description provided for @settlementCommissionSettlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية عمولة'**
  String get settlementCommissionSettlement;

  /// No description provided for @settlementAgeTwoHours.
  ///
  /// In ar, this message translates to:
  /// **'منذ ساعتين'**
  String get settlementAgeTwoHours;

  /// No description provided for @settlementIndependentProvider.
  ///
  /// In ar, this message translates to:
  /// **'مزود خدمة مستقل'**
  String get settlementIndependentProvider;

  /// No description provided for @settlementBeneficiaryKhalid.
  ///
  /// In ar, this message translates to:
  /// **'خالد المهيوب'**
  String get settlementBeneficiaryKhalid;

  /// No description provided for @settlementInitialKhalid.
  ///
  /// In ar, this message translates to:
  /// **'خ'**
  String get settlementInitialKhalid;

  /// No description provided for @settlementMediationDelivery.
  ///
  /// In ar, this message translates to:
  /// **'تسليم وساطة'**
  String get settlementMediationDelivery;

  /// No description provided for @settlementPenaltyDeduction.
  ///
  /// In ar, this message translates to:
  /// **'خصم جزائي'**
  String get settlementPenaltyDeduction;

  /// No description provided for @settlementAgeToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم 08:30 ص'**
  String get settlementAgeToday;

  /// No description provided for @recentSettlementsTitle.
  ///
  /// In ar, this message translates to:
  /// **'آخر التسويات المنفذة حديثاً'**
  String get recentSettlementsTitle;

  /// No description provided for @bankRefund.
  ///
  /// In ar, this message translates to:
  /// **'استرداد بنكي'**
  String get bankRefund;

  /// No description provided for @settlementCustomerBank.
  ///
  /// In ar, this message translates to:
  /// **'العميل #USR-8810 - بنك البلاد'**
  String get settlementCustomerBank;

  /// No description provided for @settlementToday1130.
  ///
  /// In ar, this message translates to:
  /// **'اليوم 11:30 ص'**
  String get settlementToday1130;

  /// No description provided for @compensationSettlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية تعويضية'**
  String get compensationSettlement;

  /// No description provided for @settlementProviderCorrection.
  ///
  /// In ar, this message translates to:
  /// **'مزود الخدمة - تصحيح عمولة'**
  String get settlementProviderCorrection;

  /// No description provided for @settlementYesterday0915.
  ///
  /// In ar, this message translates to:
  /// **'أمس 09:15 م'**
  String get settlementYesterday0915;

  /// No description provided for @settlementsLinkedRajhiEscrow.
  ///
  /// In ar, this message translates to:
  /// **'مصرف الراجحي - حساب الضمان المركزي'**
  String get settlementsLinkedRajhiEscrow;

  /// No description provided for @settlementRecentOperationsCount.
  ///
  /// In ar, this message translates to:
  /// **'142 عملية'**
  String get settlementRecentOperationsCount;

  /// No description provided for @viewLabel.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get viewLabel;

  /// No description provided for @viewAllLabel.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAllLabel;

  /// No description provided for @createSettlementToast.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تسوية جديدة'**
  String get createSettlementToast;

  /// No description provided for @frozenScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الطلبات المعلقة والمجمدة'**
  String get frozenScreenTitle;

  /// No description provided for @frozenTotalTitle.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبالغ والعمليات المجمدة احترازياً'**
  String get frozenTotalTitle;

  /// No description provided for @frozenRequestCount.
  ///
  /// In ar, this message translates to:
  /// **'طلبات مجمدة'**
  String get frozenRequestCount;

  /// No description provided for @frozenProtocol.
  ///
  /// In ar, this message translates to:
  /// **'بروتوكول المادة 18 مكافحة الاحتيال'**
  String get frozenProtocol;

  /// No description provided for @frozenAllFilter.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get frozenAllFilter;

  /// No description provided for @frozenMerchantsFilter.
  ///
  /// In ar, this message translates to:
  /// **'تجار ومتاجر'**
  String get frozenMerchantsFilter;

  /// No description provided for @frozenProvidersFilter.
  ///
  /// In ar, this message translates to:
  /// **'مقدمو خدمات'**
  String get frozenProvidersFilter;

  /// No description provided for @frozenSupervisorsFilter.
  ///
  /// In ar, this message translates to:
  /// **'المشرفون'**
  String get frozenSupervisorsFilter;

  /// No description provided for @frozenCouriersFilter.
  ///
  /// In ar, this message translates to:
  /// **'المناديب'**
  String get frozenCouriersFilter;

  /// No description provided for @frozenUsersFilter.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get frozenUsersFilter;

  /// No description provided for @frozenAdsFilter.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get frozenAdsFilter;

  /// No description provided for @frozenExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير بيان الأموال المجمدة (PDF / Excel)'**
  String get frozenExport;

  /// No description provided for @frozenRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث حالة الحركات ومزامنة الرقابة اللحظية'**
  String get frozenRefresh;

  /// No description provided for @frozenRequestOneName.
  ///
  /// In ar, this message translates to:
  /// **'تاجر مستلزمات حاسب'**
  String get frozenRequestOneName;

  /// No description provided for @frozenRequestOneSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب أرباح مالي دوري'**
  String get frozenRequestOneSubtitle;

  /// No description provided for @frozenMerchantType.
  ///
  /// In ar, this message translates to:
  /// **'تجار ومتاجر'**
  String get frozenMerchantType;

  /// No description provided for @frozenPrecautionaryStatus.
  ///
  /// In ar, this message translates to:
  /// **'مجمد احترازياً'**
  String get frozenPrecautionaryStatus;

  /// No description provided for @frozenRequestOneReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب التجميد: بلاغ نزاع مفتوح #CMP-1042 مع شبهة تلاعب في عروض ترويجية.'**
  String get frozenRequestOneReason;

  /// No description provided for @frozenSupervisorSaad.
  ///
  /// In ar, this message translates to:
  /// **'أ. سعد العتيبي'**
  String get frozenSupervisorSaad;

  /// No description provided for @frozenTodayFourHours.
  ///
  /// In ar, this message translates to:
  /// **'اليوم • منذ 4 ساعات'**
  String get frozenTodayFourHours;

  /// No description provided for @frozenRestoreAndRelease.
  ///
  /// In ar, this message translates to:
  /// **'إعادة العمل وفك التجميد للصرف'**
  String get frozenRestoreAndRelease;

  /// No description provided for @frozenRejectAndForfeit.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرفض والمصادرة'**
  String get frozenRejectAndForfeit;

  /// No description provided for @frozenRequestTwoName.
  ///
  /// In ar, this message translates to:
  /// **'ورشة الإتقان للكهرباء'**
  String get frozenRequestTwoName;

  /// No description provided for @frozenAnnualMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'مستحقات عقود صيانة سنوية'**
  String get frozenAnnualMaintenance;

  /// No description provided for @frozenProviderType.
  ///
  /// In ar, this message translates to:
  /// **'مقدمو خدمات'**
  String get frozenProviderType;

  /// No description provided for @frozenRequestTwoReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب التجميد: شكوى عدم اكتمال الصيانة المنزلية'**
  String get frozenRequestTwoReason;

  /// No description provided for @frozenSupervisorAhmed.
  ///
  /// In ar, this message translates to:
  /// **'أ. أحمد حسان'**
  String get frozenSupervisorAhmed;

  /// No description provided for @frozenYesterdayJanuary.
  ///
  /// In ar, this message translates to:
  /// **'أمس • 27 يناير'**
  String get frozenYesterdayJanuary;

  /// No description provided for @frozenPartialFullRelease.
  ///
  /// In ar, this message translates to:
  /// **'فك التجميد الجزئي / الكامل'**
  String get frozenPartialFullRelease;

  /// No description provided for @frozenCustomerRefund.
  ///
  /// In ar, this message translates to:
  /// **'تسوية استرداد للعميل'**
  String get frozenCustomerRefund;

  /// No description provided for @frozenRequestThreeName.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة الأفق للتجارة'**
  String get frozenRequestThreeName;

  /// No description provided for @frozenFastTransferPending.
  ///
  /// In ar, this message translates to:
  /// **'حوالة بنكية سريعة (SARIE) معلقة'**
  String get frozenFastTransferPending;

  /// No description provided for @frozenIbanMismatch.
  ///
  /// In ar, this message translates to:
  /// **'تعارض آيبان'**
  String get frozenIbanMismatch;

  /// No description provided for @frozenRequestThreeReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب التجميد: فشل التحقق الآلي من تطابق اسم المستفيد مع السجل التجاري في البنك المركزي السعودي.'**
  String get frozenRequestThreeReason;

  /// No description provided for @frozenJanuary25.
  ///
  /// In ar, this message translates to:
  /// **'25 يناير 2025'**
  String get frozenJanuary25;

  /// No description provided for @frozenRecheckTransfer.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التحقق وتنشيط الحوالة'**
  String get frozenRecheckTransfer;

  /// No description provided for @frozenRequestIbanCertificate.
  ///
  /// In ar, this message translates to:
  /// **'طلب شهادة آيبان جديدة مختومة من البنك'**
  String get frozenRequestIbanCertificate;

  /// No description provided for @frozenPendingTransferAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المعلق للحوالة:'**
  String get frozenPendingTransferAmount;

  /// No description provided for @frozenHeldAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المحتجز للتجميد:'**
  String get frozenHeldAmount;

  /// No description provided for @frozenRegisteredIban.
  ///
  /// In ar, this message translates to:
  /// **'الآيبان المسجل:'**
  String get frozenRegisteredIban;

  /// No description provided for @frozenGrossTransaction.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المعاملة:'**
  String get frozenGrossTransaction;

  /// No description provided for @frozenAccountNameMismatch.
  ///
  /// In ar, this message translates to:
  /// **'عدم تطابق اسم الحساب'**
  String get frozenAccountNameMismatch;

  /// No description provided for @frozenPlatformFeeDeduction.
  ///
  /// In ar, this message translates to:
  /// **'خصم عمولة المنصة:'**
  String get frozenPlatformFeeDeduction;

  /// No description provided for @frozenSupervisorLabel.
  ///
  /// In ar, this message translates to:
  /// **'مشرف:'**
  String get frozenSupervisorLabel;

  /// No description provided for @frozenThawSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم فك التجميد وإرسال طلب الصرف للإدارة للموافقة'**
  String get frozenThawSuccess;

  /// No description provided for @frozenForfeitSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب ومصادرته وحفظ سبب الرفض'**
  String get frozenForfeitSuccess;

  /// No description provided for @frozenForfeitReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب الرفض والمصادرة الرقابية بالتفصيل...'**
  String get frozenForfeitReasonHint;

  /// No description provided for @frozenBankLinksTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات ربط الحسابات البنكية المجمدة'**
  String get frozenBankLinksTitle;

  /// No description provided for @frozenBankLinkReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب التجميد:'**
  String get frozenBankLinkReason;

  /// No description provided for @frozenBankLinkRestore.
  ///
  /// In ar, this message translates to:
  /// **'فك التجميد وإعادته للمراجعة'**
  String get frozenBankLinkRestore;

  /// No description provided for @frozenBankLinkReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض مع تسجيل السبب'**
  String get frozenBankLinkReject;

  /// No description provided for @frozenBankLinkRestoreDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة طلب ربط الحساب للمراجعة'**
  String get frozenBankLinkRestoreDialogTitle;

  /// No description provided for @frozenBankLinkRestoreDialogDescription.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد فك تجميد طلب ربط الحساب وإعادته إلى قائمة المطابقة النشطة؟'**
  String get frozenBankLinkRestoreDialogDescription;

  /// No description provided for @frozenBankLinkRestoreConfirm.
  ///
  /// In ar, this message translates to:
  /// **'فك التجميد والإعادة'**
  String get frozenBankLinkRestoreConfirm;

  /// No description provided for @frozenBankLinkRestoreSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم فك تجميد الطلب وإعادته إلى قائمة المطابقة البنكية.'**
  String get frozenBankLinkRestoreSuccess;

  /// No description provided for @frozenBankLinkRejectDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض طلب ربط الحساب المجمد'**
  String get frozenBankLinkRejectDialogTitle;

  /// No description provided for @frozenBankLinkRejectReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب رفض طلب ربط الحساب...'**
  String get frozenBankLinkRejectReasonHint;

  /// No description provided for @frozenBankLinkRejectSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض طلب ربط الحساب المجمد وحفظ السبب.'**
  String get frozenBankLinkRejectSuccess;

  /// No description provided for @frozenForfeitReasonNotice.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حفظ السبب مع قرار الرفض والمصادرة وإرساله للإدارة للمراجعة.'**
  String get frozenForfeitReasonNotice;

  /// No description provided for @frozenActionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تنفيذ الإجراء. حدّث الطلب وحاول مرة أخرى.'**
  String get frozenActionFailed;

  /// No description provided for @frozenLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الطلبات المعلقة والمجمدة.'**
  String get frozenLoadFailed;

  /// No description provided for @frozenNoRequests.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات معلقة أو مجمدة حالياً.'**
  String get frozenNoRequests;

  /// No description provided for @transactionHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات'**
  String get transactionHistoryTitle;

  /// No description provided for @transactionFinancialSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'برواح المازوري - الإدارة المالية'**
  String get transactionFinancialSubtitle;

  /// No description provided for @transactionSupervisedBy.
  ///
  /// In ar, this message translates to:
  /// **'تحت إشراف: أ. سعد العتيبي'**
  String get transactionSupervisedBy;

  /// No description provided for @transactionAvailableBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد المحفظة المتاح للتسوية'**
  String get transactionAvailableBalance;

  /// No description provided for @transactionTotalWithdrawals.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السحوبات'**
  String get transactionTotalWithdrawals;

  /// No description provided for @transactionTotalDeposits.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيداعات'**
  String get transactionTotalDeposits;

  /// No description provided for @transactionApprovedHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحركات المصرفية المعتمدة'**
  String get transactionApprovedHistory;

  /// No description provided for @transactionThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر (يناير 2025)'**
  String get transactionThisMonth;

  /// No description provided for @transactionAllFilter.
  ///
  /// In ar, this message translates to:
  /// **'الكل (6)'**
  String get transactionAllFilter;

  /// No description provided for @transactionDepositsFilter.
  ///
  /// In ar, this message translates to:
  /// **'عمليات الإيداع (+3)'**
  String get transactionDepositsFilter;

  /// No description provided for @transactionWithdrawalsFilter.
  ///
  /// In ar, this message translates to:
  /// **'عمليات السحب (-3)'**
  String get transactionWithdrawalsFilter;

  /// No description provided for @transactionTodayGroup.
  ///
  /// In ar, this message translates to:
  /// **'اليوم • 28 يناير 2025'**
  String get transactionTodayGroup;

  /// No description provided for @transactionTwoOperations.
  ///
  /// In ar, this message translates to:
  /// **'عمليتان'**
  String get transactionTwoOperations;

  /// No description provided for @transactionDepositSales.
  ///
  /// In ar, this message translates to:
  /// **'إيداع مبيعات نقدية - متجر إلكتروني'**
  String get transactionDepositSales;

  /// No description provided for @transactionNationalGateway.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة مدى • بوابة الدفع الوطنية'**
  String get transactionNationalGateway;

  /// No description provided for @transactionSuccess.
  ///
  /// In ar, this message translates to:
  /// **'ناجح ومكتمل'**
  String get transactionSuccess;

  /// No description provided for @transactionTimeTodayDeposit.
  ///
  /// In ar, this message translates to:
  /// **'02:45 م'**
  String get transactionTimeTodayDeposit;

  /// No description provided for @transactionProfitWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'سحب أرباح للبنك - مصرف الراجحي'**
  String get transactionProfitWithdrawal;

  /// No description provided for @transactionFastNetwork.
  ///
  /// In ar, this message translates to:
  /// **'آيبان: SA44****5521 • سريع SARIE'**
  String get transactionFastNetwork;

  /// No description provided for @transactionApproved.
  ///
  /// In ar, this message translates to:
  /// **'تحويل معتمد'**
  String get transactionApproved;

  /// No description provided for @transactionTimeTodayWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'11:15 ص'**
  String get transactionTimeTodayWithdrawal;

  /// No description provided for @transactionYesterdayGroup.
  ///
  /// In ar, this message translates to:
  /// **'أمس • 27 يناير 2025'**
  String get transactionYesterdayGroup;

  /// No description provided for @transactionWaslniDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع طلبات وصلني'**
  String get transactionWaslniDeposit;

  /// No description provided for @transactionAutomatedSettlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية لوجستية آلية متوافقة'**
  String get transactionAutomatedSettlement;

  /// No description provided for @transactionCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get transactionCompleted;

  /// No description provided for @transactionTimeYesterdayDeposit.
  ///
  /// In ar, this message translates to:
  /// **'06:30 م'**
  String get transactionTimeYesterdayDeposit;

  /// No description provided for @transactionSnbWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'سحب أرباح - البنك الأهلي'**
  String get transactionSnbWithdrawal;

  /// No description provided for @transactionCorporateVerification.
  ///
  /// In ar, this message translates to:
  /// **'آيبان: SA12****8894 • توثيق مؤسسي'**
  String get transactionCorporateVerification;

  /// No description provided for @transactionCertified.
  ///
  /// In ar, this message translates to:
  /// **'مصدق رقابياً'**
  String get transactionCertified;

  /// No description provided for @transactionTimeYesterdayWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'09:20 ص'**
  String get transactionTimeYesterdayWithdrawal;

  /// No description provided for @transactionLastWeekGroup.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع الماضي • 23 يناير 2025'**
  String get transactionLastWeekGroup;

  /// No description provided for @transactionMerchantDisputeDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع تسوية نزاع لصالح التاجر...'**
  String get transactionMerchantDisputeDeposit;

  /// No description provided for @transactionArbitrationDecision.
  ///
  /// In ar, this message translates to:
  /// **'قرار تحكيمي منصة المدفوعات #ARB-209'**
  String get transactionArbitrationDecision;

  /// No description provided for @transactionEffectiveSettlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية نافذة'**
  String get transactionEffectiveSettlement;

  /// No description provided for @transactionTimeLastWeekDeposit.
  ///
  /// In ar, this message translates to:
  /// **'04:10 م'**
  String get transactionTimeLastWeekDeposit;

  /// No description provided for @transactionWithdrawalReview.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب أرباح قيد المراجعة الفورية...'**
  String get transactionWithdrawalReview;

  /// No description provided for @transactionAmlReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة مطابقة الامتثال المالي (AML)'**
  String get transactionAmlReview;

  /// No description provided for @transactionBankAudit.
  ///
  /// In ar, this message translates to:
  /// **'قيد التدقيق البنكي'**
  String get transactionBankAudit;

  /// No description provided for @transactionTimeLastWeekWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'01:15 م'**
  String get transactionTimeLastWeekWithdrawal;

  /// No description provided for @transactionHeldBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المحجوز:'**
  String get transactionHeldBalance;

  /// No description provided for @transactionBalanceAfter.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد بعد الحركة:'**
  String get transactionBalanceAfter;

  /// No description provided for @transactionDownloadStatement.
  ///
  /// In ar, this message translates to:
  /// **'تحميل كشف الحساب المعتمد (PDF)'**
  String get transactionDownloadStatement;

  /// No description provided for @totalRequiredAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السعر المطلوب'**
  String get totalRequiredAmount;

  /// No description provided for @goldenAnnualPackage.
  ///
  /// In ar, this message translates to:
  /// **'الباقة الذهبية السنوية'**
  String get goldenAnnualPackage;

  /// No description provided for @proServiceProvider.
  ///
  /// In ar, this message translates to:
  /// **'مزود خدمة احترافي'**
  String get proServiceProvider;

  /// No description provided for @vipAnnualPackage.
  ///
  /// In ar, this message translates to:
  /// **'باقة VIP السنوية'**
  String get vipAnnualPackage;

  /// No description provided for @unlimitedDeliveryPackage.
  ///
  /// In ar, this message translates to:
  /// **'باقة التوصيل اللامحدود'**
  String get unlimitedDeliveryPackage;

  /// No description provided for @featuredWeekPackage.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مميز (أسبوع واحد)'**
  String get featuredWeekPackage;

  /// No description provided for @directBankTransferSadad.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي مباشر (سداد / الراجحي)'**
  String get directBankTransferSadad;

  /// No description provided for @directDebitEscrow.
  ///
  /// In ar, this message translates to:
  /// **'خصم مباشر من المحفظة الضامنة (Escrow)'**
  String get directDebitEscrow;

  /// No description provided for @creditCardMada.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة ائتمانية (مدى)'**
  String get creditCardMada;

  /// No description provided for @walletDeduction.
  ///
  /// In ar, this message translates to:
  /// **'خصم من المحفظة'**
  String get walletDeduction;

  /// No description provided for @directBankTransferSnb.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي مباشر (الأهلي)'**
  String get directBankTransferSnb;

  /// No description provided for @availableBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'رصيد متاح'**
  String get availableBalanceLabel;

  /// No description provided for @featuredMerchantSubscription.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك تاجر مميز'**
  String get featuredMerchantSubscription;

  /// No description provided for @premiumUser.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم مميز'**
  String get premiumUser;

  /// No description provided for @deliveryCourier.
  ///
  /// In ar, this message translates to:
  /// **'مندوب توصيل'**
  String get deliveryCourier;

  /// No description provided for @commercialAds.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات تجارية'**
  String get commercialAds;

  /// No description provided for @eliteElectronicsStore.
  ///
  /// In ar, this message translates to:
  /// **'متجر النخبة للإلكترونيات'**
  String get eliteElectronicsStore;

  /// No description provided for @maintenanceWorkshop.
  ///
  /// In ar, this message translates to:
  /// **'ورشة الصيانة المتكاملة...'**
  String get maintenanceWorkshop;

  /// No description provided for @vipUserUpgrade.
  ///
  /// In ar, this message translates to:
  /// **'ترقية مستخدم VIP'**
  String get vipUserUpgrade;

  /// No description provided for @fastCourierPackage.
  ///
  /// In ar, this message translates to:
  /// **'باقة المندوب السريع'**
  String get fastCourierPackage;

  /// No description provided for @mainBannerAd.
  ///
  /// In ar, this message translates to:
  /// **'إعلان بانر رئيسي'**
  String get mainBannerAd;

  /// No description provided for @alRajhiBankName.
  ///
  /// In ar, this message translates to:
  /// **'مصرف الراجحي'**
  String get alRajhiBankName;

  /// No description provided for @snbBankName.
  ///
  /// In ar, this message translates to:
  /// **'البنك الأهلي السعودي (SNB)'**
  String get snbBankName;

  /// No description provided for @riyadBankName.
  ///
  /// In ar, this message translates to:
  /// **'بنك الرياض'**
  String get riyadBankName;

  /// No description provided for @madaGatewayName.
  ///
  /// In ar, this message translates to:
  /// **'بوابة سداد و مدى (Mada Gateway)'**
  String get madaGatewayName;

  /// No description provided for @stcPayWalletName.
  ///
  /// In ar, this message translates to:
  /// **'محفظة STC Pay المركزية'**
  String get stcPayWalletName;

  /// No description provided for @operatingAccountType.
  ///
  /// In ar, this message translates to:
  /// **'حساب تشغيلي'**
  String get operatingAccountType;

  /// No description provided for @escrowAccountType.
  ///
  /// In ar, this message translates to:
  /// **'حساب ضمان Escrow'**
  String get escrowAccountType;

  /// No description provided for @electronicPaymentGatewayType.
  ///
  /// In ar, this message translates to:
  /// **'بوابة دفع إلكتروني'**
  String get electronicPaymentGatewayType;

  /// No description provided for @digitalWalletType.
  ///
  /// In ar, this message translates to:
  /// **'محفظة رقمية'**
  String get digitalWalletType;

  /// No description provided for @reconciliationNewCommercialAccountRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب ربط وتوثيق حساب تجاري جديد'**
  String get reconciliationNewCommercialAccountRequest;

  /// No description provided for @reconciliationSupplierAccountRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب ربط حساب مورد معتمد'**
  String get reconciliationSupplierAccountRequest;

  /// No description provided for @reconciliationFreelanceProviderRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب ربط حساب مزود خدمة مستقل'**
  String get reconciliationFreelanceProviderRequest;

  /// No description provided for @reconciliationMatchDescription100.
  ///
  /// In ar, this message translates to:
  /// **'تطابق الاسم التجاري والبنكي موثق بنسبة 100%'**
  String get reconciliationMatchDescription100;

  /// No description provided for @reconciliationMatchDescription96.
  ///
  /// In ar, this message translates to:
  /// **'اختلاف طفيف في اللواحق القانونية للاسم التجاري'**
  String get reconciliationMatchDescription96;

  /// No description provided for @reconciliationMatchDescription89.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة فردية تتطلب شهادة آيبان حديثة مختومة'**
  String get reconciliationMatchDescription89;

  /// No description provided for @reconciliationWarning96.
  ///
  /// In ar, this message translates to:
  /// **'تم رصد اختلاف بين لاحقة السجل والحساب البنكي'**
  String get reconciliationWarning96;

  /// No description provided for @reconciliationWarning89.
  ///
  /// In ar, this message translates to:
  /// **'شهادة الآيبان المرفقة تعود لأكثر من 6 أشهر'**
  String get reconciliationWarning89;

  /// No description provided for @reconciliationCommercialName1.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة التجارة المتقدمة المحدودة'**
  String get reconciliationCommercialName1;

  /// No description provided for @reconciliationBeneficiaryName1.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة التجارة المتقدمة للخدمات والتوكيلات'**
  String get reconciliationBeneficiaryName1;

  /// No description provided for @reconciliationCommercialName2.
  ///
  /// In ar, this message translates to:
  /// **'شركة مدار الرواد للمقاولات العامة'**
  String get reconciliationCommercialName2;

  /// No description provided for @reconciliationBeneficiaryName2.
  ///
  /// In ar, this message translates to:
  /// **'شركة مدار الرواد للتجارة والمقاولات ش.ش.و'**
  String get reconciliationBeneficiaryName2;

  /// No description provided for @reconciliationCommercialName3.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة القمة الرقمية لتقنية المعلومات'**
  String get reconciliationCommercialName3;

  /// No description provided for @reconciliationBeneficiaryName3.
  ///
  /// In ar, this message translates to:
  /// **'فهد سليمان عبد الله العتيبي'**
  String get reconciliationBeneficiaryName3;

  /// No description provided for @reconciliationHijriSuffix.
  ///
  /// In ar, this message translates to:
  /// **'هـ'**
  String get reconciliationHijriSuffix;

  /// No description provided for @reconciliationFreezeRequest.
  ///
  /// In ar, this message translates to:
  /// **'تجميد الطلب'**
  String get reconciliationFreezeRequest;

  /// No description provided for @merchantsSupervisorTitle.
  ///
  /// In ar, this message translates to:
  /// **'Merchants'**
  String get merchantsSupervisorTitle;

  /// No description provided for @merchantSupervisorRoleBadge.
  ///
  /// In ar, this message translates to:
  /// **'مشرف تجار'**
  String get merchantSupervisorRoleBadge;

  /// No description provided for @merchantSupervisorAdminSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'برواح المازوري - الإدارة'**
  String get merchantSupervisorAdminSubtitle;

  /// No description provided for @welcomeSupervisorAhmed.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، المشرف أحمد'**
  String get welcomeSupervisorAhmed;

  /// No description provided for @fieldSupervisorTag.
  ///
  /// In ar, this message translates to:
  /// **'ميداني'**
  String get fieldSupervisorTag;

  /// No description provided for @merchantsPortfolioSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة التجار الموكلة إليك - منطقة الرياض'**
  String get merchantsPortfolioSubtitle;

  /// No description provided for @approvedMerchantsMetric.
  ///
  /// In ar, this message translates to:
  /// **'تاجر معتمد'**
  String get approvedMerchantsMetric;

  /// No description provided for @pendingReviewMetric.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة'**
  String get pendingReviewMetric;

  /// No description provided for @searchMerchantsHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم، السجل التجاري، أو التصنيف'**
  String get searchMerchantsHint;

  /// No description provided for @filterActiveVerified.
  ///
  /// In ar, this message translates to:
  /// **'نشط وموثق'**
  String get filterActiveVerified;

  /// No description provided for @filterUnderAudit.
  ///
  /// In ar, this message translates to:
  /// **'قيد التدقيق'**
  String get filterUnderAudit;

  /// No description provided for @filterUpdateRequired.
  ///
  /// In ar, this message translates to:
  /// **'تحديث بيانات مطلوب'**
  String get filterUpdateRequired;

  /// No description provided for @filterSuspended.
  ///
  /// In ar, this message translates to:
  /// **'معلق مؤقتاً'**
  String get filterSuspended;

  /// No description provided for @registeredStoresSection.
  ///
  /// In ar, this message translates to:
  /// **'المتاجر المسجلة تحت إشرافك'**
  String get registeredStoresSection;

  /// No description provided for @storesRatio.
  ///
  /// In ar, this message translates to:
  /// **'{current} من أصل {total}'**
  String storesRatio(Object current, Object total);

  /// No description provided for @recentlyActiveSort.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث نشاطاً'**
  String get recentlyActiveSort;

  /// No description provided for @crShortLabel.
  ///
  /// In ar, this message translates to:
  /// **'س.ت'**
  String get crShortLabel;

  /// No description provided for @linkNewMerchant.
  ///
  /// In ar, this message translates to:
  /// **'ربط تاجر جديد'**
  String get linkNewMerchant;

  /// No description provided for @navMerchants.
  ///
  /// In ar, this message translates to:
  /// **'التجار'**
  String get navMerchants;

  /// No description provided for @navAds.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get navAds;

  /// No description provided for @navFinancialRequests.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المالية'**
  String get navFinancialRequests;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get navAccount;

  /// No description provided for @merchantSectionComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قسم {section} قيد التجهيز'**
  String merchantSectionComingSoon(Object section);

  /// No description provided for @adsManagementTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الإعلانات قبل النشر'**
  String get adsManagementTitle;

  /// No description provided for @adsReviewGateway.
  ///
  /// In ar, this message translates to:
  /// **'بوابة التدقيق الإشرافي المباشر'**
  String get adsReviewGateway;

  /// No description provided for @adsUrgentDecision.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب قراراً فورياً'**
  String get adsUrgentDecision;

  /// No description provided for @adsHiddenToday.
  ///
  /// In ar, this message translates to:
  /// **'المخفية'**
  String get adsHiddenToday;

  /// No description provided for @adsPendingToday.
  ///
  /// In ar, this message translates to:
  /// **'المعتمدة اليوم'**
  String get adsPendingToday;

  /// No description provided for @adsUnderReviewCount.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get adsUnderReviewCount;

  /// No description provided for @adsAllFilter.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get adsAllFilter;

  /// No description provided for @adsVehiclesFilter.
  ///
  /// In ar, this message translates to:
  /// **'سيارات ومركبات'**
  String get adsVehiclesFilter;

  /// No description provided for @adsElectronicsFilter.
  ///
  /// In ar, this message translates to:
  /// **'إلكترونيات'**
  String get adsElectronicsFilter;

  /// No description provided for @adsRealEstateFilter.
  ///
  /// In ar, this message translates to:
  /// **'عقارات'**
  String get adsRealEstateFilter;

  /// No description provided for @adsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالعنوان أو التاجر أو الكود...'**
  String get adsSearchHint;

  /// No description provided for @adsClearSearch.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get adsClearSearch;

  /// No description provided for @adsPendingHeading.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات المعلقة للتدقيق'**
  String get adsPendingHeading;

  /// No description provided for @adsRecentSort.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث وصولاً'**
  String get adsRecentSort;

  /// No description provided for @adsOldestSort.
  ///
  /// In ar, this message translates to:
  /// **'الأقدم وصولاً'**
  String get adsOldestSort;

  /// No description provided for @adsImageCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} صور'**
  String adsImageCount(Object count);

  /// No description provided for @adsCarMerchant.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة الأفق لتجارة السيارات'**
  String get adsCarMerchant;

  /// No description provided for @adsCarCategory.
  ///
  /// In ar, this message translates to:
  /// **'معرض سيارات • الرياض'**
  String get adsCarCategory;

  /// No description provided for @adsCarTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرسيدس E300 موديل 2023 فل كامل AMG'**
  String get adsCarTitle;

  /// No description provided for @adsCarDetails.
  ///
  /// In ar, this message translates to:
  /// **'عداد: 15,000 كم'**
  String get adsCarDetails;

  /// No description provided for @adsCarPrice.
  ///
  /// In ar, this message translates to:
  /// **'245,000 ر.س'**
  String get adsCarPrice;

  /// No description provided for @adsPhoneMerchant.
  ///
  /// In ar, this message translates to:
  /// **'متجر الصفوة للإلكترونيات'**
  String get adsPhoneMerchant;

  /// No description provided for @adsPhoneCategory.
  ///
  /// In ar, this message translates to:
  /// **'موثق في معروف • الرياض'**
  String get adsPhoneCategory;

  /// No description provided for @adsPhoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'آيفون 16 برو ماكس 256GB تيتانيوم طبيعي جديد'**
  String get adsPhoneTitle;

  /// No description provided for @adsPhoneDetails.
  ///
  /// In ar, this message translates to:
  /// **'الكفالة المحلية: 5 سنوات'**
  String get adsPhoneDetails;

  /// No description provided for @adsPhonePrice.
  ///
  /// In ar, this message translates to:
  /// **'4,699 ر.س'**
  String get adsPhonePrice;

  /// No description provided for @adsVillaMerchant.
  ///
  /// In ar, this message translates to:
  /// **'شركة اليمامة للمقاولات والعقارات'**
  String get adsVillaMerchant;

  /// No description provided for @adsVillaCategory.
  ///
  /// In ar, this message translates to:
  /// **'وسيط عقاري معتمد • الرياض'**
  String get adsVillaCategory;

  /// No description provided for @adsVillaTitle.
  ///
  /// In ar, this message translates to:
  /// **'فيلا مودرن فاخرة درج صالة - حي النرجس'**
  String get adsVillaTitle;

  /// No description provided for @adsVillaDetails.
  ///
  /// In ar, this message translates to:
  /// **'مساحة الأرض 375 م²'**
  String get adsVillaDetails;

  /// No description provided for @adsVillaPrice.
  ///
  /// In ar, this message translates to:
  /// **'2,850,000 ر.س'**
  String get adsVillaPrice;

  /// No description provided for @adsLicenseVerified.
  ///
  /// In ar, this message translates to:
  /// **'الترخيص التجاري موثق'**
  String get adsLicenseVerified;

  /// No description provided for @adsMarketPriceMatched.
  ///
  /// In ar, this message translates to:
  /// **'سعر متوافق مع متوسط السوق'**
  String get adsMarketPriceMatched;

  /// No description provided for @adsReviewHidden.
  ///
  /// In ar, this message translates to:
  /// **'مخفي بانتظار المراجعة'**
  String get adsReviewHidden;

  /// No description provided for @adsMinutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String adsMinutesAgo(Object count);

  /// No description provided for @adsHoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ ساعتين'**
  String get adsHoursAgo;

  /// No description provided for @adsReviewAndApprove.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة وتدقيق الإعلان'**
  String get adsReviewAndApprove;

  /// No description provided for @adsHideAction.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الإعلان'**
  String get adsHideAction;

  /// No description provided for @adsApproveAction.
  ///
  /// In ar, this message translates to:
  /// **'قبول واعتماد النشر'**
  String get adsApproveAction;

  /// No description provided for @adsRejectAction.
  ///
  /// In ar, this message translates to:
  /// **'رفض مع ذكر السبب'**
  String get adsRejectAction;

  /// No description provided for @adsRejectReasonTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبب رفض الإعلان'**
  String get adsRejectReasonTitle;

  /// No description provided for @adsRejectReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب الرفض ليظهر للتاجر'**
  String get adsRejectReasonHint;

  /// No description provided for @adsRejectReasonInstructions.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار سبب واضح ليتم إبلاغ التاجر به وتوثيقه في سجل التدقيق الإداري.'**
  String get adsRejectReasonInstructions;

  /// No description provided for @adsRejectReasonPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر غير منطقي أو وهمي'**
  String get adsRejectReasonPrice;

  /// No description provided for @adsRejectReasonMisleading.
  ///
  /// In ar, this message translates to:
  /// **'وصف مضلل أو بيانات غير دقيقة'**
  String get adsRejectReasonMisleading;

  /// No description provided for @adsRejectReasonPhotos.
  ///
  /// In ar, this message translates to:
  /// **'صور غير مطابقة للمواصفات أو ذات جودة رديئة'**
  String get adsRejectReasonPhotos;

  /// No description provided for @adsRejectReasonPolicy.
  ///
  /// In ar, this message translates to:
  /// **'مخالفة سياسة النشر وشروط المنصة'**
  String get adsRejectReasonPolicy;

  /// No description provided for @adsRejectGuidanceOptional.
  ///
  /// In ar, this message translates to:
  /// **'توجيه مخصص للتاجر (اختياري)'**
  String get adsRejectGuidanceOptional;

  /// No description provided for @adsRejectGuidanceDirectLabel.
  ///
  /// In ar, this message translates to:
  /// **'يظهر في إشعار التاجر المباشر'**
  String get adsRejectGuidanceDirectLabel;

  /// No description provided for @adsRejectGuidanceHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل نص التوجيه لتعديل الإعلان وإعادة رفعه...'**
  String get adsRejectGuidanceHint;

  /// No description provided for @adsConfirmRejectAndNotify.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرفض وإشعار التاجر'**
  String get adsConfirmRejectAndNotify;

  /// No description provided for @adsCancelAction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get adsCancelAction;

  /// No description provided for @adsConfirmReject.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرفض'**
  String get adsConfirmReject;

  /// No description provided for @adsApprovedStatus.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد الإعلان'**
  String get adsApprovedStatus;

  /// No description provided for @adsPremiumWaitingFinance.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار مراجعة المشرف المالي'**
  String get adsPremiumWaitingFinance;

  /// No description provided for @adsPremiumWaitingManagement.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار اعتماد الإدارة وخصم الرسوم'**
  String get adsPremiumWaitingManagement;

  /// No description provided for @adsHiddenStatus.
  ///
  /// In ar, this message translates to:
  /// **'الإعلان مخفي'**
  String get adsHiddenStatus;

  /// No description provided for @adsRejectedStatus.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الإعلان'**
  String get adsRejectedStatus;

  /// No description provided for @adsNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات مطابقة'**
  String get adsNoResults;

  /// No description provided for @adsDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الإعلان'**
  String get adsDetailsTitle;

  /// No description provided for @adsInImageReviewStatus.
  ///
  /// In ar, this message translates to:
  /// **'إعلان معلق قيد المراجعة'**
  String get adsInImageReviewStatus;

  /// No description provided for @adsNotPublishedYet.
  ///
  /// In ar, this message translates to:
  /// **'غير منشور حالياً'**
  String get adsNotPublishedYet;

  /// No description provided for @adsMerchantRegistrationNumber.
  ///
  /// In ar, this message translates to:
  /// **'سجل تجاري: {number}'**
  String adsMerchantRegistrationNumber(Object number);

  /// No description provided for @productSupervisorRoleBadge.
  ///
  /// In ar, this message translates to:
  /// **'مشرف المنتجات الجديدة'**
  String get productSupervisorRoleBadge;

  /// No description provided for @productReviewTab.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get productReviewTab;

  /// No description provided for @productReportsTab.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get productReportsTab;

  /// No description provided for @productSubscriptionsTab.
  ///
  /// In ar, this message translates to:
  /// **'ترويج المنتجات'**
  String get productSubscriptionsTab;

  /// No description provided for @productAccountTab.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get productAccountTab;

  /// No description provided for @wasalnySupervisorRoleBadge.
  ///
  /// In ar, this message translates to:
  /// **'مشرف وصلني'**
  String get wasalnySupervisorRoleBadge;

  /// No description provided for @wasalnyRequestsTab.
  ///
  /// In ar, this message translates to:
  /// **'طلبات وصلني'**
  String get wasalnyRequestsTab;

  /// No description provided for @wasalnyAccountFollowComplaint.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الشكوى'**
  String get wasalnyAccountFollowComplaint;

  /// No description provided for @wasalnyReportOverview.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الأداء الميداني'**
  String get wasalnyReportOverview;

  /// No description provided for @wasalnyReportCompletionRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة إتمام الصفقات'**
  String get wasalnyReportCompletionRate;

  /// No description provided for @wasalnyReportDealsDetail.
  ///
  /// In ar, this message translates to:
  /// **'صفقة مكتملة خلال الفترة المحددة'**
  String get wasalnyReportDealsDetail;

  /// No description provided for @wasalnyReportCompletionDetail.
  ///
  /// In ar, this message translates to:
  /// **'من الصفقات التي تمت متابعتها'**
  String get wasalnyReportCompletionDetail;

  /// No description provided for @wasalnyReportResponseTime.
  ///
  /// In ar, this message translates to:
  /// **'متوسط سرعة الاستجابة'**
  String get wasalnyReportResponseTime;

  /// No description provided for @wasalnyReportResponseDetail.
  ///
  /// In ar, this message translates to:
  /// **'أسرع من المعيار المعتمد'**
  String get wasalnyReportResponseDetail;

  /// No description provided for @wasalnyReportSatisfaction.
  ///
  /// In ar, this message translates to:
  /// **'معدل رضا الأطراف'**
  String get wasalnyReportSatisfaction;

  /// No description provided for @wasalnyReportRatingDetail.
  ///
  /// In ar, this message translates to:
  /// **'استناداً إلى التقييمات الميدانية'**
  String get wasalnyReportRatingDetail;

  /// No description provided for @wasalnyComplaintReference.
  ///
  /// In ar, this message translates to:
  /// **'الشكوى #CMP-1042'**
  String get wasalnyComplaintReference;

  /// No description provided for @wasalnyComplaintOpenStatus.
  ///
  /// In ar, this message translates to:
  /// **'قيد المتابعة'**
  String get wasalnyComplaintOpenStatus;

  /// No description provided for @wasalnyComplaintSubject.
  ///
  /// In ar, this message translates to:
  /// **'تأخر استلام شحنة بعد إتمام البيع'**
  String get wasalnyComplaintSubject;

  /// No description provided for @wasalnyComplaintDescription.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الشكوى وإحالتها للمراجعة. يجري حالياً التنسيق مع أطراف الطلب للتحقق من حالة الشحنة.'**
  String get wasalnyComplaintDescription;

  /// No description provided for @wasalnyComplaintReceived.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام الشكوى وتسجيلها'**
  String get wasalnyComplaintReceived;

  /// No description provided for @wasalnyComplaintUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'الشكوى قيد المراجعة من فريق وصلني'**
  String get wasalnyComplaintUnderReview;

  /// No description provided for @wasalnyComplaintWaitingAction.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الإجراء وتحديث الأطراف'**
  String get wasalnyComplaintWaitingAction;

  /// No description provided for @wasalnyComplaintsListIntro.
  ///
  /// In ar, this message translates to:
  /// **'اختر شكوى لمراجعة تفاصيلها وأطراف النزاع'**
  String get wasalnyComplaintsListIntro;

  /// No description provided for @wasalnyComplaintReferenceWithId.
  ///
  /// In ar, this message translates to:
  /// **'الشكوى #{id}'**
  String wasalnyComplaintReferenceWithId(String id);

  /// No description provided for @wasalnyComplaintOpenDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get wasalnyComplaintOpenDetails;

  /// No description provided for @wasalnyComplaintDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الشكوى'**
  String get wasalnyComplaintDetailsTitle;

  /// No description provided for @wasalnyComplaintDetailsSection.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الشكوى'**
  String get wasalnyComplaintDetailsSection;

  /// No description provided for @wasalnyComplaintRequestSection.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الطلب'**
  String get wasalnyComplaintRequestSection;

  /// No description provided for @wasalnyComplaintPartiesSection.
  ///
  /// In ar, this message translates to:
  /// **'أطراف النزاع'**
  String get wasalnyComplaintPartiesSection;

  /// No description provided for @wasalnyComplaintSeller.
  ///
  /// In ar, this message translates to:
  /// **'البائع'**
  String get wasalnyComplaintSeller;

  /// No description provided for @wasalnyComplaintBuyer.
  ///
  /// In ar, this message translates to:
  /// **'المشتري'**
  String get wasalnyComplaintBuyer;

  /// No description provided for @wasalnyComplaintRequest.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get wasalnyComplaintRequest;

  /// No description provided for @wasalnyComplaintAmount.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الصفقة'**
  String get wasalnyComplaintAmount;

  /// No description provided for @wasalnyComplaintCreatedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ تسجيل الشكوى'**
  String get wasalnyComplaintCreatedAt;

  /// No description provided for @wasalnyComplaintResolvedStatus.
  ///
  /// In ar, this message translates to:
  /// **'تم الحل وديًا'**
  String get wasalnyComplaintResolvedStatus;

  /// No description provided for @wasalnyComplaintEscalatedStatus.
  ///
  /// In ar, this message translates to:
  /// **'مصعّدة لرئيس المشرفين'**
  String get wasalnyComplaintEscalatedStatus;

  /// No description provided for @wasalnyComplaintResolveFriendly.
  ///
  /// In ar, this message translates to:
  /// **'تم حل الشكوى والنزاع وديًا'**
  String get wasalnyComplaintResolveFriendly;

  /// No description provided for @wasalnyComplaintEscalateHead.
  ///
  /// In ar, this message translates to:
  /// **'تصعيد الشكوى لرئيس المشرفين'**
  String get wasalnyComplaintEscalateHead;

  /// No description provided for @wasalnyComplaintEscalationSheetKicker.
  ///
  /// In ar, this message translates to:
  /// **'وحدة 03: تصعيد الشكوى للإدارة'**
  String get wasalnyComplaintEscalationSheetKicker;

  /// No description provided for @wasalnyComplaintEscalationSheetType.
  ///
  /// In ar, this message translates to:
  /// **'نوع النافذة: نافذة سفلية'**
  String get wasalnyComplaintEscalationSheetType;

  /// No description provided for @wasalnyComplaintEscalationSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إجراء تصعيد الشكوى'**
  String get wasalnyComplaintEscalationSheetTitle;

  /// No description provided for @wasalnyComplaintEscalationSheetSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تصعيد الشكوى لرئيس المشرفين'**
  String get wasalnyComplaintEscalationSheetSubtitle;

  /// No description provided for @wasalnyComplaintEscalationFileLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملف الشكوى الرقابي'**
  String get wasalnyComplaintEscalationFileLabel;

  /// No description provided for @wasalnyComplaintEscalationPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار تصعيد إداري'**
  String get wasalnyComplaintEscalationPending;

  /// No description provided for @wasalnyComplaintEscalationHeldAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الضمان المحتجز'**
  String get wasalnyComplaintEscalationHeldAmount;

  /// No description provided for @wasalnyComplaintEscalationNoHeldAmount.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مبلغ محتجز'**
  String get wasalnyComplaintEscalationNoHeldAmount;

  /// No description provided for @wasalnyComplaintEscalationPolicyTitle.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيات وضوابط اللجنة الرقابية'**
  String get wasalnyComplaintEscalationPolicyTitle;

  /// No description provided for @wasalnyComplaintEscalationPolicyBody.
  ///
  /// In ar, this message translates to:
  /// **'يتم رفع الشكوى لرئيس المشرفين لمراجعة الوقائع والأدلة المسجلة، واعتماد الإجراء الإداري المناسب وفق سياسات المنصة. لا يؤدي التصعيد إلى تغيير حالة المبلغ المحتجز.'**
  String get wasalnyComplaintEscalationPolicyBody;

  /// No description provided for @wasalnyComplaintEscalationAuditTrail.
  ///
  /// In ar, this message translates to:
  /// **'سجل النافذة موثق'**
  String get wasalnyComplaintEscalationAuditTrail;

  /// No description provided for @wasalnyComplaintEscalationEvidenceTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الشكوى والأدلة المسجلة'**
  String get wasalnyComplaintEscalationEvidenceTitle;

  /// No description provided for @wasalnyComplaintEscalationVerifiedLabel.
  ///
  /// In ar, this message translates to:
  /// **'بيانات موثقة'**
  String get wasalnyComplaintEscalationVerifiedLabel;

  /// No description provided for @wasalnyComplaintEscalationNoWarranty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات ضمان ميداني مسجلة.'**
  String get wasalnyComplaintEscalationNoWarranty;

  /// No description provided for @wasalnyComplaintEscalationConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد رفع تصعيد الشكوى رسمياً'**
  String get wasalnyComplaintEscalationConfirm;

  /// No description provided for @wasalnyComplaintBackToList.
  ///
  /// In ar, this message translates to:
  /// **'العودة لقائمة الشكاوى'**
  String get wasalnyComplaintBackToList;

  /// No description provided for @wasalnyComplaintCallSeller.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بالبائع'**
  String get wasalnyComplaintCallSeller;

  /// No description provided for @wasalnyComplaintCallBuyer.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بالمشتري'**
  String get wasalnyComplaintCallBuyer;

  /// No description provided for @wasalnyComplaintResolvedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل حل الشكوى وديًا'**
  String get wasalnyComplaintResolvedMessage;

  /// No description provided for @wasalnyComplaintEscalatedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تصعيد الشكوى لرئيس المشرفين'**
  String get wasalnyComplaintEscalatedMessage;

  /// No description provided for @wasalnyComplaintCallFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر بدء الاتصال من هذا الجهاز'**
  String get wasalnyComplaintCallFailed;

  /// No description provided for @wasalnyComplaintsLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الشكاوى'**
  String get wasalnyComplaintsLoadError;

  /// No description provided for @wasalnyComplaintsRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get wasalnyComplaintsRetry;

  /// No description provided for @wasalnyComplaintPartyUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير مرتبط بطرف'**
  String get wasalnyComplaintPartyUnavailable;

  /// No description provided for @wasalnyComplaintItem.
  ///
  /// In ar, this message translates to:
  /// **'السلعة'**
  String get wasalnyComplaintItem;

  /// No description provided for @wasalnyComplaintDealCode.
  ///
  /// In ar, this message translates to:
  /// **'رقم الصفقة'**
  String get wasalnyComplaintDealCode;

  /// No description provided for @wasalnyComplaintWarranty.
  ///
  /// In ar, this message translates to:
  /// **'الضمان الميداني'**
  String get wasalnyComplaintWarranty;

  /// No description provided for @wasalnyComplaintResolveNote.
  ///
  /// In ar, this message translates to:
  /// **'تم الاتفاق بين البائع والمشتري على حل ودي'**
  String get wasalnyComplaintResolveNote;

  /// No description provided for @wasalnyComplaintResolveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تسجيل الحل الودي'**
  String get wasalnyComplaintResolveFailed;

  /// No description provided for @wasalnyComplaintEscalationReason.
  ///
  /// In ar, this message translates to:
  /// **'تتطلب الشكوى مراجعة رئيس المشرفين'**
  String get wasalnyComplaintEscalationReason;

  /// No description provided for @wasalnyComplaintEscalationFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تصعيد الشكوى'**
  String get wasalnyComplaintEscalationFailed;

  /// No description provided for @wasalnyComplaintActionTakenStatus.
  ///
  /// In ar, this message translates to:
  /// **'تم اتخاذ إجراء'**
  String get wasalnyComplaintActionTakenStatus;

  /// No description provided for @wasalnyAuditComplaintResolved.
  ///
  /// In ar, this message translates to:
  /// **'حل شكوى وديًا'**
  String get wasalnyAuditComplaintResolved;

  /// No description provided for @wasalnyAuditComplaintEscalated.
  ///
  /// In ar, this message translates to:
  /// **'تصعيد شكوى لرئيس المشرفين'**
  String get wasalnyAuditComplaintEscalated;

  /// No description provided for @wasalnyAuditAdApproved.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد إعلان وصلني'**
  String get wasalnyAuditAdApproved;

  /// No description provided for @wasalnyAuditAdHidden.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء إعلان وصلني'**
  String get wasalnyAuditAdHidden;

  /// No description provided for @wasalnyAuditAdRejected.
  ///
  /// In ar, this message translates to:
  /// **'رفض إعلان وصلني'**
  String get wasalnyAuditAdRejected;

  /// No description provided for @wasalnyAuditAdSuspended.
  ///
  /// In ar, this message translates to:
  /// **'تعليق إعلان وصلني'**
  String get wasalnyAuditAdSuspended;

  /// No description provided for @wasalnyAuditAdEditRequested.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل إعلان وصلني'**
  String get wasalnyAuditAdEditRequested;

  /// No description provided for @wasalnyAuditContactRevealed.
  ///
  /// In ar, this message translates to:
  /// **'إظهار بيانات تواصل طلب'**
  String get wasalnyAuditContactRevealed;

  /// No description provided for @wasalnyAuditContactHidden.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء بيانات تواصل طلب'**
  String get wasalnyAuditContactHidden;

  /// No description provided for @wasalnyNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات وصلني'**
  String get wasalnyNotificationsTitle;

  /// No description provided for @wasalnyNotificationNewRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب وصلني جديد'**
  String get wasalnyNotificationNewRequest;

  /// No description provided for @wasalnyNotificationNewRequestDescription.
  ///
  /// In ar, this message translates to:
  /// **'يوجد طلب جديد بانتظار متابعة مرحلة التوصيل.'**
  String get wasalnyNotificationNewRequestDescription;

  /// No description provided for @wasalnyNotificationComplaint.
  ///
  /// In ar, this message translates to:
  /// **'تحديث على شكوى'**
  String get wasalnyNotificationComplaint;

  /// No description provided for @wasalnyNotificationComplaintDescription.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة الشكوى CMP-1042 وهي قيد المتابعة.'**
  String get wasalnyNotificationComplaintDescription;

  /// No description provided for @wasalnyNotificationInspection.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل فحص شحنة'**
  String get wasalnyNotificationInspection;

  /// No description provided for @wasalnyNotificationInspectionDescription.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل نتيجة فحص شحنة الطلب W-1038.'**
  String get wasalnyNotificationInspectionDescription;

  /// No description provided for @wasalnyPromotionSendToFinance.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمشرف المالي'**
  String get wasalnyPromotionSendToFinance;

  /// No description provided for @wasalnyPromotionSentToFinance.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الترويج للمشرف المالي للمراجعة.'**
  String get wasalnyPromotionSentToFinance;

  /// No description provided for @wasalnyPromotionFinancePending.
  ///
  /// In ar, this message translates to:
  /// **'لا يزال طلب الترويج بانتظار موافقة المشرف المالي.'**
  String get wasalnyPromotionFinancePending;

  /// No description provided for @wasalnyPromotionFinanceRequestType.
  ///
  /// In ar, this message translates to:
  /// **'طلب ترويج منتج'**
  String get wasalnyPromotionFinanceRequestType;

  /// No description provided for @wasalnyPromotionFinanceApprovalConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد اعتماد ترويج {beneficiary} بمبلغ {amount} وإحالته للإدارة لتنفيذ الخصم؟'**
  String wasalnyPromotionFinanceApprovalConfirmation(
      Object amount, Object beneficiary);

  /// No description provided for @wasalnyPromotionFinanceApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد طلب الترويج وإحالته للإدارة لتنفيذ الخصم.'**
  String get wasalnyPromotionFinanceApproved;

  /// No description provided for @wasalnyPromotionFinanceRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض طلب الترويج وإشعار مشرف وصلني بسبب الرفض.'**
  String get wasalnyPromotionFinanceRejected;

  /// No description provided for @wasalnyComplaintChatParty.
  ///
  /// In ar, this message translates to:
  /// **'دردشة مع الطرفين'**
  String get wasalnyComplaintChatParty;

  /// No description provided for @wasalnyRequestsMonthlyLimitTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل الحد الشهري'**
  String get wasalnyRequestsMonthlyLimitTitle;

  /// No description provided for @wasalnyRequestsMonthlyLimitMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم استخدام طلبَي إظهار البيانات لهذا المشتري هذا الشهر. يلزم الاشتراك في التطبيق لإظهار بيانات إضافية.'**
  String get wasalnyRequestsMonthlyLimitMessage;

  /// No description provided for @wasalnyPremiumCustomer.
  ///
  /// In ar, this message translates to:
  /// **'عميل مميز'**
  String get wasalnyPremiumCustomer;

  /// No description provided for @wasalnyPremiumAdChoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل الإعلان ضمن الباقة؟'**
  String get wasalnyPremiumAdChoiceTitle;

  /// No description provided for @wasalnyPremiumAdChoiceMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذا العميل مميز. هل يُحتسب الإعلان ضمن باقته أم يُعامل كإعلان ترويجي مدفوع؟'**
  String get wasalnyPremiumAdChoiceMessage;

  /// No description provided for @wasalnyPremiumAdIncluded.
  ///
  /// In ar, this message translates to:
  /// **'ضمن الباقة'**
  String get wasalnyPremiumAdIncluded;

  /// No description provided for @wasalnyPremiumAdPaid.
  ///
  /// In ar, this message translates to:
  /// **'إعلان ترويجي مدفوع'**
  String get wasalnyPremiumAdPaid;

  /// No description provided for @wasalnyHeadInboxTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصعيدات وصلني'**
  String get wasalnyHeadInboxTitle;

  /// No description provided for @wasalnyNotificationSourceFinance.
  ///
  /// In ar, this message translates to:
  /// **'المشرف المالي'**
  String get wasalnyNotificationSourceFinance;

  /// No description provided for @wasalnyNotificationSourceChief.
  ///
  /// In ar, this message translates to:
  /// **'رئيس المشرفين'**
  String get wasalnyNotificationSourceChief;

  /// No description provided for @wasalnyNotificationSourceWasalny.
  ///
  /// In ar, this message translates to:
  /// **'حساب وصلني'**
  String get wasalnyNotificationSourceWasalny;

  /// No description provided for @wasalnyNotificationEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات جديدة.'**
  String get wasalnyNotificationEmpty;

  /// No description provided for @wasalnyPromotionTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات ترويج منتجات وصلني'**
  String get wasalnyPromotionTitle;

  /// No description provided for @wasalnyPromotionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'راجع طلبات إبراز المنتجات المستعملة وتابع حالة كل طلب'**
  String get wasalnyPromotionSubtitle;

  /// No description provided for @wasalnyRequestsSafetyTitle.
  ///
  /// In ar, this message translates to:
  /// **'بروتوكول أمان وساطة وصلني'**
  String get wasalnyRequestsSafetyTitle;

  /// No description provided for @wasalnyRequestsSafetyDescription.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة طلبات وصلني من خلال إظهار بيانات التواصل فقط بعد تأكيد موافقة الطرفين.'**
  String get wasalnyRequestsSafetyDescription;

  /// No description provided for @wasalnyRequestsCompletionRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الإتمام'**
  String get wasalnyRequestsCompletionRate;

  /// No description provided for @wasalnyRequestsActiveDeals.
  ///
  /// In ar, this message translates to:
  /// **'صفقة نشطة'**
  String get wasalnyRequestsActiveDeals;

  /// No description provided for @wasalnyRequestsAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get wasalnyRequestsAll;

  /// No description provided for @wasalnyRequestsAwaitingApproval.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الموافقة'**
  String get wasalnyRequestsAwaitingApproval;

  /// No description provided for @wasalnyRequestsCommunication.
  ///
  /// In ar, this message translates to:
  /// **'جاري التواصل'**
  String get wasalnyRequestsCommunication;

  /// No description provided for @wasalnyRequestsUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get wasalnyRequestsUnderReview;

  /// No description provided for @wasalnyRequestsSold.
  ///
  /// In ar, this message translates to:
  /// **'تم البيع'**
  String get wasalnyRequestsSold;

  /// No description provided for @wasalnyRequestsDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل'**
  String get wasalnyRequestsDelivery;

  /// No description provided for @wasalnyRequestsInspection.
  ///
  /// In ar, this message translates to:
  /// **'الفحص الميداني'**
  String get wasalnyRequestsInspection;

  /// No description provided for @wasalnyRequestsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات في هذه المرحلة.'**
  String get wasalnyRequestsEmpty;

  /// No description provided for @wasalnyRequestsEstimatedValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة المقدرة'**
  String get wasalnyRequestsEstimatedValue;

  /// No description provided for @wasalnyRequestsSeller.
  ///
  /// In ar, this message translates to:
  /// **'البائع'**
  String get wasalnyRequestsSeller;

  /// No description provided for @wasalnyRequestsBuyer.
  ///
  /// In ar, this message translates to:
  /// **'المشتري'**
  String get wasalnyRequestsBuyer;

  /// No description provided for @wasalnyRequestsOrderNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get wasalnyRequestsOrderNumber;

  /// No description provided for @wasalnyRequestsCurrentStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة الحالية'**
  String get wasalnyRequestsCurrentStatus;

  /// No description provided for @wasalnyRequestsLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get wasalnyRequestsLocation;

  /// No description provided for @wasalnyRequestsRevealTitle.
  ///
  /// In ar, this message translates to:
  /// **'إظهار بيانات التواصل'**
  String get wasalnyRequestsRevealTitle;

  /// No description provided for @wasalnyRequestsRevealConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إظهار بيانات التواصل للطرفين في هذا الطلب؟'**
  String get wasalnyRequestsRevealConfirmation;

  /// No description provided for @wasalnyRequestsRevealAction.
  ///
  /// In ar, this message translates to:
  /// **'إظهار البيانات للمشتري'**
  String get wasalnyRequestsRevealAction;

  /// No description provided for @wasalnyRequestsHideData.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء البيانات'**
  String get wasalnyRequestsHideData;

  /// No description provided for @wasalnyRequestsPreviewAction.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الطلب'**
  String get wasalnyRequestsPreviewAction;

  /// No description provided for @wasalnyRequestsPreviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get wasalnyRequestsPreviewTitle;

  /// No description provided for @wasalnyAdsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات المنتجات المستعملة'**
  String get wasalnyAdsTitle;

  /// No description provided for @wasalnyAdsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'وحدة الرقابة والمطابقة الفنية'**
  String get wasalnyAdsSubtitle;

  /// No description provided for @wasalnyAdsPendingToday.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة'**
  String get wasalnyAdsPendingToday;

  /// No description provided for @wasalnyAdsApprovedToday.
  ///
  /// In ar, this message translates to:
  /// **'المعتمد اليوم'**
  String get wasalnyAdsApprovedToday;

  /// No description provided for @wasalnyAdsFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get wasalnyAdsFilterAll;

  /// No description provided for @wasalnyAdsFilterPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة'**
  String get wasalnyAdsFilterPending;

  /// No description provided for @wasalnyAdsFilterEdit.
  ///
  /// In ar, this message translates to:
  /// **'فحص وتعديل'**
  String get wasalnyAdsFilterEdit;

  /// No description provided for @wasalnyAdsFilterApproved.
  ///
  /// In ar, this message translates to:
  /// **'المعتمدة'**
  String get wasalnyAdsFilterApproved;

  /// No description provided for @wasalnyAdsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات ضمن هذا التصنيف.'**
  String get wasalnyAdsEmpty;

  /// No description provided for @wasalnyAdsAuditNote.
  ///
  /// In ar, this message translates to:
  /// **'تم تدقيق وتأمين جميع الإجراءات الرقابية بتسجيل التدقيق الإداري.'**
  String get wasalnyAdsAuditNote;

  /// No description provided for @wasalnyAdsLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل إعلانات وصلني.'**
  String get wasalnyAdsLoadError;

  /// No description provided for @wasalnyAdsUpdateError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديث حالة الإعلان.'**
  String get wasalnyAdsUpdateError;

  /// No description provided for @wasalnyAdsPendingStatus.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة'**
  String get wasalnyAdsPendingStatus;

  /// No description provided for @wasalnyAdsApprovedStatus.
  ///
  /// In ar, this message translates to:
  /// **'منشور - مسار وصلني نشط'**
  String get wasalnyAdsApprovedStatus;

  /// No description provided for @wasalnyAdsHiddenStatus.
  ///
  /// In ar, this message translates to:
  /// **'الإعلان مخفي'**
  String get wasalnyAdsHiddenStatus;

  /// No description provided for @wasalnyAdsRejectedStatus.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض - بانتظار تعديل البائع'**
  String get wasalnyAdsRejectedStatus;

  /// No description provided for @wasalnyAdsAwaitingApprovalStatus.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الموافقة'**
  String get wasalnyAdsAwaitingApprovalStatus;

  /// No description provided for @wasalnyAdsSuspendedStatus.
  ///
  /// In ar, this message translates to:
  /// **'الإعلان معلّق'**
  String get wasalnyAdsSuspendedStatus;

  /// No description provided for @wasalnyAdsEditRequestedStatus.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب تعديل الإعلان'**
  String get wasalnyAdsEditRequestedStatus;

  /// No description provided for @wasalnyAdsAcceptAction.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get wasalnyAdsAcceptAction;

  /// No description provided for @wasalnyAdsHideAction.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get wasalnyAdsHideAction;

  /// No description provided for @wasalnyAdsSuspendAction.
  ///
  /// In ar, this message translates to:
  /// **'تعليق الإعلان'**
  String get wasalnyAdsSuspendAction;

  /// No description provided for @wasalnyAdsRejectAction.
  ///
  /// In ar, this message translates to:
  /// **'رفض بسبب'**
  String get wasalnyAdsRejectAction;

  /// No description provided for @wasalnyAdsHideTitle.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الإعلان'**
  String get wasalnyAdsHideTitle;

  /// No description provided for @wasalnyAdsSuspendTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعليق الإعلان'**
  String get wasalnyAdsSuspendTitle;

  /// No description provided for @wasalnyAdsEditRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل الإعلان'**
  String get wasalnyAdsEditRequestTitle;

  /// No description provided for @wasalnyAdsRejectTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض الإعلان'**
  String get wasalnyAdsRejectTitle;

  /// No description provided for @wasalnyAdsHideReason.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سبب إخفاء الإعلان'**
  String get wasalnyAdsHideReason;

  /// No description provided for @wasalnyAdsSuspendReason.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سبب تعليق الإعلان'**
  String get wasalnyAdsSuspendReason;

  /// No description provided for @wasalnyAdsEditRequestReason.
  ///
  /// In ar, this message translates to:
  /// **'أدخل التعديلات المطلوبة من الناشر'**
  String get wasalnyAdsEditRequestReason;

  /// No description provided for @wasalnyAdsRejectReason.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سبب رفض الإعلان'**
  String get wasalnyAdsRejectReason;

  /// No description provided for @wasalnyAdsReasonRequired.
  ///
  /// In ar, this message translates to:
  /// **'السبب مطلوب لإكمال العملية.'**
  String get wasalnyAdsReasonRequired;

  /// No description provided for @wasalnyAdsApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الإعلان ونشره.'**
  String get wasalnyAdsApproved;

  /// No description provided for @wasalnyAdsHidden.
  ///
  /// In ar, this message translates to:
  /// **'تم إخفاء الإعلان.'**
  String get wasalnyAdsHidden;

  /// No description provided for @wasalnyAdsRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الإعلان.'**
  String get wasalnyAdsRejected;

  /// No description provided for @wasalnyAdsSuspended.
  ///
  /// In ar, this message translates to:
  /// **'تم تعليق الإعلان.'**
  String get wasalnyAdsSuspended;

  /// No description provided for @wasalnyAdsEditRequested.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب التعديل إلى الناشر.'**
  String get wasalnyAdsEditRequested;

  /// No description provided for @wasalnyAdDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل وفحص بيانات الإعلان المستعمل'**
  String get wasalnyAdDetailsTitle;

  /// No description provided for @wasalnyAdDetailsPermission.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية إشرافية مقيدة: تعديل البيانات الفنية فقط'**
  String get wasalnyAdDetailsPermission;

  /// No description provided for @wasalnyAdDetailsReadOnly.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المعلن ثابتة (للاطلاع فقط)'**
  String get wasalnyAdDetailsReadOnly;

  /// No description provided for @wasalnyAdDetailsSellerVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثق النفاذ'**
  String get wasalnyAdDetailsSellerVerified;

  /// No description provided for @wasalnyAdDetailsSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإدراج'**
  String get wasalnyAdDetailsSubmitted;

  /// No description provided for @wasalnyAdDetailsPriceMatch.
  ///
  /// In ar, this message translates to:
  /// **'القيمة الحالية عادلة جداً ومطابقة لنطاق السعر.'**
  String get wasalnyAdDetailsPriceMatch;

  /// No description provided for @wasalnyCategoryCamera.
  ///
  /// In ar, this message translates to:
  /// **'إلكترونيات وتصوير ‹ كاميرات احترافية'**
  String get wasalnyCategoryCamera;

  /// No description provided for @wasalnyCategoryConsole.
  ///
  /// In ar, this message translates to:
  /// **'ألعاب إلكترونية ‹ منصات ألعاب'**
  String get wasalnyCategoryConsole;

  /// No description provided for @wasalnyCategoryLaptop.
  ///
  /// In ar, this message translates to:
  /// **'إلكترونيات ‹ أجهزة كمبيوتر محمولة'**
  String get wasalnyCategoryLaptop;

  /// No description provided for @wasalnyCategoryBicycle.
  ///
  /// In ar, this message translates to:
  /// **'رياضة وترفيه ‹ دراجات'**
  String get wasalnyCategoryBicycle;

  /// No description provided for @wasalnyAdDetailsImageGallery.
  ///
  /// In ar, this message translates to:
  /// **'معرض صور المنتج المفحوص'**
  String get wasalnyAdDetailsImageGallery;

  /// No description provided for @wasalnyAdDetailsPhotosCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} من {total} مقبولة'**
  String wasalnyAdDetailsPhotosCount(Object count, Object total);

  /// No description provided for @wasalnyAdDetailsFront.
  ///
  /// In ar, this message translates to:
  /// **'هيكل الكاميرا الأمامي'**
  String get wasalnyAdDetailsFront;

  /// No description provided for @wasalnyAdDetailsControls.
  ///
  /// In ar, this message translates to:
  /// **'الشاشة وأزرار التحكم'**
  String get wasalnyAdDetailsControls;

  /// No description provided for @wasalnyAdDetailsLens.
  ///
  /// In ar, this message translates to:
  /// **'قاعدة العدسة والمستشعر'**
  String get wasalnyAdDetailsLens;

  /// No description provided for @wasalnyAdDetailsAddPhoto.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة توثيق'**
  String get wasalnyAdDetailsAddPhoto;

  /// No description provided for @wasalnyAdDetailsCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف والقسم المعتمد'**
  String get wasalnyAdDetailsCategory;

  /// No description provided for @wasalnyAdDetailsCategoryMatch.
  ///
  /// In ar, this message translates to:
  /// **'تمت مطابقة القسم آلياً وفق نوع المنتج المستعمل والفئة السعرية.'**
  String get wasalnyAdDetailsCategoryMatch;

  /// No description provided for @wasalnyAdDetailsPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر المعتمد للنشر'**
  String get wasalnyAdDetailsPrice;

  /// No description provided for @wasalnyAdDetailsPriceRange.
  ///
  /// In ar, this message translates to:
  /// **'نطاق السعر العادل'**
  String get wasalnyAdDetailsPriceRange;

  /// No description provided for @wasalnyAdDetailsDescription.
  ///
  /// In ar, this message translates to:
  /// **'الوصف المعتمد وتدقيق المحتوى'**
  String get wasalnyAdDetailsDescription;

  /// No description provided for @wasalnyAdDetailsAutoCheck.
  ///
  /// In ar, this message translates to:
  /// **'فحص تلقائي: نظيف وخالٍ من الكلمات المحظورة'**
  String get wasalnyAdDetailsAutoCheck;

  /// No description provided for @wasalnyAdDetailsCharacters.
  ///
  /// In ar, this message translates to:
  /// **'حرف'**
  String get wasalnyAdDetailsCharacters;

  /// No description provided for @wasalnyAdDetailsApprove.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد الإعلان للنشر'**
  String get wasalnyAdDetailsApprove;

  /// No description provided for @wasalnyAdDetailsRequestEdit.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل من الناشر'**
  String get wasalnyAdDetailsRequestEdit;

  /// No description provided for @wasalnyAdDetailsSuspend.
  ///
  /// In ar, this message translates to:
  /// **'تعليق الإعلان'**
  String get wasalnyAdDetailsSuspend;

  /// No description provided for @wasalnyAdDetailsReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض الإعلان ومخالفة المعايير'**
  String get wasalnyAdDetailsReject;

  /// No description provided for @wasalnyChatWithSeller.
  ///
  /// In ar, this message translates to:
  /// **'دردشة مع المعلن'**
  String get wasalnyChatWithSeller;

  /// No description provided for @wasalnyCallSeller.
  ///
  /// In ar, this message translates to:
  /// **'الاتصال بالمعلن'**
  String get wasalnyCallSeller;

  /// No description provided for @wasalnyChatOrCallSeller.
  ///
  /// In ar, this message translates to:
  /// **'دردشة مع المعلن أو الاتصال به'**
  String get wasalnyChatOrCallSeller;

  /// No description provided for @wasalnyContactSellerTitle.
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع الشخص المعلن'**
  String get wasalnyContactSellerTitle;

  /// No description provided for @wasalnyContactSellerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مباشرة مع المعلن لمناقشة تفاصيل الإعلان أو طلب توضيحات فنية'**
  String get wasalnyContactSellerSubtitle;

  /// No description provided for @wasalnyCallNow.
  ///
  /// In ar, this message translates to:
  /// **'اتصال الآن'**
  String get wasalnyCallNow;

  /// No description provided for @wasalnyCallingSeller.
  ///
  /// In ar, this message translates to:
  /// **'جاري الاتصال بالمعلن: {phone}'**
  String wasalnyCallingSeller(Object phone);

  /// No description provided for @wasalnyCopyPhone.
  ///
  /// In ar, this message translates to:
  /// **'نسخ رقم الهاتف'**
  String get wasalnyCopyPhone;

  /// No description provided for @wasalnyPhoneCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ رقم المعلن إلى الحافظة'**
  String get wasalnyPhoneCopied;

  /// No description provided for @wasalnySellerPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف المعلن'**
  String get wasalnySellerPhoneLabel;

  /// No description provided for @wasalnyAdsUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الإعلان.'**
  String get wasalnyAdsUpdated;

  /// No description provided for @wasalnyAdsReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإجراء'**
  String get wasalnyAdsReason;

  /// No description provided for @productComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قسم {section} قيد التجهيز'**
  String productComingSoon(Object section);

  /// No description provided for @productSupervisorWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، المشرف محمد'**
  String get productSupervisorWelcome;

  /// No description provided for @productReviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مشرف مراجعة المنتجات الجديدة'**
  String get productReviewSubtitle;

  /// No description provided for @productPendingAdsCount.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة'**
  String get productPendingAdsCount;

  /// No description provided for @productApprovedAdsCount.
  ///
  /// In ar, this message translates to:
  /// **'إعلان معتمد'**
  String get productApprovedAdsCount;

  /// No description provided for @productSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث برقم الإعلان أو عنوان المنتج...'**
  String get productSearchHint;

  /// No description provided for @productCategoryAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get productCategoryAll;

  /// No description provided for @productCategoryHome.
  ///
  /// In ar, this message translates to:
  /// **'أجهزة منزلية'**
  String get productCategoryHome;

  /// No description provided for @productCategoryElectronics.
  ///
  /// In ar, this message translates to:
  /// **'إلكترونيات'**
  String get productCategoryElectronics;

  /// No description provided for @productCategoryWatches.
  ///
  /// In ar, this message translates to:
  /// **'عطور وساعات'**
  String get productCategoryWatches;

  /// No description provided for @productReviewListTitle.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات الجديدة قيد المراجعة'**
  String get productReviewListTitle;

  /// No description provided for @productReceivedMinutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String productReceivedMinutesAgo(int count);

  /// No description provided for @productConditionNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد بالكرتون'**
  String get productConditionNew;

  /// No description provided for @productConditionUsed.
  ///
  /// In ar, this message translates to:
  /// **'غير مستخدم'**
  String get productConditionUsed;

  /// No description provided for @productAcceptAction.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get productAcceptAction;

  /// No description provided for @productHideAction.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get productHideAction;

  /// No description provided for @productRejectAction.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get productRejectAction;

  /// No description provided for @productSuspendAction.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get productSuspendAction;

  /// No description provided for @productSuspendConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تعليق الإعلان'**
  String get productSuspendConfirmTitle;

  /// No description provided for @productSuspendConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تعليق «{title}» وإيقاف ظهوره مؤقتًا؟'**
  String productSuspendConfirmMessage(String title);

  /// No description provided for @productStatusSuspended.
  ///
  /// In ar, this message translates to:
  /// **'تم التعليق'**
  String get productStatusSuspended;

  /// No description provided for @productFeaturedBadge.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مميز'**
  String get productFeaturedBadge;

  /// No description provided for @productSuspendSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإجراء الرقابي'**
  String get productSuspendSheetTitle;

  /// No description provided for @productSuspendSheetSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلان #{reference} • {title}'**
  String productSuspendSheetSubtitle(String reference, String title);

  /// No description provided for @productSuspendChooseAction.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الحالة الرقابية الجديدة'**
  String get productSuspendChooseAction;

  /// No description provided for @productSuspendRepublish.
  ///
  /// In ar, this message translates to:
  /// **'إظهار وإعادة النشر (مفعل)'**
  String get productSuspendRepublish;

  /// No description provided for @productSuspendRepublishHint.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الظهور المباشر في سوق المنتجات الجديدة'**
  String get productSuspendRepublishHint;

  /// No description provided for @productSuspendHideTemporarily.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء مؤقت (تعليق الإعلان)'**
  String get productSuspendHideTemporarily;

  /// No description provided for @productSuspendHideTemporarilyHint.
  ///
  /// In ar, this message translates to:
  /// **'حجب مؤقت بانتظار استيفاء الشروط الرقابية'**
  String get productSuspendHideTemporarilyHint;

  /// No description provided for @productSuspendRejectFinal.
  ///
  /// In ar, this message translates to:
  /// **'رفض نهائي'**
  String get productSuspendRejectFinal;

  /// No description provided for @productSuspendRejectFinalHint.
  ///
  /// In ar, this message translates to:
  /// **'مخالفة المعايير الجديدة وإغلاق التذكرة فورًا'**
  String get productSuspendRejectFinalHint;

  /// No description provided for @productSuspendSelected.
  ///
  /// In ar, this message translates to:
  /// **'محدد'**
  String get productSuspendSelected;

  /// No description provided for @productSuspendCurrent.
  ///
  /// In ar, this message translates to:
  /// **'الحالي'**
  String get productSuspendCurrent;

  /// No description provided for @productSuspendReasonTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبب تغيير الحالة وملاحظات المعتمد'**
  String get productSuspendReasonTitle;

  /// No description provided for @productSuspendReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب الإجراء الرقابي...'**
  String get productSuspendReasonHint;

  /// No description provided for @productSuspendDefaultReason.
  ///
  /// In ar, this message translates to:
  /// **'تم استيفاء صور التغليف والتحقق بنجاح وإعادة تفعيل الإعلان'**
  String get productSuspendDefaultReason;

  /// No description provided for @productSuspendReasonNote.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر هذا التوضيح في سجل التدقيق'**
  String get productSuspendReasonNote;

  /// No description provided for @productSuspendNotifyTitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إشعار فوري للناشر'**
  String get productSuspendNotifyTitle;

  /// No description provided for @productSuspendNotifyHint.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه فوري عن التغيير والسبب المحدد للحالة'**
  String get productSuspendNotifyHint;

  /// No description provided for @productSuspendSaveAction.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وتحديث الحالة'**
  String get productSuspendSaveAction;

  /// No description provided for @productReviewImagesHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لمراجعة صور السلعة وفاتورة الشراء'**
  String get productReviewImagesHint;

  /// No description provided for @productAcceptConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد قبول المنتج'**
  String get productAcceptConfirmTitle;

  /// No description provided for @productAcceptConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد قبول «{title}» واعتماده للنشر؟'**
  String productAcceptConfirmMessage(Object title);

  /// No description provided for @productHideConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد إخفاء المنتج'**
  String get productHideConfirmTitle;

  /// No description provided for @productHideConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إخفاء «{title}» من قائمة المنتجات المعروضة؟'**
  String productHideConfirmMessage(Object title);

  /// No description provided for @productRejectConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد رفض المنتج'**
  String get productRejectConfirmTitle;

  /// No description provided for @productRejectReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سبب رفض المنتج'**
  String get productRejectReasonHint;

  /// No description provided for @productRejectReasonRequired.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض مطلوب لإكمال العملية'**
  String get productRejectReasonRequired;

  /// No description provided for @productHideReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سبب إخفاء المنتج'**
  String get productHideReasonHint;

  /// No description provided for @productHideReasonRequired.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإخفاء مطلوب لإكمال العملية'**
  String get productHideReasonRequired;

  /// No description provided for @productConfirmAction.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد العملية'**
  String get productConfirmAction;

  /// No description provided for @productCancelAction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get productCancelAction;

  /// No description provided for @productStatusApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم القبول'**
  String get productStatusApproved;

  /// No description provided for @productStatusHidden.
  ///
  /// In ar, this message translates to:
  /// **'تم الإخفاء'**
  String get productStatusHidden;

  /// No description provided for @productStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم الرفض'**
  String get productStatusRejected;

  /// No description provided for @productEmptyResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات مطابقة'**
  String get productEmptyResults;

  /// No description provided for @productReviewActionSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة المنتج'**
  String get productReviewActionSuccess;

  /// No description provided for @productReviewLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المنتجات قيد المراجعة. حاول مرة أخرى.'**
  String get productReviewLoadError;

  /// No description provided for @productReviewUpdateError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ قرار المنتج. حدّث الصفحة وحاول مرة أخرى.'**
  String get productReviewUpdateError;

  /// No description provided for @productDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة المنتج'**
  String get productDetailsTitle;

  /// No description provided for @productDetailsAppBarTitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض الإعلان'**
  String get productDetailsAppBarTitle;

  /// No description provided for @productDetailsInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة الشراء'**
  String get productDetailsInvoice;

  /// No description provided for @productDetailsPhotos.
  ///
  /// In ar, this message translates to:
  /// **'صور المنتج'**
  String get productDetailsPhotos;

  /// No description provided for @productDetailsMerchant.
  ///
  /// In ar, this message translates to:
  /// **'التاجر'**
  String get productDetailsMerchant;

  /// No description provided for @productDetailsPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get productDetailsPrice;

  /// No description provided for @productDetailsCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get productDetailsCategory;

  /// No description provided for @productDetailsCondition.
  ///
  /// In ar, this message translates to:
  /// **'حالة المنتج'**
  String get productDetailsCondition;

  /// No description provided for @productReviewSessionInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جلسة فحص ومراجعة نشطة'**
  String get productReviewSessionInProgress;

  /// No description provided for @productSellerLabel.
  ///
  /// In ar, this message translates to:
  /// **'المعلن:'**
  String get productSellerLabel;

  /// No description provided for @productSellerVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثق'**
  String get productSellerVerified;

  /// No description provided for @productViewFullAd.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل الإعلان الكاملة'**
  String get productViewFullAd;

  /// No description provided for @productViewFullAdHint.
  ///
  /// In ar, this message translates to:
  /// **'شاشة لمراجعة وتعديل تفاصيل الإعلان والوصف'**
  String get productViewFullAdHint;

  /// No description provided for @productInvoiceAttached.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة الشراء مرفقة'**
  String get productInvoiceAttached;

  /// No description provided for @productImageQualityChecked.
  ///
  /// In ar, this message translates to:
  /// **'جودة الصور مفحوصة'**
  String get productImageQualityChecked;

  /// No description provided for @productAuditChecklistTitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة التدقيق الإلزامي للمنتجات الجديدة:'**
  String get productAuditChecklistTitle;

  /// No description provided for @productAuditPackagingTitle.
  ///
  /// In ar, this message translates to:
  /// **'شريط الأمان والغلاف البلاستيكي سليم تماماً'**
  String get productAuditPackagingTitle;

  /// No description provided for @productAuditPackagingHint.
  ///
  /// In ar, this message translates to:
  /// **'تم فحص التغليف ولم يظهر أي تمزق أو إعادة إغلاق حراري.'**
  String get productAuditPackagingHint;

  /// No description provided for @productAuditSerialTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرقم التسلسلي مطابق للمواصفات المحلية'**
  String get productAuditSerialTitle;

  /// No description provided for @productAuditSerialHint.
  ///
  /// In ar, this message translates to:
  /// **'الباركود المسجل متطابق مع قاعدة بيانات الهيئة الرسمية.'**
  String get productAuditSerialHint;

  /// No description provided for @productAuditDescriptionTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد وصف يلمح لأي استخدام مسبق أو تجريبي'**
  String get productAuditDescriptionTitle;

  /// No description provided for @productAuditDescriptionHint.
  ///
  /// In ar, this message translates to:
  /// **'خلو نصوص الإعلان من عبارات مثل «مفتوح للتجربة» أو «شبه جديد».'**
  String get productAuditDescriptionHint;

  /// No description provided for @productInstantPublishingTitle.
  ///
  /// In ar, this message translates to:
  /// **'نشر تلقائي فوري'**
  String get productInstantPublishingTitle;

  /// No description provided for @productInstantPublishingHint.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد هذا الفحص سيقوم بنشر الإعلان مباشرة في السوق المفتوح. وإرسال إشعار رسمي للمعلن بانتهاء التدقيق.'**
  String get productInstantPublishingHint;

  /// No description provided for @productApproveAndPublishNow.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد ونشر فوراً'**
  String get productApproveAndPublishNow;

  /// No description provided for @productBackToReview.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق / رجوع'**
  String get productBackToReview;

  /// No description provided for @productFullDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل الإعلان'**
  String get productFullDetailsTitle;

  /// No description provided for @productPhotoDocumentationTitle.
  ///
  /// In ar, this message translates to:
  /// **'معاينة صور التوثيق والتغليف'**
  String get productPhotoDocumentationTitle;

  /// No description provided for @productPhotoCount.
  ///
  /// In ar, this message translates to:
  /// **'صور مرفوعة'**
  String get productPhotoCount;

  /// No description provided for @productPhotoAdOriginal.
  ///
  /// In ar, this message translates to:
  /// **'منتج جديد - مغلق أصلي'**
  String get productPhotoAdOriginal;

  /// No description provided for @productPhotoQualityCheck.
  ///
  /// In ar, this message translates to:
  /// **'فحص الملصق'**
  String get productPhotoQualityCheck;

  /// No description provided for @productSellerInquiryTitle.
  ///
  /// In ar, this message translates to:
  /// **'استفسار للمعلن'**
  String get productSellerInquiryTitle;

  /// No description provided for @productSellerInquiryHint.
  ///
  /// In ar, this message translates to:
  /// **'طلب توضيح أو إشعار المعلن بتعديل فوري'**
  String get productSellerInquiryHint;

  /// No description provided for @productSendInquiry.
  ///
  /// In ar, this message translates to:
  /// **'مراسلة'**
  String get productSendInquiry;

  /// No description provided for @productInquiryMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب استفسارك للمعلن...'**
  String get productInquiryMessageHint;

  /// No description provided for @productApprovedCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف المعتمد'**
  String get productApprovedCategory;

  /// No description provided for @productDescriptionAndCondition.
  ///
  /// In ar, this message translates to:
  /// **'وصف المنتج وحالته'**
  String get productDescriptionAndCondition;

  /// No description provided for @productWarrantyLabel.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صيغة الضمان'**
  String get productWarrantyLabel;

  /// No description provided for @productDescriptionHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب وصف المنتج وتفاصيل حالته...'**
  String get productDescriptionHint;

  /// No description provided for @productDescriptionCharacterCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} حرف'**
  String productDescriptionCharacterCount(int count);

  /// No description provided for @productDescriptionSafetyCheck.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق من خلو النص من الألفاظ المضللة'**
  String get productDescriptionSafetyCheck;

  /// No description provided for @productAdHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل حالة الإعلان'**
  String get productAdHistoryTitle;

  /// No description provided for @productHistoryOpenStatus.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get productHistoryOpenStatus;

  /// No description provided for @productHistoryCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الإعلان بواسطة المستخدم'**
  String get productHistoryCreated;

  /// No description provided for @productHistoryDocumentsAttached.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق صور التغليف والباركود'**
  String get productHistoryDocumentsAttached;

  /// No description provided for @productHistoryAssigned.
  ///
  /// In ar, this message translates to:
  /// **'إسناد الإعلان للمشرف الميداني'**
  String get productHistoryAssigned;

  /// No description provided for @productHistoryCurrent.
  ///
  /// In ar, this message translates to:
  /// **'الحالة الحالية: قيد فحص المواصفات والاستيفاءات'**
  String get productHistoryCurrent;

  /// No description provided for @productEditPermissionHint.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية التعديل الرقابي مقتصرة على التصنيف والسعر والوصف فقط. لا يمكن تغيير بيانات الناشر.'**
  String get productEditPermissionHint;

  /// No description provided for @productFinalDecisionLabel.
  ///
  /// In ar, this message translates to:
  /// **'قرار المشرف الإداري النهائي'**
  String get productFinalDecisionLabel;

  /// No description provided for @productRequiredFieldsError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى استكمال السعر والوصف قبل المتابعة.'**
  String get productRequiredFieldsError;

  /// No description provided for @productInvalidPriceError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعرًا صحيحًا بالأرقام.'**
  String get productInvalidPriceError;

  /// No description provided for @productWorkspaceComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'هذه الصفحة قيد التجهيز'**
  String get productWorkspaceComingSoon;

  /// No description provided for @productPromotionTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة ترويج المنتجات المميزة'**
  String get productPromotionTitle;

  /// No description provided for @productPromotionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'راجع طلبات إبراز المنتجات وتابع العروض النشطة'**
  String get productPromotionSubtitle;

  /// No description provided for @productPromotionPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار القرار'**
  String get productPromotionPending;

  /// No description provided for @productPromotionActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get productPromotionActive;

  /// No description provided for @productPromotionTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلبات'**
  String get productPromotionTotal;

  /// No description provided for @productPromotionRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الترويج'**
  String get productPromotionRequests;

  /// No description provided for @productPromotionFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get productPromotionFilterAll;

  /// No description provided for @productPromotionCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get productPromotionCompleted;

  /// No description provided for @productPromotionEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات ضمن هذا التصنيف.'**
  String get productPromotionEmpty;

  /// No description provided for @productPromotionPlanInfo.
  ///
  /// In ar, this message translates to:
  /// **'راجع أهلية الإعلان وحالة الدفع قبل تفعيل باقة الترويج. مدة الباقة تبدأ بعد الاعتماد.'**
  String get productPromotionPlanInfo;

  /// No description provided for @productPromotionFeaturedPlan.
  ///
  /// In ar, this message translates to:
  /// **'ظهور مميز'**
  String get productPromotionFeaturedPlan;

  /// No description provided for @productPromotionPremiumPlan.
  ///
  /// In ar, this message translates to:
  /// **'ظهور مميز بلس'**
  String get productPromotionPremiumPlan;

  /// No description provided for @productPromotionDays.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get productPromotionDays;

  /// No description provided for @productPromotionRequestedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الطلب:'**
  String get productPromotionRequestedAt;

  /// No description provided for @productPromotionDecisionNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة القرار'**
  String get productPromotionDecisionNote;

  /// No description provided for @productPromotionApprove.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد الترويج'**
  String get productPromotionApprove;

  /// No description provided for @productPromotionReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get productPromotionReject;

  /// No description provided for @productPromotionApproveTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد اعتماد الترويج'**
  String get productPromotionApproveTitle;

  /// No description provided for @productPromotionApproveMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد اعتماد طلب ترويج «{title}»؟'**
  String productPromotionApproveMessage(Object title);

  /// No description provided for @productPromotionConfirmApprove.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاعتماد'**
  String get productPromotionConfirmApprove;

  /// No description provided for @productPromotionPaymentStatusTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة الدفع'**
  String get productPromotionPaymentStatusTitle;

  /// No description provided for @productPromotionViewPaymentStatus.
  ///
  /// In ar, this message translates to:
  /// **'عرض حالة الدفع'**
  String get productPromotionViewPaymentStatus;

  /// No description provided for @productPromotionPaidByFinance.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد الدفع من المالية'**
  String get productPromotionPaidByFinance;

  /// No description provided for @productPromotionUnpaid.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم الدفع بعد'**
  String get productPromotionUnpaid;

  /// No description provided for @productPromotionUnpaidMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن اعتماد طلب الترويج قبل تأكيد المالية استلام المبلغ.'**
  String get productPromotionUnpaidMessage;

  /// No description provided for @productPromotionRejectTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض طلب الترويج'**
  String get productPromotionRejectTitle;

  /// No description provided for @productPromotionRejectReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب رفض الطلب'**
  String get productPromotionRejectReasonHint;

  /// No description provided for @productPromotionConfirmReject.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرفض'**
  String get productPromotionConfirmReject;

  /// No description provided for @productPromotionApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد طلب الترويج.'**
  String get productPromotionApproved;

  /// No description provided for @productPromotionRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض طلب الترويج.'**
  String get productPromotionRejected;

  /// No description provided for @productPromotionExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get productPromotionExpired;

  /// No description provided for @productPromotionDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الطلبات المعروضة تجريبية؛ يلزم ربطها بخدمة الاشتراكات والمدفوعات قبل التشغيل الفعلي.'**
  String get productPromotionDisclaimer;

  /// No description provided for @productPromotionAuditApproved.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد طلب ترويج منتج'**
  String get productPromotionAuditApproved;

  /// No description provided for @productPromotionAuditRejected.
  ///
  /// In ar, this message translates to:
  /// **'رفض طلب ترويج منتج'**
  String get productPromotionAuditRejected;

  /// No description provided for @productWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظة المشرف'**
  String get productWalletTitle;

  /// No description provided for @productWalletBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get productWalletBack;

  /// No description provided for @productWalletSupervisorId.
  ///
  /// In ar, this message translates to:
  /// **'SUP-9942'**
  String get productWalletSupervisorId;

  /// No description provided for @productWalletVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثق'**
  String get productWalletVerified;

  /// No description provided for @productWalletAvailableForWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح للسحب الفوري'**
  String get productWalletAvailableForWithdrawal;

  /// No description provided for @productWalletBalanceAmount.
  ///
  /// In ar, this message translates to:
  /// **'8,450 ر.س'**
  String get productWalletBalanceAmount;

  /// No description provided for @productWalletReady.
  ///
  /// In ar, this message translates to:
  /// **'نشط وجاهز'**
  String get productWalletReady;

  /// No description provided for @productWalletBalanceNote.
  ///
  /// In ar, this message translates to:
  /// **'يشمل مستحقات الإشراف المعتمدة وبدلات التدقيق المنتهية وجاهزة للتحويل الفوري.'**
  String get productWalletBalanceNote;

  /// No description provided for @productWalletTotalDues.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستحقات'**
  String get productWalletTotalDues;

  /// No description provided for @productWalletTotalDuesAmount.
  ///
  /// In ar, this message translates to:
  /// **'12,500 ر.س'**
  String get productWalletTotalDuesAmount;

  /// No description provided for @productWalletDuesDetail.
  ///
  /// In ar, this message translates to:
  /// **'الراتب + الحوافز المحققة'**
  String get productWalletDuesDetail;

  /// No description provided for @productWalletPendingReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد التدقيق المالي'**
  String get productWalletPendingReview;

  /// No description provided for @productWalletPendingAmount.
  ///
  /// In ar, this message translates to:
  /// **'4,050 ر.س'**
  String get productWalletPendingAmount;

  /// No description provided for @productWalletPendingDetail.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الفحص والمكافآت'**
  String get productWalletPendingDetail;

  /// No description provided for @productWalletSettlementRate.
  ///
  /// In ar, this message translates to:
  /// **'دورة تسوية أسبوعية منتظمة'**
  String get productWalletSettlementRate;

  /// No description provided for @productWalletSettlementPercent.
  ///
  /// In ar, this message translates to:
  /// **'معدل جاهزية الصرف: 68%'**
  String get productWalletSettlementPercent;

  /// No description provided for @productWalletRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب المستحقات المالية'**
  String get productWalletRequestTitle;

  /// No description provided for @productWalletNoFees.
  ///
  /// In ar, this message translates to:
  /// **'بدون رسوم تحويل'**
  String get productWalletNoFees;

  /// No description provided for @productWalletAmountToWithdraw.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ السحب المطلوب'**
  String get productWalletAmountToWithdraw;

  /// No description provided for @productWalletWithdrawableHint.
  ///
  /// In ar, this message translates to:
  /// **'سحب كامل المبلغ المتاح (8,450 ر.س)'**
  String get productWalletWithdrawableHint;

  /// No description provided for @productWalletCurrency.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get productWalletCurrency;

  /// No description provided for @productWalletLimitNote.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى لعملية السحب 100 ر.س، الحد الأقصى اليومي 20,000 ر.س.'**
  String get productWalletLimitNote;

  /// No description provided for @productWalletChooseDestination.
  ///
  /// In ar, this message translates to:
  /// **'اختر وجهة التحويل'**
  String get productWalletChooseDestination;

  /// No description provided for @productWalletInstapay.
  ///
  /// In ar, this message translates to:
  /// **'إنستاباي'**
  String get productWalletInstapay;

  /// No description provided for @productWalletFast.
  ///
  /// In ar, this message translates to:
  /// **'فوري'**
  String get productWalletFast;

  /// No description provided for @productWalletMobileWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة هاتف'**
  String get productWalletMobileWallet;

  /// No description provided for @productWalletWalletProviders.
  ///
  /// In ar, this message translates to:
  /// **'فودافون / أورنج'**
  String get productWalletWalletProviders;

  /// No description provided for @productWalletBankTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get productWalletBankTransfer;

  /// No description provided for @productWalletIban.
  ///
  /// In ar, this message translates to:
  /// **'آيبان (IBAN)'**
  String get productWalletIban;

  /// No description provided for @productWalletIbanAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الدفع اللحظي (IPA) أو رقم الآيبان المصرفي'**
  String get productWalletIbanAddress;

  /// No description provided for @productWalletPaymentAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الدفع اللحظي (IPA) أو رقم الهاتف المرتبط'**
  String get productWalletPaymentAddress;

  /// No description provided for @productWalletProcessingTime.
  ///
  /// In ar, this message translates to:
  /// **'سرعة المعالجة: فوري ومباشر على مدار الساعة'**
  String get productWalletProcessingTime;

  /// No description provided for @productWalletFeeDetails.
  ///
  /// In ar, this message translates to:
  /// **'رسوم المعالجة والتحويل: 0.5 ر.س (محفظة بالكامل للمشرف)'**
  String get productWalletFeeDetails;

  /// No description provided for @productWalletSubmitRequest.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد وطلب السحب المالي'**
  String get productWalletSubmitRequest;

  /// No description provided for @productWalletAmountError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغاً بين 100 و8,450 ر.س.'**
  String get productWalletAmountError;

  /// No description provided for @productWalletDetailsError.
  ///
  /// In ar, this message translates to:
  /// **'أكمل بيانات الحساب قبل إرسال طلب السحب.'**
  String get productWalletDetailsError;

  /// No description provided for @productWalletConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد طلب السحب'**
  String get productWalletConfirmTitle;

  /// No description provided for @productWalletConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تأكيد سحب مبلغ {amount} ر.س؟'**
  String productWalletConfirmMessage(Object amount);

  /// No description provided for @productWalletConfirmAction.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد السحب'**
  String get productWalletConfirmAction;

  /// No description provided for @productWalletRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل طلب السحب بنجاح.'**
  String get productWalletRequestSent;

  /// No description provided for @productWalletBonusTitle.
  ///
  /// In ar, this message translates to:
  /// **'حافز الإنجاز الأسبوعي متاح!'**
  String get productWalletBonusTitle;

  /// No description provided for @productWalletBonusAmount.
  ///
  /// In ar, this message translates to:
  /// **'+500 ر.س'**
  String get productWalletBonusAmount;

  /// No description provided for @productWalletBonusDescription.
  ///
  /// In ar, this message translates to:
  /// **'أنجزت 4 من 5 أهداف ميدانياً بنجاح يفوق المعايير المحددة.'**
  String get productWalletBonusDescription;

  /// No description provided for @productWalletHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات والتحويلات الأخيرة'**
  String get productWalletHistoryTitle;

  /// No description provided for @productWalletFullStatement.
  ///
  /// In ar, this message translates to:
  /// **'عرض كشف الحساب الكامل'**
  String get productWalletFullStatement;

  /// No description provided for @productWalletTransactionOne.
  ///
  /// In ar, this message translates to:
  /// **'سحب بنكي - مصرف الراجحي'**
  String get productWalletTransactionOne;

  /// No description provided for @productWalletTransactionOneMeta.
  ///
  /// In ar, this message translates to:
  /// **'TRX-9821 • أمس، 02:40 م'**
  String get productWalletTransactionOneMeta;

  /// No description provided for @productWalletTransactionOneAmount.
  ///
  /// In ar, this message translates to:
  /// **'-5,000'**
  String get productWalletTransactionOneAmount;

  /// No description provided for @productWalletTransactionTwo.
  ///
  /// In ar, this message translates to:
  /// **'عمولة فحص ميداني معتمد'**
  String get productWalletTransactionTwo;

  /// No description provided for @productWalletTransactionTwoMeta.
  ///
  /// In ar, this message translates to:
  /// **'أجهزة إلكترونية • WS-4088 • 24 أكتوبر'**
  String get productWalletTransactionTwoMeta;

  /// No description provided for @productWalletTransactionTwoAmount.
  ///
  /// In ar, this message translates to:
  /// **'+350'**
  String get productWalletTransactionTwoAmount;

  /// No description provided for @productWalletTransactionThree.
  ///
  /// In ar, this message translates to:
  /// **'تحويل فوري - InstaPay'**
  String get productWalletTransactionThree;

  /// No description provided for @productWalletTransactionThreeMeta.
  ///
  /// In ar, this message translates to:
  /// **'IPA-3310 • 21 أكتوبر'**
  String get productWalletTransactionThreeMeta;

  /// No description provided for @productWalletTransactionThreeAmount.
  ///
  /// In ar, this message translates to:
  /// **'-2,200'**
  String get productWalletTransactionThreeAmount;

  /// No description provided for @productWalletPaid.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get productWalletPaid;

  /// No description provided for @productWalletDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع'**
  String get productWalletDeposit;

  /// No description provided for @productWalletAuditTitle.
  ///
  /// In ar, this message translates to:
  /// **'العمليات المالية مشفرة وتخضع لتدقيق هيئة الرقابة المحاسبية لمنصة وسوقي'**
  String get productWalletAuditTitle;

  /// No description provided for @productWalletAuditCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التدقيق الدوري: AUDIT-SEC-2024-v9'**
  String get productWalletAuditCode;

  /// No description provided for @productWalletStatementUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'سيتم عرض تفاصيل كشف الحساب عند ربط المحفظة بالخدمات المالية.'**
  String get productWalletStatementUnavailable;

  /// No description provided for @productSupervisorToolsTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل المشرف والمساندة'**
  String get productSupervisorToolsTitle;

  /// No description provided for @productAuditHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل القرارات والتدقيق الرقابي'**
  String get productAuditHistoryTitle;

  /// No description provided for @productAuditHistorySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة سجل قراراتك وإجراءاتك السابقة'**
  String get productAuditHistorySubtitle;

  /// No description provided for @productAuditEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات مسجلة حتى الآن.'**
  String get productAuditEmpty;

  /// No description provided for @productAuditLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل سجل التدقيق. حاول مرة أخرى.'**
  String get productAuditLoadError;

  /// No description provided for @productAuditSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ العملية في سجل التدقيق. لم يتم تسجيل الطلب.'**
  String get productAuditSaveError;

  /// No description provided for @productAuditActionApproved.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد منتج'**
  String get productAuditActionApproved;

  /// No description provided for @productAuditActionHidden.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء منتج'**
  String get productAuditActionHidden;

  /// No description provided for @productAuditActionRejected.
  ///
  /// In ar, this message translates to:
  /// **'رفض منتج'**
  String get productAuditActionRejected;

  /// No description provided for @productAuditActionSuspended.
  ///
  /// In ar, this message translates to:
  /// **'تعليق إعلان'**
  String get productAuditActionSuspended;

  /// No description provided for @productAuditActionUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تعديل تفاصيل منتج'**
  String get productAuditActionUpdated;

  /// No description provided for @productAuditActionFieldAvailability.
  ///
  /// In ar, this message translates to:
  /// **'تغيير التوفر الميداني'**
  String get productAuditActionFieldAvailability;

  /// No description provided for @productAuditActionUrgentNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تغيير تنبيهات البلاغات العاجلة'**
  String get productAuditActionUrgentNotifications;

  /// No description provided for @productAuditEnabled.
  ///
  /// In ar, this message translates to:
  /// **'تم التفعيل'**
  String get productAuditEnabled;

  /// No description provided for @productAuditDisabled.
  ///
  /// In ar, this message translates to:
  /// **'تم التعطيل'**
  String get productAuditDisabled;

  /// No description provided for @productAuditActionWithdrawalRequested.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب مستحقات مالية'**
  String get productAuditActionWithdrawalRequested;

  /// No description provided for @productAuditActionOther.
  ///
  /// In ar, this message translates to:
  /// **'إجراء رقابي'**
  String get productAuditActionOther;

  /// No description provided for @productSupportTitle.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساندة والدعم'**
  String get productSupportTitle;

  /// No description provided for @productSupportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الإداري والتقني والتواصل مع رئيس المشرفين'**
  String get productSupportSubtitle;

  /// No description provided for @productAdminSupportTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الإداري'**
  String get productAdminSupportTitle;

  /// No description provided for @productAdminSupportDetail.
  ///
  /// In ar, this message translates to:
  /// **'استفسارات الإجراءات والسياسات والتصعيد الإداري'**
  String get productAdminSupportDetail;

  /// No description provided for @productTechnicalSupportTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدعم التقني'**
  String get productTechnicalSupportTitle;

  /// No description provided for @productTechnicalSupportDetail.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة في مشكلات التطبيق والحساب والأدوات'**
  String get productTechnicalSupportDetail;

  /// No description provided for @productSupportContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع فريق الدعم'**
  String get productSupportContactTitle;

  /// No description provided for @productHeadSupervisorName.
  ///
  /// In ar, this message translates to:
  /// **'رئيس المشرفين'**
  String get productHeadSupervisorName;

  /// No description provided for @productHeadSupervisorRole.
  ///
  /// In ar, this message translates to:
  /// **'التصعيد والمتابعة الإدارية'**
  String get productHeadSupervisorRole;

  /// No description provided for @productTechnicalSupportName.
  ///
  /// In ar, this message translates to:
  /// **'فريق الدعم التقني'**
  String get productTechnicalSupportName;

  /// No description provided for @productTechnicalSupportHours.
  ///
  /// In ar, this message translates to:
  /// **'متاح لمتابعة الأعطال التقنية'**
  String get productTechnicalSupportHours;

  /// No description provided for @productSupportOpenChat.
  ///
  /// In ar, this message translates to:
  /// **'بدء محادثة'**
  String get productSupportOpenChat;

  /// No description provided for @productSupportHours.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم عبر المحادثة، وتظهر ساعات العمل وفق الجدول المعتمد.'**
  String get productSupportHours;

  /// No description provided for @productChatsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدردشات'**
  String get productChatsTitle;

  /// No description provided for @productChatToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get productChatToday;

  /// No description provided for @productChatYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get productChatYesterday;

  /// No description provided for @productHeadSupervisorPreview.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إرسال الاستفسارات وطلبات التصعيد هنا.'**
  String get productHeadSupervisorPreview;

  /// No description provided for @productTechnicalSupportPreview.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا للمساعدة التقنية.'**
  String get productTechnicalSupportPreview;

  /// No description provided for @productNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get productNotificationsTitle;

  /// No description provided for @productNotificationsMarkAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get productNotificationsMarkAllRead;

  /// No description provided for @productNotificationNewReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات جديدة قيد المراجعة'**
  String get productNotificationNewReviewTitle;

  /// No description provided for @productNotificationNewReviewBody.
  ///
  /// In ar, this message translates to:
  /// **'توجد منتجات جديدة بانتظار إجراء المراجعة.'**
  String get productNotificationNewReviewBody;

  /// No description provided for @productNotificationWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المستحقات المالية'**
  String get productNotificationWalletTitle;

  /// No description provided for @productNotificationWalletBody.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث ملخص مستحقاتك ودورة التسوية الأسبوعية.'**
  String get productNotificationWalletBody;

  /// No description provided for @productNotificationPolicyTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه رقابي'**
  String get productNotificationPolicyTitle;

  /// No description provided for @productNotificationPolicyBody.
  ///
  /// In ar, this message translates to:
  /// **'يرجى مراجعة قائمة التدقيق قبل اعتماد المنتجات.'**
  String get productNotificationPolicyBody;

  /// No description provided for @productNotificationToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get productNotificationToday;

  /// No description provided for @productNotificationYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get productNotificationYesterday;

  /// No description provided for @productNotificationEarlier.
  ///
  /// In ar, this message translates to:
  /// **'سابقاً'**
  String get productNotificationEarlier;

  /// No description provided for @productReportEyebrow.
  ///
  /// In ar, this message translates to:
  /// **'الرقابة والجودة التنفيذية'**
  String get productReportEyebrow;

  /// No description provided for @productReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقارير قسم المنتجات الجديدة'**
  String get productReportTitle;

  /// No description provided for @productReportExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get productReportExport;

  /// No description provided for @productReportToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get productReportToday;

  /// No description provided for @productReportThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get productReportThisWeek;

  /// No description provided for @productReportThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get productReportThisMonth;

  /// No description provided for @productReportCustom.
  ///
  /// In ar, this message translates to:
  /// **'مخصص'**
  String get productReportCustom;

  /// No description provided for @productReportReviewedAds.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات المفحوصة'**
  String get productReportReviewedAds;

  /// No description provided for @productReportComparedToPrevious.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة بالفترة السابقة'**
  String get productReportComparedToPrevious;

  /// No description provided for @productReportApprovalRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل الاعتماد'**
  String get productReportApprovalRate;

  /// No description provided for @productReportApprovedCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} إعلان معتمد'**
  String productReportApprovedCount(int count);

  /// No description provided for @productReportDeclinedRate.
  ///
  /// In ar, this message translates to:
  /// **'الحجب والرفض'**
  String get productReportDeclinedRate;

  /// No description provided for @productReportDeclinedCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} إعلان محجوب'**
  String productReportDeclinedCount(int count);

  /// No description provided for @productReportAverageReview.
  ///
  /// In ar, this message translates to:
  /// **'متوسط سرعة الفحص'**
  String get productReportAverageReview;

  /// No description provided for @productReportMinutesAndFaster.
  ///
  /// In ar, this message translates to:
  /// **'أسرع بنسبة 25%'**
  String get productReportMinutesAndFaster;

  /// No description provided for @productReportMinuteUnit.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get productReportMinuteUnit;

  /// No description provided for @productReportStandardsTitle.
  ///
  /// In ar, this message translates to:
  /// **'معايير التحقق الصارمة للجديد'**
  String get productReportStandardsTitle;

  /// No description provided for @productReportStandardsVersion.
  ///
  /// In ar, this message translates to:
  /// **'بروتوكول 4.2'**
  String get productReportStandardsVersion;

  /// No description provided for @productReportPackagingTitle.
  ///
  /// In ar, this message translates to:
  /// **'شرط التغليف الحراري'**
  String get productReportPackagingTitle;

  /// No description provided for @productReportPackagingHint.
  ///
  /// In ar, this message translates to:
  /// **'التأكد من عدم فتح الشريط الأمني الأصلي'**
  String get productReportPackagingHint;

  /// No description provided for @productReportSerialTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق التسلسلي'**
  String get productReportSerialTitle;

  /// No description provided for @productReportSerialHint.
  ///
  /// In ar, this message translates to:
  /// **'فحص قاعدة بيانات الضمان المحلي المعتمد'**
  String get productReportSerialHint;

  /// No description provided for @productReportCategoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'توزيع أصناف المنتجات الجديدة'**
  String get productReportCategoryTitle;

  /// No description provided for @productReportAdsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} إعلان'**
  String productReportAdsCount(int count);

  /// No description provided for @productReportElectronics.
  ///
  /// In ar, this message translates to:
  /// **'إلكترونيات وهواتف ذكية'**
  String get productReportElectronics;

  /// No description provided for @productReportGames.
  ///
  /// In ar, this message translates to:
  /// **'أجهزة وألعاب ترفيهية'**
  String get productReportGames;

  /// No description provided for @productReportPerfumes.
  ///
  /// In ar, this message translates to:
  /// **'عطور وساعات فاخرة'**
  String get productReportPerfumes;

  /// No description provided for @productReportHomeAppliances.
  ///
  /// In ar, this message translates to:
  /// **'أجهزة منزلية ومطبخ'**
  String get productReportHomeAppliances;

  /// No description provided for @productReportAuditTitle.
  ///
  /// In ar, this message translates to:
  /// **'أحدث الإجراءات الرقابية المسجلة'**
  String get productReportAuditTitle;

  /// No description provided for @productReportLive.
  ///
  /// In ar, this message translates to:
  /// **'تحديث حي'**
  String get productReportLive;

  /// No description provided for @productReportHidden.
  ///
  /// In ar, this message translates to:
  /// **'تم الإخفاء'**
  String get productReportHidden;

  /// No description provided for @productReportApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم الاعتماد'**
  String get productReportApproved;

  /// No description provided for @productReportRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم الرفض'**
  String get productReportRejected;

  /// No description provided for @productReportActionHeadline.
  ///
  /// In ar, this message translates to:
  /// **'إعلان {adNumber}'**
  String productReportActionHeadline(String adNumber);

  /// No description provided for @productReportEditAction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإجراء'**
  String get productReportEditAction;

  /// No description provided for @productReportEditDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإجراء الرقابي'**
  String get productReportEditDialogTitle;

  /// No description provided for @productReportActionStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الإجراء'**
  String get productReportActionStatus;

  /// No description provided for @productReportActionReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإجراء'**
  String get productReportActionReason;

  /// No description provided for @productReportApplyEdit.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get productReportApplyEdit;

  /// No description provided for @productReportRecentActionsNote.
  ///
  /// In ar, this message translates to:
  /// **'هذه أحدث الإجراءات المسجلة في الفترة المحددة.'**
  String get productReportRecentActionsNote;

  /// No description provided for @productReportDataNote.
  ///
  /// In ar, this message translates to:
  /// **'بيانات عرض تجريبية تتغير حسب الفترة المحددة'**
  String get productReportDataNote;

  /// No description provided for @productReportSaveAndUpdate.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وتحديث الحالة فورًا'**
  String get productReportSaveAndUpdate;

  /// No description provided for @productReportDiscardChanges.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء والتراجع'**
  String get productReportDiscardChanges;

  /// No description provided for @productReportSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ تحديثات التقرير محليًا'**
  String get productReportSaved;

  /// No description provided for @productReportExportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقرير بصيغة CSV'**
  String get productReportExportTitle;

  /// No description provided for @productReportCopyCsv.
  ///
  /// In ar, this message translates to:
  /// **'نسخ CSV'**
  String get productReportCopyCsv;

  /// No description provided for @productReportExportCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ بيانات التقرير'**
  String get productReportExportCopied;

  /// No description provided for @productProfileMetricsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المؤشرات الرقابية والتشغيلية'**
  String get productProfileMetricsTitle;

  /// No description provided for @productProfileLastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: 12 دقيقة'**
  String get productProfileLastUpdated;

  /// No description provided for @productProfileName.
  ///
  /// In ar, this message translates to:
  /// **'م. طارق بن عبد العزيز العتيبي'**
  String get productProfileName;

  /// No description provided for @productProfileRegion.
  ///
  /// In ar, this message translates to:
  /// **'منطقة الرياض والمحافظات المجاورة'**
  String get productProfileRegion;

  /// No description provided for @productProfileSupervisorId.
  ///
  /// In ar, this message translates to:
  /// **'SUP-1082'**
  String get productProfileSupervisorId;

  /// No description provided for @productProfileVerified.
  ///
  /// In ar, this message translates to:
  /// **'مشرف ميداني معتمد'**
  String get productProfileVerified;

  /// No description provided for @productProfileFieldAvailability.
  ///
  /// In ar, this message translates to:
  /// **'متاح ميدانيًا لاستلام الفحص'**
  String get productProfileFieldAvailability;

  /// No description provided for @productProfileFieldAvailabilityHint.
  ///
  /// In ar, this message translates to:
  /// **'الاستجابة المباشرة ضمن نطاق 15 كم'**
  String get productProfileFieldAvailabilityHint;

  /// No description provided for @productProfilePreferenceLocalOnlyNotice.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ هذه الإعدادات على هذا الجهاز فقط؛ إرسال الإشعارات غير متصل حالياً.'**
  String get productProfilePreferenceLocalOnlyNotice;

  /// No description provided for @productProfilePreferenceLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الإعدادات المحفوظة. اضغط لإعادة المحاولة.'**
  String get productProfilePreferenceLoadError;

  /// No description provided for @productProfileReviewed.
  ///
  /// In ar, this message translates to:
  /// **'الصفقات المفحوصة'**
  String get productProfileReviewed;

  /// No description provided for @productProfileSinceLastMonth.
  ///
  /// In ar, this message translates to:
  /// **'+18% عن الشهر الماضي'**
  String get productProfileSinceLastMonth;

  /// No description provided for @productProfileApprovalMetric.
  ///
  /// In ar, this message translates to:
  /// **'التوفيق والحل الودي'**
  String get productProfileApprovalMetric;

  /// No description provided for @productProfileApprovedOfTotal.
  ///
  /// In ar, this message translates to:
  /// **'من أصل 263 نزاعًا مفتوحًا'**
  String get productProfileApprovedOfTotal;

  /// No description provided for @productProfileResponseSpeed.
  ///
  /// In ar, this message translates to:
  /// **'متوسط سرعة الاستجابة'**
  String get productProfileResponseSpeed;

  /// No description provided for @productProfileFasterThanAverage.
  ///
  /// In ar, this message translates to:
  /// **'أسرع بـ 6 دقائق من المعيار'**
  String get productProfileFasterThanAverage;

  /// No description provided for @productProfileQualityMetric.
  ///
  /// In ar, this message translates to:
  /// **'معدل الرضا الرقابي'**
  String get productProfileQualityMetric;

  /// No description provided for @productProfileQualityDetail.
  ///
  /// In ar, this message translates to:
  /// **'استنادًا إلى 210 تقييمًا فنيًا'**
  String get productProfileQualityDetail;

  /// No description provided for @productProfileDocumentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوثائق والتفويضات الإشرافية المعتمدة'**
  String get productProfileDocumentsTitle;

  /// No description provided for @productProfileAuthorization.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة الرقابة الميدانية'**
  String get productProfileAuthorization;

  /// No description provided for @productProfileAuthorizationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تفويض إشرافي نشط • ينتهي 15/06/1447 هـ'**
  String get productProfileAuthorizationSubtitle;

  /// No description provided for @productProfileActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get productProfileActive;

  /// No description provided for @productProfilePolicy.
  ///
  /// In ar, this message translates to:
  /// **'لائحة ضوابط وحجز الضمان'**
  String get productProfilePolicy;

  /// No description provided for @productProfilePolicySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار 4.2 المعتمد'**
  String get productProfilePolicySubtitle;

  /// No description provided for @productProfileDelegation.
  ///
  /// In ar, this message translates to:
  /// **'وثيقة صلاحيات حسم النزاع'**
  String get productProfileDelegation;

  /// No description provided for @productProfileDelegationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تفويض إشرافي مباشر'**
  String get productProfileDelegationSubtitle;

  /// No description provided for @productProfileReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get productProfileReview;

  /// No description provided for @productProfileWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظتي والبيانات المالية'**
  String get productProfileWalletTitle;

  /// No description provided for @productProfileJustUpdated.
  ///
  /// In ar, this message translates to:
  /// **'محدثة الآن'**
  String get productProfileJustUpdated;

  /// No description provided for @productProfileWalletBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح والمستحقات'**
  String get productProfileWalletBalance;

  /// No description provided for @productProfileWalletAmount.
  ///
  /// In ar, this message translates to:
  /// **'14,850 ر.س'**
  String get productProfileWalletAmount;

  /// No description provided for @productProfileWalletDetail.
  ///
  /// In ar, this message translates to:
  /// **'بدلات الإشراف الميداني + مستحقات التوفيق'**
  String get productProfileWalletDetail;

  /// No description provided for @productProfileOperationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات التشغيلية والمهام الميدانية'**
  String get productProfileOperationsTitle;

  /// No description provided for @productProfileUrgentAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات البلاغات العاجلة (VIP Dispatch)'**
  String get productProfileUrgentAlerts;

  /// No description provided for @productProfileUrgentAlertsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إشعار صوتي فوري لأولوية قصوى للنزاعات والاستلام'**
  String get productProfileUrgentAlertsSubtitle;

  /// No description provided for @productProfileAuditLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل القرارات والتدقيق الرقابي السابق'**
  String get productProfileAuditLog;

  /// No description provided for @productProfileAuditLogSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أرشيف محاضر التفتيش وإغلاق البلاغات المنجزة'**
  String get productProfileAuditLogSubtitle;

  /// No description provided for @productProfileAuditLogDetail.
  ///
  /// In ar, this message translates to:
  /// **'سجل القرارات الرقابية متاح للمراجعة من لوحة التقارير.'**
  String get productProfileAuditLogDetail;

  /// No description provided for @productProfileSupport.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساندة والدعم الإداري والتقني'**
  String get productProfileSupport;

  /// No description provided for @productProfileSupportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اتصال مباشر بمدير العمليات المركزية'**
  String get productProfileSupportSubtitle;

  /// No description provided for @productProfileSupportDetail.
  ///
  /// In ar, this message translates to:
  /// **'للحصول على المساندة، تواصل مع مدير العمليات المركزية عبر قنوات الدعم المعتمدة.'**
  String get productProfileSupportDetail;

  /// No description provided for @productProfileEndSession.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الجلسة الإشرافية وتسجيل الخروج'**
  String get productProfileEndSession;

  /// No description provided for @productProfileFooter.
  ///
  /// In ar, this message translates to:
  /// **'بوابة الرقابة الميدانية • تطبيق برواح المازوري للإدارة'**
  String get productProfileFooter;

  /// No description provided for @productProfileBuild.
  ///
  /// In ar, this message translates to:
  /// **'Build 2.9.44 - Auth Token Valid'**
  String get productProfileBuild;

  /// No description provided for @adsMerchantVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثق'**
  String get adsMerchantVerified;

  /// No description provided for @adsPhotoPosition.
  ///
  /// In ar, this message translates to:
  /// **'{current} من {total} صور'**
  String adsPhotoPosition(Object current, Object total);

  /// No description provided for @adsAdPhotoVerified.
  ///
  /// In ar, this message translates to:
  /// **'فحص الصورة'**
  String get adsAdPhotoVerified;

  /// No description provided for @adsIdentifier.
  ///
  /// In ar, this message translates to:
  /// **'معرف الإعلان: #{number}'**
  String adsIdentifier(Object number);

  /// No description provided for @adsAskingPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر المطلوب من التاجر'**
  String get adsAskingPrice;

  /// No description provided for @adsAdDescription.
  ///
  /// In ar, this message translates to:
  /// **'نص إعلان التاجر'**
  String get adsAdDescription;

  /// No description provided for @adsLicenseChecklist.
  ///
  /// In ar, this message translates to:
  /// **'قائمة التحقق النظامية للترخيص'**
  String get adsLicenseChecklist;

  /// No description provided for @adsChecklistCount.
  ///
  /// In ar, this message translates to:
  /// **'{passed} / {total} بنود'**
  String adsChecklistCount(int passed, int total);

  /// No description provided for @adsAutoHideReportsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء تلقائي عند ورود بلاغات'**
  String get adsAutoHideReportsTitle;

  /// No description provided for @adsAutoHideReportsDescription.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الإعلان مؤقتاً لحين إعادة التدقيق'**
  String get adsAutoHideReportsDescription;

  /// No description provided for @adsDeliveryTitle.
  ///
  /// In ar, this message translates to:
  /// **'مصاريف التوصيل والشحن الخاصة بالمنتج'**
  String get adsDeliveryTitle;

  /// No description provided for @adsDeliveryActive.
  ///
  /// In ar, this message translates to:
  /// **'خدمة مفعلة'**
  String get adsDeliveryActive;

  /// No description provided for @adsDeliveryDescription.
  ///
  /// In ar, this message translates to:
  /// **'خدمة التوصيل مطلوبة مع هذا الإعلان. يحق للمشرف تعديل رسوم التوصيل قبل الاعتماد أو الإخفاء.'**
  String get adsDeliveryDescription;

  /// No description provided for @adsDeliveryFee.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ ثابت (ر.س)'**
  String get adsDeliveryFee;

  /// No description provided for @adsUpdateDeliveryFee.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الرسوم'**
  String get adsUpdateDeliveryFee;

  /// No description provided for @adsDeliveryFeeNote.
  ///
  /// In ar, this message translates to:
  /// **'تم تدقيق وتعديل التوصيل وفق اللائحة'**
  String get adsDeliveryFeeNote;

  /// No description provided for @adsSupervisorDecision.
  ///
  /// In ar, this message translates to:
  /// **'قرار المشرف الإداري'**
  String get adsSupervisorDecision;

  /// No description provided for @adsSupervisorLevel.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية الاعتماد: المستوى 1'**
  String get adsSupervisorLevel;

  /// No description provided for @adsRequestEdit.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل بيانات'**
  String get adsRequestEdit;

  /// No description provided for @adsEditRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل بيانات الإعلان'**
  String get adsEditRequestTitle;

  /// No description provided for @adsEditRequestSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الملاحظات والتوجيهات المطلوبة من التاجر لتعديل الإعلان قبل النشر'**
  String get adsEditRequestSubtitle;

  /// No description provided for @adsEditRequestAdTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعلان: {title}'**
  String adsEditRequestAdTitle(Object title);

  /// No description provided for @adsEditRequestGuidanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات وتوجيهات المشرف للتاجر (إلزامي)'**
  String get adsEditRequestGuidanceTitle;

  /// No description provided for @adsEditRequestInstructions.
  ///
  /// In ar, this message translates to:
  /// **'يرجى توضيح جميع التفاصيل والبنود المطلوب تعديلها بوضوح لتوجيه التاجر مباشرة إلى ما يحتاج لتصحيحه قبل إعادة مراجعة الإعلان.'**
  String get adsEditRequestInstructions;

  /// No description provided for @adsEditRequestHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب التعديلات المطلوبة من التاجر...'**
  String get adsEditRequestHint;

  /// No description provided for @adsEditRequestRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب لإرسال طلب التعديل'**
  String get adsEditRequestRequired;

  /// No description provided for @adsEditRequestSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب التعديل للتاجر'**
  String get adsEditRequestSend;

  /// No description provided for @adsEditRequestCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء وتراجع'**
  String get adsEditRequestCancel;

  /// No description provided for @adsFeeUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث رسوم التوصيل'**
  String get adsFeeUpdated;

  /// No description provided for @adsFeeInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغاً صحيحاً غير سالب'**
  String get adsFeeInvalid;

  /// No description provided for @adsRequestEditUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل البيانات غير متاح حالياً'**
  String get adsRequestEditUnavailable;

  /// No description provided for @adsMileage.
  ///
  /// In ar, this message translates to:
  /// **'العداد الحالي'**
  String get adsMileage;

  /// No description provided for @adsExteriorColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون الخارجي'**
  String get adsExteriorColor;

  /// No description provided for @adsAccidentRecord.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الحوادث'**
  String get adsAccidentRecord;

  /// No description provided for @adsTransmission.
  ///
  /// In ar, this message translates to:
  /// **'ناقل الحركة'**
  String get adsTransmission;

  /// No description provided for @adsMileageValue.
  ///
  /// In ar, this message translates to:
  /// **'15,000 كم'**
  String get adsMileageValue;

  /// No description provided for @adsWhiteColorValue.
  ///
  /// In ar, this message translates to:
  /// **'أبيض لؤلؤي'**
  String get adsWhiteColorValue;

  /// No description provided for @adsNoAccidentsValue.
  ///
  /// In ar, this message translates to:
  /// **'خالٍ من الحوادث'**
  String get adsNoAccidentsValue;

  /// No description provided for @adsAutomaticValue.
  ///
  /// In ar, this message translates to:
  /// **'أوتوماتيك'**
  String get adsAutomaticValue;

  /// No description provided for @adsPhoneWarranty.
  ///
  /// In ar, this message translates to:
  /// **'الكفالة المحلية'**
  String get adsPhoneWarranty;

  /// No description provided for @adsPhoneCondition.
  ///
  /// In ar, this message translates to:
  /// **'حالة المنتج'**
  String get adsPhoneCondition;

  /// No description provided for @adsPhoneColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get adsPhoneColor;

  /// No description provided for @adsPhoneStorage.
  ///
  /// In ar, this message translates to:
  /// **'سعة التخزين'**
  String get adsPhoneStorage;

  /// No description provided for @adsWarrantyValue.
  ///
  /// In ar, this message translates to:
  /// **'5 سنوات'**
  String get adsWarrantyValue;

  /// No description provided for @adsNewConditionValue.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get adsNewConditionValue;

  /// No description provided for @adsNaturalTitaniumValue.
  ///
  /// In ar, this message translates to:
  /// **'تيتانيوم طبيعي'**
  String get adsNaturalTitaniumValue;

  /// No description provided for @adsStorageValue.
  ///
  /// In ar, this message translates to:
  /// **'256 جيجابايت'**
  String get adsStorageValue;

  /// No description provided for @adsVillaArea.
  ///
  /// In ar, this message translates to:
  /// **'مساحة الأرض'**
  String get adsVillaArea;

  /// No description provided for @adsVillaRooms.
  ///
  /// In ar, this message translates to:
  /// **'عدد الغرف'**
  String get adsVillaRooms;

  /// No description provided for @adsVillaLicense.
  ///
  /// In ar, this message translates to:
  /// **'الترخيص العقاري'**
  String get adsVillaLicense;

  /// No description provided for @adsVillaLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get adsVillaLocation;

  /// No description provided for @adsVillaAreaValue.
  ///
  /// In ar, this message translates to:
  /// **'375 م²'**
  String get adsVillaAreaValue;

  /// No description provided for @adsVillaRoomsValue.
  ///
  /// In ar, this message translates to:
  /// **'5 غرف نوم'**
  String get adsVillaRoomsValue;

  /// No description provided for @adsVillaLicensedValue.
  ///
  /// In ar, this message translates to:
  /// **'ساري وموثق'**
  String get adsVillaLicensedValue;

  /// No description provided for @adsVillaLocationValue.
  ///
  /// In ar, this message translates to:
  /// **'حي النرجس، الرياض'**
  String get adsVillaLocationValue;

  /// No description provided for @adsVehicleDescription.
  ///
  /// In ar, this message translates to:
  /// **'السيارة بحالة الوكالة، شبه جديدة، صيانة كاملة لدى الوكيل. جميع الصيانات الدورية تمت في مراكز مرسيدس المعتمدة. لا يوجد رش أو تعديل نهائياً.'**
  String get adsVehicleDescription;

  /// No description provided for @adsPhoneDescription.
  ///
  /// In ar, this message translates to:
  /// **'جهاز جديد غير مستخدم، بضمان محلي ساري، مع كامل الملحقات والفاتورة. تمت مطابقة الرقم التسلسلي والمواصفات مع المستندات المرفقة.'**
  String get adsPhoneDescription;

  /// No description provided for @adsVillaDescription.
  ///
  /// In ar, this message translates to:
  /// **'فيلا مودرن فاخرة بتصميم حديث وتشطيبات عالية الجودة، في موقع مميز قريب من الخدمات. رخصة البناء والوثائق العقارية متوفرة للمراجعة.'**
  String get adsVillaDescription;

  /// No description provided for @adsCheckPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر والشروط المالية متوافقة'**
  String get adsCheckPrice;

  /// No description provided for @adsCheckPhotos.
  ///
  /// In ar, this message translates to:
  /// **'الصور واقعية ومطابقة'**
  String get adsCheckPhotos;

  /// No description provided for @adsCheckSpecifications.
  ///
  /// In ar, this message translates to:
  /// **'تطابق المواصفات مع فحص السلامة'**
  String get adsCheckSpecifications;

  /// No description provided for @adsCheckMerchantLicense.
  ///
  /// In ar, this message translates to:
  /// **'سريان رخصة المعرض التجاري والمفوضين'**
  String get adsCheckMerchantLicense;

  /// No description provided for @adsCheckExpiryReminder.
  ///
  /// In ar, this message translates to:
  /// **'تنتهي بعد 90 يوماً - تذكير آلي مفعل'**
  String get adsCheckExpiryReminder;

  /// No description provided for @adsCheckReminder.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get adsCheckReminder;

  /// No description provided for @adsCheckReviewRecommended.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get adsCheckReviewRecommended;

  /// No description provided for @adsCheckPassed.
  ///
  /// In ar, this message translates to:
  /// **'مفحوص'**
  String get adsCheckPassed;

  /// No description provided for @finRequestReadOnlyNotice.
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات المالية من صلاحية المدير المالي فقط'**
  String get finRequestReadOnlyNotice;

  /// No description provided for @finRequestMerchantProceeds.
  ///
  /// In ar, this message translates to:
  /// **'مستحقات التجار المعلقة'**
  String get finRequestMerchantProceeds;

  /// No description provided for @finRequestTotalProceeds.
  ///
  /// In ar, this message translates to:
  /// **'142,500'**
  String get finRequestTotalProceeds;

  /// No description provided for @finRequestProceedsNote.
  ///
  /// In ar, this message translates to:
  /// **'ضمن نطاق إشرافك'**
  String get finRequestProceedsNote;

  /// No description provided for @finRequestReviewQueue.
  ///
  /// In ar, this message translates to:
  /// **'لدى الإدارة المالية'**
  String get finRequestReviewQueue;

  /// No description provided for @finRequestUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد التدقيق المالي'**
  String get finRequestUnderReview;

  /// No description provided for @finRequestHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات والمطالبات'**
  String get finRequestHistoryTitle;

  /// No description provided for @finRequestUpdatedJustNow.
  ///
  /// In ar, this message translates to:
  /// **'تحديث فوري'**
  String get finRequestUpdatedJustNow;

  /// No description provided for @finRequestAllFilter.
  ///
  /// In ar, this message translates to:
  /// **'الكل (3)'**
  String get finRequestAllFilter;

  /// No description provided for @finRequestSalesFilter.
  ///
  /// In ar, this message translates to:
  /// **'أرباح مبيعات'**
  String get finRequestSalesFilter;

  /// No description provided for @finRequestWithdrawalFilter.
  ///
  /// In ar, this message translates to:
  /// **'سحب أرصدة'**
  String get finRequestWithdrawalFilter;

  /// No description provided for @finRequestPackageFilter.
  ///
  /// In ar, this message translates to:
  /// **'رسوم باقات'**
  String get finRequestPackageFilter;

  /// No description provided for @finRequestNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات مطابقة لهذا التصنيف'**
  String get finRequestNoResults;

  /// No description provided for @finRequestCarMerchant.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة الأفق لتجارة السيارات'**
  String get finRequestCarMerchant;

  /// No description provided for @finRequestCarTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب تحويل أرباح مبيعات'**
  String get finRequestCarTitle;

  /// No description provided for @finRequestCarAmount.
  ///
  /// In ar, this message translates to:
  /// **'48,000'**
  String get finRequestCarAmount;

  /// No description provided for @finRequestTodayTime.
  ///
  /// In ar, this message translates to:
  /// **'اليوم، 10:45 ص'**
  String get finRequestTodayTime;

  /// No description provided for @finRequestBankVerified.
  ///
  /// In ar, this message translates to:
  /// **'حساب الآيبان مدقق ومعتمد ميدانياً'**
  String get finRequestBankVerified;

  /// No description provided for @finRequestPackageMerchant.
  ///
  /// In ar, this message translates to:
  /// **'متجر الصفوة للإلكترونيات'**
  String get finRequestPackageMerchant;

  /// No description provided for @finRequestPackageTitle.
  ///
  /// In ar, this message translates to:
  /// **'سداد رسوم اشتراك باقة ذهبية - سنوي'**
  String get finRequestPackageTitle;

  /// No description provided for @finRequestPackageAmount.
  ///
  /// In ar, this message translates to:
  /// **'3,500'**
  String get finRequestPackageAmount;

  /// No description provided for @finRequestYesterdayTime.
  ///
  /// In ar, this message translates to:
  /// **'أمس، 04:15 م'**
  String get finRequestYesterdayTime;

  /// No description provided for @finRequestCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل ومعتمد من المالية'**
  String get finRequestCompleted;

  /// No description provided for @finRequestApprovedByFinance.
  ///
  /// In ar, this message translates to:
  /// **'تم الاعتماد بواسطة: إدارة الحسابات العامة'**
  String get finRequestApprovedByFinance;

  /// No description provided for @finRequestJewelryMerchant.
  ///
  /// In ar, this message translates to:
  /// **'مجوهرات البريق'**
  String get finRequestJewelryMerchant;

  /// No description provided for @finRequestWithdrawalTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب رصيد محفظة'**
  String get finRequestWithdrawalTitle;

  /// No description provided for @finRequestWithdrawalAmount.
  ///
  /// In ar, this message translates to:
  /// **'22,000'**
  String get finRequestWithdrawalAmount;

  /// No description provided for @finRequestOlderTime.
  ///
  /// In ar, this message translates to:
  /// **'20 أكتوبر، 02:20 م'**
  String get finRequestOlderTime;

  /// No description provided for @finRequestAwaitingManager.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار موافقة المدير المالي'**
  String get finRequestAwaitingManager;

  /// No description provided for @finRequestSalesMatched.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة كشوفات المبيعات مكتملة'**
  String get finRequestSalesMatched;

  /// No description provided for @finRequestCurrency.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get finRequestCurrency;

  /// No description provided for @finRequestRestrictedStatus.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للمطابقة'**
  String get finRequestRestrictedStatus;

  /// No description provided for @finRequestSendToFinance.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمشرف المالي'**
  String get finRequestSendToFinance;

  /// No description provided for @finRequestViewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل الطلب'**
  String get finRequestViewDetails;

  /// No description provided for @finRequestPolicyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سياسة التدقيق المزدوج'**
  String get finRequestPolicyTitle;

  /// No description provided for @finRequestPolicyMessage.
  ///
  /// In ar, this message translates to:
  /// **'أي طلب مالي يتطلب اعتماداً نهائياً من الإدارة المالية. صلاحيات مشرف التجار للعرض والمتابعة فقط.'**
  String get finRequestPolicyMessage;

  /// No description provided for @finRequestNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get finRequestNumber;

  /// No description provided for @finRequestClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get finRequestClose;

  /// No description provided for @merchantProfileName.
  ///
  /// In ar, this message translates to:
  /// **'أحمد بن عبد العزيز الشهري'**
  String get merchantProfileName;

  /// No description provided for @merchantProfileRegion.
  ///
  /// In ar, this message translates to:
  /// **'مشرف تجار ميداني - منطقة الرياض'**
  String get merchantProfileRegion;

  /// No description provided for @merchantProfileSupervisorId.
  ///
  /// In ar, this message translates to:
  /// **'SUP-4092'**
  String get merchantProfileSupervisorId;

  /// No description provided for @merchantProfileActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط وموثق'**
  String get merchantProfileActive;

  /// No description provided for @merchantProfileMonthlyAds.
  ///
  /// In ar, this message translates to:
  /// **'إعلان هذا الشهر'**
  String get merchantProfileMonthlyAds;

  /// No description provided for @merchantProfileStores.
  ///
  /// In ar, this message translates to:
  /// **'تاجر نشط تحت إشرافك'**
  String get merchantProfileStores;

  /// No description provided for @withdrawalRequestDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل الطلب'**
  String get withdrawalRequestDetails;

  /// No description provided for @withdrawalDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل طلب السحب'**
  String get withdrawalDetailsTitle;

  /// No description provided for @withdrawalDetailsRequestNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get withdrawalDetailsRequestNumber;

  /// No description provided for @withdrawalDetailsBeneficiary.
  ///
  /// In ar, this message translates to:
  /// **'المستفيد'**
  String get withdrawalDetailsBeneficiary;

  /// No description provided for @withdrawalDetailsBeneficiaryRole.
  ///
  /// In ar, this message translates to:
  /// **'صفة المستفيد'**
  String get withdrawalDetailsBeneficiaryRole;

  /// No description provided for @withdrawalDetailsGrossAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبلغ'**
  String get withdrawalDetailsGrossAmount;

  /// No description provided for @withdrawalDetailsFeePercentage.
  ///
  /// In ar, this message translates to:
  /// **'نسبة العمولة'**
  String get withdrawalDetailsFeePercentage;

  /// No description provided for @withdrawalDetailsFeeAmount.
  ///
  /// In ar, this message translates to:
  /// **'قيمة العمولة'**
  String get withdrawalDetailsFeeAmount;

  /// No description provided for @withdrawalDetailsNetAmount.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبلغ المستحق'**
  String get withdrawalDetailsNetAmount;

  /// No description provided for @withdrawalDetailsBankName.
  ///
  /// In ar, this message translates to:
  /// **'البنك'**
  String get withdrawalDetailsBankName;

  /// No description provided for @withdrawalDetailsIban.
  ///
  /// In ar, this message translates to:
  /// **'رقم الآيبان'**
  String get withdrawalDetailsIban;

  /// No description provided for @withdrawalDetailsDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الطلب'**
  String get withdrawalDetailsDate;

  /// No description provided for @withdrawalDetailsAuditResult.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة الفحص'**
  String get withdrawalDetailsAuditResult;

  /// No description provided for @withdrawalDetailsAlert.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة رقابية'**
  String get withdrawalDetailsAlert;

  /// No description provided for @withdrawalDetailsSource.
  ///
  /// In ar, this message translates to:
  /// **'مصدر المستحقات'**
  String get withdrawalDetailsSource;

  /// No description provided for @withdrawalDetailsTransferMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة التحويل'**
  String get withdrawalDetailsTransferMethod;

  /// No description provided for @withdrawalDetailsInstantReady.
  ///
  /// In ar, this message translates to:
  /// **'متاح للتحويل الفوري'**
  String get withdrawalDetailsInstantReady;

  /// No description provided for @withdrawalDetailsStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get withdrawalDetailsStatusPending;

  /// No description provided for @withdrawalDetailsStatusInvestigation.
  ///
  /// In ar, this message translates to:
  /// **'قيد التحقيق والتدقيق'**
  String get withdrawalDetailsStatusInvestigation;

  /// No description provided for @withdrawalDetailsStatusApproved.
  ///
  /// In ar, this message translates to:
  /// **'معتمد'**
  String get withdrawalDetailsStatusApproved;

  /// No description provided for @withdrawalDetailsStatusFrozen.
  ///
  /// In ar, this message translates to:
  /// **'مجمّد'**
  String get withdrawalDetailsStatusFrozen;

  /// No description provided for @withdrawalDetailsStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get withdrawalDetailsStatusRejected;

  /// No description provided for @withdrawalDetailsNoValue.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get withdrawalDetailsNoValue;

  /// No description provided for @merchantProfileDocumentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملفات والمستندات الرقابية المعتمدة'**
  String get merchantProfileDocumentsTitle;

  /// No description provided for @merchantProfileAuthorizationCard.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة التفويض الإشرافي الميداني'**
  String get merchantProfileAuthorizationCard;

  /// No description provided for @merchantProfileValidUntil.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية حتى 31 ديسمبر 2025'**
  String get merchantProfileValidUntil;

  /// No description provided for @merchantProfileOpenDocument.
  ///
  /// In ar, this message translates to:
  /// **'استعراض البطاقة'**
  String get merchantProfileOpenDocument;

  /// No description provided for @merchantProfileGovernanceGuide.
  ///
  /// In ar, this message translates to:
  /// **'دليل معايير اعتماد الإعلانات'**
  String get merchantProfileGovernanceGuide;

  /// No description provided for @merchantProfileGuideSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اللوائح الإعلانية والضوابط التنظيمية'**
  String get merchantProfileGuideSubtitle;

  /// No description provided for @merchantProfileDelegationDocument.
  ///
  /// In ar, this message translates to:
  /// **'وثيقة تفويض الصلاحيات للإدارة'**
  String get merchantProfileDelegationDocument;

  /// No description provided for @merchantProfileDelegationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الامتثال القانوني ومصفوفة القرارات'**
  String get merchantProfileDelegationSubtitle;

  /// No description provided for @merchantProfileFieldPermissions.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الاتصال والصلاحيات الميدانية'**
  String get merchantProfileFieldPermissions;

  /// No description provided for @merchantProfileUpdatedAutomatically.
  ///
  /// In ar, this message translates to:
  /// **'محدث تلقائياً'**
  String get merchantProfileUpdatedAutomatically;

  /// No description provided for @merchantProfileAvailability.
  ///
  /// In ar, this message translates to:
  /// **'التوفر الميداني والجاهزية'**
  String get merchantProfileAvailability;

  /// No description provided for @merchantProfileAvailabilitySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تلقي طلبات المراجعة الميدانية'**
  String get merchantProfileAvailabilitySubtitle;

  /// No description provided for @merchantProfileDirectNotifications.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات المباشرة للإعلانات'**
  String get merchantProfileDirectNotifications;

  /// No description provided for @merchantProfileNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إشعار فوري عند رفع إعلان أو تأهيله'**
  String get merchantProfileNotificationsSubtitle;

  /// No description provided for @merchantProfileLocalOnlyNotice.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ التغييرات على هذا الجهاز فقط؛ إرسال الإشعارات غير متصل حالياً.'**
  String get merchantProfileLocalOnlyNotice;

  /// No description provided for @merchantProfileLocalAuditNotice.
  ///
  /// In ar, this message translates to:
  /// **'يعرض هذا السجل المحلي تغييرات الملف الشخصي على هذا الجهاز فقط، وليس سجل تدقيق على الخادم.'**
  String get merchantProfileLocalAuditNotice;

  /// No description provided for @merchantProfileNoLocalActivity.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تغييرات محلية مسجلة على الملف الشخصي بعد.'**
  String get merchantProfileNoLocalActivity;

  /// No description provided for @merchantProfilePreferenceUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير تفضيل الملف الشخصي'**
  String get merchantProfilePreferenceUpdated;

  /// No description provided for @merchantProfileEnabled.
  ///
  /// In ar, this message translates to:
  /// **'مُفعّل'**
  String get merchantProfileEnabled;

  /// No description provided for @merchantProfileDisabled.
  ///
  /// In ar, this message translates to:
  /// **'مُعطّل'**
  String get merchantProfileDisabled;

  /// No description provided for @merchantProfileLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل إعدادات الملف الشخصي المحفوظة.'**
  String get merchantProfileLoadError;

  /// No description provided for @merchantProfileSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ هذا الإعداد على الجهاز. حاول مرة أخرى.'**
  String get merchantProfileSaveError;

  /// No description provided for @merchantProfileRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get merchantProfileRetry;

  /// No description provided for @merchantProfileSecurityAudit.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والتدقيق الإداري'**
  String get merchantProfileSecurityAudit;

  /// No description provided for @merchantProfileChangeSettings.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الإعدادات'**
  String get merchantProfileChangeSettings;

  /// No description provided for @merchantAuditSuspended.
  ///
  /// In ar, this message translates to:
  /// **'تعليق التاجر'**
  String get merchantAuditSuspended;

  /// No description provided for @merchantAuditUnsuspended.
  ///
  /// In ar, this message translates to:
  /// **'فك تعليق التاجر'**
  String get merchantAuditUnsuspended;

  /// No description provided for @merchantAuditFinancialSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'إحالة طلب مالي للمشرف المالي'**
  String get merchantAuditFinancialSubmitted;

  /// No description provided for @merchantAuditFinancialRejected.
  ///
  /// In ar, this message translates to:
  /// **'رفض طلب مالي'**
  String get merchantAuditFinancialRejected;

  /// No description provided for @merchantAuditAdModerated.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة إعلان تاجر'**
  String get merchantAuditAdModerated;

  /// No description provided for @merchantAuditCommissionUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تحديث عمولة التاجر'**
  String get merchantAuditCommissionUpdated;

  /// No description provided for @merchantAuditLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل سجل العمليات الرقابية.'**
  String get merchantAuditLoadError;

  /// No description provided for @merchantProfileViewAll.
  ///
  /// In ar, this message translates to:
  /// **'السجل الشامل'**
  String get merchantProfileViewAll;

  /// No description provided for @merchantProfileLatestActivities.
  ///
  /// In ar, this message translates to:
  /// **'آخر العمليات الرقابية المنفذة'**
  String get merchantProfileLatestActivities;

  /// No description provided for @merchantProfileToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get merchantProfileToday;

  /// No description provided for @merchantProfileActivityApproved.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد حملة إعلانية: متجر أفق العطور'**
  String get merchantProfileActivityApproved;

  /// No description provided for @merchantProfileLicenseNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الترخيص: LIC-9902'**
  String get merchantProfileLicenseNumber;

  /// No description provided for @merchantProfileActivityEdit.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل إعلان: معرض مطابخ النخبة'**
  String get merchantProfileActivityEdit;

  /// No description provided for @merchantProfileActivityEditDetails.
  ///
  /// In ar, this message translates to:
  /// **'مخالفة لمعيار وضوح الأسعار'**
  String get merchantProfileActivityEditDetails;

  /// No description provided for @merchantProfileActivityLocation.
  ///
  /// In ar, this message translates to:
  /// **'معاينة ميدانية وتثبيت موقع: أسواق المدى'**
  String get merchantProfileActivityLocation;

  /// No description provided for @merchantProfileActivityLocationDetails.
  ///
  /// In ar, this message translates to:
  /// **'فرع حي الصحافة'**
  String get merchantProfileActivityLocationDetails;

  /// No description provided for @merchantProfileFinancialWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظتي والبيانات المالية'**
  String get merchantProfileFinancialWallet;

  /// No description provided for @merchantWalletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظتك'**
  String get merchantWalletTitle;

  /// No description provided for @merchantWalletSupervisorStatus.
  ///
  /// In ar, this message translates to:
  /// **'مشرف معتمد • قطاع المستقل وصالني'**
  String get merchantWalletSupervisorStatus;

  /// No description provided for @merchantWalletReady.
  ///
  /// In ar, this message translates to:
  /// **'نشط وجاهز'**
  String get merchantWalletReady;

  /// No description provided for @merchantWalletAvailableBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح للسحب الفوري'**
  String get merchantWalletAvailableBalance;

  /// No description provided for @merchantWalletAvailableAmount.
  ///
  /// In ar, this message translates to:
  /// **'8,450'**
  String get merchantWalletAvailableAmount;

  /// No description provided for @merchantWalletBalanceDescription.
  ///
  /// In ar, this message translates to:
  /// **'يشمل مستحقات الإشراف الميداني المعتمدة وبدلات التحقق الميدانية وجاهزة للتحويل الفوري.'**
  String get merchantWalletBalanceDescription;

  /// No description provided for @merchantWalletPendingDues.
  ///
  /// In ar, this message translates to:
  /// **'قيد التدقيق المالي'**
  String get merchantWalletPendingDues;

  /// No description provided for @merchantWalletPendingAmount.
  ///
  /// In ar, this message translates to:
  /// **'4,050'**
  String get merchantWalletPendingAmount;

  /// No description provided for @merchantWalletTotalDues.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستحقات'**
  String get merchantWalletTotalDues;

  /// No description provided for @merchantWalletTotalAmount.
  ///
  /// In ar, this message translates to:
  /// **'12,500'**
  String get merchantWalletTotalAmount;

  /// No description provided for @merchantWalletSettlementCycle.
  ///
  /// In ar, this message translates to:
  /// **'دورة تسوية أسبوعية منتظمة'**
  String get merchantWalletSettlementCycle;

  /// No description provided for @merchantWalletReadiness.
  ///
  /// In ar, this message translates to:
  /// **'معدل جاهزية الصرف: 68%'**
  String get merchantWalletReadiness;

  /// No description provided for @merchantWalletWithdrawTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب المستحقات المالية'**
  String get merchantWalletWithdrawTitle;

  /// No description provided for @merchantWalletNoTransferFees.
  ///
  /// In ar, this message translates to:
  /// **'بدون رسوم تحويل'**
  String get merchantWalletNoTransferFees;

  /// No description provided for @merchantWalletRequestedAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ السحب المطلوب'**
  String get merchantWalletRequestedAmount;

  /// No description provided for @merchantWalletFullBalance.
  ///
  /// In ar, this message translates to:
  /// **'سحب كامل الرصيد (8,450 ر.س)'**
  String get merchantWalletFullBalance;

  /// No description provided for @merchantWalletTransferLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى لعملية السحب 100 ر.س، الحد الأقصى اليومي 20,000 ر.س'**
  String get merchantWalletTransferLimit;

  /// No description provided for @merchantWalletChooseMethod.
  ///
  /// In ar, this message translates to:
  /// **'اختر وجهة التحويل'**
  String get merchantWalletChooseMethod;

  /// No description provided for @merchantWalletBankTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get merchantWalletBankTransfer;

  /// No description provided for @merchantWalletIban.
  ///
  /// In ar, this message translates to:
  /// **'آيبان (IBAN)'**
  String get merchantWalletIban;

  /// No description provided for @merchantWalletDigitalWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة رقمية'**
  String get merchantWalletDigitalWallet;

  /// No description provided for @merchantWalletWalletProvider.
  ///
  /// In ar, this message translates to:
  /// **'VFC / E&'**
  String get merchantWalletWalletProvider;

  /// No description provided for @merchantWalletInstantTransfer.
  ///
  /// In ar, this message translates to:
  /// **'إنستاباي'**
  String get merchantWalletInstantTransfer;

  /// No description provided for @merchantWalletInstant.
  ///
  /// In ar, this message translates to:
  /// **'فوري'**
  String get merchantWalletInstant;

  /// No description provided for @merchantWalletTransferAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الدفع اللحظي (IPA) أو رقم الهاتف المرتبط'**
  String get merchantWalletTransferAddress;

  /// No description provided for @merchantWalletIbanValue.
  ///
  /// In ar, this message translates to:
  /// **'SA0380000000608010167519'**
  String get merchantWalletIbanValue;

  /// No description provided for @merchantWalletPhoneValue.
  ///
  /// In ar, this message translates to:
  /// **'01012345678'**
  String get merchantWalletPhoneValue;

  /// No description provided for @merchantWalletInstantAddress.
  ///
  /// In ar, this message translates to:
  /// **'supervisor.audit@instapay'**
  String get merchantWalletInstantAddress;

  /// No description provided for @merchantWalletAccountName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الحساب المسجل: م. عبد الرحمن الشهري (موثق)'**
  String get merchantWalletAccountName;

  /// No description provided for @merchantWalletProcessingDetails.
  ///
  /// In ar, this message translates to:
  /// **'سرعة المعالجة: فوري ومباشر على مدار الساعة\nرسوم المعالجة والتحويل: 0.5 ر.س (محفظة بالكامل للمشرف)'**
  String get merchantWalletProcessingDetails;

  /// No description provided for @merchantWalletConfirmWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد وطلب السحب المالي'**
  String get merchantWalletConfirmWithdrawal;

  /// No description provided for @merchantWalletBonusTitle.
  ///
  /// In ar, this message translates to:
  /// **'حافز الإنجاز الأسبوعي متاح!  +500'**
  String get merchantWalletBonusTitle;

  /// No description provided for @merchantWalletBonusDescription.
  ///
  /// In ar, this message translates to:
  /// **'أنجزت 5 مهام ميدانية بنجاح بتفوق المعايير المحددة.'**
  String get merchantWalletBonusDescription;

  /// No description provided for @merchantWalletTransactionHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات والتحويلات الأخيرة'**
  String get merchantWalletTransactionHistory;

  /// No description provided for @merchantWalletTransactionBank.
  ///
  /// In ar, this message translates to:
  /// **'سحب بنكي - مصرف الراجحي'**
  String get merchantWalletTransactionBank;

  /// No description provided for @merchantWalletTransactionDateOne.
  ///
  /// In ar, this message translates to:
  /// **'أمس، 02:40 م'**
  String get merchantWalletTransactionDateOne;

  /// No description provided for @merchantWalletTransactionAmountOne.
  ///
  /// In ar, this message translates to:
  /// **'-5,000'**
  String get merchantWalletTransactionAmountOne;

  /// No description provided for @merchantWalletTransactionInstant.
  ///
  /// In ar, this message translates to:
  /// **'تحويل فوري - InstaPay'**
  String get merchantWalletTransactionInstant;

  /// No description provided for @merchantWalletTransactionDateTwo.
  ///
  /// In ar, this message translates to:
  /// **'21 أكتوبر'**
  String get merchantWalletTransactionDateTwo;

  /// No description provided for @merchantWalletTransactionAmountTwo.
  ///
  /// In ar, this message translates to:
  /// **'-2,200'**
  String get merchantWalletTransactionAmountTwo;

  /// No description provided for @merchantWalletCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get merchantWalletCompleted;

  /// No description provided for @merchantWalletAuditNotice.
  ///
  /// In ar, this message translates to:
  /// **'العمليات المالية مشفرة وتخضع لآلية الرقابة المحاسبية لمنصة وصالني'**
  String get merchantWalletAuditNotice;

  /// No description provided for @merchantWalletAuditCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق الدوري: AUDIT-SEC-2024-v9'**
  String get merchantWalletAuditCode;

  /// No description provided for @merchantWalletActionUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'طلب السحب غير متاح حالياً'**
  String get merchantWalletActionUnavailable;

  /// No description provided for @merchantProfileJustUpdated.
  ///
  /// In ar, this message translates to:
  /// **'محدث لحظياً'**
  String get merchantProfileJustUpdated;

  /// No description provided for @merchantProfileBalanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح والمستحقات'**
  String get merchantProfileBalanceTitle;

  /// No description provided for @merchantProfileBalance.
  ///
  /// In ar, this message translates to:
  /// **'14,850'**
  String get merchantProfileBalance;

  /// No description provided for @merchantProfileBalanceDetails.
  ///
  /// In ar, this message translates to:
  /// **'بدلات الإشراف الميداني + مستحقات التوثيق'**
  String get merchantProfileBalanceDetails;

  /// No description provided for @merchantProfileWalletDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المحفظة'**
  String get merchantProfileWalletDetails;

  /// No description provided for @merchantProfileDocumentDetails.
  ///
  /// In ar, this message translates to:
  /// **'مستند معتمد للمشرف'**
  String get merchantProfileDocumentDetails;

  /// No description provided for @merchantProfileDocumentNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم المستند'**
  String get merchantProfileDocumentNumber;

  /// No description provided for @merchantProfileClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get merchantProfileClose;

  /// No description provided for @merchantProfileMinutesUnit.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة مضت'**
  String get merchantProfileMinutesUnit;

  /// No description provided for @merchantProfileTwoHoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ ساعتين'**
  String get merchantProfileTwoHoursAgo;

  /// No description provided for @merchantProfileMorningAbbreviation.
  ///
  /// In ar, this message translates to:
  /// **'ص'**
  String get merchantProfileMorningAbbreviation;

  /// No description provided for @merchantInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التاجر'**
  String get merchantInfoTitle;

  /// No description provided for @merchantInfoProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملف التاجر'**
  String get merchantInfoProfile;

  /// No description provided for @merchantInfoLiveMonitoring.
  ///
  /// In ar, this message translates to:
  /// **'مراقبة مباشرة'**
  String get merchantInfoLiveMonitoring;

  /// No description provided for @merchantInfoStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get merchantInfoStatusActive;

  /// No description provided for @merchantInfoStatusActiveVerified.
  ///
  /// In ar, this message translates to:
  /// **'نشط وموثق'**
  String get merchantInfoStatusActiveVerified;

  /// No description provided for @merchantInfoStatusUnderAudit.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get merchantInfoStatusUnderAudit;

  /// No description provided for @merchantInfoStatusUpdateRequired.
  ///
  /// In ar, this message translates to:
  /// **'تحديث البيانات مطلوب'**
  String get merchantInfoStatusUpdateRequired;

  /// No description provided for @merchantInfoStatusSuspended.
  ///
  /// In ar, this message translates to:
  /// **'معلق مؤقتاً'**
  String get merchantInfoStatusSuspended;

  /// No description provided for @merchantInfoAccreditedCategory.
  ///
  /// In ar, this message translates to:
  /// **'معتمد لدى {category}'**
  String merchantInfoAccreditedCategory(Object category);

  /// No description provided for @merchantInfoTotalAds.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإعلانات'**
  String get merchantInfoTotalAds;

  /// No description provided for @merchantInfoActiveAds.
  ///
  /// In ar, this message translates to:
  /// **'{count} نشط'**
  String merchantInfoActiveAds(Object count);

  /// No description provided for @merchantInfoAdsUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'{count} قيد المراجعة'**
  String merchantInfoAdsUnderReview(Object count);

  /// No description provided for @merchantInfoAdsShort.
  ///
  /// In ar, this message translates to:
  /// **'إعلان'**
  String get merchantInfoAdsShort;

  /// No description provided for @merchantInfoAdsGroup.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get merchantInfoAdsGroup;

  /// No description provided for @merchantInfoPendingOperations.
  ///
  /// In ar, this message translates to:
  /// **'العمليات المعلقة'**
  String get merchantInfoPendingOperations;

  /// No description provided for @merchantInfoSuspendTemporarily.
  ///
  /// In ar, this message translates to:
  /// **'تعليق مؤقت'**
  String get merchantInfoSuspendTemporarily;

  /// No description provided for @merchantInfoMessageMerchant.
  ///
  /// In ar, this message translates to:
  /// **'مراسلة التاجر'**
  String get merchantInfoMessageMerchant;

  /// No description provided for @merchantInfoActionUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإجراء غير متاح حالياً'**
  String get merchantInfoActionUnavailable;

  /// No description provided for @merchantPendingOperationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات أو إعلانات معلقة لهذا التاجر'**
  String get merchantPendingOperationsEmpty;

  /// No description provided for @merchantPendingCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عملية معلقة'**
  String merchantPendingCount(Object count);

  /// No description provided for @merchantPendingMoreDetailsUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'عدد الإعلانات المعلقة معروف، لكن تفاصيل القائمة الكاملة غير متوفرة حالياً.'**
  String get merchantPendingMoreDetailsUnavailable;

  /// No description provided for @merchantPendingReference.
  ///
  /// In ar, this message translates to:
  /// **'رقم الإعلان'**
  String get merchantPendingReference;

  /// No description provided for @merchantPendingPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get merchantPendingPrice;

  /// No description provided for @merchantPendingApprove.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد'**
  String get merchantPendingApprove;

  /// No description provided for @merchantPendingReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get merchantPendingReject;

  /// No description provided for @merchantPendingOperationHandled.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة الإعلان'**
  String get merchantPendingOperationHandled;

  /// No description provided for @merchantConversationEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ محادثة مع هذا التاجر'**
  String get merchantConversationEmpty;

  /// No description provided for @merchantConversationInputHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك...'**
  String get merchantConversationInputHint;

  /// No description provided for @merchantConversationSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get merchantConversationSend;

  /// No description provided for @merchantInfoFinancialSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات المالية وسياسة التوصيل'**
  String get merchantInfoFinancialSettings;

  /// No description provided for @merchantInfoMerchantDashboard.
  ///
  /// In ar, this message translates to:
  /// **'تحكم المشرف'**
  String get merchantInfoMerchantDashboard;

  /// No description provided for @merchantInfoFinancialSettingsDescription.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم الرقابي للعمولات والخدمات اللوجستية وتحديد النمط المالي'**
  String get merchantInfoFinancialSettingsDescription;

  /// No description provided for @merchantInfoCfoPermission.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحية حصرية للمشرف المالي المعتمد'**
  String get merchantInfoCfoPermission;

  /// No description provided for @merchantInfoSalesCommission.
  ///
  /// In ar, this message translates to:
  /// **'عمولة التطبيق من المبيعات'**
  String get merchantInfoSalesCommission;

  /// No description provided for @merchantInfoFixedAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ ثابت بالأرقام (ر.س)'**
  String get merchantInfoFixedAmount;

  /// No description provided for @merchantInfoPercentage.
  ///
  /// In ar, this message translates to:
  /// **'نسبة مئوية (%)'**
  String get merchantInfoPercentage;

  /// No description provided for @merchantInfoAdjustCommission.
  ///
  /// In ar, this message translates to:
  /// **'تعديل نسبة العمولة المئوية (%)'**
  String get merchantInfoAdjustCommission;

  /// No description provided for @merchantInfoSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get merchantInfoSave;

  /// No description provided for @merchantInfoCommissionExample.
  ///
  /// In ar, this message translates to:
  /// **'حاسبة تقريبية لعملية بيع بقيمة 100 ر.س:'**
  String get merchantInfoCommissionExample;

  /// No description provided for @merchantInfoCommissionValue.
  ///
  /// In ar, this message translates to:
  /// **'عمولة المنصة: {amount} {currency}'**
  String merchantInfoCommissionValue(Object amount, Object currency);

  /// No description provided for @merchantInfoInvalidCommission.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عمولة من 0 إلى 100'**
  String get merchantInfoInvalidCommission;

  /// No description provided for @merchantInfoCommissionSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث العمولة'**
  String get merchantInfoCommissionSaved;

  /// No description provided for @merchantInfoVerification.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التوثيق والاعتماد'**
  String get merchantInfoVerification;

  /// No description provided for @merchantInfoVerifiedBadge.
  ///
  /// In ar, this message translates to:
  /// **'بيانات موثقة'**
  String get merchantInfoVerifiedBadge;

  /// No description provided for @merchantInfoOwner.
  ///
  /// In ar, this message translates to:
  /// **'اسم المفوض / المالك'**
  String get merchantInfoOwner;

  /// No description provided for @merchantInfoPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف المعتمد'**
  String get merchantInfoPhone;

  /// No description provided for @merchantInfoEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني الرسمي'**
  String get merchantInfoEmail;

  /// No description provided for @merchantInfoJoinedDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الربط الإشرافي'**
  String get merchantInfoJoinedDate;

  /// No description provided for @merchantInfoNotProvided.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get merchantInfoNotProvided;

  /// No description provided for @merchantInfoFieldAds.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات التاجر الميدانية'**
  String get merchantInfoFieldAds;

  /// No description provided for @merchantInfoShowAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل ({count})'**
  String merchantInfoShowAll(Object count);

  /// No description provided for @merchantInfoNoAds.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات متاحة'**
  String get merchantInfoNoAds;

  /// No description provided for @merchantInfoAdApproved.
  ///
  /// In ar, this message translates to:
  /// **'معتمد'**
  String get merchantInfoAdApproved;

  /// No description provided for @merchantInfoAdUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'تحت الفحص'**
  String get merchantInfoAdUnderReview;

  /// No description provided for @merchantSuspendBadge.
  ///
  /// In ar, this message translates to:
  /// **'إجراء احترازي'**
  String get merchantSuspendBadge;

  /// No description provided for @merchantSuspendTitle.
  ///
  /// In ar, this message translates to:
  /// **'إجراء تعليق متجر'**
  String get merchantSuspendTitle;

  /// No description provided for @merchantSuspendSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قرار رقابي وإداري عاجل'**
  String get merchantSuspendSubtitle;

  /// No description provided for @merchantSuspendImpact.
  ///
  /// In ar, this message translates to:
  /// **'تعليق المتجر سيوقف ظهور جميع إعلانات التاجر فوراً في محركات البحث وتطبيق المشترك، مع تجميد استقبال الطلبات الجديدة حتى تصحيح المخالفة واعتمادها.'**
  String get merchantSuspendImpact;

  /// No description provided for @merchantSuspendDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المخالفة والملاحظات الميدانية'**
  String get merchantSuspendDetails;

  /// No description provided for @merchantSuspendCharacterCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} / 500'**
  String merchantSuspendCharacterCount(Object count);

  /// No description provided for @merchantSuspendDetailsHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب وصفاً مفصلاً للمخالفة يظهر للتاجر في لوحة تحكمه مع توضيح الخطوات المطلوبة للتسوية...'**
  String get merchantSuspendDetailsHint;

  /// No description provided for @merchantSuspendPrivateNote.
  ///
  /// In ar, this message translates to:
  /// **'هذا النص سيظهر كسجل رسمي للتاجر في حسابه الموثق.'**
  String get merchantSuspendPrivateNote;

  /// No description provided for @merchantSuspendAttachments.
  ///
  /// In ar, this message translates to:
  /// **'المستندات التوثيقية ومحاضر المعاينة'**
  String get merchantSuspendAttachments;

  /// No description provided for @merchantSuspendUpload.
  ///
  /// In ar, this message translates to:
  /// **'انقر لإرفاق محضر المعاينة أو الصور'**
  String get merchantSuspendUpload;

  /// No description provided for @merchantSuspendFileTypes.
  ///
  /// In ar, this message translates to:
  /// **'صيغ مدعومة: PDF, JPG, PNG (بحد أقصى 10 ميجابايت)'**
  String get merchantSuspendFileTypes;

  /// No description provided for @merchantSuspendDuration.
  ///
  /// In ar, this message translates to:
  /// **'فترة التعليق المقترحة'**
  String get merchantSuspendDuration;

  /// No description provided for @merchantSuspendReasonCorrection.
  ///
  /// In ar, this message translates to:
  /// **'لحين تصحيح الوضع ومعالجة المخالفة'**
  String get merchantSuspendReasonCorrection;

  /// No description provided for @merchantSuspendReasonCorrectionDescription.
  ///
  /// In ar, this message translates to:
  /// **'إجراء موصى به من جهة الرقابة'**
  String get merchantSuspendReasonCorrectionDescription;

  /// No description provided for @merchantSuspendReasonDuration.
  ///
  /// In ar, this message translates to:
  /// **'تعليق محدد بـ 7 أيام'**
  String get merchantSuspendReasonDuration;

  /// No description provided for @merchantSuspendReasonDurationDescription.
  ///
  /// In ar, this message translates to:
  /// **'رفع تلقائي بعد انقضاء المدة'**
  String get merchantSuspendReasonDurationDescription;

  /// No description provided for @merchantSuspendReasonLegal.
  ///
  /// In ar, this message translates to:
  /// **'إحالة عاجلة للشؤون القانونية'**
  String get merchantSuspendReasonLegal;

  /// No description provided for @merchantSuspendReasonLegalDescription.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب تحقيقاً وتدقيقاً قانونياً'**
  String get merchantSuspendReasonLegalDescription;

  /// No description provided for @merchantSuspendConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التعليق المؤقت وإشعار التاجر'**
  String get merchantSuspendConfirm;

  /// No description provided for @merchantSuspendCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء والعودة لملف التاجر'**
  String get merchantSuspendCancel;

  /// No description provided for @noMerchantsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد متاجر مطابقة لخيارات البحث'**
  String get noMerchantsFound;

  /// No description provided for @merchantsUnderSupervisionTitle.
  ///
  /// In ar, this message translates to:
  /// **'التجار تحت الإشراف'**
  String get merchantsUnderSupervisionTitle;

  /// No description provided for @supervisedAreaLabel.
  ///
  /// In ar, this message translates to:
  /// **'نطاق الإشراف: منطقة الرياض (وسط وشمال العاصمة)'**
  String get supervisedAreaLabel;

  /// No description provided for @supervisorFullName.
  ///
  /// In ar, this message translates to:
  /// **'المشرف: أحمد بن عبد العزيز الخضيري'**
  String get supervisorFullName;

  /// No description provided for @totalFieldAccountsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الحسابات الميدانية'**
  String get totalFieldAccountsTitle;

  /// No description provided for @merchantsUnderYourSupervision.
  ///
  /// In ar, this message translates to:
  /// **'تاجراً تحت إشرافك'**
  String get merchantsUnderYourSupervision;

  /// No description provided for @complianceRate.
  ///
  /// In ar, this message translates to:
  /// **'الامتثال'**
  String get complianceRate;

  /// No description provided for @activeAndVerifiedMetric.
  ///
  /// In ar, this message translates to:
  /// **'نشط وموثق'**
  String get activeAndVerifiedMetric;

  /// No description provided for @pendingAlertsMetric.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات معلقة'**
  String get pendingAlertsMetric;

  /// No description provided for @temporarySuspendedMetric.
  ///
  /// In ar, this message translates to:
  /// **'تعليق مؤقت'**
  String get temporarySuspendedMetric;

  /// No description provided for @searchMerchantPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم المتجر، كود التاجر، أو السجل...'**
  String get searchMerchantPlaceholder;

  /// No description provided for @filterAllWithCount.
  ///
  /// In ar, this message translates to:
  /// **'الكل ({count})'**
  String filterAllWithCount(Object count);

  /// No description provided for @filterActiveWithCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نشط وموثق'**
  String filterActiveWithCount(Object count);

  /// No description provided for @filterPendingWithCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} تنبيهات معلقة'**
  String filterPendingWithCount(Object count);

  /// No description provided for @filterSuspendedWithCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} تعليق مؤقت'**
  String filterSuspendedWithCount(Object count);

  /// No description provided for @sortMostActive.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب: الأكثر نشاطاً'**
  String get sortMostActive;

  /// No description provided for @activeAdsHeader.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات نشطة'**
  String get activeAdsHeader;

  /// No description provided for @pendingReviewHeader.
  ///
  /// In ar, this message translates to:
  /// **'معلق للمراجعة'**
  String get pendingReviewHeader;

  /// No description provided for @platformCommissionHeader.
  ///
  /// In ar, this message translates to:
  /// **'عمولة المنصة'**
  String get platformCommissionHeader;

  /// No description provided for @viewProfileAndControl.
  ///
  /// In ar, this message translates to:
  /// **'عرض الملف والتحكم'**
  String get viewProfileAndControl;

  /// No description provided for @pendingProfitWithdrawalAlert.
  ///
  /// In ar, this message translates to:
  /// **'طلب سحب أرباح معلق'**
  String get pendingProfitWithdrawalAlert;

  /// No description provided for @supervisoryNoteActive.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة إشرافية نشطة'**
  String get supervisoryNoteActive;

  /// No description provided for @deliveryStatusFieldInspection.
  ///
  /// In ar, this message translates to:
  /// **'فحص الميدان'**
  String get deliveryStatusFieldInspection;

  /// No description provided for @deliveryStatusHeader.
  ///
  /// In ar, this message translates to:
  /// **'حالة التوصيل'**
  String get deliveryStatusHeader;

  /// No description provided for @descriptionStandardsViolation.
  ///
  /// In ar, this message translates to:
  /// **'مخالفة معايير الوصف VR3-858'**
  String get descriptionStandardsViolation;

  /// No description provided for @zeroAdsDisplayedSuspended.
  ///
  /// In ar, this message translates to:
  /// **'0 إعلان معروض (إيقاف إداري احترازي)'**
  String get zeroAdsDisplayedSuspended;

  /// No description provided for @summonAction.
  ///
  /// In ar, this message translates to:
  /// **'استدعاء'**
  String get summonAction;

  /// No description provided for @reviewViolationAndUnfreeze.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة المخالفة والفك'**
  String get reviewViolationAndUnfreeze;

  /// No description provided for @suspendedBadge.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get suspendedBadge;

  /// No description provided for @remainingMerchantsTitle.
  ///
  /// In ar, this message translates to:
  /// **'يوجد 13 تاجر آخر بحالة نشطة وممتثلة تماماً'**
  String get remainingMerchantsTitle;

  /// No description provided for @remainingMerchantsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تم فحص سجلاتهم الدورية للأسبوع الحالي بنجاح'**
  String get remainingMerchantsSubtitle;

  /// No description provided for @loadAndShowRemainingList.
  ///
  /// In ar, this message translates to:
  /// **'تحميل واستعراض بقية القائمة'**
  String get loadAndShowRemainingList;

  /// No description provided for @fieldGovernanceCardTitle.
  ///
  /// In ar, this message translates to:
  /// **'حوكمة وتفويض المشرف الميداني'**
  String get fieldGovernanceCardTitle;

  /// No description provided for @fieldGovernanceCardBody.
  ///
  /// In ar, this message translates to:
  /// **'كافة التجار المسجلين أعلاه مرتبطون مباشرة بنطاق إشرافك الميداني والرقابي بموجب قرار الحوكمة والتفويض الإداري رقم SUP-4092.'**
  String get fieldGovernanceCardBody;

  /// No description provided for @addNewMerchantToSupervision.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تاجر جديد للإشراف'**
  String get addNewMerchantToSupervision;

  /// No description provided for @retryLoadMerchants.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retryLoadMerchants;

  /// No description provided for @merchantNameField.
  ///
  /// In ar, this message translates to:
  /// **'اسم التاجر أو المنشأة'**
  String get merchantNameField;

  /// No description provided for @merchantCrField.
  ///
  /// In ar, this message translates to:
  /// **'رقم السجل التجاري'**
  String get merchantCrField;

  /// No description provided for @merchantPhoneField.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف المعتمد'**
  String get merchantPhoneField;

  /// No description provided for @supervisedMerchantsBadge.
  ///
  /// In ar, this message translates to:
  /// **'مشرف التجار'**
  String get supervisedMerchantsBadge;

  /// No description provided for @servicesSupervisorTitle.
  ///
  /// In ar, this message translates to:
  /// **'مشرف الخدمات'**
  String get servicesSupervisorTitle;

  /// No description provided for @servicesSupervisorBadge.
  ///
  /// In ar, this message translates to:
  /// **'مشرف الخدمات · SRV-01'**
  String get servicesSupervisorBadge;

  /// No description provided for @serviceProvidersTab.
  ///
  /// In ar, this message translates to:
  /// **'مقدمو الخدمات'**
  String get serviceProvidersTab;

  /// No description provided for @servicesAccountTab.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get servicesAccountTab;

  /// No description provided for @serviceProvidersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مقدمي خدمة'**
  String serviceProvidersCount(int count);

  /// No description provided for @serviceProviderProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف والسجل المهني للمزود'**
  String get serviceProviderProfileTitle;

  /// No description provided for @serviceProviderAvailableForWork.
  ///
  /// In ar, this message translates to:
  /// **'متاح ومستعد لإسناد المهام الفورية'**
  String get serviceProviderAvailableForWork;

  /// No description provided for @serviceProviderVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثق'**
  String get serviceProviderVerified;

  /// No description provided for @serviceProviderRegistryNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم السجل التجاري'**
  String get serviceProviderRegistryNumber;

  /// No description provided for @serviceProviderViewProfileAndHistory.
  ///
  /// In ar, this message translates to:
  /// **'عرض ملف المقدم وسجله'**
  String get serviceProviderViewProfileAndHistory;

  /// No description provided for @serviceProviderPerformanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'مؤشرات الأداء التشغيلي (KPIs)'**
  String get serviceProviderPerformanceTitle;

  /// No description provided for @serviceProviderUpdatedNow.
  ///
  /// In ar, this message translates to:
  /// **'تحديث مباشر'**
  String get serviceProviderUpdatedNow;

  /// No description provided for @serviceProviderCompletedTasks.
  ///
  /// In ar, this message translates to:
  /// **'المهام المنجزة'**
  String get serviceProviderCompletedTasks;

  /// No description provided for @serviceProviderTaskCompletionRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الإنجاز 99.1%'**
  String get serviceProviderTaskCompletionRate;

  /// No description provided for @serviceProviderOverallRating.
  ///
  /// In ar, this message translates to:
  /// **'التقييم العام'**
  String get serviceProviderOverallRating;

  /// No description provided for @serviceProviderRatingOutOfFive.
  ///
  /// In ar, this message translates to:
  /// **'من 5.0 · 162 تقييماً'**
  String get serviceProviderRatingOutOfFive;

  /// No description provided for @serviceProviderOnTimeRate.
  ///
  /// In ar, this message translates to:
  /// **'الالتزام بالمواعيد'**
  String get serviceProviderOnTimeRate;

  /// No description provided for @serviceProviderPunctualityDetail.
  ///
  /// In ar, this message translates to:
  /// **'انضباط وجودة في الميدان'**
  String get serviceProviderPunctualityDetail;

  /// No description provided for @serviceProviderResponseSpeed.
  ///
  /// In ar, this message translates to:
  /// **'سرعة الاستجابة'**
  String get serviceProviderResponseSpeed;

  /// No description provided for @serviceProviderMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get serviceProviderMinutes;

  /// No description provided for @serviceProviderSpecialtiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'التخصصات والاعتمادات الرسمية'**
  String get serviceProviderSpecialtiesTitle;

  /// No description provided for @serviceProviderSpecialtyAirConditioning.
  ///
  /// In ar, this message translates to:
  /// **'صيانة مكيفات سبليت ومركزي وتحديثات دكت احترافية'**
  String get serviceProviderSpecialtyAirConditioning;

  /// No description provided for @serviceProviderSpecialtyAppliances.
  ///
  /// In ar, this message translates to:
  /// **'شحن وتفريغ واختبار غاز تبريد R410A وفق المعايير'**
  String get serviceProviderSpecialtyAppliances;

  /// No description provided for @serviceProviderSpecialtyElectrical.
  ///
  /// In ar, this message translates to:
  /// **'غسيل دوري مضغوط وصيانة وقائية للمجمعات السكنية'**
  String get serviceProviderSpecialtyElectrical;

  /// No description provided for @serviceProviderPlanTitle.
  ///
  /// In ar, this message translates to:
  /// **'الامتياز المهني المعتمد'**
  String get serviceProviderPlanTitle;

  /// No description provided for @serviceProviderPlanDescription.
  ///
  /// In ar, this message translates to:
  /// **'خضوعات أمنية وتدريب عملي على جودة الخدمة'**
  String get serviceProviderPlanDescription;

  /// No description provided for @serviceProviderPlanTier.
  ///
  /// In ar, this message translates to:
  /// **'6 فنيين'**
  String get serviceProviderPlanTier;

  /// No description provided for @serviceProviderRecentTasksTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل أحدث المهام والعمليات المنجزة'**
  String get serviceProviderRecentTasksTitle;

  /// No description provided for @serviceProviderFullHistory.
  ///
  /// In ar, this message translates to:
  /// **'السجل الكامل'**
  String get serviceProviderFullHistory;

  /// No description provided for @serviceProviderViewFullHistory.
  ///
  /// In ar, this message translates to:
  /// **'عرض السجل الكامل'**
  String get serviceProviderViewFullHistory;

  /// No description provided for @serviceProviderTaskAreaOne.
  ///
  /// In ar, this message translates to:
  /// **'حي الملقا'**
  String get serviceProviderTaskAreaOne;

  /// No description provided for @serviceProviderTaskAreaTwo.
  ///
  /// In ar, this message translates to:
  /// **'حي الياسمين'**
  String get serviceProviderTaskAreaTwo;

  /// No description provided for @serviceProviderTaskAreaThree.
  ///
  /// In ar, this message translates to:
  /// **'حي الصحافة'**
  String get serviceProviderTaskAreaThree;

  /// No description provided for @serviceProviderTaskTitleOne.
  ///
  /// In ar, this message translates to:
  /// **'صيانة مكيف كونسيلد مركزي'**
  String get serviceProviderTaskTitleOne;

  /// No description provided for @serviceProviderTaskTitleTwo.
  ///
  /// In ar, this message translates to:
  /// **'فحص وتعبئة غاز فريون لمبنى تجاري'**
  String get serviceProviderTaskTitleTwo;

  /// No description provided for @serviceProviderTaskTitleThree.
  ///
  /// In ar, this message translates to:
  /// **'فك وتركيب 4 وحدات سبليت جديدة'**
  String get serviceProviderTaskTitleThree;

  /// No description provided for @serviceProviderTaskDetailOne.
  ///
  /// In ar, this message translates to:
  /// **'دقة متناهية وسرعة فائقة، مع إنهاء الفحص قبل الوقت المحدد.'**
  String get serviceProviderTaskDetailOne;

  /// No description provided for @serviceProviderTaskDetailTwo.
  ///
  /// In ar, this message translates to:
  /// **'تم التأكد من سلامة التبريد قبل تسليم الموقع.'**
  String get serviceProviderTaskDetailTwo;

  /// No description provided for @serviceProviderTaskDetailThree.
  ///
  /// In ar, this message translates to:
  /// **'اختبار عزل المواسير بعد التركيب.'**
  String get serviceProviderTaskDetailThree;

  /// No description provided for @serviceProviderTaskCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل ومعتمد'**
  String get serviceProviderTaskCompleted;

  /// No description provided for @serviceProviderHistoryEntryOne.
  ///
  /// In ar, this message translates to:
  /// **'صيانة مكيف كونسيلد مركزي · حي الملقا · 5.0'**
  String get serviceProviderHistoryEntryOne;

  /// No description provided for @serviceProviderHistoryEntryTwo.
  ///
  /// In ar, this message translates to:
  /// **'فحص وتعبئة غاز فريون · حي الياسمين · 4.8'**
  String get serviceProviderHistoryEntryTwo;

  /// No description provided for @serviceProviderHistoryEntryThree.
  ///
  /// In ar, this message translates to:
  /// **'فك وتركيب وحدات سبليت · حي الصحافة · مكتمل'**
  String get serviceProviderHistoryEntryThree;

  /// No description provided for @serviceProviderHistoryEntryFour.
  ///
  /// In ar, this message translates to:
  /// **'صيانة دورية لوحدات التكييف · حي النرجس · 5.0'**
  String get serviceProviderHistoryEntryFour;

  /// No description provided for @serviceProviderHistoryEntryFive.
  ///
  /// In ar, this message translates to:
  /// **'فحص تمديدات الكهرباء · حي الورود · 4.9'**
  String get serviceProviderHistoryEntryFive;

  /// No description provided for @servicesComplaintFilters.
  ///
  /// In ar, this message translates to:
  /// **'مرشحات الشكاوى'**
  String get servicesComplaintFilters;

  /// No description provided for @servicesComplaintRequireCompensation.
  ///
  /// In ar, this message translates to:
  /// **'إلزام المزود بالتعويض'**
  String get servicesComplaintRequireCompensation;

  /// No description provided for @servicesComplaintAlreadyClosed.
  ///
  /// In ar, this message translates to:
  /// **'الشكوى مغلقة؛ يمكنك مراجعة محضر الحل فقط.'**
  String get servicesComplaintAlreadyClosed;

  /// No description provided for @servicesComplaintFiltersHint.
  ///
  /// In ar, this message translates to:
  /// **'استخدم مرشحات الحالة أو اكتب رقم الشكوى واسم العميل أو المزود.'**
  String get servicesComplaintFiltersHint;

  /// No description provided for @merchantFeaturedBadge.
  ///
  /// In ar, this message translates to:
  /// **'تاجر مميز'**
  String get merchantFeaturedBadge;

  /// No description provided for @merchantStandardBadge.
  ///
  /// In ar, this message translates to:
  /// **'تاجر عادي'**
  String get merchantStandardBadge;

  /// No description provided for @merchantSuspendedSection.
  ///
  /// In ar, this message translates to:
  /// **'التجار المعلقون'**
  String get merchantSuspendedSection;

  /// No description provided for @merchantUnsuspendAction.
  ///
  /// In ar, this message translates to:
  /// **'فك التعليق'**
  String get merchantUnsuspendAction;

  /// No description provided for @merchantUnsuspendConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إعادة تفعيل هذا التاجر وإزالته من قائمة التجار المعلقين؟'**
  String get merchantUnsuspendConfirm;

  /// No description provided for @merchantUnsuspendSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم فك تعليق التاجر وإعادته إلى قائمة التجار.'**
  String get merchantUnsuspendSuccess;

  /// No description provided for @merchantSuspendSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تعليق التاجر وإضافته إلى قائمة التجار المعلقين.'**
  String get merchantSuspendSuccess;

  /// No description provided for @merchantSuspensionSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ تغيير حالة التاجر. حاول مرة أخرى.'**
  String get merchantSuspensionSaveError;

  /// No description provided for @merchantFinanceStatusTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة طلب المشرف المالي'**
  String get merchantFinanceStatusTitle;

  /// No description provided for @merchantFinanceViewStatus.
  ///
  /// In ar, this message translates to:
  /// **'عرض حالة الطلب'**
  String get merchantFinanceViewStatus;

  /// No description provided for @merchantFinanceStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد مراجعة المشرف المالي'**
  String get merchantFinanceStatusPending;

  /// No description provided for @merchantFinanceStatusApproved.
  ///
  /// In ar, this message translates to:
  /// **'تمت الموافقة'**
  String get merchantFinanceStatusApproved;

  /// No description provided for @merchantFinanceStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم الرفض'**
  String get merchantFinanceStatusRejected;

  /// No description provided for @merchantFinanceStatusOnHold.
  ///
  /// In ar, this message translates to:
  /// **'معلق / قيد التحقق'**
  String get merchantFinanceStatusOnHold;

  /// No description provided for @merchantFinanceRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل العملية'**
  String get merchantFinanceRequestTitle;

  /// No description provided for @merchantFinanceAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get merchantFinanceAmountLabel;

  /// No description provided for @merchantFinanceDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الطلب'**
  String get merchantFinanceDateLabel;

  /// No description provided for @merchantFinanceStatusLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get merchantFinanceStatusLabel;

  /// No description provided for @merchantFinanceNoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة الطلب'**
  String get merchantFinanceNoteLabel;

  /// No description provided for @merchantLinkHasCommercialRegister.
  ///
  /// In ar, this message translates to:
  /// **'لدى التاجر سجل تجاري'**
  String get merchantLinkHasCommercialRegister;

  /// No description provided for @merchantLinkLocalScopeNotice.
  ///
  /// In ar, this message translates to:
  /// **'عند عدم وجود سجل، استخدم رقم الهاتف الموثق. يحفظ النموذج الطلب على هذا الجهاز فقط ضمن الحساب المسجل؛ الإسناد المشترك الآمن يتطلب ربطاً بالخادم.'**
  String get merchantLinkLocalScopeNotice;

  /// No description provided for @merchantLinkValidationError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم التاجر ورقم هاتف صحيحاً ورقم السجل عند انطباقه.'**
  String get merchantLinkValidationError;

  /// No description provided for @merchantLinkSessionRequired.
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول مجدداً قبل إرسال طلب ربط التاجر.'**
  String get merchantLinkSessionRequired;

  /// No description provided for @merchantLinkSavedLocally.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ طلب الربط محلياً. لم يُرسل للتاجر أو للمنصة.'**
  String get merchantLinkSavedLocally;

  /// No description provided for @merchantLinkSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ طلب الربط.'**
  String get merchantLinkSaveFailed;

  /// No description provided for @merchantLinkSaving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ حفظ الطلب...'**
  String get merchantLinkSaving;

  /// No description provided for @adsArchiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرشيف الإعلانات'**
  String get adsArchiveTitle;

  /// No description provided for @adsReviewQueueTab.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المراجعة'**
  String get adsReviewQueueTab;

  /// No description provided for @adsPremium.
  ///
  /// In ar, this message translates to:
  /// **'مميز'**
  String get adsPremium;

  /// No description provided for @adsRegular.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get adsRegular;

  /// No description provided for @adsSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ القرار. يرجى المحاولة مرة أخرى.'**
  String get adsSaveFailed;

  /// No description provided for @adsLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل قرارات الإعلانات المحفوظة.'**
  String get adsLoadFailed;

  /// No description provided for @adsFrozenStatus.
  ///
  /// In ar, this message translates to:
  /// **'مجمد'**
  String get adsFrozenStatus;

  /// No description provided for @adsFreezeAction.
  ///
  /// In ar, this message translates to:
  /// **'تجميد الإعلان'**
  String get adsFreezeAction;

  /// No description provided for @adsUnfreezeAction.
  ///
  /// In ar, this message translates to:
  /// **'استعادة الإعلان'**
  String get adsUnfreezeAction;

  /// No description provided for @finRequestLocalWorkflowNotice.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ الطلبات محلياً وتُدرج لمراجعة المشرف المالي في هذه النسخة التجريبية. لا يتم خصم مبالغ أو إرسال إشعارات فعلية للتاجر.'**
  String get finRequestLocalWorkflowNotice;

  /// No description provided for @finRequestSentConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الطلب إلى المشرف المالي.'**
  String get finRequestSentConfirmation;

  /// No description provided for @finRequestActionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إكمال الإجراء. يرجى المحاولة مرة أخرى.'**
  String get finRequestActionFailed;

  /// No description provided for @finRequestRejectTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض طلب التاجر'**
  String get finRequestRejectTitle;

  /// No description provided for @finRequestRejectReason.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سبب الرفض ليظهر للتاجر'**
  String get finRequestRejectReason;

  /// No description provided for @finRequestRejectAction.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get finRequestRejectAction;

  /// No description provided for @finRequestRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get finRequestRejected;

  /// No description provided for @finRequestRejectionSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ سبب الرفض.'**
  String get finRequestRejectionSaved;

  /// No description provided for @financeWalletRequestSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل الطلب إلى المشرف المالي للمراجعة. لم يتم أي تحويل.'**
  String get financeWalletRequestSubmitted;

  /// No description provided for @financeRequestsInProgressTab.
  ///
  /// In ar, this message translates to:
  /// **'قيد الإجراء'**
  String get financeRequestsInProgressTab;

  /// No description provided for @financeRequestsArchiveTab.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف'**
  String get financeRequestsArchiveTab;

  /// No description provided for @financeRequestsArchiveSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث برقم الطلب أو المستفيد أو مصدر الطلب'**
  String get financeRequestsArchiveSearchHint;

  /// No description provided for @financeRequestsArchiveEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الطلبات المعتمدة والمرفوضة هنا.'**
  String get financeRequestsArchiveEmpty;

  /// No description provided for @financeRequestsArchiveNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات مؤرشفة تطابق البحث أو التصفية.'**
  String get financeRequestsArchiveNoResults;

  /// No description provided for @financeRequestsInProgressEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بانتظار المراجعة.'**
  String get financeRequestsInProgressEmpty;

  /// No description provided for @financeRequestRefreshFailed.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ القرار، لكن تعذر تحديث قائمة الطلبات.'**
  String get financeRequestRefreshFailed;

  /// No description provided for @financeRequestListFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الطلبات المالية. اسحب لأسفل لإعادة المحاولة.'**
  String get financeRequestListFailed;

  /// No description provided for @financeRecordApproval.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الموافقة'**
  String get financeRecordApproval;

  /// No description provided for @financeApproveOnlyConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل تسجل الموافقة على هذا الطلب؟ لن يؤدي ذلك إلى تحويل الأموال. المبلغ:'**
  String get financeApproveOnlyConfirmation;

  /// No description provided for @withdrawalDetailsSourceAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب مصدر الطلب'**
  String get withdrawalDetailsSourceAccount;

  /// No description provided for @withdrawalDetailsOperationType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العملية'**
  String get withdrawalDetailsOperationType;

  /// No description provided for @financeOperationWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'سحب'**
  String get financeOperationWithdrawal;

  /// No description provided for @financeOperationDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع'**
  String get financeOperationDeposit;

  /// No description provided for @financeWalletRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب عملية محفظة'**
  String get financeWalletRequestTitle;

  /// No description provided for @financeWalletAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get financeWalletAmountLabel;

  /// No description provided for @financeWalletInvalidWithdrawalAmount.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغ سحب بين 100 و8,450 ر.س.'**
  String get financeWalletInvalidWithdrawalAmount;

  /// No description provided for @financeWalletInvalidDetails.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغاً صحيحاً بين 100 و20,000 ر.س وحدد وجهة الدفع.'**
  String get financeWalletInvalidDetails;

  /// No description provided for @financeWalletConfirmDepositTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد طلب الإيداع'**
  String get financeWalletConfirmDepositTitle;

  /// No description provided for @financeWalletConfirmDepositAction.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد طلب الإيداع'**
  String get financeWalletConfirmDepositAction;

  /// No description provided for @financeWalletSubmitRequest.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب للمراجعة المالية'**
  String get financeWalletSubmitRequest;

  /// No description provided for @financeWalletOperationNote.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يوافق المشرف المالي على الطلب. تُسجل الموافقة في التطبيق ولا تتحرك الأموال قبل تكامل خدمة الدفع.'**
  String get financeWalletOperationNote;

  /// No description provided for @departmentPendingAmount.
  ///
  /// In ar, this message translates to:
  /// **'أرصدة معلقة'**
  String get departmentPendingAmount;

  /// No description provided for @departmentPendingOnlyFilter.
  ///
  /// In ar, this message translates to:
  /// **'لديها مبالغ معلقة'**
  String get departmentPendingOnlyFilter;

  /// No description provided for @departmentNoPendingItems.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محافظ بمبالغ معلقة.'**
  String get departmentNoPendingItems;

  /// No description provided for @departmentExportReport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقرير'**
  String get departmentExportReport;

  /// No description provided for @departmentExportExcel.
  ///
  /// In ar, this message translates to:
  /// **'تصدير إلى Excel'**
  String get departmentExportExcel;

  /// No description provided for @departmentExportPdf.
  ///
  /// In ar, this message translates to:
  /// **'طباعة أو حفظ PDF'**
  String get departmentExportPdf;

  /// No description provided for @departmentReportName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get departmentReportName;

  /// No description provided for @departmentReportReference.
  ///
  /// In ar, this message translates to:
  /// **'المرجع'**
  String get departmentReportReference;

  /// No description provided for @departmentSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو المرجع أو الحالة'**
  String get departmentSearchHint;

  /// No description provided for @departmentNoSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محافظ مطابقة لمعايير البحث.'**
  String get departmentNoSearchResults;

  /// No description provided for @departmentViewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل المحفظة'**
  String get departmentViewDetails;

  /// No description provided for @departmentStatusLabel.
  ///
  /// In ar, this message translates to:
  /// **'حالة الحساب'**
  String get departmentStatusLabel;

  /// No description provided for @departmentOperationsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد العمليات'**
  String get departmentOperationsCount;

  /// No description provided for @merchantInfoAdRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get merchantInfoAdRejected;

  /// No description provided for @merchantInfoAdFrozen.
  ///
  /// In ar, this message translates to:
  /// **'مجمد'**
  String get merchantInfoAdFrozen;

  /// No description provided for @merchantInfoAdHidden.
  ///
  /// In ar, this message translates to:
  /// **'مخفي'**
  String get merchantInfoAdHidden;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
