import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class AdReviewFact {
  final IconData icon;
  final String label;
  final String value;

  const AdReviewFact({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class AdReviewChecklistItem {
  final String title;
  final String status;
  final String? subtitle;
  final bool passed;

  const AdReviewChecklistItem({
    required this.title,
    required this.status,
    this.subtitle,
    this.passed = true,
  });
}

class AdvertisementReviewDetailsScreen extends StatefulWidget {
  final String merchant;
  final String merchantCategory;
  final String merchantRegistrationNumber;
  final String adNumber;
  final double initialDeliveryFee;
  final String submittedAt;
  final String title;
  final String description;
  final String price;
  final int photoCount;
  final IconData imageIcon;
  final Color imageColor;
  final List<AdReviewFact> facts;
  final List<AdReviewChecklistItem> checklist;
  final VoidCallback onApprove;
  final VoidCallback onHide;
  final VoidCallback onReject;
  final ValueChanged<String> onRequestEdit;
  final ValueChanged<double> onFeeUpdated;

  const AdvertisementReviewDetailsScreen({
    super.key,
    required this.merchant,
    required this.merchantCategory,
    required this.merchantRegistrationNumber,
    required this.adNumber,
    this.initialDeliveryFee = 150,
    required this.submittedAt,
    required this.title,
    required this.description,
    required this.price,
    required this.photoCount,
    required this.imageIcon,
    required this.imageColor,
    required this.facts,
    required this.checklist,
    required this.onApprove,
    required this.onHide,
    required this.onReject,
    required this.onRequestEdit,
    required this.onFeeUpdated,
  });

  @override
  State<AdvertisementReviewDetailsScreen> createState() =>
      _AdvertisementReviewDetailsScreenState();
}

class _AdvertisementReviewDetailsScreenState
    extends State<AdvertisementReviewDetailsScreen> {
  late final TextEditingController _feeController;
  int _selectedPhoto = 0;
  bool _hideAfterReports = false;
  bool _feeError = false;

  @override
  void initState() {
    super.initState();
    _feeController = TextEditingController(
      text: widget.initialDeliveryFee.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.adsDetailsTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryDark,
              child: MotionIcon(Icons.person_outline, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ScrollFx(child: _merchantCard(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: _advertisementCard(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: _checklistCard(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: _deliveryCard(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: _supervisorDecisionCard(l10n)),
        ],
      ),
    );
  }

  Widget _merchantCard(AppLocalizations l10n) {
    return _card(
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              _pill(l10n.adsInImageReviewStatus, AppColors.infoLight,
                  AppColors.info, Icons.circle),
              _pill(l10n.adsNotPublishedYet, AppColors.surfaceLight,
                  AppColors.textSecondary, Icons.visibility_off_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MotionIcon(Icons.storefront_outlined,
                    color: AppColors.ink),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.merchant,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.merchantCategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 9),
                    ),
                    Text(
                      l10n.adsMerchantRegistrationNumber(
                        widget.merchantRegistrationNumber,
                      ),
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _pill(l10n.adsMerchantVerified, AppColors.infoLight,
                  AppColors.info, Icons.verified),
            ],
          ),
        ],
      ),
    );
  }

  Widget _advertisementCard(AppLocalizations l10n) {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Container(
                  height: 210,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.imageColor.withValues(alpha: 0.75),
                        AppColors.cardBorder,
                        widget.imageColor,
                      ],
                    ),
                  ),
                  child: Center(
                    child: MotionIcon(widget.imageIcon,
                        size: 120, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ),
                PositionedDirectional(
                  top: 10,
                  end: 10,
                  child: _pill(
                    l10n.adsPhotoPosition(
                      (_selectedPhoto + 1).toString(),
                      widget.photoCount.toString(),
                    ),
                    AppPalette.overlayCC07172C,
                    Colors.white,
                    Icons.photo_camera_outlined,
                  ),
                ),
                PositionedDirectional(
                  top: 10,
                  start: 10,
                  child: _pill(
                    l10n.adsAdPhotoVerified,
                    Colors.white,
                    AppColors.info,
                    Icons.verified,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 62,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: widget.photoCount,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) => InkWell(
                onTap: () => setState(() => _selectedPhoto = index),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  width: 48,
                  decoration: BoxDecoration(
                    color: widget.imageColor.withValues(
                        alpha: index == _selectedPhoto ? 0.55 : 0.25),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: index == _selectedPhoto
                          ? AppColors.info
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: MotionIcon(widget.imageIcon,
                      size: 23, color: AppColors.ink),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.adsIdentifier(widget.adNumber),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ),
                    MotionIcon(Icons.schedule,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(widget.submittedAt,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.adsAskingPrice,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: CountText(
                          widget.price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.25,
                  children:
                      widget.facts.map((fact) => _factTile(fact)).toList(),
                ),
                const SizedBox(height: 12),
                _sectionTitle(l10n.adsAdDescription, Icons.subject),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _factTile(AdReviewFact fact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          MotionIcon(fact.icon, size: 16, color: AppColors.info),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(fact.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 8)),
                CountText(fact.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistCard(AppLocalizations l10n) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(l10n.adsLicenseChecklist, Icons.checklist_rtl,
              trailing: l10n.adsChecklistCount(
                  widget.checklist.where((item) => item.passed).length,
                  widget.checklist.length)),
          const SizedBox(height: 12),
          ...widget.checklist.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  MotionIcon(
                    item.passed
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: item.passed
                        ? AppColors.ink
                        : AppColors.textMuted,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item.title,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: AppColors.ink, fontSize: 11)),
                        if (item.subtitle != null)
                          Text(item.subtitle!,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: AppColors.info, fontSize: 9)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.status,
                      style: TextStyle(
                          color:
                              item.passed ? AppColors.info : AppColors.danger,
                          fontSize: 9)),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _hideAfterReports,
              onChanged: (value) => setState(() => _hideAfterReports = value),
              title: Text(l10n.adsAutoHideReportsTitle,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: AppColors.ink, fontSize: 11)),
              subtitle: Text(l10n.adsAutoHideReportsDescription,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryCard(AppLocalizations l10n) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(l10n.adsDeliveryTitle, Icons.local_shipping_outlined,
              trailing: l10n.adsDeliveryActive),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(l10n.adsDeliveryDescription,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _feeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end,
                  onChanged: (_) {
                    if (_feeError) setState(() => _feeError = false);
                  },
                  decoration: InputDecoration(
                    labelText: l10n.adsDeliveryFee,
                    suffixText: l10n.finRequestCurrency,
                    errorText: _feeError ? l10n.adsFeeInvalid : null,
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () {
                  final fee = double.tryParse(_feeController.text);
                  if (fee == null || !fee.isFinite || fee < 0) {
                    setState(() => _feeError = true);
                    return;
                  }
                  widget.onFeeUpdated(fee);
                },
                icon: const MotionIcon(Icons.tune, size: 16),
                label: Text(l10n.adsUpdateDeliveryFee,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.adsDeliveryFeeNote,
              textAlign: TextAlign.end,
              style: TextStyle(color: AppColors.info, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _supervisorDecisionCard(AppLocalizations l10n) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(l10n.adsSupervisorDecision, Icons.gavel,
              trailing: l10n.adsSupervisorLevel),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: widget.onApprove,
              icon: const MotionIcon(Icons.verified_outlined),
              label: Text(l10n.adsApproveAction),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: widget.onHide,
              icon: const MotionIcon(Icons.visibility_off_outlined),
              label: Text(l10n.adsHideAction),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                backgroundColor: AppColors.surfaceLight,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _decisionButton(
                  label: l10n.adsRejectAction,
                  icon: Icons.block,
                  foreground: AppColors.dangerDark,
                  background: AppColors.dangerBorder,
                  onPressed: widget.onReject,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _decisionButton(
                  label: l10n.adsRequestEdit,
                  icon: Icons.edit_note,
                  foreground: AppColors.ink,
                  background: AppColors.surfaceLight,
                  onPressed: () => _showEditRequestSheet(l10n),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decisionButton({
    required String label,
    required IconData icon,
    required Color foreground,
    required Color background,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 44,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: MotionIcon(icon, size: 16),
        label: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10)),
        style: FilledButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }

  Future<void> _showEditRequestSheet(AppLocalizations l10n) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdEditRequestSheet(adTitle: widget.title),
    );
    if (note == null || !mounted) return;
    widget.onRequestEdit(note);
  }

  Widget _sectionTitle(String title, IconData icon, {String? trailing}) {
    return Row(
      children: [
        MotionIcon(icon, color: AppColors.ink, size: 19),
        const SizedBox(width: 7),
        Expanded(
          child: Text(title,
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          _pill(trailing, AppColors.infoLight, AppColors.info, null),
        ],
      ],
    );
  }
}

class _AdEditRequestSheet extends StatefulWidget {
  final String adTitle;

  const _AdEditRequestSheet({required this.adTitle});

  @override
  State<_AdEditRequestSheet> createState() => _AdEditRequestSheetState();
}

class _AdEditRequestSheetState extends State<_AdEditRequestSheet> {
  final TextEditingController _noteController = TextEditingController();
  bool _showRequiredError = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.76,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ScrollFx(child: Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => Navigator.pop(context),
                            tooltip: l10n.adsCancelAction,
                            icon: const MotionIcon(Icons.close, size: 18),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceLight,
                              foregroundColor: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  l10n.adsEditRequestTitle,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  l10n.adsEditRequestAdTitle(widget.adTitle),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          MotionIcon(Icons.edit_document,
                              color: AppColors.info, size: 22),
                        ],
                      )),
                      const Divider(height: 18),
                      ScrollFx(child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.adsEditRequestGuidanceTitle,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                MotionIcon(Icons.edit_note,
                                    color: AppColors.info, size: 18),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.adsEditRequestInstructions,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              key: const ValueKey('ad-edit-request-note'),
                              controller: _noteController,
                              minLines: 4,
                              maxLines: 5,
                              maxLength: 500,
                              textAlign: TextAlign.end,
                              onChanged: (_) {
                                if (_showRequiredError) {
                                  setState(() => _showRequiredError = false);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: l10n.adsEditRequestHint,
                                errorText: _showRequiredError
                                    ? l10n.adsEditRequestRequired
                                    : null,
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.cardBorder),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final note = _noteController.text.trim();
                          if (note.isEmpty) {
                            setState(() => _showRequiredError = true);
                            return;
                          }
                          Navigator.pop(context, note);
                        },
                        icon: const MotionIcon(Icons.send_outlined, size: 17),
                        label: Text(l10n.adsEditRequestSend),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.adsEditRequestCancel,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _pill(String label, Color background, Color foreground, IconData? icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          MotionIcon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
        ],
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: foreground, fontSize: 9, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

Widget _card({required Widget child, EdgeInsets? padding}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: child,
  );
}
