import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/market_branches_api_data_source.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_account.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/market_branch.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_add_supervisor_sheet.dart';

/// فروع سوق برواح: رئيس المشرفين يضيف الفرع وحساب التاجر الخاص به، ويعدّل
/// بياناته، ويطلب حذفه (الحذف يعتمده الأدمن).
class HeadSupervisorMarketBranchesScreen extends StatefulWidget {
  const HeadSupervisorMarketBranchesScreen({super.key});

  @override
  State<HeadSupervisorMarketBranchesScreen> createState() =>
      _HeadSupervisorMarketBranchesScreenState();
}

class _HeadSupervisorMarketBranchesScreenState
    extends State<HeadSupervisorMarketBranchesScreen> {
  MarketBranchesApiDataSource get _api => sl<MarketBranchesApiDataSource>();

  List<MarketBranch> _branches = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final branches = await _api.getBranches();
      if (!mounted) return;
      setState(() {
        _branches = branches;
        _error = null;
        _loading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'market branches',
      ));
      if (!mounted) return;
      setState(() {
        _error = error is HeadSupervisorApiRejection
            ? error.message
            : 'تعذر تحميل فروع سوق برواح من السيرفر.';
        _loading = false;
      });
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm([MarketBranch? branch]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _BranchFormSheet(api: _api, branch: branch),
    );
    if (saved != true || !mounted) return;
    _notice(branch == null
        ? 'تم إنشاء الفرع وحسابه. يدخل التاجر من تطبيق اليوزر بالإيميل والباسورد.'
        : 'تم حفظ بيانات ${branch.name}.');
    await _load();
  }

  Future<void> _requestDeletion(MarketBranch branch) async {
    if (branch.deletionPending) {
      _notice('طلب حذف ${branch.name} قيد مراجعة الأدمن.');
      return;
    }
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(headSupervisorText(dialogContext,
            arabic: 'طلب حذف ${branch.name}', english: 'Delete ${branch.name}')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            headSupervisorText(dialogContext,
                arabic:
                    'الطلب يروح للأدمن. لو وافق، الفرع يختفي من سوق برواح وحسابه يتقفل، وطلباته القديمة تفضل محفوظة.',
                english:
                    'The admin decides. If approved, the branch leaves the market and its account is closed; past orders stay.'),
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: headSupervisorText(dialogContext,
                  arabic: 'سبب الحذف', english: 'Reason'),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(headSupervisorText(dialogContext, arabic: 'إلغاء', english: 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.dangerDark),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(headSupervisorText(dialogContext,
                arabic: 'رفع للأدمن', english: 'Send to admin')),
          ),
        ],
      ),
    );
    final reason = controller.text.trim();
    controller.dispose();
    if (confirmed != true || !mounted) return;
    try {
      await _api.requestDeletion(branch.id, reason: reason.isEmpty ? null : reason);
      if (!mounted) return;
      _notice('تم رفع طلب حذف ${branch.name} للأدمن.');
      await _load();
    } on HeadSupervisorApiRejection catch (rejection) {
      if (mounted) _notice(rejection.message);
    } catch (_) {
      if (mounted) _notice('تعذر رفع طلب الحذف. حاول مرة أخرى.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        title: Text(
          headSupervisorText(context,
              arabic: 'فروع سوق برواح', english: 'Barwah market branches'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const MotionIcon(Icons.add_business_outlined, color: Colors.white),
        label: Text(headSupervisorText(context, arabic: 'إضافة فرع', english: 'Add branch')),
      ),
      body: BrandRefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () {
                      setState(() => _loading = true);
                      _load();
                    },
                    child: Text(headSupervisorText(context,
                        arabic: 'إعادة المحاولة', english: 'Retry')),
                  ),
                ]),
              )
            else if (_branches.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Text(
                  headSupervisorText(context,
                      arabic:
                          'لا توجد فروع بعد. أضف أول فرع، وبعدها حسابه يقدر يضيف الأقسام والمنتجات من تطبيق اليوزر.',
                      english:
                          'No branches yet. Add the first one; its account then adds sections and products from the user app.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              for (final branch in _branches)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BranchCard(
                    branch: branch,
                    onEdit: () => _openForm(branch),
                    onDelete: () => _requestDeletion(branch),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.onEdit,
    required this.onDelete,
  });

  final MarketBranch branch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final (label, color) = branch.deletionPending
        ? ('طلب حذف عند الأدمن', AppColors.dangerDark)
        : branch.isActive
            ? ('ظاهر للعملاء', AppColors.infoDark)
            : ('موقوف عن العملاء', AppColors.textSecondary);
    final place = [branch.address, branch.city, branch.governorate]
        .where((part) => part.trim().isNotEmpty)
        .join(' - ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text(branch.name,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
        ]),
        const SizedBox(height: 8),
        _Line(icon: Icons.location_on_outlined, text: place),
        _Line(icon: Icons.phone_outlined, text: branch.phone),
        _Line(icon: Icons.person_outline, text: 'المسئول العام: ${branch.managerName}'),
        _Line(icon: Icons.mail_outline, text: branch.email),
        _Line(
          icon: Icons.inventory_2_outlined,
          text: '${branch.sectionsCount} قسم · ${branch.productsCount} منتج',
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const MotionIcon(Icons.edit_outlined, size: 16),
              label: const Text('تعديل', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.dangerDark),
              icon: const MotionIcon(Icons.delete_outline, size: 16),
              label: const Text('حذف', style: TextStyle(fontSize: 12)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MotionIcon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
      ]),
    );
  }
}

