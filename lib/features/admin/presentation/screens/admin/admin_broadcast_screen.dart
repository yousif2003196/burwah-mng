import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_extra_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// مركز الإشعارات: بث لكل المشرفين / كل رؤساء المشرفين / إشعار فردي لأي حساب.
class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  int _target = 0; // 0 كل المشرفين، 1 كل الرؤساء، 2 فردي
  int _account = 0;

  // مفتاح المستلم كما تقرأه صناديق الوارد في كل حساب.
  static const _accounts = <(String, Bi)>[
    ('finance', (ar: 'المشرف المالي', en: 'Finance supervisor')),
    ('merchant', (ar: 'مشرف التجار', en: 'Merchants supervisor')),
    ('products', (ar: 'مشرف المنتجات', en: 'Products supervisor')),
    ('wasalny', (ar: 'مشرف وصلني', en: 'Wasalny supervisor')),
    ('services', (ar: 'مشرف الخدمات', en: 'Services supervisor')),
    ('head', (ar: 'رئيس المشرفين', en: 'Head supervisor')),
  ];
  static const _allSupervisors = [
    'finance',
    'merchant',
    'products',
    'wasalny',
    'services',
  ];

  bool _sending = false;
  final List<(DateTime, String, int)> _sent = [];

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty || body.isEmpty) {
      AppSnackBar.showWarning(
        context,
        adminText(context,
            ar: 'اكتب العنوان ونص الإشعار أولاً', en: 'Enter a title and message first'),
      );
      return;
    }
    final recipients = switch (_target) {
      0 => _allSupervisors,
      1 => const ['head'],
      _ => [_accounts[_account].$1],
    };
    final targetLabel = switch (_target) {
      0 => adminText(context, ar: 'كل المشرفين', en: 'all supervisors'),
      1 => adminText(context, ar: 'كل رؤساء المشرفين', en: 'all head supervisors'),
      _ => _accounts[_account].$2.of(context),
    };
    setState(() => _sending = true);
    try {
      final now = DateTime.now();
      await LocalEventStore().publishAll([
        for (final recipient in recipients)
          LocalEvent(
            id: 'admin-broadcast-${now.microsecondsSinceEpoch}-$recipient',
            recipient: recipient,
            source: 'admin',
            titleAr: title,
            titleEn: title,
            messageAr: body,
            messageEn: body,
            createdAt: now,
          ),
      ]);
      if (!mounted) return;
      setState(() {
        _sent.insert(0, (now, targetLabel, recipients.length));
        _title.clear();
        _body.clear();
      });
      AppSnackBar.showSuccess(
        context,
        adminText(context,
            ar: 'تم إرسال الإشعار إلى $targetLabel',
            en: 'Notification sent to $targetLabel'),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin broadcast',
      ));
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context,
            ar: 'تعذر إرسال الإشعار. حاول مرة أخرى.',
            en: 'Could not send the notification. Try again.'),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0.5,
        title: Text(
          adminText(context, ar: 'مركز الإشعارات والبث', en: 'Notification center'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: AdminPage(
        children: [
          AdminSegmentedTabs(
            labels: [
              adminText(context, ar: 'كل المشرفين', en: 'All supervisors'),
              adminText(context, ar: 'كل الرؤساء', en: 'All heads'),
              adminText(context, ar: 'فردي', en: 'Individual'),
            ],
            icons: const [
              Icons.groups_2_outlined,
              Icons.workspace_premium_outlined,
              Icons.person_outline,
            ],
            selected: _target,
            onChanged: (i) => setState(() => _target = i),
          ),
          const SizedBox(height: 14),
          if (_target == 2) ...[
            DropdownButtonFormField<int>(
              initialValue: _account,
              decoration:
                  _decoration(adminText(context, ar: 'الحساب المستلم', en: 'Recipient account')),
              items: [
                for (var i = 0; i < _accounts.length; i++)
                  DropdownMenuItem(value: i, child: Text(_accounts[i].$2.of(context))),
              ],
              onChanged: (v) => setState(() => _account = v ?? 0),
            ),
            const SizedBox(height: 6),
            Text(
              adminText(context,
                  ar: 'التجار والمناديب والعملاء (borwah) يتطلبون الربط بالخادم.',
                  en: 'Merchants, couriers and customers (borwah) need the backend connection.'),
              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _title,
            decoration: _decoration(adminText(context, ar: 'عنوان الإشعار', en: 'Title')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            minLines: 4,
            maxLines: 6,
            decoration: _decoration(adminText(context, ar: 'نص الإشعار', en: 'Message')),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _sending ? null : _send,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const MotionIcon(Icons.send_rounded),
              label: Text(
                adminText(context, ar: 'إرسال الإشعار', en: 'Send notification'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (_sent.isNotEmpty) ...[
            AdminSectionTitle(
              icon: Icons.history_rounded,
              title: adminText(context, ar: 'آخر الإرسالات', en: 'Recent sends'),
              trailing: '${_sent.length}',
            ),
            for (final item in _sent.take(5)) ...[
              AdminListRow(
                icon: Icons.check_circle_outline,
                color: AppColors.successDark,
                title: item.$2,
                subtitle:
                    '${item.$1.hour.toString().padLeft(2, '0')}:${item.$1.minute.toString().padLeft(2, '0')} • ${adminText(context, ar: '${item.$3} حساب', en: '${item.$3} account(s)')}',
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}
