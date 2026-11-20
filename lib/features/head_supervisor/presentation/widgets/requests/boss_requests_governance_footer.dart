import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

class BossRequestsGovernanceFooter extends StatelessWidget {
  const BossRequestsGovernanceFooter({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: AppColors.blueFill,
            border: AppColors.blueEdge,
            boxShadow: AppColors.blueGlow,
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(20)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MotionIcon(Icons.admin_panel_settings_outlined,
              size: 24, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    headSupervisorText(context,
                        arabic: 'صلاحيات الإشراف الإداري والرقابي',
                        english: 'Administrative and oversight authority'),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 5),
                Text(
                    headSupervisorText(context,
                        arabic:
                            'تمنح منصة رئيس المشرفين حق مراجعة القرارات التشغيلية. وتظل القرارات المالية والحسابات مقيدة بموافقة الإدارة المالية وفق المعايير.',
                        english:
                            'The Head Supervisor can review operational decisions. Financial decisions and accounts remain subject to finance approval.'),
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.55,
                        color: Colors.white.withValues(alpha: 0.82))),
              ],
            ),
          ),
        ]),
      );
}
