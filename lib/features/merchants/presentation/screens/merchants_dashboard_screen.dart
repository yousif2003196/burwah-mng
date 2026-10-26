import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_cubit.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_supervisor_local_store.dart';
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_cubit.dart';
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_state.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_details_screen.dart';
import 'package:barwah_app/features/merchants/presentation/widgets/merchant_card.dart';
import 'package:barwah_app/features/merchants/presentation/widgets/merchant_search_filter_bar.dart';
import 'package:barwah_app/features/merchants/presentation/widgets/supervisor_app_bar.dart';
import 'package:barwah_app/features/merchants/presentation/widgets/supervisor_header_card.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class MerchantsDashboardScreen extends StatefulWidget {
  final bool showAppBar;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLinkNewMerchant;

  const MerchantsDashboardScreen({
    super.key,
    this.showAppBar = true,
    this.onNotificationTap,
    this.onProfileTap,
    this.onLinkNewMerchant,
  });

  @override
  State<MerchantsDashboardScreen> createState() =>
      _MerchantsDashboardScreenState();
}

class _MerchantsDashboardScreenState extends State<MerchantsDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, bool> _suspensionOverrides = const {};

  @override
  void initState() {
    super.initState();
    MerchantSupervisorLocalStore.revision.addListener(_loadSuspensionOverrides);
    _loadSuspensionOverrides();
  }

  @override
  void dispose() {
    MerchantSupervisorLocalStore.revision
        .removeListener(_loadSuspensionOverrides);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuspensionOverrides() async {
    try {
      final overrides =
          await MerchantSupervisorLocalStore.getSuspensionOverrides();
      if (mounted) setState(() => _suspensionOverrides = overrides);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'merchant suspension status refresh',
      ));
    }
  }

  void _showAddMerchantSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final crController = TextEditingController();
    final phoneController = TextEditingController();
    var hasCommercialRegister = true;
    var isSaving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) => Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: MotionIcon(
                        Icons.storefront_outlined,
                        color: AppColors.ink,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.addNewMerchantToSupervision,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.supervisedAreaLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.merchantNameField,
                    hintText: 'مثال: شركة الرواد للتجارة',
                    prefixIcon: const MotionIcon(Icons.business_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: crController,
                  keyboardType: TextInputType.number,
                  enabled: hasCommercialRegister,
                  decoration: InputDecoration(
                    labelText: l10n.merchantCrField,
                    hintText: '1010XXXXXX',
                    prefixIcon: const MotionIcon(Icons.badge_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: hasCommercialRegister,
                  title: Text(l10n.merchantLinkHasCommercialRegister),
                  onChanged: (value) => setSheetState(
                    () => hasCommercialRegister = value ?? true,
                  ),
                ),
                if (!hasCommercialRegister)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      l10n.merchantLinkLocalScopeNotice,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.merchantPhoneField,
                    hintText: '+966 5X XXX XXXX',
                    prefixIcon: const MotionIcon(Icons.phone_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final currentName = nameController.text.trim();
                          final currentPhone = phoneController.text.trim();
                          final digits = currentPhone.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          final currentCr = crController.text.trim();
                          if (currentName.isEmpty ||
                              digits.length < 9 ||
                              (hasCommercialRegister && currentCr.isEmpty)) {
                            AppSnackBar.showError(
                              context,
                              l10n.merchantLinkValidationError,
                            );
                            return;
                          }
                          final authState = context.read<AuthCubit>().state;
                          if (authState is! AuthSuccess) {
                            AppSnackBar.showError(
                              context,
                              l10n.merchantLinkSessionRequired,
                            );
                            return;
                          }
                          setSheetState(() => isSaving = true);
                          try {
                            final preferences =
                                await SharedPreferences.getInstance();
                            final key =
                                'merchant_link_requests_${authState.user.id}';
                            final existing = preferences.getString(key);
                            final records = existing == null
                                ? <dynamic>[]
                                : jsonDecode(existing) as List<dynamic>;
                            records.add({
                              'id':
                                  'MER-LINK-${DateTime.now().microsecondsSinceEpoch}',
                              'merchantName': currentName,
                              'commercialRegistration':
                                  hasCommercialRegister ? currentCr : null,
                              'phone': currentPhone,
                              'createdAt': DateTime.now().toIso8601String(),
                            });
                            final saved = await preferences.setString(
                              key,
                              jsonEncode(records),
                            );
                            if (!saved) {
                              throw StateError(
                                'Could not save the merchant link request.',
                              );
                            }
                            final linkedMerchants = preferences
                                .getString('merchant_linked_merchants_v1');
                            final linkedRecords = linkedMerchants == null
                                ? <dynamic>[]
                                : jsonDecode(linkedMerchants) as List<dynamic>;
                            linkedRecords.add(records.last);
                            final linkedSaved = await preferences.setString(
                              'merchant_linked_merchants_v1',
                              jsonEncode(linkedRecords),
                            );
                            if (!linkedSaved) {
                              throw StateError(
                                  'Could not add the merchant to the supervised list.');
                            }
                            try {
                              await LocalEventStore().publish(
                                LocalEvent(
                                  id: 'merchant-linked-${records.last['id']}',
                                  recipient: 'merchant',
                                  source: 'merchants',
                                  titleAr: 'تم ربط حسابك بالإشراف',
                                  titleEn: 'Your account is now supervised',
                                  messageAr:
                                      'تمت إضافة $currentName إلى قائمة التجار الخاضعين للإشراف. رقم الطلب: ${records.last['id']}',
                                  messageEn:
                                      '$currentName was added to the supervised merchants list. Request: ${records.last['id']}',
                                  createdAt: DateTime.now(),
                                ),
                              );
                            } on Object catch (error, stackTrace) {
                              FlutterError.reportError(
                                FlutterErrorDetails(
                                  exception: error,
                                  stack: stackTrace,
                                  library: 'merchant linking notification',
                                ),
                              );
                            }
                            if (!sheetContext.mounted) return;
                            Navigator.of(sheetContext).pop();
                            context.read<MerchantsCubit>().loadMerchants();
                            AppSnackBar.showInfo(
                              context,
                              l10n.merchantLinkSavedLocally,
                            );
                          } catch (error, stackTrace) {
                            FlutterError.reportError(
                              FlutterErrorDetails(
                                exception: error,
                                stack: stackTrace,
                                library: 'merchant supervision link request',
                              ),
                            );
                            if (sheetContext.mounted) {
                              setSheetState(() => isSaving = false);
                              AppSnackBar.showError(
                                context,
                                l10n.merchantLinkSaveFailed,
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isSaving
                        ? l10n.merchantLinkSaving
                        : l10n.addNewMerchantToSupervision,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      crController.dispose();
      phoneController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: widget.showAppBar
          ? SupervisorAppBar(
              onNotificationTap: widget.onNotificationTap,
              onProfileTap: widget.onProfileTap,
            )
          : null,
      body: BlocBuilder<MerchantsCubit, MerchantsState>(
        builder: (context, state) {
          if (state is MerchantsLoading || state is MerchantsInitial) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.ink,
              ),
            );
          }

          if (state is MerchantsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MotionIcon(Icons.error_outline,
                        color: AppColors.danger, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<MerchantsCubit>().loadMerchants(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                      ),
                      child: const Text('إعادة المحاولة',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          final loadedState = state as MerchantsLoaded;

          return RefreshIndicator(
            color: AppColors.primaryDark,
            onRefresh: () => context.read<MerchantsCubit>().loadMerchants(),
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  children: [
                    // 1. Supervisor Welcome & Stats Header Card
                    ScrollFx(child: SupervisorHeaderCard(stats: loadedState.stats)),

                    const SizedBox(height: 16),

                    // 2. Search & Category Filters Bar
                    ScrollFx(child: MerchantSearchFilterBar(
                      searchController: _searchController,
                      stats: loadedState.stats,
                      selectedFilterIndex: loadedState.selectedFilterIndex,
                      onSearchChanged: (query) =>
                          context.read<MerchantsCubit>().searchMerchants(query),
                      onClearSearch: () {
                        _searchController.clear();
                        context.read<MerchantsCubit>().searchMerchants('');
                      },
                      onFilterSelected: (index) =>
                          context.read<MerchantsCubit>().setFilterIndex(index),
                    )),

                    const SizedBox(height: 16),

                    // 3. Section Header: [Stores Under Supervision] [5 of 18] [Recently Active]
                    ScrollFx(child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Recently Active sort button
                        InkWell(
                          onTap: () {
                            AppSnackBar.showInfo(
                              context,
                              'تم ترتيب القائمة حسب الأحدث نشاطاً',
                              duration: const Duration(seconds: 1),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MotionIcon(Icons.swap_vert,
                                    size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.recentlyActiveSort,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Section Title & Badge
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBorder,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  l10n.storesRatio(
                                    loadedState.filteredMerchants.length
                                        .toString(),
                                    loadedState.allMerchants.length.toString(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  l10n.registeredStoresSection,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),

                    const SizedBox(height: 12),

                    // 4. Merchants List
                    if (loadedState.filteredMerchants.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Column(
                            children: [
                              MotionIcon(Icons.storefront_outlined,
                                  size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                l10n.noMerchantsFound,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...loadedState.filteredMerchants.map(
                        (merchant) => MerchantCard(
                          merchant: merchant,
                          isLocallySuspended: _suspensionOverrides[merchant.id],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MerchantDetailsScreen(
                                  merchant: merchant,
                                  isLocallySuspended:
                                      _suspensionOverrides[merchant.id],
                                ),
                              ),
                            );
                          },
                          onActionTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    MerchantDetailsScreen(merchant: merchant),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),

                // Floating Action Button: [ربط تاجر جديد]
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddMerchantSheet(context),
                    icon: const MotionIcon(Icons.store_mall_directory_outlined,
                        size: 18, color: Colors.white),
                    label: Text(
                      l10n.linkNewMerchant,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