/// إضافة فرع جديد (مع حسابه) أو تعديل فرع موجود.
class _BranchFormSheet extends StatefulWidget {
  const _BranchFormSheet({required this.api, this.branch});

  final MarketBranchesApiDataSource api;
  final MarketBranch? branch;

  @override
  State<_BranchFormSheet> createState() => _BranchFormSheetState();
}

class _BranchFormSheetState extends State<_BranchFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.branch?.name ?? '');
  late final _phone = TextEditingController(text: widget.branch?.phone ?? '');
  late final _manager = TextEditingController(text: widget.branch?.managerName ?? '');
  late final _address = TextEditingController(text: widget.branch?.address ?? '');
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _active = widget.branch?.isActive ?? true;

  List<EgyptGovernorate> _places = const [];
  bool _placesLoading = true;
  String? _placesError;
  int? _governorateId;
  int? _cityId;
  bool _saving = false;
  String? _error;

  bool get _creating => widget.branch == null;

  @override
  void initState() {
    super.initState();
    _governorateId = widget.branch?.governorateId;
    _cityId = widget.branch?.cityId;
    _loadPlaces();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _manager.dispose();
    _address.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await widget.api.getPlaces();
      if (!mounted) return;
      setState(() {
        _places = places;
        _placesLoading = false;
        _placesError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _placesLoading = false;
        _placesError = 'تعذر تحميل المحافظات والمدن.';
      });
    }
  }

  List<EgyptCity> get _cities =>
      _places.where((g) => g.id == _governorateId).firstOrNull?.cities ?? const [];

  Future<void> _save() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    final draft = MarketBranchDraft(
      name: _name.text,
      phone: _phone.text,
      managerName: _manager.text,
      governorateId: _governorateId!,
      cityId: _cityId!,
      address: _address.text,
      isActive: _active,
      email: _email.text,
      password: _password.text,
    );
    setState(() => _saving = true);
    try {
      final branch = widget.branch;
      if (branch == null) {
        await widget.api.createBranch(draft);
      } else {
        await widget.api.updateBranch(branch.id, draft);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on HeadSupervisorApiRejection catch (rejection) {
      if (mounted) setState(() => _error = rejection.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر الحفظ على السيرفر. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value, String message) =>
      value == null || value.trim().isEmpty ? message : null;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          children: [
            Text(
              _creating ? 'فرع جديد في سوق برواح' : 'تعديل ${widget.branch!.name}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'اسم الفرع'),
              validator: (v) => _required(v, 'اكتب اسم الفرع'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'رقم تليفون الفرع'),
              validator: (v) => v == null || v.trim().length < 8 ? 'اكتب رقم تليفون صحيح' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _manager,
              decoration: const InputDecoration(labelText: 'المسئول العام عن الفرع'),
              validator: (v) => _required(v, 'اكتب اسم المسئول العام'),
            ),
            const SizedBox(height: 14),
            Text('مكان الفرع',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 6),
            if (_placesLoading)
              const LinearProgressIndicator()
            else if (_placesError != null)
              Row(children: [
                Expanded(child: Text(_placesError!, style: TextStyle(color: AppColors.dangerDark))),
                TextButton(
                  onPressed: () {
                    setState(() => _placesLoading = true);
                    _loadPlaces();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ])
            else ...[
              DropdownButtonFormField<int>(
                initialValue: _places.any((g) => g.id == _governorateId) ? _governorateId : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'المحافظة'),
                items: [
                  for (final g in _places) DropdownMenuItem(value: g.id, child: Text(g.name)),
                ],
                onChanged: (value) => setState(() {
                  _governorateId = value;
                  _cityId = null;
                }),
                validator: (v) => v == null ? 'اختر المحافظة' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                key: ValueKey(_governorateId),
                initialValue: _cities.any((c) => c.id == _cityId) ? _cityId : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'المدينة / المركز'),
                items: [
                  for (final c in _cities) DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (value) => setState(() => _cityId = value),
                validator: (v) => v == null ? 'اختر المدينة' : null,
              ),
            ],
            const SizedBox(height: 10),
            TextFormField(
              controller: _address,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'العنوان بالتفصيل (اختياري)'),
            ),
            const SizedBox(height: 4),
            Text(
              'النقطة على الخريطة يحددها حساب الفرع من تطبيق اليوزر (موقع المتجر).',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _active,
              onChanged: (value) => setState(() => _active = value),
              title: const Text('ظاهر للعملاء في سوق برواح', style: TextStyle(fontSize: 13)),
            ),
            if (_creating) ...[
              const Divider(height: 24),
              Text('حساب التاجر الخاص بالفرع',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink)),
              const SizedBox(height: 4),
              Text(
                'إيميل جديد خاص بالفرع. التاجر يدخل بيه من تطبيق اليوزر ويضيف الأقسام والمنتجات، وتظهر في سوق برواح بس.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'إيميل حساب الفرع'),
                validator: (v) {
                  final email = v?.trim() ?? '';
                  return email.contains('@') && email.contains('.') ? null : 'اكتب إيميل صحيح';
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                validator: (v) => supervisorPasswordError(context, v ?? ''),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: AppColors.dangerDark, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving || _placesLoading ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_creating ? 'إنشاء الفرع والحساب' : 'حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }
}
