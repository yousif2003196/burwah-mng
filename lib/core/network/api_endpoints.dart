/// كل مسارات واجهة Berwah في ملف واحد.
///
/// المسارات نسبية وبدون `/` في أولها، لأن `ApiConsumer` يضمن أن العنوان
/// الأساسي ينتهي بـ `/`.
class ApiEndpoints {
  const ApiEndpoints._();

  // المصادقة

  /// دخول المشرفين ورئيس المشرفين (auth.md 3.1). يُجرَّب أولًا.
  static const loginForSupervisor = '$_supervisorForAd/LoginForSupervisor';

  /// دخول الحسابات العامة (Admin وAccountant)؛ يُجرَّب لو رفض
  /// [loginForSupervisor] الحساب.
  static const accountLogin = 'api/Account/Login';

  /// ترتيب مسارات الدخول التي يجربها التطبيق.
  static const loginRoutes = [loginForSupervisor, accountLogin];

  static const refreshToken = 'api/Account/RefreshToken';

  /// يلغي جلسة هذا الجهاز في السيرفر (الجلسات على الأجهزة الأخرى تبقى).
  static const logout = 'api/Account/Logout';

  /// طلبات المصادقة لا يُجدَّد لها التوكن عند 401.
  static const authPaths = {
    loginForSupervisor,
    accountLogin,
    refreshToken,
    logout,
  };

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
  static String adRequestEdit(int id) => '$_supervisorForAd/request-edit/$id';
  static const adMyAccess = '$_supervisorForAd/my-access';

  // محفظة الحساب نفسه (المشرفين): الرصيد وطلبات السحب للمالية.
  static const walletSummary = 'api/Wallet/Summary';
  static const walletWithdraw = 'api/Wallet/Withdraw';
  static const walletMyWithdrawals = 'api/Wallet/MyWithdrawals';
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

  // رئيس المشرفين — BossOfSupervisor

  static const _boss = 'api/BossOfSupervisor';

  static const bossOverview = '$_boss/dashboard-overview';
  static const bossSupervisors = '$_boss/supervisors';
  static const bossAddSupervisor = '$_boss/supervisors/add';
  static String bossSupervisorProfile(int id) => '$_boss/supervisors/$id/profile';
  static String bossSuspendSupervisor(int id) => '$_boss/supervisors/$id/suspend';
  static String bossDeleteSupervisor(int id) =>
      '$_boss/supervisors/$id/delete-permanent';
  static String bossSupervisorPermissions(int id) =>
      '$_boss/supervisors/$id/permissions';
  static String bossReactivateSupervisor(int id) =>
      '$_boss/supervisors/$id/reactivate';
  static String bossResetSupervisorPassword(int id) =>
      '$_boss/supervisors/$id/reset-password';
  static String bossEndSupervisorSessions(int id) =>
      '$_boss/supervisors/$id/end-sessions';
  static String bossSupervisorAuditLog(int id) =>
      '$_boss/supervisors/$id/audit-log';
  static const bossDeletionRequests = '$_boss/deletion-requests';
  static String bossApproveDeletion(int supervisorId) =>
      '$_boss/deletion-requests/$supervisorId/approve';
  static String bossRejectDeletion(int supervisorId) =>
      '$_boss/deletion-requests/$supervisorId/reject';
  static const bossOrdersAndDisputes = '$_boss/orders-and-disputes';
  static String bossReevaluateRequest(int id) => '$_boss/requests/$id/reevaluate';
  static String bossResolveDispute(int id) => '$_boss/disputes/$id/resolve';
  static const bossTickets = '$_boss/tickets';
  static const bossMerchantComplaints = '$_boss/merchant-complaints';
  static String bossMerchantComplaintAction(int id) =>
      '$_boss/merchant-complaints/$id/action';
  static String bossComplaintDetails(int id) => '$_boss/complaints/$id/details';
  static String bossComplaintCompensate(int id) => '$_boss/complaints/$id/compensate';
  static String bossComplaintSuspendProvider(int id) =>
      '$_boss/complaints/$id/suspend-provider';
  static String bossComplaintWarn(int id) => '$_boss/complaints/$id/warn';

  // طلبات صرف من رئيس المشرفين ينفّذها المشرف المالي
  static const financeRequests = 'api/FinanceRequests';
  static String executeFinanceRequest(int id) => 'api/FinanceRequests/$id/execute';
  static String rejectFinanceRequest(int id) => 'api/FinanceRequests/$id/reject';
  static String bossUnbanAndInvestigate(int id) =>
      '$_boss/complaints/$id/unban-and-investigate';
  static String bossComplaintDecision(int id) => '$_boss/complaints/$id/decision';
  static String bossSummonChat(int id) => '$_boss/complaints/$id/summon-chat';
  static String bossComplaintSummonChat(int id) =>
      '$_boss/complaints/$id/summon-chat';
  static String bossComplaintUnbanAndInvestigate(int id) =>
      '$_boss/complaints/$id/unban-and-investigate';
  static const bossProfile = '$_boss/profile';

  /// حساب رئيس المشرفين نفسه.
  static const bossMe = '$_boss/me';
  static const bossMyActivity = '$_boss/me/activity';
  static const bossChangeMyPassword = '$_boss/me/change-password';
  static const bossEndMyOtherSessions = '$_boss/me/end-other-sessions';

  /// إشعار لمستخدمين تطبيق اليوزر (audience = all / customers / merchants / captains).
  static const bossBroadcastUsers = '$_boss/broadcast-users';
  static const bossBroadcastUsersCount = '$_boss/broadcast-users/count';
  /// GET / PUT: نطاق التجار ونطاقات الكباتن (الدراجة لوحدها).
  static const bossRadiusSettings = '$_boss/radius-settings';

  // تصعيدات المشرفين لرئيس المشرفين (منتجات، تجار، شكاوى خدمات)
  static const supervisorEscalations = 'api/SupervisorEscalations';
  static const mySupervisorEscalations = 'api/SupervisorEscalations/mine';
  static String decideSupervisorEscalation(int id) =>
      'api/SupervisorEscalations/$id/decide';
  static const bossWallet = '$_boss/wallet';
  static const bossWalletPayout = '$_boss/wallet/payout';

  /// تعميم/توجيه من رئيس المشرفين للمشرفين (إشعار فوري + سجل).
  static const bossBroadcast = '$_boss/broadcast';

  // فروع سوق برواح — رئيس المشرفين يديرها والأدمن يعتمد حذفها
  static const _branches = 'api/BrowahBranches';
  static const marketBranches = _branches;
  static String marketBranch(int id) => '$_branches/$id';
  static String marketBranchDeleteRequest(int id) => '$_branches/$id/delete-request';
  static const marketBranchDeletionRequests = '$_branches/deletion-requests';
  static String marketBranchApproveDeletion(int id) => '$_branches/$id/approve-deletion';
  static String marketBranchRejectDeletion(int id) => '$_branches/$id/reject-deletion';

  /// محافظات ومدن مصر (نفس قائمة تطبيق اليوزر).
  static const egyptPlaces = 'api/Places/Egypt';

  // طلبات سحب المحافظ — المشرف المالي (Accountant) والأدمن يعتمدونها
  static const _walletAdmin = 'api/Wallet/Admin';
  static const walletAdminWithdrawals = '$_walletAdmin/Withdrawals';
  static String walletAdminWithdrawalApprove(int id) =>
      '$_walletAdmin/Withdrawals/$id/Approve';
  static String walletAdminWithdrawalReject(int id) =>
      '$_walletAdmin/Withdrawals/$id/Reject';
}
