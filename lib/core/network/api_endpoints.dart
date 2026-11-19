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
  static const accountChangePassword = 'api/Account/ChangePassword';
  static const accountSettings = 'api/Account/Settings';
  static const adAuditLog = '$_supervisorForAd/audit-log';

  // التجار — SupervisorForMerchant (مطاعم / بقالة / أكل بيتي)
  static const _supervisorMerchant = 'api/supervisor/merchant';
  static const merchantStats = '$_supervisorMerchant/stats';
  static const merchantList = '$_supervisorMerchant/merchants';
  static String merchantDetails(int id) => '$_supervisorMerchant/merchants/$id';
  static String merchantApprove(int id) => '$_supervisorMerchant/merchants/$id/approve';
  static String merchantReject(int id) => '$_supervisorMerchant/merchants/$id/reject';
  static String merchantRequestInfo(int id) => '$_supervisorMerchant/merchants/$id/request-info';
  static String merchantSuspend(int id) => '$_supervisorMerchant/merchants/$id/suspend';
  static String merchantReactivate(int id) => '$_supervisorMerchant/merchants/$id/reactivate';
  static String merchantCommission(int id) => '$_supervisorMerchant/merchants/$id/commission';
  static String merchantOrders(int id) => '$_supervisorMerchant/merchants/$id/orders';
  static String merchantProductHide(int id) => '$_supervisorMerchant/products/$id/hide';
  static String merchantProductShow(int id) => '$_supervisorMerchant/products/$id/show';
  static const merchantWithdrawals = '$_supervisorMerchant/withdrawals';
  static String merchantWithdrawalRecommend(int id) => '$_supervisorMerchant/withdrawals/$id/recommend';
  static const merchantEvents = '$_supervisorMerchant/events';
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
      '$_supervisorForSr/escalate-request/$id';  static String serviceEscalateProvider(int providerId) =>
      '$_supervisorForSr/escalate-provider/$providerId';
  static const serviceProviderEscalations =
      '$_supervisorForSr/provider-escalations';
  static String serviceCloseProviderEscalation(int providerId) =>
      '$_supervisorForSr/close-provider-escalation/$providerId';
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
  static const serviceAuditLog = '$_supervisorForSr/audit-log';
  static const serviceProfileOverview = '$_supervisorForSr/profile-overview';
  static const serviceReports = '$_supervisorForSr/reports';

  // المستعمل ووصلني — SupervisorUsed

  static const _supervisorUsed = 'api/SupervisorUsed';

  static const usedStats = '$_supervisorUsed/stats';
  static const usedAds = _supervisorUsed;
  static String usedAd(int id) => '$_supervisorUsed/$id';
  static String usedApprove(int id) => '$_supervisorUsed/$id/approve';
  static String usedRequestEdit(int id) => '$_supervisorUsed/$id/request-edit';
  static String usedSuspend(int id) => '$_supervisorUsed/$id/suspend';
  static String usedRestore(int id) => '$_supervisorUsed/$id/restore';

  // طلبات وصلني على المنتجات المستعملة (مراجعة المشرف)
  static const wasalnyRequests = 'api/WasalnyRequest/supervisor';
  static String wasalnyRequest(int id) => '$wasalnyRequests/$id';
  static String wasalnyRequestApprove(int id) => '$wasalnyRequests/$id/approve';
  static String wasalnyRequestReject(int id) => '$wasalnyRequests/$id/reject';
  static String wasalnyRequestFreeze(int id) => '$wasalnyRequests/$id/freeze';
  static String wasalnyRequestReopen(int id) => '$wasalnyRequests/$id/reopen';
  static const usedAuditLog = '$_supervisorUsed/audit-log';
  static const usedReports = '$_supervisorUsed/reports';
  static const usedProfileOverview = '$_supervisorUsed/profile-overview';
  static const usedAdvancedWallet = '$_supervisorUsed/advanced-wallet';
  static const usedComplaintEscalations =
      '$_supervisorUsed/complaint-escalations';
  static String usedComplaintResolve(int id) =>
      '$_supervisorUsed/complaints/$id/resolve';
  static String usedApproveOrder(int orderId) =>
      'api/Order/Admin/ApproveOrder/$orderId';
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
