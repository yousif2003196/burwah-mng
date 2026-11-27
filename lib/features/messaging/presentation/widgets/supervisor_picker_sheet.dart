import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// مشرف يقدر رئيس المشرفين يبدأ معاه محادثة.
class ChatSupervisorOption {
  const ChatSupervisorOption({
    required this.id,
    required this.name,
    required this.role,
    required this.code,
    this.frozen = false,
  });

  final int id;
  final String name;

  /// الدور في Identity: SupervisorForAd / SupervisorUsed / ...
  final String role;
  final String code;
  final bool frozen;

  factory ChatSupervisorOption.fromJson(Map<String, dynamic> j) =>
      ChatSupervisorOption(
        id: (j['id'] as num).toInt(),
        name: '${j['name'] ?? ''}'.trim(),
        role: '${j['role'] ?? ''}'.trim(),
        code: '${j['supId'] ?? ''}'.trim(),
        frozen: j['isFrozen'] == true,
      );

  static String roleLabel(String role, bool arabic) => switch (role) {
        'SupervisorForAd' => arabic ? 'مشرف المنتجات' : 'Products supervisor',
        'SupervisorUsed' => arabic ? 'مشرف المستعمل (وصلني)' : 'Used goods supervisor',
        'SupervisorForMerchant' => arabic ? 'مشرف التجار' : 'Merchants supervisor',
        'SupervisorForServices' => arabic ? 'مشرف الخدمات' : 'Services supervisor',
        'Accountant' => arabic ? 'المالية' : 'Finance',
        _ => arabic ? 'مشرف' : 'Supervisor',
      };

  String label(bool arabic) => roleLabel(role, arabic);
}

/// قايمة المشرفين (من `GET api/BossOfSupervisor/supervisors`) مع بحث وفلتر بالقسم.
/// بترجع المشرف اللي اتختار، أو null لو اتقفلت.
class SupervisorPickerSheet extends StatefulWidget {
  const SupervisorPickerSheet({super.key});

  static Future<ChatSupervisorOption?> show(BuildContext context) =>
      showModalBottomSheet<ChatSupervisorOption>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: AppColors.surface,
        builder: (_) => const SupervisorPickerSheet(),
      );

  @override
  State<SupervisorPickerSheet> createState() => _SupervisorPickerSheetState();
}

class _SupervisorPickerSheetState extends State<SupervisorPickerSheet> {
  late Future<List<ChatSupervisorOption>> _future = _load();
  String _query = '';
  String _role = 'all';

  bool get _ar => Localizations.localeOf(context).languageCode == 'ar';

  Future<List<ChatSupervisorOption>> _load() async {
    final response = await sl<ApiConsumer>(instanceName: 'berwah')
        .get<Object>(ApiEndpoints.bossSupervisors);
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    if (data is! List) throw const FormatException('supervisors must be a list');
    return [
      for (final item in data)
        if (item is Map && item['id'] is num)
          ChatSupervisorOption.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  bool _matches(ChatSupervisorOption s) {
    if (_role != 'all' && s.role != _role) return false;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return '${s.name} ${s.code} ${s.label(true)} ${s.label(false)}'
        .toLowerCase()
        .contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.78;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: Text(
                  _ar ? 'ابدأ محادثة مع مشرف' : 'Start a chat with a supervisor',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: _ar
                        ? 'ابحث بالاسم أو الكود أو القسم'
                        : 'Search by name, code or department',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<ChatSupervisorOption>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_ar
                                ? 'تعذر تحميل المشرفين'
                                : 'Could not load supervisors'),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => setState(() => _future = _load()),
                              child: Text(_ar ? 'إعادة المحاولة' : 'Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    final all = snapshot.data ?? const <ChatSupervisorOption>[];
                    final roles = {for (final s in all) s.role}.toList()..sort();
                    final shown = all.where(_matches).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 34,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              _chip('all', _ar ? 'الكل ${all.length}' : 'All ${all.length}'),
                              for (final r in roles)
                                _chip(r, ChatSupervisorOption.roleLabel(r, _ar)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: shown.isEmpty
                              ? Center(
                                  child: Text(
                                    _ar ? 'مفيش مشرفين مطابقين' : 'No matching supervisors',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                                  itemCount: shown.length,
                                  separatorBuilder: (_, __) =>
                                      Divider(height: 1, color: AppColors.borderLight),
                                  itemBuilder: (_, i) => _tile(shown[i]),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String role, String label) {
    final selected = _role == role;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _role = role),
        selectedColor: AppColors.primaryDark,
        backgroundColor: AppColors.surfaceLight,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : AppColors.ink,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
    );
  }

  Widget _tile(ChatSupervisorOption s) {
    final name = s.name.isEmpty ? s.code : s.name;
    final initials = name.trim().isEmpty
        ? '؟'
        : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w.characters.first).join();
    return ListTile(
      onTap: () => Navigator.of(context).pop(s),
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceHighlight,
        child: Text(initials,
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold)),
      ),
      title: Text(name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
      subtitle: Text(
        [s.label(_ar), if (s.code.isNotEmpty) s.code, if (s.frozen) (_ar ? 'معلق' : 'Suspended')]
            .join(' • '),
        style: TextStyle(
          fontSize: 12,
          color: s.frozen ? AppColors.dangerDark : AppColors.textSecondary,
        ),
      ),
      trailing: MotionIcon(Icons.chat_bubble_outline, size: 20, color: AppColors.primaryDark),
    );
  }
}
