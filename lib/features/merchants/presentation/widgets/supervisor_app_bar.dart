import 'package:flutter/material.dart';

import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_theme_switcher.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/floating_bar.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class SupervisorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final int unreadNotificationsCount;

  const SupervisorAppBar({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
    this.unreadNotificationsCount = 1,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return SizedBox(
      height: 68 + MediaQuery.paddingOf(context).top,
      child: FloatingBarFrame(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
        children: [
          // Start: Logo, Title, Role Badge, Subtitle
          Expanded(
            child: Row(
              children: [
                // App Logo Container
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.blueFill,
                    border: AppColors.blueEdge,
                    boxShadow: AppColors.blueGlow,
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: MotionIcon(
                      Icons.security_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        runSpacing: 2,
                        children: [
                          // Title: Merchants
                          Text(
                            l10n.merchantsSupervisorTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          // Role Badge Pill [مشرف تجار]
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: AppColors.infoBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MotionIcon(Icons.shield_outlined,
                                    size: 10, color: AppColors.infoDark),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    l10n.merchantSupervisorRoleBadge,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.infoDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        l10n.merchantSupervisorAdminSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // End: Language switcher, Notification Bell & Profile Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppThemeSwitcherButton(dense: true),
              const SizedBox(width: 4),
              // Language switch button
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: AppLocaleController.instance.toggle,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MotionIcon(Icons.language,
                          color: AppColors.ink, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        isArabic ? 'English' : 'العربية',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Notification Bell with Red Badge Dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: MotionIcon(Icons.notifications_none_outlined,
                        size: 22, color: AppColors.textPrimary),
                    onPressed: onNotificationTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (unreadNotificationsCount > 0)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 8),

              // Profile Avatar Button
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.blueFill,
                    border: AppColors.blueEdge,
                    boxShadow: AppColors.blueGlow,
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const MotionIcon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }
}
