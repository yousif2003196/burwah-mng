import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class ProductSupervisorSupportScreen extends StatelessWidget {
  const ProductSupervisorSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        title: Text(
          l10n.productSupportTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScrollFx(child: _SupportCard(
            icon: Icons.support_agent_outlined,
            title: l10n.productAdminSupportTitle,
            detail: l10n.productAdminSupportDetail,
          )),
          const SizedBox(height: 10),
          ScrollFx(child: _SupportCard(
            icon: Icons.computer_outlined,
            title: l10n.productTechnicalSupportTitle,
            detail: l10n.productTechnicalSupportDetail,
          )),
          const SizedBox(height: 18),
          Text(
            l10n.productSupportContactTitle,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
          const SizedBox(height: 10),
          ScrollFx(child: _ContactTile(
            icon: Icons.supervisor_account_outlined,
            title: l10n.productHeadSupervisorName,
            subtitle: l10n.productHeadSupervisorRole,
            actionLabel: l10n.productSupportOpenChat,
            onTap: () => _openChat(context),
          )),
          const SizedBox(height: 8),
          ScrollFx(child: _ContactTile(
            icon: Icons.support_agent_outlined,
            title: l10n.productTechnicalSupportName,
            subtitle: l10n.productTechnicalSupportHours,
            actionLabel: l10n.productSupportOpenChat,
            onTap: () => _openChat(context),
          )),
          const SizedBox(height: 18),
          ScrollFx(child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                MotionIcon(Icons.schedule_outlined, color: AppColors.infoDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.productSupportHours,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AccountConversationsScreen(accountId: 'products'),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceLight,
            child: MotionIcon(icon, color: AppColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(detail,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: MotionIcon(icon, color: AppColors.infoDark),
        title: Text(title,
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: TextButton(onPressed: onTap, child: Text(actionLabel)),
        onTap: onTap,
      ),
    );
  }
}
