import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/floating_bar.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// تبويبات مقسّمة (Segmented) بعدّاد اختياري، مثل "رؤساء المشرفين (6)".
class AdminSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final List<int?> counts;
  final List<IconData> icons;
  final int selected;
  final ValueChanged<int> onChanged;
  final Color? _countColor;
  Color get countColor => _countColor ?? AppColors.info;

  const AdminSegmentedTabs({
    super.key,
    required this.labels,
    required this.icons,
    required this.selected,
    required this.onChanged,
    this.counts = const [],
    Color? countColor,
  }) : _countColor = countColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.infoBorder),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: i == selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MotionIcon(
                        icons[i],
                        size: 16,
                        color: i == selected
                            ? AppColors.ink
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: i == selected
                                ? AppColors.ink
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (i < counts.length && counts[i] != null) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: i == selected
                                ? countColor.withValues(alpha: 0.15)
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CountText(
                            '${counts[i]}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: i == selected
                                  ? countColor
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// بطاقة مؤشر (KPI): أيقونة + وسم + رقم كبير + وصف + ملاحظة ملوّنة.
class AdminKpiCard extends StatelessWidget {
  final IconData icon;
  final String tag;
  final AdminTone tagTone;
  final String value;
  final String caption;
  final String note;
  final Color? _noteColor;
  Color get noteColor => _noteColor ?? AppColors.textSecondary;
  final Color? _valueColor;
  Color get valueColor => _valueColor ?? AppColors.ink;

  const AdminKpiCard({
    super.key,
    required this.icon,
    required this.tag,
    required this.tagTone,
    required this.value,
    required this.caption,
    required this.note,
    Color? noteColor,
    Color? valueColor,
  }) : _noteColor = noteColor, _valueColor = valueColor;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: adminToneColor(tagTone).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: MotionIcon(icon, size: 18, color: adminToneColor(tagTone)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AdminChip(label: tag, tone: tagTone),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              CountText(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: valueColor == AppColors.ink
                        ? AppColors.textSecondary
                        : valueColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: noteColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة إجراء سريع (أيقونة + عنوان + وصف).
class AdminQuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AdminQuickAction({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MotionIcon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// صندوق معلومات ملوّن (مثل: قواعد الاعتماد المالي / ملاحظات رئيس المشرفين).
class AdminInfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final AdminTone tone;

  const AdminInfoBox({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.tone = AdminTone.info,
  });

  @override
  Widget build(BuildContext context) {
    final color = adminToneColor(tone);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MotionIcon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط علوي: صورة الحساب + عنوان + جرس + مبدّل (الإدارة / السوق PUSE).
class AdminTopBar extends StatelessWidget {
  final String title;
  final int system; // 0 = Admin, 1 = PUSE
  final ValueChanged<int> onSystemChanged;
  final VoidCallback onProfile;
  final VoidCallback onLogout;
  final VoidCallback onNotifications;
  final int unread;

  const AdminTopBar({
    super.key,
    required this.title,
    required this.system,
    required this.onSystemChanged,
    required this.onProfile,
    required this.onLogout,
    required this.onNotifications,
    this.unread = 0,
  });

  static const double height = 56 + 56 + 2 * FloatingBarFrame.verticalGap;

  @override
  Widget build(BuildContext context) {
    return FloatingBarFrame(
      radius: 26,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  PopupMenuButton<int>(
                    tooltip: adminText(context, ar: 'الحساب', en: 'Account'),
                    onSelected: (value) =>
                        value == 0 ? onProfile() : onLogout(),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 0,
                        child: Text(adminText(context,
                            ar: 'الملف الشخصي', en: 'Profile')),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text(adminText(context,
                            ar: 'تسجيل الخروج', en: 'Log out')),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: AppColors.primaryDark,
                              child: MotionIcon(Icons.person_outline,
                                  color: Colors.white, size: 19),
                            ),
                            PositionedDirectional(
                              bottom: -1,
                              end: -1,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        MotionIcon(Icons.keyboard_arrow_down,
                            size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: adminText(context,
                        ar: 'الإشعارات', en: 'Notifications'),
                    onPressed: onNotifications,
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        MotionIcon(Icons.notifications_none_outlined,
                            color: AppColors.ink),
                        if (unread > 0)
                          PositionedDirectional(
                            top: -5,
                            end: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CountText(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _SystemSwitch(
                  selected: system,
                  onChanged: onSystemChanged,
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class _SystemSwitch extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _SystemSwitch({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = [
      adminText(context, ar: 'الإدارة (Admin)', en: 'Admin'),
      adminText(context, ar: 'السوق (PUSE)', en: 'Market (PUSE)'),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: i == selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          i == selected ? FontWeight.bold : FontWeight.w500,
                      color: i == selected
                          ? AppColors.ink
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
