import 'package:flutter/widgets.dart';

import 'package:barwah_app/l10n/app_localizations.dart';

class FinanceLocalizer {
  static const _withdrawalTextTranslations = <String, String>{
    'متجر الأفق للأجهزة الكهربائية': 'Horizon Electrical Appliances Store',
    'م. أحمد الخالدي': 'Eng. Ahmed Al-Khaldi',
    'تاجر مستلزمات حاسب': 'Computer Supplies Merchant',
    'أ. سعد العتيبي': 'Mr. Saad Al-Otaibi',
    'مؤسسة التبريد المتقن': 'Precision Cooling Establishment',
    'ورشة الإتقان للكهرباء': 'Al-Itqan Electrical Workshop',
    'معتمد ومطابق عبر النفاذ الموحد': 'Verified and matched through Nafath',
    'فني صيانة معتمد | عمولات منجزة':
        'Certified maintenance technician | completed commissions',
    'موقوف مؤقتاً للتحقيق الرقابي': 'Temporarily suspended for audit review',
    'مشرف تجار معتمد': 'Certified merchant supervisor',
    'مقدم خدمة معتمد\n(م. خليل إبراهيم)':
        'Certified service provider\n(Eng. Khalil Ibrahim)',
    'مقدم خدمة صيانة': 'Maintenance service provider',
    'المرجع الرقابي\n#FAR-102': 'Audit reference\n#FAR-102',
    'آيبان موثق': 'Verified IBAN',
    'اليوم، 10:45 ص (منذ ساعتين)': 'Today, 10:45 AM (2 hours ago)',
    'تم تجميد الطلب احترازياً بقرار المشرف المالي':
        'Precautionarily frozen by finance supervisor',
    'مطابقة الفواتير: 100% | لا توجد بلاغات نزاع أو شكاوى نشطة | رصيد المحفظة مغطى بالكامل ومطابق لصافي التحصيلات التشغيلية.':
        'Invoice match: 100% | No active disputes or complaints | Wallet balance fully covers and matches net operating collections.',
    'معتمد من النظام - جاهز للإرسال البنكي الفوري عبر شبكة سريع':
        'System approved - ready for instant bank transfer via SARIE',
    'طلب تجميد سحب صادر من مشرف التجار (Finance Action Request #FAR-102) لوجود شبهة تلاعب في عروض ترويجية #CMP-1042 مع عملاء النهائيين بشأن استرداد مبالغ مشتريات ملغاة.':
        'Withdrawal freeze requested by the merchant supervisor (Finance Action Request #FAR-102) over suspected promotion fraud #CMP-1042 involving refunds for cancelled purchases.',
    'عمولات إشراف واعتماد عقود التجار المنجزة (شهر أكتوبر)':
        'Supervision commissions and completed merchant contract approvals (October)',
    'أجور إنجاز 14 طلب صيانة وتبريد ميدانية معتمدة من العميل والمشرف':
        'Payment for 14 on-site maintenance and cooling jobs approved by the customer and supervisor',
    'وجود شكوى مفتوحة من عميل (#CMP-1042) لعدم اكتمال أعمال الصيانة بانتظار فحص المشرف وإعادة تقييم الخدمة الميدانية.':
        'An open customer complaint (#CMP-1042) reports incomplete maintenance work; awaiting supervisor inspection and reassessment of the field service.',
    'تحويل سريع عبر IBAN بنك الراجحي':
        'Instant transfer via Al Rajhi Bank IBAN',
    'حالة الطلب: محجوز بموجب بروتوكول حماية الجودة الإشرافي':
        'Request status: Held under the supervisory quality protection protocol',
  };

  static String localizeWithdrawalText(BuildContext context, String text) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || l10n.localeName.startsWith('ar')) return text;
    return _withdrawalTextTranslations[text] ?? localizeBankName(context, text);
  }

  static String localizeBankName(BuildContext context, String bankName) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || l10n.localeName.startsWith('ar')) return bankName;
    if (bankName.contains('الراجحي')) return l10n.alRajhiBankName;
    if (bankName.contains('الأهلي')) return l10n.snbBankName;
    if (bankName.contains('الرياض')) return l10n.riyadBankName;
    if (bankName.contains('مدى') || bankName.contains('Mada')) {
      return l10n.madaGatewayName;
    }
    if (bankName.contains('STC')) return l10n.stcPayWalletName;
    return bankName;
  }

  static String localizeAccountType(BuildContext context, String accountType) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || l10n.localeName.startsWith('ar')) return accountType;
    if (accountType.contains('ضمان') || accountType.contains('Escrow')) {
      return l10n.escrowAccountType;
    }
    if (accountType.contains('تشغيلي')) return l10n.operatingAccountType;
    if (accountType.contains('بوابة دفع')) {
      return l10n.electronicPaymentGatewayType;
    }
    if (accountType.contains('رقمية')) return l10n.digitalWalletType;
    return accountType;
  }

  static String localizePackageName(BuildContext context, String packageName) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || l10n.localeName.startsWith('ar')) return packageName;
    if (packageName.contains('الذهبية')) return l10n.goldenAnnualPackage;
    if (packageName.contains('احترافي')) return l10n.proServiceProvider;
    if (packageName.contains('VIP')) return l10n.vipAnnualPackage;
    if (packageName.contains('اللامحدود')) return l10n.unlimitedDeliveryPackage;
    if (packageName.contains('أسبوع')) return l10n.featuredWeekPackage;
    return packageName;
  }

  static String localizePaymentMethod(BuildContext context, String method) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || l10n.localeName.startsWith('ar')) return method;
    if (method.contains('سداد') || method.contains('الراجحي')) {
      return l10n.directBankTransferSadad;
    }
    if (method.contains('المحفظة الضامنة') || method.contains('Escrow')) {
      return l10n.directDebitEscrow;
    }
    if (method.contains('الائتمانية') || method.contains('Mada')) {
      return l10n.creditCardMada;
    }
    if (method.contains('خصم من المحفظة')) return l10n.walletDeduction;
    if (method.contains('الأهلي')) return l10n.directBankTransferSnb;
    return method;
  }

  static String localizeProviderName(BuildContext context, String name) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || l10n.localeName.startsWith('ar')) return name;
    if (name.contains('النخبة')) return l10n.eliteElectronicsStore;
    if (name.contains('ورشة الصيانة')) return l10n.maintenanceWorkshop;
    if (name.contains('VIP')) return l10n.vipUserUpgrade;
    if (name.contains('المندوب السريع')) return l10n.fastCourierPackage;
    if (name.contains('بانر رئيسي')) return l10n.mainBannerAd;
    return name;
  }

  static String localizeCategoryName(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || l10n.localeName.startsWith('ar')) return category;
    if (category.contains('تاجر مميز')) {
      return l10n.featuredMerchantSubscription;
    }
    if (category.contains('خدمات منزلية')) return l10n.homeServicesProvider;
    if (category.contains('مستخدم مميز')) return l10n.premiumUser;
    if (category.contains('مندوب توصيل')) return l10n.deliveryCourier;
    if (category.contains('إعلانات تجارية')) return l10n.commercialAds;
    return category;
  }

  static String? localizeAvailableBalance(
      BuildContext context, String? balance) {
    if (balance == null) return null;
    final l10n = AppLocalizations.of(context);
    if (l10n == null || l10n.localeName.startsWith('ar')) return balance;
    final clean =
        balance.replaceAll('رصيد متاح', '').replaceAll('ج.م', '').trim();
    return '${l10n.availableBalanceLabel}: $clean ${l10n.currencyEgy}';
  }
}
