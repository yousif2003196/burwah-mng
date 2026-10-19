// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'borwah_mng';

  @override
  String get cfoSessionTimestamp => '04/11/1446 AH - 10:45 AM';

  @override
  String get ordersUnit => 'orders';

  @override
  String get financialGovernanceTitle =>
      'Financial Governance and Delegation Policy';

  @override
  String get ongoingOperatingInvoices => 'Ongoing Operating Invoices and Dues';

  @override
  String get completedAndMatched => 'Completed and reconciled 100%';

  @override
  String get switchLanguage => 'Switch language';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirmTitle => 'Confirm sign out';

  @override
  String get logoutConfirmMessage => 'Do you want to sign out of your account?';

  @override
  String get logoutCancel => 'Cancel';

  @override
  String get logoutConfirm => 'Sign out';

  @override
  String get appSubtitle => 'Field Management & Supervision System';

  @override
  String get secureLoginPortal => 'Secure & Encrypted Login Portal';

  @override
  String get workEmail => 'Work Email';

  @override
  String get password => 'Password';

  @override
  String get roleAccessNotice =>
      'System interface and permissions are automatically determined based on your supervisory role upon verification.';

  @override
  String get loginButton => 'Sign In';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get requestAccessReset =>
      'Request access reset via Technical Administrator';

  @override
  String get restrictedAccessFooter =>
      'This app is restricted to management and supervisors only';

  @override
  String get copyrightNotice =>
      'Version 3.4.0 (Internal) • All rights reserved to Browah Al-Mazory Co.';

  @override
  String get certifiedFinancialAuditor => 'Certified Financial Auditor';

  @override
  String get liveFinancialSession => 'Live Financial Session';

  @override
  String get financialControlTitle =>
      'Central Financial Control - Browah Al-Mazory';

  @override
  String get cfoControlPanelSubtitle =>
      'CFO Dashboard | Active Financial Shift & Real-Time Liquidity Reconciliation';

  @override
  String get cfoName => 'Mr. Sulaiman Al-Rajhi';

  @override
  String get cfoRole => 'Executive Chief Financial Officer';

  @override
  String get cfoBadgeCode => '#CF0-01';

  @override
  String get currencyEgy => 'Egy';

  @override
  String get totalAggregatedLiquidity =>
      'Total Cash Liquidity & Aggregated Escrow';

  @override
  String get alRajhiMainOperating => 'Al Rajhi Bank (Main Operating Account)';

  @override
  String get snbEscrowAccount =>
      'Saudi National Bank - SNB (Commercial Escrow Account)';

  @override
  String get pendingMerchantWithdrawalsTitle =>
      'Pending Withdrawal Requests Under Review for Merchants & Users';

  @override
  String get pendingSupervisorWithdrawalsTitle =>
      'Pending Withdrawal Requests Under Review for Supervisors & Assistants';

  @override
  String get auditInvoiceNote =>
      'Requires invoice auditing and reconciliation prior to signature';

  @override
  String get pendingSubscriptionsTitle =>
      'Pending Subscription & Upgrade Requests';

  @override
  String get pendingSubscriptionsSubtitle =>
      'Store plan upgrades, technician subscriptions, and annual renewals awaiting financial approval';

  @override
  String get reviewSubscriptionsAction => 'Review & Approve Subscriptions';

  @override
  String get operationalExpenses => 'Operational Expenses & Disbursements';

  @override
  String get expensesManagementTitle => 'Expenses and Payments';

  @override
  String get amountToDisburse => 'Amount to pay and disburse';

  @override
  String get accountAndPaymentChannel => 'Account and direct-payment channel';

  @override
  String get noAccountsAvailable => 'No accounts are available';

  @override
  String get escrowBalanceLabel => 'Escrow account balance:';

  @override
  String get currentLedgerBalanceLabel => 'Current ledger balance:';

  @override
  String get expenseCategoryAndDocuments =>
      'Expense category and supporting documents';

  @override
  String get detailedExpenseReason => 'Detailed reason for the expense';

  @override
  String get expenseDetailsHint =>
      'Enter a detailed description of the expense';

  @override
  String get invoiceSupportDocument => 'Tax invoice and supporting document';

  @override
  String get attachDocumentOptional => 'Attach a document image (optional)';

  @override
  String get expenseReasonRequired => 'Please enter the expense reason first';

  @override
  String get expenseAmountInvalid => 'Enter a valid amount greater than zero';

  @override
  String get expenseRequestPendingStatus => 'Awaiting admin approval';

  @override
  String get expenseRequestNumber => 'Request ID';

  @override
  String get expenseRequestAmount => 'Amount';

  @override
  String get expenseRequestSent =>
      'The expense request was sent to management for approval. The account balance was not changed.';

  @override
  String get expenseRequestSendFailed =>
      'Could not send the expense request. Please try again.';

  @override
  String get expenseRequestSubmitting => 'Sending request...';

  @override
  String get expenseConfirmTitle => 'Submit expense request';

  @override
  String get expenseConfirmDescription =>
      'The expense request will be sent to management for review and approval. No amount will be deducted yet.';

  @override
  String get expenseAttachedPrefix => 'Attached';

  @override
  String get expenseRemoveDocumentAction => 'tap to remove';

  @override
  String get expenseDocumentAttached => 'Document attached';

  @override
  String get expenseDocumentRemoved => 'Attached document removed';

  @override
  String get strictFinancialDisbursementGovernance =>
      'Strict financial disbursement governance';

  @override
  String get disbursementGovernanceNote =>
      'This operation is subject to document review and automated bank reconciliation. The payment order is recorded in the financial audit log with an encrypted tracking number and requires the CFO\'s direct digital signature.';

  @override
  String get approvePaymentOrder =>
      'Approve payment order and send to management';

  @override
  String get cancelPaymentOrder => 'Cancel and withdraw the payment order';

  @override
  String get paymentApprovedSuccessfully =>
      'Payment order approved successfully';

  @override
  String get monthlyTotalExpenses => 'Total Monthly Disbursements';

  @override
  String get expenseManagement => 'Disbursement Mgmt';

  @override
  String get scheduledDisbursementItems => '4 Scheduled Disbursement Items';

  @override
  String get recordNewPayment =>
      'Record New Payment Entry / Expense Management';

  @override
  String get monthlyEarnedCommissions =>
      'Application Commissions Earned This Month';

  @override
  String get netRegulatoryRevenue => 'Net Regulatory Revenue';

  @override
  String get comparedToLastMonth => 'Compared to last month (Egy 249,450)';

  @override
  String get balancesUnderRegulatoryAudit =>
      'Balances Held Under Regulatory Audit';

  @override
  String get frozenWalletsNote =>
      'Wallets frozen precautionarily by General Management and Supervisors due to open dispute reports.';

  @override
  String get operationalDepartmentsWallets =>
      'Direct Operational Department Wallets';

  @override
  String get activeSectorsCount => '4 Active Sectors';

  @override
  String get merchantsWalletTitle => 'Merchants & Stores Department Wallet';

  @override
  String get merchantsWalletDesc =>
      'Periodic balance available for bank settlement and withdrawal';

  @override
  String get usedAndEscrowWalletTitle =>
      'Used Goods & \'Wasalny\' Down Payment Wallet';

  @override
  String get usedAndEscrowWalletDesc =>
      'Active transaction guarantee and escrow account (Escrow)';

  @override
  String get servicesMaintenanceWalletTitle =>
      'Services & Maintenance Orders Wallet';

  @override
  String get servicesMaintenanceWalletDesc =>
      'Dues for certified technicians and service providers';

  @override
  String get servicesSupervisorRoleBadge => 'Services Supervisor';

  @override
  String get servicesSupervisorBadgeCode => '#SRV-01';

  @override
  String get servicesSupervisorAccountName => 'Services Supervisor';

  @override
  String get servicesProfileTitle => 'My Profile';

  @override
  String get servicesProfileName => 'Abdulaziz bin Khalid Al-Salem';

  @override
  String get servicesProfileIdentity => 'Senior Field Supervisor · Services';

  @override
  String get servicesProfileCoverage =>
      'Coverage: Riyadh and neighboring areas';

  @override
  String get servicesProfileAvailability =>
      'On duty — available for assignments';

  @override
  String get servicesProfileCompletedTasks => 'Completed requests';

  @override
  String get servicesProfileFieldTasks => 'Verified field tasks';

  @override
  String get servicesProfilePerformanceRating => 'Performance rating';

  @override
  String get servicesProfileRatingDetail => 'Excellent · Last 120 tasks';

  @override
  String get servicesProfileAssignmentTime => 'Average assignment time';

  @override
  String get servicesProfileMinutes => 'minutes';

  @override
  String get servicesProfileComplaintResolution => 'Complaint resolution';

  @override
  String get servicesProfileResolutionDetail => 'Within target';

  @override
  String get servicesProfileDemoMetricsNotice =>
      'Profile details, performance metrics, and balances are demo values until an approved data source is connected.';

  @override
  String get servicesProfileLoadError =>
      'Could not load profile details saved on this device.';

  @override
  String get servicesProfileWalletTitle => 'Dues and commissions wallet';

  @override
  String get servicesProfileWalletDescription =>
      'Manage dues and withdraw earnings';

  @override
  String get servicesProfileAvailableBalance => 'Available to withdraw';

  @override
  String get servicesProfilePendingDues => 'Pending settlement';

  @override
  String get servicesProfileCurrency => 'SAR';

  @override
  String get servicesProfileOpenWallet => 'Open wallet and withdraw';

  @override
  String get servicesProfileWalletDetails =>
      'Review your available balance and pending dues from the wallet page.';

  @override
  String get servicesAccountEditProfile => 'Account and notification settings';

  @override
  String get servicesAccountName => 'Name';

  @override
  String get servicesAccountPhone => 'Phone number';

  @override
  String get servicesAccountCoverage => 'Coverage area';

  @override
  String get servicesAccountSave => 'Save';

  @override
  String get servicesAccountSaved => 'Changes saved on this device';

  @override
  String servicesAccountSaveError(Object error) {
    return 'Could not save changes: $error';
  }

  @override
  String get servicesAccountLoadError => 'Could not load local account data.';

  @override
  String get servicesAccountRetry => 'Retry';

  @override
  String get servicesAccountNameRequired => 'Enter a name.';

  @override
  String get servicesAccountLocalOnly =>
      'These details are stored on this device only and do not update the server account.';

  @override
  String get servicesAccountNotificationsTitle => 'Notification preferences';

  @override
  String get servicesAccountAssignmentAlerts => 'Service assignment alerts';

  @override
  String get servicesAccountComplaintAlerts => 'Complaint updates';

  @override
  String get servicesAccountSystemAlerts => 'Administrative notices';

  @override
  String get servicesAccountPreferencesLocalOnly =>
      'Preferences are stored locally and are not connected to a notification service.';

  @override
  String get servicesAccountWalletTitle => 'Wallet and transactions';

  @override
  String get servicesAccountWalletUnavailable => 'Wallet is not connected';

  @override
  String get servicesAccountWalletUnavailableDetails =>
      'An approved financial service must be connected to show balances or submit withdrawals. No transactions can be made in this build.';

  @override
  String get servicesAccountActivityTitle => 'Account activity';

  @override
  String get servicesAccountNoActivity => 'No activity has been recorded yet.';

  @override
  String get servicesAccountActivityLocalOnly =>
      'This history is stored on this device and is not a centralized audit log.';

  @override
  String get servicesAccountActivityProfileUpdated => 'Profile details updated';

  @override
  String get servicesAccountActivityPreferencesUpdated =>
      'Notification preferences updated';

  @override
  String get servicesAccountActivityOther => 'Account activity';

  @override
  String get servicesAccountLogoutTitle => 'Sign out';

  @override
  String get servicesAccountLogoutMessage =>
      'Do you want to sign out of the services supervisor account?';

  @override
  String get servicesWalletBack => 'Back';

  @override
  String get servicesWalletTitle => 'My wallet and transactions';

  @override
  String get servicesWalletSummaryTitle => 'Wallet summary';

  @override
  String get servicesWalletLiveUpdate => 'Demo data';

  @override
  String get servicesWalletTotalBalance => 'Total balance';

  @override
  String get servicesWalletAvailable => 'Available balance';

  @override
  String get servicesWalletReadyForTransfer => 'Ready for transfer';

  @override
  String get servicesWalletPending => 'Pending dues';

  @override
  String get servicesWalletExpectedThisWeek => 'Expected this week';

  @override
  String get servicesWalletMonthlyCommissions => 'Current month commissions';

  @override
  String get servicesWalletWithdrawalTitle => 'Request a withdrawal';

  @override
  String get servicesWalletAmountLabel => 'Withdrawal amount';

  @override
  String get servicesWalletMaxAmount => 'Maximum';

  @override
  String get servicesWalletMethodTitle => 'Choose a transfer method';

  @override
  String get servicesWalletInstapay => 'InstaPay transfer';

  @override
  String get servicesWalletInstapayDetails => 'Instant transfer to account';

  @override
  String get servicesWalletInstapayId => 'InstaPay ID';

  @override
  String get servicesWalletMobileWallet => 'Mobile wallet';

  @override
  String get servicesWalletMobileWalletDetails => 'Transfer to a phone number';

  @override
  String get servicesWalletMobileNumber => 'Phone number';

  @override
  String get servicesWalletBank => 'Bank transfer';

  @override
  String get servicesWalletBankDetails => 'Deposit to bank account';

  @override
  String get servicesWalletBankAccount => 'Bank account number';

  @override
  String get servicesWalletReviewNote =>
      'Requests are recorded for financial-supervisor review. A transfer or deposit will not occur until approval and payment-service integration.';

  @override
  String get servicesWalletSubmit => 'Submit withdrawal request';

  @override
  String get financeWalletWithdrawal => 'Withdrawal';

  @override
  String get financeWalletDeposit => 'Deposit';

  @override
  String get financeWalletDepositTitle => 'Request a wallet deposit';

  @override
  String get financeWalletSubmitDeposit => 'Submit deposit request';

  @override
  String get financeWalletWithdrawalNote =>
      'The request will remain pending and no money will be transferred until the financial supervisor approves it.';

  @override
  String get financeWalletDepositNote =>
      'The requested amount will not be added to your balance until the financial supervisor approves it.';

  @override
  String get financeWalletConfirmWithdrawal => 'Confirm withdrawal request';

  @override
  String get financeWalletConfirmDeposit => 'Confirm deposit request';

  @override
  String financeWalletConfirmWithdrawalMessage(Object amount, Object currency) {
    return 'Send a withdrawal request for $amount $currency to the financial supervisor?';
  }

  @override
  String financeWalletConfirmDepositMessage(Object amount, Object currency) {
    return 'Send a deposit request for $amount $currency to the financial supervisor?';
  }

  @override
  String get financeWalletInvalidDepositAmount =>
      'Enter a valid amount greater than zero.';

  @override
  String get financeWalletWithdrawalRequestSent =>
      'Withdrawal request sent to the financial supervisor. It is pending approval.';

  @override
  String get financeWalletDepositRequestSent =>
      'Deposit request sent to the financial supervisor. It is pending approval.';

  @override
  String get financeWalletRequestFailed =>
      'Could not submit the financial request. Please try again.';

  @override
  String get financeWalletHistoryLoadError =>
      'Could not load your financial requests. Tap to retry.';

  @override
  String get financeWalletNoRequests =>
      'You have not submitted any financial requests.';

  @override
  String financeWalletPendingNotification(Object count) {
    return '$count new supervisor financial request(s) await your review.';
  }

  @override
  String get financeOperationType => 'Operation type';

  @override
  String get financeSourceAccount => 'Requesting account';

  @override
  String get financeRequestApprovalTitle => 'Approve financial request';

  @override
  String get financeRequestRejectionTitle => 'Reject financial request';

  @override
  String financeRequestApprovalConfirmation(
      Object operation, Object name, Object amount) {
    return 'Approve this $operation request for $name ($amount)?';
  }

  @override
  String get financeRequestApproved =>
      'Request approved. Actual payment or balance posting still requires payment-service integration.';

  @override
  String get financeRequestApprovedBadge => 'Approved';

  @override
  String get financeRequestRejected => 'Financial request rejected.';

  @override
  String get financeRequestRejectedBadge => 'Rejected';

  @override
  String get financeRequestFrozen =>
      'Financial request frozen for investigation.';

  @override
  String get financeRequestDecisionFailed =>
      'Could not save the decision. The request was not changed.';

  @override
  String get servicesWalletHistoryTitle => 'Transaction history';

  @override
  String get servicesWalletFullStatement => 'View all';

  @override
  String get servicesWalletStatementNotice =>
      'This device-local request history is not synced to a server or financial service.';

  @override
  String get servicesWalletHistoryInstapay => 'InstaPay transfer';

  @override
  String get servicesWalletHistoryOneDate => 'Today · 10:30 AM';

  @override
  String get servicesWalletStatusCompleted => 'Completed';

  @override
  String get servicesWalletHistoryBank => 'Bank transfer';

  @override
  String get servicesWalletHistoryTwoDate => 'Yesterday · 02:15 PM';

  @override
  String get servicesWalletHistoryReview => 'Withdrawal request';

  @override
  String get servicesWalletHistoryThreeDate => 'May 18, 2025 · 11:20 AM';

  @override
  String get servicesWalletHistoryNewRequest => 'New withdrawal request';

  @override
  String get servicesWalletHistoryJustNow => 'Just now';

  @override
  String get servicesWalletStatusReview => 'Under review';

  @override
  String get servicesWalletComplianceTitle => 'Compliance notice';

  @override
  String get servicesWalletComplianceBody =>
      'Balances are demo values. Requests are saved locally for financial-supervisor approval; no real transfer, deposit, push notification, or server request occurs.';

  @override
  String get servicesWalletAmountError =>
      'Enter an amount greater than zero and no more than the available balance.';

  @override
  String get servicesWalletDestinationError =>
      'Enter destination details before submitting the request.';

  @override
  String get servicesWalletConfirmTitle => 'Confirm withdrawal request';

  @override
  String servicesWalletConfirmMessage(Object amount, Object currency) {
    return 'Add a withdrawal request for $amount $currency to the demo history?';
  }

  @override
  String get servicesWalletRequestSent =>
      'Added to the demo history only; nothing was sent to a financial provider.';

  @override
  String get servicesProfileAdministrationTitle =>
      'Administrative details and credentials';

  @override
  String get servicesProfileDelegationTitle =>
      'Professional delegation and supervision';

  @override
  String get servicesProfileDelegationDetail => 'Valid through 1447/06/30 AH';

  @override
  String get servicesProfileActive => 'Active';

  @override
  String get servicesProfileNotificationsTitle => 'Instant complaint alerts';

  @override
  String get servicesProfileNotificationsDetail =>
      'Immediate alerts for high-priority tasks';

  @override
  String get servicesProfileEnabled => 'Enabled';

  @override
  String get servicesProfileAuditTitle => 'Supervisor activity and audit log';

  @override
  String get servicesProfileAuditDetail =>
      'Field operations and supervisory activity records';

  @override
  String get servicesProfileLogout => 'Sign out of supervisor session';

  @override
  String get servicesProfileFooter =>
      'Field Services Management Portal · Version 2.4.1';

  @override
  String get servicesReviewTab => 'Under Review';

  @override
  String get servicesProvidersTab => 'Service Providers';

  @override
  String get servicesComplaintsTab => 'Complaints';

  @override
  String get servicesReviewTitle => 'Service requests under review';

  @override
  String get servicesReviewSubtitle =>
      'Review requests, verify technical work, and assign operations';

  @override
  String servicesNewRequestsCount(Object count) {
    return '$count new';
  }

  @override
  String get servicesCompletedToday => 'Approved requests';

  @override
  String get servicesAwaitingDecision => 'Awaiting decision';

  @override
  String get servicesFilterAll => 'All';

  @override
  String get servicesFilterMaintenance => 'Maintenance & appliances';

  @override
  String get servicesFilterElectrical => 'Electrical & wiring';

  @override
  String get servicesFilterMoving => 'Moving & setup';

  @override
  String get servicesRequestsEmpty =>
      'There are no requests matching this category.';

  @override
  String get servicesUnderReview => 'Under review';

  @override
  String get servicesUrgent => 'Urgent';

  @override
  String get servicesVerifiedProvider => 'Verified technician';

  @override
  String get servicesWorkDescription => 'Requested work:';

  @override
  String get servicesCurrency => 'SAR';

  @override
  String get servicesUrgentNotice =>
      'Field delay alert: please review the appointment and contact the service provider.';

  @override
  String get servicesApproveAction => 'Accept request';

  @override
  String get servicesRejectAction => 'Reject request';

  @override
  String get servicesViewDetails => 'View technical request details';

  @override
  String get servicesApproveTitle => 'Are you sure you want to accept?';

  @override
  String get servicesRejectTitle => 'Reject service request';

  @override
  String get servicesApproveMessage =>
      'The request will be accepted and removed from the current review queue.';

  @override
  String get servicesRejectMessage =>
      'The request will be rejected and removed from the current review queue.';

  @override
  String get servicesRequestApproved =>
      'The request status was updated in the review queue.';

  @override
  String get servicesRequestRejected => 'The request was rejected.';

  @override
  String servicesRequestRejectedWithReason(String reason) {
    return 'The request was rejected. Reason: $reason';
  }

  @override
  String get servicesFeaturedRequest => 'Featured request';

  @override
  String get servicesCommentAction => 'Comment';

  @override
  String get servicesCommentTitle => 'Add a request comment';

  @override
  String get servicesCommentHint =>
      'Write your comment or notes about this request...';

  @override
  String get servicesCommentSave => 'Save comment';

  @override
  String get servicesCommentSaved => 'The comment was saved to the request.';

  @override
  String get servicesDecisionProvider => 'Service provider';

  @override
  String get servicesDecisionDiagnosticFee => 'Estimated fee';

  @override
  String get servicesApprovalNotification =>
      'The customer and provider will be notified that the request is accepted and ready for service.';

  @override
  String get servicesApproveConfirmPublish => 'Confirm publish and accept';

  @override
  String get servicesRejectionQuickReasons => 'Quick reasons';

  @override
  String get servicesRejectionReasonScope => 'Outside service area';

  @override
  String get servicesRejectionReasonDetails => 'Incomplete work details';

  @override
  String get servicesRejectionReasonTerms => 'Violates service terms';

  @override
  String get servicesRejectionReasonLabel => 'Required rejection reason';

  @override
  String get servicesRejectionReasonHint =>
      'Describe the reason for rejection...';

  @override
  String get servicesRejectionAuditNote =>
      'The rejection reason will be recorded and shared with the customer in the request history.';

  @override
  String get servicesRejectConfirm => 'Confirm request rejection';

  @override
  String get servicesProvidersComingSoon =>
      'The service provider management and approval page will be prepared in the next phase.';

  @override
  String get servicesProvidersPortalBadge =>
      'Field assignment and screening portal';

  @override
  String get servicesProvidersTitle => 'Available service providers';

  @override
  String get servicesProvidersSubtitle =>
      'Database of approved and trusted service providers ready for matching and direct assignment';

  @override
  String get servicesCertifiedProviders => 'Certified providers';

  @override
  String get servicesAvailableNow => 'Available now';

  @override
  String get servicesCommitmentRate => 'Commitment rate';

  @override
  String get servicesProvidersSearchHint =>
      'Search by name, registration, specialty, or district...';

  @override
  String get servicesProvidersClearSearch => 'Clear search';

  @override
  String get servicesProvidersFilterPlumbing => 'Plumbing';

  @override
  String get servicesProvidersEmpty =>
      'No service providers match the selected search or category.';

  @override
  String get servicesProvidersAvailable => 'Available now';

  @override
  String get servicesProvidersBusy => 'Currently on a job';

  @override
  String get servicesProvidersCommercialRegister => 'Verified registration';

  @override
  String get servicesProvidersLicense => 'Approved professional license';

  @override
  String get servicesProvidersServiceTerms => 'Responds within 15 min';

  @override
  String get servicesProvidersExecutionWindow =>
      'Available in 2 hours (about 3:30 PM)';

  @override
  String servicesProvidersTasksCount(Object count) {
    return '$count completed tasks';
  }

  @override
  String servicesProvidersCommitment(Object rate) {
    return '$rate commitment';
  }

  @override
  String get servicesProvidersViewProfile => 'View provider profile and record';

  @override
  String get servicesProvidersGovernanceTitle => 'Provider records governance';

  @override
  String get servicesProvidersGovernanceMessage =>
      'Field supervisors can screen, match, and assign requests. Editing permanent records or approving new providers requires electronic authorization from central provider and licensing administration.';

  @override
  String get servicesProvidersSpecialty => 'Technical specialty';

  @override
  String get servicesProvidersRegisteredSkills => 'Registered skills';

  @override
  String get servicesProvidersCoverage => 'Coverage area';

  @override
  String get servicesProvidersRating => 'Customer rating';

  @override
  String get servicesProvidersCompletedTasks => 'Completed tasks';

  @override
  String get servicesProvidersSampleProfileNotice =>
      'Profile and record data are samples and need to be connected to provider records.';

  @override
  String get servicesProviderProfileTitle => 'Provider profile and work record';

  @override
  String get servicesProviderProfileRegistryNumber => 'Provider ID';

  @override
  String get servicesProviderProfileVerified =>
      'Provider details and credentials verified';

  @override
  String get servicesProviderProfileFeatured => 'Featured provider';

  @override
  String get servicesProviderProfileNeedsReview => 'Needs review';

  @override
  String get servicesProviderProfileCall => 'Call';

  @override
  String get servicesProviderProfileChat => 'Chat';

  @override
  String get servicesProviderProfileCallUnavailable =>
      'A phone call could not be started on this device.';

  @override
  String get servicesProviderProfileCertifications =>
      'Licenses and certifications';

  @override
  String get servicesProviderProfileSpecialties =>
      'Specialties and field teams';

  @override
  String get servicesProviderProfileFieldTeam => 'Field team';

  @override
  String get servicesProviderProfileApprovedTeam =>
      'Approved team available for assignment';

  @override
  String get servicesProviderProfileRecentTasks =>
      'Recent completed tasks and operations';

  @override
  String get servicesProviderProfileTaskDetail =>
      'Service completed and reviewed by the customer.';

  @override
  String get servicesProviderProfileTaskCompleted => 'Completed';

  @override
  String get servicesProviderProfileTaskRecord => 'View record';

  @override
  String get servicesProviderProfileCompletedTasksDetail => 'Documented tasks';

  @override
  String get servicesProviderProfileRatingDetail => 'Customer rating';

  @override
  String get servicesProviderProfileCommitmentDetail =>
      'On-time commitment rate';

  @override
  String get servicesProviderProfileResponseTime => 'Response time';

  @override
  String get servicesProviderProfileMinutes => 'minutes';

  @override
  String get servicesChatsTitle => 'Service chats';

  @override
  String get servicesComplaintsTitle => 'Service complaints and reports';

  @override
  String get servicesComplaintsSubtitle =>
      'Resolve field disputes and ensure service quality and warranty coverage';

  @override
  String get servicesComplaintActive => 'Active complaints';

  @override
  String get servicesComplaintUrgent => 'Urgent';

  @override
  String get servicesComplaintPriorityMedium => 'Medium priority';

  @override
  String get servicesComplaintResolutionTime => 'Average resolution';

  @override
  String get servicesComplaintMinutes => 'minutes';

  @override
  String get servicesComplaintSatisfaction => 'Customer satisfaction';

  @override
  String get servicesComplaintApproved => 'Approved satisfaction';

  @override
  String get servicesComplaintSearchHint =>
      'Search by complaint ID, client or provider...';

  @override
  String get servicesComplaintFilterAll => 'All';

  @override
  String get servicesComplaintFilterInvestigating => 'Investigating';

  @override
  String get servicesComplaintFilterWaiting => 'Awaiting response';

  @override
  String get servicesComplaintFilterClosed => 'Resolved';

  @override
  String get servicesComplaintNoResults =>
      'No complaints match this search or filter.';

  @override
  String servicesComplaintAgeMinutes(int count) {
    return '$count minutes ago';
  }

  @override
  String servicesComplaintAgeHours(int count) {
    return '$count hours ago';
  }

  @override
  String get servicesComplaintClient => 'Reporting client';

  @override
  String get servicesComplaintProvider => 'Reported provider';

  @override
  String get servicesComplaintClientOne => 'Dr. Maha Al-Dubaisi';

  @override
  String get servicesComplaintClientTwo => 'Sarah Al-Otaibi';

  @override
  String get servicesComplaintClientThree => 'Client Fahd';

  @override
  String get servicesComplaintProviderOne => 'Precision Cooling Establishment';

  @override
  String get servicesComplaintProviderTwo => 'Comprehensive Excellence Team';

  @override
  String get servicesComplaintProviderThree => 'Fahd Al-Arjahi';

  @override
  String servicesComplaintProviderId(String id) {
    return 'Linked request: $id';
  }

  @override
  String get servicesComplaintRiyadh => 'Riyadh';

  @override
  String get servicesComplaintSubjectOne => 'Split AC maintenance and cooling';

  @override
  String get servicesComplaintDescriptionOne =>
      'Persistent water leakage from the indoor unit after maintenance. The report is under review and a field inspection is being scheduled to verify warranty work.';

  @override
  String get servicesComplaintSubjectTwo =>
      'Electrical upgrades and smart settings';

  @override
  String get servicesComplaintDescriptionTwo =>
      'The field visit missed its scheduled time by a full hour without an apology or prior notice about the technician\'s delay.';

  @override
  String get servicesComplaintSubjectThree =>
      'Bedroom furniture moving and installation';

  @override
  String get servicesComplaintDescriptionThree =>
      'The issue was addressed and approved after the client confirmed service delivery.';

  @override
  String get servicesComplaintLocationOne => 'Al Narjis District, Riyadh';

  @override
  String get servicesComplaintLocationTwo => 'Al Malqa District, Riyadh';

  @override
  String get servicesComplaintLocationThree => 'Al Yasmin District, Riyadh';

  @override
  String get servicesComplaintPriceOne => '280';

  @override
  String get servicesComplaintPriceTwo => '450';

  @override
  String get servicesComplaintPriceThree => '1,200';

  @override
  String get servicesComplaintClosedToday => 'Closed today at 11:30 AM';

  @override
  String get servicesComplaintUnderReview => 'Under supervisor review';

  @override
  String get servicesComplaintWaitingProvider => 'Awaiting provider response';

  @override
  String get servicesComplaintClosed => 'Resolved and closed';

  @override
  String get servicesComplaintInvestigateAndResolve =>
      'Inspect, investigate and resolve';

  @override
  String get servicesComplaintContactParties => 'Contact both parties';

  @override
  String servicesComplaintGroupChatTitle(String id) {
    return 'Complaint $id group chat';
  }

  @override
  String get servicesComplaintReassign => 'Reassign immediately';

  @override
  String get servicesComplaintEscalate => 'Escalate to chief supervisor';

  @override
  String get servicesComplaintShowResolution => 'View settlement record';

  @override
  String get servicesComplaintResolutionRecorded =>
      'Approved supervisory action: The issue was resolved onsite and compensation was credited to the client for the delay.';

  @override
  String get servicesComplaintClosedAudit => 'Closed audit record — read only';

  @override
  String get servicesComplaintResolutionTitle =>
      'Quality resolution for field disputes';

  @override
  String get servicesComplaintResolutionDescription =>
      'The services supervisor can settle disputes, schedule service visits and manage warranty actions, including reassignment to an alternative provider.';

  @override
  String get servicesComplaintDetails => 'Complaint details';

  @override
  String get servicesComplaintActionConfirmation =>
      'This action will be recorded in the complaint history and notify the related parties. Continue?';

  @override
  String get servicesComplaintEscalationConfirmation =>
      'The complaint will be referred to the chief supervisor for review. Escalate now?';

  @override
  String get servicesComplaintEscalated => 'Escalated';

  @override
  String servicesComplaintEscalatedNotice(String id) {
    return 'Complaint $id was escalated to the chief supervisor.';
  }

  @override
  String get servicesComplaintContactNotice =>
      'Contact options for the client and service provider are ready.';

  @override
  String get servicesComplaintActionRecorded =>
      'The action was recorded and the parties were notified.';

  @override
  String get servicesNoNewNotifications => 'There are no new notifications.';

  @override
  String get servicesNotificationsTitle => 'Notifications';

  @override
  String get servicesDetailsTitle => 'Request preview and details';

  @override
  String get servicesRequestWorkDetailsTitle => 'Service scope and location';

  @override
  String get servicesRequestLocationLabel => 'Service address';

  @override
  String get servicesRequestPhotosTitle => 'Attached service photos';

  @override
  String get servicesRequestNoPhotos =>
      'No photos are attached to this request.';

  @override
  String get servicesRequestAssignmentTitle =>
      'Assign the service to a provider';

  @override
  String get servicesRequestAssignmentDescription =>
      'Choose an available provider matching the service category from the providers list.';

  @override
  String get servicesRequestChooseProvider => 'Choose a service provider';

  @override
  String get servicesRequestNoMatchingProviders =>
      'No providers are currently available for this category.';

  @override
  String get servicesRequestAssignProvider => 'Assign service';

  @override
  String servicesRequestAssigned(String provider) {
    return 'Service assigned to $provider';
  }

  @override
  String get servicesComplaintPartiesTitle => 'Dispute parties and contact';

  @override
  String get servicesComplaintProblemTitle => 'Reported problem';

  @override
  String get servicesComplaintFiledBy => 'Reporting party';

  @override
  String get servicesComplaintServiceInfoTitle => 'Disputed service details';

  @override
  String get servicesComplaintPriceLabel => 'Service price';

  @override
  String get servicesComplaintPhotosTitle => 'Attached problem photos';

  @override
  String get servicesComplaintNoPhotos =>
      'No photos are attached to this complaint.';

  @override
  String get servicesBackToRequests => 'Back to requests';

  @override
  String get servicesCallPhone => 'Call';

  @override
  String get servicesContactWhatsApp => 'WhatsApp';

  @override
  String get servicesEstimatedCost => 'Estimated service cost';

  @override
  String get servicesApprovedEstimate => 'Approved estimate';

  @override
  String get servicesEstimatedCostTotal => 'Estimated total cost';

  @override
  String get servicesInspectionFee => 'Initial inspection fee';

  @override
  String get servicesLaborAndPartsFee => 'Labor and parts';

  @override
  String get servicesRequestMoreInfoTitle =>
      'Request additional information from customer';

  @override
  String get servicesRequestMoreInfoDescription =>
      'If request details are unclear or additional information is needed to complete the review before assignment, send the customer a direct question.';

  @override
  String get servicesRequestMoreInfoHint =>
      'Enter your question or the details needed from the customer...';

  @override
  String get servicesRequireExtraPhotos =>
      'Require additional supporting photos';

  @override
  String get servicesSendInfoRequest => 'Send request';

  @override
  String get servicesInfoRequestRequired =>
      'Enter the requested information before sending.';

  @override
  String get servicesInfoRequestSent =>
      'The information request was sent to the customer.';

  @override
  String get servicesEditClassification =>
      'Edit technical service classification';

  @override
  String get servicesCurrentClassification => 'Current approved classification';

  @override
  String get servicesApprovedClassification => 'Approved classification';

  @override
  String get servicesExecutionPeriod => 'Preferred execution period';

  @override
  String get servicesDayPeriod => 'Daytime (9:00 AM - 1:00 PM)';

  @override
  String get servicesEveningPeriod => 'Evening (4:00 PM - 9:00 PM)';

  @override
  String get servicesSaveClassification => 'Update and save classification';

  @override
  String get servicesClassificationSaved =>
      'Service classification and period saved.';

  @override
  String get servicesContactUnavailable =>
      'Could not start contact from this device.';

  @override
  String get servicesPublishConfirm => 'Confirm request publication';

  @override
  String get deliveryLogisticsWalletTitle =>
      'Delivery Couriers & Logistics Wallet';

  @override
  String get deliveryLogisticsWalletDesc =>
      'Field delivery and shipping fees and dues';

  @override
  String get instantLiquidityAdequacyRatio =>
      'Instant Banking Liquidity Adequacy Ratio';

  @override
  String get verySafeAndStable => 'Very Safe & Stable';

  @override
  String get dailyWithdrawalCoverageRatio =>
      'Daily Withdrawal Request Coverage Ratio';

  @override
  String get excessCashCoverage => 'Surplus Cash Coverage';

  @override
  String get statutoryMinimumRequirement =>
      'Statutory Minimum Requirement: 85.0%';

  @override
  String get autoBankingSettlement =>
      'Automatic banking settlement via SADAD & SARIE: 100% Completed and Reconciled';

  @override
  String get governancePolicyNotice =>
      'Pursuant to governance policy: Field supervisors and department heads have no authority to alter balances, withdraw, or transfer funds. Execution and documentation of financial transactions are strictly restricted to the authorized CFO under an official bank delegation number.';

  @override
  String get governancePolicyClause => 'Clause #04 - A';

  @override
  String get urgentWithdrawalsAction =>
      'Review Urgent Withdrawal Requests (14 Orders Ready for Disbursement)';

  @override
  String get exportDailyReportPdf =>
      'Export Daily Liquidity & Financial Position Report (PDF)';

  @override
  String get liquidityDistributedOnChannels =>
      'Liquidity Distributed Across Banking Channels';

  @override
  String get liveBankingReconciliation =>
      'Live Banking Reconciliation (SARI/SARIE 100% Active)';

  @override
  String get instantSync => 'Instant Sync';

  @override
  String get mainBanksCount => '3 Main Banks';

  @override
  String get instaPayCount => '2 InstaPay Channels';

  @override
  String get digitalWalletsCount => '2 Digital Wallets';

  @override
  String get officialBankAccountsAndIban =>
      'Official Bank Accounts & IBAN Records';

  @override
  String get bankAccountsScreenSubtitle =>
      'Manage liquidity and reconcile with the Saudi Payments network';

  @override
  String get refreshBalances => 'Refresh balances';

  @override
  String get noAccountsInCategory =>
      'No accounts are registered in this category';

  @override
  String get operationalAccountsFilter => 'Operating accounts';

  @override
  String get escrowAccountsFilter => 'Escrow accounts';

  @override
  String get paymentGatewaysFilter => 'Payment gateways';

  @override
  String get digitalWalletsFilter => 'Digital wallets';

  @override
  String get instantBankSyncNote =>
      'Automatic synchronization and reconciliation across all channels';

  @override
  String get createBankAccount => 'Add new account';

  @override
  String get exportAccountStatementButton => 'Export PDF statement';

  @override
  String get openDailyLedger => 'Bank transactions and daily operations';

  @override
  String get dailyLedgerDescription =>
      'View journal entries, deposits, and incoming and outgoing transfers';

  @override
  String get escrowAccountBadge => 'Escrow account';

  @override
  String get availableLedgerBalanceLabel => 'Available ledger balance:';

  @override
  String get ibanOrIdentifierLabel => 'IBAN / Identifier:';

  @override
  String get connectedReconciledViaSarie =>
      'Connected and reconciled live via SARIE';

  @override
  String get linkBankAccountTitle => 'Link a new bank account';

  @override
  String get enterBankDetailsToApprove =>
      'Enter bank account details for approval';

  @override
  String get bankNameField => 'Bank name';

  @override
  String get accountTypeField => 'Account type';

  @override
  String get ibanField => 'IBAN';

  @override
  String get editBankAccountAction => 'Edit account details';

  @override
  String get bankEditNotice =>
      'Approved account details will not change yet. The edit request will be sent to the admin for approval or rejection.';

  @override
  String get bankEditSubmitAction => 'Save and send to admin';

  @override
  String get bankEditPendingStatus => 'Edit request awaiting admin decision';

  @override
  String get bankEditPendingDetails => 'Proposed details';

  @override
  String get bankEditRequestNumber => 'Request ID';

  @override
  String get bankEditSubmitting => 'Sending request...';

  @override
  String get bankEditRequestSent =>
      'The edit request was sent to the admin. Current account details remain approved until a decision is made.';

  @override
  String get bankEditRequestFailed =>
      'Could not send the edit request. Please try again.';

  @override
  String get bankEditRequired => 'This field is required';

  @override
  String get bankEditNoChanges => 'No account details were changed';

  @override
  String get bankLinkRequestSent => 'Account-link request sent';

  @override
  String get saveAccount => 'Save account';

  @override
  String get exportAccountsTitle => 'Export account statement';

  @override
  String get pdfReportExplanation =>
      'A detailed official PDF report of all reconciled bank balances will be generated.';

  @override
  String get download => 'Download';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get accountsExportSuccess => 'Account statement exported successfully';

  @override
  String get accountsCount => '3 Accounts';

  @override
  String get collectionAndDistribution => 'Collection & Distribution';

  @override
  String get sadadAndSarie => 'SADAD & SARIE';

  @override
  String get frozenEscrowAccount => 'Frozen Escrow Account';

  @override
  String get emergencyAccount =>
      'Emergency & Instant Banking Settlement Account';

  @override
  String get approvedT0 => 'Approved T+0';

  @override
  String get dailyLedgerBalance => 'Current Ledger Balance';

  @override
  String get ibanNumber => 'IBAN Number';

  @override
  String get internalAccountNumber => 'Internal Account Number';

  @override
  String get dailyLogLedger => 'Daily Transaction Ledger';

  @override
  String get reviewHeldEscrow => 'Review Held Escrow';

  @override
  String get reconciliationDisputesNote =>
      'Subject to automated financial reconciliation with Disputes Portal';

  @override
  String get approvedEWallets => 'Approved E-Wallets';

  @override
  String get walletsCount => '2 Wallets';

  @override
  String get stcPayEnterprise => 'stc pay for Business (Enterprise)';

  @override
  String get apiConnected => 'API Integrated';

  @override
  String get actualWalletBalance => 'Actual Wallet Balance';

  @override
  String get withdrawalFeesFree =>
      'Withdrawal Fees: Free (Corporate Agreement)';

  @override
  String get urpayBusiness => 'urpay for Business';

  @override
  String get activeStatus => 'Active';

  @override
  String get salarySupportDisbursement => 'Auxiliary Payroll Disbursement';

  @override
  String get feedWalletBalance => 'Fund Wallet Balance';

  @override
  String get bankingGovernanceAuthNote =>
      'Modifying, withdrawing, or unlinking any banking channel is subject to strict financial security standards, requiring 2FA via the Nafath platform and encrypted electronic signature authentication (SHA-256) by the CFO.';

  @override
  String get addNewBankAccount => 'Add Bank Account or New Payment Channel';

  @override
  String get exportAccountsStatementPdf => 'Export Accounts Statement (PDF)';

  @override
  String get exportDetailedStatementExcel => 'Detailed Statement (Excel)';

  @override
  String get bankingAndCashSurveillanceGateway =>
      'Disbursement & Cash Surveillance Gateway';

  @override
  String get merchantWithdrawalsHeaderTitle =>
      'Withdrawal Requests for Merchants, Users & Couriers';

  @override
  String get merchantWithdrawalsHeaderSubtitle =>
      'List of approved cash withdrawal requests for stores and providers';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get underRegulatoryHold => 'Under Precautionary Hold';

  @override
  String get regulatoryFreeze => 'Regulatory Freeze';

  @override
  String get allTab => 'All';

  @override
  String get merchantsTab => 'Merchants';

  @override
  String get usersTab => 'Users';

  @override
  String get verifiedViaNafath => 'Verified & Reconciled via Unified Nafath';

  @override
  String get underReviewStatus => 'Under Review';

  @override
  String get grossAmount => 'Total Requested Amount (Gross):';

  @override
  String get platformFee => 'Platform & Service Commission';

  @override
  String get netTransferredAmount => 'Net Amount Transferred to Bank Account:';

  @override
  String get receivingBank => 'Receiving Bank:';

  @override
  String get submissionDate => 'Submission Date:';

  @override
  String get automatedTaxAuditResult =>
      'Automated Tax & Wallet Reconciliation Result';

  @override
  String get automatedTaxAuditDetails =>
      'Invoice Matching: 100% | No active disputes or claims | Wallet balance fully covered and reconciled with net operating collections.';

  @override
  String get approveAndSendToAdmin => 'Approve & Send Request to Management';

  @override
  String get freezeRequestTemporarily => 'Temporary Request Freeze';

  @override
  String get readyForInstantDisbursement => 'Ready for Disbursement';

  @override
  String get readyForInstantBankingTransfer =>
      'Approved by System - Ready for instant transfer via SARIE network';

  @override
  String get approveAndIssueBankOrder => 'Approve & Issue Bank Payment Order';

  @override
  String get temporarilySuspendedForAudit =>
      'Temporarily Suspended for Regulatory Investigation';

  @override
  String get grossHeldAmount => 'Total Blocked Amount (Gross):';

  @override
  String get estimatedPlatformFee => 'Estimated Platform Fee';

  @override
  String get netFrozenAmount => 'Net Precautionary Amount Frozen:';

  @override
  String get auditReferenceCode => 'Audit Reference Code';

  @override
  String get regulatoryNoticeFromSupervisor =>
      'Regulatory Notice Memo from Merchant Supervisor';

  @override
  String get rejectAndNotifyCustomer => 'Reject & Notify Customer';

  @override
  String get freezeRequest => 'Freeze Request';

  @override
  String get totalAwaitingApproval => 'Total Amounts Awaiting Approval';

  @override
  String get remainingForReview => 'Remaining for Review';

  @override
  String get supervisorWithdrawalsHeaderTitle =>
      'Withdrawal Requests for Supervisors & Service Providers';

  @override
  String get supervisorWithdrawalsHeaderSubtitle =>
      'List of fees, supervision commissions, and maintenance dues approved for disbursement';

  @override
  String get awaitingApprovalTab => 'Awaiting Approval';

  @override
  String get platformSupervisorsTab => 'Platform Supervisors';

  @override
  String get awaitingDisbursementBadge => 'Awaiting Disbursement';

  @override
  String get totalFeesAndCommissions => 'Total Fees & Supervision Commissions:';

  @override
  String get netAmountDueForDisbursement => 'Net Amount Due for Disbursement:';

  @override
  String get disbursementSource => 'Dues Source';

  @override
  String get complianceAndAuditResult =>
      'Automated Performance Compliance Result';

  @override
  String get verifiedIban => 'Verified IBAN';

  @override
  String get fieldCompletionDetails => 'Field Completion Details';

  @override
  String get temporarilySuspendedBadge => 'Temporarily Suspended';

  @override
  String get grossClaimedAmount => 'Total Claimed Amount:';

  @override
  String get deductedPlatformFee => 'Deducted Platform Fee';

  @override
  String get netHeldAmount => 'Net Precautionarily Held Amount:';

  @override
  String get requestStatusProtocol =>
      'Request Status: Blocked under Supervisory Quality Protection Protocol';

  @override
  String get regulatoryNoticeFromServicesSupervisor =>
      'Regulatory Notice from Services Supervisor';

  @override
  String get batchApproval => 'Batch Approval';

  @override
  String get samaComplianceNotice =>
      'Transfers comply with Saudi Central Bank (SAMA) standards';

  @override
  String get subscriptionOrdersTitle => 'Subscription Orders';

  @override
  String get financialManagementSubtitle =>
      'Browah Al-Mazory - Financial Administration';

  @override
  String get financialAuditAndLicenses => 'Financial Audit & Licenses';

  @override
  String get subscriptionsAndUpgradesReviewTitle =>
      'Subscription & Upgrade Requests';

  @override
  String get subscriptionsAndUpgradesReviewSubtitle =>
      'Review and activate store and service provider subscriptions • Browah Al-Mazory';

  @override
  String get currentSubscriptionsCycleSummary =>
      'Current Subscriptions Cycle Summary';

  @override
  String get updatedNow => 'Updated Just Now';

  @override
  String get pendingSubscriptionFees => 'Pending Subscription Fees';

  @override
  String get ordersUnderAudit => 'Orders Under Audit';

  @override
  String get activatedThisMonth => 'Activated This Month';

  @override
  String get revenueGrowth => '+24% Revenue Growth';

  @override
  String get expiredAwaitingRenewal => 'Expired Awaiting Renewal';

  @override
  String get autoCommercialAlert => 'Automated Commercial Alert';

  @override
  String get couriersTab => 'Couriers';

  @override
  String get advertisementsTab => 'Advertisements';

  @override
  String get corporateAccount => 'Corporate account';

  @override
  String get subscriptionsHistoryTitle =>
      'Active and inactive subscription and upgrade records';

  @override
  String get browsePreviousOperations =>
      'Browse the history of all previous operations';

  @override
  String get openingSubscriptionsRegister => 'Opening the register...';

  @override
  String get storesAndMerchants => 'Stores & Merchants';

  @override
  String get serviceProviders => 'Service Providers';

  @override
  String get awaitingCertificationRequests => 'Requests Awaiting Certification';

  @override
  String get sortByNewest => 'Sort by Newest';

  @override
  String get underMatching => 'Under Matching';

  @override
  String get commercialRegister => 'CR:';

  @override
  String get licenseNumber => 'License No:';

  @override
  String get premiumMerchantSubscription => 'Premium Merchant Subscription';

  @override
  String get homeServicesProvider => 'Home Services Provider';

  @override
  String get targetedPackageType => 'Targeted Package Type';

  @override
  String get annualGoldenPackage => 'Annual Golden Package';

  @override
  String get proServiceProviderPackage => 'Professional Service Provider';

  @override
  String get taxInclusive15 => 'VAT Inclusive 15%';

  @override
  String get semiAnnualDuration => 'Semi-Annual (6 Months)';

  @override
  String get sufficientWalletBalance => 'Sufficient Balance in Wallet';

  @override
  String get paymentMethod => 'Payment Method:';

  @override
  String get directBankTransfer =>
      'Direct Bank Transfer (SADAD / Al Rajhi Corporate Account)';

  @override
  String get directDeductionFromEscrow => 'Direct Deduction from Escrow Wallet';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get previewReceiptAndTransferData =>
      'Preview Receipt & Transfer Details';

  @override
  String get autoApprovalReady => 'Ready for Automated Approval';

  @override
  String get rejectWithReason => 'Reject with Reason';

  @override
  String get licensesGovernanceTitle =>
      'Governance of Licenses & Upgrades Approval';

  @override
  String get licensesGovernanceDesc =>
      'Activating packages immediately grants commercial permissions, appearance priority, and regulatory exemptions defined in Browah Al-Mazory\'s financial system. All operations are subject to subsequent documentary and tax audits.';

  @override
  String get certifiedAndDocumentedRecord => 'Certified & Documented Record';

  @override
  String get pdfReport => 'PDF Report';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get navLiquidity => 'Liquidity';

  @override
  String get navWithdrawalOrders => 'Withdrawals';

  @override
  String get navReconciliation => 'Reconciliation';

  @override
  String get navSettlements => 'Settlements';

  @override
  String get navCommissions => 'Commissions';

  @override
  String get navAudit => 'Auditing';

  @override
  String get navHome => 'Home';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get financialDepartment => 'Financial Administration';

  @override
  String get encryptedBit256 => 'bit-256 encrypted';

  @override
  String get secureApprovedSession => 'Secure, authenticated audit session';

  @override
  String get cfoAuditingTitle => 'CFO & Head of Financial Auditing';

  @override
  String get sovereignApprovalPowers =>
      'Executive approval and bank authentication powers';

  @override
  String get certifiedAuditorAuthority =>
      'Certified financial auditor • Authorized for dual bank signatures and authentication at Browah Al-Mazory';

  @override
  String get officialPhone => 'Verified phone';

  @override
  String get corporateEmail => 'Corporate email';

  @override
  String get enabledNafath => 'National Nafath enabled';

  @override
  String get authorizationEffectiveFrom =>
      'Regulatory authorization effective from: 2027';

  @override
  String get activeAndReconciled => 'Active and reconciled';

  @override
  String get duesWalletTitle => 'Dues and fees wallet';

  @override
  String get executiveWalletDescription =>
      'Direct executive management and oversight account';

  @override
  String get totalAccountingDues => 'Total accounting dues balance';

  @override
  String get pendingRegulatoryBalance => 'Balance under regulatory review';

  @override
  String get awaitingQuarterlyClose => 'Awaiting quarterly close';

  @override
  String get approvedWithoutConditions => 'Approved without conditions';

  @override
  String get approvedPayoutAccount => 'Approved settlement account for payouts';

  @override
  String get requestOwnerProfitWithdrawal => 'Request owner profit withdrawal';

  @override
  String get editWithdrawalInformation => 'Edit withdrawal information';

  @override
  String get cfoExclusive => 'CFO only';

  @override
  String get sovereignControls => 'Executive controls and actions';

  @override
  String get feesAndCommissionsMatrix => 'General fees and commissions matrix';

  @override
  String get feesAndCommissionsMatrixDesc =>
      'Set platform percentages, payment-gateway deductions, and contracted operation pricing.';

  @override
  String get exclusivePermission => 'Exclusive access';

  @override
  String get editMatrix => 'Edit matrix';

  @override
  String get fastSettlementFees => 'Fast settlement fees';

  @override
  String get currentBaseCommission => 'Current base commission';

  @override
  String get comprehensivePaymentsReports =>
      'Comprehensive payments and revenue statement';

  @override
  String get comprehensivePaymentsReportsDesc =>
      'Generate cash-flow statements, VAT reports, and consolidated bank-settlement packages.';

  @override
  String get exportDetailedExcel => 'Export detailed Excel';

  @override
  String get exportApprovedPdf => 'Export approved PDF';

  @override
  String get liveDocumented => 'Live • documented';

  @override
  String get auditActivityLog => 'CFO audit and activity log';

  @override
  String get ownerDisputeSettlementApproval =>
      'Owner dispute settlement payout approval';

  @override
  String get todayAtEleven => 'Today 11:00 AM';

  @override
  String get approveDisputeSettlement =>
      'Approved dispute settlement #CMP-1035 for Egy 1,200.00 to Dr. Tareq Al-Omari.';

  @override
  String get referenceCode => 'Reference:';

  @override
  String get validDigitalSignature => 'Valid SHA-256 digital signature';

  @override
  String get aggregatedProfitWithdrawal =>
      'Aggregated profit withdrawal approval (SARIE)';

  @override
  String get todayAtNineThirty => 'Today 09:30 AM';

  @override
  String get periodicMerchantTransfers =>
      'Periodic payouts to 12 approved stores through instant payments, totaling Egy 142,500.00.';

  @override
  String get alRajhiBank => 'Al Rajhi Bank';

  @override
  String get executedAndPosted => 'Executed by bank and posted';

  @override
  String get precautionaryWalletFreeze => 'Precautionary store wallet freeze';

  @override
  String get yesterdayAtFourFifteen => 'Yesterday 04:15 PM';

  @override
  String get suspendMerchantDisbursement =>
      'Payouts paused for computer-supplies store (#TRD-304) due to a suspected recurring payment dispute.';

  @override
  String get auditNoticeReference => 'Audit notice #771';

  @override
  String get underInvestigation => 'Under investigation and audit';

  @override
  String get maintenanceCommissionUpdate =>
      'Maintenance-sector commission update';

  @override
  String get yesterdayAtOneTwenty => 'Yesterday 01:20 PM';

  @override
  String get commissionUpdatedByBoard =>
      'Collected commission updated to 8.0% under board resolution BOD-44/B.';

  @override
  String get activeSystemUpdate => 'Active system update';

  @override
  String get viewFullAuditActivity =>
      'View full audit and activity log (342 documented events)';

  @override
  String get reconciliationEngine => 'KYC & IBAN VERIFICATION ENGINE';

  @override
  String get reconciliationImmediateCompliance =>
      'Immediate banking compliance';

  @override
  String get reconciliationPageTitle =>
      'Bank account reconciliation and fraud prevention';

  @override
  String get reconciliationAuthorityTitle =>
      'Restricted executive supervisory authority';

  @override
  String get reconciliationAuthorityNotice =>
      'Only the CFO may review, verify, and approve. Field supervisors are strictly prohibited from changing bank-account details.';

  @override
  String get reconciliationGovernmentPortal =>
      'Government document and integration portal';

  @override
  String get reconciliationGovernmentSync =>
      'Live synchronization with the commercial registry and central bank';

  @override
  String get reconciliationConnected => 'Connected';

  @override
  String get reconciliationAccountDetails =>
      'Detailed account reconciliation data';

  @override
  String get reconciliationCommercialName => 'Registered commercial name';

  @override
  String get reconciliationCommercialEntity =>
      'Madar Technology Information Systems Establishment';

  @override
  String get reconciliationBeneficiaryName => 'Bank-account beneficiary name';

  @override
  String get reconciliationBeneficiaryEntity =>
      'Madar Technology Establishment';

  @override
  String get reconciliationFinalActions =>
      'Final approval actions (CFO-only authority):';

  @override
  String get reconciliationApproveAccount =>
      'Approve bank account and send to management';

  @override
  String get reconciliationApproveSuccess =>
      'Bank account approved and sent to management.';

  @override
  String get reconciliationLoadFailed => 'Could not load bank-link requests.';

  @override
  String get reconciliationNoPendingRequests =>
      'There are no bank-link requests awaiting review.';

  @override
  String get reconciliationFreezeSuccess =>
      'Request frozen for financial review.';

  @override
  String get reconciliationFrozenRequestsTitle => 'Frozen bank-link requests';

  @override
  String get reconciliationFreezeReasonLabel => 'Freeze reason:';

  @override
  String get reconciliationFreezeDialogDescription =>
      'This bank-link request will be held and recorded for financial review. It will be removed from the active review queue.';

  @override
  String get reconciliationActionFailed =>
      'Could not complete the action. Please try again.';

  @override
  String get reconciliationRequestIban =>
      'Request a recent stamped IBAN certificate';

  @override
  String get reconciliationIbanRequestSent =>
      'Request for a recent stamped IBAN certificate sent.';

  @override
  String get reconciliationRejectTransfer =>
      'Reject and freeze transfers to this account';

  @override
  String get reconciliationRejectSuccess =>
      'Request rejected and reason recorded for review.';

  @override
  String get reconciliationComplianceReview =>
      'Financial compliance review - Government document portal';

  @override
  String get reconciliationBusinessName => 'Madar Technology Trading Company';

  @override
  String get reconciliationNewAccountRequest =>
      'Request to approve a new primary bank account for recurring payouts';

  @override
  String get reconciliationAmlScore => 'AML/CFT regulatory compliance score';

  @override
  String get reconciliationAmlMatched =>
      'Secure match under anti-money-laundering and counter-terrorism financing protocols.';

  @override
  String get reconciliationMatchVerified => '100% matched  ✓';

  @override
  String get reconciliationBankName => 'Al Rajhi Bank';

  @override
  String get reconciliationIbanLabel =>
      '3. International bank account number (IBAN) and bank';

  @override
  String get reconciliationRegistrationLabel =>
      '4. Commercial registration and validity status';

  @override
  String get reconciliationValidUntil => 'Valid through 1447/06/15 AH';

  @override
  String get reconciliationPreviewDocument => 'Preview';

  @override
  String get reconciliationDocumentPreviewToast =>
      'Previewing document doc-iban-5501.pdf';

  @override
  String get reconciliationNextAccount => 'Next account in the waiting list';

  @override
  String get reconciliationQueueTitle => 'Reconciliation request queue';

  @override
  String get reconciliationSearchHint =>
      'Search by name, request ID, bank, or IBAN';

  @override
  String get reconciliationFilterAll => 'All';

  @override
  String get reconciliationFilterAttention => 'Needs attention';

  @override
  String get reconciliationNeedsAttention => 'Review';

  @override
  String get reconciliationNoMatchingRequests =>
      'No requests match these search criteria.';

  @override
  String get reconciliationAwaitingManagement => 'Awaiting management approval';

  @override
  String get reconciliationAwaitingCertificate =>
      'Awaiting updated IBAN certificate';

  @override
  String get reconciliationInProgressTab => 'In progress';

  @override
  String get reconciliationArchiveTab => 'Archive';

  @override
  String get reconciliationArchiveEmpty => 'There are no archived requests.';

  @override
  String get reconciliationDecisionReason => 'Decision reason';

  @override
  String get reconciliationNextBusiness => 'Suhaila Perfumes Store';

  @override
  String get reconciliationNextBank =>
      'Saudi National Bank  •  SA22 1000 **** **** 8819';

  @override
  String get reconciliationNameMismatch =>
      'Match status: minor trade-name discrepancy (review authorization and agency documents before payout).';

  @override
  String get reconciliationAuditAlert => 'Audit alert';

  @override
  String get reconciliationOpenAudit =>
      'Open full audit file for account #TRD-6022';

  @override
  String get withdrawSheetBrand => 'Barwah Mazouri Financial Services';

  @override
  String get withdrawSheetTitle => 'Owner profit withdrawal request';

  @override
  String get withdrawSheetAccount =>
      'Executive management and oversight account — Mr. Sulaiman Al-Rajhi';

  @override
  String get withdrawSheetInstantAuth =>
      'Instant Nafath verification • real-time SARIE withdrawal';

  @override
  String get withdrawSheetRequestId => 'Request #WD-8842';

  @override
  String get withdrawSheetAvailableBalance =>
      'Available balance ready for instant payout';

  @override
  String get withdrawSheetMinimumNotice =>
      'Minimum withdrawal: 1,000 Egy • no administrative transfer fees';

  @override
  String get withdrawSheetEnterAmount => 'Enter the amount to withdraw';

  @override
  String get withdrawSheetSetMaximum => 'Set maximum';

  @override
  String get withdrawSheetSelectBank => 'Approved receiving bank account';

  @override
  String get withdrawSheetIbanVerified => 'IBAN verified';

  @override
  String get withdrawSheetBankName => 'Al Rajhi Bank';

  @override
  String get withdrawSheetBankStatus =>
      'SAMA-verified account • active and reconciled';

  @override
  String get withdrawSheetPrimaryAccount => 'Primary account';

  @override
  String get withdrawSheetSubmitSuccess =>
      'Withdrawal request submitted successfully';

  @override
  String get withdrawSheetConfirm =>
      'Confirm and send withdrawal request to management';

  @override
  String get withdrawSheetCancel => 'Cancel';

  @override
  String get withdrawSheetAllAmount => 'All (52,000 Egy)';

  @override
  String get withdrawSheetAmount25k => '25,000 Egy';

  @override
  String get withdrawSheetAmount10k => '10,000 Egy';

  @override
  String get withdrawSheetAmount5k => '5,000 Egy';

  @override
  String get matrixLive => 'Local settings';

  @override
  String get matrixCfoPermission => 'Exclusive CFO authority (CFO-01)';

  @override
  String get matrixIntro =>
      'Review commission rates and save local changes for review.';

  @override
  String get matrixLastUpdate =>
      'Last updated: January 1, 2025 under board resolution BOD-44/B';

  @override
  String get matrixSalesRateTitle => 'General sales and merchant rate';

  @override
  String get matrixRateRange => 'Range: 2.0% - 10.0%';

  @override
  String get matrixCurrentRate => 'Currently applied rate';

  @override
  String get matrixSetTargetRate => 'Set target rate';

  @override
  String get matrixMinimumRate => 'Minimum 2.0%';

  @override
  String get matrixReferenceRate => 'Reference 5.0%';

  @override
  String get matrixMaximumRate => 'Maximum 10.0%';

  @override
  String get matrixSalesRateNote =>
      'Applies to all store deals, new products, and direct device sales without local exceptions.';

  @override
  String get matrixSettlementFeesTitle => 'Wallet settlement and refund fees';

  @override
  String get matrixCurrentSettlementFee => 'Current settlement fee';

  @override
  String get matrixFixedInstantFee =>
      'Additional fixed fee (instant settlement)';

  @override
  String get matrixCostCoverage => 'Cost coverage details:';

  @override
  String get matrixDeliveryFleet => 'Waslni fleet & partners';

  @override
  String get matrixCurrentCommission => 'Currently approved commission';

  @override
  String get matrixDeliveryPercentage => 'Percentage of delivery value';

  @override
  String get matrixFixedPerShipment => 'Fixed amount per shipment';

  @override
  String get matrixAccountingReason =>
      'Accounting rationale and mandatory audit note';

  @override
  String get matrixCancel => 'Cancel';

  @override
  String get reconciliationFinanceSubtitle => 'Finance Management & Accounts';

  @override
  String get departmentMerchantsTitle => 'Merchants & Retail Wallet';

  @override
  String get departmentEscrowTitle => 'Used Escrow & Waslni Wallet';

  @override
  String get departmentServicesTitle => 'Service Requests & Maintenance Wallet';

  @override
  String get departmentCouriersTitle => 'Delivery Agents & Logistics Wallet';

  @override
  String get departmentActiveStores => 'Active stores';

  @override
  String get departmentPendingRequests => 'Pending requests';

  @override
  String get departmentPlatformCommission => 'Platform commission';

  @override
  String get departmentActiveDeals => 'Active deals';

  @override
  String get departmentDisputes => 'Disputes';

  @override
  String get departmentProtectionFee => 'Protection fee';

  @override
  String get departmentServiceProviders => 'Service providers';

  @override
  String get departmentActiveCouriers => 'Active couriers';

  @override
  String get departmentPendingEntitlements => 'Pending entitlements';

  @override
  String get departmentShipmentFee => 'Shipment fee';

  @override
  String get departmentAuditedBadge => 'Audited and approved';

  @override
  String get departmentTotalBalance =>
      'Total balance available for settlement and withdrawal';

  @override
  String get departmentWalletSectionTitle => 'Oversight and merchant accounts';

  @override
  String get departmentSyncStatus => 'SADAD and SARIE synchronized';

  @override
  String get departmentGovernanceTitle =>
      'Settlement governance and banking controls (CFO)';

  @override
  String get departmentLastReconciliation =>
      'Last bank reconciliation: today at 2:45 PM';

  @override
  String get departmentAvailableBalance => 'Available for withdrawal';

  @override
  String get departmentUnderReview => 'Under audit and settlement';

  @override
  String get departmentMonthlySales => 'Completed sales this month';

  @override
  String get departmentOperationsUnit => 'operations';

  @override
  String get departmentViewHistory => 'View transaction history';

  @override
  String get departmentInstantSettlement => 'Instant settlement';

  @override
  String get departmentScheduledPayment => 'Scheduled bank payment';

  @override
  String get departmentUnderInspection => 'Under inspection';

  @override
  String get departmentInShipping => 'In transit';

  @override
  String get departmentWeeklySettlement => 'Weekly settlement';

  @override
  String get departmentActiveMatched => 'Active and reconciled';

  @override
  String get departmentProtectedEscrow => 'Escrow protected';

  @override
  String get departmentApprovedProvider => 'Approved provider';

  @override
  String get departmentStrategicPartner => 'Strategic partner';

  @override
  String get departmentActiveCourier => 'Active courier';

  @override
  String get departmentPendingSuffix => 'pending';

  @override
  String get departmentMerchantHorizon =>
      'Al Ofoq Technology and Trading Establishment';

  @override
  String get departmentStoreElite => 'Al Safwa Gold Store';

  @override
  String get departmentSparkleJewelry => 'Al Bareq Fine Jewelry';

  @override
  String get departmentEliteDevices => 'Elite Devices House';

  @override
  String get departmentCamryEscrow => '2020 Toyota Camry';

  @override
  String get departmentIphoneEscrow => 'iPhone 14 Pro Max';

  @override
  String get departmentItqanAc => 'Itqan Air Conditioning Establishment';

  @override
  String get departmentComprehensiveMaintenance =>
      'Comprehensive Maintenance Company';

  @override
  String get departmentZajelShipping => 'Zajel Shipping Company';

  @override
  String get departmentWaslniCourier => 'Waslni fleet courier (Mohammed Ahmed)';

  @override
  String get departmentRecordPrefix => 'CR:';

  @override
  String get departmentLicensePrefix => 'License:';

  @override
  String get departmentEscrowPrefix => 'Escrow deposit';

  @override
  String get departmentCourierNumberPrefix => 'Courier ID:';

  @override
  String get departmentAllFilter => 'All';

  @override
  String get departmentHighestBalanceFilter => 'Highest balance';

  @override
  String get departmentWithdrawalFilter => 'Withdrawing (8)';

  @override
  String get departmentGovernanceNotice =>
      'All wallet transfers are reconciled daily against the SARIE instant-payment network and SADAD. In accordance with Saudi Central Bank instructions, suspicious transactions are held for manual review by Barwah Mazouri Financial Compliance.';

  @override
  String get matrixScreenTitle => 'Update Profit & Fee Matrix';

  @override
  String get matrixDefaultReason =>
      'Periodic update to reflect bank payment-gateway fee changes and expansion of the field-delivery network';

  @override
  String get matrixLastUpdated => 'Last saved:';

  @override
  String get matrixCfoDescription =>
      'Edit proposed commission rates and save them locally for review; this page does not activate changes on the payment engine.';

  @override
  String get matrixAppliedRate => 'Saved rate';

  @override
  String get matrixTargetRate => 'Set target rate';

  @override
  String get matrixMinimumValue => 'Minimum 2.0%';

  @override
  String get matrixReferenceValue => 'Reference 5.0%';

  @override
  String get matrixMaximumValue => 'Maximum 10.0%';

  @override
  String get matrixSalesNote =>
      'Applies to all store deals, new products, and direct device sales without local exceptions.';

  @override
  String get matrixCurrentSettlementRate => 'Current settlement rate';

  @override
  String get matrixInstantFixedFee =>
      'Additional fixed fee (instant settlement)';

  @override
  String get matrixInstantFixedFeeNote =>
      'Apply a fixed 5.00 Egy fee to each urgent settlement';

  @override
  String get matrixCoverageDetails => 'Cost coverage details:';

  @override
  String get matrixGatewayCoverage =>
      'Payment-gateway fee coverage (Mada / Visa / SARIE) at 0.85%';

  @override
  String get matrixOperatingMargin => '+ 0.40% protective operating margin';

  @override
  String get matrixSettlementNote =>
      'Automatically deducted for instant wallet settlement and dispute-refund requests.';

  @override
  String get matrixDeliveryTitle =>
      'Delivery, transport, and shipping commission';

  @override
  String get matrixDeliveryDescription =>
      'Applied to each successful delivery by Waslni fleet couriers and contracted logistics companies, then deposited into the central wallet.';

  @override
  String get matrixAuditReasonTitle =>
      'Accounting rationale and mandatory audit note';

  @override
  String get matrixAuditReasonPrompt =>
      'Reason for changing rates (required for central audit):';

  @override
  String get matrixNotifyUsers =>
      'Notification preference for merchants, couriers, and supervisors when a matrix update is applied.';

  @override
  String get matrixSaveSuccess => 'Matrix changes were saved on this device.';

  @override
  String get matrixSaveAndSend => 'Save changes';

  @override
  String get matrixAuditTrailNotice =>
      'Changes are saved locally with the save time and reason. Tap to view history.';

  @override
  String get settlementsScreenTitle => 'Settlements Management';

  @override
  String get settlementsSubtitle => 'Barwah Mazouri - Finance Management';

  @override
  String get settlementBack => 'Back';

  @override
  String get settlementsAuthority => 'Executive CFO authority';

  @override
  String get settlementsPageTitle => 'Digital Wallets & Settlement Management';

  @override
  String get settlementsPageDescription =>
      'Execute approved financial transfers with the required legal evidence and approved financial-dispute record.';

  @override
  String get settlementsEscrowWallet => 'Escrow wallet';

  @override
  String get settlementsReservedOrders => 'Reserved for active orders';

  @override
  String get settlementsPendingBalance => 'Pending settlement balance';

  @override
  String get settlementsReadyRefund => 'Refund request ready to close';

  @override
  String get settlementSheetTitle => 'New settlement request';

  @override
  String get settlementOffsetMode => 'Balance offset';

  @override
  String get settlementRefundMode => 'Refund';

  @override
  String get settlementTypeLabel => 'Settlement type';

  @override
  String get settlementTypeInstant => 'Instant settlement';

  @override
  String get settlementBeneficiaryLabel => 'Beneficiary';

  @override
  String get settlementBeneficiaryAudit => 'Verification and audit';

  @override
  String get settlementAmountLabel => 'Settlement amount';

  @override
  String get settlementReferenceLabel => 'Reference';

  @override
  String get settlementNotesLabel => 'Settlement notes';

  @override
  String get settlementNotesHint => 'Enter settlement request details';

  @override
  String get settlementPaymentDetailsTitle => 'Payment details';

  @override
  String get settlementPaymentMethodLabel => 'Payment method';

  @override
  String get settlementPaymentBankTransfer => 'Bank transfer';

  @override
  String get settlementDateLabel => 'Date';

  @override
  String get settlementStatusLabel => 'Status';

  @override
  String get settlementStatusUnderReview => 'Under review';

  @override
  String get settlementSubmit => 'Submit request';

  @override
  String get settlementSubmitSuccess =>
      'Settlement request submitted successfully';

  @override
  String get addNewSettlement => 'Add new settlement';

  @override
  String get instantRefundSettlement => 'Refund / instant settlement';

  @override
  String get filterAll => 'All';

  @override
  String get filterInReview => 'In review';

  @override
  String get filterApproved => 'Approved';

  @override
  String get filterDisputed => 'Disputed';

  @override
  String get pendingSettlementRequests => 'Pending settlement requests';

  @override
  String get settlementRequestOne => 'requests';

  @override
  String get settlementVerifiedBank => 'Verified bank account';

  @override
  String get settlementMaintenanceDispute => 'Maintenance dispute';

  @override
  String get settlementFullRefund => 'Full refund';

  @override
  String get settlementAge35Minutes => '35 minutes ago';

  @override
  String get settlementBeneficiaryTariq => 'Dr. Tariq Al-Omari';

  @override
  String get settlementInitialTariq => 'T';

  @override
  String get settlementApprovedPartner =>
      'Approved partner - commercial registration';

  @override
  String get settlementBeneficiaryRealEstate =>
      'Al-Daman Real Estate Establishment';

  @override
  String get settlementInitialRealEstate => 'D';

  @override
  String get settlementCommissionCorrection => 'Commission correction';

  @override
  String get settlementCommissionSettlement => 'Commission settlement';

  @override
  String get settlementAgeTwoHours => 'Two hours ago';

  @override
  String get settlementIndependentProvider => 'Independent service provider';

  @override
  String get settlementBeneficiaryKhalid => 'Khalid Al-Mahyoub';

  @override
  String get settlementInitialKhalid => 'K';

  @override
  String get settlementMediationDelivery => 'Mediation delivery';

  @override
  String get settlementPenaltyDeduction => 'Penalty deduction';

  @override
  String get settlementAgeToday => 'Today at 8:30 AM';

  @override
  String get recentSettlementsTitle => 'Recently completed settlements';

  @override
  String get bankRefund => 'Bank refund';

  @override
  String get settlementCustomerBank => 'Customer #USR-8810 - Bank Albilad';

  @override
  String get settlementToday1130 => 'Today at 11:30 AM';

  @override
  String get compensationSettlement => 'Compensation settlement';

  @override
  String get settlementProviderCorrection =>
      'Service provider - commission correction';

  @override
  String get settlementYesterday0915 => 'Yesterday at 9:15 PM';

  @override
  String get settlementsLinkedRajhiEscrow =>
      'Al Rajhi Bank - Central Escrow Account';

  @override
  String get settlementRecentOperationsCount => '142 operations';

  @override
  String get viewLabel => 'View';

  @override
  String get viewAllLabel => 'View all';

  @override
  String get createSettlementToast => 'Add new settlement';

  @override
  String get frozenScreenTitle => 'Frozen & Pending Requests';

  @override
  String get frozenTotalTitle =>
      'Total precautionarily frozen amounts and transactions';

  @override
  String get frozenRequestCount => 'frozen requests';

  @override
  String get frozenProtocol => 'Article 18 anti-fraud protocol';

  @override
  String get frozenAllFilter => 'All';

  @override
  String get frozenMerchantsFilter => 'Merchants & stores';

  @override
  String get frozenProvidersFilter => 'Service providers';

  @override
  String get frozenSupervisorsFilter => 'Supervisors';

  @override
  String get frozenCouriersFilter => 'Couriers';

  @override
  String get frozenUsersFilter => 'Users';

  @override
  String get frozenAdsFilter => 'Advertisements';

  @override
  String get frozenExport => 'Export frozen funds statement (PDF / Excel)';

  @override
  String get frozenRefresh =>
      'Refresh transaction status and synchronize live oversight';

  @override
  String get frozenRequestOneName => 'Computer supplies merchant';

  @override
  String get frozenRequestOneSubtitle => 'Recurring profit withdrawal request';

  @override
  String get frozenMerchantType => 'Merchants & stores';

  @override
  String get frozenPrecautionaryStatus => 'Frozen as a precaution';

  @override
  String get frozenRequestOneReason =>
      'Freeze reason: open dispute #CMP-1042 with suspected promotional-offer manipulation.';

  @override
  String get frozenSupervisorSaad => 'Mr. Saad Al-Otaibi';

  @override
  String get frozenTodayFourHours => 'Today • 4 hours ago';

  @override
  String get frozenRestoreAndRelease => 'Restore and release funds for payout';

  @override
  String get frozenRejectAndForfeit => 'Confirm rejection and forfeiture';

  @override
  String get frozenRequestTwoName => 'Itqan Electrical Workshop';

  @override
  String get frozenAnnualMaintenance => 'Annual maintenance-contract dues';

  @override
  String get frozenProviderType => 'Service providers';

  @override
  String get frozenRequestTwoReason =>
      'Freeze reason: complaint that home maintenance was incomplete';

  @override
  String get frozenSupervisorAhmed => 'Mr. Ahmed Hassan';

  @override
  String get frozenYesterdayJanuary => 'Yesterday • January 27';

  @override
  String get frozenPartialFullRelease => 'Release partially / fully';

  @override
  String get frozenCustomerRefund => 'Issue customer refund settlement';

  @override
  String get frozenRequestThreeName => 'Al Ofoq Trading Establishment';

  @override
  String get frozenFastTransferPending =>
      'Pending instant bank transfer (SARIE)';

  @override
  String get frozenIbanMismatch => 'IBAN mismatch';

  @override
  String get frozenRequestThreeReason =>
      'Freeze reason: automated verification could not match the beneficiary name with the commercial registry at the Saudi Central Bank.';

  @override
  String get frozenJanuary25 => 'January 25, 2025';

  @override
  String get frozenRecheckTransfer => 'Recheck and reactivate transfer';

  @override
  String get frozenRequestIbanCertificate =>
      'Request a new stamped IBAN certificate from the bank';

  @override
  String get frozenPendingTransferAmount => 'Pending transfer amount:';

  @override
  String get frozenHeldAmount => 'Amount held for freeze:';

  @override
  String get frozenRegisteredIban => 'Registered IBAN:';

  @override
  String get frozenGrossTransaction => 'Gross transaction:';

  @override
  String get frozenAccountNameMismatch => 'Account name mismatch';

  @override
  String get frozenPlatformFeeDeduction => 'Platform fee deduction:';

  @override
  String get frozenSupervisorLabel => 'Supervisor:';

  @override
  String get frozenThawSuccess =>
      'The request was unfrozen and sent to management for payout approval';

  @override
  String get frozenForfeitSuccess =>
      'The request was rejected and forfeited, and the reason was recorded';

  @override
  String get frozenForfeitReasonHint =>
      'Enter the reason for rejection and regulatory forfeiture...';

  @override
  String get frozenBankLinksTitle => 'Frozen bank-link requests';

  @override
  String get frozenBankLinkReason => 'Freeze reason:';

  @override
  String get frozenBankLinkRestore => 'Unfreeze and return to review';

  @override
  String get frozenBankLinkReject => 'Reject with reason';

  @override
  String get frozenBankLinkRestoreDialogTitle => 'Restore bank-link request';

  @override
  String get frozenBankLinkRestoreDialogDescription =>
      'Unfreeze this bank-link request and return it to the active reconciliation review queue?';

  @override
  String get frozenBankLinkRestoreConfirm => 'Unfreeze and return';

  @override
  String get frozenBankLinkRestoreSuccess =>
      'The request was unfrozen and returned to bank reconciliation.';

  @override
  String get frozenBankLinkRejectDialogTitle =>
      'Reject frozen bank-link request';

  @override
  String get frozenBankLinkRejectReasonHint =>
      'Enter the reason for rejecting this bank-link request...';

  @override
  String get frozenBankLinkRejectSuccess =>
      'The frozen bank-link request was rejected and the reason was recorded.';

  @override
  String get frozenForfeitReasonNotice =>
      'The reason will be recorded with the rejection and forfeiture decision and sent to management for review.';

  @override
  String get frozenActionFailed =>
      'Could not complete the action. Refresh the request and try again.';

  @override
  String get frozenLoadFailed => 'Could not load pending and frozen requests.';

  @override
  String get frozenNoRequests =>
      'There are no pending or frozen requests right now.';

  @override
  String get transactionHistoryTitle => 'Transaction History';

  @override
  String get transactionFinancialSubtitle =>
      'Barwah Mazouri - Finance Management';

  @override
  String get transactionSupervisedBy => 'Supervised by: Mr. Saad Al-Otaibi';

  @override
  String get transactionAvailableBalance =>
      'Wallet balance available for settlement';

  @override
  String get transactionTotalWithdrawals => 'Total withdrawals';

  @override
  String get transactionTotalDeposits => 'Total deposits';

  @override
  String get transactionApprovedHistory => 'Approved bank transaction history';

  @override
  String get transactionThisMonth => 'This month (January 2025)';

  @override
  String get transactionAllFilter => 'All (6)';

  @override
  String get transactionDepositsFilter => 'Deposits (+3)';

  @override
  String get transactionWithdrawalsFilter => 'Withdrawals (-3)';

  @override
  String get transactionTodayGroup => 'Today • January 28, 2025';

  @override
  String get transactionTwoOperations => '2 transactions';

  @override
  String get transactionDepositSales => 'Cash sales deposit - online store';

  @override
  String get transactionNationalGateway =>
      'Mada card • National payment gateway';

  @override
  String get transactionSuccess => 'Successful and complete';

  @override
  String get transactionTimeTodayDeposit => '2:45 PM';

  @override
  String get transactionProfitWithdrawal =>
      'Profit withdrawal to bank - Al Rajhi';

  @override
  String get transactionFastNetwork =>
      'IBAN: SA44****5521 • SARIE instant transfer';

  @override
  String get transactionApproved => 'Transfer approved';

  @override
  String get transactionTimeTodayWithdrawal => '11:15 AM';

  @override
  String get transactionYesterdayGroup => 'Yesterday • January 27, 2025';

  @override
  String get transactionWaslniDeposit => 'Waslni orders deposit';

  @override
  String get transactionAutomatedSettlement =>
      'Compliant automated logistics settlement';

  @override
  String get transactionCompleted => 'Completed';

  @override
  String get transactionTimeYesterdayDeposit => '6:30 PM';

  @override
  String get transactionSnbWithdrawal =>
      'Profit withdrawal - Saudi National Bank';

  @override
  String get transactionCorporateVerification =>
      'IBAN: SA12****8894 • Corporate verification';

  @override
  String get transactionCertified => 'Regulator certified';

  @override
  String get transactionTimeYesterdayWithdrawal => '9:20 AM';

  @override
  String get transactionLastWeekGroup => 'Last week • January 23, 2025';

  @override
  String get transactionMerchantDisputeDeposit =>
      'Dispute settlement deposit to merchant...';

  @override
  String get transactionArbitrationDecision =>
      'Payment platform arbitration decision #ARB-209';

  @override
  String get transactionEffectiveSettlement => 'Settlement effective';

  @override
  String get transactionTimeLastWeekDeposit => '4:10 PM';

  @override
  String get transactionWithdrawalReview =>
      'Profit withdrawal request under immediate review...';

  @override
  String get transactionAmlReview =>
      'Financial compliance reconciliation review (AML)';

  @override
  String get transactionBankAudit => 'Under bank audit';

  @override
  String get transactionTimeLastWeekWithdrawal => '1:15 PM';

  @override
  String get transactionHeldBalance => 'Balance held:';

  @override
  String get transactionBalanceAfter => 'Balance after transaction:';

  @override
  String get transactionDownloadStatement =>
      'Download approved account statement (PDF)';

  @override
  String get totalRequiredAmount => 'Total Required Amount';

  @override
  String get goldenAnnualPackage => 'Annual Golden Package';

  @override
  String get proServiceProvider => 'Professional Service Provider';

  @override
  String get vipAnnualPackage => 'Annual VIP Package';

  @override
  String get unlimitedDeliveryPackage => 'Unlimited Delivery Package';

  @override
  String get featuredWeekPackage => 'Featured Listing (One Week)';

  @override
  String get directBankTransferSadad =>
      'Direct Bank Transfer (SADAD / Al Rajhi)';

  @override
  String get directDebitEscrow => 'Direct Deduction from Escrow Wallet';

  @override
  String get creditCardMada => 'Credit Card (Mada)';

  @override
  String get walletDeduction => 'Wallet Deduction';

  @override
  String get directBankTransferSnb => 'Direct Bank Transfer (SNB)';

  @override
  String get availableBalanceLabel => 'Available Balance';

  @override
  String get featuredMerchantSubscription => 'Featured Merchant Subscription';

  @override
  String get premiumUser => 'Premium User';

  @override
  String get deliveryCourier => 'Delivery Courier';

  @override
  String get commercialAds => 'Commercial Advertisements';

  @override
  String get eliteElectronicsStore => 'Elite Electronics Store';

  @override
  String get maintenanceWorkshop => 'Integrated Maintenance Workshop';

  @override
  String get vipUserUpgrade => 'VIP User Upgrade';

  @override
  String get fastCourierPackage => 'Fast Courier Package';

  @override
  String get mainBannerAd => 'Main Banner Advertisement';

  @override
  String get alRajhiBankName => 'Al Rajhi Bank';

  @override
  String get snbBankName => 'Saudi National Bank (SNB)';

  @override
  String get riyadBankName => 'Riyad Bank';

  @override
  String get madaGatewayName => 'SADAD and Mada Payment Gateway';

  @override
  String get stcPayWalletName => 'STC Pay Central Wallet';

  @override
  String get operatingAccountType => 'Operating Account';

  @override
  String get escrowAccountType => 'Escrow Account';

  @override
  String get electronicPaymentGatewayType => 'Electronic Payment Gateway';

  @override
  String get digitalWalletType => 'Digital Wallet';

  @override
  String get reconciliationNewCommercialAccountRequest =>
      'Request to link and verify new commercial account';

  @override
  String get reconciliationSupplierAccountRequest =>
      'Request to link approved supplier account';

  @override
  String get reconciliationFreelanceProviderRequest =>
      'Request to link freelance service provider account';

  @override
  String get reconciliationMatchDescription100 =>
      'Commercial and bank name match certified 100%';

  @override
  String get reconciliationMatchDescription96 =>
      'Minor difference in legal suffixes of the commercial name';

  @override
  String get reconciliationMatchDescription89 =>
      'Sole proprietorship requiring a certified IBAN certificate';

  @override
  String get reconciliationWarning96 =>
      'Difference detected between commercial registry suffix and bank account';

  @override
  String get reconciliationWarning89 =>
      'The attached IBAN certificate is older than 6 months';

  @override
  String get reconciliationCommercialName1 => 'Advanced Trade Ltd. Co.';

  @override
  String get reconciliationBeneficiaryName1 =>
      'Advanced Trade for Services and Agencies Est.';

  @override
  String get reconciliationCommercialName2 =>
      'Madar Al-Rowad General Contracting Co.';

  @override
  String get reconciliationBeneficiaryName2 =>
      'Madar Al-Rowad for Trade & Contracting One-Person Co.';

  @override
  String get reconciliationCommercialName3 =>
      'Digital Summit Information Technology Est.';

  @override
  String get reconciliationBeneficiaryName3 =>
      'Fahad Sulaiman Abdullah Al-Otaibi';

  @override
  String get reconciliationHijriSuffix => 'AH';

  @override
  String get reconciliationFreezeRequest => 'Freeze Request';

  @override
  String get merchantsSupervisorTitle => 'Merchants';

  @override
  String get merchantSupervisorRoleBadge => 'Merchant Supervisor';

  @override
  String get merchantSupervisorAdminSubtitle =>
      'Browah Al-Mazory - Administration';

  @override
  String get welcomeSupervisorAhmed => 'Welcome, Supervisor Ahmed';

  @override
  String get fieldSupervisorTag => 'Field';

  @override
  String get merchantsPortfolioSubtitle =>
      'Your assigned merchants portfolio - Riyadh Region';

  @override
  String get approvedMerchantsMetric => 'Approved Merchants';

  @override
  String get pendingReviewMetric => 'Pending Review';

  @override
  String get searchMerchantsHint => 'Search by name, CR number, or category';

  @override
  String get filterActiveVerified => 'Active & Verified';

  @override
  String get filterUnderAudit => 'Under Audit';

  @override
  String get filterUpdateRequired => 'Update Required';

  @override
  String get filterSuspended => 'Suspended';

  @override
  String get registeredStoresSection =>
      'Registered Stores Under Your Supervision';

  @override
  String storesRatio(Object current, Object total) {
    return '$current of $total';
  }

  @override
  String get recentlyActiveSort => 'Recently Active';

  @override
  String get crShortLabel => 'CR';

  @override
  String get linkNewMerchant => 'Link New Merchant';

  @override
  String get navMerchants => 'Merchants';

  @override
  String get navAds => 'Ads';

  @override
  String get navFinancialRequests => 'Financial Requests';

  @override
  String get navAccount => 'Account';

  @override
  String merchantSectionComingSoon(Object section) {
    return '$section is coming soon';
  }

  @override
  String get adsManagementTitle => 'Pre-publication Ad Management';

  @override
  String get adsReviewGateway => 'Live supervisory review gateway';

  @override
  String get adsUrgentDecision => 'Needs an immediate decision';

  @override
  String get adsHiddenToday => 'Hidden';

  @override
  String get adsPendingToday => 'Approved today';

  @override
  String get adsUnderReviewCount => 'Under review';

  @override
  String get adsAllFilter => 'All';

  @override
  String get adsVehiclesFilter => 'Cars & vehicles';

  @override
  String get adsElectronicsFilter => 'Electronics';

  @override
  String get adsRealEstateFilter => 'Real estate';

  @override
  String get adsSearchHint => 'Search title, merchant, or code...';

  @override
  String get adsClearSearch => 'Clear search';

  @override
  String get adsPendingHeading => 'Ads awaiting review';

  @override
  String get adsRecentSort => 'Recently received';

  @override
  String get adsOldestSort => 'Oldest received';

  @override
  String adsImageCount(Object count) {
    return '$count photos';
  }

  @override
  String get adsCarMerchant => 'Al-Ufuq Car Trading Est.';

  @override
  String get adsCarCategory => 'Car showroom • Riyadh';

  @override
  String get adsCarTitle => '2023 Mercedes E300 AMG fully loaded';

  @override
  String get adsCarDetails => 'Mileage: 15,000 km';

  @override
  String get adsCarPrice => 'SAR 245,000';

  @override
  String get adsPhoneMerchant => 'Al-Safwa Electronics Store';

  @override
  String get adsPhoneCategory => 'Verified on Maroof • Riyadh';

  @override
  String get adsPhoneTitle => 'New iPhone 16 Pro Max 256GB Natural Titanium';

  @override
  String get adsPhoneDetails => 'Local warranty: 5 years';

  @override
  String get adsPhonePrice => 'SAR 4,699';

  @override
  String get adsVillaMerchant => 'Al-Yamama Contracting & Real Estate Co.';

  @override
  String get adsVillaCategory => 'Licensed real estate broker • Riyadh';

  @override
  String get adsVillaTitle =>
      'Luxury modern villa with living-room stairs - Al Narjis';

  @override
  String get adsVillaDetails => 'Land area: 375 m²';

  @override
  String get adsVillaPrice => 'SAR 2,850,000';

  @override
  String get adsLicenseVerified => 'Business license verified';

  @override
  String get adsMarketPriceMatched => 'Price matches market average';

  @override
  String get adsReviewHidden => 'Hidden pending review';

  @override
  String adsMinutesAgo(Object count) {
    return '$count minutes ago';
  }

  @override
  String get adsHoursAgo => '2 hours ago';

  @override
  String get adsReviewAndApprove => 'Review and verify ad';

  @override
  String get adsHideAction => 'Hide ad';

  @override
  String get adsApproveAction => 'Approve and publish';

  @override
  String get adsRejectAction => 'Reject with reason';

  @override
  String get adsRejectReasonTitle => 'Reason for rejection';

  @override
  String get adsRejectReasonHint =>
      'Enter the reason to share with the merchant';

  @override
  String get adsRejectReasonInstructions =>
      'Choose a clear reason to notify the merchant and record it in the administrative audit log.';

  @override
  String get adsRejectReasonPrice => 'Unrealistic or misleading price';

  @override
  String get adsRejectReasonMisleading =>
      'Misleading description or inaccurate information';

  @override
  String get adsRejectReasonPhotos =>
      'Photos do not match specifications or are low quality';

  @override
  String get adsRejectReasonPolicy =>
      'Violates publishing policy or platform terms';

  @override
  String get adsRejectGuidanceOptional =>
      'Custom guidance for the merchant (optional)';

  @override
  String get adsRejectGuidanceDirectLabel =>
      'Shown in the merchant\'s notification';

  @override
  String get adsRejectGuidanceHint =>
      'Enter guidance for editing and resubmitting the ad...';

  @override
  String get adsConfirmRejectAndNotify =>
      'Confirm rejection and notify merchant';

  @override
  String get adsCancelAction => 'Cancel';

  @override
  String get adsConfirmReject => 'Confirm rejection';

  @override
  String get adsApprovedStatus => 'Ad approved';

  @override
  String get adsPremiumWaitingFinance => 'Waiting for finance review';

  @override
  String get adsPremiumWaitingManagement =>
      'Waiting for management approval and fee deduction';

  @override
  String get adsHiddenStatus => 'Ad hidden';

  @override
  String get adsRejectedStatus => 'Ad rejected';

  @override
  String get adsNoResults => 'No matching ads found';

  @override
  String get adsDetailsTitle => 'Ad details';

  @override
  String get adsInImageReviewStatus => 'Ad pending review';

  @override
  String get adsNotPublishedYet => 'Not published yet';

  @override
  String adsMerchantRegistrationNumber(Object number) {
    return 'Registration: $number';
  }

  @override
  String get productSupervisorRoleBadge => 'New Products Supervisor';

  @override
  String get productReviewTab => 'Under review';

  @override
  String get productReportsTab => 'Reports';

  @override
  String get productSubscriptionsTab => 'Product promotions';

  @override
  String get productAccountTab => 'Account';

  @override
  String get wasalnySupervisorRoleBadge => 'Wasalny Supervisor';

  @override
  String get wasalnyRequestsTab => 'Wasalny requests';

  @override
  String get wasalnyAccountFollowComplaint => 'Track complaint';

  @override
  String get wasalnyReportOverview => 'Field performance overview';

  @override
  String get wasalnyReportCompletionRate => 'Deal completion rate';

  @override
  String get wasalnyReportDealsDetail =>
      'Deals completed in the selected period';

  @override
  String get wasalnyReportCompletionDetail =>
      'Of deals handled by the supervisor';

  @override
  String get wasalnyReportResponseTime => 'Average response time';

  @override
  String get wasalnyReportResponseDetail => 'Faster than the service standard';

  @override
  String get wasalnyReportSatisfaction => 'Party satisfaction rating';

  @override
  String get wasalnyReportRatingDetail => 'Based on field service ratings';

  @override
  String get wasalnyComplaintReference => 'Complaint #CMP-1042';

  @override
  String get wasalnyComplaintOpenStatus => 'Being followed up';

  @override
  String get wasalnyComplaintSubject =>
      'Shipment delayed after sale completion';

  @override
  String get wasalnyComplaintDescription =>
      'The complaint has been recorded and referred for review. The request parties are being contacted to verify the shipment status.';

  @override
  String get wasalnyComplaintReceived => 'Complaint received and recorded';

  @override
  String get wasalnyComplaintUnderReview => 'Complaint under review by Wasalny';

  @override
  String get wasalnyComplaintWaitingAction =>
      'Waiting for action and party updates';

  @override
  String get wasalnyComplaintsListIntro =>
      'Select a complaint to review its details and dispute parties';

  @override
  String wasalnyComplaintReferenceWithId(String id) {
    return 'Complaint #$id';
  }

  @override
  String get wasalnyComplaintOpenDetails => 'View details';

  @override
  String get wasalnyComplaintDetailsTitle => 'Complaint details';

  @override
  String get wasalnyComplaintDetailsSection => 'Complaint information';

  @override
  String get wasalnyComplaintRequestSection => 'Request information';

  @override
  String get wasalnyComplaintPartiesSection => 'Dispute parties';

  @override
  String get wasalnyComplaintSeller => 'Seller';

  @override
  String get wasalnyComplaintBuyer => 'Buyer';

  @override
  String get wasalnyComplaintRequest => 'Request ID';

  @override
  String get wasalnyComplaintAmount => 'Deal amount';

  @override
  String get wasalnyComplaintCreatedAt => 'Complaint date';

  @override
  String get wasalnyComplaintResolvedStatus => 'Resolved amicably';

  @override
  String get wasalnyComplaintEscalatedStatus => 'Escalated to head supervisor';

  @override
  String get wasalnyComplaintResolveFriendly =>
      'Resolve complaint and dispute amicably';

  @override
  String get wasalnyComplaintEscalateHead =>
      'Escalate complaint to head supervisor';

  @override
  String get wasalnyComplaintEscalationSheetKicker =>
      'MODULE 03: ADMIN COMPLAINT ESCALATION';

  @override
  String get wasalnyComplaintEscalationSheetType => 'Type: Bottom sheet';

  @override
  String get wasalnyComplaintEscalationSheetTitle =>
      'Complaint escalation action';

  @override
  String get wasalnyComplaintEscalationSheetSubtitle =>
      'Escalate this complaint to the head supervisor';

  @override
  String get wasalnyComplaintEscalationFileLabel =>
      'Supervisory complaint file';

  @override
  String get wasalnyComplaintEscalationPending =>
      'Awaiting administrative escalation';

  @override
  String get wasalnyComplaintEscalationHeldAmount => 'Held warranty amount';

  @override
  String get wasalnyComplaintEscalationNoHeldAmount => 'No amount on hold';

  @override
  String get wasalnyComplaintEscalationPolicyTitle =>
      'Oversight committee authority and policy';

  @override
  String get wasalnyComplaintEscalationPolicyBody =>
      'The complaint will be sent to the head supervisor to review the recorded facts and evidence and determine the appropriate administrative action under platform policy. Escalation does not change the held amount.';

  @override
  String get wasalnyComplaintEscalationAuditTrail => 'Auditable activity log';

  @override
  String get wasalnyComplaintEscalationEvidenceTitle =>
      'Complaint summary and recorded evidence';

  @override
  String get wasalnyComplaintEscalationVerifiedLabel => 'Verified information';

  @override
  String get wasalnyComplaintEscalationNoWarranty =>
      'No field-warranty information is recorded.';

  @override
  String get wasalnyComplaintEscalationConfirm =>
      'Confirm formal complaint escalation';

  @override
  String get wasalnyComplaintBackToList => 'Back to complaints';

  @override
  String get wasalnyComplaintCallSeller => 'Call seller';

  @override
  String get wasalnyComplaintCallBuyer => 'Call buyer';

  @override
  String get wasalnyComplaintResolvedMessage =>
      'Complaint marked as resolved amicably';

  @override
  String get wasalnyComplaintEscalatedMessage =>
      'Complaint escalated to the head supervisor';

  @override
  String get wasalnyComplaintCallFailed =>
      'Could not start a call on this device';

  @override
  String get wasalnyComplaintsLoadError => 'Could not load complaints';

  @override
  String get wasalnyComplaintsRetry => 'Try again';

  @override
  String get wasalnyComplaintPartyUnavailable => 'No party linked';

  @override
  String get wasalnyComplaintItem => 'Item';

  @override
  String get wasalnyComplaintDealCode => 'Deal ID';

  @override
  String get wasalnyComplaintWarranty => 'Field warranty';

  @override
  String get wasalnyComplaintResolveNote =>
      'Seller and buyer agreed on an amicable resolution';

  @override
  String get wasalnyComplaintResolveFailed =>
      'Could not record the amicable resolution';

  @override
  String get wasalnyComplaintEscalationReason =>
      'Complaint requires head supervisor review';

  @override
  String get wasalnyComplaintEscalationFailed =>
      'Could not escalate the complaint';

  @override
  String get wasalnyComplaintActionTakenStatus => 'Action taken';

  @override
  String get wasalnyAuditComplaintResolved => 'Complaint resolved amicably';

  @override
  String get wasalnyAuditComplaintEscalated =>
      'Complaint escalated to head supervisor';

  @override
  String get wasalnyAuditAdApproved => 'Wasalny advertisement approved';

  @override
  String get wasalnyAuditAdHidden => 'Wasalny advertisement hidden';

  @override
  String get wasalnyAuditAdRejected => 'Wasalny advertisement rejected';

  @override
  String get wasalnyAuditAdSuspended => 'Wasalny advertisement suspended';

  @override
  String get wasalnyAuditAdEditRequested =>
      'Wasalny advertisement edit requested';

  @override
  String get wasalnyAuditContactRevealed => 'Request contact details revealed';

  @override
  String get wasalnyAuditContactHidden => 'Request contact details hidden';

  @override
  String get wasalnyNotificationsTitle => 'Wasalny notifications';

  @override
  String get wasalnyNotificationNewRequest => 'New Wasalny request';

  @override
  String get wasalnyNotificationNewRequestDescription =>
      'A new request is waiting for delivery-stage follow-up.';

  @override
  String get wasalnyNotificationComplaint => 'Complaint update';

  @override
  String get wasalnyNotificationComplaintDescription =>
      'Complaint CMP-1042 has been updated and is being followed up.';

  @override
  String get wasalnyNotificationInspection => 'Shipment inspection completed';

  @override
  String get wasalnyNotificationInspectionDescription =>
      'The inspection result for request W-1038 has been recorded.';

  @override
  String get wasalnyPromotionSendToFinance => 'Send to finance supervisor';

  @override
  String get wasalnyPromotionSentToFinance =>
      'The promotion request was sent to the finance supervisor for review.';

  @override
  String get wasalnyPromotionFinancePending =>
      'The promotion request is still awaiting the finance supervisor\'s approval.';

  @override
  String get wasalnyPromotionFinanceRequestType => 'Product promotion request';

  @override
  String wasalnyPromotionFinanceApprovalConfirmation(
      Object amount, Object beneficiary) {
    return 'Approve $beneficiary\'s promotion for $amount and forward it to management for deduction?';
  }

  @override
  String get wasalnyPromotionFinanceApproved =>
      'The promotion request was approved and forwarded to management for deduction.';

  @override
  String get wasalnyPromotionFinanceRejected =>
      'The promotion request was rejected and the Wasalny supervisor was notified.';

  @override
  String get wasalnyComplaintChatParty => 'Chat with both parties';

  @override
  String get wasalnyRequestsMonthlyLimitTitle => 'Monthly limit reached';

  @override
  String get wasalnyRequestsMonthlyLimitMessage =>
      'This buyer has used two contact-disclosure requests this month. An in-app subscription is required to reveal more details.';

  @override
  String get wasalnyPremiumCustomer => 'Premium customer';

  @override
  String get wasalnyPremiumAdChoiceTitle =>
      'Is this ad included in the package?';

  @override
  String get wasalnyPremiumAdChoiceMessage =>
      'This customer is Premium. Should the ad use their package or be treated as a paid promotion?';

  @override
  String get wasalnyPremiumAdIncluded => 'Included in package';

  @override
  String get wasalnyPremiumAdPaid => 'Paid promotion';

  @override
  String get wasalnyHeadInboxTitle => 'Wasalny escalations';

  @override
  String get wasalnyNotificationSourceFinance => 'Finance supervisor';

  @override
  String get wasalnyNotificationSourceChief => 'Head supervisor';

  @override
  String get wasalnyNotificationSourceWasalny => 'Wasalny account';

  @override
  String get wasalnyNotificationEmpty => 'No notifications yet.';

  @override
  String get wasalnyPromotionTitle => 'Wasalny product promotion requests';

  @override
  String get wasalnyPromotionSubtitle =>
      'Review used-product promotion requests and track each request status';

  @override
  String get wasalnyRequestsSafetyTitle => 'Wasalny secure mediation protocol';

  @override
  String get wasalnyRequestsSafetyDescription =>
      'Review Wasalny requests and reveal contact details only after both parties confirm.';

  @override
  String get wasalnyRequestsCompletionRate => 'Completion rate';

  @override
  String get wasalnyRequestsActiveDeals => 'Active deals';

  @override
  String get wasalnyRequestsAll => 'All';

  @override
  String get wasalnyRequestsAwaitingApproval => 'Awaiting approval';

  @override
  String get wasalnyRequestsCommunication => 'Coordinating';

  @override
  String get wasalnyRequestsUnderReview => 'Under review';

  @override
  String get wasalnyRequestsSold => 'Sold';

  @override
  String get wasalnyRequestsDelivery => 'Delivery';

  @override
  String get wasalnyRequestsInspection => 'Inspection';

  @override
  String get wasalnyRequestsEmpty => 'There are no requests at this stage.';

  @override
  String get wasalnyRequestsEstimatedValue => 'Estimated value';

  @override
  String get wasalnyRequestsSeller => 'Seller';

  @override
  String get wasalnyRequestsBuyer => 'Buyer';

  @override
  String get wasalnyRequestsOrderNumber => 'Request number';

  @override
  String get wasalnyRequestsCurrentStatus => 'Current status';

  @override
  String get wasalnyRequestsLocation => 'Location';

  @override
  String get wasalnyRequestsRevealTitle => 'Reveal contact details';

  @override
  String get wasalnyRequestsRevealConfirmation =>
      'Reveal contact details to both parties in this request?';

  @override
  String get wasalnyRequestsRevealAction => 'Show details to buyer';

  @override
  String get wasalnyRequestsHideData => 'Hide details';

  @override
  String get wasalnyRequestsPreviewAction => 'Preview request';

  @override
  String get wasalnyRequestsPreviewTitle => 'Request details';

  @override
  String get wasalnyAdsTitle => 'Used product advertisements';

  @override
  String get wasalnyAdsSubtitle => 'Supervision and technical compliance';

  @override
  String get wasalnyAdsPendingToday => 'Awaiting review';

  @override
  String get wasalnyAdsApprovedToday => 'Approved today';

  @override
  String get wasalnyAdsFilterAll => 'All';

  @override
  String get wasalnyAdsFilterPending => 'Awaiting review';

  @override
  String get wasalnyAdsFilterEdit => 'Inspect and edit';

  @override
  String get wasalnyAdsFilterApproved => 'Approved';

  @override
  String get wasalnyAdsEmpty => 'There are no ads in this category.';

  @override
  String get wasalnyAdsAuditNote =>
      'All moderation actions are secured and recorded in the administrative audit log.';

  @override
  String get wasalnyAdsLoadError =>
      'Wasalny advertisements could not be loaded.';

  @override
  String get wasalnyAdsUpdateError =>
      'The advertisement status could not be updated.';

  @override
  String get wasalnyAdsPendingStatus => 'Awaiting review';

  @override
  String get wasalnyAdsApprovedStatus => 'Published - Wasalny delivery active';

  @override
  String get wasalnyAdsHiddenStatus => 'Advertisement hidden';

  @override
  String get wasalnyAdsRejectedStatus => 'Rejected - awaiting seller edits';

  @override
  String get wasalnyAdsAwaitingApprovalStatus => 'Awaiting approval';

  @override
  String get wasalnyAdsSuspendedStatus => 'Advertisement suspended';

  @override
  String get wasalnyAdsEditRequestedStatus => 'Changes requested';

  @override
  String get wasalnyAdsAcceptAction => 'Accept';

  @override
  String get wasalnyAdsHideAction => 'Hide';

  @override
  String get wasalnyAdsSuspendAction => 'Suspend';

  @override
  String get wasalnyAdsRejectAction => 'Reject';

  @override
  String get wasalnyAdsHideTitle => 'Hide advertisement';

  @override
  String get wasalnyAdsSuspendTitle => 'Suspend advertisement';

  @override
  String get wasalnyAdsEditRequestTitle => 'Request advertisement changes';

  @override
  String get wasalnyAdsRejectTitle => 'Reject advertisement';

  @override
  String get wasalnyAdsHideReason =>
      'Enter a reason for hiding this advertisement';

  @override
  String get wasalnyAdsSuspendReason =>
      'Enter a reason for suspending this advertisement';

  @override
  String get wasalnyAdsEditRequestReason =>
      'Enter the changes required from the publisher';

  @override
  String get wasalnyAdsRejectReason =>
      'Enter a reason for rejecting this advertisement';

  @override
  String get wasalnyAdsReasonRequired => 'A reason is required to continue.';

  @override
  String get wasalnyAdsApproved => 'Advertisement approved and published.';

  @override
  String get wasalnyAdsHidden => 'Advertisement hidden.';

  @override
  String get wasalnyAdsRejected => 'Advertisement rejected.';

  @override
  String get wasalnyAdsSuspended => 'Advertisement suspended.';

  @override
  String get wasalnyAdsEditRequested => 'Changes requested from the publisher.';

  @override
  String get wasalnyAdDetailsTitle => 'Inspect used advertisement';

  @override
  String get wasalnyAdDetailsPermission =>
      'Restricted supervisor access: technical details only';

  @override
  String get wasalnyAdDetailsReadOnly => 'Publisher details are read-only';

  @override
  String get wasalnyAdDetailsSellerVerified => 'Verified seller';

  @override
  String get wasalnyAdDetailsSubmitted => 'Submitted';

  @override
  String get wasalnyAdDetailsPriceMatch =>
      'The current price is fair and matches the suggested range.';

  @override
  String get wasalnyCategoryCamera =>
      'Electronics & imaging > Professional cameras';

  @override
  String get wasalnyCategoryConsole => 'Gaming > Consoles';

  @override
  String get wasalnyCategoryLaptop => 'Electronics > Laptops';

  @override
  String get wasalnyCategoryBicycle => 'Sports & recreation > Bicycles';

  @override
  String get wasalnyAdDetailsImageGallery => 'Inspected product photos';

  @override
  String wasalnyAdDetailsPhotosCount(Object count, Object total) {
    return '$count of $total accepted';
  }

  @override
  String get wasalnyAdDetailsFront => 'Front camera body';

  @override
  String get wasalnyAdDetailsControls => 'Screen and controls';

  @override
  String get wasalnyAdDetailsLens => 'Lens mount and sensor';

  @override
  String get wasalnyAdDetailsAddPhoto => 'Add documentation photo';

  @override
  String get wasalnyAdDetailsCategory => 'Approved category';

  @override
  String get wasalnyAdDetailsCategoryMatch =>
      'Category matched automatically to the used product type and price range.';

  @override
  String get wasalnyAdDetailsPrice => 'Listed price';

  @override
  String get wasalnyAdDetailsPriceRange => 'Fair price range';

  @override
  String get wasalnyAdDetailsDescription =>
      'Approved description and content review';

  @override
  String get wasalnyAdDetailsAutoCheck =>
      'Automatic check: clean and free of restricted terms';

  @override
  String get wasalnyAdDetailsCharacters => 'characters';

  @override
  String get wasalnyAdDetailsApprove => 'Approve advertisement';

  @override
  String get wasalnyAdDetailsRequestEdit => 'Request changes from publisher';

  @override
  String get wasalnyAdDetailsSuspend => 'Suspend advertisement';

  @override
  String get wasalnyAdDetailsReject => 'Reject for policy violation';

  @override
  String get wasalnyChatWithSeller => 'Chat with advertiser';

  @override
  String get wasalnyCallSeller => 'Call advertiser';

  @override
  String get wasalnyChatOrCallSeller => 'Chat with advertiser or call';

  @override
  String get wasalnyContactSellerTitle => 'Contact the advertiser';

  @override
  String get wasalnyContactSellerSubtitle =>
      'Contact the advertiser directly to discuss ad details or request technical clarification';

  @override
  String get wasalnyCallNow => 'Call now';

  @override
  String wasalnyCallingSeller(Object phone) {
    return 'Calling advertiser: $phone';
  }

  @override
  String get wasalnyCopyPhone => 'Copy phone number';

  @override
  String get wasalnyPhoneCopied =>
      'Advertiser phone number copied to clipboard';

  @override
  String get wasalnySellerPhoneLabel => 'Advertiser phone number';

  @override
  String get wasalnyAdsUpdated => 'Advertisement updated.';

  @override
  String get wasalnyAdsReason => 'Action reason';

  @override
  String productComingSoon(Object section) {
    return '$section is coming soon';
  }

  @override
  String get productSupervisorWelcome => 'Welcome, Supervisor Mohamed';

  @override
  String get productReviewSubtitle => 'New products review supervisor';

  @override
  String get productPendingAdsCount => 'Awaiting review';

  @override
  String get productApprovedAdsCount => 'Approved ads';

  @override
  String get productSearchHint => 'Search by ad number or product title...';

  @override
  String get productCategoryAll => 'All';

  @override
  String get productCategoryHome => 'Home appliances';

  @override
  String get productCategoryElectronics => 'Electronics';

  @override
  String get productCategoryWatches => 'Perfumes & watches';

  @override
  String get productReviewListTitle => 'New products under review';

  @override
  String productReceivedMinutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String get productConditionNew => 'New in box';

  @override
  String get productConditionUsed => 'Used';

  @override
  String get productAcceptAction => 'Accept';

  @override
  String get productHideAction => 'Hide';

  @override
  String get productRejectAction => 'Reject';

  @override
  String get productSuspendAction => 'Suspend';

  @override
  String get productSuspendConfirmTitle => 'Confirm ad suspension';

  @override
  String productSuspendConfirmMessage(String title) {
    return 'Do you want to suspend “$title” and temporarily stop it from appearing?';
  }

  @override
  String get productStatusSuspended => 'Suspended';

  @override
  String get productFeaturedBadge => 'Featured';

  @override
  String get productSuspendSheetTitle => 'Edit compliance action';

  @override
  String productSuspendSheetSubtitle(String reference, String title) {
    return 'Ad #$reference • $title';
  }

  @override
  String get productSuspendChooseAction => 'Select the new compliance status';

  @override
  String get productSuspendRepublish => 'Show and republish (enabled)';

  @override
  String get productSuspendRepublishHint =>
      'Enable direct visibility in the new products marketplace';

  @override
  String get productSuspendHideTemporarily => 'Hide temporarily (suspend ad)';

  @override
  String get productSuspendHideTemporarilyHint =>
      'Temporarily hidden until compliance requirements are met';

  @override
  String get productSuspendRejectFinal => 'Reject permanently';

  @override
  String get productSuspendRejectFinalHint =>
      'Violates new standards and close the ticket immediately';

  @override
  String get productSuspendSelected => 'Selected';

  @override
  String get productSuspendCurrent => 'Current';

  @override
  String get productSuspendReasonTitle =>
      'Reason for status change and reviewer notes';

  @override
  String get productSuspendReasonHint =>
      'Enter the reason for this compliance action...';

  @override
  String get productSuspendDefaultReason =>
      'Packaging photos were verified and the ad is ready to be reactivated';

  @override
  String get productSuspendReasonNote =>
      'This note will appear in the audit log';

  @override
  String get productSuspendNotifyTitle =>
      'Send an immediate notification to the publisher';

  @override
  String get productSuspendNotifyHint =>
      'Notify them immediately about the status change and reason';

  @override
  String get productSuspendSaveAction => 'Save and update status';

  @override
  String get productReviewImagesHint =>
      'Tap to review product photos and purchase invoice';

  @override
  String get productAcceptConfirmTitle => 'Confirm product acceptance';

  @override
  String productAcceptConfirmMessage(Object title) {
    return 'Do you want to accept “$title” and approve it for publishing?';
  }

  @override
  String get productHideConfirmTitle => 'Confirm hiding product';

  @override
  String productHideConfirmMessage(Object title) {
    return 'Do you want to hide “$title” from the displayed products list?';
  }

  @override
  String get productRejectConfirmTitle => 'Confirm product rejection';

  @override
  String get productRejectReasonHint =>
      'Enter a reason for rejecting this product';

  @override
  String get productRejectReasonRequired =>
      'A rejection reason is required to continue';

  @override
  String get productHideReasonHint => 'Enter a reason for hiding this product';

  @override
  String get productHideReasonRequired =>
      'A reason for hiding is required to continue';

  @override
  String get productConfirmAction => 'Confirm';

  @override
  String get productCancelAction => 'Cancel';

  @override
  String get productStatusApproved => 'Accepted';

  @override
  String get productStatusHidden => 'Hidden';

  @override
  String get productStatusRejected => 'Rejected';

  @override
  String get productEmptyResults => 'No matching products found';

  @override
  String get productReviewActionSuccess => 'Product status updated';

  @override
  String get productReviewLoadError =>
      'Could not load products under review. Please try again.';

  @override
  String get productReviewUpdateError =>
      'Could not save the product decision. Refresh and try again.';

  @override
  String get productDetailsTitle => 'Product review';

  @override
  String get productDetailsAppBarTitle => 'View advertisement';

  @override
  String get productDetailsInvoice => 'Purchase invoice';

  @override
  String get productDetailsPhotos => 'Product photos';

  @override
  String get productDetailsMerchant => 'Merchant';

  @override
  String get productDetailsPrice => 'Price';

  @override
  String get productDetailsCategory => 'Category';

  @override
  String get productDetailsCondition => 'Condition';

  @override
  String get productReviewSessionInProgress => 'Active inspection and review';

  @override
  String get productSellerLabel => 'Seller:';

  @override
  String get productSellerVerified => 'Verified';

  @override
  String get productViewFullAd => 'View full advertisement details';

  @override
  String get productViewFullAdHint =>
      'Review and edit advertisement details and description';

  @override
  String get productInvoiceAttached => 'Purchase invoice attached';

  @override
  String get productImageQualityChecked => 'Image quality checked';

  @override
  String get productAuditChecklistTitle =>
      'Mandatory new product audit checklist:';

  @override
  String get productAuditPackagingTitle =>
      'Security seal and plastic wrapping are fully intact';

  @override
  String get productAuditPackagingHint =>
      'Packaging inspected; no tears or signs of heat resealing.';

  @override
  String get productAuditSerialTitle =>
      'Serial number matches local specifications';

  @override
  String get productAuditSerialHint =>
      'Registered barcode matches the official authority database.';

  @override
  String get productAuditDescriptionTitle =>
      'Description does not imply prior or trial use';

  @override
  String get productAuditDescriptionHint =>
      'No phrases such as “opened for testing” or “like new”.';

  @override
  String get productInstantPublishingTitle => 'Publish immediately';

  @override
  String get productInstantPublishingHint =>
      'Approving this inspection publishes the ad directly to the marketplace and sends the seller an official review completion notification.';

  @override
  String get productApproveAndPublishNow => 'Approve and publish now';

  @override
  String get productBackToReview => 'Close / Back';

  @override
  String get productFullDetailsTitle => 'Advertisement details';

  @override
  String get productPhotoDocumentationTitle =>
      'Packaging and documentation photo review';

  @override
  String get productPhotoCount => 'Uploaded photos';

  @override
  String get productPhotoAdOriginal => 'New product - original seal';

  @override
  String get productPhotoQualityCheck => 'Label inspection';

  @override
  String get productSellerInquiryTitle => 'Ask the seller';

  @override
  String get productSellerInquiryHint =>
      'Request clarification or an immediate correction';

  @override
  String get productSendInquiry => 'Message';

  @override
  String get productInquiryMessageHint =>
      'Write your question to the seller...';

  @override
  String get productApprovedCategory => 'Approved category';

  @override
  String get productDescriptionAndCondition =>
      'Product description and condition';

  @override
  String get productWarrantyLabel => 'Add warranty statement';

  @override
  String get productDescriptionHint =>
      'Enter the product description and condition...';

  @override
  String productDescriptionCharacterCount(int count) {
    return '$count characters';
  }

  @override
  String get productDescriptionSafetyCheck => 'Checked for misleading wording';

  @override
  String get productAdHistoryTitle => 'Advertisement status history';

  @override
  String get productHistoryOpenStatus => 'Open';

  @override
  String get productHistoryCreated => 'Advertisement created by the user';

  @override
  String get productHistoryDocumentsAttached =>
      'Packaging and barcode photos attached';

  @override
  String get productHistoryAssigned =>
      'Advertisement assigned to field supervisor';

  @override
  String get productHistoryCurrent =>
      'Current status: specification and requirements review';

  @override
  String get productEditPermissionHint =>
      'Supervisory editing is limited to category, price, and description. Publisher details cannot be changed.';

  @override
  String get productFinalDecisionLabel =>
      'Final administrative supervisor decision';

  @override
  String get productRequiredFieldsError =>
      'Complete the price and description before continuing.';

  @override
  String get productInvalidPriceError => 'Enter a valid numeric price.';

  @override
  String get productWorkspaceComingSoon => 'This page is coming soon';

  @override
  String get productPromotionTitle => 'Featured Product Promotions';

  @override
  String get productPromotionSubtitle =>
      'Review promotion requests and monitor active listings';

  @override
  String get productPromotionPending => 'Awaiting decision';

  @override
  String get productPromotionActive => 'Active';

  @override
  String get productPromotionTotal => 'Total requests';

  @override
  String get productPromotionRequests => 'Promotion requests';

  @override
  String get productPromotionFilterAll => 'All';

  @override
  String get productPromotionCompleted => 'Completed';

  @override
  String get productPromotionEmpty => 'There are no requests in this category.';

  @override
  String get productPromotionPlanInfo =>
      'Check listing eligibility and payment status before activating a promotion. The plan duration starts upon approval.';

  @override
  String get productPromotionFeaturedPlan => 'Featured';

  @override
  String get productPromotionPremiumPlan => 'Featured Plus';

  @override
  String get productPromotionDays => 'days';

  @override
  String get productPromotionRequestedAt => 'Requested:';

  @override
  String get productPromotionDecisionNote => 'Decision note';

  @override
  String get productPromotionApprove => 'Approve promotion';

  @override
  String get productPromotionReject => 'Reject request';

  @override
  String get productPromotionApproveTitle => 'Confirm promotion approval';

  @override
  String productPromotionApproveMessage(Object title) {
    return 'Approve the promotion request for “$title”?';
  }

  @override
  String get productPromotionConfirmApprove => 'Confirm approval';

  @override
  String get productPromotionPaymentStatusTitle => 'Payment status';

  @override
  String get productPromotionViewPaymentStatus => 'View payment status';

  @override
  String get productPromotionPaidByFinance => 'Payment confirmed by Finance';

  @override
  String get productPromotionUnpaid => 'Payment has not been completed';

  @override
  String get productPromotionUnpaidMessage =>
      'This promotion cannot be approved until Finance confirms receipt of payment.';

  @override
  String get productPromotionRejectTitle => 'Reject promotion request';

  @override
  String get productPromotionRejectReasonHint =>
      'Enter a reason for rejecting this request';

  @override
  String get productPromotionConfirmReject => 'Confirm rejection';

  @override
  String get productPromotionApproved => 'Promotion request approved.';

  @override
  String get productPromotionRejected => 'Promotion request rejected.';

  @override
  String get productPromotionExpired => 'Expired';

  @override
  String get productPromotionDisclaimer =>
      'Displayed requests are sample data; connect the subscription and payment services before production use.';

  @override
  String get productPromotionAuditApproved => 'Product promotion approved';

  @override
  String get productPromotionAuditRejected => 'Product promotion rejected';

  @override
  String get productWalletTitle => 'Supervisor Wallet';

  @override
  String get productWalletBack => 'Back';

  @override
  String get productWalletSupervisorId => 'SUP-9942';

  @override
  String get productWalletVerified => 'Verified';

  @override
  String get productWalletAvailableForWithdrawal =>
      'Available for instant withdrawal';

  @override
  String get productWalletBalanceAmount => 'SAR 8,450';

  @override
  String get productWalletReady => 'Active and ready';

  @override
  String get productWalletBalanceNote =>
      'Includes approved supervision dues and completed audit allowances, ready for instant transfer.';

  @override
  String get productWalletTotalDues => 'Total dues';

  @override
  String get productWalletTotalDuesAmount => 'SAR 12,500';

  @override
  String get productWalletDuesDetail => 'Salary + earned incentives';

  @override
  String get productWalletPendingReview => 'Pending financial review';

  @override
  String get productWalletPendingAmount => 'SAR 4,050';

  @override
  String get productWalletPendingDetail => 'Inspection and reward review';

  @override
  String get productWalletSettlementRate => 'Regular weekly settlement cycle';

  @override
  String get productWalletSettlementPercent => 'Payout readiness: 68%';

  @override
  String get productWalletRequestTitle =>
      'Request withdrawal of financial dues';

  @override
  String get productWalletNoFees => 'No transfer fees';

  @override
  String get productWalletAmountToWithdraw => 'Amount to withdraw';

  @override
  String get productWalletWithdrawableHint =>
      'Withdraw all available funds (SAR 8,450)';

  @override
  String get productWalletCurrency => 'SAR';

  @override
  String get productWalletLimitNote =>
      'Minimum withdrawal is SAR 100; daily maximum is SAR 20,000.';

  @override
  String get productWalletChooseDestination => 'Choose transfer destination';

  @override
  String get productWalletInstapay => 'InstaPay';

  @override
  String get productWalletFast => 'Instant';

  @override
  String get productWalletMobileWallet => 'Mobile wallet';

  @override
  String get productWalletWalletProviders => 'Vodafone / Orange';

  @override
  String get productWalletBankTransfer => 'Bank transfer';

  @override
  String get productWalletIban => 'IBAN';

  @override
  String get productWalletIbanAddress =>
      'Instant payment address (IPA) or bank IBAN';

  @override
  String get productWalletPaymentAddress =>
      'Instant payment address (IPA) or linked phone number';

  @override
  String get productWalletProcessingTime =>
      'Processing: immediate, available 24/7';

  @override
  String get productWalletFeeDetails =>
      'Processing and transfer fee: SAR 0.5 (fully covered for the supervisor)';

  @override
  String get productWalletSubmitRequest => 'Confirm and request withdrawal';

  @override
  String get productWalletAmountError =>
      'Enter an amount between SAR 100 and SAR 8,450.';

  @override
  String get productWalletDetailsError =>
      'Complete the account details before submitting your withdrawal request.';

  @override
  String get productWalletConfirmTitle => 'Confirm withdrawal request';

  @override
  String productWalletConfirmMessage(Object amount) {
    return 'Confirm withdrawal of SAR $amount?';
  }

  @override
  String get productWalletConfirmAction => 'Confirm withdrawal';

  @override
  String get productWalletRequestSent =>
      'Withdrawal request submitted successfully.';

  @override
  String get productWalletBonusTitle => 'Weekly achievement bonus available!';

  @override
  String get productWalletBonusAmount => '+SAR 500';

  @override
  String get productWalletBonusDescription =>
      'You completed 4 of 5 field goals, exceeding the defined standards.';

  @override
  String get productWalletHistoryTitle => 'Recent transactions and transfers';

  @override
  String get productWalletFullStatement => 'View full account statement';

  @override
  String get productWalletTransactionOne => 'Bank withdrawal - Al Rajhi Bank';

  @override
  String get productWalletTransactionOneMeta => 'TRX-9821 • Yesterday, 2:40 PM';

  @override
  String get productWalletTransactionOneAmount => '-5,000';

  @override
  String get productWalletTransactionTwo =>
      'Approved field inspection commission';

  @override
  String get productWalletTransactionTwoMeta =>
      'Electronics • WS-4088 • Oct 24';

  @override
  String get productWalletTransactionTwoAmount => '+350';

  @override
  String get productWalletTransactionThree => 'Instant transfer - InstaPay';

  @override
  String get productWalletTransactionThreeMeta => 'IPA-3310 • Oct 21';

  @override
  String get productWalletTransactionThreeAmount => '-2,200';

  @override
  String get productWalletPaid => 'Completed';

  @override
  String get productWalletDeposit => 'Deposit';

  @override
  String get productWalletAuditTitle =>
      'Financial operations are encrypted and audited by the platform accounting oversight authority';

  @override
  String get productWalletAuditCode => 'Periodic audit code: AUDIT-SEC-2024-v9';

  @override
  String get productWalletStatementUnavailable =>
      'Full account statement details will appear once the wallet is connected to financial services.';

  @override
  String get productSupervisorToolsTitle => 'Supervisor records and support';

  @override
  String get productAuditHistoryTitle =>
      'Decision and compliance audit history';

  @override
  String get productAuditHistorySubtitle =>
      'Review your previous decisions and actions';

  @override
  String get productAuditEmpty => 'No actions have been recorded yet.';

  @override
  String get productAuditLoadError =>
      'Could not load the audit history. Please try again.';

  @override
  String get productAuditSaveError =>
      'Could not save the action to the audit log. The request was not recorded.';

  @override
  String get productAuditActionApproved => 'Product approved';

  @override
  String get productAuditActionHidden => 'Product hidden';

  @override
  String get productAuditActionRejected => 'Product rejected';

  @override
  String get productAuditActionSuspended => 'Advertisement suspended';

  @override
  String get productAuditActionUpdated => 'Product details updated';

  @override
  String get productAuditActionFieldAvailability =>
      'Field availability changed';

  @override
  String get productAuditActionUrgentNotifications =>
      'Urgent alerts setting changed';

  @override
  String get productAuditEnabled => 'Enabled';

  @override
  String get productAuditDisabled => 'Disabled';

  @override
  String get productAuditActionWithdrawalRequested =>
      'Financial withdrawal requested';

  @override
  String get productAuditActionOther => 'Compliance action';

  @override
  String get productSupportTitle => 'Support and assistance center';

  @override
  String get productSupportSubtitle =>
      'Administrative and technical support, and contact with the head supervisor';

  @override
  String get productAdminSupportTitle => 'Administrative support';

  @override
  String get productAdminSupportDetail =>
      'Questions about procedures, policies, and administrative escalation';

  @override
  String get productTechnicalSupportTitle => 'Technical support';

  @override
  String get productTechnicalSupportDetail =>
      'Help with application, account, and tool issues';

  @override
  String get productSupportContactTitle => 'Contact the support team';

  @override
  String get productHeadSupervisorName => 'Head Supervisor';

  @override
  String get productHeadSupervisorRole =>
      'Administrative follow-up and escalation';

  @override
  String get productTechnicalSupportName => 'Technical Support Team';

  @override
  String get productTechnicalSupportHours =>
      'Available to help with technical issues';

  @override
  String get productSupportOpenChat => 'Start chat';

  @override
  String get productSupportHours =>
      'Contact support by chat; service hours follow the approved schedule.';

  @override
  String get productChatsTitle => 'Chats';

  @override
  String get productChatToday => 'Today';

  @override
  String get productChatYesterday => 'Yesterday';

  @override
  String get productHeadSupervisorPreview =>
      'Send questions and escalation requests here.';

  @override
  String get productTechnicalSupportPreview =>
      'Contact us for technical assistance.';

  @override
  String get productNotificationsTitle => 'Notifications';

  @override
  String get productNotificationsMarkAllRead => 'Mark all as read';

  @override
  String get productNotificationNewReviewTitle =>
      'New products awaiting review';

  @override
  String get productNotificationNewReviewBody =>
      'There are new products waiting for your review.';

  @override
  String get productNotificationWalletTitle => 'Financial dues updated';

  @override
  String get productNotificationWalletBody =>
      'Your dues summary and weekly settlement cycle were updated.';

  @override
  String get productNotificationPolicyTitle => 'Compliance reminder';

  @override
  String get productNotificationPolicyBody =>
      'Review the checklist before approving products.';

  @override
  String get productNotificationToday => 'Today';

  @override
  String get productNotificationYesterday => 'Yesterday';

  @override
  String get productNotificationEarlier => 'Earlier';

  @override
  String get productReportEyebrow => 'Executive compliance and quality';

  @override
  String get productReportTitle => 'New Products Department Reports';

  @override
  String get productReportExport => 'Export';

  @override
  String get productReportToday => 'Today';

  @override
  String get productReportThisWeek => 'This week';

  @override
  String get productReportThisMonth => 'This month';

  @override
  String get productReportCustom => 'Custom';

  @override
  String get productReportReviewedAds => 'Ads inspected';

  @override
  String get productReportComparedToPrevious => 'compared to previous period';

  @override
  String get productReportApprovalRate => 'Approval rate';

  @override
  String productReportApprovedCount(int count) {
    return '$count approved ads';
  }

  @override
  String get productReportDeclinedRate => 'Hidden and rejected';

  @override
  String productReportDeclinedCount(int count) {
    return '$count ads hidden';
  }

  @override
  String get productReportAverageReview => 'Average inspection speed';

  @override
  String get productReportMinutesAndFaster => '25% faster';

  @override
  String get productReportMinuteUnit => 'min';

  @override
  String get productReportStandardsTitle =>
      'Strict verification standards for new items';

  @override
  String get productReportStandardsVersion => 'Protocol 4.2';

  @override
  String get productReportPackagingTitle => 'Thermal packaging requirement';

  @override
  String get productReportPackagingHint =>
      'Verify the original security seal is intact';

  @override
  String get productReportSerialTitle => 'Serial verification';

  @override
  String get productReportSerialHint =>
      'Check the approved local warranty database';

  @override
  String get productReportCategoryTitle => 'New product category distribution';

  @override
  String productReportAdsCount(int count) {
    return '$count ads';
  }

  @override
  String get productReportElectronics => 'Electronics and smartphones';

  @override
  String get productReportGames => 'Gaming and entertainment';

  @override
  String get productReportPerfumes => 'Luxury perfumes and watches';

  @override
  String get productReportHomeAppliances => 'Home and kitchen appliances';

  @override
  String get productReportAuditTitle => 'Latest recorded compliance actions';

  @override
  String get productReportLive => 'Live';

  @override
  String get productReportHidden => 'Hidden';

  @override
  String get productReportApproved => 'Approved';

  @override
  String get productReportRejected => 'Rejected';

  @override
  String productReportActionHeadline(String adNumber) {
    return 'Ad $adNumber';
  }

  @override
  String get productReportEditAction => 'Edit action';

  @override
  String get productReportEditDialogTitle => 'Edit compliance action';

  @override
  String get productReportActionStatus => 'Action status';

  @override
  String get productReportActionReason => 'Reason';

  @override
  String get productReportApplyEdit => 'Apply';

  @override
  String get productReportRecentActionsNote =>
      'These are the latest actions recorded in the selected period.';

  @override
  String get productReportDataNote =>
      'Sample report data changes with the selected period';

  @override
  String get productReportSaveAndUpdate => 'Save and update status now';

  @override
  String get productReportDiscardChanges => 'Cancel and revert';

  @override
  String get productReportSaved => 'Report updates saved locally';

  @override
  String get productReportExportTitle => 'Export report as CSV';

  @override
  String get productReportCopyCsv => 'Copy CSV';

  @override
  String get productReportExportCopied => 'Report data copied';

  @override
  String get productProfileMetricsTitle => 'Compliance and operational metrics';

  @override
  String get productProfileLastUpdated => 'Last updated: 12 minutes ago';

  @override
  String get productProfileName => 'Eng. Tarek Abdulaziz Al-Otaibi';

  @override
  String get productProfileRegion =>
      'Riyadh region and surrounding governorates';

  @override
  String get productProfileSupervisorId => 'SUP-1082';

  @override
  String get productProfileVerified => 'Certified field supervisor';

  @override
  String get productProfileFieldAvailability =>
      'Available for field inspections';

  @override
  String get productProfileFieldAvailabilityHint =>
      'Direct response within a 15 km radius';

  @override
  String get productProfilePreferenceLocalOnlyNotice =>
      'These settings are saved on this device only; notification delivery is not connected.';

  @override
  String get productProfilePreferenceLoadError =>
      'Could not load saved settings. Tap to retry.';

  @override
  String get productProfileReviewed => 'Inspections reviewed';

  @override
  String get productProfileSinceLastMonth => '+18% from last month';

  @override
  String get productProfileApprovalMetric =>
      'Mediation and amicable resolution';

  @override
  String get productProfileApprovedOfTotal => 'Out of 263 open disputes';

  @override
  String get productProfileResponseSpeed => 'Average response speed';

  @override
  String get productProfileFasterThanAverage => '6 minutes faster than target';

  @override
  String get productProfileQualityMetric => 'Compliance satisfaction rate';

  @override
  String get productProfileQualityDetail => 'Based on 210 technical ratings';

  @override
  String get productProfileDocumentsTitle =>
      'Approved supervisory documents and delegations';

  @override
  String get productProfileAuthorization => 'Field supervision authorization';

  @override
  String get productProfileAuthorizationSubtitle =>
      'Active supervisory delegation • Expires 15/06/1447 AH';

  @override
  String get productProfileActive => 'Active';

  @override
  String get productProfilePolicy => 'Guarantee hold policy';

  @override
  String get productProfilePolicySubtitle => 'Approved version 4.2';

  @override
  String get productProfileDelegation => 'Dispute resolution authority';

  @override
  String get productProfileDelegationSubtitle =>
      'Direct supervisory delegation';

  @override
  String get productProfileReview => 'Review';

  @override
  String get productProfileWalletTitle => 'My wallet and financial details';

  @override
  String get productProfileJustUpdated => 'Updated now';

  @override
  String get productProfileWalletBalance => 'Available balance and dues';

  @override
  String get productProfileWalletAmount => 'SAR 14,850';

  @override
  String get productProfileWalletDetail =>
      'Field supervision allowances + mediation dues';

  @override
  String get productProfileOperationsTitle =>
      'Operational settings and field assignments';

  @override
  String get productProfileUrgentAlerts =>
      'Urgent incident alerts (VIP Dispatch)';

  @override
  String get productProfileUrgentAlertsSubtitle =>
      'Immediate sound alert for high-priority disputes and pickups';

  @override
  String get productProfileAuditLog =>
      'Previous decisions and compliance audit log';

  @override
  String get productProfileAuditLogSubtitle =>
      'Archive of inspection reports and completed incidents';

  @override
  String get productProfileAuditLogDetail =>
      'Compliance decisions are available for review from the reports dashboard.';

  @override
  String get productProfileSupport =>
      'Administrative and technical support center';

  @override
  String get productProfileSupportSubtitle =>
      'Direct contact with the central operations manager';

  @override
  String get productProfileSupportDetail =>
      'For assistance, contact the central operations manager through approved support channels.';

  @override
  String get productProfileEndSession => 'End supervisory session and sign out';

  @override
  String get productProfileFooter =>
      'Field compliance portal • Barwah Al-Mazory Management';

  @override
  String get productProfileBuild => 'Build 2.9.44 - Auth Token Valid';

  @override
  String get adsMerchantVerified => 'Verified';

  @override
  String adsPhotoPosition(Object current, Object total) {
    return '$current of $total photos';
  }

  @override
  String get adsAdPhotoVerified => 'Photo checked';

  @override
  String adsIdentifier(Object number) {
    return 'Ad ID: #$number';
  }

  @override
  String get adsAskingPrice => 'Asking price';

  @override
  String get adsAdDescription => 'Merchant\'s ad description';

  @override
  String get adsLicenseChecklist => 'Regulatory license checklist';

  @override
  String adsChecklistCount(int passed, int total) {
    return '$passed / $total items';
  }

  @override
  String get adsAutoHideReportsTitle => 'Auto-hide after reports';

  @override
  String get adsAutoHideReportsDescription =>
      'Temporarily hide the ad until it is reviewed again';

  @override
  String get adsDeliveryTitle => 'Product delivery and shipping costs';

  @override
  String get adsDeliveryActive => 'Service active';

  @override
  String get adsDeliveryDescription =>
      'Delivery service is requested for this ad. The supervisor may adjust delivery fees before approval or hiding.';

  @override
  String get adsDeliveryFee => 'Fixed amount (SAR)';

  @override
  String get adsUpdateDeliveryFee => 'Update fee';

  @override
  String get adsDeliveryFeeNote =>
      'Delivery fee checked and adjusted to policy';

  @override
  String get adsSupervisorDecision => 'Supervisor decision';

  @override
  String get adsSupervisorLevel => 'Approval authority: Level 1';

  @override
  String get adsRequestEdit => 'Request data update';

  @override
  String get adsEditRequestTitle => 'Request ad changes';

  @override
  String get adsEditRequestSubtitle =>
      'Enter the merchant\'s required corrections before the ad can be published';

  @override
  String adsEditRequestAdTitle(Object title) {
    return 'Ad: $title';
  }

  @override
  String get adsEditRequestGuidanceTitle =>
      'Supervisor notes and guidance for the merchant (required)';

  @override
  String get adsEditRequestInstructions =>
      'Clearly describe every detail and item that needs to be changed so the merchant knows what to correct before the ad is reviewed again.';

  @override
  String get adsEditRequestHint =>
      'Enter the changes required from the merchant...';

  @override
  String get adsEditRequestRequired =>
      'This field is required to submit an edit request';

  @override
  String get adsEditRequestSend => 'Send edit request to merchant';

  @override
  String get adsEditRequestCancel => 'Cancel and go back';

  @override
  String get adsFeeUpdated => 'Delivery fee updated';

  @override
  String get adsFeeInvalid => 'Enter a valid non-negative amount';

  @override
  String get adsRequestEditUnavailable =>
      'Requesting an ad edit is not available yet';

  @override
  String get adsMileage => 'Current mileage';

  @override
  String get adsExteriorColor => 'Exterior color';

  @override
  String get adsAccidentRecord => 'Accident report';

  @override
  String get adsTransmission => 'Transmission';

  @override
  String get adsMileageValue => '15,000 km';

  @override
  String get adsWhiteColorValue => 'Pearl white';

  @override
  String get adsNoAccidentsValue => 'No accident record';

  @override
  String get adsAutomaticValue => 'Automatic';

  @override
  String get adsPhoneWarranty => 'Local warranty';

  @override
  String get adsPhoneCondition => 'Product condition';

  @override
  String get adsPhoneColor => 'Color';

  @override
  String get adsPhoneStorage => 'Storage capacity';

  @override
  String get adsWarrantyValue => '5 years';

  @override
  String get adsNewConditionValue => 'New';

  @override
  String get adsNaturalTitaniumValue => 'Natural titanium';

  @override
  String get adsStorageValue => '256 GB';

  @override
  String get adsVillaArea => 'Land area';

  @override
  String get adsVillaRooms => 'Number of rooms';

  @override
  String get adsVillaLicense => 'Real estate license';

  @override
  String get adsVillaLocation => 'Location';

  @override
  String get adsVillaAreaValue => '375 m²';

  @override
  String get adsVillaRoomsValue => '5 bedrooms';

  @override
  String get adsVillaLicensedValue => 'Valid and verified';

  @override
  String get adsVillaLocationValue => 'Al Narjis, Riyadh';

  @override
  String get adsVehicleDescription =>
      'Agency-condition vehicle, nearly new, with complete dealer service history. All scheduled maintenance was completed at authorized Mercedes centers. No repainting or modifications.';

  @override
  String get adsPhoneDescription =>
      'Brand-new, unused device with a valid local warranty, complete accessories, and invoice. The serial number and specifications have been matched against the attached documents.';

  @override
  String get adsVillaDescription =>
      'Luxury modern villa with contemporary design and high-quality finishes in a prime location close to amenities. Building permit and property documents are available for review.';

  @override
  String get adsCheckPrice => 'Price and financial terms are compliant';

  @override
  String get adsCheckPhotos => 'Photos are authentic and match the item';

  @override
  String get adsCheckSpecifications =>
      'Specifications match the safety inspection';

  @override
  String get adsCheckMerchantLicense =>
      'Trade license and authorized persons are valid';

  @override
  String get adsCheckExpiryReminder =>
      'Expires in 90 days - automatic reminder enabled';

  @override
  String get adsCheckReminder => 'Reminder';

  @override
  String get adsCheckReviewRecommended => 'Review';

  @override
  String get adsCheckPassed => 'Checked';

  @override
  String get finRequestReadOnlyNotice =>
      'Financial actions are restricted to the CFO';

  @override
  String get finRequestMerchantProceeds => 'Pending merchant proceeds';

  @override
  String get finRequestTotalProceeds => '142,500';

  @override
  String get finRequestProceedsNote => 'Within your supervision scope';

  @override
  String get finRequestReviewQueue => 'With finance';

  @override
  String get finRequestUnderReview => 'Under financial review';

  @override
  String get finRequestHistoryTitle => 'Operations and claims history';

  @override
  String get finRequestUpdatedJustNow => 'Updated just now';

  @override
  String get finRequestAllFilter => 'All (3)';

  @override
  String get finRequestSalesFilter => 'Sales profit';

  @override
  String get finRequestWithdrawalFilter => 'Balance withdrawals';

  @override
  String get finRequestPackageFilter => 'Package fees';

  @override
  String get finRequestNoResults => 'No requests match this category';

  @override
  String get finRequestCarMerchant => 'Al-Ufuq Car Trading Est.';

  @override
  String get finRequestCarTitle => 'Sales profit transfer request';

  @override
  String get finRequestCarAmount => '48,000';

  @override
  String get finRequestTodayTime => 'Today, 10:45 AM';

  @override
  String get finRequestBankVerified => 'IBAN verified and field-approved';

  @override
  String get finRequestPackageMerchant => 'Al-Safwa Electronics Store';

  @override
  String get finRequestPackageTitle => 'Annual Gold package subscription fee';

  @override
  String get finRequestPackageAmount => '3,500';

  @override
  String get finRequestYesterdayTime => 'Yesterday, 4:15 PM';

  @override
  String get finRequestCompleted => 'Completed and finance-approved';

  @override
  String get finRequestApprovedByFinance => 'Approved by: General Accounts';

  @override
  String get finRequestJewelryMerchant => 'Golden Sparkle Jewelry';

  @override
  String get finRequestWithdrawalTitle => 'Wallet balance withdrawal request';

  @override
  String get finRequestWithdrawalAmount => '22,000';

  @override
  String get finRequestOlderTime => 'October 20, 2:20 PM';

  @override
  String get finRequestAwaitingManager => 'Awaiting CFO approval';

  @override
  String get finRequestSalesMatched => 'Sales statements fully reconciled';

  @override
  String get finRequestCurrency => 'SAR';

  @override
  String get finRequestRestrictedStatus => 'Ready for reconciliation';

  @override
  String get finRequestSendToFinance => 'Send to finance supervisor';

  @override
  String get finRequestViewDetails => 'View request details';

  @override
  String get finRequestPolicyTitle => 'Dual-review policy';

  @override
  String get finRequestPolicyMessage =>
      'Every financial request needs final finance approval. Merchant supervisors can view and track requests only.';

  @override
  String get finRequestNumber => 'Request number';

  @override
  String get finRequestClose => 'Close';

  @override
  String get merchantProfileName => 'Ahmed bin Abdulaziz Al-Shehri';

  @override
  String get merchantProfileRegion =>
      'Field Merchant Supervisor - Riyadh Region';

  @override
  String get merchantProfileSupervisorId => 'SUP-4092';

  @override
  String get merchantProfileActive => 'Active and verified';

  @override
  String get merchantProfileMonthlyAds => 'Ads this month';

  @override
  String get merchantProfileStores => 'Active merchants under your supervision';

  @override
  String get withdrawalRequestDetails => 'View request details';

  @override
  String get withdrawalDetailsTitle => 'Withdrawal request details';

  @override
  String get withdrawalDetailsRequestNumber => 'Request number';

  @override
  String get withdrawalDetailsBeneficiary => 'Beneficiary';

  @override
  String get withdrawalDetailsBeneficiaryRole => 'Beneficiary role';

  @override
  String get withdrawalDetailsGrossAmount => 'Gross amount';

  @override
  String get withdrawalDetailsFeePercentage => 'Fee percentage';

  @override
  String get withdrawalDetailsFeeAmount => 'Fee amount';

  @override
  String get withdrawalDetailsNetAmount => 'Net amount';

  @override
  String get withdrawalDetailsBankName => 'Bank';

  @override
  String get withdrawalDetailsIban => 'IBAN';

  @override
  String get withdrawalDetailsDate => 'Request date';

  @override
  String get withdrawalDetailsAuditResult => 'Audit result';

  @override
  String get withdrawalDetailsAlert => 'Regulatory note';

  @override
  String get withdrawalDetailsSource => 'Source of funds';

  @override
  String get withdrawalDetailsTransferMethod => 'Transfer method';

  @override
  String get withdrawalDetailsInstantReady => 'Available for instant transfer';

  @override
  String get withdrawalDetailsStatusPending => 'Pending review';

  @override
  String get withdrawalDetailsStatusInvestigation =>
      'Under investigation and audit';

  @override
  String get withdrawalDetailsStatusApproved => 'Approved';

  @override
  String get withdrawalDetailsStatusFrozen => 'Frozen';

  @override
  String get withdrawalDetailsStatusRejected => 'Rejected';

  @override
  String get withdrawalDetailsNoValue => 'Not available';

  @override
  String get merchantProfileDocumentsTitle =>
      'Approved oversight files and documents';

  @override
  String get merchantProfileAuthorizationCard =>
      'Field Supervisory Authorization Card';

  @override
  String get merchantProfileValidUntil => 'Valid through December 31, 2025';

  @override
  String get merchantProfileOpenDocument => 'View card';

  @override
  String get merchantProfileGovernanceGuide =>
      'Advertising Approval Standards Guide';

  @override
  String get merchantProfileGuideSubtitle =>
      'Advertising policies and regulations';

  @override
  String get merchantProfileDelegationDocument =>
      'Management Authority Delegation Document';

  @override
  String get merchantProfileDelegationSubtitle =>
      'Legal compliance and decision matrix';

  @override
  String get merchantProfileFieldPermissions =>
      'Field Contact and Permissions Management';

  @override
  String get merchantProfileUpdatedAutomatically => 'Updated automatically';

  @override
  String get merchantProfileAvailability => 'Field Availability and Readiness';

  @override
  String get merchantProfileAvailabilitySubtitle =>
      'Receive field review requests';

  @override
  String get merchantProfileDirectNotifications =>
      'Direct Advertisement Alerts';

  @override
  String get merchantProfileNotificationsSubtitle =>
      'Instant alert when an ad is submitted or qualified';

  @override
  String get merchantProfileLocalOnlyNotice =>
      'Changes are stored on this device only; notification delivery is not connected.';

  @override
  String get merchantProfileLocalAuditNotice =>
      'This local history records profile changes made on this device only; it is not a server audit log.';

  @override
  String get merchantProfileNoLocalActivity =>
      'No local profile changes recorded yet.';

  @override
  String get merchantProfilePreferenceUpdated => 'Profile preference changed';

  @override
  String get merchantProfileEnabled => 'Enabled';

  @override
  String get merchantProfileDisabled => 'Disabled';

  @override
  String get merchantProfileLoadError =>
      'Could not load saved profile settings.';

  @override
  String get merchantProfileSaveError =>
      'Could not save this setting on the device. Please try again.';

  @override
  String get merchantProfileRetry => 'Retry';

  @override
  String get merchantProfileSecurityAudit =>
      'Security and Administrative Audit';

  @override
  String get merchantProfileChangeSettings => 'Change settings';

  @override
  String get merchantAuditSuspended => 'Merchant suspended';

  @override
  String get merchantAuditUnsuspended => 'Merchant suspension lifted';

  @override
  String get merchantAuditFinancialSubmitted =>
      'Financial request referred to finance';

  @override
  String get merchantAuditFinancialRejected => 'Financial request rejected';

  @override
  String get merchantAuditAdModerated => 'Merchant advertisement reviewed';

  @override
  String get merchantAuditCommissionUpdated => 'Merchant commission updated';

  @override
  String get merchantAuditLoadError =>
      'Could not load the supervisory activity log.';

  @override
  String get merchantProfileViewAll => 'Full history';

  @override
  String get merchantProfileLatestActivities => 'Latest supervisory activities';

  @override
  String get merchantProfileToday => 'Today';

  @override
  String get merchantProfileActivityApproved =>
      'Approved an ad campaign: Afaq Perfumes Store';

  @override
  String get merchantProfileLicenseNumber => 'License number: LIC-9902';

  @override
  String get merchantProfileActivityEdit =>
      'Ad edit request: Elite Kitchens Showroom';

  @override
  String get merchantProfileActivityEditDetails =>
      'Pricing clarity standard violation';

  @override
  String get merchantProfileActivityLocation =>
      'Field visit and location verified: Al-Mada Markets';

  @override
  String get merchantProfileActivityLocationDetails => 'Al-Sahafa branch';

  @override
  String get merchantProfileFinancialWallet =>
      'My Wallet and Financial Information';

  @override
  String get merchantWalletTitle => 'Your wallet';

  @override
  String get merchantWalletSupervisorStatus =>
      'Verified supervisor • Independent and Waselni sector';

  @override
  String get merchantWalletReady => 'Active and ready';

  @override
  String get merchantWalletAvailableBalance =>
      'Balance available for instant withdrawal';

  @override
  String get merchantWalletAvailableAmount => '8,450';

  @override
  String get merchantWalletBalanceDescription =>
      'Includes approved field supervision dues and verification allowances, ready for instant transfer.';

  @override
  String get merchantWalletPendingDues => 'Under financial review';

  @override
  String get merchantWalletPendingAmount => '4,050';

  @override
  String get merchantWalletTotalDues => 'Total entitlements';

  @override
  String get merchantWalletTotalAmount => '12,500';

  @override
  String get merchantWalletSettlementCycle => 'Regular weekly settlement cycle';

  @override
  String get merchantWalletReadiness => 'Payout readiness: 68%';

  @override
  String get merchantWalletWithdrawTitle =>
      'Request withdrawal of financial dues';

  @override
  String get merchantWalletNoTransferFees => 'No transfer fees';

  @override
  String get merchantWalletRequestedAmount => 'Requested withdrawal amount';

  @override
  String get merchantWalletFullBalance => 'Withdraw full balance (SAR 8,450)';

  @override
  String get merchantWalletTransferLimit =>
      'Minimum withdrawal is SAR 100; daily maximum is SAR 20,000';

  @override
  String get merchantWalletChooseMethod => 'Choose a transfer destination';

  @override
  String get merchantWalletBankTransfer => 'Bank transfer';

  @override
  String get merchantWalletIban => 'IBAN';

  @override
  String get merchantWalletDigitalWallet => 'Digital wallet';

  @override
  String get merchantWalletWalletProvider => 'VFC / E&';

  @override
  String get merchantWalletInstantTransfer => 'InstaPay';

  @override
  String get merchantWalletInstant => 'Instant';

  @override
  String get merchantWalletTransferAddress =>
      'Instant payment address (IPA) or linked phone number';

  @override
  String get merchantWalletIbanValue => 'SA0380000000608010167519';

  @override
  String get merchantWalletPhoneValue => '01012345678';

  @override
  String get merchantWalletInstantAddress => 'supervisor.audit@instapay';

  @override
  String get merchantWalletAccountName =>
      'Registered account name: Abdulrahman Al-Shehri (verified)';

  @override
  String get merchantWalletProcessingDetails =>
      'Processing speed: instant, 24/7\nProcessing and transfer fee: SAR 0.5 (fully covered for the supervisor)';

  @override
  String get merchantWalletConfirmWithdrawal =>
      'Confirm and request withdrawal';

  @override
  String get merchantWalletBonusTitle =>
      'Weekly achievement bonus available! +500';

  @override
  String get merchantWalletBonusDescription =>
      'Completed 5 field tasks successfully, exceeding the defined standards.';

  @override
  String get merchantWalletTransactionHistory =>
      'Recent operations and transfers';

  @override
  String get merchantWalletTransactionBank => 'Bank withdrawal - Al Rajhi Bank';

  @override
  String get merchantWalletTransactionDateOne => 'Yesterday, 2:40 PM';

  @override
  String get merchantWalletTransactionAmountOne => '-5,000';

  @override
  String get merchantWalletTransactionInstant => 'Instant transfer - InstaPay';

  @override
  String get merchantWalletTransactionDateTwo => 'October 21';

  @override
  String get merchantWalletTransactionAmountTwo => '-2,200';

  @override
  String get merchantWalletCompleted => 'Completed';

  @override
  String get merchantWalletAuditNotice =>
      'Financial operations are encrypted and subject to Waselni accounting oversight';

  @override
  String get merchantWalletAuditCode =>
      'Periodic verification code: AUDIT-SEC-2024-v9';

  @override
  String get merchantWalletActionUnavailable =>
      'Withdrawal requests are not available yet';

  @override
  String get merchantProfileJustUpdated => 'Updated just now';

  @override
  String get merchantProfileBalanceTitle => 'Available balance and dues';

  @override
  String get merchantProfileBalance => '14,850';

  @override
  String get merchantProfileBalanceDetails =>
      'Field supervision allowance + verification dues';

  @override
  String get merchantProfileWalletDetails => 'Wallet details';

  @override
  String get merchantProfileDocumentDetails => 'Approved supervisor document';

  @override
  String get merchantProfileDocumentNumber => 'Document number';

  @override
  String get merchantProfileClose => 'Close';

  @override
  String get merchantProfileMinutesUnit => 'minutes ago';

  @override
  String get merchantProfileTwoHoursAgo => '2 hours ago';

  @override
  String get merchantProfileMorningAbbreviation => 'AM';

  @override
  String get merchantInfoTitle => 'Merchant information';

  @override
  String get merchantInfoProfile => 'Merchant profile';

  @override
  String get merchantInfoLiveMonitoring => 'Live monitoring';

  @override
  String get merchantInfoStatusActive => 'Active';

  @override
  String get merchantInfoStatusActiveVerified => 'Active & verified';

  @override
  String get merchantInfoStatusUnderAudit => 'Under review';

  @override
  String get merchantInfoStatusUpdateRequired => 'Update required';

  @override
  String get merchantInfoStatusSuspended => 'Temporarily suspended';

  @override
  String merchantInfoAccreditedCategory(Object category) {
    return 'Accredited in $category';
  }

  @override
  String get merchantInfoTotalAds => 'Total ads';

  @override
  String merchantInfoActiveAds(Object count) {
    return '$count active';
  }

  @override
  String merchantInfoAdsUnderReview(Object count) {
    return '$count under review';
  }

  @override
  String get merchantInfoAdsShort => 'AD';

  @override
  String get merchantInfoAdsGroup => 'Ads';

  @override
  String get merchantInfoPendingOperations => 'Pending operations';

  @override
  String get merchantInfoSuspendTemporarily => 'Suspend temporarily';

  @override
  String get merchantInfoMessageMerchant => 'Message merchant';

  @override
  String get merchantInfoActionUnavailable =>
      'This action is not connected yet';

  @override
  String get merchantPendingOperationsEmpty =>
      'There are no pending operations or ads for this merchant';

  @override
  String merchantPendingCount(Object count) {
    return '$count pending operations';
  }

  @override
  String get merchantPendingMoreDetailsUnavailable =>
      'The pending count is known, but the full list details are not currently available.';

  @override
  String get merchantPendingReference => 'Advertisement reference';

  @override
  String get merchantPendingPrice => 'Price';

  @override
  String get merchantPendingApprove => 'Approve';

  @override
  String get merchantPendingReject => 'Reject';

  @override
  String get merchantPendingOperationHandled => 'Advertisement status updated';

  @override
  String get merchantConversationEmpty =>
      'Start a conversation with this merchant';

  @override
  String get merchantConversationInputHint => 'Write a message...';

  @override
  String get merchantConversationSend => 'Send';

  @override
  String get merchantInfoFinancialSettings =>
      'Financial and commission settings';

  @override
  String get merchantInfoMerchantDashboard => 'Merchant dashboard';

  @override
  String get merchantInfoFinancialSettingsDescription =>
      'Control the merchant\'s fees and commission';

  @override
  String get merchantInfoCfoPermission =>
      'Exclusive permissions for the approved finance supervisor';

  @override
  String get merchantInfoSalesCommission => 'Sales commission';

  @override
  String get merchantInfoFixedAmount => 'Fixed amount (SAR)';

  @override
  String get merchantInfoPercentage => 'Percentage (%)';

  @override
  String get merchantInfoAdjustCommission => 'Adjust commission percentage (%)';

  @override
  String get merchantInfoSave => 'Save';

  @override
  String get merchantInfoCommissionExample =>
      'Estimated commission for a sale of SAR 100:';

  @override
  String merchantInfoCommissionValue(Object amount, Object currency) {
    return 'Commission amount: $amount $currency';
  }

  @override
  String get merchantInfoInvalidCommission =>
      'Enter a commission from 0 to 100';

  @override
  String get merchantInfoCommissionSaved => 'Commission updated';

  @override
  String get merchantInfoVerification =>
      'Verification and accreditation details';

  @override
  String get merchantInfoVerifiedBadge => 'Verified data';

  @override
  String get merchantInfoOwner => 'Owner / authorized person';

  @override
  String get merchantInfoPhone => 'Verified phone number';

  @override
  String get merchantInfoEmail => 'Primary email';

  @override
  String get merchantInfoJoinedDate => 'Supervision start date';

  @override
  String get merchantInfoNotProvided => 'Not provided';

  @override
  String get merchantInfoFieldAds => 'Field merchant advertisements';

  @override
  String merchantInfoShowAll(Object count) {
    return 'Show all ($count)';
  }

  @override
  String get merchantInfoNoAds => 'No advertisements are available';

  @override
  String get merchantInfoAdApproved => 'Approved';

  @override
  String get merchantInfoAdUnderReview => 'Under review';

  @override
  String get merchantSuspendBadge => 'High risk';

  @override
  String get merchantSuspendTitle => 'Suspend merchant';

  @override
  String get merchantSuspendSubtitle =>
      'Regulatory and administrative decision';

  @override
  String get merchantSuspendImpact =>
      'Suspending this merchant will hide all of its ads immediately, stop related business activity, and prevent it from receiving new orders until the violation is resolved and the account is reactivated.';

  @override
  String get merchantSuspendDetails => 'Violation and field notes';

  @override
  String merchantSuspendCharacterCount(Object count) {
    return '$count / 500';
  }

  @override
  String get merchantSuspendDetailsHint =>
      'Describe the violation clearly for the merchant in the control panel, and explain the steps required to resolve it...';

  @override
  String get merchantSuspendPrivateNote =>
      'This note is for the merchant\'s official account';

  @override
  String get merchantSuspendAttachments =>
      'Supporting documents and field evidence';

  @override
  String get merchantSuspendUpload =>
      'Tap to attach an inspection report or photos';

  @override
  String get merchantSuspendFileTypes =>
      'Supported formats: PDF, JPG, PNG (up to 10 MB)';

  @override
  String get merchantSuspendDuration => 'Proposed suspension period';

  @override
  String get merchantSuspendReasonCorrection =>
      'Until the violation is corrected';

  @override
  String get merchantSuspendReasonCorrectionDescription =>
      'Recommended, pending a field review';

  @override
  String get merchantSuspendReasonDuration => 'Suspend for 7 days';

  @override
  String get merchantSuspendReasonDurationDescription =>
      'Automatically lift after the period ends';

  @override
  String get merchantSuspendReasonLegal => 'Refer to Legal Affairs';

  @override
  String get merchantSuspendReasonLegalDescription =>
      'Requires a legal investigation and statement';

  @override
  String get merchantSuspendConfirm =>
      'Confirm temporary suspension and notify merchant';

  @override
  String get merchantSuspendCancel => 'Cancel and return to merchant profile';

  @override
  String get noMerchantsFound => 'No merchants match the search criteria';

  @override
  String get merchantsUnderSupervisionTitle => 'Supervised Merchants';

  @override
  String get supervisedAreaLabel =>
      'Supervision Scope: Riyadh Region (Central & North)';

  @override
  String get supervisorFullName =>
      'Supervisor: Ahmed bin Abdulaziz Al-Khudairi';

  @override
  String get totalFieldAccountsTitle => 'Total Field Accounts';

  @override
  String get merchantsUnderYourSupervision => 'Stores Under Your Supervision';

  @override
  String get complianceRate => 'Compliance';

  @override
  String get activeAndVerifiedMetric => 'Active & Verified';

  @override
  String get pendingAlertsMetric => 'Pending Alerts';

  @override
  String get temporarySuspendedMetric => 'Temporary Suspension';

  @override
  String get searchMerchantPlaceholder =>
      'Search by merchant name, code, or CR...';

  @override
  String filterAllWithCount(Object count) {
    return 'All ($count)';
  }

  @override
  String filterActiveWithCount(Object count) {
    return '$count Active & Verified';
  }

  @override
  String filterPendingWithCount(Object count) {
    return '$count Pending Alerts';
  }

  @override
  String filterSuspendedWithCount(Object count) {
    return '$count Temporarily Suspended';
  }

  @override
  String get sortMostActive => 'Sort: Most Active';

  @override
  String get activeAdsHeader => 'Active Ads';

  @override
  String get pendingReviewHeader => 'Pending Review';

  @override
  String get platformCommissionHeader => 'Platform Commission';

  @override
  String get viewProfileAndControl => 'View Profile & Control';

  @override
  String get pendingProfitWithdrawalAlert => 'Pending Profit Withdrawal';

  @override
  String get supervisoryNoteActive => 'Active Supervisory Note';

  @override
  String get deliveryStatusFieldInspection => 'Field Inspection';

  @override
  String get deliveryStatusHeader => 'Delivery Status';

  @override
  String get descriptionStandardsViolation =>
      'Description Standards Violation VR3-858';

  @override
  String get zeroAdsDisplayedSuspended =>
      '0 Displayed Ads (Administrative Precautionary Stop)';

  @override
  String get summonAction => 'Summon';

  @override
  String get reviewViolationAndUnfreeze => 'Review Violation & Unfreeze';

  @override
  String get suspendedBadge => 'Suspended';

  @override
  String get remainingMerchantsTitle =>
      'There are 13 other merchants fully active and compliant';

  @override
  String get remainingMerchantsSubtitle =>
      'Their routine weekly records were inspected successfully';

  @override
  String get loadAndShowRemainingList => 'Load & View Remaining List';

  @override
  String get fieldGovernanceCardTitle =>
      'Field Supervisor Governance & Delegation';

  @override
  String get fieldGovernanceCardBody =>
      'All merchants registered above are directly tied to your field supervision scope under governance and administrative delegation order SUP-4092.';

  @override
  String get addNewMerchantToSupervision => 'Add New Merchant to Supervision';

  @override
  String get retryLoadMerchants => 'Retry';

  @override
  String get merchantNameField => 'Merchant or Store Name';

  @override
  String get merchantCrField => 'Commercial Registration No.';

  @override
  String get merchantPhoneField => 'Verified Phone Number';

  @override
  String get supervisedMerchantsBadge => 'Merchant Supervisor';

  @override
  String get servicesSupervisorTitle => 'Services Supervisor';

  @override
  String get servicesSupervisorBadge => 'Services Supervisor · SRV-01';

  @override
  String get serviceProvidersTab => 'Service providers';

  @override
  String get servicesAccountTab => 'My account';

  @override
  String serviceProvidersCount(int count) {
    return '$count service providers';
  }

  @override
  String get serviceProviderProfileTitle => 'Provider profile and work history';

  @override
  String get serviceProviderAvailableForWork =>
      'Available for immediate task assignments';

  @override
  String get serviceProviderVerified => 'Verified';

  @override
  String get serviceProviderRegistryNumber => 'Commercial registration number';

  @override
  String get serviceProviderViewProfileAndHistory =>
      'View provider profile and history';

  @override
  String get serviceProviderPerformanceTitle =>
      'Operational performance (KPIs)';

  @override
  String get serviceProviderUpdatedNow => 'Live updates';

  @override
  String get serviceProviderCompletedTasks => 'Completed tasks';

  @override
  String get serviceProviderTaskCompletionRate => '99.1% completion rate';

  @override
  String get serviceProviderOverallRating => 'Overall rating';

  @override
  String get serviceProviderRatingOutOfFive => 'Out of 5.0 · 162 ratings';

  @override
  String get serviceProviderOnTimeRate => 'On-time rate';

  @override
  String get serviceProviderPunctualityDetail => 'Reliable field service';

  @override
  String get serviceProviderResponseSpeed => 'Response speed';

  @override
  String get serviceProviderMinutes => 'minutes';

  @override
  String get serviceProviderSpecialtiesTitle =>
      'Official specialties and accreditations';

  @override
  String get serviceProviderSpecialtyAirConditioning =>
      'Split and central AC maintenance and professional duct upgrades';

  @override
  String get serviceProviderSpecialtyAppliances =>
      'Refrigerant charging, recovery and R410A testing to standards';

  @override
  String get serviceProviderSpecialtyElectrical =>
      'Periodic pressure washing and preventive maintenance for residential complexes';

  @override
  String get serviceProviderPlanTitle => 'Accredited professional plan';

  @override
  String get serviceProviderPlanDescription =>
      'Security screening and practical service-quality training';

  @override
  String get serviceProviderPlanTier => '6 technicians';

  @override
  String get serviceProviderRecentTasksTitle =>
      'Recent completed tasks and operations';

  @override
  String get serviceProviderFullHistory => 'Full history';

  @override
  String get serviceProviderViewFullHistory => 'View full history';

  @override
  String get serviceProviderTaskAreaOne => 'Al Malqa district';

  @override
  String get serviceProviderTaskAreaTwo => 'Al Yasmin district';

  @override
  String get serviceProviderTaskAreaThree => 'Al Sahafa district';

  @override
  String get serviceProviderTaskTitleOne => 'Central concealed AC maintenance';

  @override
  String get serviceProviderTaskTitleTwo =>
      'Commercial building refrigerant inspection and refill';

  @override
  String get serviceProviderTaskTitleThree =>
      'Removal and installation of 4 new split units';

  @override
  String get serviceProviderTaskDetailOne =>
      'Thorough and fast service, with inspection completed ahead of schedule.';

  @override
  String get serviceProviderTaskDetailTwo =>
      'Cooling system safety was verified before handover.';

  @override
  String get serviceProviderTaskDetailThree =>
      'Pipe insulation was tested after installation.';

  @override
  String get serviceProviderTaskCompleted => 'Completed and approved';

  @override
  String get serviceProviderHistoryEntryOne =>
      'Central concealed AC maintenance · Al Malqa · 5.0';

  @override
  String get serviceProviderHistoryEntryTwo =>
      'Refrigerant inspection and refill · Al Yasmin · 4.8';

  @override
  String get serviceProviderHistoryEntryThree =>
      'Split unit removal and installation · Al Sahafa · Complete';

  @override
  String get serviceProviderHistoryEntryFour =>
      'Routine AC maintenance · Al Narjis · 5.0';

  @override
  String get serviceProviderHistoryEntryFive =>
      'Electrical wiring inspection · Al Wurud · 4.9';

  @override
  String get servicesComplaintFilters => 'Complaint filters';

  @override
  String get servicesComplaintRequireCompensation =>
      'Require provider compensation';

  @override
  String get servicesComplaintAlreadyClosed =>
      'This complaint is closed; you can review its resolution record.';

  @override
  String get servicesComplaintFiltersHint =>
      'Filter by status or search by complaint ID, client or provider.';

  @override
  String get merchantFeaturedBadge => 'Featured merchant';

  @override
  String get merchantStandardBadge => 'Standard merchant';

  @override
  String get merchantSuspendedSection => 'Suspended merchants';

  @override
  String get merchantUnsuspendAction => 'Lift suspension';

  @override
  String get merchantUnsuspendConfirm =>
      'Reactivate this merchant and remove it from the suspended merchants list?';

  @override
  String get merchantUnsuspendSuccess =>
      'The suspension was lifted and the merchant was restored.';

  @override
  String get merchantSuspendSuccess =>
      'The merchant was suspended and moved to the suspended list.';

  @override
  String get merchantSuspensionSaveError =>
      'Could not save the merchant status. Please try again.';

  @override
  String get merchantFinanceStatusTitle =>
      'Financial supervisor request status';

  @override
  String get merchantFinanceViewStatus => 'View request status';

  @override
  String get merchantFinanceStatusPending =>
      'Under financial supervisor review';

  @override
  String get merchantFinanceStatusApproved => 'Approved';

  @override
  String get merchantFinanceStatusRejected => 'Rejected';

  @override
  String get merchantFinanceStatusOnHold => 'On hold / under investigation';

  @override
  String get merchantFinanceRequestTitle => 'Transaction details';

  @override
  String get merchantFinanceAmountLabel => 'Amount';

  @override
  String get merchantFinanceDateLabel => 'Request date';

  @override
  String get merchantFinanceStatusLabel => 'Status';

  @override
  String get merchantFinanceNoteLabel => 'Request note';

  @override
  String get merchantLinkHasCommercialRegister =>
      'Merchant has a commercial registration';

  @override
  String get merchantLinkLocalScopeNotice =>
      'Without a registration, use the verified phone number. This prototype saves a request only on this device, scoped to your signed-in account; secure shared assignment requires the backend.';

  @override
  String get merchantLinkValidationError =>
      'Enter a merchant name, a valid phone number, and a registration number when applicable.';

  @override
  String get merchantLinkSessionRequired =>
      'Sign in again before submitting a merchant link request.';

  @override
  String get merchantLinkSavedLocally =>
      'Link request saved locally. It has not been sent to the merchant or platform.';

  @override
  String get merchantLinkSaveFailed => 'Could not save the link request.';

  @override
  String get merchantLinkSaving => 'Saving request...';

  @override
  String get adsArchiveTitle => 'Ad archive';

  @override
  String get adsReviewQueueTab => 'Review queue';

  @override
  String get adsPremium => 'Premium';

  @override
  String get adsRegular => 'Standard';

  @override
  String get adsSaveFailed => 'Could not save this decision. Please try again.';

  @override
  String get adsLoadFailed => 'Could not load saved advertisement decisions.';

  @override
  String get adsFrozenStatus => 'Frozen';

  @override
  String get adsFreezeAction => 'Freeze ad';

  @override
  String get adsUnfreezeAction => 'Restore ad';

  @override
  String get finRequestLocalWorkflowNotice =>
      'Requests are stored locally and queued for finance review in this demo. No payment is deducted and no merchant notification is sent.';

  @override
  String get finRequestSentConfirmation =>
      'Request sent to the financial supervisor.';

  @override
  String get finRequestActionFailed =>
      'Could not complete this action. Please try again.';

  @override
  String get finRequestRejectTitle => 'Reject merchant request';

  @override
  String get finRequestRejectReason => 'Enter a reason for the merchant';

  @override
  String get finRequestRejectAction => 'Reject request';

  @override
  String get finRequestRejected => 'Rejected';

  @override
  String get finRequestRejectionSaved => 'Rejection reason saved.';

  @override
  String get financeWalletRequestSubmitted =>
      'Request sent to the financial supervisor for review. No transfer has been made.';

  @override
  String get financeRequestsInProgressTab => 'In progress';

  @override
  String get financeRequestsArchiveTab => 'Archive';

  @override
  String get financeRequestsArchiveSearchHint =>
      'Search by request number, beneficiary, or source';

  @override
  String get financeRequestsArchiveEmpty =>
      'Completed and rejected requests will appear here.';

  @override
  String get financeRequestsArchiveNoResults =>
      'No archived requests match your search or filter.';

  @override
  String get financeRequestsInProgressEmpty =>
      'There are no requests waiting for review.';

  @override
  String get financeRequestRefreshFailed =>
      'The decision was saved, but the request list could not be refreshed.';

  @override
  String get financeRequestListFailed =>
      'Financial requests could not be loaded. Pull down to retry.';

  @override
  String get financeRecordApproval => 'Record approval';

  @override
  String get financeApproveOnlyConfirmation =>
      'Record approval for this request? This does not trigger a transfer. Amount:';

  @override
  String get withdrawalDetailsSourceAccount => 'Request source account';

  @override
  String get withdrawalDetailsOperationType => 'Operation type';

  @override
  String get financeOperationWithdrawal => 'Withdrawal';

  @override
  String get financeOperationDeposit => 'Deposit';

  @override
  String get financeWalletRequestTitle => 'Wallet operation request';

  @override
  String get financeWalletAmountLabel => 'Amount';

  @override
  String get financeWalletInvalidWithdrawalAmount =>
      'Enter a withdrawal amount between SAR 100 and SAR 8,450.';

  @override
  String get financeWalletInvalidDetails =>
      'Enter a valid amount between SAR 100 and SAR 20,000 and provide a payment destination.';

  @override
  String get financeWalletConfirmDepositTitle => 'Confirm deposit request';

  @override
  String get financeWalletConfirmDepositAction => 'Confirm deposit request';

  @override
  String get financeWalletSubmitRequest => 'Send financial request for review';

  @override
  String get financeWalletOperationNote =>
      'The financial supervisor must approve this request. Approval is recorded in the app; no money is moved until a payment service is integrated.';

  @override
  String get departmentPendingAmount => 'Pending balances';

  @override
  String get departmentPendingOnlyFilter => 'With pending balances';

  @override
  String get departmentNoPendingItems => 'No wallets have pending balances.';

  @override
  String get departmentExportReport => 'Export report';

  @override
  String get departmentExportExcel => 'Export to Excel';

  @override
  String get departmentExportPdf => 'Print or save PDF';

  @override
  String get departmentReportName => 'Name';

  @override
  String get departmentReportReference => 'Reference';

  @override
  String get departmentSearchHint => 'Search by name, reference, or status';

  @override
  String get departmentNoSearchResults =>
      'No wallets match these search criteria.';

  @override
  String get departmentViewDetails => 'View wallet details';

  @override
  String get departmentStatusLabel => 'Account status';

  @override
  String get departmentOperationsCount => 'Operation count';

  @override
  String get merchantInfoAdRejected => 'Rejected';

  @override
  String get merchantInfoAdFrozen => 'Frozen';

  @override
  String get merchantInfoAdHidden => 'Hidden';
}
