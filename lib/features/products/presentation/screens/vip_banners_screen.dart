import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/features/products/data/datasources/vip_banner_api_data_source.dart';
import 'package:barwah_app/features/products/domain/entities/vip_banner.dart';

/// إدارة بنرات قسم VIP: صورة بعنوان وتفاصيل وعرض، مرتبطة بإعلان أو مستقلة.
class VipBannersScreen extends StatefulWidget {
  const VipBannersScreen({super.key});

  @override
  State<VipBannersScreen> createState() => _VipBannersScreenState();
}

class _VipBannersScreenState extends State<VipBannersScreen> {
  List<VipBanner> _banners = const [];
  bool _loading = true;
  Object? _error;

  VipBannerApiDataSource get _api => sl<VipBannerApiDataSource>();
  bool get _ar => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final banners = await _api.load();
      if (!mounted) return;
      setState(() {
        _banners = banners;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _edit([VipBanner? banner]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BannerForm(banner: banner, arabic: _ar),
    );
    if (saved == true) {
      await _load();
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        _ar ? 'تم حفظ البنر' : 'Banner saved',
      );
    }
  }

  Future<void> _toggle(VipBanner banner, bool active) async {
    try {
      await _api.setActive(banner.id, active);
      await _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(context, '$error'.replaceFirst('Bad state: ', ''));
    }
  }

