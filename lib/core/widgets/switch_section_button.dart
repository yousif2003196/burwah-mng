import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

/// زر "تبديل القسم" في الشريط العلوي للأقسام؛ يظهر لحساب الأدمن فقط.
class SwitchSectionButton extends StatelessWidget {
  const SwitchSectionButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.switchSection,
      onPressed: onPressed,
      icon: MotionIcon(Icons.apps_rounded, color: AppColors.ink),
    );
  }
}
