import 'package:flutter/material.dart';

enum MerchantStatus {
  active,
  activeVerified, // نشط وموثق
  underAudit, // قيد التدقيق
  updateRequired, // تحديث بيانات مطلوب
  temporarilySuspended // معلق مؤقتاً
}

enum MerchantAdvertisementStatus {
  approved,
  awaitingFinance,
  awaitingManagement,
  underReview,
  rejected,
  frozen,
  hidden,
}

class MerchantAdvertisement {
  final String title;
  final String titleEn;
  final String reference;
  final String price;
  final MerchantAdvertisementStatus status;

  const MerchantAdvertisement({
    required this.title,
    required this.titleEn,
    required this.reference,
    required this.price,
    required this.status,
  });

  String getTitle(bool isArabic) => isArabic ? title : titleEn;
}

class MerchantEntity {
  final String id;
  final String? code;
  final String name;
  final String nameEn;
  final String category;
  final String categoryEn;
  final IconData categoryIcon;
  final String crNumber;
  final String? logoUrl;
  final IconData? logoIcon;
  final MerchantStatus status;
  final bool isFeatured;
  final String? statusTagText;
  final String? statusTagTextEn;
  final String? location;
  final String? locationEn;
  final String? delegateName;
  final String? delegateNameEn;
  final String? deliveryStatus;
  final String? deliveryStatusEn;
  final int adsCount;
  final String adsCountLabel;
  final String adsCountLabelEn;
  final String adsSectionTitle;
  final String adsSectionTitleEn;
  final IconData adsIcon;
  final String activityNote;
  final String activityNoteEn;
  final String footerStatusText;
  final String footerStatusTextEn;
  final IconData footerStatusIcon;
  final Color? footerStatusColor;
  final String actionButtonText;
  final String actionButtonTextEn;
  final bool isSuspended;
  final String? ownerName;
  final String? ownerNameEn;
  final String? contactPhone;
  final String? contactEmail;
  final String? joinedDate;
  final String? joinedDateEn;
  final double? commissionPercent;

  /// مبلغ ثابت بالجنيه على كل طلب بدل النسبة (null = نسبة).
  final double? commissionFixedAmount;

  /// percent | fixed | default (النسبة العامة).
  final String commissionType;

  /// النسبة العامة للمنصة (لما التاجر ملوش عمولة خاصة).
  final double? defaultCommissionPercent;

  /// العمولة بالكلام زي ما السيرفر حسبها (خاصة بالتاجر أو العامة اللي حددها رئيس المشرفين).
  final String? commissionLabel;
  final int? activeAdsCount;
  final int? underReviewAdsCount;
  final int? pendingReviewCount;
  final String? financialWithdrawalAlert;
  final String? financialWithdrawalAlertEn;
  final String? violationNotice;
  final String? violationNoticeEn;
  final List<MerchantAdvertisement> recentAdvertisements;
  final List<MerchantAdvertisement> allAdvertisements;

  const MerchantEntity({
    required this.id,
    this.code,
    required this.name,
    required this.nameEn,
    required this.category,
    required this.categoryEn,
    required this.categoryIcon,
    required this.crNumber,
    this.logoUrl,
    this.logoIcon,
    required this.status,
    this.isFeatured = false,
    this.statusTagText,
    this.statusTagTextEn,
    this.location,
    this.locationEn,
    this.delegateName,
    this.delegateNameEn,
    this.deliveryStatus,
    this.deliveryStatusEn,
    required this.adsCount,
    required this.adsCountLabel,
    required this.adsCountLabelEn,
    required this.adsSectionTitle,
    required this.adsSectionTitleEn,
    required this.adsIcon,
    required this.activityNote,
    required this.activityNoteEn,
    required this.footerStatusText,
    required this.footerStatusTextEn,
    required this.footerStatusIcon,
    this.footerStatusColor,
    required this.actionButtonText,
    required this.actionButtonTextEn,
    this.isSuspended = false,
    this.ownerName,
    this.ownerNameEn,
    this.contactPhone,
    this.contactEmail,
    this.joinedDate,
    this.joinedDateEn,
    this.commissionPercent,
    this.commissionFixedAmount,
    this.commissionType = 'default',
    this.defaultCommissionPercent,
    this.commissionLabel,
    this.activeAdsCount,
    this.underReviewAdsCount,
    this.pendingReviewCount,
    this.financialWithdrawalAlert,
    this.financialWithdrawalAlertEn,
    this.violationNotice,
    this.violationNoticeEn,
    this.recentAdvertisements = const [],
    this.allAdvertisements = const [],
  });

  String getCode() => code ?? id;
  String getName(bool isArabic) => isArabic ? name : nameEn;
  String getCategory(bool isArabic) => isArabic ? category : categoryEn;
  String getLocation(bool isArabic) =>
      isArabic ? (location ?? '') : (locationEn ?? location ?? '');
  String getDelegateName(bool isArabic) =>
      isArabic ? (delegateName ?? '') : (delegateNameEn ?? delegateName ?? '');
  String getStatusTagText(bool isArabic) => isArabic
      ? (statusTagText ?? '')
      : (statusTagTextEn ?? statusTagText ?? '');
  String getDeliveryStatus(bool isArabic) => isArabic
      ? (deliveryStatus ?? '')
      : (deliveryStatusEn ?? deliveryStatus ?? '');
  String? getFinancialWithdrawalAlert(bool isArabic) => isArabic
      ? financialWithdrawalAlert
      : (financialWithdrawalAlertEn ?? financialWithdrawalAlert);
  String? getViolationNotice(bool isArabic) =>
      isArabic ? violationNotice : (violationNoticeEn ?? violationNotice);
  String getAdsCountLabel(bool isArabic) =>
      isArabic ? adsCountLabel : adsCountLabelEn;
  String getAdsSectionTitle(bool isArabic) =>
      isArabic ? adsSectionTitle : adsSectionTitleEn;
  String getActivityNote(bool isArabic) =>
      isArabic ? activityNote : activityNoteEn;
  String getFooterStatusText(bool isArabic) =>
      isArabic ? footerStatusText : footerStatusTextEn;
  String getActionButtonText(bool isArabic) =>
      isArabic ? actionButtonText : actionButtonTextEn;
}
