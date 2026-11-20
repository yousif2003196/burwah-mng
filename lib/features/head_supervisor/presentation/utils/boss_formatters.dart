import 'package:flutter/material.dart';

import 'package:barwah_app/core/utils/currency_formatter.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// "منذ X" بالعربي أو الإنجليزي. تاريخ غير معروف يعرض "—".
String bossElapsed(BuildContext context, DateTime? date) {
  if (date == null) return '—';
  final minutes = DateTime.now().difference(date).inMinutes;
  if (minutes < 1) {
    return headSupervisorText(context, arabic: 'الآن', english: 'Just now');
  }
  if (minutes < 60) {
    return headSupervisorText(context,
        arabic: 'منذ $minutes دقيقة', english: '$minutes min ago');
  }
  final hours = minutes ~/ 60;
  if (hours < 24) {
    return headSupervisorText(context,
        arabic: 'منذ $hours ساعة', english: '$hours hr ago');
  }
  final days = hours ~/ 24;
  return headSupervisorText(context,
      arabic: 'منذ $days يوم', english: '$days day(s) ago');
}

/// "اليوم" أو "منذ X يوم".
String bossDayLabel(BuildContext context, DateTime? date) {
  if (date == null) return '—';
  final days = DateTime.now().difference(date).inDays;
  return days == 0
      ? headSupervisorText(context, arabic: 'اليوم', english: 'Today')
      : headSupervisorText(context,
          arabic: 'منذ $days يوم', english: '$days days ago');
}

/// تاريخ ووقت مختصر: `20/11/2026 03:30`.
String bossDateTime(DateTime? date) {
  if (date == null) return '—';
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.day}/${date.month}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}

/// "اليوم 03:30" أو "20/11 03:30".
String bossShortTime(BuildContext context, DateTime? date) {
  if (date == null) return '—';
  final now = DateTime.now();
  final time =
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return headSupervisorText(context, arabic: 'اليوم $time', english: 'Today $time');
  }
  return '${date.day}/${date.month} $time';
}

String bossMoney(double amount, {bool showDecimals = false}) =>
    CurrencyFormatter.format(amount, showDecimals: showDecimals);