  Future<void> _delete(VipBanner banner) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_ar ? 'حذف البنر' : 'Delete banner'),
        content: Text(
          _ar
              ? 'سيُحذف "${banner.title}" نهائيًا من قسم VIP.'
              : '"${banner.title}" will be removed from the VIP section for good.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_ar ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _ar ? 'حذف' : 'Delete',
              style: TextStyle(color: AppColors.dangerDark),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.delete(banner.id);
      await _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(context, '$error'.replaceFirst('Bad state: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _ar ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_ar ? 'بنرات VIP' : 'VIP banners'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.ink,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(_ar ? 'إضافة بنر' : 'Add banner'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : BrandRefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    Text(
                      _ar
                          ? 'تظهر البنرات النشطة للمستخدمين ضمن المعروض في قسم VIP. البنر المرتبط بإعلان يفتح الإعلان عند الضغط، وغير المرتبط يفتح صفحة تفاصيله.'
                          : 'Active banners appear in the VIP section. A banner linked to an ad opens that ad; one without opens its own details page.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          _ar ? 'تعذر تحميل البنرات. اسحب للتحديث.' : 'Could not load banners. Pull to refresh.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    else if (_banners.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Text(
                          _ar ? 'لا توجد بنرات بعد. أضف أول بنر.' : 'No banners yet. Add the first one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    for (final banner in _banners) ...[
                      _BannerTile(
                        banner: banner,
                        arabic: _ar,
                        onEdit: () => _edit(banner),
                        onDelete: () => _delete(banner),
                        onToggle: (v) => _toggle(banner, v),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({
    required this.banner,
    required this.arabic,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final VipBanner banner;
  final bool arabic;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final ends = banner.endsAt;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: AppColors.surfaceLight,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
                if (!banner.isActive || banner.expired)
                  ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        banner.expired
                            ? (arabic ? 'انتهى' : 'Expired')
                            : (arabic ? 'مخفي' : 'Hidden'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (banner.offerText != null || banner.discountPercent != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (banner.offerText != null) banner.offerText!,
                      if (banner.discountPercent != null) '${banner.discountPercent}%',
                    ].join(' • '),
                    style: TextStyle(color: AppColors.warningDark, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  [
                    banner.advertisementId != null
                        ? (arabic
                            ? 'مرتبط بالإعلان #${banner.advertisementId}'
                            : 'Linked to ad #${banner.advertisementId}')
                        : (arabic ? 'صورة فقط (يفتح التفاصيل)' : 'Image only (opens details)'),
                    if (ends != null)
                      (arabic ? 'ينتهي ' : 'Ends ') + DateFormat('yyyy/MM/dd').format(ends),
                  ].join(' • '),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Switch(value: banner.isActive, onChanged: onToggle),
                    Text(
                      arabic ? 'ظاهر للمستخدمين' : 'Visible',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: arabic ? 'تعديل' : 'Edit',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: arabic ? 'حذف' : 'Delete',
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, color: AppColors.dangerDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerForm extends StatefulWidget {
  const _BannerForm({required this.banner, required this.arabic});

  final VipBanner? banner;
  final bool arabic;

  @override
  State<_BannerForm> createState() => _BannerFormState();
}

class _BannerFormState extends State<_BannerForm> {
  late final _title = TextEditingController(text: widget.banner?.title);
  late final _details = TextEditingController(text: widget.banner?.details);
  late final _offer = TextEditingController(text: widget.banner?.offerText);
  late final _discount = TextEditingController(
    text: widget.banner?.discountPercent?.toString() ?? '',
  );

  Uint8List? _imageBytes;
  String _imageName = 'banner.jpg';
  DateTime? _endsAt;
  int? _adId;
  String? _adTitle;
  bool _active = true;
  bool _saving = false;
  String? _error;

  bool get _ar => widget.arabic;
  bool get _editing => widget.banner != null;

  @override
  void initState() {
    super.initState();
    final banner = widget.banner;
    if (banner != null) {
      _endsAt = banner.endsAt;
      _adId = banner.advertisementId;
      _active = banner.isActive;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    _offer.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.image);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.isEmpty) {
        setState(() => _error = _ar ? 'تعذر تحميل الصورة.' : 'Could not load the image.');
        return;
      }
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = _ar ? 'تعذر اختيار الصورة.' : 'Could not pick the image.');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endsAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) {
      // ينتهي البنر في آخر لحظة من اليوم المختار.
      setState(() => _endsAt = DateTime(picked.year, picked.month, picked.day, 23, 59));
    }
  }

  Future<void> _pickAd() async {
    List<({int id, String title})> ads;
    try {
      ads = await sl<VipBannerApiDataSource>().loadApprovedAds();
    } catch (_) {
      ads = const [];
    }
    if (!mounted) return;
    final chosen = await showDialog<({int id, String title})?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(_ar ? 'اختر الإعلان' : 'Choose the ad'),
        children: [
          if (ads.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_ar ? 'لا توجد إعلانات مقبولة.' : 'No approved ads.'),
            ),
          SizedBox(
            width: double.maxFinite,
            height: ads.isEmpty ? 0 : 360,
            child: ListView(
              children: [
                for (final ad in ads)
                  ListTile(
                    title: Text(ad.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('#${ad.id}'),
                    onTap: () => Navigator.pop(context, ad),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen != null) {
      setState(() {
        _adId = chosen.id;
        _adTitle = chosen.title;
      });
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final discountText = _discount.text.trim();
    final discount = discountText.isEmpty ? null : int.tryParse(discountText);
    String? error;
    if (title.isEmpty) {
      error = _ar ? 'اكتب عنوان البنر.' : 'Enter a title.';
    } else if (!_editing && _imageBytes == null) {
      error = _ar ? 'ارفع صورة البنر.' : 'Upload the banner image.';
    } else if (discountText.isNotEmpty && (discount == null || discount < 1 || discount > 100)) {
      error = _ar ? 'نسبة الخصم بين 1 و 100.' : 'Discount must be 1–100.';
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await sl<VipBannerApiDataSource>().save(
        id: widget.banner?.id,
        title: title,
        details: _details.text,
        offerText: _offer.text,
        discountPercent: discount,
        endsAt: _endsAt,
        advertisementId: _adId,
        clearAdvertisement: _adId == null && widget.banner?.advertisementId != null,
        isActive: _active,
        imageBytes: _imageBytes,
        imageName: _imageName,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '$e'.replaceFirst('Bad state: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingUrl = widget.banner?.imageUrl;
    return Directionality(
      textDirection: _ar ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editing ? (_ar ? 'تعديل البنر' : 'Edit banner') : (_ar ? 'بنر جديد' : 'New banner'),
                style: TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _saving ? null : _pickImage,
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                        : existingUrl != null
                            ? Image.network(existingUrl, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined, size: 34),
                                  const SizedBox(height: 6),
                                  Text(_ar ? 'اضغط لرفع صورة البنر' : 'Tap to upload the banner image'),
                                ],
                              ),
                  ),
                ),
              ),
              if (_editing)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: _saving ? null : _pickImage,
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: Text(_ar ? 'تغيير الصورة' : 'Change image'),
                  ),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _title,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: _ar ? 'العنوان' : 'Title',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _offer,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: _ar ? 'العرض (سطر قصير، اختياري)' : 'Offer line (optional)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _discount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _ar ? 'نسبة الخصم % (اختياري)' : 'Discount % (optional)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _details,
                minLines: 3,
                maxLines: 6,
                maxLength: 3000,
                decoration: InputDecoration(
                  labelText: _ar ? 'التفاصيل الكاملة' : 'Full details',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickAd,
                icon: const Icon(Icons.link),
                label: Text(
                  _adId == null
                      ? (_ar ? 'ربط بإعلان (اختياري)' : 'Link to an ad (optional)')
                      : (_ar
                          ? 'الإعلان #$_adId${_adTitle == null ? '' : ' — $_adTitle'}'
                          : 'Ad #$_adId${_adTitle == null ? '' : ' — $_adTitle'}'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_adId != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _adId = null;
                              _adTitle = null;
                            }),
                    child: Text(_ar ? 'إلغاء الربط (صورة فقط)' : 'Unlink (image only)'),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _endsAt == null
                      ? (_ar ? 'تاريخ الانتهاء (اختياري)' : 'End date (optional)')
                      : (_ar ? 'ينتهي ' : 'Ends ') + DateFormat('yyyy/MM/dd').format(_endsAt!),
                ),
              ),
              if (_endsAt != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _saving ? null : () => setState(() => _endsAt = null),
                    child: Text(_ar ? 'بدون تاريخ انتهاء' : 'No end date'),
                  ),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: _saving ? null : (v) => setState(() => _active = v),
                title: Text(_ar ? 'ظاهر للمستخدمين' : 'Visible to users'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: TextStyle(color: AppColors.dangerDark, fontSize: 12)),
                ),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_ar ? 'حفظ' : 'Save'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
