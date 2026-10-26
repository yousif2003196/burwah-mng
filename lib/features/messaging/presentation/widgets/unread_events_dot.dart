import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

/// نقطة حمراء صغيرة تظهر عند وجود إشعارات غير مقروءة لـ [recipient]
/// (تُستخدم كشارة فوق زر البروفايل في الشريط الملفوف).
class UnreadEventsDot extends StatelessWidget {
  const UnreadEventsDot({super.key, required this.recipient});

  final String recipient;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalEventStore.revision,
      builder: (context, revision, _) => FutureBuilder<List<LocalEvent>>(
        future: LocalEventStore().getEvents(recipient),
        builder: (context, snapshot) {
          final unread =
              snapshot.data?.where((event) => !event.isRead).length ?? 0;
          if (unread == 0) return const SizedBox.shrink();
          return Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
          );
        },
      ),
    );
  }
}
