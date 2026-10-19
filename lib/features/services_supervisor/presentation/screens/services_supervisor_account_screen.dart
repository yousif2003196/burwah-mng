import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'services_supervisor_wallet_screen.dart';

class ServicesSupervisorAccountScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ServicesSupervisorAccountScreen({super.key, required this.onLogout});

  @override
  State<ServicesSupervisorAccountScreen> createState() =>
      _ServicesSupervisorAccountScreenState();
}

class _ServicesSupervisorAccountScreenState
    extends State<ServicesSupervisorAccountScreen> {
  static const _storageKey = 'services_supervisor_account_state_v1';

  _AccountData _data = const _AccountData();
  bool _isLoading = true;
  bool _isSaving = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_storageKey);
      final loaded = encoded == null
          ? const _AccountData()
          : _AccountData.fromJson(
              jsonDecode(encoded) as Map<String, dynamic>,
            );
      if (!mounted) return;
      setState(() {
        _data = loaded;
        _isLoading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _save(_AccountData next, String action) async {
    setState(() => _isSaving = true);
    final updated = next.copyWith(
      activity: [
        _AccountActivity(action: action, occurredAt: DateTime.now()),
        ...next.activity,
      ].take(100).toList(growable: false),
    );
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _storageKey,
        jsonEncode(updated.toJson()),
      );
      if (!saved) {
        throw StateError('Could not save services supervisor account data.');
      }
      if (!mounted) return;
      setState(() {
        _data = updated;
        _isSaving = false;
      });
      _showMessage(AppLocalizations.of(context)!.servicesAccountSaved);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage(
        AppLocalizations.of(context)!.servicesAccountSaveError('$error'),
      );
    }
  }

  Future<void> _editProfile(AppLocalizations l10n) async {
    final nameController = TextEditingController(text: _data.name);
    final phoneController = TextEditingController(text: _data.phone);
    final coverageController = TextEditingController(text: _data.coverage);
    try {
      final result = await showDialog<_ProfileFormValue>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.servicesAccountEditProfile),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.servicesAccountName,
                  ),
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.servicesAccountPhone,
                  ),
                ),
                TextField(
                  controller: coverageController,
                  decoration: InputDecoration(
                    labelText: l10n.servicesAccountCoverage,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.servicesAccountLocalOnly,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.logoutCancel),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  _showMessage(l10n.servicesAccountNameRequired);
                  return;
                }
                Navigator.of(dialogContext).pop(
                  _ProfileFormValue(
                    name: name,
                    phone: phoneController.text.trim(),
                    coverage: coverageController.text.trim(),
                  ),
                );
              },
              child: Text(l10n.servicesAccountSave),
            ),
          ],
        ),
      );
      if (result == null || !mounted) return;
      await _save(
        _data.copyWith(
          name: result.name,
          phone: result.phone,
          coverage: result.coverage,
        ),
        'profileUpdated',
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
      coverageController.dispose();
    }
  }

  Future<void> _updatePreference({
    required bool assignments,
    required bool complaints,
    required bool system,
  }) =>
      _save(
        _data.copyWith(
          assignmentAlerts: assignments,
          complaintAlerts: complaints,
          systemAlerts: system,
        ),
        'notificationPreferencesUpdated',
      );

  Future<void> _confirmLogout(AppLocalizations l10n) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.servicesAccountLogoutTitle),
        content: Text(l10n.servicesAccountLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.logoutCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (shouldLogout == true) widget.onLogout();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildLoadError(l10n)
              : _buildAccount(context, l10n),
    );
  }

  Widget _buildLoadError(AppLocalizations l10n) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.servicesAccountLoadError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _load,
                child: Text(l10n.servicesAccountRetry),
              ),
            ],
          ),
        ),
      );

  Widget _buildAccount(BuildContext context, AppLocalizations l10n) {
    final displayName =
        _data.name.isEmpty ? l10n.servicesProfileName : _data.name;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFEAF0F7),
                child: Icon(
                  Icons.person_outline,
                  size: 38,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.servicesSupervisorRoleBadge,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (_data.phone.isNotEmpty || _data.coverage.isNotEmpty) ...[
                const SizedBox(height: 10),
                if (_data.phone.isNotEmpty)
                  _ProfileDetail(
                    icon: Icons.phone_outlined,
                    text: _data.phone,
                  ),
                if (_data.coverage.isNotEmpty)
                  _ProfileDetail(
                    icon: Icons.location_on_outlined,
                    text: _data.coverage,
                  ),
              ],
              const SizedBox(height: 12),
              Text(
                l10n.servicesAccountLocalOnly,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : () => _editProfile(l10n),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.servicesAccountEditProfile),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: l10n.servicesAccountNotificationsTitle,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.servicesAccountAssignmentAlerts),
              value: _data.assignmentAlerts,
              onChanged: _isSaving
                  ? null
                  : (value) => _updatePreference(
                        assignments: value,
                        complaints: _data.complaintAlerts,
                        system: _data.systemAlerts,
                      ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.servicesAccountComplaintAlerts),
              value: _data.complaintAlerts,
              onChanged: _isSaving
                  ? null
                  : (value) => _updatePreference(
                        assignments: _data.assignmentAlerts,
                        complaints: value,
                        system: _data.systemAlerts,
                      ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.servicesAccountSystemAlerts),
              value: _data.systemAlerts,
              onChanged: _isSaving
                  ? null
                  : (value) => _updatePreference(
                        assignments: _data.assignmentAlerts,
                        complaints: _data.complaintAlerts,
                        system: value,
                      ),
            ),
            Text(
              l10n.servicesAccountPreferencesLocalOnly,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: l10n.servicesAccountWalletTitle,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primaryDark,
              ),
              title: Text(l10n.servicesProfileOpenWallet),
              subtitle: Text(l10n.servicesProfileWalletDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const ServicesSupervisorWalletScreen(
                    owner: SupervisorWalletOwner.services,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: l10n.servicesAccountActivityTitle,
          children: [
            if (_data.activity.isEmpty)
              Text(
                l10n.servicesAccountNoActivity,
                style: const TextStyle(color: AppColors.textSecondary),
              )
            else
              for (final entry in _data.activity.take(10))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: Text(_activityLabel(entry.action, l10n)),
                  subtitle: Text(
                    MaterialLocalizations.of(context).formatFullDate(
                      entry.occurredAt.toLocal(),
                    ),
                  ),
                ),
            Text(
              l10n.servicesAccountActivityLocalOnly,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _isSaving ? null : () => _confirmLogout(l10n),
          icon: const Icon(Icons.logout),
          label: Text(l10n.logout),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.cardBorder),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _activityLabel(String action, AppLocalizations l10n) =>
      switch (action) {
        'profileUpdated' => l10n.servicesAccountActivityProfileUpdated,
        'notificationPreferencesUpdated' =>
          l10n.servicesAccountActivityPreferencesUpdated,
        _ => l10n.servicesAccountActivityOther,
      };
}

class _AccountData {
  final String name;
  final String phone;
  final String coverage;
  final bool assignmentAlerts;
  final bool complaintAlerts;
  final bool systemAlerts;
  final List<_AccountActivity> activity;

  const _AccountData({
    this.name = '',
    this.phone = '',
    this.coverage = '',
    this.assignmentAlerts = true,
    this.complaintAlerts = true,
    this.systemAlerts = true,
    this.activity = const [],
  });

  factory _AccountData.fromJson(Map<String, dynamic> json) {
    final activities = json['activity'];
    if (activities != null && activities is! List<dynamic>) {
      throw const FormatException('Invalid services supervisor activity log.');
    }
    return _AccountData(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      coverage: json['coverage'] as String? ?? '',
      assignmentAlerts: json['assignmentAlerts'] as bool? ?? true,
      complaintAlerts: json['complaintAlerts'] as bool? ?? true,
      systemAlerts: json['systemAlerts'] as bool? ?? true,
      activity: [
        for (final value in activities as List<dynamic>? ?? const [])
          _AccountActivity.fromJson(value as Map<String, dynamic>),
      ],
    );
  }

  _AccountData copyWith({
    String? name,
    String? phone,
    String? coverage,
    bool? assignmentAlerts,
    bool? complaintAlerts,
    bool? systemAlerts,
    List<_AccountActivity>? activity,
  }) =>
      _AccountData(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        coverage: coverage ?? this.coverage,
        assignmentAlerts: assignmentAlerts ?? this.assignmentAlerts,
        complaintAlerts: complaintAlerts ?? this.complaintAlerts,
        systemAlerts: systemAlerts ?? this.systemAlerts,
        activity: activity ?? this.activity,
      );

  Map<String, Object> toJson() => {
        'name': name,
        'phone': phone,
        'coverage': coverage,
        'assignmentAlerts': assignmentAlerts,
        'complaintAlerts': complaintAlerts,
        'systemAlerts': systemAlerts,
        'activity': activity.map((entry) => entry.toJson()).toList(),
      };
}

class _AccountActivity {
  final String action;
  final DateTime occurredAt;

  const _AccountActivity({
    required this.action,
    required this.occurredAt,
  });

  factory _AccountActivity.fromJson(Map<String, dynamic> json) =>
      _AccountActivity(
        action: json['action'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
      );

  Map<String, String> toJson() => {
        'action': action,
        'occurredAt': occurredAt.toIso8601String(),
      };
}

class _ProfileFormValue {
  final String name;
  final String phone;
  final String coverage;

  const _ProfileFormValue({
    required this.name,
    required this.phone,
    required this.coverage,
  });
}

class _ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProfileDetail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(child: Text(text)),
          ],
        ),
      );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      );
}
