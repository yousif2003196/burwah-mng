import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/service_provider_catalog.dart';
import 'package:barwah_app/features/services_supervisor/domain/entities/service_provider.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _ServiceCategory { maintenance, electrical, moving }

class ServicesRequestDetailsScreen extends StatefulWidget {
  final String reference;
  final String service;
  final String provider;
  final String description;
  final String location;
  final String requestedAt;
  final String phone;
  final String price;
  final String diagnosticFee;
  final String workFee;
  final List<String> photoUrls;
  final ServiceProvider? assignedProvider;
  final Future<bool> Function(ServiceProvider) onAssign;
  final IconData icon;
  final String initialCategory;
  final Future<bool> Function() onConfirm;

  const ServicesRequestDetailsScreen({
    super.key,
    required this.reference,
    required this.service,
    required this.provider,
    required this.description,
    required this.location,
    required this.requestedAt,
    required this.phone,
    required this.price,
    required this.diagnosticFee,
    required this.workFee,
    this.photoUrls = const [],
    this.assignedProvider,
    required this.onAssign,
    required this.icon,
    required this.initialCategory,
    required this.onConfirm,
  });

  @override
  State<ServicesRequestDetailsScreen> createState() =>
      _ServicesRequestDetailsScreenState();
}

class _ServicesRequestDetailsScreenState
    extends State<ServicesRequestDetailsScreen> {
  final _additionalInfoController = TextEditingController();
  _ServiceCategory? _selectedCategory;
  ServiceProvider? _selectedProvider;
  bool _requiresPhotos = false;
  bool _isEvening = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _ServiceCategory.values.byName(widget.initialCategory);
    _selectedProvider = widget.assignedProvider;
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: true,
          title: Text(
            l10n.servicesDetailsTitle,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            tooltip: l10n.servicesBackToRequests,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: MotionIcon(
              isArabic ? Icons.arrow_forward : Icons.arrow_back,
              color: AppColors.ink,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 14),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryDark,
                child:
                    MotionIcon(Icons.person_outline, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 92),
          children: [
            ScrollFx(child: _requestHeader(l10n, isArabic)),
            const SizedBox(height: 14),
            ScrollFx(child: _costCard(l10n)),
            const SizedBox(height: 14),
            ScrollFx(child: _serviceWorkCard(l10n)),
            const SizedBox(height: 14),
            ScrollFx(child: _additionalInfoCard(l10n)),
            const SizedBox(height: 14),
            ScrollFx(child: _classificationCard(l10n)),
            const SizedBox(height: 14),
            ScrollFx(child: _assignmentCard(l10n, isArabic)),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _confirmRequest,
              icon: const MotionIcon(Icons.person_add_alt_1_outlined, size: 19),
              label: Text(
                l10n.servicesPublishConfirm,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _requestHeader(AppLocalizations l10n, bool isArabic) {
    return _DetailCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.requestedAt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    MotionIcon(
                      Icons.access_time,
                      color: AppColors.textSecondary,
                      size: 13,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              _Pill(
                label: l10n.servicesUnderReview,
                background: AppColors.infoBorder,
                foreground: AppColors.infoDark,
              ),
              const SizedBox(width: 7),
              _Pill(
                label: '#${widget.reference}',
                background: AppColors.primaryDark,
                foreground: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.provider,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.service,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.blueFill,
                  border: AppColors.blueEdge,
                  boxShadow: AppColors.blueGlow,
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: MotionIcon(widget.icon, color: Colors.white, size: 25),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  label: l10n.servicesCallPhone,
                  icon: Icons.call_outlined,
                  onTap: () => _openContact(
                    Uri(scheme: 'tel', path: widget.phone),
                    l10n,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContactButton(
                  label: l10n.servicesContactWhatsApp,
                  icon: Icons.chat_outlined,
                  onTap: () => _openContact(
                    Uri.https(
                      'wa.me',
                      widget.phone.replaceAll(RegExp(r'[^0-9]'), ''),
                    ),
                    l10n,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceWorkCard(AppLocalizations l10n) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.home_repair_service_outlined,
            title: l10n.servicesRequestWorkDetailsTitle,
          ),
          const SizedBox(height: 10),
          Text(
            widget.description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MotionIcon(
                Icons.location_on_outlined,
                color: AppColors.infoDark,
                size: 19,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.servicesRequestLocationLabel,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.location,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l10n.servicesRequestPhotosTitle,
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.photoUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.photoUrls[index],
                    width: 130,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 130,
                      height: 110,
                      color: AppColors.surfaceLight,
                      alignment: Alignment.center,
                      child: MotionIcon(
                        Icons.broken_image_outlined,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              l10n.servicesRequestNoPhotos,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _assignmentCard(AppLocalizations l10n, bool isArabic) {
    final matchingProviders = serviceProviders.where((provider) {
      final category = switch (provider.category) {
        ServiceProviderCategory.maintenance => _ServiceCategory.maintenance,
        ServiceProviderCategory.electrical => _ServiceCategory.electrical,
        ServiceProviderCategory.moving => _ServiceCategory.moving,
        ServiceProviderCategory.plumbing => null,
      };
      return category == _selectedCategory && provider.available;
    }).toList();

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.person_add_alt_1_outlined,
            title: l10n.servicesRequestAssignmentTitle,
          ),
          const SizedBox(height: 5),
          Text(
            l10n.servicesRequestAssignmentDescription,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<ServiceProvider>(
            initialValue: matchingProviders.contains(_selectedProvider)
                ? _selectedProvider
                : null,
            isExpanded: true,
            decoration: _fieldDecoration(),
            hint: Text(l10n.servicesRequestChooseProvider),
            items: [
              for (final provider in matchingProviders)
                DropdownMenuItem(
                  value: provider,
                  child: Text(
                    isArabic ? provider.nameAr : provider.nameEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (provider) =>
                setState(() => _selectedProvider = provider),
          ),
          if (matchingProviders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.servicesRequestNoMatchingProviders,
                style: TextStyle(color: AppColors.danger, fontSize: 11),
              ),
            ),
          if (_selectedProvider != null) ...[
            const SizedBox(height: 9),
            Text(
              isArabic ? _selectedProvider!.cityAr : _selectedProvider!.cityEn,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 9),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: _selectedProvider == null
                  ? null
                  : () async {
                      final assigned = await widget.onAssign(_selectedProvider!);
                      if (!context.mounted || !assigned) return;
                      AppSnackBar.showSuccess(
                        context,
                        l10n.servicesRequestAssigned(
                          isArabic
                              ? _selectedProvider!.nameAr
                              : _selectedProvider!.nameEn,
                        ),
                      );
                    },
              icon: const MotionIcon(Icons.assignment_turned_in_outlined, size: 18),
              label: Text(l10n.servicesRequestAssignProvider),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _costCard(AppLocalizations l10n) {
    return _DetailCard(
      child: Column(
        children: [
          _SectionTitle(
            icon: Icons.payments_outlined,
            title: l10n.servicesEstimatedCost,
            trailing: _Pill(
              label: l10n.servicesApprovedEstimate,
              background: AppColors.infoBorder,
              foreground: AppColors.infoDark,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.servicesEstimatedCostTotal,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                MotionIcon(
                  Icons.request_quote_outlined,
                  color: AppColors.infoDark,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CountText(
                      widget.price,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.servicesCurrency,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _CostBreakdown(
                  label: l10n.servicesInspectionFee,
                  amount: widget.diagnosticFee,
                  currency: l10n.servicesCurrency,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CostBreakdown(
                  label: l10n.servicesLaborAndPartsFee,
                  amount: widget.workFee,
                  currency: l10n.servicesCurrency,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _additionalInfoCard(AppLocalizations l10n) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.bookmark_added_outlined,
            title: l10n.servicesRequestMoreInfoTitle,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.servicesRequestMoreInfoDescription,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _additionalInfoController,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.servicesRequestMoreInfoHint,
              filled: true,
              fillColor: AppColors.surfaceLight,
              hintStyle: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.info),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: _requiresPhotos,
                onChanged: (value) =>
                    setState(() => _requiresPhotos = value ?? false),
                visualDensity: VisualDensity.compact,
                activeColor: AppColors.ink,
              ),
              Expanded(
                child: Text(
                  l10n.servicesRequireExtraPhotos,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _sendInfoRequest,
                icon: const MotionIcon(Icons.send_outlined, size: 15),
                label: Text(l10n.servicesSendInfoRequest),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.infoLight,
                  foregroundColor: AppColors.ink,
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _classificationCard(AppLocalizations l10n) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.tune,
            title: l10n.servicesEditClassification,
            trailing: _Pill(
              label: l10n.servicesCurrentClassification,
              background: AppColors.surfaceLight,
              foreground: AppColors.infoDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.servicesApprovedClassification,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<_ServiceCategory>(
            initialValue: _selectedCategory,
            isExpanded: true,
            decoration: _fieldDecoration(),
            items: [
              DropdownMenuItem(
                value: _ServiceCategory.maintenance,
                child: Text(l10n.servicesFilterMaintenance),
              ),
              DropdownMenuItem(
                value: _ServiceCategory.electrical,
                child: Text(l10n.servicesFilterElectrical),
              ),
              DropdownMenuItem(
                value: _ServiceCategory.moving,
                child: Text(l10n.servicesFilterMoving),
              ),
            ],
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.servicesExecutionPeriod,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _PeriodButton(
                  selected: !_isEvening,
                  label: l10n.servicesDayPeriod,
                  onTap: () => setState(() => _isEvening = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PeriodButton(
                  selected: _isEvening,
                  label: l10n.servicesEveningPeriod,
                  onTap: () => setState(() => _isEvening = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 42,
            child: FilledButton.icon(
              onPressed: _saveClassification,
              icon: const MotionIcon(Icons.sync, size: 17),
              label: Text(l10n.servicesSaveClassification),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceHighlight,
                foregroundColor: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceLight,
      prefixIcon: MotionIcon(
        Icons.assignment_outlined,
        color: AppColors.infoDark,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _openContact(Uri uri, AppLocalizations l10n) async {
    final opened = await launchUrl(uri);
    if (opened || !mounted) return;
    AppSnackBar.showError(context, l10n.servicesContactUnavailable);
  }

  void _sendInfoRequest() {
    final l10n = AppLocalizations.of(context)!;
    if (_additionalInfoController.text.trim().isEmpty) {
      AppSnackBar.showError(context, l10n.servicesInfoRequestRequired);
      return;
    }
    AppSnackBar.showSuccess(context, l10n.servicesInfoRequestSent);
    _additionalInfoController.clear();
  }

  void _saveClassification() {
    if (_selectedCategory == null) return;
    final l10n = AppLocalizations.of(context)!;
    AppSnackBar.showSuccess(context, l10n.servicesClassificationSaved);
  }

  Future<void> _confirmRequest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.servicesPublishConfirm),
        content: Text(AppLocalizations.of(context)!.servicesApproveMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.logoutCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.servicesPublishConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final resolved = await widget.onConfirm();
    if (resolved && mounted) Navigator.of(context).pop();
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MotionIcon(icon, color: AppColors.infoDark, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ContactButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: MotionIcon(icon, size: 17, color: AppColors.infoDark),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

class _CostBreakdown extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;

  const _CostBreakdown({
    required this.label,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $amount $currency',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 9,
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: MotionIcon(
          selected ? Icons.nightlight_outlined : Icons.wb_sunny_outlined,
          size: 17,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10),
        ),
        style: FilledButton.styleFrom(
          backgroundColor:
              selected ? AppColors.primaryDark : AppColors.surfaceLight,
          foregroundColor: selected ? Colors.white : AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 7),
        ),
      ),
    );
  }
}
