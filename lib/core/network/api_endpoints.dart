/// كل مسارات واجهة Berwah في ملف واحد.
///
/// المسارات نسبية وبدون `/` في أولها، لأن `ApiConsumer` يضمن أن العنوان
/// الأساسي ينتهي بـ `/`.
class ApiEndpoints {
  const ApiEndpoints._();

  // المصادقة

  /// مسار تسجيل الدخول المستخدم حاليًا لكل الأدوار.
  ///
  /// للتحويل إلى [loginForSupervisor] بعد أن يؤكد الباك إند قبوله حسابات
  /// BossOfSupervisor وAccountant، غيّر هذا السطر وحده.
  static const login = accountLogin;

  static const accountLogin = 'api/Account/Login';
  static const loginForSupervisor = '$_supervisorForAd/LoginForSupervisor';
  static const refreshToken = 'api/Account/RefreshToken';

  // مراجعة الإعلانات — SupervisorForAd

  static const _supervisorForAd = 'api/SupervisorForAd';

  static const adStats = '$_supervisorForAd/stats';
  static const adPendingAds = '$_supervisorForAd/pending-ads';
  static const adList = '$_supervisorForAd/ads';

  /// GET لتفاصيل الإعلان، وPUT لتعديل بياناته.
  static String ad(int id) => '$_supervisorForAd/ad/$id';
  static String adUpdateStatus(int id) =>
      '$_supervisorForAd/update-ad-status/$id';
  static String adReject(int id) => '$_supervisorForAd/reject/$id';
  static String adHide(int id) => '$_supervisorForAd/hide/$id';
  static const adReports = '$_supervisorForAd/reports';

  // التجار — SupervisorForMerchant

  static const _supervisorMerchant = 'api/supervisor/merchant';

  static const merchantStats = '$_supervisorMerchant/stats';
  static const merchantList = '$_supervisorMerchant/merchants';
  static const merchantAdd = '$_supervisorMerchant/merchants/add';
  static String merchantProfile(int merchantId) =>
      '$_supervisorMerchant/merchant/$merchantId/profile';
  static String merchantPendingAds(int merchantId) =>
      '$_supervisorMerchant/merchant/$merchantId/pending-ads';
  static String merchantSuspend(int merchantId) =>
      '$_supervisorMerchant/merchant/$merchantId/suspend';
  static String merchantCommission(int merchantId) =>
      '$_supervisorMerchant/merchant/$merchantId/commission';

  static const merchantAdStats = '$_supervisorMerchant/ads/stats';
  static const merchantAdPending = '$_supervisorMerchant/ads/pending';
  static String merchantAdDetails(int id) =>
      '$_supervisorMerchant/ads/$id/details';
  static String merchantAdApprove(int id) =>
      '$_supervisorMerchant/ads/$id/approve';
  static String merchantAdReject(int id) =>
      '$_supervisorMerchant/ads/$id/reject';
  static String merchantAdRequestEdit(int id) =>
      '$_supervisorMerchant/ads/$id/request-edit';

  // طلبات الخدمات — SupervisorForSR

  static const _supervisorForSr = 'api/SupervisorForSR';

  static const serviceStats = '$_supervisorForSr/stats';
  static const servicePending = '$_supervisorForSr/pending';
  static const serviceRequests = '$_supervisorForSr/requests';
  static String serviceDetails(int id) => '$_supervisorForSr/details/$id';
  static String serviceApprove(int id) => '$_supervisorForSr/approve/$id';
  static String serviceReject(int id) => '$_supervisorForSr/reject/$id';
  static String serviceUpdateAndApprove(int id) =>
      '$_supervisorForSr/update-and-approve/$id';
  static String serviceRequestInfo(int id) =>
      '$_supervisorForSr/request-info/$id';
  static String serviceReturnRequest(int id) =>
      '$_supervisorForSr/return-request/$id';
  static String serviceSuspendRequest(int id) =>
      '$_supervisorForSr/suspend-request/$id';
  static String serviceEscalateRequest(int id) =>
      '$_supervisorForSr/escalate-request/$id';
  static String serviceSubcategories(int requestId) =>
      '$_supervisorForSr/subcategories/$requestId';
  static String serviceUpdateCategory(int id) =>
      '$_supervisorForSr/update-category/$id';

  static const serviceProvidersDirectory =
      '$_supervisorForSr/providers-directory';
  static String serviceProviderProfile(int providerId) =>
      '$_supervisorForSr/provider-professional-profile/$providerId';
  static String serviceProviderState(int providerId) =>
      '$_supervisorForSr/provider-state/$providerId';
  static String serviceReassign(int requestId) =>
      '$_supervisorForSr/reassign/$requestId';

  static const serviceComplaintStats = '$_supervisorForSr/complaint/stats';
  static const serviceComplaints = '$_supervisorForSr/list';
  static String serviceComplaintEscalate(int id) =>
      '$_supervisorForSr/escalate/$id';
  static String serviceEnforceCompensation(int id) =>
      '$_supervisorForSr/enforce-compensation/$id';

  static const serviceAdvancedWallet = '$_supervisorForSr/advanced-wallet';
  static const serviceAdvancedWalletWithdraw =
      '$_supervisorForSr/advanced-wallet/withdraw';
  static const serviceAccountSettings = '$_supervisorForSr/account-settings';

  // المستعمل ووصلني — SupervisorUsed

  static const _supervisorUsed = 'api/SupervisorUsed';

  static const usedStats = '$_supervisorUsed/stats';
  static const usedAds = _supervisorUsed;
  static String usedAd(int id) => '$_supervisorUsed/$id';
  static String usedApprove(int id) => '$_supervisorUsed/$id/approve';
  static String usedRequestEdit(int id) => '$_supervisorUsed/$id/request-edit';
  static String usedSuspend(int id) => '$_supervisorUsed/$id/suspend';
  static String usedRejectWithPenalty(int id) =>
      '$_supervisorUsed/$id/reject-with-penalty';

  static const wosallyOrders = '$_supervisorUsed/wosally-orders';
  static String wosallyOrder(int id) => '$_supervisorUsed/wosally-orders/$id';
  static String wosallyApproveAndReveal(int id) =>
      '$_supervisorUsed/wosally-orders/$id/approve-and-reveal';
  static String wosallySendJointAlert(int id) =>
      '$_supervisorUsed/wosally-orders/$id/send-joint-alert';

  static const usedComplaints = '$_supervisorUsed/complaints';
  static String usedComplaintDetails(int id) =>
      '$_supervisorUsed/complaints/$id/details';
  static String usedComplaintFollowUp(int id) =>
      '$_supervisorUsed/complaints/$id/follow-up';
  static String usedComplaintSendToSeller(int id) =>
      '$_supervisorUsed/complaints/$id/send-to-seller';
  static String usedComplaintEscalate(int id) =>
      '$_supervisorUsed/complaints/$id/escalate';

  static const usedWallet = '$_supervisorUsed/wallet';
}
